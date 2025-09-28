# R3 Text Box Rendering Library Documentation

## Overview

`boxtext.r3` provides advanced text rendering capabilities that automatically fit and wrap text within defined rectangular regions. It supports multiple text alignment options, color schemes, outline effects, and intelligent line breaking using SDL2 and SDL2_ttf for high-quality typography in R3 applications.

## Dependencies
- `r3/lib/math.r3` - Mathematical operations for layout calculations
- `r3/lib/sdl2gfx.r3` - Graphics primitives for rendering
- `r3/lib/sdl2ttf.r3` - TrueType font rendering

## Core Concepts

### Text Box System
The library automatically:
- **Word wraps** text to fit within specified boundaries
- **Splits long lines** at appropriate break points
- **Calculates optimal layout** for different alignment modes
- **Renders with anti-aliasing** using SDL2_ttf

### Coordinate Packing
Uses 64-bit packed coordinates for efficient parameter passing:
- **16 bits each** for x, y, width, height values
- **Percentage-based** sizing relative to screen dimensions

## Utility Functions

### Coordinate Packing
```r3
xywh64     | x y w h -- 64bit       // Pack coordinates into 64-bit value
xywh%64    | x y w h -- 64bit       // Pack with percentage conversion
xy%64      | x y -- 64bit           // Pack position with percentage, full size
64box      | 64bit addr --          // Unpack to memory structure
```

### Screen Percentage
```r3
w%         | -- screen_width_16.16  // Screen width as fixed-point
h%         | -- screen_height_16.16 // Screen height as fixed-point
```

**Examples:**
```r3
100 200 300 150 xywh64              // Pack absolute coordinates
10 20 50 30 xywh%64                 // Pack as percentage of screen
```

## Text Rendering Functions

### Basic Text Rendering
```r3
textbox    | alignment text box color font -- // Standard blended text
textboxb   | alignment text box colors font -- // Text with background
textboxo   | alignment text box outline_colors font -- // Outlined text
textboxh   | alignment text box color font -- height // Calculate height only
```

### Single Line Rendering
```r3
textline   | text x y color font -- // Render single line at position
```

## Alignment System

The alignment parameter uses bit flags for positioning:

### Vertical Alignment
- **Bit 0**: Middle vertical alignment
- **Bit 1**: Bottom vertical alignment
- **Default**: Top alignment

### Horizontal Alignment  
- **Bit 4**: Center horizontal alignment
- **Bit 5**: Right horizontal alignment
- **Default**: Left alignment

**Alignment Constants:**
```r3
$00     // Top-left (default)
$01     // Middle-left
$02     // Bottom-left
$10     // Top-center
$11     // Middle-center (centered)
$12     // Bottom-center
$20     // Top-right
$21     // Middle-right  
$22     // Bottom-right
```

## Color Formats

### Standard Colors
```r3
color      | $RRGGBB               // RGB color for text
```

### Background Colors (textboxb)
```r3
colors     | $RRGGBB_RRGGBB       // Text color | Background color
```

### Outline Colors (textboxo)  
```r3
outline_colors | $OOPP_RRGGBB     // Outline thickness (OO) | Padding (PP) | Text color | Outline color
```

**Examples:**
```r3
$ff0000                           // Red text
$ffffff_000000                    // White text on black background  
$02ff_ff0000_000000              // Red text, black outline, 2px thick, 2px padding
```

## Complete Usage Examples

### Simple Text Box
```r3
#my-font
#text-content "Hello World!\nThis is a test\nof text wrapping."

:setup
    "fonts/arial.ttf" 16 TTF_OpenFont 'my-font ! ;

:draw-text
    $11                           // Center alignment
    text-content                  // Text to render
    100 100 300 200 xywh64       // Box: x=100, y=100, w=300, h=200
    $000000                       // Black text
    my-font                       // Font handle
    textbox ;

setup
draw-text
```

### Multi-Style Text Display
```r3
#title-font
#body-font
#title "Game Statistics"
#stats "Score: 1500\nLevel: 5\nLives: 3\nTime: 120s"

:setup-fonts
    "fonts/arial.ttf" 24 TTF_OpenFont 'title-font !
    "fonts/arial.ttf" 14 TTF_OpenFont 'body-font ! ;

:draw-stats-panel
    | Title - centered at top
    $10 title 50 50 400 40 xywh64
    $ffffff title-font textbox
    
    | Stats - left-aligned below title
    $00 stats 50 100 400 200 xywh64
    $cccccc body-font textbox ;
```

