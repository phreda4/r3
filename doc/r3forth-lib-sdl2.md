# R3Forth SDL2 Library (sdl2.r3)

A comprehensive SDL2 wrapper for R3Forth providing window management, rendering, input handling, audio, and OpenGL integration for cross-platform multimedia applications.

## Overview

This library provides:
- **Window creation and management** (windowed, fullscreen, resizable)
- **2D rendering** (textures, primitives, color blending)
- **Input handling** (keyboard, mouse, clipboard)
- **Audio playback** (queued audio system)
- **OpenGL context** creation and management
- **Event system** with callbacks
- **Cross-platform** (Windows and Linux)

---

## Initialization

### Basic Window Creation

- **`SDLinit`** `( "title" w h -- )` - Create window with renderer
  ```r3forth
  "My Game" 800 600 SDLinit
  ```
  - Creates window at default position
  - Initializes SDL with video subsystem
  - Creates hardware-accelerated renderer
  - Raises window to front

- **`SDLmini`** `( "title" w h -- )` - Create minimized window
  ```r3forth
  "Background App" 640 480 SDLmini
  ```
  - Window starts minimized
  - Useful for background processes

- **`sdlinitR`** `( "title" w h -- )` - Create resizable window
  ```r3forth
  "Resizable Window" 1024 768 sdlinitR
  ```
  - User can resize window
  - Content scales automatically

### Fullscreen Initialization

- **`SDLinitScr`** `( "title" display w h -- )` - Create fullscreen window
  ```r3forth
  "Fullscreen Game" 0 1920 1080 SDLinitScr
  ```
  - `display`: Monitor index (0 = primary)
  - Creates desktop fullscreen window
  - Uses native resolution if available

- **`SDLfullw`** `( "title" display -- )` - Fullscreen with native resolution
  ```r3forth
  "Full Native" 0 SDLfullw
  ```
  - Automatically detects display resolution
  - Sets `sw` and `sh` to native size

- **`SDLfull`** - Toggle fullscreen mode
  ```r3forth
  SDLfull  | Switch to fullscreen
  ```
  - Toggles current window to fullscreen

### Cleanup

- **`SDLquit`** - Shutdown SDL and close window
  ```r3forth
  SDLquit
  ```
  - Destroys renderer
  - Destroys window
  - Shuts down SDL subsystem
  - Always call before program exit

---

## Global Variables

- **`SDL_windows`** - Window handle
- **`SDLrenderer`** - Renderer handle
- **`sw`** - Screen width
- **`sh`** - Screen height

---

## Rendering

### Render Control

- **`SDLredraw`** - Present rendered frame
  ```r3forth
  | ... drawing commands ...
  SDLredraw  | Display result
  ```
  - Swaps backbuffer to screen
  - Call once per frame

- **`SDL_RenderClear`** `( renderer -- )` - Clear render target
  ```r3forth
  SDLrenderer SDL_RenderClear
  ```
  - Clears to current draw color

- **`SDL_SetRenderDrawColor`** `( renderer r g b a -- )` - Set draw color
  ```r3forth
  SDLrenderer 255 0 0 255 SDL_SetRenderDrawColor  | Red
  ```
  - RGBA format (0-255)
  - Affects primitives and clear

- **`SDL_GetRenderDrawColor`** `( renderer 'r 'g 'b 'a -- )` - Get draw color
  ```r3forth
  SDLrenderer 'r 'g 'b 'a SDL_GetRenderDrawColor
  ```

### Blend Modes

- **`SDLblend`** - Enable alpha blending
  ```r3forth
  SDLblend  | Enable transparency
  ```
  - Required for alpha channel rendering

- **`SDL_SetRenderDrawBlendMode`** `( renderer mode -- )` - Set blend mode
  ```r3forth
  SDLrenderer 1 SDL_SetRenderDrawBlendMode  | Alpha blend
  ```
  - 0 = None, 1 = Blend, 2 = Add, 4 = Mod

---

## Textures

### Texture Creation

- **`SDLframebuffer`** `( w h -- texture )` - Create render texture
  ```r3forth
  800 600 SDLframebuffer  | RGBA8888 texture
  ```
  - Pixel format: RGBA8888
  - Streaming access
  - Can be render target

