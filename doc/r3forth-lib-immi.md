# R3Forth IMMI Library (immi.r3)

An immediate mode GUI (IMGUI) library for R3Forth providing a complete set of interactive widgets and layout management for building user interfaces.

## Overview

IMMI (Immediate Mode Interface) v.3 provides a stateless GUI system where widgets are created and rendered in a single pass each frame. The library handles focus management, mouse interaction, keyboard input, and automatic layout.

**Dependencies:**
- `r3/lib/sdl2gfx.r3` - SDL2 graphics functions
- `r3/util/txfont.r3` - Text font rendering

**Key Concepts:**
- **Immediate mode**: Widgets don't persist between frames
- **Layout system**: Flexible grid and box-based positioning
- **Focus management**: Automatic tab order and keyboard navigation
- **State tracking**: Internal ID system for hover/click/focus states

---

## Layout System

### Window Management

- **`uiFull`** `( -- )` - Set layout to full screen
  - Uses entire screen dimensions as active area
  ```
  uiFull  | Use full screen for UI
  ```

- **`uiBox`** `( x y w h -- )` - Define rectangular layout area
  - Sets the active UI region for subsequent widgets
  - All coordinates relative to this box
  ```
  100 100 400 300 uiBox  | 400x300 box at (100,100)
  ```

### Layout Stack

- **`uiPush`** `( -- )` - Save current layout state
  - Pushes current box dimensions onto stack
  - Allows nested layouts

- **`uiPop`** `( -- )` - Restore previous layout state
  - Pops layout from stack
  - Returns to previous UI region

- **`uiRest`** `( -- )` - Restore layout without popping
  - Resets to current saved layout
  - Useful for repetitive operations

### Layout Subdivision

- **`uiN`** `( lines -- )` - Take top N lines (or pixels if negative)
  - Positive: number of text lines
  - Negative: exact pixel height
  ```
  2 uiN  | Take top 2 lines
  -50 uiN  | Take top 50 pixels
  ```

- **`uiS`** `( lines -- )` - Take bottom N lines/pixels
  - Similar to uiN but from bottom

- **`uiE`** `( cols -- )` - Take right N columns/pixels
  - Positive: text-width based columns
  - Negative: exact pixels

- **`uiO`** `( cols -- )` - Take left N columns/pixels (O = Oeste/West)

### Padding

- **`uiPading`** `( x y -- )` - Set padding for layout area
  - x: horizontal padding
  - y: vertical padding
  ```
  10 10 uiPading  | 10 pixel padding on all sides
  ```

### Grid System

- **`uiGrid`** `( cols rows -- )` - Create grid layout
  - Divides current box into cols×rows grid
  - Automatically adjusts for fit
  ```
  3 4 uiGrid  | 3 columns, 4 rows
  ```

- **`uiNext`** `( -- )` - Move to next grid cell (row-major order)
  - Advances left-to-right, then top-to-bottom
  - Wraps to beginning when reaching end

- **`uiNextV`** `( -- )` - Move to next grid cell (column-major order)
  - Advances top-to-bottom, then left-to-right

- **`uiAt`** `( x y -- )` - Jump to specific grid cell
  - x: column index (0-based)
  - y: row index (0-based)
  ```
  1 2 uiAt  | Go to column 1, row 2
  ```

- **`uiTo`** `( w h -- )` - Set cursor size in grid units
  - w: width in grid columns
  - h: height in grid rows

### Size Helpers

- **`%cw`** `( -- width )` - Get current cursor width in fixed-point
- **`%ch`** `( -- height )` - Get current cursor height in fixed-point

---

## UI State Management

### Frame Control

- **`uiStart`** `( -- )` - Initialize UI frame
  - Must be called at start of each frame
  - Resets focus and mouse state
  - Handles keyboard modifiers

- **`uiEnd`** `( -- )` - Finalize UI frame
  - Must be called at end of each frame
  - Processes last widget if active

### Focus Management

- **`uiFocus>>`** `( -- )` - Move focus to next widget
  - Advances focus forward

- **`uiFocus<<`** `( -- )` - Move focus to previous widget
  - Moves focus backward

- **`uiRefocus`** `( -- )` - Reset focus to current widget
  - Forces focus refresh

---

## Interaction Zones

### Zone Definition

- **`uiZone`** `( -- )` - Define interaction area (1 line height)
  - Sets clickable/hoverable region
  - Uses current cursor position and font height

- **`uiZoneL`** `( nlines -- )` - Define zone with N lines height
  - Multiple line height zone
  ```
  3 uiZoneL  | 3 lines tall interaction zone
  ```