### Styled Text with Effects
```r3
#warning-text "WARNING!\nSystem overheating detected.\nShutdown recommended."

:draw-warning
    | Outlined red text for visibility
    $11                           // Centered alignment
    warning-text                  // Warning message
    200 300 300 100 xywh64       // Center of screen
    $0404_ff0000_000000          // 4px red outline on white text
    title-font
    textboxo ;
```

### Dynamic Text Sizing
```r3
#dynamic-text "This text will be sized to fit perfectly in its container."
#calculated-height

:fit-text-to-box
    | Calculate required height
    $00 dynamic-text 100 100 300 0 xywh64
    $000000 body-font textboxh 'calculated-height !
    
    | Render with calculated height
    $01                           // Middle-left alignment
    dynamic-text
    100 100 300 calculated-height xywh64
    $000000 body-font textbox ;
```

### Responsive Text Layout
```r3
:draw-responsive-ui
    | Use percentage-based sizing
    $11                           // Centered
    "Welcome to the Game!"
    25 20 50 15 xywh%64          // 25% from left, 20% from top, 50% width, 15% height  
    $ffffff title-font textbox
    
    | Instructions below
    $10                           // Top-center
    "Use arrow keys to move\nSpace to jump\nESC to quit"
    25 40 50 30 xywh%64          // Below title
    $cccccc body-font textbox ;
```

### Game HUD with Multiple Text Elements
```r3
#player-name "Player One"
#score 15750
#health 85
#ammo 24

:draw-hud
    | Player name - top left
    $00 player-name 10 10 200 30 xywh64
    $ffffff body-font textbox
    
    | Score - top center  
    score "Score: %d" sprintf
    $10 swap sw 2/ 100 - 10 200 30 xywh64
    $ffff00 body-font textbox
    
    | Health - top right with color coding
    health dup 30 <? ( $ff0000 ; ) 70 <? ( $ffaa00 ; ) $00ff00 nip
    swap "Health: %d%%" sprintf swap
    $20 swap sw 210 - 10 200 30 xywh64
    body-font textbox
    
    | Ammo - bottom right
    $22 ammo "Ammo: %d" sprintf
    sw 210 - sh 50 - 200 30 xywh64
    $ffffff body-font textbox ;
```

## Advanced Features

### Line Breaking Algorithm
The library intelligently breaks lines at:
1. **Space characters** (preferred break points)
2. **Semicolons** (alternative break points)  
3. **Hard breaks** (CR/LF characters)
4. **Overflow points** (when words are too long)

### Memory Management
```r3
#buffer * 4096              // Text processing buffer
#lines * 512                // Line pointer array
#boxlines * 512             // Line layout information
```

The system uses fixed-size buffers for predictable memory usage.

### Performance Optimizations
- **Batch processing**: All text layout calculated before rendering
- **Texture caching**: SDL2 texture creation for smooth rendering
- **Efficient line breaking**: Single-pass text analysis
- **Packed coordinates**: Reduced parameter passing overhead

## Error Handling and Edge Cases

### Text Overflow
- **Vertical overflow**: Text continues beyond box bounds
- **Horizontal overflow**: Words break at character boundaries
- **Empty strings**: Handled gracefully without errors

### Font Issues
- **Missing fonts**: Check font loading before calling textbox functions
- **Size limits**: Very large text may exceed buffer limits
- **Character encoding**: UTF-8 support through SDL2_ttf

## Best Practices

1. **Pre-calculate Heights**: Use `textboxh` for dynamic layouts
2. **Font Management**: Load fonts once, reuse handles
3. **Buffer Sizes**: Monitor text length against buffer limits
4. **Alignment Consistency**: Use consistent alignment for visual coherence
5. **Color Accessibility**: Ensure sufficient contrast for readability

## Integration Patterns

### With Animation System
```r3
#text-alpha 255
'text-alpha 255 0 1 2.0 0 +vanim    // Fade out text over 2 seconds
text-alpha 24 << $ffffff or         // Apply alpha to color
```

### With UI System
```r3
:tooltip | "text" --
    sdlx sdly 200 100 xywh64        // Position at mouse
    $11 rot $ffff80_000000          // Yellow background tooltip
    small-font textboxb ;
```

### With Localization
```r3
#current-language 0

:get-text | key -- "text"
    current-language 
    0 =? ( drop english-texts + @ )
    1 =? ( drop spanish-texts + @ )
    drop default-text ;

"welcome" get-text textbox          // Localized text rendering
```

This text box library provides comprehensive text layout and rendering capabilities essential for creating professional-quality user interfaces and game HUDs in R3 applications.