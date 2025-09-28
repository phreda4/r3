# R3 Virtual Drawing Library Documentation

## Overview

`vdraw.r3` provides a virtual drawing system that abstracts 2D graphics operations through callback functions. This allows the same drawing code to work with different rendering backends (software, hardware, framebuffers) by simply changing the callback functions. It implements efficient algorithms for lines, rectangles, filled shapes, and ellipses with flood fill capabilities.

## Dependencies
- `r3/lib/mem.r3` - Memory management for dynamic operations
- `r3/lib/math.r3` - Mathematical operations for geometric calculations

## Core Concepts

### Virtual Drawing System
The library uses function pointers to abstract rendering operations:
- **Pixel Setting**: `vecs` callback for drawing individual pixels
- **Pixel Getting**: `vecg` callback for reading pixel values
- **Backend Independence**: Same code works with different renderers

### Coordinate System
- **Origin**: Top-left corner (0,0)
- **Bounds**: Defined by `maxw` × `maxh` dimensions
- **Clipping**: Automatic bounds checking for all operations

## System Setup

### Configuration Functions
```r3
vset!        | 'pixel_set_callback --    // Set pixel drawing function
vget!        | 'pixel_get_callback --    // Set pixel reading function
vsize!       | width height --           // Set virtual canvas size
```

**Callback Signatures:**
- `pixel_set_callback`: `| x y -- ` (draw pixel at coordinates)
- `pixel_get_callback`: `| x y -- color` (read pixel color)

**Example Setup:**
```r3
:my-pixel-set | x y --
    swap 800 * + framebuffer + 
    current-color swap ! ;

:my-pixel-get | x y -- color
    swap 800 * + framebuffer + @ ;

'my-pixel-set vset!
'my-pixel-get vget!
800 600 vsize!
```

## Drawing Operations

### Basic Line Drawing
```r3
vop          | x y --                   // Move to position (set current point)
vline        | x y --                   // Draw line from current point to x,y
```

The line drawing uses an optimized Bresenham-style algorithm that handles:
- **Horizontal lines**: Direct pixel runs for efficiency
- **Vertical lines**: Column-wise drawing
- **Diagonal lines**: Fixed-point arithmetic for smooth interpolation

### Rectangle Drawing
```r3
vrect        | x1 y1 x2 y2 --           // Draw rectangle outline
vfrect       | x1 y1 x2 y2 --           // Draw filled rectangle
```

**Examples:**
```r3
100 100 200 150 vrect                   // Draw rectangle outline
50 50 150 100 vfrect                    // Draw filled rectangle
```

### Ellipse Drawing
```r3
vellipse     | rx ry cx cy --            // Draw filled ellipse
vellipseb    | rx ry cx cy --            // Draw ellipse outline
```

Uses an efficient ellipse algorithm with:
- **Symmetry exploitation**: Draws four quadrants simultaneously
- **Integer arithmetic**: Avoids floating-point calculations
- **Smooth curves**: Proper pixel coverage for anti-aliasing

**Examples:**
```r3
50 30 200 150 vellipse                  // Filled ellipse (50×30 radius at 200,150)
25 25 100 100 vellipseb                 // Circle outline (25 radius at 100,100)
```

### Flood Fill
```r3
vfill        | color x y --             // Flood fill from point
```

Implements a stack-based flood fill algorithm:
- **Boundary detection**: Stops at color boundaries
- **Span filling**: Fills horizontal spans efficiently
- **Recursive expansion**: Expands above and below filled spans

**Example:**
```r3
$ff0000 150 200 vfill                   // Red flood fill starting at (150,200)
```

## Complete Usage Examples

### Software Framebuffer Renderer
```r3
#framebuffer * 800 * 600
#current-color $ffffff

:fb-set-pixel | x y --
    dup 0 <? ( 2drop ; ) 600 >=? ( 2drop ; )
    over 0 <? ( 2drop ; ) 800 >=? ( 2drop ; )
    
    800 * + framebuffer +
    current-color swap ! ;

:fb-get-pixel | x y -- color
    dup 0 <? ( 2drop 0 ; ) 600 >=? ( 2drop 0 ; )
    over 0 <? ( 2drop 0 ; ) 800 >=? ( 2drop 0 ; )
    
    800 * + framebuffer + @ ;

:setup-framebuffer
    'fb-set-pixel vset!
    'fb-get-pixel vget!
    800 600 vsize! ;

:set-color | color --
    'current-color ! ;

:draw-scene
    $ff0000 set-color
    100 100 vop                         // Move to start
    300 150 vline                       // Draw line
    
    $00ff00 set-color  
    150 200 250 300 vfrect              // Green rectangle
    
    $0000ff set-color
    40 30 400 350 vellipse              // Blue ellipse
    
    $ffff00 set-color
    200 250 vfill ;                     // Yellow flood fill

setup-framebuffer
draw-scene
```

### SDL2 Integration
```r3
:sdl-set-pixel | x y --
    current-color SDLrenderer SDL_SetRenderDrawColor
    SDLrenderer rot rot 1 1 SDL_RenderFillRect ;

:sdl-get-pixel | x y -- color
    | Read pixel from SDL surface/texture
    | (implementation depends on SDL2 pixel reading method)
    0 ; // Placeholder

:setup-sdl-drawing
    'sdl-set-pixel vset!
    'sdl-get-pixel vget!
    sw sh vsize! ;
```

