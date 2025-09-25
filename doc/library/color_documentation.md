# R3 Color Manipulation Library Documentation

## Overview

`color.r3` provides comprehensive color manipulation functions for R3, including color space conversions, blending operations, and utility functions for graphics programming. It supports multiple color spaces including RGB, HSV, YUV, YCoCg, and specialized formats for performance-critical applications.

## Dependencies
- `r3/lib/math.r3` - Mathematical operations for color calculations

## Basic Color Operations

### Color Format Utilities
```r3
swapcolor  | color -- swapped_color   // Swap red and blue channels (RGB ↔ BGR)
colavg     | a b -- average          // Average two colors
```

**Examples:**
```r3
$ff0000 swapcolor                    // Red becomes blue: $0000ff
$ff0000 $00ff00 colavg              // Returns $7f7f00 (average)
```

## Color Blending Functions

### Fast Blending (Approximate)
```r3
col50%     | c1 c2 -- blend          // 50% blend (fast approximation)
col25%     | c1 c2 -- blend          // 25% c1 + 75% c2 (fast)
col33%     | c1 c2 -- blend          // 33% blend using bit patterns
```

### Precise Blending
```r3
colmix     | c1 c2 alpha -- blend    // Precise alpha blending (0-255)
colmix4    | c1 c2 alpha -- blend    // 4-bit precision blending (0-15)
```

**Examples:**
```r3
$ff0000 $0000ff col50%              // 50% red + 50% blue = purple
$ff0000 $0000ff 128 colmix          // Precise 50% blend
$f00 $00f 8 colmix4                 // 4-bit blend (50%)
```

## Color Distance and Comparison

### Color Difference
```r3
diffrgb2   | color1 color2 -- distance  // Manhattan distance in RGB space
```

**Example:**
```r3
$ff0000 $ff8000 diffrgb2            // Distance between red and orange
```

## Color Space Conversions

### RGB ↔ YUV Conversion
YUV is useful for video processing and perceptually-based operations.

```r3
rgb2yuv    | rgb -- yuv              // RGB to YUV color space
yuv2rgb    | yuv -- rgb              // YUV to RGB color space  
yuv32      | yuv -- rgb32            // YUV to 32-bit RGB
```

**Examples:**
```r3
$ff8040 rgb2yuv                     // Convert orange to YUV
yuv2rgb                             // Convert back to RGB
```

### RGB ↔ HSV Conversion
HSV (Hue, Saturation, Value) is intuitive for color manipulation.

```r3
hsv2rgb    | h s v -- rgb32          // HSV to RGB (h: 0-$ffff, s,v: 0-1.0)
rgb2hsv    | argb -- h s v           // RGB to HSV components
```

**HSV Parameters:**
- **Hue (h)**: 0-$ffff (0-360° mapped to 16-bit)
- **Saturation (s)**: 0-1.0 (fixed-point)
- **Value (v)**: 0-1.0 (fixed-point)

**Examples:**
```r3
$8000 1.0 1.0 hsv2rgb               // Pure red (180° hue)
$ff0000 rgb2hsv                     // Get HSV components of red
```

### YCoCg Color Space
YCoCg is optimized for fast conversion and good compression properties.

```r3
rgb2ycocg  | r g b -- y co cg        // RGB components to YCoCg
ycocg2rgb  | y co cg -- r g b        // YCoCg to RGB components
rgb2ycc    | rgb32 -- y co cg        // Packed RGB to YCoCg
```

### Alternative YUV (YUV2)
Fast YUV variant with simpler calculations.

```r3
rgb2yuv2   | g b r -- y u v          // RGB to alternative YUV
yuv2rgb2   | y u v -- g b r          // Alternative YUV to RGB
```

## Specialized Color Formats

### G-Cb-Cr Format
Difference-based format for compression.

```r3
RGB>Gbr    | r g b -- g cb cr        // RGB to G + differences
Gbr>RGB    | g cb cr -- r g b        // G + differences to RGB
```

### YCoCg24 (Lifting Transform)
Advanced YCoCg with lifting for better compression.

```r3
RGB2YCoCg24| r g b -- y co cg        // RGB to YCoCg with lifting
YCoCg242RGB| y co cg -- r g b        // YCoCg with lifting to RGB
```

## Lighting and Shading

### Shadow Effects
```r3
shadow4    | color shadow -- result  // 4-bit shadow multiplication
shadow8    | color shadow -- result  // 8-bit shadow multiplication
```

### Light Effects
```r3
light4     | color light -- result   // 4-bit light addition
light8     | color light -- result   // 8-bit light addition
```

**Examples:**
```r3
$ffffff 8 shadow4                   // Darken white by factor of 8/15
$800080 4 light4                    // Brighten purple
```

## Low-Precision Color Operations

### 2-Bit Blending
```r3
blend2     | c1 c2 index -- blend   // 2-bit precision blend
```

