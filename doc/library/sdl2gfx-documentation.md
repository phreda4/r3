# SDL2 Graphics Library Documentation (r3)

## Overview
This is a graphics library for SDL2 written in r3 programming language, providing various drawing primitives, image handling, sprite rendering, and animation capabilities.

## Dependencies
- `r3/lib/sdl2.r3` - Core SDL2 bindings
- `r3/lib/sdl2image.r3` - SDL2 image loading support

## Core Drawing Functions

### Color Management
- **`rgb24`** `( rgb -- r g b )` - Convert RGB color to individual components
- **`rgb32`** `( argb -- r g b a )` - Convert ARGB color to individual components with alpha
- **`SDLColor`** `( col -- )` - Set renderer draw color (no alpha)
- **`SDLColorA`** `( col -- )` - Set renderer draw color with alpha
- **`SDLcls`** `( color -- )` - Clear screen with specified color

### Basic Drawing
- **`SDLPoint`** `( x y -- )` - Draw a single point
- **`SDLGetPixel`** `( x y -- value )` - Get pixel color at position
- **`SDLLine`** `( x1 y1 x2 y2 -- )` - Draw line between two points
- **`SDLLineH`** `( x y x2 -- )` - Draw horizontal line
- **`SDLLineV`** `( x y y2 -- )` - Draw vertical line

### Rectangles
- **`SDLRect`** `( x y w h -- )` - Draw rectangle outline
- **`SDLFRect`** `( x y w h -- )` - Draw filled rectangle
- **`SDLRound`** `( r x y w h -- )` - Draw rounded rectangle
- **`SDLFRound`** `( r x y w h -- )` - Draw filled rounded rectangle

### Circles and Ellipses
- **`SDLCircle`** `( r x y -- )` - Draw circle outline
- **`SDLFCircle`** `( r x y -- )` - Draw filled circle
- **`SDLEllipse`** `( rx ry x y -- )` - Draw ellipse outline
- **`SDLFEllipse`** `( rx ry x y -- )` - Draw filled ellipse

### Triangles
- **`SDLTriangle`** `( x1 y1 x2 y2 x3 y3 -- )` - Draw filled triangle

## Image Handling

### Basic Image Operations
- **`SDLImage`** `( x y img -- )` - Draw image at position
- **`SDLImages`** `( x y w h img -- )` - Draw scaled image
- **`SDLImageb`** `( box img -- )` - Draw image using box coordinates
- **`SDLImagebb`** `( srcbox dstbox img -- )` - Draw image with source and destination boxes

## Tileset Management

### Loading and Configuration
- **`tsload`** `( w h filename -- tileset )` - Load tileset with specified tile dimensions
- **`tscolor`** `( rrggbb tileset -- )` - Set color modulation for tileset
- **`tsalpha`** `( alpha tileset -- )` - Set alpha modulation for tileset

### Drawing Tiles
- **`tsdraw`** `( n tileset x y -- )` - Draw tile at position
- **`tsdraws`** `( n tileset x y w h -- )` - Draw scaled tile
- **`tsbox`** `( boxsrc n tileset -- )` - Get tile box coordinates
- **`tsfree`** `( tileset -- )` - Free tileset resources

## Sprite System

### Basic Sprites
- **`sprite`** `( x y img -- )` - Draw centered sprite
- **`spriteZ`** `( x y zoom img -- )` - Draw scaled sprite
- **`spriteR`** `( x y angle img -- )` - Draw rotated sprite
- **`spriteRZ`** `( x y angle zoom img -- )` - Draw rotated and scaled sprite

### Sprite Sheets (Advanced)
- **`ssload`** `( w h filename -- spritesheet )` - Load sprite sheet
- **`sstint`** `( color -- )` - Set sprite tint color (AARRGGBB format)
- **`ssnotint`** - Remove sprite tinting
- **`sspritewh`** `( spritesheet -- h w )` - Get sprite dimensions

### Sprite Sheet Drawing
- **`ssprite`** `( x y n spritesheet -- )` - Draw sprite from sheet
- **`sspriter`** `( x y angle n spritesheet -- )` - Draw rotated sprite
- **`sspritez`** `( x y zoom n spritesheet -- )` - Draw scaled sprite
- **`sspriterz`** `( x y angle zoom n spritesheet -- )` - Draw rotated and scaled sprite

## Surface Management
- **`createSurf`** `( w h -- surface )` - Create new surface
- **`Surf>pix`** `( surface -- surf pixels )` - Get surface pixel data
- **`Surf>wh`** `( surface -- surf w h )` - Get surface dimensions
- **`Surf>pixpi`** `( surface -- pixels pitch )` - Get pixel data and pitch

