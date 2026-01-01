# R3Forth Math Library (math.r3)

A comprehensive mathematical library for R3Forth featuring fixed-point arithmetic, trigonometric functions, and various mathematical operations.

## Overview

This library uses **48.16 fixed-point arithmetic** (48 bits integer, 16 bits fractional) for precise calculations. All angles are in **bangles** (0-1.0 represents 0-360°).

---

## Basic Operations

### Cell Operations

- **`cell+`** - Add 8 to value (cell size increment)
- **`ncell+`** - Add n cells (multiply by 8 and add)
- **`1+`** - Increment by 1
- **`1-`** - Decrement by 1
- **`2/`** - Divide by 2 (right shift)
- **`2*`** - Multiply by 2 (left shift)

---

## Fixed-Point Arithmetic (48.16)

### Basic Fixed-Point Operations

- **`*.u`** `( a b -- c )` - Unsigned fixed-point multiplication

- **`*.`** `( a b -- c )` - Signed fixed-point multiplication with proper sign handling

- **`/.`** `( a b -- c )` - Fixed-point division

- **`2/.`** - Fixed-point divide by 2 with sign adjustment

### Conversion Functions

- **`ceil`** `( a -- a )` - Round up to nearest integer
- **`int.`** - Convert fixed-point to integer (discard fractional part)
- **`fix.`** - Convert integer to fixed-point format
- **`sign`** `( v -- v s )` - Get value and its sign (-1 or 1)

---

## Trigonometric Functions

All trigonometric functions use **bangles** (0-65536 = 0-360°).

- **`cos`** `( bangle -- r )` - Cosine function
  ```
  0 cos       → 1.0 (cos(0°) = 1.0)
  1.0 cos   → 0 (cos(90°) = 0.0)
  ```

- **`sin`** `( bangle -- r )` - Sine function
  ```
  0 sin       → 0 (sin(0°) = 0.0)
  1.0 sin   → 1.0 (sin(90°) = 1.0)
  ```

- **`tan`** `( v -- f )` - Tangent function

- **`sincos`** `( bangle -- sin cos )` - Calculate both sine and cosine efficiently

- **`atan2`** `( x y -- bangle )` - Arc tangent of y/x, returns angle in bangles

---

## Polar Coordinates

- **`xy+polar`** `( x y bangle r -- x' y' )` - Add polar offset to cartesian coordinates

- **`xy+polar2`** `( x y r ang -- x' y' )` - Alternative polar addition

- **`ar>xy`** `( xc yc bangle r -- xc yc x y )` - Convert polar to cartesian, keeping center

- **`polar`** `( bangle largo -- dx dy )` - Convert polar to cartesian offset
  ```
  0 1.0 polar  → 1.0 0 (angle 0°, radius 1.0)
  ```

- **`polar2`** `( largo bangle -- dx dy )` - Polar conversion with swapped parameters

---

## Distance and Geometry

- **`distfast`** `( dx dy -- dis )` - Fast distance approximation
  - Uses formula: `max*7/8 + min/2`
  - Faster than true Euclidean distance with ~4% error

---

## Min/Max/Clamp Operations

- **`average`** `( x y -- v )` - Calculate average of two values

- **`min`** `( a b -- m )` - Return minimum value

- **`max`** `( a b -- m )` - Return maximum value

- **`clampmax`** `( v max -- v )` - Clamp value to maximum

- **`clampmin`** `( v min -- v )` - Clamp value to minimum

- **`clamp0`** `( v -- v )` - Clamp to zero (remove negative values)

- **`clamp0max`** `( v max -- v )` - Clamp between 0 and max

- **`clamps16`** `( v -- v )` - Clamp to signed 16-bit range (-32768 to 32767)

- **`between`** `( v min max -- flag )` - Check if value is between min and max

---

## Advanced Math Functions

### Square Root and Logarithms

- **`sqrt.`** `( x -- r )` - Fixed-point square root
  ```
  4.0 sqrt.  → 2.0 
  ```

