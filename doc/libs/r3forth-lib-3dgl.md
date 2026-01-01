# R3Forth 3D Graphics Library (3dgl.r3)

A comprehensive 3D matrix mathematics library for R3Forth designed for OpenGL integration, providing transformation matrices, projections, and optimized fixed-point calculations.

## Overview

This library provides:
- **4x4 transformation matrices** in fixed-point format (48.16)
- **Matrix stack** with push/pop operations (20 levels deep)
- **Projection matrices** (perspective and orthographic)
- **Transformation operations** (translate, rotate, scale)
- **View matrices** (look-at camera)
- **OpenGL interop** (float32 conversion)
- **Optimized rotations** (quaternions and Euler angles)

**Key concepts:**
- All matrices are 4x4 in column-major order
- Fixed-point format: 48.16 (1.0 = 65536 or `$10000`)
- Matrix stack allows hierarchical transformations
- Direct OpenGL float matrix export

---

## Matrix Stack Management

The library maintains a matrix stack with the current matrix at `mat>`.

### Initialization

- **`matini`** - Initialize matrix stack with identity matrix
  ```r3forth
  matini  | Reset to identity matrix
  ```

- **`matinim`** `( 'mat -- )` - Initialize with custom matrix
  ```r3forth
  'custom-matrix matinim  | Set as current matrix
  ```

### Stack Operations

- **`mpush`** - Push current matrix onto stack
  ```r3forth
  mpush
  | ... apply transformations ...
  mpop  | Restore previous matrix
  ```
  - Duplicates current matrix
  - Allows 20 levels of nesting

- **`mpushi`** - Push identity matrix onto stack
  ```r3forth
  mpushi  | Start fresh with identity
  | ... transformations ...
  mpop
  ```

- **`mpop`** - Pop matrix from stack
  ```r3forth
  mpush
  1.0 2.0 3.0 mtran  | Apply translation
  | ... render objects ...
  mpop  | Restore previous state
  ```

- **`nmpop`** `( n -- )` - Pop n matrices from stack
  ```r3forth
  3 nmpop  | Pop 3 levels at once
  ```

---

## OpenGL Float Conversion

Convert fixed-point matrices to IEEE 754 float32 for OpenGL.

### Export to Float

- **`getfmat`** `( -- fmat )` - Convert current matrix to float32
  ```r3forth
  getfmat  | Returns pointer to float matrix
  glUniformMatrix4fv  | Pass to OpenGL
  ```
  - Returns 16 float32 values (64 bytes)
  - Column-major order (OpenGL standard)

- **`gettfmat`** `( -- fmat )` - Convert and transpose
  ```r3forth
  gettfmat  | Returns transposed float matrix
  ```
  - Useful for row-major APIs

### Import from Float

- **`mcpyf`** `( fmat -- )` - Copy float matrix to current
  ```r3forth
  opengl-matrix mcpyf  | Import from OpenGL
  ```

- **`mcpyft`** `( fmat -- )` - Copy and transpose
  ```r3forth
  row-major-matrix mcpyft
  ```

- **`midf`** `( fmat -- )` - Copy float to identity matrix
  ```r3forth
  external-matrix midf
  ```

---

## Projection Matrices

### Perspective Projection

- **`mperspective`** `( near far cotang aspect -- )` - Create perspective matrix
  ```r3forth
  0.1 100.0  | near=0.1, far=100.0
  1.0        | cotangent of FOV/2 (45° ≈ 1.0)
  1.333      | aspect ratio (4:3)
  mperspective
  ```
  - Field of view: `FOV = 2 * atan(1/cotang)`
  - Standard OpenGL perspective projection
  - Near and far clipping planes

### Orthographic Projection

- **`mortho`** `( right left top bottom far near -- )` - Create orthographic matrix
  ```r3forth
  10.0 -10.0  | right, left
  10.0 -10.0  | top, bottom
  100.0 0.1   | far, near
  mortho
  ```
  - Parallel projection (no perspective)
  - Useful for 2D rendering or UI

---

## Camera/View Matrix

- **`mlookat`** `( 'eye 'target 'up -- )` - Create view matrix
  ```r3forth
  'eye-pos    | Camera position (x,y,z)
  'target-pos | Look at point (x,y,z)
  'up-vector  | Up direction (usually 0,1,0)
  mlookat
  ```
  - Creates view matrix from camera parameters
  - `'eye`, `'target`, `'up` are vec3 pointers
  - Automatically calculates right/up/forward vectors

