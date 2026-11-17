# r3forth `rimm/` — Immediate Mode GUI

RIMM is the immediate mode GUI of r3forth. It works with **many backends** (SDL2 render, OpenGL) and replaces the old `imm*` libraries (`immi`, `imcolor`, `imedit`, `imfiledlg`, `immdatetime`).

Source: [github.com/phreda4/r3/tree/main/r3/rimm](https://github.com/phreda4/r3/tree/main/r3/rimm)

## Contents

1. [Quick start](#quick-start)
2. [Files](#files)
3. [Frame loop](#frame-loop)
4. [Layout](#layout)
5. [Mouse and keyboard state](#mouse-and-keyboard-state)
6. [Widgets](#widgets)
7. [Theme and colors](#theme-and-colors)
8. [Extra widgets](#extra-widgets) — color, editor, file dialog, date
9. [Backends](#backends)
10. [Moving from the old imm libs](#moving-from-the-old-imm-libs)

---

## Quick start

Include the backend **first**, then the widgets you need.

```forth
^r3/rimm/rimmsdl.r3        | backend (SDL2). For OpenGL use rimmgl.r3
^r3/rimm/rimmwid.r3        | layout + theme + widgets

#font
#vol 0.5
#name * 64

:gui
	font txfont
	uiStart                       | begin frame
	4 4 uiPad
	22 uiN                        | top strip of 22 pixels
	"Hello" uiLabel
	uiRest
	0 1.0 'vol uiSliderf
	'name 64 uiInputLine
	'exit "Exit" uiBtn
	uiEnd ;                       | end frame

:main
	0 cls
	gui
	SDLredraw
	sdlkey >esc< =? ( exit ) drop ;

:
	"RIMM" 800 600 SDLinitR
	"media/ttf/Roboto-Medium.ttf" 18 txload 'font !
	'main SDLshow
	SDLquit ;
```

---

## Files

| File | What it does |
|---|---|
| `rimmsdl.r3` | Backend: SDL2 render (clip) |
| `rimmgl.r3` | Backend: OpenGL (`glgfx`) |
| `rimmcore.r3` | Layout, ids, mouse and keyboard state |
| `rimmtheme.r3` | Colors, shapes, skins, ready-made themes |
| `rimmicon.r3` | Icons drawn with lines (no font, no image) |
| `rimmwid.r3` | Widgets (includes core and theme) |
| `rimmcolor.r3` | Color picker |
| `rimmedit.r3` | Text area, text view, code editor |
| `rimmfile.r3` | File dialog |
| `rimmdate.r3` | Date field with calendar |

---

## Frame loop

Every frame, call `uiStart` before the widgets and `uiEnd` after them.
`uiEnd` draws the pop-ups (combo list, color picker, file dialog) over the rest.

```
::uiStart ( -- )              start of the frame: the frame is the whole screen
::uiEnd ( -- )                end of the frame, draws the open pop-up
::uiPopup? ( -- flag )        not 0 while a pop-up is open
```

---

## Layout

The **frame** is the area where widgets go. The **cursor box** `cx cy cw ch` is the place of the next widget.

```
##fx ##fy ##fw ##fh           frame
##cx ##cy ##cw ##ch           cursor box (current widget)
```

### Frame

```
::uiBox ( x y w h -- )        set the frame
::uiFull ( -- )               frame = whole screen
::uiWinBox ( -- x y w h )     the current frame
::uiPad ( x y -- )            padding inside the frame
::%cw ( frac -- px )          fraction of the frame width (1.0 = all)
::%ch ( frac -- px )          fraction of the frame height
::uiPush ( -- )               save the frame (16 levels)
::uiPop ( -- )                restore the frame
```

### Split the frame

Take a strip from the frame. The strip becomes the frame; the rest stays on the stack. A negative size means "all minus this".

```
::uiN ( px -- )               strip from the top
::uiS ( px -- )               strip from the bottom
::uiO ( px -- )               strip from the left
::uiE ( px -- )               strip from the right
::uiRest ( -- )               go back to the rest of the frame
```

### Rows and columns

Widgets go one per row. Use `uiCols` to fill cells line by line.

```
::uiRowH ( px -- )            row height (0 = follow the font)
::rh ( -- px )                current row height
::uiCols ( n -- )             n equal columns (1 = back to one column)
::uiColsW ( 'wts n -- )       n columns; weight > 0 = proportion, < 0 = pixels
::uiSpan ( n -- )             next widget takes n cells
::uiCol# ( -- n )             number of columns now
::uiLn ( -- )                 end of row
::uiLnEnd ( -- )              end the line of columns
::uiAdvH ( h -- )             widget done, go to the next cell or row
::ui.. ( -- )                 widget done (next cell or next row)
::uil.. ( -- )                one row down
::ui-- ( -- )                 separator line
```

### Grid

```
::uiGrid ( c r -- )           divide the frame in c columns by r rows
::uiAt ( x y -- )             cursor box at the grid cell x y
::uiTo ( w h -- )             size of the cursor box in cells
::uiNext ( -- )               next grid cell (along the rows)
::uiNextV ( -- )              next grid cell (down the columns)
```

### Draw words

All use the current draw color.

```
::uiFill ( -- )               fill the cursor box
::uiRect ( -- )               outline
::uiRFill ( r -- )            fill with rounded corners
::uiRRect ( r -- )            outline with rounded corners
::uiCFill ( -- )              fill as a capsule
::uiCRect ( -- )              outline as a capsule
::uiTex ( texture -- )        draw a texture in the box
::uiLineGrid ( -- )           grid lines (also uiLineGridV, uiLineGridH)
::uiClip ( -- )               clip to the interaction area
::uiUnclip ( -- )             remove the clip
::uiPanelBg ( -- )            panel background of the frame
```

The `uil...` versions (`uilFill`, `uilRFill`, `uilCFill`, `uilTex`, `uilRect`, `uilRRect`, `uilCRect`) draw over the interaction area instead of the cursor box.

### Text

```
::ttwrite ( "" -- )           text, left
::ttwritec ( "" -- )          text, centered
::ttwriter ( "" -- )          text, right
::ttinl ( "" -- )             left, with theme padding (inside fields)
::ttinr ( "" -- )             right, with theme padding
::uiLabel ( "" -- )           left text, then next cell
::uiLabelC ( "" -- )          centered text, then next cell
::uiLabelR ( "" -- )          right text, then next cell
::uiTlabel ( "" -- )          label as wide as its text (rows of widgets)
::uiText ( "" align -- )      wrapped text, align = $VH
```

---

## Mouse and keyboard state

`uiZone` defines the interaction area of a widget. After it, ask the state with these words; each runs its vector `'v` only when the condition is true.

```
::uiZone ( -- )               area = cursor box, one row high
::uiZoneL ( n -- )            area of n rows
::uiZoneW ( -- )              area = whole cursor box
::uiZoneBox ( x y w h -- )    area = this box
::uiBackBox ( -- )            restore the box saved by uiZoneBox

::uiOvr ( 'v -- )             mouse is over
::uiDwn ( 'v -- )             button pressed now
::uiSel ( 'v -- )             widget active (button held)
::uiClk ( 'v -- )             clicked
::uiUp ( 'v -- )              button released
::uiFocusIn ( 'v -- )         widget gets the keyboard focus
::uiFocus ( 'v -- )           widget keeps the focus
::uiEx? ( -- flag )           last widget was activated
::uiEx! ( -- )                mark the last widget as activated
```

### Focus and keys

```
::uiRefocus ( -- )            clear the focus
::uiFocus>> ( -- )            focus to the next widget
::uiFocus<< ( -- )            focus to the previous widget
::tabfocus ( -- )             Tab key action (Shift = backwards)
```

### Mouse zone (camera and the like)

```
::immBox ( x y w h -- )       set the zone
::immFull ( -- )              zone = whole screen
::immMouse ( -- state )       mouse state 0..6 of the zone
::immZone ( -- )              zone as interaction area
::uiPlace ( n -- )            drag and drop: the box is place n
```

Mouse state: 0 none, 1 over, 2 in, 3 active, 4 active outside, 5 out, 6 click.

---

## Widgets

`'var` is the address of a variable. `'list` is a list of strings ending in 0.

### Buttons

```
::uiBtn ( 'click "" -- )          button with text
::uiIBtn ( 'click icon -- )       button with icon (ICxxx)
::uiRBtn ( 'click "" -- )         rounded button
::uiCBtn ( 'click "" -- )         capsule button
::uiNBtn ( 'click "" -- )         button as wide as its text
::uiTBtn ( 'click "" align -- )   button with wrapped text
::uiTBtnH ( 'click "" align h -- )  same, with height in pixels
::uiBtnX ( 'click data 'content -- )  button with your own content
::ctLabel ( "" -- )               content: centered text
::ctIcon ( n -- )                 content: centered icon
```

### Sliders and bars

```
::uiSliderf ( min max 'var -- )       fixed point slider
::uiSlideri ( min max 'var -- )       integer slider
::uiSliderfL ( "name" min max 'var -- )   with name and value
::uiSlideriL ( "name" min max 'var -- )
::uiVSliderf ( min max 'var -- )      vertical
::uiVSlideri ( min max 'var -- )
::uiProgressf ( min max 'var -- )     progress bar (can be dragged)
::uiProgressi ( min max 'var -- )
```

### Choices

```
::uiToggle ( 'var "" -- )         on/off button
::uiCheck ( 'var 'list -- )       one check box per string (one bit each)
::uiRadio ( 'var 'list -- )       radio buttons, var = chosen number
::uiTabs ( 'var 'list -- )        tabs in a row
::uiCombo ( 'var 'list -- )       drop-down list (var has 2 cells)
```

### Lists and trees

```
::uiList ( 'var n 'list -- )      list box of n lines (var: selected, first line)
::uiTree ( 'var n 'list -- )      tree; each string starts with a byte:
                                  level in $1f, $20 has children, $80 open
::uiNindx ( n -- "" )             string n of the list being drawn
```

### Layout widgets

```
::uiSection ( 'var "" -- open )   folding header
::uiProps ( frac -- )             rows of two columns: name and value
```

### Text input

```
::uiInputLine ( 'buf max -- )     one line editor
```

---

## Theme and colors

A theme sets colors, corner radius, border, row height and padding.

```
::thDark ::thLight ::thBlender ::thGodot ::thMagica    ready-made themes
::uiTheme ( n -- )         theme by number (0 dark, 1 light, 2 blender, 3 godot, 4 magica)
::thNext ( -- )            next theme
::thNow ( -- n )           current theme number
```

### Color styles

Call one before a widget to color it.

```
::stInfo   cyan (default)       ::stDang   red
::stWarn   orange               ::stSucc   green
::stLink   blue                 ::stDark   dark gray
::stLigt   light gray           ::stColor ( rgb -- )   your color
::stTheme  accent of the theme
::stRad ( r -- )                corner radius (0 square, -1 capsule)
```

### Skins

Each kind of widget is drawn by a **skin**. A theme or your program can replace it.

```
::skin! ( 'vec kind -- )        replace the skin of a kind
::sk ( .. kind -- )             draw the skin over the interaction area
::skAt ( .. x y w h kind -- )   draw the skin in a box
::skFocus ( -- )                focus outline
```

Kinds: `skinBtn` `skinField` `skinCheck` `skinRadio` `skinSlide` `skinPanel` `skinTab` `skinScroll` `skinSect`.

### Icons

Icons are drawn with lines, so they work in any backend and size.

```
::uiIcon ( n x y size -- )      draw icon n
```

Names: `ICCHK` `ICX` `ICRIGHT` `ICDOWN` `ICLEFT` `ICUP` `ICPLUS` `ICMINUS`.

---

## Extra widgets

Include the file you need after `rimmwid.r3`.

### rimmcolor.r3 — color picker

```
::uiColor ( 'var -- )           color swatch; a click opens the picker ($RRGGBB)
::uiColorH ( 'var -- )          same, with the hex text
::color! ( rgb -- )             set the picker color
```

### rimmedit.r3 — text and code editor

Use a **monospace** font. Click the editor to give it the focus.

```
::uiTextArea ( 'buf max -- )        multiline text box
::uiTextView ( 'buf max -- )        read only (select and copy)
::uiCodeEdit ( 'buf max -- )        code editor: r3 colors, line numbers, status bar
::uiTextAreaH ( 'buf max h -- )     with height in pixels
::uiCodeEditH ( 'buf max h -- )
::uiEdit ( -- )                     the internal document (edram, edload, edsave)
::edattach ( 'buf max -- )          use this buffer as the document
::edtolf ( 'buf -- )                CR to LF, to use the text outside the editor
::edram ( -- )                      new empty document
::edload ( "file" -- )              load a file
::edsave ( -- )                     save the file
::edwin ( x y w h -- )              place of the internal editor
::edlinenum! ( 0/1 -- )             hide or show line numbers
```

Keys in the code editor: `Ctrl-F` find, `Ctrl-D` definition, `Ctrl-L` line numbers, `Ctrl-Z` / `Ctrl-Y` undo / redo.

### rimmfile.r3 — file dialog

```
::uiFileName ( 'buf max -- )    field with a file name; a click opens the dialog
::uiFileOpen ( 'buf max -- )    the file must exist
::uiFileSave ( 'buf max -- )    overwrite needs OK twice
::uiFileFilter ( "png bmp" -- ) show only these extensions ("" = all)
::uiFileFull ( -- "path" )      the current choice
```

`Esc` closes the dialog. The Hidden check shows files that start with a dot.

### rimmdate.r3 — date field

```
::uiDate ( 'var -- )            date field; a click opens a calendar
```

The variable is a `dt64` (see `datetime.r3`). 0 = no value (the calendar starts today).

---

## Backends

A backend gives the drawing words (`color`, `frect`, `rect`, `line`, `lineH`, `lineHg`, `fround`, text with `txfont`...) and the clip.

| | `rimmsdl.r3` | `rimmgl.r3` |
|---|---|---|
| Start | `SDLinitR` | `rimmGLini` |
| Fonts | `txload` (txfont.r3) | `txload` (gltxfont.r3), load after `rimmGLini` |
| Frame | `0 cls` ... `SDLredraw` | `GLcls fini` ... `fend GLUpdate` |

Both give the same clip words:

```
::gclip ( x y w h -- )          clip to the rectangle
::gclip0 ( -- )                 remove the clip
::gclipPush ( x y w h -- )      clip to the rectangle inside the current clip
::gclipPop ( -- )               go back (8 levels)
```

OpenGL frame:

```forth
GLcls fini
	uiStart  ...  uiEnd
fend GLUpdate
```

`rimmGLini ( "title" w h -- )` opens the window and prepares `glgfx`. If your program sets its own `SDLeventR`, call `fixFontResize` inside it.

---
