# R3Forth Color Library (color.r3)

A comprehensive color manipulation library for R3Forth providing color space conversions, blending operations, and various color utilities for graphics programming.

## Overview

This library provides fast color operations using bit manipulation and fixed-point arithmetic. All RGB colors use 32-bit format: `$AARRGGBB` (alpha optional, often `$00RRGGBB`).

**Dependencies:**
- `r3/lib/math.r3` - Fixed-point math operations

**Color Format:**
- Standard: `$RRGGBB` (24-bit RGB)
- With alpha: `$AARRGGBB` (32-bit ARGB)
- Components: 8 bits each (0-255)

---

## Basic Color Operations

### Color Component Manipulation

- **`swapcolor`** `( color -- swapcolor )` - Swap red and blue channels
  - Converts RGB ↔ BGR
  - Useful for format conversions
  ```
  $ff0000 swapcolor  | $0000ff (red → blue)
  ```

- **`bgr2rgb`** `( BGR -- RGB )` - Convert BGR to RGB format
  - Alias for color channel reordering
  - Preserves green channel
  ```
  $0000ff bgr2rgb  | $ff0000
  ```

---

## Color Averaging and Blending

### Fast Averaging

- **`colavg`** `( a b -- c )` - Fast average of two colors
  - Averages each channel independently
  - Uses bit tricks for speed
  - Result: (a + b) / 2
  ```
  $ff0000 $0000ff colavg  | $7f007f (purple)
  ```

- **`col50%`** `( c1 c2 -- c )` - 50/50 blend of colors
  - Similar to colavg but slightly different algorithm
  - Averages each channel: (c1 + c2) / 2

- **`col25%`** `( c1 c2 -- c )` - 25/75 blend of colors
  - Result: c1 × 0.25 + c2 × 0.75
  - Useful for subtle color tints

- **`col33%`** `( c1 c2 -- c )` - 33/66 blend approximation
  - Fast approximate 1:2 blend
  - Uses bit masking for speed

### Precise Color Mixing

- **`colmix`** `( c1 c2 alpha -- c )` - Linear interpolation between colors
  - `alpha`: 0-255 (0 = c1, 255 = c2)
  - Result: c1 × (1 - α) + c2 × α
  - Smooth transitions between colors
  ```
  $ff0000 $0000ff 128 colmix  | $7f007f (halfway blend)
  $ff0000 $0000ff 64 colmix   | $bf003f (75% red, 25% blue)
  ```

- **`colmix4`** `( c1 c2 alpha -- c )` - 4-bit precision color mix
  - `alpha`: 0-15 (4-bit)
  - Faster but less precise than colmix
  - Good for performance-critical code

---

## Color Difference

- **`diffrgb2`** `( a b -- diff )` - Calculate color difference
  - Returns Manhattan distance in RGB space
  - Result: |R₁-R₂| + |G₁-G₂| + |B₁-B₂|
  - Range: 0 (identical) to 765 (opposite)
  ```
  $ffffff $000000 diffrgb2  | 765 (maximum difference)
  $ff0000 $fe0000 diffrgb2  | 1 (minimal difference)
  ```

---

## Color Space Conversions

### RGB ↔ YUV

YUV color space separates luminance (Y) from chrominance (U, V).

- **`rgb2yuv`** `( r g b -- y u v )` - Convert RGB to YUV
  - Y: luminance (0-255)
  - U, V: chrominance (-128 to 127, stored as 0-255)
  ```
  255 0 0 rgb2yuv  | Red in YUV space
  ```

- **`yuv2rgb`** `( y u v -- r g b )` - Convert YUV to RGB
  - Inverse transformation
  - Clamps results to valid RGB range

- **`yuv32`** `( y u v -- color )` - YUV to packed RGB32
  - Direct conversion to 32-bit color
  - More efficient than yuv2rgb when color needed

### RGB ↔ YUV2 (Alternative)

Alternative YUV formulation: Y = G + (B+R-2G)/4, U = B-G, V = R-G

- **`rgb2yuv2`** `( g b r -- y u v )` - Convert to YUV2
  - Different component order (GBR input)
  - Simpler calculation, faster

- **`yuv2rgb2`** `( y u v -- g b r )` - Convert from YUV2
  - Returns GBR order

### RGB ↔ HSV

HSV (Hue, Saturation, Value) is intuitive for color manipulation.

- **`hsv2rgb`** `( h s v -- rgb32 )` - Convert HSV to RGB
  - `h`: hue (0.0-1.0 in fixed-point, 0.0=red, 0.333=green, 0.666=blue)
  - `s`: saturation (0.0-1.0, 0=gray, 1=full color)
  - `v`: value/brightness (0.0-1.0, 0=black, 1=full)
  - Returns packed 32-bit RGB
  ```
  0.0 1.0 1.0 hsv2rgb    | $ff0000 (pure red)
  0.333 1.0 1.0 hsv2rgb  | $00ff00 (pure green)
  0.0 0.0 0.5 hsv2rgb    | $7f7f7f (gray)
  ```