- **`log2.`** `( y -- r )` - Base-2 logarithm in fixed-point

- **`ln.`** - Natural logarithm (base e)

- **`exp.`** - Exponential function (e^x)

### Power Functions

- **`pow2.`** `( y -- r )` - Calculate 2^y in fixed-point

- **`pow.`** `( x y -- r )` - Calculate x^y in fixed-point
  ```
  2.0 2.0 pow.  → 4.0 
  ```

- **`pow`** `( base exp -- r )` - Integer power function

- **`root.`** `( x n -- r )` - Calculate nth root of x

### Hyperbolic and Special Functions

- **`tanh.`** - Hyperbolic tangent

- **`fastanh.`** - Fast approximation of hyperbolic tangent (soft clipping)

- **`gamma.`** `( x -- r )` - Gamma function using Stirling's approximation

- **`beta.`** `( x y -- r )` - Beta function

- **`cubicpulse`** `( c w x -- v )` - Cubic pulse function (Iñigo Quilez)
  - Generates smooth pulse centered at `c` with width `w`

---

## Bit Manipulation

- **`msb`** - Get position of most significant bit

- **`bswap32`** `( v -- vs )` - Byte swap for 32-bit value

- **`bswap64`** `( v -- vs )` - Byte swap for 64-bit value

- **`nextpow2`** `( v -- p2 )` - Round up to next power of 2
  ```
  100 nextpow2  → 128
  ```

---

## Optimized Arithmetic

### Multiplication

- **`6*`** - Multiply by 6 (optimized)
- **`10*`** - Multiply by 10 (optimized)
- **`100*`** - Multiply by 100 (optimized)
- **`1000*`** - Multiply by 1000 (optimized)
- **`10000*`** - Multiply by 10000 (optimized)
- **`100000*`** - Multiply by 100000 (optimized)
- **`1000000*`** - Multiply by 1000000 (optimized)

### Division and Modulo

- **`6/`** - Divide by 6 (optimized using magic number)
- **`6mod`** - Modulo 6
- **`10/`** - Divide by 10 (optimized)
- **`10/mod`** `( n -- q r )` - Divide by 10 and get remainder
- **`1000000/`** - Divide by 1000000 (optimized)

---

## Floating Point Conversion

### Integer/Fixed to Float32

- **`i2fp`** `( i -- fp )` - Convert integer to IEEE 754 float32

- **`f2fp`** `( f.p -- fp )` - Convert 48.16 fixed-point to float32

- **`f2fp24`** `( f -- fp )` - Convert 40.24 fixed-point to float32

### Float32 to Integer/Fixed

- **`fp2f`** `( fp -- fixed )` - Convert float32 to 48.16 fixed-point

- **`fp2i`** `( fp -- int )` - Convert float32 to integer

- **`fp2f24`** `( fp -- fixed )` - Convert float32 to 40.24 fixed-point

- **`fp16f`** `( fp16 -- f )` - Convert half-precision float to fixed-point

### Normalized Byte Conversion

- **`byte>float32N`** `( byte -- float )` - Convert byte (0-255) to normalized float32 (0.0-1.0)

- **`float32N>byte`** `( f32 -- byte )` - Convert normalized float32 to byte (0-255)

---

## Notes

- **Fixed-point format**: 48.16 means 48 bits for integer part, 16 bits for fractional
- **Bangle unit**: 1.0 bangles = 360 degrees (1 bangle ≈ 0.0055°)
- **1.0 in fixed-point**: `1.0` or `$10000`
- Most operations preserve sign and handle edge cases properly

## Example Usage

```r3forth
| Calculate distance from origin to point (3.0, 4.0)
3.0 4.0 distfast  | (≈5.0)

| Rotate point by 45 degrees
0 0 0.25 1.0 ar>xy    | angle=45°, radius=1.0
                        | → 0 0 0.707 0.707

| Power calculation
2.0 3.0 pow.      | 2.0^3.0 → 8.0
```