## Texture Composition
- **`texIni`** `( w h -- )` - Initialize texture composition
- **`texEnd`** `( -- texture )` - Finish texture composition
- **`texEndAlpha`** `( -- texture )` - Finish with alpha blending
- **`tex2static`** `( texture -- newtexture )` - Convert to static texture

## Timing and Animation

### Timer Functions
- **`timer<`** - Reset timer
- **`timer.`** - Advance timer
- **`timer+`** - Add delta time to value
- **`timer-`** - Subtract delta time from value

### Animation System
- **`ICS>anim`** `( init cnt scale -- animval )` - Create animation value
- **`vICS>anim`** `( v init cnt scale -- animval )` - Create animation with initial value
- **`anim>n`** `( anim -- frame )` - Get current animation frame
- **`anim>c`** `( anim -- count )` - Get animation count
- **`anim>stop`** `( anim -- anim )` - Stop animation

## Internal Data Structures

### Variables
- `rec` - Auxiliary rectangle buffer
- `vert` - Vertex buffer for geometry rendering
- `index` - Index buffer for triangles
- `xm`, `ym` - Temporary coordinates
- `dx`, `dy` - Delta values for calculations
- `deltatime` - Frame time delta
- `prevt` - Previous frame time
- `comptex` - Composition texture handle

## Usage Notes

1. **Color Format**: Colors are typically in RGB (0xRRGGBB) or ARGB (0xAARRGGBB) format
2. **Coordinates**: Use integer coordinates for pixel-perfect rendering
3. **Angles**: Angles are typically in fixed-point format (use `sincos` for conversion)
4. **Zoom**: Zoom values use fixed-point arithmetic (16-bit precision)
5. **Memory**: The library uses stack-based memory management with `ab[` and `]ba` blocks

## Performance Considerations

- Use batch rendering when possible (multiple points/lines at once)
- Sprites use GPU geometry rendering for efficient transformation
- Tilesets are optimized for drawing multiple tiles from the same texture
- Surface operations are slower than direct texture rendering

### Usage Examples

```forth
| Example 1: Basic shapes and colors
^r3/lib/sdl2gfx.r3

:draw-scene
    $FF0000 SDLcls              | Clear screen with red
    $00FF00 SDLColor            | Set green color
    100 100 200 200 SDLLine     | Draw diagonal line
    50 50 100 50 SDLFRect       | Draw filled rectangle
    ;

| Example 2: Sprite with rotation and zoom
^r3/lib/sdl2gfx.r3

#player-sprite

:init-game
    "player.png" loadimg 'player-sprite !
    ;

:draw-player | x y angle --
    1.0 player-sprite spriteRZ  | Draw with rotation and 1.0 zoom
    ;

| Example 3: Tileset usage
^r3/lib/sdl2gfx.r3

#tilemap

:load-tiles
    32 32 "tiles.png" tsload 'tilemap !
    ;

:draw-tile | tile-index x y --
    tilemap swap rot tsdraw
    ;

| Example 4: Animated sprite sheet
^r3/lib/sdl2gfx.r3

#spritesheet
#anim-state

:init-animation
    64 64 "character.png" ssload 'spritesheet !
    0 8 1.0 ICS>anim 'anim-state !  | 8 frames, scale 1.0
    ;

:update-animation
    timer.                          | Update timer
    anim-state timer+ 'anim-state ! | Advance animation
    ;

:draw-animated-sprite | x y --
    anim-state anim>n spritesheet ssprite
    ;

| Example 5: Texture composition
^r3/lib/sdl2gfx.r3

:create-composite-texture
    512 512 texIni              | Start 512x512 texture
    $000000 SDLcls              | Clear to black
    | Draw multiple elements to texture
    100 100 50 150 SDLFEllipse  | Draw filled ellipse
    200 200 100 100 SDLFRect    | Draw rectangle
    texEndAlpha                 | Finish with alpha blending
    ;
```

### Notes

- Angles are in "turns" where 0.5 = 180°, 1.0 = 360°
- Zoom factors use 16-bit fixed point (65536 = 1.0)
- Color format is typically $RRGGBB for RGB or $AARRGGBB for ARGB
- Sprites are drawn centered at the specified position
- Tilesets and sprite sheets divide images into uniform grids
- The texture composition system allows creating complex textures at runtime
- Animation system uses delta time for frame-independent animation