- **`SDL_CreateTexture`** `( renderer format access w h -- texture )` - Create texture
  ```r3forth
  SDLrenderer $16362004 1 640 480 SDL_CreateTexture
  ```
  - Format: `$16362004` = RGBA8888
  - Access: 1 = Streaming, 2 = Target

- **`SDL_CreateTextureFromSurface`** `( renderer surface -- texture )` - Create from surface
  ```r3forth
  SDLrenderer loaded-surface SDL_CreateTextureFromSurface
  ```

### Texture Operations

- **`SDL_UpdateTexture`** `( texture rect pixels pitch -- )` - Update texture data
  ```r3forth
  my-texture 0 'pixelbuffer 64 SDL_UpdateTexture
  ```
  - `rect`: 0 for entire texture or pointer to SDL_Rect
  - `pitch`: bytes per row (width × 4 for RGBA)

- **`SDL_LockTexture`** `( texture rect 'pixels 'pitch -- )` - Lock for direct access
  ```r3forth
  texture 0 'pixels 'pitch SDL_LockTexture
  | ... modify pixels ...
  texture SDL_UnlockTexture
  ```

- **`SDL_UnlockTexture`** `( texture -- )` - Unlock texture

- **`SDL_DestroyTexture`** `( texture -- )` - Free texture
  ```r3forth
  old-texture SDL_DestroyTexture
  ```

### Texture Properties

- **`SDL_QueryTexture`** `( texture 'format 'access 'w 'h -- )` - Get texture info
  ```r3forth
  texture 0 0 'width 'height SDL_QueryTexture
  ```

- **`SDLTexwh`** `( texture -- w h )` - Get texture dimensions
  ```r3forth
  my-texture SDLTexwh  | Returns width and height
  ```

- **`SDL_SetTextureColorMod`** `( texture r g b -- )` - Tint texture
  ```r3forth
  sprite 255 128 128 SDL_SetTextureColorMod  | Red tint
  ```

- **`SDL_SetTextureAlphaMod`** `( texture alpha -- )` - Set transparency
  ```r3forth
  sprite 128 SDL_SetTextureAlphaMod  | 50% transparent
  ```

- **`SDL_SetTextureBlendMode`** `( texture mode -- )` - Set blend mode

- **`SDL_SetTextureScaleMode`** `( texture mode -- )` - Set scaling filter
  ```r3forth
  texture 0 SDL_SetTextureScaleMode  | Nearest (pixel-perfect)
  texture 1 SDL_SetTextureScaleMode  | Linear (smooth)
  ```

---

## Drawing

### Texture Rendering

- **`SDL_RenderCopy`** `( renderer texture srcrect dstrect -- )` - Draw texture
  ```r3forth
  SDLrenderer sprite 0 'dest-rect SDL_RenderCopy
  ```
  - `srcrect`: 0 for full texture or pointer to source rectangle
  - `dstrect`: Pointer to destination rectangle (x, y, w, h)

- **`SDL_RenderCopyEx`** `( renderer texture srcrect dstrect angle centerx centery flip -- )` - Draw with rotation
  ```r3forth
  SDLrenderer sprite 0 'dest-rect
  45.0 0 0 0  | 45° rotation, no flip
  SDL_RenderCopyEx
  ```
  - `angle`: Rotation in degrees (0-360)
  - `center`: 0 for center or pointer to pivot point
  - `flip`: 0 = None, 1 = Horizontal, 2 = Vertical

### Primitive Drawing

- **`SDL_RenderDrawPoint`** `( renderer x y -- )` - Draw point
  ```r3forth
  SDLrenderer 100 100 SDL_RenderDrawPoint
  ```

- **`SDL_RenderDrawPoints`** `( renderer 'points count -- )` - Draw multiple points
  ```r3forth
  SDLrenderer 'point-array 100 SDL_RenderDrawPoints
  ```

- **`SDL_RenderDrawLine`** `( renderer x1 y1 x2 y2 -- )` - Draw line
  ```r3forth
  SDLrenderer 0 0 100 100 SDL_RenderDrawLine
  ```

- **`SDL_RenderDrawRect`** `( renderer 'rect -- )` - Draw rectangle outline
  ```r3forth
  SDLrenderer 'my-rect SDL_RenderDrawRect
  ```
  - `'rect`: Pointer to x, y, w, h (4 integers)

