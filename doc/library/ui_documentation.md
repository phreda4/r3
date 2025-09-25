# R3 User Interface Library Documentation

## Overview

`ui.r3` is a comprehensive user interface library built on top of the immediate mode GUI system (`gui.r3`). It provides a complete set of styled widgets including buttons, inputs, lists, sliders, and complex controls with built-in theming, focus management, and responsive layout capabilities.

## Dependencies
- `r3/lib/gui.r3` - Immediate mode GUI foundation
- `r3/lib/sdl2gfx.r3` - Graphics primitives for UI rendering
- `r3/util/txfont.r3` - Font rendering system

## Theme System

### Color Scheme Variables
```r3
#cifil      // Fill colors (over|normal) - main widget backgrounds
#cisel      // Selection colors (over|normal) - selected states  
#cifnt      // Font color - text rendering
#cifoc      // Focus color - keyboard focus indicator
```

### Built-in Themes
```r3
stDang      // Danger theme (red tones)
stWarn      // Warning theme (yellow/orange)
stSucc      // Success theme (green tones)
stInfo      // Info theme (blue tones)
stLink      // Link theme (blue/purple)
stDark      // Dark theme
stLigt      // Light theme
```

### Font Color Themes
```r3
stFDang     // Danger text colors
stFWarn     // Warning text colors
stFSucc     // Success text colors
stFInfo     // Info text colors
stFLink     // Link text colors
stFDark     // Dark text colors
stFWhit     // White text colors
```

**Example:**
```r3
stDang                              // Set danger theme
"Delete File" uiBtn                 // Red-themed button
```

## Layout System

### Window Management
```r3
uiWin!      | x y w h --            // Set main window bounds
uiWinFit!   | x y w h --            // Set window, fit to screen
uiWin@      | -- x y w h            // Get current window bounds
uiWinBox!   | x1 y1 x2 y2 --        // Set window by corners
```

### Layout Flow
```r3
uiH         | --                    // Set horizontal flow
uiV         | --                    // Set vertical flow
ui..        | --                    // Advance to next position
uicr        | --                    // Carriage return (new line)
uidn        | --                    // Move down one row
uiri        | --                    // Move right to next column
ui<         | --                    // Move left one widget
ui>>        | --                    // Move to right edge
```

### Positioning and Sizing
```r3
uiZone!     | x y w h --            // Set current widget zone
uiZone      | --                    // Apply zone as GUI region
uiZone@     | -- x y w h            // Get current zone dimensions
uiPad       | padx pady --          // Set padding values
```

### Grid System
```r3
uiGrid      | cols rows --          // Setup grid layout
uiGridA     | cols rows --          // Setup grid with auto-adjustment
uiGAt       | col row --            // Position at grid cell
uiGTo       | width height --       // Span multiple grid cells
```

**Example:**
```r3
4 3 uiGrid                          // 4x3 grid
0 0 uiGAt "Top Left" uiBtn         // Button at (0,0)
2 1 uiGAt 2 1 uiGTo "Wide" uiBtn   // 2-wide button at (2,1)
```

## Text Rendering

### Text Alignment
```r3
ttemitl     | "text" --             // Left-aligned text
ttemitc     | "text" --             // Center-aligned text  
ttemitr     | "text" --             // Right-aligned text
```

### Labels
```r3
uiLabel     | "text" --             // Left-aligned label
uiLabelc    | "text" --             // Center-aligned label
uiLabelr    | "text" --             // Right-aligned label
uiLabelMini | "text" --             // Compact label
uiTlabel    | "text" --             // Tight label (no advance)
```

## Button Controls

### Basic Buttons
```r3
uiBtn       | 'callback "text" --  // Standard rectangular button
uiRBtn      | 'callback "text" --  // Rounded rectangle button
uiCBtn      | 'callback "text" --  // Circular/pill button
uiTBtn      | 'callback "text" --  // Text-sized button
```

