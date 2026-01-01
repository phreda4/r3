# R3Forth Text User Interface Library (tui.r3)

A complete Text User Interface (TUI) framework for R3Forth providing widget-based UI construction with keyboard and mouse support, focus management, and event handling.

## Overview

This library provides:
- **Layout system** with nested frames and automatic clipping
- **Widget system** with focus management and event routing
- **Input handling** (keyboard, mouse, wheel)
- **Complete widget set** (buttons, lists, trees, input, check, radio, slider, progress)
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
    tui  | Reset at start
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
  uikey [esc] =? ( exit )
  ```

### UI Reset

- **`tui`** - Reset for new frame
  ```r3forth
  :my-ui
    tui  | Reset state and frame
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
  - Increments fy by 1
  - Moves to column fx

- **`fw%`** `( percent -- columns )` - Calculate percentage of width
  ```r3forth
  50.0 fw%  | 50% of frame width
  ```

- **`fh%`** `( percent -- rows )` - Calculate percentage of height

- **`flin?`** `( x y -- 1/0 )` - Check if point is inside frame
  ```r3forth
  evtmx evtmy flin? 0? ( "Outside" print ; )
  ```

- **`flin?1`** `( x y -- 1/0 )` - Check if point is in first line only
  ```r3forth
  evtmx evtmy flin?1  | Only tests Y >= fy (not Y < fy+fh)
  ```

- **`flxvalid?`** `( -- 1/0 )` - Check if frame is valid (w,h > 0)

---

## Widgets

### Widget State

Each widget returns a state value indicating interaction:

- `0` = Normal (no interaction)
- `1` = Over (mouse hover)
- `2` = In (mouse button down inside)
- `3` = Active (dragging inside)
- `4` = Active outside (dragging but outside widget)
- `5` = Out (mouse released outside after drag)
- `6` = Click (mouse released inside)

### Widget Functions

- **`tuiw`** `( -- state )` - Widget with mouse interaction (full frame)
  ```r3forth
  tuiw
  6 =? ( "Clicked!" print )
  drop
  ```
  - Tests entire frame area
  - Auto-increments widget ID
  - Tracks mouse state
  - Returns interaction state

- **`tuiw1`** `( -- state )` - Widget with mouse interaction (single line)
  ```r3forth
  tuiw1  | Only tests first line of frame
  6 =? ( "Clicked!" print )
  drop
  ```
  - Tests only first row (fy)
  - Useful for single-line widgets (buttons, inputs)

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

- **`tuBtn`** `( 'callback "text" -- )` - Standard button (single line)
  ```r3forth
  :on-click "Button clicked!" print tuR! ;
  'on-click "Click Me" tuBtn
  ```
  - Centers text horizontally
  - Single line height
  - Calls callback on click or Enter key
  - Focus with Tab/Shift+Tab
  - Automatically increments fy

- **`tuTBtn`** `( 'callback "text" -- )` - Text-box button (multi-line)
  ```r3forth
  'save-action "Save\nFile" tuTBtn
  ```
  - Fills entire frame with text
  - Multi-line support
  - Supports color codes in text
  - Useful for larger buttons

### Labels

- **`tuLabel`** `( "text" -- )` - Left-aligned label
  ```r3forth
  "Username:" tuLabel
  ```
  - Single line
  - Automatically increments fy

- **`tuLabelC`** `( "text" -- )` - Center-aligned label
  ```r3forth
  "Title" tuLabelC
  ```

- **`tuLabelR`** `( "text" -- )` - Right-aligned label
  ```r3forth
  "123" tuLabelR  | Right-align numbers
  ```

### Windows/Panels

- **`tuWin`** - Draw window border
  ```r3forth
  10 5 60 20 flx!
  tuWin  | Draw curved border
  ```
  - Highlights if active window
  - Auto-increments window ID
  - Uses `.wbordec` (curved border)

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
  - Shows scroll indicator

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
- Type to insert characters (32-126)
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

- **Insert mode** (default): Blinking bar cursor, characters inserted
- **Overwrite mode**: Block cursor, characters replaced

