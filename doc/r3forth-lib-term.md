# R3Forth Terminal Library (term.r3)

A comprehensive cross-platform terminal control library for R3Forth featuring ANSI/VT escape sequences, buffered output, keyboard input, and mouse events.

## Overview

This library provides unified terminal control across Windows and Linux with support for:
- **Buffered output** (64KB) for efficient rendering
- **ANSI escape sequences** for colors and cursor control
- **Keyboard input** with special key detection
- **Mouse events** (button clicks, movement, and wheel)
- **Terminal resize detection**
- **UTF-8 support** on both platforms

---

## Key Codes

Predefined constants for special keyboard keys. These are **platform-independent** and work the same on Windows and Linux.

### Basic Keys

- **`[ESC]`** - Escape key
- **`[ENTER]`** - Enter/Return key (platform-specific internally)
- **`[BACK]`** - Backspace key
- **`[TAB]`** - Tab key
- **`[DEL]`** - Delete key
- **`[INS]`** - Insert key

### Arrow Keys

- **`[UP]`** - Up arrow
- **`[DN]`** - Down arrow
- **`[RI]`** - Right arrow
- **`[LE]`** - Left arrow

### Navigation Keys

- **`[PGUP]`** - Page Up
- **`[PGDN]`** - Page Down
- **`[HOME]`** - Home key
- **`[END]`** - End key

### Shift Combinations

- **`[SHIFT+TAB]`** - Shift + Tab
- **`[SHIFT+DEL]`** - Shift + Delete
- **`[SHIFT+INS]`** - Shift + Insert
- **`[SHIFT+UP]`** - Shift + Up arrow
- **`[SHIFT+DN]`** - Shift + Down arrow
- **`[SHIFT+RI]`** - Shift + Right arrow
- **`[SHIFT+LE]`** - Shift + Left arrow
- **`[SHIFT+PGUP]`** - Shift + Page Up
- **`[SHIFT+PGDN]`** - Shift + Page Down
- **`[SHIFT+HOME]`** - Shift + Home
- **`[SHIFT+END]`** - Shift + End

### Function Keys

- **`[F1]`** through **`[F12]`** - Function keys

### Modifier Keys

- **CTRL combinations:** `[CTRL]+A` produces `$01`, `[CTRL]+B` produces `$02`, etc.
- **ALT combinations:** `[ALT]+A` produces `$1b` followed by `A`

---

## Output Buffer System

All output is buffered in a 64KB buffer for efficient terminal rendering. The buffer automatically flushes when full.

### Buffer Management

- **`.cl`** - Clear output buffer (reset to beginning)
  ```r3forth
  .cl  | Clear buffer, start fresh
  ```

- **`.flush`** - Write buffer contents to terminal and reset
  ```r3forth
  "Hello" .type
  "World" .type
  .flush  | Display both strings
  ```
  - Automatically called when buffer is full
  - Always call before waiting for input

### Basic Output

- **`.type`** `( str cnt -- )` - Add string to output buffer
  ```r3forth
  "Hello" 5 .type  | Add "Hello" to buffer
  ```

- **`.emit`** `( char -- )` - Add single character to buffer
  ```r3forth
  65 .emit  | Add 'A' to buffer
  ```

- **`.cr`** - Add newline (carriage return + line feed)
  ```r3forth
  "Line 1" .type .cr
  "Line 2" .type .cr
  ```

- **`.sp`** - Add single space

- **`.nsp`** `( n -- )` - Add n spaces
  ```r3forth
  10 .nsp  | Add 10 spaces
  ```

- **`.nch`** `( char n -- )` - Add character n times
  ```r3forth
  45 20 .nch  | Add 20 dashes (---...)
  ```
  **Note:** Not multibyte-safe

### String Output

- **`.write`** `( "str" -- )` - Write counted string
  ```r3forth
  "Hello World" .write
  ```

- **`.print`** `( ... "format" -- )` - Format and print (uses `sprintc`)
  ```r3forth
  42 "Answer: %d" .print
  ```

