# R3Forth Terminal Library (console.r3)

A comprehensive cross-platform terminal control library for R3Forth featuring ANSI/VT escape sequences, buffered output, keyboard input, and mouse events.

## Overview

This library provides unified terminal control across Windows and Linux with support for:
- **Buffered output** (about 8 KB) for efficient rendering
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

All output is buffered in an 8 KB buffer for efficient terminal rendering. The buffer is flushed automatically when it is full, and by `.flush`, `.println`, `getch` (and so `waitkey`, `.input`).

### Buffer Management

- **`.cl`** - Clear output buffer (reset to beginning)
  ```r3forth
  .cl  | Clear buffer, start fresh
  ```

- **`.flush`** - Write buffer contents to terminal and reset
  ```r3forth
  "Hello" .print
  "World" .print
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
  "Line 1" .write .cr
  "Line 2" .write .cr
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

- **`.print`** `( ... "format" -- )` - Format and print (uses `,print`)
  ```r3forth
  42 "Answer: %d" .print
  ```

- **`.println`** `( ... "format" -- )` - Format and print with newline, flush the buffer
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
  20 10 .at "Temporary" .write
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
- **`.Ital`** - Italic text
- **`.Under`** - Underlined text
- **`.Blink`** - Blinking text
- **`.Rever`** - Reverse video (swap foreground/background)
- **`.Hidden`** - Hidden text
- **`.Strike`** - Strikethrough text
- **`.Reset`** - Reset all attributes to default
  ```r3forth
  .Bold .Red "Error!" .write .Reset
  ```

---

## Terminal Information

### Global Variables

- **`rows`** - Current terminal height (number of rows)
- **`cols`** - Current terminal width (number of columns)

Example:
```r3forth
rows cols "Terminal size: %d x %d" .println
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
  1 =? ( evtkey handle-key )    | handle-key ( key -- )
  2 =? ( handle-mouse )
  drop
  ```
  - Returns event type or 0 if no event

- **`getevt`** `( -- type )` - Wait for any event
  ```r3forth
  ( running 1? drop
    getevt
    1 =? ( evtkey process-key )   | process-key ( key -- ), may set 0 'running !
    2 =? ( process-mouse )
    4 =? ( handle-resize )
    drop
  ) drop ;
  ```
  - Blocks until event occurs

---

## Keyboard Input

- **`getch`** `( -- key )` - Wait for keypress and return key code
  ```r3forth
  getch  | Wait for key
  [ESC] =? ( "Exit" .println ; )
  drop
  ```

- **`inkey`** `( -- key )` - Check for keypress without waiting. Mouse and resize events are consumed and reported as `0` (use `inevt` to see them)
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
evtmxy .at "*" .write  | Draw at mouse position
```

### Mouse Buttons

- **`evtmb`** - Mouse button state (bitmask)
  - Bit 0: Left button
  - Bit 1: Right button
  - Bit 2: Middle button

```r3forth
evtmb 1 and? ( "Left button pressed" .write ; )
evtmb 2 and? ( "Right button pressed" .write ; )
```

### Mouse Wheel

- **`evtmw`** - Mouse wheel delta
  - Positive: wheel scrolled up
  - Negative: wheel scrolled down
  - Zero: no wheel movement

```r3forth
evtmw 
0 >? ( "Scroll up" .write ; )
0 <? ( "Scroll down" .write ; )
drop
```

---

## Resize Detection

- **`.onresize`** `( 'callback -- )` - Set callback for terminal resize
  ```r3forth
  :on-resize
    rows cols "New size: %d x %d" .println ;
  
  'on-resize .onresize
  ```
  - Callback is executed when terminal size changes
  - Global variables `rows` and `cols` are updated before callback
  - It runs while the program polls the keyboard (`inevt`, `getevt`, `inkey`, `getch`)

---

## Simple Input Functions

- **`waitesc`** - Wait until ESC key is pressed
  ```r3forth
  "Press ESC to exit..." .println
  waitesc
  .cls
  ```

