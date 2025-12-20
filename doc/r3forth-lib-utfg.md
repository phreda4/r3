# R3Forth UTF Graphics Library (utfg.r3)

A terminal graphics library for R3Forth providing UTF-8 box drawing, large ASCII art fonts, text alignment, and advanced text formatting using Unicode block characters.

## Overview

This library provides:
- **Large fonts** (8x8 pixel representation using UTF-8 blocks)
- **Box drawing** (lines, borders with various styles)
- **Text alignment** (left, center, right with UTF-8 support)
- **Text wrapping** and formatting in boxes
- **Two font styles** (ZX Spectrum and blocky styles)
- **Color escapes** for terminal output

---

## Large Fonts

Display ASCII characters as 4-line tall graphics using UTF-8 block characters (▀▄█).

### Font Rendering

- **`.xwrite`** `( "str" -- )` - Write string in ZX Spectrum style font
  ```r3forth
  "HELLO" .xwrite
  ```
  - Each character: 4 lines tall, 8 characters wide
  - Uses half-block characters (▀▄█)
  - Moves cursor down automatically

- **`.awrite`** `( "str" -- )` - Write string in blocky style font
  ```r3forth
  "WORLD" .awrite
  ```
  - Alternative font style
  - Same height and behavior as `.xwrite`

### Color Escapes in Large Fonts

Both `.xwrite` and `.awrite` support inline color codes:

```r3forth
"[BF]RED[30]BLUE" .xwrite
```

Format: `[BF]` where:
- **B** = Background color (hex digit 0-F)
- **F** = Foreground color (hex digit 0-F)

Colors (4-bit terminal):
- `0` = Black
- `1` = Red
- `2` = Green
- `3` = Yellow
- `4` = Blue
- `5` = Magenta
- `6` = Cyan
- `7` = White
- `8-F` = Bright variants

Example:
```r3forth
"[0F]White on Black [41]Red on Blue" .xwrite
```

---

## Box Drawing

### Single-Line Boxes

- **`.boxl`** `( x y w h -- )` - Draw single-line box
  ```r3forth
  10 5 40 10 .boxl
  ```
  - Characters: ┌─┐│└┘
  - Sharp corners
  - Standard box drawing

### Curved-Line Boxes

- **`.boxc`** `( x y w h -- )` - Draw rounded corner box
  ```r3forth
  10 5 40 10 .boxc
  ```
  - Characters: ╭─╮│╰╯
  - Rounded corners
  - Softer appearance

### Double-Line Boxes

- **`.boxd`** `( x y w h -- )` - Draw double-line box
  ```r3forth
  10 5 40 10 .boxd
  ```
  - Characters: ╔═╗║╚╝
  - Bold, prominent borders
  - Good for emphasis

### Filled Box

- **`.boxf`** `( x y w h -- )` - Draw filled box (spaces)
  ```r3forth
  10 5 40 10 .boxf
  ```
  - Fills area with spaces
  - Useful for clearing regions

---

## Lines

### Horizontal Lines

- **`.hline`** `( w -- )` - Draw horizontal single line
  ```r3forth
  20 .hline  | Draws: ────────────────────
  ```
  - Character: ─

- **`.hlined`** `( w -- )` - Draw horizontal double line
  ```r3forth
  20 .hlined  | Draws: ════════════════════
  ```
  - Character: ═

### Vertical Lines

- **`.vline`** `( h -- )` - Draw vertical single line
  ```r3forth
  10 5 .at 10 .vline
  ```
  - Character: │
  - Moves cursor down automatically

- **`.vlined`** `( h -- )` - Draw vertical double line
  ```r3forth
  10 5 .at 10 .vlined
  ```
  - Character: ║
  - Moves cursor down automatically

---

## Text Alignment

### Alignment Functions

These functions create aligned strings in temporary memory (mark/empty).

- **`lalign`** `( cnt "str" -- )` - Left align text
  ```r3forth
  20 "Hello" lalign
  here .write  | "Hello               "
  ```
  - Pads right with spaces
  - Respects UTF-8 character boundaries

- **`calign`** `( cnt "str" -- )` - Center align text
  ```r3forth
  20 "Hello" calign
  here .write  | "       Hello        "
  ```
  - Centers text in width
  - Distributes padding evenly

