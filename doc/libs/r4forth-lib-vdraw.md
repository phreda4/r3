# R3Forth VDraw Library (vdraw.r3)

A vector drawing library for R3Forth that provides efficient 2D shape rendering through callback functions, enabling custom pixel-level drawing operations for various backends (framebuffers, displays, virtual canvases).

## Overview

VDraw is a backend-agnostic drawing library that works by calling user-defined functions for pixel operations (set) and pixel reading (get). This design allows it to work with any rendering target: framebuffers, displays, textures, or custom data structures.

**Key Features:**
- Callback-based architecture for flexibility
- Line drawing with Bresenham's algorithm
- Flood fill with scanline algorithm
- Rectangle and ellipse primitives
- Optimized for integer coordinates
- Memory-efficient operation

**Dependencies:**
- `r3/lib/mem.r3` - Memory management
- `r3/lib/math.r3` - Fixed-point arithmetic

---

## Configuration

### Setup Functions

- **`vset!`** `( 'callback -- )` - Set pixel drawing callback
  - Callback signature: `( x y -- )`
  - Called for each pixel to be drawn
  - Must handle coordinate validation if needed
  ```
  [ myPixel! ; ] vset!  | Set pixel drawing function
  ```

- **`vget!`** `( 'callback -- )` - Set pixel reading callback
  - Callback signature: `( x y -- color )`
  - Called to read pixel value at coordinate
  - Used by flood fill algorithm
  ```
  [ myPixel@ ; ] vget!  | Set pixel reading function
  ```

- **`vsize!`** `( w h -- )` - Set drawing area dimensions
  - `w`: Maximum width (pixels)
  - `h`: Maximum height (pixels)
  - Used for boundary checking in fill operations
  ```
  800 600 vsize!  | Set drawing area to 800×600
  ```

---

## Drawing Operations

### Line Drawing

- **`vop`** `( x y -- )` - Move to position (set origin point)
  - Sets starting point for line drawing
  - Does not draw anything
  - Similar to "pen up" in turtle graphics
  ```
  100 100 vop  | Move to (100, 100)
  ```

- **`vline`** `( x y -- )` - Draw line from last position to new position
  - Draws line from previous vop/vline point to (x, y)
  - Uses optimized line algorithm
  - Automatically handles horizontal, vertical, and diagonal lines
  - Similar to "pen down" in turtle graphics
  ```
  100 100 vop
  200 150 vline  | Draw line from (100,100) to (200,150)
  300 200 vline  | Draw line from (200,150) to (300,200)
  ```

---

## Shape Primitives

### Rectangles

- **`vrect`** `( x1 y1 x2 y2 -- )` - Draw rectangle outline
  - (x1, y1): Top-left corner
  - (x2, y2): Bottom-right corner
  - Draws only the border (4 lines)
  - Coordinates can be in any order (auto-sorted)
  ```
  50 50 150 100 vrect  | Rectangle outline
  ```

- **`vfrect`** `( x1 y1 x2 y2 -- )` - Draw filled rectangle
  - Fills entire rectangle area
  - Calls vset for every pixel inside
  - Optimized with horizontal scanlines
  ```
  50 50 150 100 vfrect  | Filled rectangle
  ```

### Ellipses

- **`vellipse`** `( rx ry cx cy -- )` - Draw filled ellipse
  - `rx`: X radius (horizontal)
  - `ry`: Y radius (vertical)
  - `cx`, `cy`: Center position
  - Fills entire ellipse area
  - Uses modified midpoint algorithm
  ```
  50 30 200 150 vellipse  | Ellipse centered at (200,150)
  ```

- **`vellipseb`** `( rx ry cx cy -- )` - Draw ellipse outline (border)
  - Same parameters as vellipse
  - Draws only the perimeter
  - Calls vset twice per scanline (left and right edges)
  ```
  50 30 200 150 vellipseb  | Ellipse border
  ```

---

## Flood Fill

### Area Filling

- **`vfill`** `( color x y -- )` - Flood fill from seed point
  - `color`: Color to set (passed to vset callback)
  - `x`, `y`: Starting seed point
  - Fills all connected pixels of same color
  - Uses scanline flood fill algorithm
  - Stops at boundaries (different colors)
  - Requires both vget and vset callbacks
  - Does nothing if seed point already has target color
  ```
  $ff0000 150 120 vfill  | Fill with red from (150,120)
  ```

**Algorithm:**
- Reads seed point color with vget
- Fills scanlines horizontally
- Scans above and below for connected regions
- Uses stack-based approach for recursion
- Memory efficient for complex shapes

---

## Implementation Examples

### Basic Setup