---

## Check Box Widget

Toggle checkbox with label.

### Usage

- **`tuCheck`** `( 'var "label" -- )` - Display checkbox
  ```r3forth
  #option 0  | 0=unchecked, 1=checked
  
  'option "Enable feature" tuCheck
  ```
  - Shows `[ ]` when unchecked
  - Shows `[X]` when checked
  - Click or Enter to toggle
  - Sets `tuX?` when changed

### Example

```r3forth
#save-backup 0
#auto-save 1

:options-ui
  tui
  10 5 40 10 flx!
  tuWin
  1 1 flpad
  
  2 flxN
  'save-backup "Save backup copies" tuCheck
  
  flxRest 2 flxN
  'auto-save "Auto-save every 5 min" tuCheck
  ;
```

---

## Radio Button Widget

Mutually exclusive options.

### Usage

- **`tuRadio`** `( n 'var "label" -- )` - Display radio button
  ```r3forth
  #color 0  | Selected option (0, 1, or 2)
  
  0 'color "Red" tuRadio
  1 'color "Green" tuRadio
  2 'color "Blue" tuRadio
  ```
  - Shows `( )` when not selected
  - Shows `(•)` when selected
  - Click or Enter to select
  - Deselects others automatically (same variable)
  - Sets `tuX?` when changed

### Example

```r3forth
#difficulty 1  | 0=Easy, 1=Normal, 2=Hard

:settings-ui
  tui
  10 5 40 15 flx!
  tuWin
  1 1 flpad
  
  $01 "Difficulty" .wtitle
  
  2 flxN
  0 'difficulty "Easy" tuRadio
  
  flxRest 2 flxN
  1 'difficulty "Normal" tuRadio
  
  flxRest 2 flxN
  2 'difficulty "Hard" tuRadio
  ;
```

---

## Slider Widget

Horizontal slider for numeric input.

### Usage

- **`tuSlider`** `( 'var min max -- )` - Display slider
  ```r3forth
  #volume 50  | Current value (0-100)
  
  'volume 0 100 tuSlider
  ```
  - Shows horizontal line (─)
  - Shows position marker (●)
  - Click to jump to position
  - Drag to adjust value
  - Sets `tuX?` when changed
  - Automatically increments fy

### Example

```r3forth
#volume 75
#brightness 50

:settings-ui
  tui
  10 5 40 12 flx!
  tuWin
  1 1 flpad
  
  2 flxN
  "Volume:" tuLabel
  flxRest 2 flxN
  'volume 0 100 tuSlider
  
  flxRest 2 flxN
  "Brightness:" tuLabel
  flxRest 2 flxN
  'brightness 0 100 tuSlider
  
  | Show values
  flxRest 2 flxN
  volume "Volume: %d%%" sprint tuLabel
  ;
```

---

## Progress Bar Widget

Display progress indicator.

### Usage

- **`tuProgress`** `( percent -- )` - Display progress bar
  ```r3forth
  50 tuProgress  | 50% complete
  ```
  - Shows filled bar (█ characters)
  - Percent: 0-100 (auto-clamped)
  - Fills frame width
  - Automatically increments fy

### Example

```r3forth
#progress 0

:update-progress
  progress 1+ 100 min 'progress !
  tuR!  | Request redraw
  ;

:progress-ui
  tui
  
  cols 2/ 20 - rows 2/ 3 -
  40 8 flx!
  tuWin
  1 1 flpad
  
  $01 "Loading..." .wtitle
  
  2 flxN
  
  flxRest 2 flxN
  progress tuProgress
  
  flxRest 2 flxN
  progress "%d%% complete" sprint tuLabelC
  ;

:loading
  0 'progress !
  'progress-ui onTui
  ;
```

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

## Complete Examples