- **`uiZoneW`** `( -- )` - Define zone using full cursor size
  - Uses current cw/ch dimensions

- **`uiZoneBox`** `( x y w h -- )` - Define custom rectangular zone
  - Saves current cursor, sets custom zone
  - Use `uiBackBox` to restore

- **`uiBackBox`** `( -- )` - Restore cursor after uiZoneBox

- **`uiPlace`** `( n -- )` - Mark position for drag operations
  - Sets drag target index

### Interaction Callbacks

All callbacks execute only when their condition is met:

- **`uiOvr`** `( 'callback -- )` - Execute on mouse over
  - Triggers when mouse hovers over zone

- **`uiDwn`** `( 'callback -- )` - Execute on mouse down
  - Triggers when mouse button pressed in zone

- **`uiSel`** `( 'callback -- )` - Execute while selected (active)
  - Triggers while zone is being clicked

- **`uiClk`** `( 'callback -- )` - Execute on click release
  - Triggers when mouse released after click

- **`uiUp`** `( 'callback -- )` - Execute on release outside
  - Triggers when released after leaving zone

- **`uiFocusIn`** `( 'callback -- )` - Execute when gaining focus
  - Triggers once when focus enters

- **`uiFocus`** `( 'callback -- )` - Execute while focused
  - Triggers every frame while focused

### State Query

- **`uiEx?`** `( -- flag )` - Check if widget was activated
  - Returns true if widget triggered action
  - Used after widget calls to check interaction

---

## Drawing Functions

### Basic Shapes

- **`uiFill`** `( -- )` - Draw filled rectangle
  - Uses current cursor position and size

- **`uiRect`** `( -- )` - Draw rectangle outline
  - 1 pixel border

- **`uiRFill`** `( round -- )` - Draw filled rounded rectangle
  - Parameter: corner radius in pixels

- **`uiRRect`** `( round -- )` - Draw rounded rectangle outline
  - Parameter: corner radius

- **`uiCFill`** `( -- )` - Draw filled circle/ellipse
  - Automatically sizes to cursor dimensions

- **`uiCRect`** `( -- )` - Draw circle/ellipse outline

- **`uiTex`** `( texture -- )` - Draw texture at cursor
  - Stretches texture to cursor size

- **`uiWinBox`** `( -- x y w h )` - Get current window box dimensions

### Line-based Drawing

- **`uilFill`** `( -- )` - Fill line height (for text backgrounds)
- **`uilRFill`** `( round -- )` - Rounded fill for line
- **`uilCFill`** `( -- )` - Circular fill for line
- **`uilTex`** `( texture -- )` - Texture for line height
- **`uilRect`** `( -- )` - Rectangle outline for line
- **`uilRRect`** `( round -- )` - Rounded rectangle outline for line
- **`uilCRect`** `( -- )` - Circular outline for line

### Grid Lines

- **`uiLineGridV`** `( -- )` - Draw vertical grid lines
- **`uiLineGridH`** `( -- )` - Draw horizontal grid lines
- **`uiLineGrid`** `( -- )` - Draw both vertical and horizontal lines

---

## Style System

### Color Variables

```
colBac  | Background colors (normal|disabled|focus|over)
colFil  | Fill colors
colTxt  | Text colors
colFoc  | Focus highlight color
```

### Style Presets

- **`stDang`** `( -- )` - Danger style (red) `$ffff8099ff85001B`
- **`stWarn`** `( -- )` - Warning style (orange) `$ffffBF29fff55D00`
- **`stSucc`** `( -- )` - Success style (green) `$ff5BCD9Aff1F6546`
- **`stInfo`** `( -- )` - Info style (blue) `$ff80D9FFff005D85`
- **`stLink`** `( -- )` - Link style (dark blue) `$ff4258FFff000F85`
- **`stDark`** `( -- )` - Dark style `$ff393F4Cff14161A`
- **`stLigt`** `( -- )` - Light style `$ffaaaaaaff888888`

---

## Text Widgets

### Labels

- **`uiLabel`** `( "text" -- )` - Left-aligned label
  - Renders text and advances cursor one line

- **`uiLabelC`** `( "text" -- )` - Center-aligned label

- **`uiLabelR`** `( "text" -- )` - Right-aligned label

- **`uiText`** `( "text" align -- )` - Multi-line text with alignment
  - Uses txText for word wrapping
  - Alignment: $VH format (vertical/horizontal)

- **`uiTlabel`** `( "text" -- )` - Auto-sized centered label
  - Adjusts cursor width to text width