```r3forth
| Setup for framebuffer drawing
#framebuffer * 640000  | 800×600 pixels

:fb! | x y --
    800 * + framebuffer + c! ;

:fb@ | x y -- color
    800 * + framebuffer + c@ ;

:initVDraw
    [ fb! ; ] vset!
    [ fb@ ; ] vget!
    800 600 vsize! ;

initVDraw
```

### Drawing Lines

```r3forth
:drawBox
    | Draw square outline
    100 100 vop
    200 100 vline  | Top
    200 200 vline  | Right
    100 200 vline  | Bottom
    100 100 vline  | Left (close box)
    ;

:drawStar
    | Draw 5-pointed star
    150 50 vop
    120 150 vline
    200 90 vline
    100 90 vline
    180 150 vline
    150 50 vline ;
```

### Complex Shapes

```r3forth
:drawHouse
    | Walls
    100 150 200 250 vfrect
    
    | Roof (triangle with lines)
    100 150 vop
    150 100 vline
    200 150 vline
    
    | Door
    130 200 170 250 vfrect
    
    | Window
    110 170 130 190 vrect ;
```

### Flood Fill Application

```r3forth
#currentColor 0

:setColor | color --
    'currentColor ! ;

:drawPixel | x y --
    800 * + framebuffer + currentColor swap c! ;

:readPixel | x y -- color
    800 * + framebuffer + c@ ;

:initFill
    [ drawPixel ; ] vset!
    [ readPixel ; ] vget!
    800 600 vsize! ;

:paintBucket | x y color --
    rot rot  | color x y
    2dup readPixel pick3 =? ( 4drop ; )  | Already that color
    -rot pick2 swap  | color color x y
    vfill drop ;

initFill

| Draw outline
50 50 250 250 vrect

| Fill inside
$ff0000 150 150 vfill  | Fill with red
```

### Ellipse Patterns

```r3forth
:drawConcentricCircles
    10 ( 100 <?
        dup dup 200 200 vellipseb  | Draw border
        10 +
    ) drop ;

:drawEllipsePattern
    0 ( 360 <?
        dup 360 */ 100 *. 200 + >r  | Calculate x
        dup 360 */ 50 *. 200 + >r   | Calculate y
        30 20 r> r> vellipse
        10 +
    ) drop ;
```

---

## Advanced Usage

### Custom Rendering Backend

```r3forth
| Example: Draw to texture with color
#texture * 1000000
#drawColor $ffffff

:texSetPixel | x y --
    1024 * + texture + drawColor swap ! ;

:texGetPixel | x y -- color
    1024 * + texture + @ ;

:setupTexture
    [ texSetPixel ; ] vset!
    [ texGetPixel ; ] vget!
    1024 1024 vsize! ;

setupTexture
drawColor 'currentColor !
```

### Alpha Blending Callback

```r3forth
#backbuffer * 640000
#alpha 128

:alphaBlend | x y --
    2dup backbuffer + c@  | old color
    currentColor alpha colmix  | blend
    swap backbuffer + c! ;

[ alphaBlend ; ] vset!
```

### Clipping Rectangle

```r3forth
#clipX1 #clipY1 #clipX2 #clipY2

:clippedSet | x y --
    dup clipY1 <? ( 2drop ; )
    dup clipY2 >? ( 2drop ; )
    over clipX1 <? ( 2drop ; )
    over clipX2 >? ( 2drop ; )
    actualDrawPixel ;

[ clippedSet ; ] vset!
```

### Pattern Fill

```r3forth
#pattern [ $ff $00 $ff $00 $ff $00 $ff $00 ]

:patternSet | x y --
    over 7 and over 7 and 8 * + pattern + c@
    swap actualDrawPixel ;

[ patternSet ; ] vset!
```

---

## Complete Examples

### Paint Program

```r3forth
^r3/lib/sdl2gfx.r3
^r3/util/vdraw.r3

#screen * 640000
#penColor $ffffff
#fillMode 0

:scr! | x y --
    800 * + screen + penColor swap c! ;

:scr@ | x y -- color
    800 * + screen + c@ ;

:initPaint
    [ scr! ; ] vset!
    [ scr@ ; ] vget!
    800 600 vsize! ;

:drawToScreen
    0 ( 600 <?
        0 ( 800 <?
            2dup scr@
            SDLColor
            2dup 1 1 SDLFRect
            1+
        ) drop
        1+
    ) drop ;

:handleMouse
    sdlb 0? ( drop ; )
    
    fillMode 1 =? (
        penColor sdlx sdly vfill
        drop ;
    ) drop
    
    | Draw mode
    sdlx sdly vline ;

:mainLoop
    <esc> SDLkey =? ( ; )
    
    handleMouse
    drawToScreen
    SDLredraw
    mainLoop ;

initPaint
sdlx sdly vop
mainLoop
```