### Form with All Widgets
```r3forth
#username * 32
#password * 32
#remember 0
#color 0
#volume 50
#progress 0

:form-ui
  tui
  
  10 5 60 25 flx!
  tuWin
  1 1 flpad
  
  $01 "REGISTRATION FORM" .wtitle
  
  | Username
  2 flxN
  "Username:" tuLabel
  flxRest 2 flxN
  'username 32 tuInputLine
  
  | Password
  flxRest 2 flxN
  "Password:" tuLabel
  flxRest 2 flxN
  'password 32 tuInputLine
  
  | Remember me
  flxRest 2 flxN
  'remember "Remember me" tuCheck
  
  | Color selection
  flxRest 2 flxN
  "Favorite color:" tuLabel
  flxRest 2 flxN
  0 'color "Red" tuRadio
  flxRest 2 flxN
  1 'color "Blue" tuRadio
  flxRest 2 flxN
  2 'color "Green" tuRadio
  
  | Volume slider
  flxRest 2 flxN
  "Volume:" tuLabel
  flxRest 2 flxN
  'volume 0 100 tuSlider
  
  | Progress
  flxRest 2 flxN
  progress tuProgress
  
  | Update progress for demo
  progress 100 <? ( 1 'progress +! tuR! ) drop
  ;

'form-ui onTui
```

### Settings Panel
```r3forth
#vsync 1
#aa 1
#quality 1
#music-vol 80
#sfx-vol 60

:settings
  tui
  
  cols 2/ 30 - rows 2/ 12 -
  60 24 flx!
  tuWina
  1 1 flpad
  
  $01 "SETTINGS" .wtitle
  
  | Graphics
  2 flxN
  .Bold "Graphics" tuLabel .Reset
  
  flxRest 2 flxN
  'vsync "V-Sync" tuCheck
  
  flxRest 2 flxN
  'aa "Anti-aliasing" tuCheck
  
  flxRest 2 flxN
  "Quality:" tuLabel
  flxRest 2 flxN
  0 'quality "Low" tuRadio
  flxRest 2 flxN
  1 'quality "Medium" tuRadio
  flxRest 2 flxN
  2 'quality "High" tuRadio
  
  | Audio
  flxRest 2 flxN
  .Bold "Audio" tuLabel .Reset
  
  flxRest 2 flxN
  "Music volume:" tuLabel
  flxRest 2 flxN
  'music-vol 0 100 tuSlider
  
  flxRest 2 flxN
  "SFX volume:" tuLabel
  flxRest 2 flxN
  'sfx-vol 0 100 tuSlider
  
  | Buttons
  flxRest -2 flxN
  flxpush
  50.0 fw% flxO
  :on-save "Settings saved!" print tuR! ;
  'on-save "Save" tuBtn
  flxpop
  50.0 fw% flxE
  :on-cancel exit ;
  'on-cancel "Cancel" tuBtn
  ;

'settings onTui
```

---

## Best Practices

1. **Always call `tui` at start of render**
   ```r3forth
   :my-ui
     tui  | Reset state and frame
     | ... widgets ...
     ;
   ```

2. **Use `tuiw1` for single-line widgets**
   ```r3forth
   tuBtn  | Uses tuiw1 internally
   tuCheck  | Uses tuiw1 internally
   ```

3. **Request redraw when state changes**
   ```r3forth
   value-changed? ( tuR! ; )
   ```

4. **Use appropriate widget**
   - Buttons for actions
   - Check for on/off options
   - Radio for exclusive choices
   - Slider for numeric ranges
   - List for selections
   - Progress for status

5. **Handle `tuX?` for actions**
   ```r3forth
   'callback "Button" tuBtn
   tuX? 1? ( | Process action ) drop
   ```

---

## Notes

- **Frame coordinates:** 1-based (1,1 is top-left)
- **Widget IDs:** Auto-incremented, reset each frame
- **Focus:** Only one widget has focus
- **Active widget:** Only one can be clicked/dragged
- **`tuiw` vs `tuiw1`:** Use `tuiw1` for single-line widgets
- **Cursor:** Hidden by default, shown with `tuC!`
- **All widgets increment fy** except containers
- **Check/Radio:** Value is 0 or 1 (or index for radio)
- **Slider:** Value clamped to min-max range
- **Progress:** Percent auto-clamped 0-100