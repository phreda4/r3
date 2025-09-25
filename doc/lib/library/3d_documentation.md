# R3 3D Mathematics Library Documentation

## Overview

`3d.r3` is a comprehensive 3D mathematics library for R3 that provides projection, transformation, and matrix operations for 3D graphics rendering. It integrates with SDL2 and OpenGL to provide complete 3D graphics capabilities.

## Dependencies
- `r3/lib/sdl2.r3` - SDL2 graphics library
- `r3/lib/3dgl.r3` - 3D OpenGL utilities

## Global Variables

### Screen Parameters
```r3
#xf #yf                   // X and Y focal lengths (projection factors)
#ox #oy                   // Screen center offset (origin)
```

These variables define the projection parameters and screen center for 3D-to-2D conversion.

## Projection Modes

### `2dmode | --`
Sets up 2D rendering mode.
- Sets origin to screen center
- No focal length calculation (2D only)

**Example:**
```r3
2dmode                    // Switch to 2D rendering
```

### `3dmode | fov --`
Sets up 3D perspective projection with field of view.

**Parameters:**
- `fov` - Field of view factor (affects perspective strength)

**Example:**
```r3
1.0 3dmode               // Setup 3D with standard FOV
0.5 3dmode               // Setup 3D with wider FOV
```

### `Omode | --`
Sets up orthographic projection mode.
- Uses minimum of screen width/height for uniform scaling
- No perspective distortion

**Example:**
```r3
Omode                    // Switch to orthographic projection
```

### `whmode | w h --`
Sets up projection with custom width and height.

**Parameters:**
- `w` - Virtual screen width
- `h` - Virtual screen height

**Example:**
```r3
1024 768 whmode          // Setup for 1024×768 virtual screen
```

### `o3dmode | w h --`
Alternative 3D mode setup with custom dimensions.

## Basic Projection Functions

### `p3d | x y z -- x y`
Projects 3D point to 2D screen coordinates.

**Parameters:**
- `x, y, z` - 3D world coordinates
- **Returns:** `x, y` - 2D screen coordinates

**Example:**
```r3
100.0 50.0 200.0 p3d     // Project (100,50,200) to screen
drawpoint                 // Draw the projected point
```

### `p3dz | x y z -- x y z`
Projects 3D point while preserving Z coordinate.

**Example:**
```r3
obj-x obj-y obj-z p3dz   // Project keeping Z for depth testing
```

### `p3di | x y z -- z y x`
Inverted projection (returns coordinates in Z,Y,X order).

### `p3dcz | z -- 1/z`
Calculates reciprocal of Z for perspective division.

**Example:**
```r3
obj-z p3dcz              // Get 1/z for perspective-correct interpolation
```

## High-Performance Projection

### `p3d1 | x y z -- x y`
Fast projection using bit shifts (9-bit precision).
- Faster than `p3d` but lower precision
- Good for performance-critical applications

### `p3di1 | x y z -- z y x`
Fast inverted projection using bit shifts.

## Transform-Based Projection

### `project3d | x y z -- u v`
Projects 3D point through current transformation matrix.

**Example:**
```r3
:render-object
    obj-x obj-y obj-z project3d
    sprite-draw ;
```

### `project3dz | x y z -- z x y`
Projects with transformation, preserving Z coordinate.

### `invproject3d | x y z -- x y`
Inverse projection from screen to world coordinates.

### `projectdim | x y z -- u v`
Projects dimensions (for scaling) rather than positions.

### `project | x y z -- u v`
Simple projection without transformation matrix.

### `projectv | x y z -- u v`
Vector projection (for directions, not positions).

## Screen Utilities

### `inscreen | -- x y`
Projects current transformation origin to screen coordinates.

### `proyect2d | x y z -- x y`
2D projection (ignores Z, adds screen offset).

### `aspect | -- a`
Returns screen aspect ratio as fixed-point number.

**Example:**
```r3
aspect                   // Get aspect ratio
fov *. 'adjusted-fov !   // Adjust FOV for aspect ratio
```

## Matrix Transformations

### Translation

#### `mtrans | x y z --`
Applies translation to current matrix.

**Example:**
```r3
100.0 50.0 200.0 mtrans  // Translate by (100, 50, 200)
```

#### `mtransi | x y z --`
Pre-multiplies translation (inverse order).

### Rotation

#### `mrotxi | x --`
Rotates around X-axis by angle `x` (in bangles).

**Example:**
```r3
$4000 mrotxi             // Rotate 90° around X-axis
```

#### `mrotyi | y --`
Rotates around Y-axis by angle `y`.

**Example:**
```r3
$2000 mrotyi             // Rotate 45° around Y-axis
```

#### `mrotzi | z --`
Rotates around Z-axis by angle `z`.

**Example:**
```r3
$8000 mrotzi             // Rotate 180° around Z-axis
```

## Complete 3D Rendering Example