### Text Helpers

- **`ttwrite`** `( "text" -- )` - Write text at cursor (left-aligned)
- **`ttwritec`** `( "text" -- )` - Write text centered
- **`ttwriter`** `( "text" -- )` - Write text right-aligned

### Separators

- **`uil..`** `( -- )` - Advance cursor by text height
- **`ui..`** `( -- )` - Advance cursor by text height + padding
- **`ui--`** `( -- )` - Draw horizontal separator line

---

## Button Widgets

### Standard Buttons

- **`uiBtn`** `( 'callback "text" -- )` - Standard rectangular button
  - Executes callback on click
  ```
  [ "Clicked!" print ; ] "Click Me" uiBtn
  ```

- **`uiRBtn`** `( 'callback "text" -- )` - Rounded corner button
  - 6 pixel corner radius

- **`uiCBtn`** `( 'callback "text" -- )` - Circular/pill button
  - Maximum corner rounding

- **`uiTBtn`** `( 'callback "text" align -- )` - Text-aligned button
  - Custom text alignment within button
  - Uses full cursor width/height

- **`uiNBtn`** `( 'callback "text" -- )` - Auto-width button
  - Button width matches text width + 4 pixels
  - Useful for toolbar buttons

---

## Input Widgets

### Sliders

- **`uiSliderf`** `( min max 'var -- )` - Fixed-point horizontal slider
  - Draggable slider for fixed-point values
  - Displays value as decimal
  ```
  0.0 1.0 'volume uiSliderf
  ```

- **`uiSlideri`** `( min max 'var -- )` - Integer horizontal slider
  - Integer value slider
  - Displays value as integer

- **`uiVSliderf`** `( min max 'var -- )` - Vertical fixed-point slider
- **`uiVSlideri`** `( min max 'var -- )` - Vertical integer slider

### Progress Bars

- **`uiProgressf`** `( min max 'var -- )` - Fixed-point progress bar
  - Non-interactive display of progress
  - Can be made interactive by enabling selection

- **`uiProgressi`** `( min max 'var -- )` - Integer progress bar

---

## Selection Widgets

### Checkboxes

- **`uiCheck`** `( 'var 'list -- )` - Multiple checkbox list
  - 'var': variable holding bitmask of selected items
  - 'list': null-terminated string list
  - Each line becomes one checkbox
  - Uses icons: 139 (checked), 138 (unchecked)
  ```
  #options 0
  [ "Option 1" 0
    "Option 2" 0
    "Option 3" 0 ]
  'options 'optionList uiCheck
  ```

### Radio Buttons

- **`uiRadio`** `( 'var 'list -- )` - Radio button group
  - 'var': variable holding selected index
  - 'list': null-terminated string list
  - Only one selection allowed
  - Uses icons: 137 (selected), 136 (unselected)
  ```
  #choice 0
  'choice 'choiceList uiRadio
  ```

---

## List and Tree Widgets

### List Widget

- **`uiList`** `( 'var maxlines 'list -- )` - Scrollable list
  - 'var': 8-byte structure [selection, scroll_offset]
  - maxlines: visible lines in viewport
  - 'list': null-terminated string list
  - Features:
    - Vertical scrolling
    - Mouse wheel support
    - Click to select
    - Keyboard navigation (up/down arrows)
  ```
  #listState 0 0
  'listState 10 'itemList uiList
  ```

### Tree Widget

- **`uiTree`** `( 'var maxlines 'list -- )` - Hierarchical tree view
  - Similar to uiList but supports hierarchy
  - List format: each line prefixed with level byte
    - Byte format: `$1f`:level, `$20`:has_children, `$80`:is_open
  - Collapsible/expandable nodes
  - Click to expand/collapse
  - Uses icons: 129 (collapsed), 130 (expanded)

---

## Combo Box

- **`uiCombo`** `( 'var 'list -- )` - Drop-down combo box
  - 'var': variable holding selected index
  - 'list': null-terminated string list
  - Shows selected item
  - Click to open dropdown list
  - Shows up to 6 items at once
  - Scrollable if more items
  ```
  #selected 0
  'selected 'countries uiCombo
  ```

---

## Text Input