### Graph Plotter

```r3forth
:plotFunction | 'function --
    0 vop
    0 ( 800 <?
        dup over ex  | x f(x)
        vline
        1+
    ) 2drop ;

:sine | x -- y
    360 */ sin. 100 *. 300 + ;

:parabola | x -- y
    400 - dup * 1000 / 300 + ;

[ sine ; ] plotFunction
[ parabola ; ] plotFunction
```

### Maze Solver

```r3forth
| Use flood fill to solve maze
#maze * 10000  | 100×100 maze

:mazeGet | x y -- wall?
    100 * + maze + c@ ;

:mazeFill | x y --
    100 * + maze + 2 swap c! ;  | Mark as path

:solveMaze | startX startY --
    [ mazeGet 0 =? ; ] vget!  | Passable=0
    [ mazeFill ; ] vset!
    100 100 vsize!
    
    0 swap swap vfill  | Fill from start
    
    | Now check if exit is marked
    ;
```

---

## Algorithm Details

### Line Drawing (Bresenham)

The library uses an optimized Bresenham line algorithm with special cases:
- **Horizontal lines**: Direct loop, no division
- **Vertical lines**: Direct loop
- **Diagonal lines**: Fixed-point interpolation

### Flood Fill (Scanline)

Stack-based scanline algorithm:
1. Fill current scanline left and right
2. Check line above for connected regions
3. Check line below for connected regions
4. Push new seed points on stack
5. Repeat until stack empty

**Advantages:**
- Memory efficient (only stores seed points)
- Faster than recursive approach
- No stack overflow for large areas

### Ellipse Drawing (Midpoint)

Uses modified midpoint ellipse algorithm:
- Separates into regions for optimal stepping
- Integer arithmetic only
- Symmetric drawing (4-way symmetry)

---

## Performance Tips

1. **Optimize callbacks**: vset/vget called for every pixel
2. **Batch operations**: Group multiple shapes before display
3. **Horizontal lines**: Fastest drawing primitive
4. **Fill vs outline**: Filled shapes much faster than multiple outlines
5. **Coordinate sorting**: vrect/vfrect auto-sort, but pre-sorted is faster

---

## Best Practices

### 1. Always Initialize

```r3forth
| CORRECT
'mySet vset!
'myGet vget!
800 600 vsize!

| WRONG - undefined behavior
vline  | No vset callback set!
```

### 2. Validate in Callbacks

```r3forth
:safeSet | x y --
    dup 0 <? ( 2drop ; )
    dup maxHeight >=? ( 2drop ; )
    over 0 <? ( 2drop ; )
    over maxWidth >=? ( 2drop ; )
    actualSetPixel ;
```

### 3. Use vop Before vline

```r3forth
| CORRECT
x1 y1 vop
x2 y2 vline

| WRONG - undefined start point
x2 y2 vline  | Line from where?
```

### 4. Check Fill Seed Point

```r3forth
| CORRECT - check if fill needed
color x y 2dup vget@ pick3 <>? (
    vfill
) 3drop

| INEFFICIENT - always fills
color x y vfill
```

---

## Common Patterns

### Drawing Polylines

```r3forth
:polyline | 'points count --
    >r @+ @+ vop  | Start at first point
    r> 1- ( 1? 1-
        swap @+ @+ vline swap
    ) 2drop ;
```

### Drawing Polygons

```r3forth
:polygon | 'points count --
    dup >r polyline
    r> 3 << over + 8 - @  | Get last point
    swap @ vline ;  | Close to first
```

### Grid Drawing

```r3forth
:drawGrid | spacing --
    0 ( maxh <?
        0 over vop maxw over vline
        over +
    ) drop
    
    0 ( maxw <?
        dup >r
        dup 0 vop dup maxh vline
        over +
    ) 2drop ;
```

---

## Notes

- **Callback requirement**: vset must be set before drawing
- **Fill requirement**: vfill needs both vset and vget
- **Coordinate system**: Top-left origin (0,0)
- **Integer only**: All coordinates are integers
- **No antialiasing**: Pixel-perfect drawing only
- **Stack usage**: Fill uses temporary memory for seed points
- **Line continuity**: vline draws from last vop/vline position

## Limitations

- No curve drawing (Bezier, arc, etc.)
- No rotation or scaling
- No gradient fills
- Integer coordinates only (no subpixel precision)
- Flood fill limited by maxw/maxh bounds
- No built-in clipping (must implement in callbacks)