- **`SDL_RenderFillRect`** `( renderer 'rect -- )` - Draw filled rectangle
  ```r3forth
  SDLrenderer 'my-rect SDL_RenderFillRect
  ```

- **`SDL_RenderGeometry`** `( renderer texture 'vertices num-vert 'indices num-ind -- )` - Draw triangles
  ```r3forth
  SDLrenderer 0 'vertices 3 0 0 SDL_RenderGeometry
  ```
  - For custom 2D shapes

### Render Target

- **`SDL_SetRenderTarget`** `( renderer texture -- )` - Render to texture
  ```r3forth
  SDLrenderer my-texture SDL_SetRenderTarget
  | ... draw to texture ...
  SDLrenderer 0 SDL_SetRenderTarget  | Back to screen
  ```

- **`SDL_RenderSetClipRect`** `( renderer 'rect -- )` - Set clipping region
  ```r3forth
  SDLrenderer 'clip-rect SDL_RenderSetClipRect
  ```

- **`SDL_RenderReadPixels`** `( renderer 'rect format 'pixels pitch -- )` - Read pixels
  ```r3forth
  SDLrenderer 0 $16362004 'buffer sw 4 * SDL_RenderReadPixels
  ```

---

## Input Handling

### Event Processing

- **`SDLupdate`** - Process all pending events
  ```r3forth
  ( .exit 0? drop
    SDLupdate
    | ... game logic ...
    SDLredraw
  )
  ```
  - Updates `SDLkey`, `SDLchar`, `SDLx`, `SDLy`, `SDLb`, `SDLw`
  - Handles window resize events
  - Must be called every frame

### Event Callback

- **`SDLeventR`** `( 'callback -- )` - Set resize callback
  ```r3forth
  :on-resize
    sw sh "Resized to %d x %d" print ;
  
  'on-resize SDLeventR
  ```
  - Called when window is resized
  - `sw` and `sh` are updated before callback

### Input State Variables

- **`SDLkey`** - Current key code (or 0)
  ```r3forth
  SDLkey 
  <esc> =? ( exit ; )  | ESC pressed
  >esc< =? ( ; )  | ESC released
  ```
  - See `sdlkeys.r3` for key constants

- **`SDLchar`** - Text input character
  ```r3forth
  SDLchar 1? (         | Character was typed
    'textbuffer append-char
  ) drop
  ```

- **`SDLx`, `SDLy`** - Mouse coordinates
  ```r3forth
  SDLx SDLy  | Current mouse position
  ```

- **`SDLb`** - Mouse button state (bitmask)
  ```r3forth
  SDLb 1 and? ( "Left button down" print ; )
  SDLb 2 and? ( "Middle button down" print ; )
  SDLb 4 and? ( "Right button down" print ; )
  ```
  - Bit 0: Left button
  - Bit 1: Middle button
  - Bit 2: Right button

- **`SDLw`** - Mouse wheel delta
  ```r3forth
  SDLw 0 >? ( "Scroll up" print ; )
  SDLw 0 <? ( "Scroll down" print ; )
  ```

### Click Detection

- **`SDLClick`** `( 'callback -- )` - Execute on mouse click
  ```r3forth
  :on-click
    SDLx SDLy "Clicked at %d, %d" print ;
  
  'on-click SDLClick
  ```
  - Triggered on button press and release
  - Called once per click cycle

---

## Main Loop Helpers

- **`SDLshow`** `( 'word -- )` - Main loop with callback
  ```r3forth
  :game-loop
    draw-game
    SDLredraw ;
  
  'game-loop SDLshow
  ```
  - Calls callback repeatedly until `exit` is called
  - Handles events automatically

- **`exit`** - Exit main loop
  ```r3forth
  SDLkey >esc< =? ( exit ; )
  ```

- **`sdlbreak`** - Debug pause (F12 to continue, ESC to exit)
  ```r3forth
  some-error? ( sdlbreak ; )
  ```

---

## Surfaces

Surfaces are CPU-side image buffers.