**Example:**
```r3
:on-save-click
    "File saved!" print ;

'on-save-click "Save File" uiBtn
```

## Input Controls

### Selection Controls
```r3
uiCheck     | 'var 'list --         // Checkbox group (bitmask)
uiRadio     | 'var 'list --         // Radio button group
uiTab       | 'var 'list --         // Tab selector
```

**Example:**
```r3
#options $7                         // Binary: 111 (first 3 selected)
#selected-option 1
#current-tab 0

'options "Option A" $0d "Option B" $0d "Option C" 0 uiCheck
'selected-option "Red" $0d "Green" $0d "Blue" 0 uiRadio  
'current-tab "Home" $0d "Settings" $0d "Help" 0 uiTab
```

### Text Input
```r3
uiInputLine | 'buffer maxlen --    // Single-line text input
uiText      | 'buffer --           // Multi-line text area
uiEdit      | 'buffer --           // Rich text editor
```

**Example:**
```r3
#username * 32
#password * 32

'username 31 uiInputLine           // Username field
'password 31 uiInputLine           // Password field
```

## Sliders and Progress Bars

### Horizontal Sliders
```r3
uiSliderf   | min max 'var --      // Float slider
uiSlideri   | min max 'var --      // Integer slider  
uiSlideri8  | min max 'var --      // 8-bit integer slider
```

### Vertical Sliders
```r3
uiVSliderf  | min max 'var --      // Vertical float slider
uiVSlideri  | min max 'var --      // Vertical integer slider
uiVSlideri8 | min max 'var --      // Vertical 8-bit slider
```

### Progress Bars
```r3
uiProgressf | min max 'var --      // Float progress bar
uiProgressi | min max 'var --      // Integer progress bar
uiVProgressf| min max 'var --      // Vertical float progress
uiVProgressi| min max 'var --      // Vertical integer progress
```

**Example:**
```r3
#volume 0.7
#brightness 128
#progress 0.3

0.0 1.0 'volume uiSliderf          // Volume: 0-100%
0 255 'brightness uiSlideri        // Brightness: 0-255
0.0 1.0 'progress uiProgressf      // Progress: 0-100%
```

## List Controls

### Basic Lists
```r3
uiList      | 'var lines 'data --  // Scrollable list
uiListV     | 'var lines 'data --  // Virtual list (large datasets)
uiCombo     | 'var 'data --        // Dropdown combo box
```

### Tree Control
```r3
uiTree      | 'var lines 'data --  // Hierarchical tree view
```

**List Data Format:**
```r3
#file-list "file1.txt" 0 "file2.txt" 0 "folder/" 0 0
#selected-file 0

'selected-file 5 'file-list uiList  // 5 visible lines
```

## Drawing Utilities

### Shape Drawing
```r3
uiRect      // Draw rectangle outline (current zone)
uiFill      // Fill rectangle (current zone)
uiRRect     // Draw rounded rectangle
uiRFill     // Fill rounded rectangle
uiCRect     // Draw circular/pill shape
uiCFill     // Fill circular/pill shape
```

### Window-based Drawing
```r3
uiRectW     // Rectangle outline (window bounds)
uiFillW     // Fill rectangle (window bounds)  
uiRRectW    // Rounded rectangle (window)
uiRFillW    // Fill rounded rectangle (window)
```

### Lines and Grids
```r3
uiLineH     // Horizontal line
uiLineV     // Vertical line
uiLineWH    // Full-width horizontal line
uiGrid#     // Draw grid pattern
```

## Advanced Features

### Stack-based State Management
```r3
uiPush      // Save current position/size
uiPop       // Restore position/size
uiPushA     // Save position/size + window
uiPopA      // Restore position/size + window
```

### Focus and Interaction
```r3
uiExitWidget    // Force exit current widget
refreshfoco     // Reset focus system
clickfoco       // Set focus to current element
nextfoco        // Move to next focusable element
prevfoco        // Move to previous focusable element
```

## Complete Application Examples

