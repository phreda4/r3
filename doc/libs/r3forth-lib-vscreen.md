# R3Forth VScreen Library (vscreen.r3)

A virtual screen system for R3Forth that provides resolution-independent rendering with automatic scaling and letterboxing for consistent display across different window sizes.

## Overview

VScreen creates a fixed-size virtual rendering surface that automatically scales to fit the actual window while maintaining aspect ratio. This ensures your game or application looks consistent regardless of the player's screen resolution.

**Key Features:**
- Fixed virtual resolution for consistent rendering
- Automatic aspect ratio preservation
- Letterboxing for non-matching aspect ratios
- Coordinate transformation from window to virtual space
- Smooth scaling with configurable filtering

**Dependencies:**
- `r3/lib/sdl2.r3` - SDL2 graphics functions

---

## Setup

### Virtual Screen Creation

- **`vscreen`** `( w h -- )` - Create virtual screen
  - `w`: Virtual screen width in pixels
  - `h`: Virtual screen height in pixels
  - Creates render texture at specified resolution
  - Automatically handles window resize events
  - Calculates scaling and centering
  ```
  800 600 vscreen  | Create 800×600 virtual screen
  ```

### Cleanup

- **`vfree`** `( -- )` - Destroy virtual screen
  - Releases virtual screen texture
  - Call before program exit
  ```
  vfree  | Clean up virtual screen
  ```

---

## Rendering

### Frame Management

- **`vini`** `( -- )` - Begin virtual screen rendering
  - Sets render target to virtual screen texture
  - All subsequent drawing goes to virtual surface
  - Must be called before any rendering operations
  ```
  vini  | Start rendering to virtual screen
  ```

- **`vredraw`** `( -- )` - Display virtual screen
  - Switches render target back to window
  - Copies virtual screen to window with scaling
  - Applies letterboxing if needed
  - Presents final image
  - Must be called to show rendered content
  ```
  vredraw  | Display virtual screen in window
  ```

---

## Coordinate Transformation

### Mouse/Input Coordinates

The library automatically transforms window coordinates to virtual screen space:

- **`sdlx`** `( -- x )` - Get virtual X coordinate
  - Overrides SDL's sdlx function
  - Returns mouse X in virtual screen coordinates
  - Accounts for scaling and letterboxing
  ```
  sdlx  | Get mouse X in virtual space (0-vscrw)
  ```

- **`sdly`** `( -- y )` - Get virtual Y coordinate
  - Overrides SDL's sdly function
  - Returns mouse Y in virtual screen coordinates
  - Accounts for scaling and letterboxing
  ```
  sdly  | Get mouse Y in virtual space (0-vscrh)
  ```

---

## Size Helpers

- **`%w`** `( -- width )` - Get virtual width in fixed-point
  - Returns vscrw in 48.16 fixed-point format
  - Useful for percentage calculations

- **`%h`** `( -- height )` - Get virtual height in fixed-point
  - Returns vscrh in 48.16 fixed-point format

---

## Internal Variables

These variables are maintained by the system:

- **`vscrw`** - Virtual screen width
- **`vscrh`** - Virtual screen height
- **`vscrtex`** - Virtual screen texture handle
- **`vscrz`** - Current scale factor (fixed-point)
- **`vcenx`** - X offset for centering (window space)
- **`vceny`** - Y offset for centering (window space)
- **`scl`** - Inverse scale for coordinate transformation

---

## How It Works

### Scaling Algorithm

1. **Calculate scale**: Fit virtual screen to window preserving aspect ratio
   ```
   scale = min(window_width / virtual_width, window_height / virtual_height)
   ```

2. **Center calculation**: Position scaled virtual screen in window center
   ```
   offsetX = (window_width - virtual_width × scale) / 2
   offsetY = (window_height - virtual_height × scale) / 2
   ```

3. **Coordinate transform**: Convert window coordinates to virtual space
   ```
   virtualX = (windowX - offsetX) / scale
   virtualY = (windowY - offsetY) / scale
   ```

### Letterboxing

When window aspect ratio doesn't match virtual screen:
- Horizontal bars (pillarbox): Window wider than virtual screen
- Vertical bars (letterbox): Window taller than virtual screen
- Bars appear black by default

---

## Usage Examples

### Basic Setup