- **`uiInputLine`** `( 'buffer maxlen -- )` - Single line text input
  - 'buffer': string buffer for input
  - maxlen: maximum character count
  - Features:
    - Cursor with insert/overwrite mode
    - Arrow key navigation
    - Backspace/Delete
    - Home/End keys
    - Tab for focus navigation
    - Enter to confirm
  - Keyboard shortcuts:
    - `<ins>`: Toggle insert/overwrite mode
    - `<le>/<ri>`: Move cursor
    - `<home>/<end>`: Jump to start/end
    - `<back>/<del>`: Delete characters
  ```
  #textbuf * 256
  'textbuf 255 uiInputLine
  ```

---

## Advanced Features

### Last Widget System

The library can save and restore the last widget for special behaviors:

- **`uiSaveLast`** `( x y w h 'vector -- )` - Save widget state
  - Used internally for popup widgets like combo boxes

- **`uiExitWidget`** `( -- )` - Exit last widget mode
  - Closes active popup/overlay widget

---

## Internal State

### Cursor Variables

```
cx, cy  | Current cursor position
cw, ch  | Current cursor dimensions
fx, fy  | Frame origin
fw, fh  | Frame dimensions
```

### Widget State Values

The `uiState` variable contains combined state:
- `$0f` mask: Mouse state (0-6)
  - 0: Normal (outside)
  - 1: Over (hovering)
  - 2: In (mouse down, first frame)
  - 3: Active (held down)
  - 4: Active outside (dragged out)
  - 5: Out (released outside)
  - 6: Click (released inside)
- `$10`: Focus gain
- `$20`: Has focus

---

## Example Usage

### Basic Layout

```r3forth
uiStart  | Begin frame

uiFull   | Use full screen
10 10 uiPading  | 10px padding

| Title
$ffffff sdlcolor
2 uiN  | Take 2 lines at top
"My Application" uiLabelC

| Content area
-100 uiN  | Take all but bottom 100px
colBack uiFill

| Buttons at bottom
100 uiS  | Take bottom 100px
3 1 uiGrid  | 3 columns, 1 row

0 0 uiAt
[ "OK clicked" print ; ] "OK" uiBtn

1 0 uiAt
[ "Cancel clicked" print ; ] "Cancel" uiBtn

uiEnd  | End frame
```

### Form with Multiple Widgets

```r3forth
#volume 0.5
#brightness 128
#soundEnabled 1
#quality 0

uiStart
uiFull
20 20 uiPading

| Sliders
"Volume" uiLabel
0.0 1.0 'volume uiSliderf

"Brightness" uiLabel
0 255 'brightness uiSlideri

| Checkbox
'soundEnabled "Enable Sound" 0 uiCheck

| Radio buttons
"Quality" uiLabel
'quality [ "Low" 0 "Medium" 0 "High" 0 ] uiRadio

uiEnd
```

### Grid Layout

```r3forth
uiStart
uiFull

3 3 uiGrid  | 3x3 grid

0 ( 9 <? 
    dup 3 /mod uiAt  | Calculate grid position
    colFill uiFill   | Draw background
    dup .d uiLabelC  | Show number
    1+ ) drop

uiEnd
```

### Nested Layouts

```r3forth
uiStart
uiFull

| Left panel
-300 uiO  | Take right 300px
uiPush    | Save layout

    "Left Panel" uiLabel
    | ... left panel content

uiPop     | Restore layout

| Right panel  
300 uiE   | Take remaining space
"Right Panel" uiLabel
| ... right panel content

uiEnd
```

---

## Notes

- **Immediate mode**: Widgets must be recreated every frame
- **State management**: Widget state stored externally (in user variables)
- **Focus order**: Determined by widget declaration order
- **ID system**: Automatic internal ID assignment based on call order
- **Tab navigation**: Supported by default in focusable widgets
- **Mouse wheel**: Supported in sliders and lists
- **Style changes**: Call style functions before widgets to apply
- **Performance**: Efficient for moderate widget counts (hundreds)
- **Font required**: Must load font with txfont library before using text
- **Color format**: Uses SDL2 color format `$AARRGGBB`

## Keyboard Modifiers

- `<shift>`: Detected automatically, stored in `keymd`
- `<tab>`: Advances focus to next widget
- `<shift+tab>`: Moves focus to previous widget
- `<ret>`: Activates focused widget
- Arrow keys: Navigate in lists, trees, and sliders

## Best Practices

1. **Always call uiStart/uiEnd** - Required for each frame
2. **Set layout first** - Use uiBox/uiFull before widgets
3. **Use uiPush/uiPop** - For nested layouts
4. **Set colors before drawing** - Style affects subsequent widgets
5. **Check uiEx?** - After interactive widgets to detect activation
6. **Store widget state externally** - Variables must persist between frames
7. **Consistent ordering** - Keep widget order same each frame for focus