### Settings Panel
```r3
#show-settings 1
#volume 0.8
#brightness 180
#vsync 1
#difficulty 1
#resolution 2

:settings-panel
    uiStart
    stDark                          // Dark theme
    
    100 100 400 500 uiWinFit!
    8 8 uiPad                       // 8px padding
    
    "Settings" uiTitle
    uiLineWH
    
    "Audio" uiLabel
    0.0 1.0 'volume uiSliderf
    volume .f2 " Volume" swap + uiLabelr
    
    ui..
    "Graphics" uiLabel  
    0 255 'brightness uiSlideri
    brightness .d " Brightness" swap + uiLabelr
    
    'vsync "Enable VSync" 0 uiCheck
    
    ui..
    "Gameplay" uiLabel
    'difficulty "Easy" $0d "Normal" $0d "Hard" 0 uiRadio
    
    ui..
    :close-settings 0 'show-settings ! ;
    'close-settings "Close" uiBtn
    
    uiEnd ;

:main-loop
    cls
    show-settings ? ( settings-panel )
    SDLredraw ;
```

### File Browser
```r3
#current-dir "/"
#selected-file 0
#file-list * 2048

:refresh-files
    | Populate file-list with directory contents
    current-dir load-directory-contents
    'file-list strcpy ;

:on-file-select
    selected-file get-filename
    dup is-directory? 
    ? ( 'current-dir strcpy refresh-files )
    ( "Selected: " print print ) ;

:file-browser
    uiStart
    stLigt
    
    50 50 600 400 uiWinFit!
    4 4 uiPad
    
    current-dir uiLabel
    uiLineWH
    
    'selected-file 15 'file-list uiList
    'on-file-select onClick
    
    uiEnd ;
```

### Color Picker
```r3
#picked-color $ff8040
#red-component 255
#green-component 128  
#blue-component 64

:update-color
    red-component 16 << green-component 8 << or blue-component or
    'picked-color ! ;

:color-picker
    uiStart
    
    200 200 300 200 uiWinFit!
    6 6 uiPad
    
    "Color Picker" uiTitle
    
    "Red" uiLabel
    0 255 'red-component uiSlideri8
    update-color
    
    "Green" uiLabel  
    0 255 'green-component uiSlideri8
    update-color
    
    "Blue" uiLabel
    0 255 'blue-component uiSlideri8  
    update-color
    
    | Preview
    picked-color SDLcolor uiFill
    
    uiEnd ;
```

## Performance Considerations

### Rendering Optimization
- **Batch Drawing**: Group similar UI elements together
- **Selective Updates**: Only redraw changed regions when possible
- **Font Caching**: Reuse rendered text textures
- **Theme Consistency**: Minimize color/style changes

### Memory Management
- **Static Buffers**: Use fixed-size buffers for text inputs
- **List Virtualization**: Use uiListV for large datasets
- **Widget Recycling**: Reuse widget structures when possible

### Focus Management
- **Tab Order**: Arrange widgets in logical tab sequence
- **Focus Indicators**: Provide clear visual focus feedback
- **Keyboard Navigation**: Support arrow keys for list navigation

## Best Practices

1. **Theme Consistency**: Choose one theme per screen/dialog
2. **Layout Planning**: Use grid system for complex layouts  
3. **User Feedback**: Provide visual feedback for all interactions
4. **Accessibility**: Support keyboard navigation throughout
5. **State Management**: Keep UI state synchronized with application data
6. **Error Handling**: Validate input data and provide feedback

## Integration Patterns

### With Animation System
```r3
#button-color $ffffff
'button-color $ff8080 $ffffff 1 1.0 0 +vcolanim  // Animate button color
```

### With File System
```r3
:load-config
    "config.ui" fload 
    | Parse and apply UI settings
    ;
```

This comprehensive UI library provides all the tools needed to create professional, responsive user interfaces in R3 applications with consistent theming, proper focus management, and efficient rendering.