Example:
```r3forth
#eye 0 5.0 10.0      | Camera at (0, 5, 10)
#target 0 0 0        | Looking at origin
#up 0 1.0 0          | Y-axis is up

'eye 'target 'up mlookat
```

---

## Translation

- **`mtran`** `( x y z -- )` - Translate (multiply)
  ```r3forth
  1.0 2.0 3.0 mtran  | Move by (1, 2, 3)
  ```
  - Post-multiplies translation
  - Accumulates with existing transformations

- **`mtranx`** `( x -- )` - Translate along X-axis only
  ```r3forth
  5.0 mtranx
  ```

- **`mtrany`** `( y -- )` - Translate along Y-axis only
  ```r3forth
  3.0 mtrany
  ```

- **`mtranz`** `( z -- )` - Translate along Z-axis only
  ```r3forth
  -10.0 mtranz
  ```

### Set Position (Replace)

- **`mpos`** `( x y z -- )` - Set translation directly
  ```r3forth
  10.0 5.0 0 mpos  | Set position to (10, 5, 0)
  ```
  - Replaces translation without affecting rotation/scale

- **`mtra`** `( x y z -- )` - Create translation matrix (identity + translation)
  ```r3forth
  matini
  5.0 0 0 mtra  | Pure translation matrix
  ```

---

## Rotation

### Single-Axis Rotation

- **`mrotx`** `( rx -- )` - Rotate around X-axis (pitch)
  ```r3forth
  $4000 mrotx  | 90° rotation (16384 bangles)
  ```
  - Angles in bangles (0-65536 = 0-360°)
  - Post-multiplies rotation

- **`mroty`** `( ry -- )` - Rotate around Y-axis (yaw)
  ```r3forth
  $8000 mroty  | 180° rotation
  ```

- **`mrotz`** `( rz -- )` - Rotate around Z-axis (roll)
  ```r3forth
  $2000 mrotz  | 45° rotation
  ```

### Multi-Axis Rotation

- **`mrotxyz`** `( rx ry rz -- )` - Rotate around all axes (Euler angles)
  ```r3forth
  $1000 $2000 $3000 mrotxyz  | Pitch, yaw, roll
  ```
  - Post-multiplication (applies to current matrix)
  - Order: X, then Y, then Z

- **`mrotxyzi`** `( rx ry rz -- )` - Inverse rotation (pre-multiplication)
  ```r3forth
  $1000 $2000 $3000 mrotxyzi
  ```
  - Useful for inverse transformations

- **`mrot`** `( rx ry rz -- )` - Create rotation matrix (identity + rotation)
  ```r3forth
  matini
  $4000 0 0 mrot  | Pure 90° X-rotation
  ```

### Quaternion Rotation

- **`matqua`** `( 'quat -- )` - Create rotation from quaternion
  ```r3forth
  'my-quaternion matqua
  ```
  - `'quat` points to 4 values: x, y, z, w
  - Automatically normalizes quaternion

### Combined Position and Rotation

- **`mrpos`** `( r16 x y z -- )` - Set position and packed rotation
  ```r3forth
  packed-rotation 10.0 5.0 2.0 mrpos
  ```
  - `r16` is packed rotation (see `packrota`)
  - Creates complete transformation matrix

---

## Scaling

- **`mscale`** `( x y z -- )` - Scale (post-multiply)
  ```r3forth
  2.0 2.0 2.0 mscale  | Double size
  ```
  - Non-uniform scaling supported

- **`mscalei`** `( x y z -- )` - Scale on principal axes only
  ```r3forth
  2.0 1.0 0.5 mscalei  | Stretch X, compress Z
  ```
  - Faster, affects only diagonal elements

- **`muscalei`** `( s -- )` - Uniform scale on principal axes
  ```r3forth
  1.5 muscalei  | Scale by 150%
  ```
  - Single scale factor

---

## Transformations

Apply matrix transformation to 3D points.

- **`transform`** `( x y z -- x' y' z' )` - Transform point by current matrix
  ```r3forth
  1.0 2.0 3.0 transform  | Returns transformed coordinates
  ```
  - Full 4x4 transformation
  - Includes translation

- **`transformr`** `( x y z -- x' y' z' )` - Rotate only (no translation)
  ```r3forth
  0 1.0 0 transformr  | Rotate vector
  ```
  - Ignores translation component
  - Useful for transforming directions/normals

- **`ztransform`** `( x y z -- z' )` - Get transformed Z coordinate only
  ```r3forth
  1.0 2.0 3.0 ztransform  | Returns Z depth
  ```
  - Optimized for depth calculations
  - Useful for sorting/culling