- **`ralign`** `( cnt "str" -- )` - Right align text
  ```r3forth
  20 "Hello" ralign
  here .write  | "               Hello"
  ```
  - Pads left with spaces

### Aligned Writing

Convenience functions that align and write in one step:

- **`lwrite`** `( w "str" -- )` - Left align and write
  ```r3forth
  1 10 .at 30 "Left aligned" lwrite
  ```

- **`cwrite`** `( w "str" -- )` - Center align and write
  ```r3forth
  1 10 .at 30 "Centered" cwrite
  ```

- **`rwrite`** `( w "str" -- )` - Right align and write
  ```r3forth
  1 10 .at 30 "Right aligned" rwrite
  ```

---

## Advanced Text Formatting

### Text in Box with Wrapping

- **`xText`** `( w h x y "str" -- )` - Display text in box with wrapping
  ```r3forth
  40 10 5 5 
  "This is a long text that will automatically wrap to fit within the specified width. Line breaks and word wrapping are handled automatically."
  xText
  ```
  
  Features:
  - Automatic word wrapping
  - Respects manual line breaks (CR/LF)
  - Aligns according to current settings
  - Clips to specified height
  - UTF-8 aware

### Alignment Configuration

- **`xalign`** `( align-code -- )` - Set horizontal and vertical alignment
  ```r3forth
  $05 xalign  | Horizontal: center, Vertical: center
  ```

  **Alignment codes (bitfield):**
  
  Bits 0-1 (Horizontal):
  - `$0` = Left align
  - `$1` = Center align
  - `$2` = Right align
  
  Bits 2-3 (Vertical):
  - `$0` = Top align
  - `$4` = Center align (vertical)
  - `$8` = Bottom align
  
  **Common combinations:**
  ```r3forth
  $00 xalign  | Top-left
  $01 xalign  | Top-center
  $02 xalign  | Top-right
  $04 xalign  | Middle-left
  $05 xalign  | Middle-center (centered both ways)
  $06 xalign  | Middle-right
  $08 xalign  | Bottom-left
  $09 xalign  | Bottom-center
  $0A xalign  | Bottom-right
  ```

- **`xwrite`** `( w "str" -- )` - Write with current alignment
  ```r3forth
  $05 xalign  | Center
  30 "Centered text" xwrite
  ```

---

## Usage Examples

### Title Banner
```r3forth
:show-title
  .cls
  1 1 .at
  .Bold .Cyan
  "MY APPLICATION" .xwrite
  .Reset
  ;
```

### Menu System
```r3forth
:draw-menu
  10 5 60 15 .boxd
  
  12 7 .at .Bold "MAIN MENU" .xwrite .Reset
  
  12 12 .at "1. New Game" .write
  12 13 .at "2. Load Game" .write
  12 14 .at "3. Options" .write
  12 15 .at "4. Exit" .write
  ;
```

### Centered Dialog
```r3forth
:show-dialog | "message" --
  $05 xalign  | Center both ways
  
  | Calculate position (center of screen)
  cols 2/ 30 -
  rows 2/ 5 -
  
  | Draw box
  2dup 60 10 .boxc
  
  | Draw text
  60 10 rot 1+ rot 1+ rot xText
  
  .flush
  waitkey
  ;

"Press any key to continue..." show-dialog
```

### Progress Bar
```r3forth
:progress-bar | percent --
  20 10 .at
  40 5 .boxl
  
  22 12 .at
  .Green
  dup 38 * 100 / "█" .rep
  .Reset
  
  22 13 .at
  38 swap "%d%%" cwrite
  
  .flush
  ;

50 progress-bar  | 50% complete
```

### Info Panel
```r3forth
:info-panel
  5 2 70 20 .boxd
  
  7 3 .at .Bold "SYSTEM INFORMATION" .xwrite .Reset
  7 8 .at 30 "CPU:" lwrite 40 .col "Intel i7" .write
  7 9 .at 30 "Memory:" lwrite 40 .col "16GB" .write
  7 10 .at 30 "OS:" lwrite 40 .col "Linux" .write
  
  7 15 .at 66 "─" .rep
  7 16 .at .Dim "Press ESC to exit" .write .Reset
  ;
```

