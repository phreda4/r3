# R3 Math Library Documentation

## Overview

`math.r3` is a comprehensive mathematical library for R3 that provides fixed-point arithmetic, trigonometry, logarithms, floating-point conversions, and various utility functions optimized for performance-critical applications.

## Number Format Systems

### Fixed-Point Arithmetic (48.16)
The library uses 48.16 fixed-point format where:
- **48 bits** for the integer part
- **16 bits** for the fractional part
- Range: approximately ±140 trillion with 1/65536 precision

### Angle System (bangle)
- **0 to $FFFF** represents 0° to 360° (or 0 to 2π radians)
- **0.25** = **$4000** = 90° (π/2)
- **0.5** = **$8000** = 180° (π)
- **0.75** = **$C000** = 270° (3π/2)

## Basic Operations

### Memory and Size Operations
```r3
cell+     | adr -- adr+8      // Add 8 bytes (cell size)
ncell+    | adr n -- adr'     // Add n×8 bytes
1+        | n -- n+1          // Increment
1-        | n -- n-1          // Decrement  
2/        | n -- n/2          // Right shift (divide by 2)
2*        | n -- n*2          // Left shift (multiply by 2)
```

### Fixed-Point Arithmetic
```r3
*.u       | a b -- c          // Unsigned multiply (48.16)
*.        | a b -- c          // Signed multiply (48.16)
/.        | a b -- c          // Fixed-point divide
2/.       | a -- a/2          // Divide by 2 with sign correction
ceil      | a -- a            // Round up to next integer
int.      | fp -- int         // Extract integer part (>>16)
fix.      | int -- fp         // Convert integer to fixed-point (<<16)
```

**Examples:**
```r3
1.5 2.0 *.               // 1.5 × 2.0 = 3.0
10.0 3.0 /.              // 10.0 ÷ 3.0 = 3.333...
$18000 ceil              // 1.5 rounded up = 2.0
```

## Trigonometry

### Primary Functions
```r3
sin       | bangle -- r      // Sine function
cos       | bangle -- r      // Cosine function  
tan       | bangle -- r      // Tangent function
sincos    | bangle -- sin cos // Both sine and cosine
atan2     | x y -- bangle    // Arc tangent of y/x
```

### Polar Coordinate Conversion
```r3
polar     | bangle len -- dx dy           // Convert to Cartesian
polar2    | len bangle -- dx dy           // Convert to Cartesian (alt order)
ar>xy     | xc yc bangle r -- xc yc x y   // Polar offset from center
xy+polar  | x y bangle r -- x y           // Add polar offset
xy+polar2 | x y r ang -- x y              // Add polar offset (alt order)
```

**Examples:**
```r3
$4000 1.0 polar          // 90° × 1.0 = (0, 1.0)
100 200 $2000 50 xy+polar // Move (100,200) by 45° × 50
0 1.0 atan2              // atan2(0,1) = 90° = $4000
```

## Mathematical Functions

### Logarithms and Exponentials
```r3
ln.       | x -- ln(x)       // Natural logarithm (fixed-point)
log2fix   | x -- log2(x)     // Base-2 logarithm
lnfix     | x -- ln(x)       // Natural log (alternative)
log10fix  | x -- log10(x)    // Base-10 logarithm
exp.      | x -- e^x         // Exponential function
```

### Power Functions
```r3
pow       | base exp -- r    // Integer power
pow.      | base exp -- r    // Fixed-point power
root.     | base root -- r   // Nth root
sqrt.     | v -- sqrt(v)     // Square root
```

**Examples:**
```r3
2.0 ln.                  // ln(2) ≈ 0.693
$10000 log2fix           // log2(1) = 0
2.0 3.0 pow.            // 2^3 = 8.0
4.0 sqrt.               // √4 = 2.0
```

## Utility Functions

### Min/Max and Clamping
```r3
min       | a b -- min       // Minimum of two values
max       | a b -- max       // Maximum of two values
clampmax  | v max -- v       // Clamp to maximum
clampmin  | v min -- v       // Clamp to minimum  
clamp0    | v -- v           // Clamp to non-negative
clamp0max | v max -- v       // Clamp to [0, max]
clamps16  | v -- v           // Clamp to signed 16-bit range
between   | v min max -- flag // Check if value is between bounds
```

### Averaging and Distance
```r3
average   | x y -- avg       // Average of two values
distfast  | dx dy -- dist    // Fast distance approximation
```

**Examples:**
```r3
10 20 min                // min(10,20) = 10
-5 clamp0               // clamp(-5,0) = 0
100 50 200 between      // 100 between 50,200 = true
```

