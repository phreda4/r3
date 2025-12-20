# R3Forth SDL2 Graphics Library (sdl2gfx.r3)

A high-level 2D graphics library for R3Forth built on SDL2, providing primitives, sprites, tilesets, sprite sheets, animations, and advanced rendering features.

## Overview

This library provides:
- **Color management** (RGB/ARGB conversion)
- **Primitive drawing** (lines, rectangles, circles, ellipses)
- **Image rendering** (simple images, scaled, rotated)
- **Sprite system** (rotation, scaling, zoom)
- **Tileset management** (tile-based graphics)
- **Sprite sheets** (packed sprite atlases)
- **Texture composition** (render-to-texture)
- **Animation system** (time-based animation)

---

## Color Functions

### Color Conversion

- **`rgb24`** `( rgb -- r g b )` - Extract RGB components from 24-bit color
  ```r3forth
  $FF8040 rgb24  | Returns 255 128 64 (R G B)
  ```

- **`rgb32`** `( argb -- r g b a )` - Extract ARGB components from 32-bit color
  ```r3forth
  $80FF8040 rgb32  | Returns 255 128 64 128 (R G B A)
  ```

### Setting Colors

- **`SDLColor`** `( rgb -- )` - Set draw color (opaque)
  ```r3forth
  $FF0000 SDLColor  | Red
  ```

- **`SDLColorA`** `( argb -- )` - Set draw color with alpha
  ```r3forth
  $80FF0000 SDLColorA  | Semi-transparent red
  ```

- **`SDLcls`** `( color -- )` - Clear screen with color
  ```r3forth
  $000000 SDLcls  | Clear to black
  ```

---

## Primitive Drawing

### Points and Lines

- **`SDLPoint`** `( x y -- )` - Draw single point
  ```r3forth
  100 100 SDLPoint
  ```

- **`SDLGetPixel`** `( x y -- color )` - Read pixel color
  ```r3forth
  100 100 SDLGetPixel  | Returns RGB value
  ```

- **`SDLLine`** `( x1 y1 x2 y2 -- )` - Draw line
  ```r3forth
  0 0 100 100 SDLLine  | Diagonal line
  ```

- **`SDLLineH`** `( x1 y x2 -- )` - Draw horizontal line
  ```r3forth
  50 100 150 SDLLineH  | Horizontal from (50,100) to (150,100)
  ```

- **`SDLLineV`** `( x y1 y2 -- )` - Draw vertical line
  ```r3forth
  100 50 150 SDLLineV  | Vertical from (100,50) to (100,150)
  ```

### Rectangles

- **`SDLFRect`** `( x y w h -- )` - Draw filled rectangle
  ```r3forth
  50 50 100 80 SDLFRect
  ```

- **`SDLRect`** `( x y w h -- )` - Draw rectangle outline
  ```r3forth
  50 50 100 80 SDLRect
  ```

- **`SDLFRound`** `( r x y w h -- )` - Draw filled rounded rectangle
  ```r3forth
  10 50 50 200 150 SDLFRound  | Radius=10
  ```

- **`SDLRound`** `( r x y w h -- )` - Draw rounded rectangle outline
  ```r3forth
  15 50 50 200 150 SDLRound
  ```

### Circles

- **`SDLFCircle`** `( r x y -- )` - Draw filled circle
  ```r3forth
  50 200 200 SDLFCircle  | Radius=50, center=(200,200)
  ```

- **`SDLCircle`** `( r x y -- )` - Draw circle outline
  ```r3forth
  50 200 200 SDLCircle
  ```

### Ellipses

- **`SDLFEllipse`** `( rx ry x y -- )` - Draw filled ellipse
  ```r3forth
  80 50 200 200 SDLFEllipse  | rx=80, ry=50
  ```

- **`SDLEllipse`** `( rx ry x y -- )` - Draw ellipse outline
  ```r3forth
  80 50 200 200 SDLEllipse
  ```

### Triangle

- **`SDLTriangle`** `( x1 y1 x2 y2 x3 y3 -- )` - Draw filled triangle
  ```r3forth
  100 50  200 150  50 150 SDLTriangle
  ```

---

## Image Rendering

Simple image drawing functions.

- **`SDLImage`** `( x y img -- )` - Draw image at position
  ```r3forth
  100 100 my-image SDLImage
  ```
  - Draws at original size
  - Top-left corner at (x, y)

- **`SDLImages`** `( x y w h img -- )` - Draw scaled image
  ```r3forth
  100 100 200 150 my-image SDLImages
  ```
  - Stretches/shrinks to fit w×h

- **`SDLImageb`** `( 'box img -- )` - Draw with box (destination)
  ```r3forth
  'dest-box my-image SDLImageb
  ```
  - Box format: x, y, w, h (4 integers)