### Formatted Text Box
```r3forth
:help-text
  $00 xalign  | Top-left
  
  10 5 60 15 .boxl
  
  60 13 12 7
  "HELP
  
This application demonstrates text formatting with automatic word wrapping. The text will flow naturally within the box boundaries.

Use arrow keys to navigate.
Press ESC to return."
  xText
  ;
```

### ASCII Art Title
```r3forth
:fancy-title
  .cls
  .home
  
  .Red
  "[F0]                    " .xwrite
  "[F0]   TETRIS GAME      " .xwrite
  "[F0]                    " .xwrite
  .Reset
  
  1 13 .at
  .Yellow "Press SPACE to start" .awrite .Reset
  
  .flush
  ;
```

### Table Layout
```r3forth
:draw-table
  5 3 .at 70 1 .boxl
  5 4 .at .Bold
  10 "NAME" lwrite
  30 "SCORE" lwrite
  50 "TIME" lwrite
  .Reset
  
  5 5 .at 70 .hlined
  
  | Rows
  6 6 .at
  10 "Player1" lwrite
  30 "1000" rwrite
  50 "10:30" rwrite
  
  6 7 .at
  10 "Player2" lwrite
  30 "850" rwrite
  50 "08:15" rwrite
  ;
```

### Multi-column Layout
```r3forth
:two-columns
  | Left column
  5 5 35 20 .boxl
  $01 xalign  | Top-center
  7 7 .at .Bold "COLUMN 1" .xwrite .Reset
  
  33 18 9 9
  "This is the content of the first column with automatic wrapping."
  xText
  
  | Right column
  45 5 35 20 .boxl
  $01 xalign
  47 7 .at .Bold "COLUMN 2" .xwrite .Reset
  
  33 18 49 9
  "This is the content of the second column."
  xText
  ;
```

---

## Best Practices

1. **Use appropriate box style**
   ```r3forth
   | Single line for normal boxes
   .boxl
   
   | Double line for emphasis
   .boxd
   
   | Curved for friendly UI
   .boxc
   ```

2. **Set alignment before xText**
   ```r3forth
   $05 xalign  | Center
   w h x y "text" xText
   ```

3. **Flush after drawing**
   ```r3forth
   draw-ui
   .flush
   ```

4. **Reset colors after use**
   ```r3forth
   .Red "Error" .xwrite
   .Reset  | Always reset
   ```

5. **Check terminal size**
   ```r3forth
   cols 80 <? ( "Terminal too small" print ; )
   ```

---

## UTF-8 Considerations

### Character Counting

The library correctly handles UTF-8:
- `lalign`, `calign`, `ralign` count **characters** not bytes
- `xText` wrapping respects UTF-8 boundaries
- Box drawing uses proper UTF-8 sequences

### Supported Characters

**Box Drawing:**
- ─ │ ┌ ┐ └ ┘ (single line)
- ═ ║ ╔ ╗ ╚ ╝ (double line)
- ─ │ ╭ ╮ ╰ ╯ (rounded)

**Block Characters:**
- ▀ (upper half block)
- ▄ (lower half block)
- █ (full block)

---

## Performance Tips

1. **Minimize .flush calls** - Draw everything then flush once
2. **Use .boxf to clear** - Faster than clearing individual lines
3. **Cache large fonts** - Don't redraw static titles every frame
4. **Batch color changes** - Set color once for multiple operations

---

## Common Patterns

### Centered Message Box
```r3forth
:msgbox | "text" --
  $05 xalign
  cols 2/ 20 - rows 2/ 3 -
  2dup 40 6 .boxc
  40 4 rot 2 + rot 2 + rot xText
  .flush waitkey
  ;
```

### Highlighted Text
```r3forth
:highlight | "text" --
  .Rever .write .Reset
  ;
```

### Border Frame
```r3forth
:frame
  0 0 cols rows .boxd
  ;
```

---

## Notes

- **Large fonts:** Take 4 terminal rows per text line
- **Alignment:** All functions are UTF-8 aware
- **Box minimum:** 3x3 characters (enforced by functions)
- **Text wrapping:** Breaks at spaces and semicolons
- **Color codes:** In format `[BF]` where B=background, F=foreground (hex)
- **Cursor movement:** Large fonts move cursor down 4 lines automatically
- **Memory:** Uses `mark`/`empty` for temporary string buffers
- **Terminal support:** Requires UTF-8 capable terminal
- **Coordinates:** 1-based (1,1 is top-left)