- **`oztransform`** `( -- z )` - Get origin Z after transformation
  ```r3forth
  oztransform  | Z position of (0,0,0) in current matrix
  ```

- **`oxyztransform`** `( -- x y z )` - Get origin position
  ```r3forth
  oxyztransform  | Position of (0,0,0) in current matrix
  ```
  - Returns translation component directly

---

## Matrix Operations

### Matrix Inversion

- **`matinv`** - Invert current matrix
  ```r3forth
  matinv  | Creates inverse on stack
  ```
  - Pushes inverted matrix onto stack
  - Returns 0 if matrix is singular (non-invertible)
  - Advances `mat>` by 128 bytes

### Matrix Multiplication

- **`mcpy`** `( 'mat -- )` - Copy matrix to current
  ```r3forth
  'source-matrix mcpy
  ```

- **`m*`** - Multiply two previous matrices
  ```r3forth
  mpush  | Matrix A
  mpush  | Matrix B
  m*     | Pushes A * B
  ```
  - Result pushed as new matrix

- **`mm*`** `( 'mat -- )` - Multiply current by external matrix
  ```r3forth
  'transform-matrix mm*  | current = current * 'mat
  ```
  - Post-multiplication

- **`mmi*`** `( 'mat -- )` - Multiply external by current
  ```r3forth
  'transform-matrix mmi*  | current = 'mat * current
  ```
  - Pre-multiplication

---

## Optimized Rotation Utilities

### Direct Rotation Calculation

- **`calcrot`** `( rx ry rz -- )` - Pre-calculate sin/cos for rotations
  ```r3forth
  $4000 $2000 $1000 calcrot  | Prepare rotation values
  ```
  - Stores sin/cos in internal variables
  - Used by `makerot` and `calcvrot`

- **`makerot`** `( x y z -- x' y' z' )` - Apply pre-calculated rotation
  ```r3forth
  rx ry rz calcrot  | Setup rotation
  1.0 0 0 makerot   | Rotate point
  ```
  - Faster than matrix multiplication for single points
  - Requires prior `calcrot` call

- **`calcvrot`** `( rx ry rz -- )` - Calculate rotation matrix elements
  ```r3forth
  $4000 $2000 $1000 calcvrot
  ```
  - Stores 3x3 rotation matrix in m11-m33 variables
  - Used by `mrotxyz` and `mrotxyzi`

---

## Packed Rotation Format

Compact storage for multiple rotations (space optimization).

- **`packrota`** `( rx ry rz -- rp )` - Pack 3 rotations into 48 bits
  ```r3forth
  $1000 $2000 $3000 packrota  | Returns packed value
  ```
  - Each rotation: 16 bits (full bangle range)
  - Total: 48 bits for all three axes
  - Used by `mrpos`

- **`+rota`** `( ra rb -- rr )` - Add packed rotations
  ```r3forth
  packed-rot1 packed-rot2 +rota
  ```
  - Parallel addition with overflow masking
  - Useful for rotation interpolation

### Packed Velocity (21-bit per component)

- **`pack21`** `( vx vy vz -- vp )` - Pack 3 values into 63 bits
  ```r3forth
  vel-x vel-y vel-z pack21
  ```
  - Each component: 21 bits
  - Total: 63 bits
  - Higher precision than 16-bit packing

- **`+p21`** `( va vb -- vr )` - Add packed 21-bit values
  ```r3forth
  velocity1 velocity2 +p21
  ```
  - Parallel addition with masking

---

## Usage Examples

### Basic Scene Setup
```r3forth
:setup-scene
  matini  | Start with identity
  
  | Setup perspective projection
  0.1 100.0        | Near/far
  1.0              | Cotangent of 45°
  sw sh / fix.     | Aspect ratio (width/height)
  mperspective
  
  | Setup camera
  'camera-pos 'target 'up mlookat
  ;
```

### Hierarchical Transformations
```r3forth
:draw-robot
  mpush  | Save world matrix
    | Draw torso
    0 2.0 0 mtran
    1.0 2.0 1.0 mscale
    draw-cube
    
    mpush  | Save torso matrix
      | Draw right arm
      1.5 1.0 0 mtran
      0.125 mrotz  | Rotate 45°
      0.5 1.5 0.5 mscale
      draw-cube
    mpop
    
    mpush  | Save torso matrix
      | Draw left arm
      -1.5 1.0 0 mtran
      -0.125 mrotz  | Rotate -45°
      0.5 1.5 0.5 mscale
      draw-cube
    mpop
  mpop  | Restore world matrix
  ;
```