- **`rgb2hsv`** `( argb -- h s v )` - Convert RGB to HSV
  - Input: 32-bit RGB color
  - Returns: hue, saturation, value (all fixed-point 0.0-1.0)
  ```
  $ff0000 rgb2hsv  | 0.0 1.0 1.0 (red)
  $7f7f7f rgb2hsv  | h 0.0 0.5 (gray - any hue, no saturation)
  ```

### RGB ↔ YCoCg

YCoCg (Luma-Orange-Green) is optimized for fast conversion.

- **`rgb2ycocg`** `( r g b -- y co cg )` - Convert RGB to YCoCg
  - Very fast conversion
  - Y: luma
  - Co: orange (R-B)
  - Cg: green component

- **`ycocg2rgb`** `( y co cg -- r g b )` - Convert YCoCg to RGB
  - Fast inverse transformation

- **`rgb2ycc`** `( RGB -- y co cg )` - Packed RGB to YCoCg
  - Unpacks 32-bit color and converts to YCoCg

### RGB ↔ YCoCg24

24-bit optimized YCoCg with forward/reverse lifting.

- **`RGB2YCoCg24`** `( r g b -- Y co cg )` - RGB to YCoCg24
  - Uses lifting scheme for reversibility
  - All components 0-255

- **`YCoCg242RGB`** `( Y co cg -- r g b )` - YCoCg24 to RGB
  - Perfect reconstruction

### RGB ↔ GCbCr

Color difference format with Green as base.

- **`RGB>Gbr`** `( R G B -- G b r )` - RGB to GCbCr
  - b = B - G
  - r = R - G
  - Preserves green channel

- **`Gbr>RGB`** `( G b r -- R G B )` - GCbCr to RGB
  - Reconstructs original RGB

---

## Shadow and Light Effects

### 4-bit Shadow/Light

- **`shadow4`** `( color shadow -- color )` - Apply shadow with 4-bit precision
  - `shadow`: 0-15 (0=black, 15=original)
  - Fast darkening effect
  ```
  $ffffff 8 shadow4  | $777777 (half brightness)
  $ff0000 4 shadow4  | $440000 (dark red)
  ```

- **`light4`** `( color light -- color )` - Apply light with 4-bit precision
  - `light`: 0-15 (0=original, 15=brightest)
  - Fast lightening effect
  ```
  $7f0000 8 light4   | Lighter red
  ```

### 8-bit Shadow/Light

- **`shadow8`** `( color shadow -- color )` - Apply shadow with 8-bit precision
  - `shadow`: 0-255 (0=black, 255=original)
  - More precise than shadow4
  ```
  $ffffff 128 shadow8  | $7f7f7f (half brightness)
  ```

- **`light8`** `( color light -- color )` - Apply light with 8-bit precision
  - `light`: 0-255 (0=original, 255=add 255 to each channel)
  - Clamps to prevent overflow

---

## Special Blending

- **`blend2`** `( c1 c2 i -- c )` - Blend colors with 2-bit weight
  - `i`: 0-3 (shift amount)
  - Fast approximate blending
  ```
  $ff0000 $0000ff 1 blend2  | Blend with shift
  ```

---

## Compact Color Formats

### 12-bit Color (4 bits per channel)

- **`b2color`** `( col -- color )` - Expand 12-bit to 24-bit
  - Input: $RGB (4 bits each)
  - Output: $RRGGBB (8 bits each)
  - Duplicates high nibble to low nibble
  ```
  $f00 b2color  | $ff0000 (red)
  $0f0 b2color  | $00ff00 (green)
  $369 b2color  | $336699 (blue-gray)
  ```

### 16-bit Color (4 bits per channel + alpha)

- **`4bcol`** `( col -- color )` - Expand 16-bit ARGB to 32-bit
  - Input: $ARGB (4 bits each)
  - Output: $AARRGGBB (8 bits each)
  ```
  $f00f 4bcol  | $ff0000ff (opaque blue)
  ```

- **`4bicol`** `( col -- color )` - Inverted 16-bit expansion
  - Different component ordering
  - Useful for specific file formats

---

## Complete Examples

### Color Fading

```r3forth
#currentColor $ff0000
#targetColor $0000ff
#fadeAmount 0

:updateFade
    fadeAmount 1 + 255 clampmax 'fadeAmount !
    currentColor targetColor fadeAmount colmix
    'currentColor ! ;

:drawFaded
    currentColor SDLColor
    100 100 200 200 SDLFRect ;
```

### HSV Color Wheel

```r3forth
:drawColorWheel
    0 ( 360 <?
        dup 360 */ 1.0 1.0 hsv2rgb  | Convert hue to RGB
        SDLColor
        | Draw segment
        dup 10 * 200 + 200 20 20 SDLFRect
        1+
    ) drop ;
```