- **`.println`** `( ... "format" -- )` - Format and print with newline
  ```r3forth
  3.14 "Pi: %f" .println
  ```

- **`.rep`** `( cnt "str" -- )` - Repeat string cnt times
  ```r3forth
  5 "=-" .rep  | Output "=-=-=-=-"
  ```

### Auto-flush Versions

These functions automatically flush after output:

- **`.fwrite`** `( "str" -- )` - Write and flush
- **`.fprint`** `( ... "format" -- )` - Print and flush
- **`.fprintln`** `( ... "format" -- )` - Print line and flush

---

## ANSI Escape Sequence Helpers

Low-level helpers for building ANSI escape sequences.

- **`.^[`** - Output escape sequence prefix (`ESC[`)

- **`.[w`** `( "str" -- )` - Output `ESC[` + string
  ```r3forth
  "H" .[w  | Output ESC[H (home cursor)
  ```

- **`.[p`** `( ... "format" -- )` - Output formatted escape sequence
  ```r3forth
  10 20 "%d;%dH" .[p  | Output ESC[10;20H
  ```

---

## Cursor Control

### Positioning

- **`.home`** - Move cursor to home position (1,1)
  ```r3forth
  .home  | Move to top-left corner
  ```

- **`.cls`** - Clear entire screen and move to home
  ```r3forth
  .cls  | Clear screen
  ```

- **`.at`** `( col row -- )` - Position cursor at column, row (1-based)
  ```r3forth
  10 5 .at  | Move to column 10, row 5
  ```

- **`.col`** `( col -- )` - Move cursor to column (same row)
  ```r3forth
  20 .col  | Move to column 20
  ```

### Erasing

- **`.eline`** - Erase from cursor to end of current line
- **`.ealine`** - Erase entire current line
- **`.escreen`** - Erase from cursor to end of screen
- **`.escreenup`** - Erase from cursor to beginning of screen

### Cursor Visibility

- **`.showc`** - Show cursor
- **`.hidec`** - Hide cursor
- **`.blc`** - Enable cursor blinking
- **`.unblc`** - Disable cursor blinking

### Cursor State

- **`.savec`** - Save current cursor position
  ```r3forth
  .savec
  20 10 .at "Temporary" .type
  .restorec  | Return to saved position
  ```

- **`.restorec`** - Restore saved cursor position

### Cursor Shapes

- **`.ovec`** - Default cursor shape
- **`.insc`** - Blinking vertical bar
- **`.blockc`** - Steady block
- **`.underc`** - Steady underscore

---

## Screen Buffer Control

- **`.alsb`** - Switch to alternate screen buffer
  ```r3forth
  .alsb  | Switch to alternate screen
  | ... draw interface ...
  .masb  | Return to main screen
  ```
  - Preserves main screen content
  - Useful for full-screen applications
  - Automatically flushes

- **`.masb`** - Switch back to main screen buffer
  - Automatically flushes

### Scrolling Region

- **`.scrolloff`** `( rows -- )` - Limit scrolling to rows 1 through n
  ```r3forth
  20 .scrolloff  | Enable scrolling in rows 1-20 only
  ```

- **`.scrollon`** - Reset scrolling region to full screen

---

## Colors

### Foreground Colors (Text)

**Standard colors:**
- **`.Black`** - Black text
- **`.Red`** - Red text
- **`.Green`** - Green text
- **`.Yellow`** - Yellow text
- **`.Blue`** - Blue text
- **`.Magenta`** - Magenta text
- **`.Cyan`** - Cyan text
- **`.White`** - White text

**Bright colors:**
- **`.Blackl`** - Bright black (gray)
- **`.Redl`** - Bright red
- **`.Greenl`** - Bright green
- **`.Yellowl`** - Bright yellow
- **`.Bluel`** - Bright blue
- **`.Magental`** - Bright magenta
- **`.Cyanl`** - Bright cyan
- **`.Whitel`** - Bright white