### Camera Orbiting
```r3forth
#angle 0

:orbit-camera
  angle 1+ $FFFF and 'angle !
  
  | Calculate camera position
  angle sin 10.0 *.  | X = sin * radius
  angle cos 10.0 *.  | Z = cos * radius
  5.0                | Y = height
  
  'camera-pos v3!    | Set camera position
  'origin 'up mlookat
  ;
```

### Animation Matrix
```r3forth
#time 0

:animate-object
  time 1+ 'time !
  
  mpush
    | Rotate over time
    time $F and 11 <<  | Slow rotation
    dup dup mrotxyz
    
    | Bounce up and down
    time $100 and 8 >> 1.0 -
    0 swap 0 mtran
    
    draw-mesh
  mpop
  ;
```

### Billboard Effect
```r3forth
:draw-billboard | x y z --
  mpush
    mtran  | Move to position
    
    | Extract and invert rotation only
    matinv  | Invert transforms
    0 0 0 mpos  | Clear translation
    
    | Now faces camera
    draw-sprite
  mpop
  ;
```

### Skeletal Animation
```r3forth
#bone-matrices * 1280  | 10 bones × 128 bytes

:setup-bone | bone-id parent-id x y z rx ry rz --
  bone-id 7 << 'bone-matrices +  | Get bone matrix
  mcpy  | Start with parent matrix
  
  mtran  | Apply bone offset
  mrotxyz  | Apply bone rotation
  ;

:animate-skeleton
  | Root bone
  0 0 root-x root-y root-z
  root-rx root-ry root-rz
  setup-bone
  
  | Child bones...
  1 0 shoulder-x shoulder-y shoulder-z
  shoulder-rx shoulder-ry shoulder-rz
  setup-bone
  ;
```

### Particle System
```r3forth
#particles * 3200  | 100 particles × 32 bytes

:update-particle | 'particle --
  @+ swap  | Get position
  @+ swap  | Get velocity
  @  | Get rotation
  
  | Update rotation
  1+ $FFFF and
  
  | Apply to matrix
  packrota
  over @ over @ over @ mrpos
  
  | Update position
  velocity + position !
  ;
```

---

## Best Practices

1. **Always initialize before use**
   ```r3forth
   matini  | Start with clean identity matrix
   ```

2. **Use matrix stack for hierarchies**
   ```r3forth
   mpush
     | Child transformations
   mpop  | Restore parent
   ```

3. **Order matters for transformations**
   ```r3forth
   | Scale → Rotate → Translate (typical order)
   mscale
   mrotxyz
   mtran
   ```

4. **Cache matrices when possible**
   ```r3forth
   | Calculate once
   projection-matrix mcpy
   | Reuse many times
   ```

5. **Use appropriate precision**
   ```r3forth
   | For angles: bangles (16-bit)
   | For positions: fixed-point (48.16)
   | For OpenGL: float32 (getfmat)
   ```

6. **Pre-calculate rotations for batches**
   ```r3forth
   rx ry rz calcrot
   ( particles?
     makerot  | Fast rotation
     draw-particle
   )
   ```

---

## Performance Tips

1. **Minimize matrix operations** - Batch similar objects
2. **Use `mscalei` instead of `mscale`** when possible (2x faster)
3. **Cache view-projection matrix** - Don't recalculate per object
4. **Use `transformr` for normals** - Skip translation
5. **Pre-pack rotations** - Saves space and enables parallel ops
6. **Avoid frequent matrix inversions** - Store inverse when possible

---

## Matrix Format

Matrices are stored in **column-major order** (OpenGL standard):

```
m[0]  m[4]  m[8]   m[12]    |  Xx  Yx  Zx  Tx
m[1]  m[5]  m[9]   m[13]    |  Xy  Yy  Zy  Ty
m[2]  m[6]  m[10]  m[14]    |  Xz  Yz  Zz  Tz
m[3]  m[7]  m[11]  m[15]    |  0   0   0   1
```

Where:
- **X, Y, Z columns**: Rotation/scale basis vectors
- **T column**: Translation
- **Bottom row**: Perspective (usually 0,0,0,1)

---

## Notes

- **Fixed-point:** All values in 48.16 format (1.0 = 65536)
- **Angles:** Bangles format (0-1.0 = 0-360°)
- **Stack depth:** Maximum 20 matrices (2560 bytes)
- **Column-major:** Compatible with OpenGL
- **Thread safety:** Not thread-safe (global matrix stack)
- **Precision:** ~4 decimal places for 48.16 format
- **OpenGL compatibility:** Use `getfmat` for direct OpenGL use
- **Matrix size:** 128 bytes per matrix (16 × 8 bytes)