### Color Format Conversions
```r3
b2color    | 12bit -- 24bit         // 12-bit to 24-bit color expansion
bgr2rgb    | bgr -- rgb             // BGR to RGB channel swap
4bcol      | 16bit -- 32bit         // 16-bit to 32-bit expansion
4bicol     | 16bit -- 32bit         // 16-bit to 32-bit (inverted channels)
```

## Complete Color Processing Examples

### Color Palette Generator
```r3
:generate-rainbow | steps -- 
    0 swap ( 1? 1-
        dup $ffff * over / | step hue
        1.0 1.0 hsv2rgb    | Convert to RGB
        ,                  | Store color
        swap 1+ swap
    ) drop ;

| Usage:
mark 16 generate-rainbow empty      // Generate 16 rainbow colors
```

### Color Grading System
```r3
#shadows 0.8    | Shadow multiplier
#highlights 1.2  | Highlight multiplier  
#midtones 1.0   | Midtone multiplier

:color-grade | rgb -- graded_rgb
    dup rgb2yuv                     // Convert to YUV
    rot dup 0.3 <? ( shadows *. ; ) // Dark areas
    dup 0.7 >? ( highlights *. ; )  // Bright areas  
    midtones *.                     // Midtones
    rot rot yuv2rgb ;               // Convert back

| Usage:
$804020 color-grade                 // Grade a brownish color
```

### Color Harmony Generator
```r3
:complementary | rgb -- comp_rgb
    rgb2hsv                         // Get HSV
    rot $8000 +                     // Add 180° to hue
    $ffff and                       // Wrap around
    rot rot hsv2rgb ;               // Convert back

:triadic | rgb -- rgb1 rgb2
    dup rgb2hsv                     // Original HSV
    pick2 $5555 + $ffff and rot rot hsv2rgb >r  // +120°
    $aaaa + $ffff and rot rot hsv2rgb r> ;      // +240°

| Usage:
$ff4080 complementary              // Get complement
$ff4080 triadic                    // Get triadic harmony
```

### Image Processing Functions
```r3
:desaturate | rgb -- gray
    rgb2hsv                         // Get HSV
    0 rot rot hsv2rgb ;             // Set saturation to 0

:adjust-brightness | rgb factor -- rgb'
    rgb2hsv                         // Get HSV  
    rot pick2 *. rot rot hsv2rgb ;  // Multiply value

:adjust-saturation | rgb factor -- rgb'
    rgb2hsv                         // Get HSV
    rot rot pick2 *. rot hsv2rgb ;  // Multiply saturation

| Usage:
$ff8040 desaturate                 // Convert to grayscale
$ff8040 1.5 adjust-brightness      // Make 50% brighter
$ff8040 0.5 adjust-saturation      // Half saturation
```

## Performance Characteristics

### Speed Comparison (Fastest to Slowest)
1. **col50%, col25%**: Bit manipulation, very fast
2. **YCoCg conversions**: Simple arithmetic operations  
3. **YUV conversions**: More complex but optimized
4. **colmix**: Precise blending with multiplication
5. **HSV conversions**: Complex trigonometry and conditionals

### Memory Usage
- **Temporary Variables**: Uses global variables (#vR, #vG, #vB) for HSV
- **No Dynamic Allocation**: All operations use stack or globals
- **Constant Tables**: Uses function pointer tables for efficiency

## Color Space Selection Guide

### Choose RGB for:
- Direct hardware output
- Simple color operations
- When precision is most important

### Choose HSV for:
- Color pickers and UI
- Artistic color manipulation
- Hue-based effects and filters

### Choose YUV for:
- Video processing
- Compression algorithms
- Perceptually-uniform operations

### Choose YCoCg for:
- Real-time compression
- Fast approximate operations
- When conversion speed matters

## Integration Examples

### With Graphics System
```r3
:fade-sprite | sprite alpha --
    over get-sprite-color           // Get current color
    $000000 rot colmix              // Blend with black
    swap set-sprite-color ;         // Update sprite
```

### With Animation System
```r3
:animate-color | start-color end-color t -- current-color
    256 *. int.                     // Convert to 0-255
    colmix ;                        // Blend colors

| Usage in animation:
'sprite-color $ff0000 $0000ff +vcolanim  // Animate red to blue
```

## Best Practices

1. **Choose Appropriate Precision**: Use 4-bit functions for performance, 8-bit for quality
2. **Color Space Selection**: Pick the right space for your operations
3. **Batch Operations**: Group similar color operations together
4. **Avoid Unnecessary Conversions**: Stay in one color space when possible
5. **Test Perceptual Quality**: Use YUV/HSV for perceptually-based operations

This color library provides comprehensive color manipulation capabilities for R3 graphics applications, with both high-performance approximate operations and precise color-correct functions for different use cases.