- **`SDL_CreateRGBSurface`** `( flags w h depth Rmask Gmask Bmask Amask -- surface )` - Create surface
  ```r3forth
  0 640 480 32 
  $FF000000 $FF0000 $FF00 $FF
  SDL_CreateRGBSurface
  ```

- **`SDL_CreateRGBSurfaceWithFormat`** `( flags w h depth format -- surface )` - Create with format
  ```r3forth
  0 800 600 32 $16362004 SDL_CreateRGBSurfaceWithFormat
  ```

- **`SDL_CreateRGBSurfaceWithFormatFrom`** `( pixels w h depth pitch format -- surface )` - From existing pixels

- **`SDL_LockSurface`** `( surface -- )` - Lock for pixel access

- **`SDL_UnlockSurface`** `( surface -- )` - Unlock surface

- **`SDL_BlitSurface`** `( src srcrect dst dstrect -- )` - Copy surface
  ```r3forth
  source-surface 0 dest-surface 'dest-rect SDL_BlitSurface
  ```

- **`SDL_FillRect`** `( surface rect color -- )` - Fill with color
  ```r3forth
  my-surface 0 $FF0000FF SDL_FillRect  | Fill red
  ```

- **`SDL_SetSurfaceBlendMode`** `( surface mode -- )` - Set blend mode

- **`SDL_SetSurfaceAlphaMod`** `( surface alpha -- )` - Set transparency

- **`SDL_ConvertSurfaceFormat`** `( surface format flags -- newsurface )` - Convert format

- **`SDL_FreeSurface`** `( surface -- )` - Free surface memory

---

## Audio

### Audio Device

- **`SDL_OpenAudioDevice`** `( devicename iscapture 'spec 'obtained flags -- deviceid )` - Open audio
  ```r3forth
  0 0 'audio-spec 0 0 SDL_OpenAudioDevice 'audio-device !
  ```
  - `devicename`: 0 for default
  - `iscapture`: 0 for playback, 1 for recording
  - Returns device ID

- **`SDL_QueueAudio`** `( deviceid 'data len -- )` - Queue audio data
  ```r3forth
  audio-device 'sound-buffer buffer-size SDL_QueueAudio
  ```

- **`SDL_GetQueuedAudioSize`** `( deviceid -- size )` - Get queued bytes
  ```r3forth
  audio-device SDL_GetQueuedAudioSize
  ```

- **`SDL_PauseAudioDevice`** `( deviceid pause -- )` - Pause/unpause
  ```r3forth
  audio-device 0 SDL_PauseAudioDevice  | Unpause (start)
  audio-device 1 SDL_PauseAudioDevice  | Pause
  ```

- **`SDL_CloseAudioDevice`** `( deviceid -- )` - Close audio device

---

## OpenGL Integration

### OpenGL Context

- **`SDL_GL_SetAttribute`** `( attr value -- )` - Set GL attribute
  ```r3forth
  $11 3 SDL_GL_SetAttribute  | GL_CONTEXT_MAJOR_VERSION = 3
  $12 3 SDL_GL_SetAttribute  | GL_CONTEXT_MINOR_VERSION = 3
  ```

- **`SDL_GL_CreateContext`** `( window -- context )` - Create GL context
  ```r3forth
  SDL_windows SDL_GL_CreateContext 'gl-context !
  ```

- **`SDL_GL_DeleteContext`** `( context -- )` - Delete context

- **`SDL_GL_MakeCurrent`** `( window context -- )` - Make context current
  ```r3forth
  SDL_windows gl-context SDL_GL_MakeCurrent
  ```

- **`SDL_GL_SetSwapInterval`** `( interval -- )` - Set VSync
  ```r3forth
  1 SDL_GL_SetSwapInterval  | Enable VSync
  0 SDL_GL_SetSwapInterval  | Disable VSync
  ```

- **`SDL_GL_SwapWindow`** `( window -- )` - Swap GL buffers
  ```r3forth
  SDL_windows SDL_GL_SwapWindow
  ```

- **`SDL_GL_LoadLibrary`** `( path -- )` - Load GL library
  ```r3forth
  0 SDL_GL_LoadLibrary  | Load default
  ```

- **`SDL_GL_GetProcAddress`** `( name -- addr )` - Get GL function
  ```r3forth
  "glCreateShader" SDL_GL_GetProcAddress 'glCreateShader !
  ```