- **`SDLImagebb`** `( 'srcbox 'dstbox img -- )` - Draw with source and destination
  ```r3forth
  'source-box 'dest-box my-image SDLImagebb
  ```
  - Copy portion of image to specific location

---

## Sprite System

Advanced sprite rendering with rotation, scaling, and zoom.

### Basic Sprites

- **`sprite`** `( x y img -- )` - Draw sprite centered at position
  ```r3forth
  400 300 player-sprite sprite
  ```
  - Image center is at (x, y)
  - No rotation or scaling

- **`spriteZ`** `( x y zoom img -- )` - Draw sprite with zoom
  ```r3forth
  400 300 2.0 player-sprite spriteZ  | 2x zoom
  ```
  - Zoom: 1.0 = normal, 2.0 = double size, 0.5 = half size

- **`spriteR`** `( x y angle img -- )` - Draw rotated sprite
  ```r3forth
  400 300 0.25 player-sprite spriteR  | 90° rotation
  ```
  - Angle in bangles (0-1.0 = 0-360°)

- **`spriteRZ`** `( x y angle zoom img -- )` - Draw rotated and zoomed sprite
  ```r3forth
  400 300 0.10 1.5 player-sprite spriteRZ
  ```

---

## Tileset System

Efficient tile-based rendering for grids and tile maps.

### Tileset Creation

- **`tsload`** `( w h "filename" -- ts )` - Load tileset
  ```r3forth
  32 32 "tiles.png" tsload 'my-tileset !
  ```
  - `w h`: Size of each tile in pixels
  - Automatically divides image into tiles
  - Returns tileset handle

### Tileset Properties

- **`tscolor`** `( rgb 'ts -- )` - Tint entire tileset
  ```r3forth
  $FF8080 my-tileset tscolor  | Red tint
  ```

- **`tsalpha`** `( alpha 'ts -- )` - Set tileset transparency
  ```r3forth
  128 my-tileset tsalpha  | 50% transparent
  ```

### Drawing Tiles

- **`tsdraw`** `( n 'ts x y -- )` - Draw tile at position
  ```r3forth
  5 my-tileset 100 100 tsdraw  | Draw tile #5
  ```
  - `n`: Tile index (0-based)
  - Draws at original tile size

- **`tsdraws`** `( n 'ts x y w h -- )` - Draw scaled tile
  ```r3forth
  5 my-tileset 100 100 64 64 tsdraws  | Scale to 64×64
  ```

- **`tsbox`** `( 'boxsrc n 'ts -- )` - Get tile source rectangle
  ```r3forth
  'source-rect 3 my-tileset tsbox
  ```
  - Fills box with tile coordinates

### Cleanup

- **`tsfree`** `( ts -- )` - Free tileset resources
  ```r3forth
  my-tileset tsfree
  ```

---

## Sprite Sheet System

Optimized sprite sheets with UV coordinates for efficient rendering.

### Sprite Sheet Creation

- **`ssload`** `( w h "filename" -- ss )` - Load sprite sheet
  ```r3forth
  64 64 "characters.png" ssload 'char-sprites !
  ```
  - Divides image into w×h sprites
  - Stores UV coordinates for each sprite
  - More efficient than tileset for many sprites

### Sprite Sheet Info

- **`sspritewh`** `( 'ss -- w h )` - Get sprite dimensions
  ```r3forth
  char-sprites sspritewh  | Returns width and height
  ```

### Tinting

- **`sstint`** `( argb -- )` - Set sprite tint color
  ```r3forth
  $80FF0000 sstint  | Semi-transparent red tint
  ```
  - Affects next sprite sheet draw
  - Includes alpha channel

- **`ssnotint`** - Reset to no tint
  ```r3forth
  ssnotint  | Full color, opaque
  ```

### Drawing Sprites

- **`ssprite`** `( x y n ss -- )` - Draw sprite from sheet
  ```r3forth
  200 200 3 char-sprites ssprite  | Draw sprite #3
  ```

- **`sspriter`** `( x y angle n ss -- )` - Draw rotated sprite
  ```r3forth
  200 200 0.25 3 char-sprites sspriter  | 90° rotation
  ```

- **`sspritez`** `( x y zoom n ss -- )` - Draw zoomed sprite
  ```r3forth
  200 200 2.0 3 char-sprites sspritez  | 2x zoom
  ```

- **`sspriterz`** `( x y angle zoom n ss -- )` - Draw rotated and zoomed
  ```r3forth
  200 200 0.10 1.5 3 char-sprites sspriterz
  ```

---

## Surface Management

Low-level surface (CPU-side bitmap) operations.