## Specialized Functions

### Bit Manipulation
```r3
bswap32   | v -- v_swapped   // Byte swap 32-bit
bswap64   | v -- v_swapped   // Byte swap 64-bit  
nextpow2  | v -- pow2        // Next power of 2
clzl      | v -- count       // Count leading zeros (64-bit)
```

### Fast Integer Operations
```r3
6*        | n -- n×6         // Multiply by 6
6/        | n -- n÷6         // Divide by 6
6mod      | n -- n%6         // Modulo 6
10*       | n -- n×10        // Multiply by 10
100*      | n -- n×100       // Multiply by 100
1000*     | n -- n×1000      // Multiply by 1000
10/       | n -- n÷10        // Divide by 10
10/mod    | n -- quot rem    // Divmod by 10
```

## Floating-Point Conversion

### IEEE 754 Conversion
```r3
i2fp      | int -- fp32      // Integer to float32
f2fp      | fixed -- fp32    // Fixed-point to float32
f2fp24    | f24.8 -- fp32    // 24.8 fixed to float32
fp2f      | fp32 -- fixed    // Float32 to fixed-point
fp2i      | fp32 -- int      // Float32 to integer
fp2f24    | fp32 -- f24.8    // Float32 to 24.8 fixed
fp16f     | fp16 -- fixed    // Half-float to fixed
```

### Byte/Float Conversion
```r3
byte>float32N  | byte -- fp32    // Byte to normalized float [0,1]
float32N>byte  | fp32 -- byte    // Normalized float to byte [0,255]
```

**Examples:**
```r3
100 i2fp                 // Convert 100 to float32
1.5 f2fp                // Convert 1.5 fixed to float32
255 byte>float32N       // Convert 255 to 1.0 float
0.5 float32N>byte       // Convert 0.5 to 128
```

## Specialized Mathematical Functions

### Cubic Pulse (Iñigo Quilez)
```r3
cubicpulse | c w x -- v     // Smooth pulse function
```
Creates a smooth pulse centered at `c` with width `w` at position `x`.

**Example:**
```r3
0.5 0.2 0.4 cubicpulse     // Pulse at 0.5, width 0.2, sampled at 0.4
```

### Sign Function
```r3
sign      | v -- v s        // Value and its sign (1 or -1)
```

## Complete Example: 2D Rotation System

```r3
| Rotate a point around origin
#point-x 100.0
#point-y 50.0
#rotation $0      | Current rotation angle

:rotate-point | angle --
    point-x point-y    | Get current position
    rot 0 0            | angle x y cx cy
    pick3 100.0 ar>xy  | Add polar offset with radius 100
    'point-y ! 'point-x ! ;

:setup-rotation
    0 'rotation ! ;

:update-rotation
    rotation $100 +    | Increment angle
    $ffff and 'rotation !
    
    rotation rotate-point ;

:draw-point
    point-x int. point-y int.
    5 5 fillrect ;

setup-rotation
:game-loop
    cls
    update-rotation
    draw-point
    'game-loop onkey ;
```

## Performance Characteristics

### Optimizations
- **Fixed-Point**: Avoids floating-point unit, faster on integer hardware
- **Table-Free Trig**: Uses polynomial approximation, no lookup tables
- **Fast Division**: Optimized integer division algorithms
- **Bit Operations**: Efficient bit manipulation for common operations

### Precision Trade-offs
- **16-bit Fractional**: Good precision for most applications
- **Polynomial Approximation**: Small error in trigonometric functions
- **Fast Distance**: Approximate but very fast distance calculation

## Common Usage Patterns

### Game Object Movement
```r3
:move-forward | obj --
    dup 16 + @           | Get rotation
    50.0 polar           | Convert to velocity
    pick2 @ +            | Add to x position  
    over !
    over 8 + @ +         | Add to y position
    swap 8 + ! ;
```

### Smooth Animation
```r3
:ease-in-out | t -- eased_t
    2.0 *.               | t * 2
    1.0 <=? ( dup *. 2.0 /. ; )  | t < 1: t²/2
    1.0 - dup *. -2.0 *. 1.0 + ; | else: -2(t-1)² + 1
```

### Color Blending
```r3
:blend-colors | c1 c2 t -- blended
    >r                   | Store t
    over over r@         | c1 c2 c1 c2 t
    byte>float32N *.     | c1 c2 c1×t
    -rot 1.0 r> - *.     | c1×t c2×(1-t)  
    + float32N>byte ;    | Blend and convert back
```

This math library provides a solid foundation for games, simulations, and real-time applications requiring fast mathematical operations without relying on floating-point hardware.bb