# R3Forth Text User Interface Library (tui.r3)

A complete Text User Interface (TUI) framework for R3Forth providing widget-based UI construction with keyboard and mouse support, focus management, and event handling.

## Overview

This library provides:
- **Layout system** with nested frames and automatic clipping
- **Widget system** with focus management and event routing
- **Input handling** (keyboard, mouse, wheel)
- **Standard widgets** (buttons, lists, trees, input fields)
- **Event-driven architecture** with redraw optimization
- **Modal loop** with automatic rendering

---

## Core Concepts

### Layout System (Frame Layout)

The library uses a **frame-based layout** system where all widgets are constrained to rectangular regions.

**Global frame variables:**
- `fx` - Frame X position (column)
- `fy` - Frame Y position (row)
- `fw` - Frame width (columns)
- `fh` - Frame height (rows)

### Widget IDs

Widgets are automatically assigned sequential IDs starting from 0. The system tracks:
- `id` - Current widget ID (auto-incremented)
- `ida` - Active widget (being clicked/dragged)
- `idf` - Focused widget (keyboard input)
- `wid` - Current window/panel ID

---

## Initialization and Main Loop

### Starting TUI

- **`onTui`** `( 'render-callback -- )` - Start TUI main loop
  ```r3forth
  :my-ui
    | ... draw widgets here ...
    ;
  
  'my-ui onTui
  ```
  - Initializes event system
  - Enters modal loop
  - Calls render callback on changes
  - Returns when `exit` is called

- **`exit`** - Exit TUI loop
  ```r3forth
  uikey [esc] =? ( exit ; )
  ```

### UI Reset

- **`tui`** - Reset for new frame
  ```r3forth
  :my-ui
    tui  | Reset state
    | ... draw widgets ...
    ;
  ```
  - Resets widget ID counter
  - Restores main frame
  - Call at start of render callback

---

## Frame Layout

### Frame Initialization

- **`flx`** - Initialize frame to full terminal
  ```r3forth
  flx  | Set frame to 1,1,cols,rows
  ```

- **`flx!`** `( x y w h -- )` - Set explicit frame
  ```r3forth
  10 5 60 20 flx!
  ```

### Frame Stack

- **`flxpush`** - Push current frame to stack
  ```r3forth
  flxpush
  | ... modify frame ...
  flxpop  | Restore
  ```

- **`flxpop`** - Pop frame from stack

- **`flxRest`** - Restore frame without popping
  ```r3forth
  5 flxN  | Take 5 rows from top
  flxRest | Restore full frame
  ```

### Frame Division

Divide frame into regions (N=North, S=South, E=East, O=Oeste/West):

- **`flxN`** `( n -- )` - Take n rows from top
  ```r3forth
  5 flxN  | Frame is now top 5 rows
  ```
  - Negative values: all except n rows
  - Updates fy and fh

- **`flxS`** `( n -- )` - Take n rows from bottom
  ```r3forth
  3 flxS  | Frame is now bottom 3 rows
  ```

- **`flxE`** `( n -- )` - Take n columns from right
  ```r3forth
  20 flxE  | Frame is now rightmost 20 columns
  ```

- **`flxO`** `( n -- )` - Take n columns from left
  ```r3forth
  30 flxO  | Frame is now leftmost 30 columns
  ```

### Frame Utilities

- **`flpad`** `( x y -- )` - Add padding to frame
  ```r3forth
  1 1 flpad  | Add 1 column/row padding on all sides
  ```

- **`flcr`** - Carriage return within frame
  ```r3forth
  flcr  | Move to start of next line in frame
  ```

- **`fw%`** `( percent -- columns )` - Calculate percentage of width
  ```r3forth
  50.0 fw%  | 50% of frame width
  ```

- **`fh%`** `( percent -- rows )` - Calculate percentage of height

- **`flin?`** `( x y -- 1/0 )` - Check if point is inside frame
  ```r3forth
  evtmx evtmy flin? 0? ( "Outside" print ; )
  ```

- **`flxvalid?`** `( -- 1/0 )` - Check if frame is valid (w,h > 0)

---

## Widgets

### Widget State

