# R3forth Libraries Documentation

## Overview

This document provides comprehensive documentation for the standard libraries available in R3forth. Each library is designed to extend the core language with specific functionality while maintaining the stack-based, concatenative philosophy of R3forth.

Libraries are included in R3forth programs using the `^` prefix:
```forth
^lib/console.r3
^lib/math.r3
```

## Library Documentation Format

Each library section includes:
- **Purpose**: Brief description of the library's functionality
- **Include Path**: How to include the library
- **Dependencies**: Other libraries required (if any)
- **Word Reference**: Complete list of words with stack effects and descriptions
- **Usage Examples**: Practical code examples

---

## Core Libraries Index

### System Libraries
- **console.r3** - Console I/O and text formatting
- **math.r3** - Extended mathematical operations and fixed-point arithmetic
- **mem.r3** - Memory management utilities
- **str.r3** - String manipulation functions

### Graphics Libraries
- **sdl2.r3** - SDL2 base functionality
- **sdl2gfx.r3** - SDL2 graphics primitives
- **sdl2image.r3** - Image loading and manipulation
- **sdl2mixer.r3** - Audio playback and mixing

### Data Structure Libraries
- **vec.r3** - Dynamic vectors/arrays
- **list.r3** - Linked list operations
- **hash.r3** - Hash table implementation

### Utility Libraries
- **file.r3** - File I/O operations
- **rand.r3** - Random number generation
- **time.r3** - Time and date functions
- **net.r3** - Network operations

---

## Library Documentation

*Documentation for each library will be added below as provided*

## lib/sdl2gfx.r3

### Purpose
Provides graphics primitives and sprite rendering capabilities for SDL2, including basic shapes, image handling, tilesets, sprites with rotation/zoom, and texture composition.

### Include Path
```forth
^r3/lib/sdl2gfx.r3
```

### Dependencies
- `^r3/lib/sdl2.r3` - Base SDL2 functionality
- `^r3/lib/sdl2image.r3` - Image loading support

### Word Reference

#### Color Management

| Word | Stack Effect | Description |
|------|-------------|-------------|
| `SDLColor` | col -- | Set render color (RGB, no alpha) from 24-bit hex value |
| `SDLColorA` | col -- | Set render color with alpha from 32-bit ARGB hex value |

#### Screen Operations

| Word | Stack Effect | Description |
|------|-------------|-------------|
| `SDLcls` | color -- | Clear screen with specified color |
| `SDLPoint` | x y -- | Draw a single pixel at x,y |
| `SDLGetPixel` | x y -- rgb | Read pixel color at x,y (returns 24-bit RGB) |

#### Line Drawing

| Word | Stack Effect | Description |
|------|-------------|-------------|
| `SDLLine` | x1 y1 x2 y2 -- | Draw line from (x1,y1) to (x2,y2) |
| `SDLLineH` | x1 y x2 -- | Draw horizontal line from x1 to x2 at y |
| `SDLLineV` | x y1 y2 -- | Draw vertical line from y1 to y2 at x |

#### Rectangle Operations

| Word | Stack Effect | Description |
|------|-------------|-------------|
| `SDLRect` | x y w h -- | Draw rectangle outline |
| `SDLFRect` | x y w h -- | Draw filled rectangle |
| `SDLRound` | r x y w h -- | Draw rounded rectangle outline with radius r |
| `SDLFRound` | r x y w h -- | Draw filled rounded rectangle with radius r |

#### Ellipse and Circle Operations

| Word | Stack Effect | Description |
|------|-------------|-------------|
| `SDLEllipse` | rx ry x y -- | Draw ellipse outline with radii rx,ry centered at x,y |
| `SDLFEllipse` | rx ry x y -- | Draw filled ellipse with radii rx,ry centered at x,y |

#### Triangle Operations

| Word | Stack Effect | Description |
|------|-------------|-------------|
| `SDLTriangle` | x1 y1 x2 y2 x3 y3 -- | Draw filled triangle with three vertices |

#### Basic Image Operations

| Word | Stack Effect | Description |
|------|-------------|-------------|
| `SDLImage` | x y img -- | Draw image at position x,y |
| `SDLImages` | x y w h img -- | Draw image scaled to width w and height h |
| `SDLImageb` | box img -- | Draw image using box structure for destination |
| `SDLImagebb` | srcbox dstbox img -- | Draw image from source box to destination box |

#### Sprite Operations (Center-based)