- **`createSurf`** `( w h -- surface )` - Create ARGB surface
  ```r3forth
  640 480 createSurf 'my-surface !
  ```
  - 32-bit ARGB format
  - For pixel manipulation

- **`Surf>pix`** `( surface -- surf pixels )` - Get pixel buffer pointer
  ```r3forth
  my-surface Surf>pix  | Returns surface and pixel array
  ```

- **`Surf>wh`** `( surface -- surf w h )` - Get dimensions
  ```r3forth
  my-surface Surf>wh  | Returns surface, width, height
  ```

- **`Surf>wha`** `( surface -- 'wh )` - Get pointer to width/height
  ```r3forth
  my-surface Surf>wha
  ```

- **`Surf>pixpi`** `( surface -- 'pixels pitch )` - Get pixels and pitch
  ```r3forth
  my-surface Surf>pixpi
  ```
  - Pitch: Bytes per row

---

## Texture Composition

Render-to-texture for creating complex graphics offline.

- **`texIni`** `( w h -- )` - Begin rendering to texture
  ```r3forth
  800 600 texIni
  | ... draw commands ...
  texEnd
  ```
  - All subsequent drawing goes to texture
  - Creates target texture internally

- **`texEnd`** `( -- texture )` - Finish and return texture
  ```r3forth
  800 600 texIni
  $FF0000 SDLColor
  100 100 200 200 SDLFRect
  texEnd 'composed-texture !
  ```
  - Returns handle to created texture
  - Restores rendering to screen

- **`texEndAlpha`** `( -- texture )` - Finish with alpha blending enabled
  ```r3forth
  texEndAlpha 'transparent-texture !
  ```
  - Same as `texEnd` but enables blending

- **`tex2static`** `( tex -- newtex )` - Convert dynamic texture to static
  ```r3forth
  render-target tex2static 'static-copy !
  ```
  - Copies render target to regular texture
  - Destroys original texture
  - Useful for caching

---

## Timer System

Frame-independent timing for animations and game logic.

- **`timer<`** - Reset timer
  ```r3forth
  timer<  | Start timing
  ```
  - Sets start time
  - Resets delta to 0

- **`timer.`** - Update timer
  ```r3forth
  timer.  | Call every frame
  ```
  - Calculates time since last call
  - Updates `deltatime` variable

- **`timer+`** `( time -- time' )` - Add delta time
  ```r3forth
  animation-time timer+ 'animation-time !
  ```
  - For frame-independent animation

- **`timer-`** `( time -- time' )` - Subtract delta time
  ```r3forth
  countdown timer- 'countdown !
  ```

---

## Animation System

Packed animation format for efficient frame animation.

### Animation Format

Animations pack: initial frame, frame count, time scale, and current time into a single 64-bit value.

### Creating Animations

- **`ICS>anim`** `( init cnt scale -- anim )` - Create animation value
  ```r3forth
  0 16 4 ICS>anim  | Start=0, 16 frames, scale=4
  ```
  - `init`: Starting frame
  - `cnt`: Number of frames
  - `scale`: Time scale (higher = slower)

- **`vICS>anim`** `( time init cnt scale -- anim )` - Create with initial time
  ```r3forth
  1000 0 16 4 vICS>anim
  ```

### Using Animations

- **`anim>n`** `( anim -- frame )` - Get current frame with wrap
  ```r3forth
  animation anim>n  | Returns frame number (loops)
  ```
  - Automatically wraps from last to first frame
  - Returns frame number to use