Each widget returns a state value indicating interaction:

- `0` = Normal (no interaction)
- `1` = Over (mouse hover) - not always available
- `2` = In (mouse button down inside)
- `3` = Active (dragging inside)
- `4` = Active outside (dragging but outside widget)
- `5` = Out (mouse released outside after drag)
- `6` = Click (mouse released inside)

State transitions:
```
Normal(0) → Over(1) → In(2) → Active(3) ⇄ Active-Out(4)
                                 ↓            ↓
                               Click(6)    Out(5)
```
### Widget Functions

- **`tuiw`** `( -- state )` - Widget with mouse interaction
  ```r3forth
  tuiw
  6 =? ( "Clicked!" print )
  drop
  ```
  - Auto-increments widget ID
  - Tracks mouse state
  - Returns interaction state

- **`tuif`** `( -- state )` - Widget with focus (keyboard)
  ```r3forth
  tuif
  1 =? ( "Got focus" print )
  2 =? ( "Has focus" print )
  drop
  ```
  - Returns: 0=no focus, 1=just got focus, 2=has focus

### Action Flags

- **`tuX!`** - Mark action executed (click/enter)
- **`tuX?`** `( -- 1/0 )` - Check if action should execute
- **`tuR!`** - Request redraw
- **`tuC!`** - Enable cursor display
- **`tuRefocus`** - Reset focus system

---

## Standard Widgets

### Buttons

- **`tuBtn`** `( 'callback "text" -- )` - Standard button
  ```r3forth
  :on-click "Button clicked!" print ;
  'on-click "Click Me" tuBtn
  ```
  - Centers text horizontally
  - Calls callback on click or Enter key
  - Focus with Tab/Shift+Tab

- **`tuTBtn`** `( 'callback "text" -- )` - Text-box button
  ```r3forth
  'save-action "Save File" tuTBtn
  ```
  - Fills entire frame with text
  - Supports color codes in text

### Windows/Panels

- **`tuWin`** - Draw window border
  ```r3forth
  10 5 60 20 flx!
  tuWin  | Draw curved border
  ```
  - Highlights if active window
  - Auto-increments window ID

- **`tuWina`** - Draw window border with bold when active
  ```r3forth
  tuWina  | Bold border when active
  ```

### Drawing Helpers

- **`.wfill`** - Fill frame with spaces
- **`.wborde`** - Draw single-line border
- **`.wborded`** - Draw double-line border
- **`.wbordec`** - Draw curved border

- **`.wtitle`** `( place "title" -- )` - Draw title at position
  ```r3forth
  $01 "My Window" .wtitle  | Top-center
  ```
  - Place codes: `$xy` where x,y are 0-7
  - `$01` = top-center, `$44` = center-center

---

## List Widget

Display scrollable lists with keyboard/mouse navigation.

### List Variable Format
```r3forth
#mylist
  0  | Current selection (value)
  0  | Scroll offset
```

### Usage

- **`tuList`** `( 'var "list" -- )` - Display list widget
  ```r3forth
  #items "Apple\0Banana\0Cherry\0"
  
  'mylist items tuList
  ```
  - String format: null-separated items (`\0`)
  - Automatically scrolls
  - Mouse wheel support
  - Keyboard: Up/Down, PgUp/PgDn, Tab

### List Controls

**Mouse:**
- Click item to select
- Scroll wheel to scroll

**Keyboard:**
- `↑`/`↓` - Previous/next item
- `PgUp`/`PgDn` - Page up/down
- `Tab`/`Shift+Tab` - Change focus

### Custom List Rendering

- **`xwrite!`** `( 'render-func -- )` - Set custom list item renderer
  ```r3forth
  :my-renderer | width "text" --
    | ... custom rendering ...
    ;
  
  'my-renderer xwrite!
  'mylist items tuList
  xwrite.reset
  ```

- **`xwrite.reset`** - Reset to default renderer (`lwrite`)

---

## Tree Widget

Display hierarchical trees with expand/collapse.

### Tree String Format

Each line: `[FLAGS]TEXT\0`

**Flags (first byte):**
- Bits 0-4: Level (0-31)
- Bit 5 (`$20`): Has children
- Bit 7 (`$80`): Is expanded