### Shadow Effect

```r3forth
#baseColor $ff4444

:drawWithShadow
    | Draw shadow (darker)
    baseColor 128 shadow8 SDLColor
    102 102 100 100 SDLFRect
    
    | Draw main object
    baseColor SDLColor
    100 100 100 100 SDLFRect ;
```

### Smooth Color Transition

```r3forth
#phase 0

:animateColor
    phase 1 + 1.0 and 'phase !
    
    | Animate through rainbow
    phase 1.0 1.0 hsv2rgb
    SDLColor
    
    sw 2/ sh 2/ 100 SDLCircle ;
```

### YUV Color Adjustment

```r3forth
:adjustBrightness | color amount -- color
    >r
    dup 16 >> $ff and
    over 8 >> $ff and
    rot $ff and
    rgb2yuv          | y u v
    
    rot r> + 255 clampmin clamp0max  | Adjust Y
    rot rot
    yuv32 ;          | Back to RGB

$7f7f7f 50 adjustBrightness  | Brighten gray
```


### Luminance Calculation

```r3forth
:getLuminance | rgb -- brightness
    dup 16 >> $ff and
    over 8 >> $ff and
    rot $ff and
    rgb2yuv drop drop ;  | Return Y component

$ff0000 getLuminance  | Red luminance
$00ff00 getLuminance  | Green luminance (brighter)
```

---

## Color Space Use Cases

| Color Space | Best For |
|-------------|----------|
| RGB | Display, direct rendering |
| YUV/YUV2 | Brightness adjustment, compression |
| HSV | Color picking, hue rotation, saturation |
| YCoCg | Fast lossless conversion |
| YCoCg24 | 24-bit perfect reconstruction |
| GCbCr | Color difference coding |

---

## Performance Notes

- **Bit operations**: Most functions use bitwise ops for speed
- **colmix vs colmix4**: colmix4 is faster but less smooth
- **YCoCg**: Fastest color space conversion
- **HSV**: Slowest but most intuitive for manipulation
- **Shadow/Light 4-bit**: Faster than 8-bit versions
- **Fast averaging**: colavg, col50% faster than colmix

---

## Best Practices

### 1. Choose Right Blend Function

```r3forth
| Fixed 50/50 blend - fastest
color1 color2 col50%

| Need specific ratio - use colmix
color1 color2 192 colmix  | 75% color2

| Performance critical - use colmix4
color1 color2 12 colmix4  | 75% in 4-bit
```

### 2. Color Space Selection

```r3forth
| Adjusting brightness - use YUV
color rgb2yuv
rot 50 + 255 clampmax -rot
yuv32

| Rotating hue - use HSV
color rgb2hsv
rot 0.2 + 1.0 and -rot
hsv2rgb

| Desaturating - use HSV
color rgb2hsv
swap 0.5 * swap  | Half saturation
hsv2rgb
```

### 3. Compact Colors for Memory

```r3forth
| Store palette as 12-bit
#palette [ $f00 $0f0 $00f $fff ... ]

| Expand when needed
'palette i + d@ b2color
```

---

## Common Color Operations

### Grayscale Conversion

```r3forth
:toGrayscale | rgb -- gray
    rgb2yuv drop drop  | Get Y (luminance)
    dup 8 << dup 8 << or or ;  | Replicate to RGB
```

### Invert Color

```r3forth
:invertColor | rgb -- inverted
    $ffffff xor ;
```

### Lighten/Darken

```r3forth
:lighten | color -- lighter
    255 light8 ;

:darken | color -- darker  
    128 shadow8 ;
```

### Desaturate

```r3forth
:desaturate | rgb amount -- rgb
    >r rgb2hsv
    swap r> * 1.0 clampmin swap
    hsv2rgb ;
```

### Color Temperature

```r3forth
:warmColor | rgb -- warmer
    rgb2hsv
    rot 0.05 + 1.0 and -rot  | Shift toward red
    hsv2rgb ;

:coolColor | rgb -- cooler
    rgb2hsv
    rot 0.05 - 1.0 and -rot  | Shift toward blue
    hsv2rgb ;
```

---

## Notes

- **Alpha channel**: Most functions ignore/preserve alpha in 32-bit colors
- **Clamping**: YUV conversions include automatic clamping to 0-255
- **Fixed-point**: HSV uses 48.16 fixed-point (1.0 = $10000)
- **Precision**: 8-bit functions more accurate than 4-bit versions
- **Overflow**: Light functions clamp to prevent overflow
- **Performance**: Bit operations make most functions very fast
- **Color matching**: Use diffrgb2 with threshold for fuzzy matching

## Limitations

- No gamma correction built-in
- HSV hue wraps at 1.0 (must handle manually)
- Shadow/light functions don't preserve hue perfectly
- Some color space conversions may have small rounding errors
- 4-bit functions trade precision for speed