**Extended color:**
- **`.fc`** `( color -- )` - Set foreground to 256-color palette (0-255)
  ```r3forth
  196 .fc  | Bright red from extended palette
  ```

### Background Colors

**Standard backgrounds:**
- **`.BBlack`** - Black background
- **`.BRed`** - Red background
- **`.BGreen`** - Green background
- **`.BYellow`** - Yellow background
- **`.BBlue`** - Blue background
- **`.BMagenta`** - Magenta background
- **`.BCyan`** - Cyan background
- **`.BWhite`** - White background

**Bright backgrounds:**
- **`.BBlackl`** - Bright black background
- **`.BRedl`** - Bright red background
- **`.BGreenl`** - Bright green background
- **`.BYellowl`** - Bright yellow background
- **`.BBluel`** - Bright blue background
- **`.BMagental`** - Bright magenta background
- **`.BCyanl`** - Bright cyan background
- **`.BWhitel`** - Bright white background

**Extended background:**
- **`.bc`** `( color -- )` - Set background to 256-color palette (0-255)

### RGB Colors (True Color)

- **`.fgrgb`** `( r g b -- )` - Set foreground to RGB (0-255 each)
  ```r3forth
  255 128 0 .fgrgb  | Orange text
  ```

- **`.bgrgb`** `( r g b -- )` - Set background to RGB
  ```r3forth
  0 0 64 .bgrgb  | Dark blue background
  ```

---

## Text Attributes

- **`.Bold`** - Bold/bright text
- **`.Dim`** - Dim/faint text
- **`.Italic`** - Italic text
- **`.Under`** - Underlined text
- **`.Blink`** - Blinking text
- **`.Rever`** - Reverse video (swap foreground/background)
- **`.Hidden`** - Hidden text
- **`.Strike`** - Strikethrough text
- **`.Reset`** - Reset all attributes to default
  ```r3forth
  .Bold .Red "Error!" .type .Reset
  ```

---

## Terminal Information

### Global Variables

- **`rows`** - Current terminal height (number of rows)
- **`cols`** - Current terminal width (number of columns)

Example:
```r3forth
rows cols "Terminal size: %d x %d" .fprintln
```

---

## Event System

The library provides a unified event system for keyboard, mouse, and resize events.

### Event Types

- **Type 1** - Keyboard event
- **Type 2** - Mouse event
- **Type 4** - Resize event

### Event Polling

- **`inevt`** `( -- type )` - Check for event without waiting
  ```r3forth
  inevt 
  1 =? ( drop evtkey handle-key )
  2 =? ( drop handle-mouse )
  drop
  ```
  - Returns event type or 0 if no event

- **`getevt`** `( -- type )` - Wait for any event
  ```r3forth
  ( getevt
    1 =? ( drop evtkey process-key )
    2 =? ( drop process-mouse )
    4 =? ( drop handle-resize )
  ) ;
  ```
  - Blocks until event occurs

---

## Keyboard Input

- **`getch`** `( -- key )` - Wait for keypress and return key code
  ```r3forth
  getch  | Wait for key
  [ESC] =? ( "Exit" print ; )
  drop
  ```

- **`inkey`** `( -- key )` - Check for keypress without waiting
  ```r3forth
  inkey  | Returns 0 if no key pressed
  0? ( drop ; )
  process-key
  ```

- **`evtkey`** `( -- key )` - Get key code from current keyboard event
  - Use after receiving type 1 from `inevt` or `getevt`

---

## Mouse Input

### Mouse Position

- **`evtmx`** - Mouse column position (1-based)
- **`evtmy`** - Mouse row position (1-based)
- **`evtmxy`** `( -- x y )` - Get both coordinates

Example:
```r3forth
evtmxy .at "*" .type  | Draw at mouse position
```

### Mouse Buttons

- **`evtmb`** - Mouse button state (bitmask)
  - Bit 0: Left button
  - Bit 1: Right button
  - Bit 2: Middle button

```r3forth
evtmb 1 and? ( "Left button pressed" print ; )
evtmb 2 and? ( "Right button pressed" print ; )
```