### Texture/Image Drawing
```r3
#texture-buffer * 256 * 256
#texture-width 256
#texture-height 256

:tex-set-pixel | x y --
    texture-height * + texture-buffer +
    current-color swap ! ;

:tex-get-pixel | x y -- color  
    texture-height * + texture-buffer + @ ;

:setup-texture
    'tex-set-pixel vset!
    'tex-get-pixel vget!
    texture-width texture-height vsize! ;

:generate-texture-pattern
    setup-texture
    
    | Draw concentric circles
    0 ( 128 <? 
        dup 2* 1+ dup 128 128 vellipseb
        10 +
    ) drop
    
    | Add some rectangles
    64 64 192 192 vrect
    80 80 176 176 vrect ;
```

### Vector Graphics Renderer
```r3
#path-commands * 1000
#path-count 0

:path-moveto | x y --
    0 'path-commands path-count 3* + !  // Command: MOVETO
    'path-commands path-count 3* + 4 + !+ !
    1 'path-count +! ;

:path-lineto | x y --
    1 'path-commands path-count 3* + !  // Command: LINETO  
    'path-commands path-count 3* + 4 + !+ !
    1 'path-count +! ;

:render-path
    0 0 vop                             // Initialize position
    
    0 ( path-count <?
        dup 3* 'path-commands +
        @+ swap @+ swap @               // cmd x y
        
        rot 
        0 =? ( vop )                    // MOVETO
        1 =? ( vline )                  // LINETO
        2drop
        
        1+
    ) drop ;
```

## Algorithm Details

### Line Drawing Algorithm
The library implements an optimized line drawing algorithm:

```r3
:rline | xd yd --
    ya =? ( xa ihline ; )               // Horizontal line optimization
    xa ya pick2 <? ( 2swap )           // Ensure proper ordering
    
    | Fixed-point arithmetic for smooth lines
    pick2 - 1 + >r                     // Calculate span
    pick2 - r@ 16 <</                  // Delta in 16.16 format
    rot 16 << $8000 +                  // Starting position with rounding
    -rot r>                            // Stack: start_fp y delta count
    
    ( 1? 1- >r >r
        over 16 >> over pick3 r@ + 16 >> ihline  // Draw span
        1 + swap r@ + swap             // Update coordinates
        r> r>
    ) 4drop ;
```

### Flood Fill Algorithm
Uses a span-based flood fill for efficiency:

```r3
:fillline | adr y x1 -- adr'
    0 'sa ! 0 'sb !                    // Reset span flags
    ( maxw <?
        2dup swap vecg ex cf <>? ( 3drop ; ) drop  // Stop at boundary
        dup pick2 vecs ex              // Fill pixel
        spanabove                      // Check span above
        spanbelow                      // Check span below  
        1 +                            // Next x coordinate
    ) 2drop ;
```

## Performance Characteristics

### Line Drawing
- **Horizontal/Vertical**: O(n) where n is line length
- **Diagonal**: O(n) with fixed-point arithmetic overhead
- **Memory**: Constant stack usage

### Flood Fill
- **Time**: O(A) where A is filled area
- **Memory**: O(W) where W is maximum width of filled region
- **Stack-based**: Uses memory stack for span queue

### Ellipse Drawing
- **Time**: O(π × r) where r is average radius
- **Memory**: Constant
- **Symmetry**: 4-fold symmetry reduces calculations

## Optimization Strategies

### Backend-Specific Optimizations
```r3
:optimized-hline | y x1 x2 --
    | Direct memory operations for horizontal lines
    2dup >? ( swap ) 
    pick2 framebuffer + over 800 * +   // Calculate start address
    pick2 over - 1+ current-color fill  // Fast memory fill
    3drop ;
```

### Clipping Integration
```r3
:clipped-pixel-set | x y --
    dup 0 maxh between? over 0 maxw between? and
    ? ( vecs ex ; ) 2drop ;
```

## Integration Patterns

### With Animation System
```r3
:animated-circle | t --
    t sin 100.0 *. 300.0 +             // Animated center x
    t cos 50.0 *. 200.0 +              // Animated center y
    t 10.0 *. sin abs 20.0 *. 10.0 +   // Animated radius
    dup vellipse ;
```

### With UI System
```r3
:draw-button | x y w h "text" --
    | Draw button background
    2over 2over vfrect
    
    | Draw button border  
    pick3 pick3 pick3 pick3 + pick3 + vrect
    
    | Text would be drawn with different system
    2drop 2drop drop ;
```

## Best Practices

1. **Efficient Callbacks**: Keep pixel set/get functions as fast as possible
2. **Bounds Checking**: Handle clipping in callbacks for safety
3. **Color Management**: Use consistent color format across system
4. **Memory Usage**: Monitor stack usage during flood fill operations
5. **Backend Selection**: Choose appropriate backend for performance needs

This virtual drawing system provides a clean abstraction for 2D graphics while maintaining the performance characteristics essential for real-time applications in the R3 environment.