```r3forth
| Include library
^r3/lib/sdl2.r3
^r3/util/vscreen.r3

| Initialize SDL
"My Game" 1024 768 SDLinit

| Create virtual screen (always render at 800×600)
800 600 vscreen

:gameLoop
    | Start rendering to virtual screen
    vini
    
    | Clear virtual screen
    $000000 SDLcls
    
    | Draw game at 800×600 resolution
    $ffffff SDLColor
    100 100 200 150 SDLFRect
    
    | Display virtual screen scaled to window
    vredraw
    
    | Handle input (coordinates auto-transformed)
    sdlx sdly handleMouse
    
    SDLkey <esc> =? ( ; ) drop
    gameLoop ;

gameLoop

| Cleanup
vfree
SDLquit
```

### Resolution-Independent Rendering

```r3forth
| Game always runs at 1920×1080 internally
1920 1080 vscreen

#playerX 960  | Center of virtual screen
#playerY 540

:drawPlayer
    vini
    
    | Draw at virtual resolution
    $ff00ff SDLColor
    playerX playerY 32 32 SDLFRect
    
    vredraw ;

:updatePlayer
    | Use virtual coordinates
    sdlx 'playerX !
    sdly 'playerY ! ;

:gameLoop
    updatePlayer
    drawPlayer
    
    SDLkey 0? ( drop gameLoop ; ) drop ;

gameLoop
```

### Multiple Virtual Screen Sizes

```r3forth
| Easy to switch between resolutions

:setVirtualRes | w h --
    vfree          | Free old virtual screen
    vscreen ;      | Create new one

| Start with 800×600
800 600 vscreen

:switchToHD
    1920 1080 setVirtualRes ;

:switchToSD  
    640 480 setVirtualRes ;

| Game code doesn't change - just uses vscrw/vscrh
```

### Pixel-Perfect Rendering

```r3forth
| For pixel art games - use small virtual resolution
320 240 vscreen  | NES-like resolution

| Disable texture filtering for crisp pixels
| (Already done by vscreen - uses nearest neighbor)

:drawPixelArt
    vini
    
    | Each virtual pixel will be scaled up
    | Draw at 320×240, displays sharp at any window size
    spriteX spriteY spriteTexture drawSprite
    
    vredraw ;
```

### UI with Virtual Screen

```r3forth
^r3/util/txfont.r3
^r3/util/vscreen.r3

800 600 vscreen

"media/fonts/arial.ttf" 16 txload 'font !

:drawUI
    vini
    
    $000000 SDLcls
    
    | Text always at 800×600 resolution
    font txfont
    $ffffff txrgb
    
    100 100 txat
    "Score: " txwrite
    score .d txwrite
    
    | Button at fixed virtual position
    300 250 200 50 SDLFRect
    
    vredraw ;

:checkButton
    | Mouse coordinates in virtual space
    sdlx 300 >= sdlx 500 <= and
    sdly 250 >= sdly 300 <= and
    sdlb and? ( buttonClicked ; ) drop ;
```

### Window Resize Handling

```r3forth
| Window resize is automatic!
800 600 vscreen  | Virtual screen stays 800×600

| User resizes window to 1600×900
| System automatically:
| 1. Calculates new scale (×2)
| 2. Centers virtual screen
| 3. Updates coordinate transforms

:gameLoop
    vini
    
    | Always draw at 800×600
    | Will scale to fit any window size
    drawGame
    
    vredraw
    
    | Mouse coordinates always in 0-800, 0-600 range
    sdlx sdly processInput
    
    SDLkey 0? ( drop gameLoop ; ) drop ;
```

---

## Best Practices

### 1. Choose Appropriate Virtual Resolution

```r3forth
| For pixel art / retro games
320 240 vscreen   | SNES-like
640 480 vscreen   | VGA

| For modern 2D games  
1280 720 vscreen  | 720p
1920 1080 vscreen | 1080p

| For UI-heavy applications
800 600 vscreen   | Classic 4:3
1024 768 vscreen  | XGA
```

### 2. Always Use vini/vredraw Pair

```r3forth
| CORRECT
:render
    vini          | Start virtual rendering
    drawStuff
    vredraw ;     | Display to window

| WRONG - will render to window directly
:render
    drawStuff     | Goes to window, not virtual screen!
    vredraw ;
```

### 3. Use Virtual Coordinates

```r3forth
| CORRECT - use transformed coordinates
:handleClick
    sdlx sdly checkButton ;  | Uses virtual coordinates

| WRONG - window coordinates don't match virtual space
:handleClick  
    SDL_GetMouseState checkButton ;  | Wrong scale!
```

### 4. Design for Virtual Resolution

```r3forth
| Design UI/game for virtual resolution
800 600 vscreen

| All coordinates relative to 800×600
#buttonX 400  | Center of virtual screen
#buttonY 300

| Will work at any window size
```