- **`waitkey`** - Wait until any key is pressed
  ```r3forth
  "Press any key to continue..." .println
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
- Event system (keyboard, mouse, resize), see the resize note below
- Mouse button and wheel detection

### Platform Notes

**Mouse Support:**
- Full support on both Windows and Linux
- Includes buttons, position, and wheel
- Movement tracking works on both platforms

**Resize Detection:**
- The size is checked every time the program polls (`inevt`, `getevt`, `inkey`, `getch`), on both platforms
- On Linux a callback must be registered with `.onresize` (it may be empty: `[ ; ] .onresize`) or a resize is never reported

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
.Green "Success: " .write
.Reset "Operation completed" .write
.cr .flush
```

### Menu System
```r3forth
:draw-menu
  .cls
  1 1 .at .Bold "=== MENU ===" .write .Reset
  1 3 .at "1. Option One" .write
  1 4 .at "2. Option Two" .write
  1 5 .at "q. Quit" .write ;

:option | key --
  $31 =? ( 1 7 .at "one chosen" .write )
  $32 =? ( 1 7 .at "two chosen" .write )
  drop ;

:menu
  draw-menu
  ( getch $71 <>? option ) drop ;
```

### Interactive Drawing
```r3forth
#px 40 #py 12

:draw-ui
  .cls
  1 1 .at "Arrow keys to move, ESC to exit" .write
  px py .at .Red "*" .write .Reset
  .flush ;

:handle-keys | key -- key
  [UP] =? ( py 1- 1 max 'py ! )
  [DN] =? ( py 1+ rows min 'py ! )
  [LE] =? ( px 1- 1 max 'px ! )
  [RI] =? ( px 1+ cols min 'px ! ) ;

:main
  .hidec
  draw-ui
  ( getch [ESC] <>? handle-keys drop draw-ui ) drop
  .showc ;
```

### Mouse Interaction
```r3forth
#running 1

:on-key evtkey [ESC] =? ( 0 'running ! ) drop ;

:on-mouse
  evtmb 1 and? ( evtmxy .at .Blue "o" .write .Reset .flush ) drop ;

:on-size
  .cls 1 1 .at "Resized!" .write .flush ;

:mouse-demo
  [ ; ] .onresize          | needed on Linux to receive event 4
  .cls .hidec
  1 1 .at "Click anywhere (ESC to exit)" .write .flush
  .enable-mouse
  ( running 1? drop
    inevt
    1 =? ( on-key )
    2 =? ( on-mouse )
    4 =? ( on-size )
    drop
    10 ms ) drop
  .disable-mouse
  .showc ;
```

The loop begins with `running 1?` on purpose: the `1 =?`, `2 =?` and `4 =?` have their own blocks, so without a loop test of its own the block would run only once.

### Progress Bar
```r3forth
:progress | pct --        ; 0..100, drawn with 20 cells
  5 /
  1 3 .at "[" .write
  .Green 35 over .nch .Reset
  45 over 20 swap - .nch
  "]" .write drop ;

:demo-progress
  .cls .hidec
  0 ( 101 <? dup progress .flush 1+ 20 ms ) drop
  1 5 .at "done" .write .flush
  waitkey .showc ;
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
  20 12 .at "Press any key to exit" .println
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
   "Prompt: " .write .flush
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
   .Red "Error" .write .Reset
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
  1 rows .at .Rever cols .nsp .write .Reset
  .restorec
  .flush ;

"Ready" status-line
```
`.nsp` paints `cols` cells with the current attributes without moving the cursor, so the text written next goes over the painted bar.

### Centered Text
```r3forth
:center | "text" row --
  over count nip cols swap - 2/ 1+ swap .at
  .write .flush ;

"Title" 1 center
```

### Box Drawing
```r3forth
:hline | n --
  ( 1? 1- "─" .write ) drop ;

#bx #by #bw #bh

:box | x y w h --         ; w h = inner size
  'bh ! 'bw ! 'by ! 'bx !
  bx by .at "┌" .write bw hline "┐" .write
  0 ( bh <?
    bx over by + 1+ .at "│" .write 32 bw .nch "│" .write
    1+ ) drop
  bx by bh + 1+ .at "└" .write bw hline "┘" .write ;

10 5 30 10 box
```

---

## Notes

- **Buffer size:** about 8 KB (flushed automatically when full)
- **Coordinate system:** 1-based (1,1 is top-left)
- **UTF-8:** Fully supported on both platforms
- **Thread safety:** Not thread-safe
- **Terminal size:** Updated automatically on resize
- **Mouse coordinates:** Match terminal grid (1-based)
- **Color support:** Requires ANSI-compatible terminal