```r3forth
#tree
  ( 0 ) "Root\0"           | Level 0
  ( $20 ) "Parent\0"       | Level 0, has children
  ( $A1 ) "  Child1\0"     | Level 1, expanded
  ( $A1 ) "  Child2\0"     | Level 1, expanded
  0
```

### Usage

- **`tuTree`** `( 'var "tree" -- )` - Display tree widget
  ```r3forth
  #treevar 0 0  | Selection, offset
  
  'treevar tree-data tuTree
  ```
  - Click/Enter to expand/collapse
  - Same navigation as list
  - Shows ▸/▾ icons for folders

---

## Input Field Widget

Single-line text input with editing.

### Usage

- **`tuInputLine`** `( 'buffer maxlen -- )` - Text input field
  ```r3forth
  #username * 32  | 32-byte buffer
  
  'username 32 tuInputLine
  ```

### Input Controls

**Editing:**
- Type to insert characters
- `Backspace` - Delete before cursor
- `Delete` - Delete at cursor
- `←`/`→` - Move cursor
- `Home`/`End` - Start/end of line
- `Insert` - Toggle insert/overwrite mode

**Focus:**
- `Tab`/`Shift+Tab` - Change focus
- `↑`/`↓` - Change focus
- `Enter` - Execute action (sets `tuX?`)

### Input Modes

- **Insert mode** (default): New characters inserted
- **Overwrite mode**: New characters replace existing

---

## Text Display

- **`tuText`** `( "text" align -- )` - Display formatted text
  ```r3forth
  "This is a long text that will wrap automatically within the frame."
  $05 tuText  | Center align
  ```
  - Automatic word wrapping
  - Respects frame boundaries
  - Alignment codes same as `xalign`

---

## Event Variables

- **`uikey`** - Current key code (from keyboard event)
  ```r3forth
  uikey [enter] =? ( "Enter pressed" print ; )
  ```

- **`evtmx`, `evtmy`** - Mouse position (from terminal lib)
- **`evtmb`** - Mouse buttons
- **`evtmw`** - Mouse wheel delta

---

## Usage Examples

### Basic Application
```r3forth
:main-ui
  tui  | Reset state
  
  flx  | Full screen
  .wfill
  
  1 flxN  | Top row
  $01 "My Application" .wtitle
  
  flxRest
  1 flxS  | Bottom row
  $04 "Press ESC to exit" .wtitle
  ;

'main-ui onTui
```

### Button Menu
```r3forth
:on-new "New file" print tuR! ;
:on-open "Open file" print tuR! ;
:on-save "Save file" print tuR! ;
:on-quit exit ;

:menu-ui
  tui
  
  10 5 30 15 flx!
  tuWin
  1 1 flpad
  
  $01 "MENU" .wtitle
  
  2 flxN
  'on-new "New" tuBtn
  
  flxRest 2 flxN
  'on-open "Open" tuBtn
  
  flxRest 2 flxN
  'on-save "Save" tuBtn
  
  flxRest 2 flxN
  'on-quit "Quit" tuBtn
  ;

'menu-ui onTui
```

### List Example
```r3forth
#files "readme.txt\0main.r3\0lib.r3\0test.r3\0"
#file-list 0 0

:file-ui
  tui
  
  10 5 40 15 flx!
  tuWin
  1 1 flpad
  
  $01 "Select File" .wtitle
  
  2 flxN  | Skip title
  
  flxRest
  'file-list files tuList
  
  | Check selection
  tuX? 1? (
    file-list @ 3 << files + 
    "Selected: %s" print tuR!
  ) drop
  ;

'file-ui onTui
```

### Split Layout
```r3forth
:split-ui
  tui
  
  flx
  .wfill
  
  | Left panel
  flxpush
  50.0 fw% flxO  | Left 50%
  .wborde
  1 1 flpad
  "Left Panel" 0 tuText
  flxpop
  
  | Right panel  
  50.0 fw% flxE  | Right 50%
  .wborde
  1 1 flpad
  "Right Panel" 0 tuText
  ;

'split-ui onTui
```