---

## Advanced Techniques

### Custom Letterbox Color

```r3forth
| Letterbox appears black by default
| To customize, clear window before vredraw:

:render
    vini
    drawGame
    
    | Clear window to custom color before copying
    SDLrenderer 0 SDL_SetRenderTarget
    $202020 SDLcls  | Dark gray letterbox
    
    | Now copy virtual screen (vredraw does this)
    SDLrenderer vscrtex 0 'recd SDL_RenderCopy
    SDLredraw ;
```

### Multiple Virtual Screens

```r3forth
| For split-screen or picture-in-picture

#vscreen1 #vscreen2

:createScreens
    SDLrenderer $16362004 2 800 600 SDL_CreateTexture
    'vscreen1 !
    
    SDLrenderer $16362004 2 800 600 SDL_CreateTexture
    'vscreen2 ! ;

:renderPlayer1
    SDLrenderer vscreen1 SDL_SetRenderTarget
    drawPlayer1View ;

:renderPlayer2
    SDLrenderer vscreen2 SDL_SetRenderTarget
    drawPlayer2View ;

:composite
    SDLrenderer 0 SDL_SetRenderTarget
    
    | Draw both screens side-by-side
    SDLrenderer vscreen1 0 0 sw 2/ sh SDL_RenderCopy
    SDLrenderer vscreen2 sw 2/ 0 sw 2/ sh SDL_RenderCopy
    
    SDLredraw ;
```

### Integer Scaling

```r3forth
| For pixel-perfect scaling (2x, 3x, 4x only)
| Modify vresize to force integer scales:

:vresizeInteger
    sw vscrw /
    sh vscrh / min  | Get scale factors
    | Force to integer: 1x, 2x, 3x, etc.
    int. 1 max
    'vscrz !
    
    | Calculate centering with integer scale
    vscrw vscrz * sw over - 2/ 'vcenx !
    vscrh vscrz * sh over - 2/ 'vceny !
    
    | Update destination rect
    vcenx vceny vscrw vscrz * vscrh vscrz *
    'recd >a da!+ da!+ da!+ da! ;

| Use custom resize
'vresizeInteger SDLeventR
```

---

## Performance Considerations

1. **Virtual screen size**: Larger = more GPU fill, but sharper result
2. **Scaling quality**: Nearest neighbor (set by vscreen) is fastest
3. **Texture format**: Uses $16362004 (ARGB8888) for compatibility
4. **One render target switch**: Minimal overhead per frame

---

## Common Patterns

### Fixed Aspect Ratio Game

```r3forth
| Game designed for 16:9
1920 1080 vscreen

| Works perfectly on:
| - 1920×1080 (exact match)
| - 3840×2160 (scales 2x)
| - 1280×720 (scales 0.666x)

| Letterboxes on:
| - 1920×1200 (too tall)
| - 2560×1080 (too wide)
```

### Adaptive UI

```r3forth
| Use virtual screen dimensions for layout
:drawScaledUI
    vini
    
    | Center button on virtual screen
    vscrw 2/ 100 - 
    vscrh 2/ 25 -
    200 50 SDLFRect
    
    vredraw ;
```

---

## Notes

- **Automatic resize**: Window resize events handled automatically
- **Coordinate safety**: Mouse coordinates always valid (clamped to virtual bounds)
- **Texture filtering**: Uses nearest neighbor for sharp scaling
- **Render target**: Properly restored after vredraw
- **Aspect ratio**: Always preserved, never stretched
- **Performance**: Single texture copy per frame, very efficient
- **Compatibility**: Works with all SDL2 drawing functions

## Limitations

- Single virtual screen at a time (custom code for split-screen)
- Fixed aspect ratio (no dynamic aspect changes)
- No rotation support built-in
- Letterbox color is black (requires custom code to change)

## Coordinate Range

- **Virtual X**: 0 to vscrw
- **Virtual Y**: 0 to vscrh
- **Window space**: Automatically handled
- **Out of bounds**: Coordinates outside virtual area work but won't be visible

## Comparison with Direct Rendering

| Aspect | Direct Rendering | Virtual Screen |
|--------|------------------|----------------|
| Resolution | Variable | Fixed |
| Aspect Ratio | Can stretch | Always preserved |
| Coordinate System | Window-dependent | Consistent |
| Mouse Input | Window coordinates | Virtual coordinates |
| Scaling | Manual | Automatic |
| Letterboxing | Manual | Automatic |
| Performance | Slightly faster | Near-identical |