```r3
| 3D Cube Renderer
#cube-vertices
| Front face
-1.0 -1.0  1.0
 1.0 -1.0  1.0
 1.0  1.0  1.0
-1.0  1.0  1.0
| Back face  
-1.0 -1.0 -1.0
 1.0 -1.0 -1.0
 1.0  1.0 -1.0
-1.0  1.0 -1.0

#rotation 0

:draw-cube
    matident               // Reset matrix
    
    | Apply transformations
    0 0 5.0 mtrans        // Move away from camera
    rotation mrotyi        // Rotate around Y
    rotation 2/ mrotxi     // Rotate around X
    
    | Draw cube faces
    'cube-vertices >a
    | Front face
    a@+ a@+ a@+ project3d moveto    // Vertex 0
    a@+ a@+ a@+ project3d lineto    // Vertex 1  
    a@+ a@+ a@+ project3d lineto    // Vertex 2
    a@+ a@+ a@+ project3d lineto    // Vertex 3
    close-path
    
    | Draw other faces...
    | (Similar code for remaining 5 faces)
    ;

:setup-3d
    1.0 3dmode             // Setup perspective projection
    0 'rotation !
    ;

:update-rotation
    rotation $100 +        // Increment rotation
    $ffff and 'rotation !
    ;

:main-loop
    cls
    update-rotation
    draw-cube
    'main-loop onkey ;

setup-3d
main-loop
```

## Camera System Example

```r3
| Simple camera system
#camera-x 0.0
#camera-y 0.0  
#camera-z -5.0
#camera-yaw 0
#camera-pitch 0

:setup-camera
    matident
    camera-pitch neg mrotxi     // Apply pitch
    camera-yaw neg mrotyi       // Apply yaw
    camera-x neg camera-y neg camera-z neg mtrans  // Apply position
    ;

:move-camera | dx dy dz --
    camera-z +! camera-y +! camera-x +! ;

:rotate-camera | dyaw dpitch --
    camera-pitch +! camera-yaw +! ;

:render-scene
    setup-camera
    | Render objects using transformed coordinates
    'objects ( @+ 1?
        dup @ over 4 + @ over 8 + @    // Get x,y,z
        project3d                       // Project to screen
        draw-object                     // Draw object
        12 +                           // Next object
    ) drop ;
```

## Optimization Techniques

### Level of Detail (LOD)
```r3
:get-lod | obj-addr -- lod-level
    dup @ over 4 + @ over 8 + @       // Get position
    camera-x - dup *.                 // Distance calculation
    camera-y over 4 + @ - dup *. + 
    camera-z over 8 + @ - dup *. +
    sqrt.                             // Distance from camera
    
    | Choose LOD based on distance
    100.0 <? ( 0 nip ; )             // High detail
    500.0 <? ( 1 nip ; )             // Medium detail  
    2 ;                              // Low detail
```

### Frustum Culling
```r3
:in-frustum | x y z -- flag
    | Simple frustum test
    dup 0.1 <? ( 3drop 0 ; )         // Behind near plane
    100.0 >? ( 3drop 0 ; )           // Beyond far plane
    
    project3d                         // Convert to screen space
    dup 0 <? ( 2drop 0 ; )           // Left of screen
    sw >? ( 2drop 0 ; )              // Right of screen
    dup 0 <? ( drop 0 ; )            // Above screen  
    sh >? ( 0 ; )                    // Below screen
    1 ;                              // Inside frustum
```

## Performance Characteristics

### Projection Speed Comparison
- `p3d1` - Fastest, 9-bit precision
- `p3d` - Standard speed, full precision  
- `project3d` - Slower, includes matrix transformation
- `project3dz` - Slowest, includes Z and transformation

### Memory Usage
- Global state: 32 bytes (4 × 64-bit values)
- Matrix stack: Depends on 3dgl.r3 implementation
- No dynamic allocation required

## Best Practices

1. **Choose Appropriate Projection**: Use `p3d1` for particles, `project3d` for geometry
2. **Batch Transformations**: Set matrix once, project multiple points
3. **Optimize Hot Paths**: Use faster functions in performance-critical loops
4. **Manage Precision**: Consider precision vs. speed tradeoffs
5. **Cache Calculations**: Store projected coordinates when possible

## Common Patterns

### Billboard Sprites
```r3
:draw-billboard | x y z sprite --
    >r
    rot rot rot project3d     // Project position
    r> draw-sprite-centered   // Draw sprite at projected position
    ;
```

### 3D Line Drawing
```r3
:line3d | x1 y1 z1 x2 y2 z2 --
    project3d >r >r           // Project end point
    project3d                 // Project start point  
    r> r> line                // Draw 2D line
    ;
```

### Depth-Sorted Rendering
```r3
:sort-by-depth
    | Sort objects by Z coordinate for proper rendering
    2 'objects p.sort         // Sort by Z column
    ;
```

This 3D library provides a solid foundation for 3D graphics in R3, with good performance characteristics and flexible projection options for different rendering needs.