### Tree Browser
```r3forth
#folders
  ( 0 ) "Root\0"
  ( $20 ) "Documents\0"
  ( $A1 ) "  Work\0"
  ( $A1 ) "  Personal\0"
  ( $20 ) "Pictures\0"
  ( $A1 ) "  2024\0"
  ( $A1 ) "  2023\0"
  0

#tree-sel 0 0

:tree-ui
  tui
  
  10 5 50 20 flx!
  tuWin
  1 1 flpad
  
  $01 "Folder Browser" .wtitle
  
  2 flxN  | Title space
  
  flxRest
  'tree-sel folders tuTree
  ;

'tree-ui onTui
```

### Form with Input
```r3forth
#username * 32
#password * 32

:on-login
  username "admin" = 1? (
    "Login successful!" print tuR!
  ) (
    "Invalid credentials" print tuR!
  ) drop ;

:login-ui
  tui
  
  cols 2/ 20 - rows 2/ 5 -
  40 12 flx!
  tuWina
  1 1 flpad
  
  $01 "LOGIN" .wtitle
  
  2 flxN  | Title
  
  flxRest 3 flxN
  1 flxN
  "Username:" 0 tuText
  flxRest
  'username 32 tuInputLine
  
  flxRest 3 flxN
  1 flxN
  "Password:" 0 tuText
  flxRest
  'password 32 tuInputLine
  
  flxRest -2 flxN
  'on-login "Login" tuBtn
  ;

'login-ui onTui
```

### Complex Layout
```r3forth
:complex-ui
  tui
  
  flx
  .wfill
  
  | Header
  flxpush
  1 flxN
  .wborde
  $44 "Application Title" .wtitle
  flxpop
  
  | Footer
  flxpush
  -1 flxS
  .wborde
  $44 "Status: Ready" .wtitle
  flxpop
  
  | Main area (middle)
  1 flxN -1 flxS
  
  | Left sidebar
  flxpush
  20 flxO
  .wborde
  1 1 flpad
  "Sidebar" 0 tuText
  flxpop
  
  | Right content
  20 flxO
  .wborde
  1 1 flpad
  "Main Content Area" 0 tuText
  ;

'complex-ui onTui
```

---

## Best Practices

1. **Always call `tui` at start of render**
   ```r3forth
   :my-ui
     tui  | Reset state
     | ... widgets ...
     ;
   ```

2. **Use frame stack for nested layouts**
   ```r3forth
   flxpush
     | Inner layout
   flxpop
   ```

3. **Check `tuX?` for button actions**
   ```r3forth
   'callback "Button" tuBtn
   tuX? 1? ( | Action executed ) drop
   ```

4. **Request redraw when state changes**
   ```r3forth
   data-changed? ( tuR! ; )
   ```

5. **Use appropriate widget for task**
   - Lists for selections
   - Trees for hierarchies
   - Input fields for text entry
   - Buttons for actions

6. **Handle focus properly**
   ```r3forth
   tuif 1 =? ( | Just got focus ) drop
   ```

---

## Layout Patterns

### Three-Column Layout
```r3forth
| Left
flxpush 33.0 fw% flxO
  | ... left content ...
flxpop

| Center
flxpush 33.0 fw% flxO 33.0 fw% flxE
  | ... center content ...
flxpop

| Right
33.0 fw% flxE
  | ... right content ...
```

### Header/Content/Footer
```r3forth
| Header
flxpush 3 flxN
  | ... header ...
flxpop

| Footer
flxpush -3 flxS
  | ... footer ...
flxpop

| Content (middle)
3 flxN -3 flxS
  | ... content ...
```

---

## Notes

- **Frame coordinates:** 1-based (1,1 is top-left)
- **Widget IDs:** Auto-incremented, reset each frame
- **Focus:** Only one widget has focus at a time
- **Active widget:** Only one can be clicked/dragged
- **Redraw:** Automatic on events, manual with `tuR!`
- **Cursor:** Hidden by default, shown with `tuC!`
- **ESC key:** Not handled automatically - implement in your UI
- **Frame stack:** Maximum 8 levels deep
- **List items:** Null-separated strings
- **Tree flags:** First byte of each line