| Word | Stack Effect | Description |
|------|-------------|-------------|
| `sprite` | x y img -- | Draw sprite centered at x,y |
| `spriteZ` | x y zoom img -- | Draw sprite with zoom factor (16-bit fixed point) |
| `spriteR` | x y angle img -- | Draw rotated sprite (angle in turns) |
| `spriteRZ` | x y angle zoom img -- | Draw sprite with rotation and zoom |

#### Tileset Operations

| Word | Stack Effect | Description |
|------|-------------|-------------|
| `tsload` | w h filename -- tileset | Load tileset with tiles of size w×h |
| `tscolor` | rrggbb tileset -- | Set color modulation for tileset |
| `tsalpha` | alpha tileset -- | Set alpha modulation for tileset |
| `tsdraw` | n tileset x y -- | Draw tile n from tileset at x,y |
| `tsdraws` | n tileset x y w h -- | Draw tile n scaled to w×h |
| `tsbox` | boxsrc n tileset -- | Get tile n dimensions into box structure |
| `tsfree` | tileset -- | Free tileset texture memory |

#### Sprite Sheet Operations

| Word | Stack Effect | Description |
|------|-------------|-------------|
| `ssload` | w h filename -- spritesheet | Load sprite sheet with sprites of size w×h |
| `sstint` | color -- | Set tint color for sprite sheet (AARRGGBB format) |
| `ssnotint` | -- | Remove tint from sprite sheet |
| `sspritewh` | spritesheet -- h w | Get sprite dimensions from sprite sheet |
| `ssprite` | x y n spritesheet -- | Draw sprite n centered at x,y |
| `sspriter` | x y angle n spritesheet -- | Draw rotated sprite n |
| `sspritez` | x y zoom n spritesheet -- | Draw zoomed sprite n |
| `sspriterz` | x y angle zoom n spritesheet -- | Draw sprite n with rotation and zoom |

#### Texture Composition

| Word | Stack Effect | Description |
|------|-------------|-------------|
| `texIni` | w h -- | Begin texture composition with specified dimensions |
| `texEnd` | -- texture | End texture composition and return texture |
| `texEndAlpha` | -- texture | End composition with alpha blending enabled |

#### Surface Operations

| Word | Stack Effect | Description |
|------|-------------|-------------|
| `createSurf` | w h -- surface | Create SDL surface with specified dimensions |
| `Surf>pix` | surface -- surface pixels | Get pixel data pointer from surface |
| `Surf>wh` | surface -- surface w h | Get width and height from surface |

#### Animation Support

| Word | Stack Effect | Description |
|------|-------------|-------------|
| `timer<` | -- | Reset animation timer |
| `timer.` | -- | Update animation timer |
| `timer+` | val -- val' | Add delta time to value |
| `timer-` | val -- val' | Subtract delta time from value |
| `ICS>anim` | init cnt scale -- animval | Create animation value from parameters |
| `vICS>anim` | v init cnt scale -- animval | Create animation with initial value |
| `anim>n` | animval -- frame | Get current animation frame number |
| `anim>c` | animval -- count | Get animation cycle count |
| `anim>stop` | animval -- animval' | Stop animation |

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
    $10000 player-sprite spriteRZ  | Draw with rotation and 1.0 zoom
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
    0 8 $1000 ICS>anim 'anim-state !  | 8 frames, scale 1.0
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
    100 100 50 SDLFEllipse      | Draw filled circle
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

---

## Common Library Patterns

### Stack Effect Notation
- `--` separates input from output
- Letters represent values (a, b, c, etc.)
- `*` represents variable number of items
- `|` adds comments about the values
- `?` indicates conditional execution

### Memory Conventions
- Words ending with `@` fetch from memory
- Words ending with `!` store to memory
- Words ending with `+` often increment pointers
- Words starting with `.` often relate to output/display

### Naming Conventions
- Lowercase for most words
- CamelCase for complex operations (e.g., `SDLinit`)
- Prefixes indicate library domain (SDL, GL, etc.)
- Suffixes indicate data size (c=byte, w=word, d=dword)

---

## Notes

- Libraries maintain R3forth's stack-based philosophy
- Most libraries avoid creating global state when possible
- Performance-critical libraries may use inline assembly
- Libraries are loaded once per program, even if included multiple times
- Private words (defined with `::`) are not accessible outside the library

---

*This documentation will be expanded as library implementations are provided*