- **`anim>c`** `( anim -- frame )` - Get current frame no wrap
  ```r3forth
  animation anim>c  | Returns frame (stops at last)
  ```
  - Clamps at last frame (doesn't loop)

- **`anim>stop`** `( anim -- anim' )` - Stop animation
  ```r3forth
  running-anim anim>stop 'stopped-anim !
  ```
  - Resets frame count to prevent animation

---

## Usage Examples

### Basic Drawing
```r3forth
:draw-scene
  $000000 SDLcls  | Clear to black
  
  $FF0000 SDLColor
  100 100 200 150 SDLFRect  | Red rectangle
  
  $00FF00 SDLColor
  300 200 50 SDLFCircle  | Green circle
  
  $0000FF SDLColor
  400 100 500 300 SDLLine  | Blue line
  
  SDLredraw
  ;
```

### Sprite Animation
```r3forth
#player-x 400
#player-y 300
#player-angle 0

:animate-player
  player-angle 100 + $FFFF and 'player-angle !
  
  player-x player-y player-angle 
  1.0 player-sprite spriteRZ
  ;

:game-loop
  SDLupdate
  $000000 SDLcls
  animate-player
  SDLredraw
  ;
```

### Tilemap Rendering
```r3forth
#tilemap * 100  | 10×10 map

:init-tilemap
  32 32 "tiles.png" tsload 'tileset !
  
  | Fill tilemap with tile indices
  100 ( 1? 1-
    5 randmax over 'tilemap + c!
  ) drop
  ;

:draw-tilemap
  10 ( 1? 1-
    10 ( 1? 1-
      | Calculate position
      over 32 * 
      pick2 32 * 
      
      | Get tile index
      pick2 10 * pick2 + 'tilemap + c@
      
      | Draw tile
      tileset tsdraw
    ) drop
  ) drop
  ;
```

### Sprite Sheet Character
```r3forth
#char-sheet
#char-frame 0

:init-character
  64 64 "character.png" ssload 'char-sheet !
  ;

:animate-character | x y --
  char-frame 1+ 8 mod 'char-frame !
  char-frame char-sheet ssprite
  ;

:draw-character
  200 200 animate-character
  ;
```

### Render to Texture
```r3forth
#background-texture

:create-background
  800 600 texIni
  
  | Draw complex background
  $000080 SDLcls  | Dark blue base
  
  100 ( 1? 1-
    800 randmax 600 randmax
    $FFFFFF SDLColor
    SDLPoint  | Stars
  ) drop
  
  texEnd 'background-texture !
  ;

:draw-scene
  0 0 background-texture SDLImage  | Draw cached background
  | ... draw dynamic objects ...
  ;
```

### Particle System
```r3forth
#particles * 3200  | 100 particles × 4 values x 8 bytes

:init-particles
  'particles >a
  100 ( 1? 1-
    800.0 randmax a!+ | x
    600.0 randmax a!+ | y
    -2.0 2.0 randminmax a!+ | vx
    -2.0 2.0 randminmax a!+ | vy
    ) drop 
  ;

:draw-particles
  $FFFFFF SDLColor
  'paticles >a
  100 ( 1? 1-
	a@+ int. a@+ int. 5 SDLFCircle | warning coord are the integer part
	a@+ a> 24 - +! | vx 'x +!
	a@+ a> 24 - +! | vy 'y +!
  ) drop
  ;
```

### Frame-Independent Animation
```r3forth
#anim-time 0

:init-animation
  timer<
  0 'anim-time !
  ;

:update-animation
  timer.
  anim-time timer+ 'anim-time !
  
  | Use anim-time for smooth animation
  anim-time $FFFF and  | Get angle
  ;

:game-loop
  update-animation
  | ... use animation value ...
  SDLredraw
  ;
```

### Packed Animation
```r3forth
#walk-anim

:init-walk
  | 8 frames starting at 0, scale 8
  0 8 8 ICS>anim 'walk-anim !
  ;

:update-walk
  walk-anim timer+ 'walk-anim !
  
  | Get current frame
  walk-anim anim>n
  
  | Draw frame
  player-x player-y rot char-sheet ssprite
  ;
```

---

## Best Practices

1. **Use appropriate primitive for task**
   ```r3forth
   | Good: specific function
   SDLFCircle  | Fast filled circle
   
   | Avoid: generic geometry
   | Manual circle with triangles
   ```

2. **Cache complex renders**
   ```r3forth
   | Good: render once
   create-background
   ( game-loop 0 0 background-texture SDLImage )
   
   | Avoid: redraw every frame
   ( game-loop draw-complex-background )
   ```

3. **Use sprite sheets over individual images**
   ```r3forth
   | Good: one texture, many sprites
   ssload
   
   | Avoid: many small textures
   ```

4. **Reset tints after use**
   ```r3forth
   $80FF0000 sstint
   draw-sprites
   ssnotint  | Always reset
   ```

5. **Free resources when done**
   ```r3forth
   my-tileset tsfree
   texture SDL_DestroyTexture
   ```

6. **Use timer system for smooth animation**
   ```r3forth
   timer<
   ( frame timer. animation timer+ ... )
   ```

---

## Performance Tips

1. **Minimize state changes** - Group draws by color/texture
2. **Use sprite sheets** - Reduces texture switches
3. **Cache static content** - Use `texIni`/`texEnd`
4. **Batch primitives** - Draw multiple points with single call
5. **Use appropriate zoom** - Don't scale if not needed

---

## Notes

- **Coordinate system:** Top-left origin, Y down
- **Angles:** Bangles (0-1.0 = 0-360°)
- **Zoom:** Fixed-point (1.0)
- **Colors:** 24-bit RGB or 32-bit ARGB
- **Sprite centering:** Sprites draw centered, images draw top-left
- **Tilesets:** Indexed from 0, row-major order
- **Animation packing:** Max 4095 frames, 255 count, 4095 scale
- **Timer precision:** Milliseconds
- **Texture limits:** Depends on GPU (typically 8192×8192 max)