### Mouse Wheel

- **`evtmw`** - Mouse wheel delta
  - Positive: wheel scrolled up
  - Negative: wheel scrolled down
  - Zero: no wheel movement

```r3forth
evtmw 
0 >? ( "Scroll up" print ; )
0 <? ( "Scroll down" print ; )
drop
```

---

## Resize Detection

- **`.onresize`** `( 'callback -- )` - Set callback for terminal resize
  ```r3forth
  :on-resize
    rows cols "New size: %d x %d" .fprintln ;
  
  'on-resize .onresize
  ```
  - Callback is executed when terminal size changes
  - Global variables `rows` and `cols` are updated before callback

---

## Simple Input Functions

- **`waitesc`** - Wait until ESC key is pressed
  ```r3forth
  "Press ESC to exit..." .fprintln
  waitesc
  .cls
  ```

- **`waitkey`** - Wait until any key is pressed
  ```r3forth
  "Press any key to continue..." .fprintln
  waitkey
  ```

---

## Cleanup and Initialization

- **`.free`** - Restore terminal to original state
  - Resets terminal modes
  - Restores mouse handling
  - Should be called before program exit

- **`.reterm`** - Reinitialize terminal modes
  - Sets up ANSI/VT support
  - Enables mouse events
  - Configures UTF-8

**Note:** The library automatically initializes on startup. Manual initialization is rarely needed.

---

## Platform Compatibility

### Cross-Platform Features (Work Identically)

All exported functions work the same on Windows and Linux:
- All key codes
- All cursor control functions
- All color functions
- All text attributes
- Buffered output system
- Event system (keyboard, mouse, resize)
- Mouse button and wheel detection

### Platform Notes

**Mouse Support:**
- Full support on both Windows and Linux
- Includes buttons, position, and wheel
- Movement tracking works on both platforms

**Resize Detection:**
- Works automatically on both platforms
- Callback system is identical

**UTF-8:**
- Fully supported on both platforms
- Automatically configured during initialization

**Key Codes:**
- All special keys use the same constants
- Platform differences handled internally
- `[ENTER]` returns same logical value (differs internally)

---

## Usage Examples

### Basic Text Output
```r3forth
.cls
.home
.Green "Success: " .type
.Reset "Operation completed" .type
.cr .flush
```

### Menu System
```r3forth
:draw-menu
  .cls
  1 1 .at .Bold "=== MENU ===" .println .Reset
  1 3 .at "1. Option One" .println
  1 4 .at "2. Option Two" .println
  1 5 .at "3. Exit" .println
  1 7 .at "Choice: " .print .flush ;

:menu
  draw-menu
  ( getch
    $31 =? ( handle-option1 )
    $32 =? ( handle-option2 )
    $33 =? ( .cls )
    drop draw-menu
    ) ;
```

### Interactive Drawing
```r3forth
#curx 40 #cury 12

:draw-ui
  .cls
  .hidec
  1 1 .at "Arrow keys to move, ESC to exit" .fprintln
  curx cury .at .Red "*" .type .Reset
  .flush ;

:handle-keys
  [UP] =? ( cury 1- 1 max 'cury ! )
  [DN] =? ( cury 1+ rows min 'cury ! )
  [LE] =? ( curx 1- 1 max 'curx ! )
  [RI] =? ( curx 1+ cols min 'curx ! )
  draw-ui ;

:main
  draw-ui
  ( getch 
    [ESC] <>?
    handle-keys ) 
  drop ;
```

### Mouse Interaction
```r3forth
:mouse-demo
  .cls
  .hidec
  1 1 .at "Click anywhere (ESC to exit)" .fprintln
  .flush
  
  ( inevt
    1 =? ( getch [ESC] =? ( 2drop .cls .showc ; ) drop )
    2 =? ( 
      evtmb 1 and? (  | Left button
        evtmxy .at .Blue "o" .type .flush
      ) drop
    )
    4 =? ( 
      .cls
      1 1 .at "Resized!" .fprintln .flush
    )
    drop
  ) ;
```

