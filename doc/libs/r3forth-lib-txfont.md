# R3Forth TxFont Library (txfont.r3)

A comprehensive text rendering library for R3Forth that provides TTF font loading, texture atlas generation, and advanced text rendering capabilities with UTF-8 support.

## Overview

This library creates optimized texture atlases from TrueType fonts and provides efficient text rendering functions. It supports **pseudo UTF-8 encoding**, including special characters and Font Awesome icons.

**Dependencies:**
- `r3/lib/sdl2gfx.r3` - SDL2 graphics functions
- `r3/lib/sdl2ttf.r3` - SDL2 TrueType font rendering

---

## Font Loading

### Basic Font Loading

- **`txload`** `( "font" size -- nfont )` - Load TTF font and create texture atlas
  - Takes font file path and size in pixels
  - Generates texture atlas with ASCII characters (32-127) and extended UTF-8
  - Returns font handle for rendering
  - Automatically handles space, tab, and newline characters
  ```
  "media/fonts/arial.ttf" 16 txload
  ```

- **`txloadwicon`** `( "font" size -- nfont )` - Load font with Font Awesome icons
  - Loads both regular font and Font Awesome icon font
  - Supports icon rendering alongside text
  - Icon font: "media/ttf/Font Awesome 7 Free-Solid-900.otf"
  - Returns font handle with icon support

---

## Font Management

### Font Selection

- **`txfont`** `( font -- )` - Set current font for rendering
  - Makes specified font active for subsequent text operations
  ```
  myfont txfont
  ```

- **`txfont@`** `( -- font )` - Get current active font
  - Returns handle to currently active font

### Font Properties

- **`txcw`** `( char -- width )` - Get character width
  - Returns pixel width of single character
  - Handles UTF-8 encoded characters

- **`txw`** `( "str" -- "str" width )` - Calculate string width
  - Measures total pixel width of string
  - Leaves string on stack for chaining
  ```
  "Hello" txw  → "Hello" 45
  ```

- **`txch`** `( char -- height )` - Get character height
  - Returns pixel height of single character

- **`txh`** `( -- height )` - Get font height
  - Returns height of current font in pixels

---

## Text Positioning

### Cursor Control

- **`txat`** `( x y -- )` - Set absolute text cursor position
  ```
  100 200 txat  | Set cursor to (100, 200)
  ```

- **`tx+at`** `( x y -- )` - Add offset to current cursor position
  ```
  10 0 tx+at  | Move cursor 10 pixels right
  ```

- **`txpos`** `( -- x y )` - Get current cursor position
  - Returns current x and y coordinates

---

## Text Rendering

### Basic Rendering

- **`txemit`** `( utf8char -- )` - Render single UTF-8 character
  - Renders at current cursor position
  - Automatically advances cursor

- **`txwrite`** `( "str" -- )` - Render string at cursor position
  - Renders entire string left-to-right
  - Updates cursor position
  ```
  "Hello World" txwrite
  ```

- **`txemitr`** `( "str" -- )` - Render string right-aligned
  - Calculates width and positions text to end at cursor
  - Useful for right-aligned text

### Formatted Output

- **`txprint`** `( .. "format" -- )` - Print formatted text
  - Similar to printf-style formatting
  - Uses sprint internally
  ```
  score "Score: %d" txprint
  ```

- **`txprintr`** `( .. "format" -- )` - Print formatted text right-aligned
  - Right-aligned version of txprint

---

## Color Control

- **`txrgb`** `( color -- )` - Set text rendering color
  - Color format: `$RRGGBB`
  - Applies to current font texture
  ```
  $FF0000 txrgb  | Set red text
  "Error!" txwrite
  ```

---

## Cursor Visualization

### Cursor Rendering

- **`txcur`** `( str cursor_pos -- )` - Draw filled cursor box
  - Shows cursor as filled rectangle
  - Position is character index in string
  ```
  mytext 5 txcur  | Draw cursor at position 5
  ```

- **`txcuri`** `( str cursor_pos -- )` - Draw insertion cursor (I-beam)
  - Shows thin vertical line cursor
  - More subtle than filled box
  - Typical text editor cursor style

---

## Advanced Text Layout

### Alignment Functions