---

## Clipboard

- **`SDL_GetClipboardText`** `( -- text )` - Get clipboard string
  ```r3forth
  SDL_GetClipboardText dup print
  SDL_free  | Free returned string
  ```

- **`SDL_HasClipboardText`** `( -- bool )` - Check if clipboard has text
  ```r3forth
  SDL_HasClipboardText 1? ( process-paste ; )
  ```

- **`SDL_SetClipboardText`** `( text -- )` - Set clipboard
  ```r3forth
  "Copied text" SDL_SetClipboardText
  ```

- **`SDL_free`** `( ptr -- )` - Free SDL-allocated memory

---

## File I/O

- **`SDL_RWFromFile`** `( filename mode -- rwops )` - Open file
  ```r3forth
  "data.bin" "rb" SDL_RWFromFile 'file-handle !
  ```
  - Mode: "rb" = read binary, "wb" = write binary

- **`SDL_RWclose`** `( rwops -- )` - Close file
  ```r3forth
  file-handle SDL_RWclose
  ```

---

## Utility Functions

- **`SDL_Delay`** `( ms -- )` - Sleep for milliseconds
  ```r3forth
  16 SDL_Delay  | ~60 FPS
  ```

- **`SDL_GetTicks`** `( -- ms )` - Get milliseconds since init
  ```r3forth
  SDL_GetTicks 'start-time !
  ```

- **`SDL_SetHint`** `( name value -- )` - Set SDL hint
  ```r3forth
  "SDL_RENDER_SCALE_QUALITY" "1" SDL_SetHint  | Linear filtering
  ```

- **`SDL_GetError`** `( -- errstr )` - Get last error
  ```r3forth
  SDL_GetError print  | Display error message
  ```

- **`SDL_ShowCursor`** `( toggle -- )` - Show/hide cursor
  ```r3forth
  0 SDL_ShowCursor  | Hide cursor
  1 SDL_ShowCursor  | Show cursor
  ```

---

## Usage Examples

### Basic Application
```r3forth

  :loop
    SDLkey >esc< =? ( exit ) drop
    
    | Clear screen
    SDLrenderer 0 0 0 255 SDL_SetRenderDrawColor
    SDLrenderer SDL_RenderClear
    
    | Draw something
    SDLrenderer 255 0 0 255 SDL_SetRenderDrawColor
    SDLrenderer 100 100 200 150 SDL_RenderFillRect
    
    SDLredraw
    ;
  

:main
  "Hello SDL2" 800 600 SDLinit
  'loop SDLshow
  SDLquit
  ;
```

### Sprite Rendering
```r3forth
#sprite-texture
#pixel-data [ .. ]  | 16 x 16 color data

:load-sprite
  | Create texture from pixel data
  800 600 SDLframebuffer 'sprite-texture !
  sprite-texture 0 'pixel-data 64 SDL_UpdateTexture
  ;

#rect [ 0 0 16 16 ] | Destination rectangle (dwords)

:draw-sprite | x y --
  swap 'rect d!+ d!
  SDLrenderer sprite-texture 0 'rect SDL_RenderCopy
  ;

:loop
  SDLrenderer SDL_RenderClear
  
  100 100 draw-sprite  | Draw at (100, 100)
  
  SDLredraw
  ;

:game
  load-sprite
  'loop SDLshow
  sprite-texture SDL_DestroyTexture
  SDLquit
  ;
```

---

## Performance Tips

1. **Minimize texture switches** - Batch rendering by texture
2. **Use render targets** for static content
3. **Lock textures** sparingly - prefer UpdateTexture
4. **Reuse rectangles** - Don't allocate per frame
5. **Cache surface conversions** - Don't convert repeatedly
6. **Use hardware acceleration** - Default renderer is optimized

---

## Notes

- **Thread safety:** SDL is not fully thread-safe - use from main thread
- **Coordinate system:** Top-left origin (0,0), Y increases downward
- **Color format:** RGBA (Red, Green, Blue, Alpha) 0-255
- **Texture formats:** Prefer RGBA8888 for compatibility
- **Window flags:** Combine with OR operator
- **Memory:** Always free textures, surfaces, and other resources
- **OpenGL:** Requires separate OpenGL function loading