### Progress Bar
```r3forth
:progress-bar | current total --
  .savec
  over 100 * over / 10 /  | percentage / 10
  .Green 61 over .nch  | '=' chars
  .Reset 45 10 pick2 - .nch  | '-' chars
  .restorec
  3drop .flush ;

:demo-progress
  .cls
  1 5 .at "Progress: [" .type
  12 5 .at "]" .type
  0 ( 100 <=?
    12 5 .at
    dup 100 progress-bar
    1+ 50 ms
  ) drop
  .flush 1000 ms ;
```

### Color Demo
```r3forth
:color-demo
  .cls
  1 1 .at "Standard Colors:" .println
  1 2 .at .Red "Red " .Green "Green " .Blue "Blue " 
         .Yellow "Yellow " .Magenta "Magenta " .Cyan "Cyan" .println
  
  1 4 .at "Bright Colors:" .println
  1 5 .at .Redl "Red " .Greenl "Green " .Bluel "Blue "
         .Yellowl "Yellow " .Magental "Magenta " .Cyanl "Cyan" .println
  
  1 7 .at "RGB Colors:" .println
  1 8 .at 255 100 0 .fgrgb "Orange " 
         100 200 255 .fgrgb "Sky Blue " .Reset .println
  
  .flush waitkey ;
```

### Alternate Screen
```r3forth
:fullscreen-app
  .alsb  | Switch to alternate screen
  .cls
  .hidec
  
  | ... application code ...
  20 12 .at "Press any key to exit" .fprintln
  .flush
  waitkey
  
  .showc
  .masb  | Return to main screen
  ;
```

---

## Best Practices

1. **Always flush before waiting for input**
   ```r3forth
   "Prompt: " .type .flush
   getch
   ```

2. **Use buffered output for efficiency**
   ```r3forth
   | Bad: multiple flushes
   "Line 1" .fprint
   "Line 2" .fprint
   
   | Good: single flush
   "Line 1" .println
   "Line 2" .println
   .flush
   ```

3. **Hide cursor during animations**
   ```r3forth
   .hidec
   | ... animation ...
   .showc
   ```

4. **Use alternate screen for full-screen apps**
   ```r3forth
   .alsb
   | ... application ...
   .masb
   ```

5. **Reset attributes after colored output**
   ```r3forth
   .Red "Error" .type .Reset
   ```

6. **Check event types before accessing data**
   ```r3forth
   inevt
   2 =? ( evtmxy process-mouse )
   drop
   ```

7. **Call `.free` before exit**
   ```r3forth
   :main
     | ... program ...
     .free
     0 exit ;
   ```

---

## Performance Tips

1. **Minimize `.flush` calls** - Buffer multiple outputs
2. **Use `.nch` for repeated characters** instead of loops
3. **Group cursor movements** with content output
4. **Avoid unnecessary `.at` calls** - use relative positioning when possible
5. **Cache color settings** - don't repeatedly set the same color
6. **Use `.savec`/`.restorec`** instead of tracking positions manually

---

## Common Patterns

### Status Line
```r3forth
:status-line | "text" --
  .savec
  1 rows .at
  .Rever .type .Reset
  .restorec
  .flush ;

"Ready" status-line
```

### Centered Text
```r3forth
:center | "text" row --
  .at
  dup count cols swap - 2/ swap .type
  .flush ;

"Title" 1 center
```

### Box Drawing
```r3forth
:box | x y w h --
  | ... draw box using .at and .nch ...
  ;

10 5 30 10 box
```

---

## Notes

- **Buffer size:** 64KB (automatically managed)
- **Coordinate system:** 1-based (1,1 is top-left)
- **UTF-8:** Fully supported on both platforms
- **Thread safety:** Not thread-safe
- **Terminal size:** Updated automatically on resize
- **Mouse coordinates:** Match terminal grid (1-based)
- **Color support:** Requires ANSI-compatible terminal