- **`txalign`** `( alignment -- )` - Set text alignment mode
  - Format: `$VH` where V = vertical (0-2), H = horizontal (0-2)
  - Horizontal: 0=left, 1=center, 2=right
  - Vertical: 0=top, 1=center, 2=bottom
  ```
  $11 txalign  | Center both horizontally and vertically
  $02 txalign  | Top-right alignment
  ```

### Text Box Rendering

- **`txText`** `( w h x y "str" -- )` - Render multi-line text in box
  - Automatically splits text into lines
  - Applies current alignment settings
  - Handles word wrapping within specified width
  - Parameters:
    - `w` - box width
    - `h` - box height
    - `x`, `y` - top-left corner position
    - `"str"` - text to render (uses `;` or newlines as separators)
  ```
  400 200 100 100 "Line 1;Line 2;Line 3" txText
  ```

### Individual Alignment Components

- **`lwrite`** `( width "str" -- )` - Write left-aligned in box
- **`cwrite`** `( width "str" -- )` - Write center-aligned in box
- **`rwrite`** `( width "str" -- )` - Write right-aligned in box

---

## Internal Implementation Details

### Character Encoding

The library uses a **pseudo UTF-8** system that handles:
- Standard ASCII (32-127)
- Extended characters: `áéíóúñÁÉÍÓÚÜüÇç«»¿`
- Font Awesome icons (when using `txloadwicon`)

### Icon Mappings

When using `txloadwicon`, the following icons are available:
- Navigation: `◁ ▷ ▽ △` (arrows)
- UI elements: `◔ ◕` (circles)
- Actions: fold, file-open, user, image, file, camera, calendar, eye, search, check, bars, close

### Texture Atlas

- Fonts are converted to texture atlases at load time
- Each character stores: position, width, height in packed format
- Atlas size: approximately 2× font size width, 3× font size height
- Characters are rendered from texture using SDL2

---

## Memory Layout

### Font Data Structure

```
[0-7]   Texture handle (SDL_Texture*)
[8+]    Character table (256 entries × 8 bytes)
        Each entry contains:
        - X, Y position in atlas (packed)
        - Width, height (packed)
```

---

## Example Usage

### Basic Text Rendering

```r3forth
| Load font
"media/fonts/arial.ttf" 16 txload 'mainfont !

| Use the font
mainfont txfont

| Set color to white
$FFFFFF txrgb

| Position and render
100 100 txat
"Hello, World!" txwrite
```

### Formatted Text with Color

```r3forth
mainfont txfont

| Red error message
$FF0000 txrgb
50 50 txat
"Error: File not found" txwrite

| Green success message
$00FF00 txrgb
50 80 txat
count "Processed %d items" txprint
```

### Multi-line Text Box

```r3forth
mainfont txfont
$000000 txrgb

| Center-aligned text box
$11 txalign  | Center horizontally and vertically

400 300 100 50 
"Welcome to the application;
This is a multi-line message;
Click anywhere to continue" 
txText
```

### Text Editor Cursor

```r3forth
mainfont txfont
$000000 txrgb

| Draw text
100 100 txat
inputtext txwrite

| Draw cursor
$0000FF txrgb
inputtext cursorpos txcuri
```

### Icon Rendering

```r3forth
"media/fonts/arial.ttf" 20 txloadwicon 'iconfont !

iconfont txfont
$4080FF txrgb

50 50 txat
$f002 txemit  | Render search icon
" Search" txwrite
```

---

## Notes

- **Character spacing**: Automatically calculated from font metrics
- **Tab handling**: Tabs are converted to space width × 4
- **Newline handling**: Both CR and LF are recognized
- **Performance**: Texture atlas approach provides fast rendering
- **UTF-8 support**: Pseudo UTF-8 handles extended Latin characters
- **Icon fonts**: Only specific Font Awesome glyphs are loaded to save memory
- **Alignment**: Must be set before calling `txText` for proper layout
- **Color blending**: Uses SDL2 texture color modulation for efficient coloring

## Limitations

- Fixed set of UTF-8 characters (not full Unicode)
- Icon font limited to predefined glyphs
- Maximum 256 character entries in atlas
- Text wrapping in `txText` uses semicolon (`;`) as explicit line separator
