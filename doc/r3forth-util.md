# r3forth `util/` Library Reference

High-level utility libraries built on top of r3forth's core (`lib/`) libraries — object pools, sorting,
easing, animation timelines, fonts and text rendering, GUI widgets (both TTF-based `sdlgui.r3` and the
newer grid-based `immi.r3`), terminal UI, tile maps, 3D model loading, and simple text databases.

Source: [github.com/phreda4/r3/tree/main/r3/util](https://github.com/phreda4/r3/tree/main/r3/util)

Every word and stack signature below was checked directly against the current source in that repository.

## Contents

1. [arr8.r3](#arr8r3) — Fixed 8-value object pool
2. [arr16.r3](#arr16r3) — Fixed 16-value object pool with sort/map
3. [blist.r3](#blistr3) — Sorted byte list
4. [dlist.r3](#dlistr3) — FIFO deque
5. [heap.r3](#heapr3) — Min-heap priority queue
6. [hash2d.r3](#hash2dr3) — 2D spatial hash for collision
7. [sort.r3](#sortr3) — ShellSort variants
8. [sortradix.r3](#sortradixr3) — RadixSort 16/32/64-bit
9. [sortradixm.r3](#sortradixmr3) — RadixSort with offset keys
10. [penner.r3](#pennerr3) — 30 Penner easing functions
11. [varanim.r3](#varanimr3) — Timeline-based variable animator
12. [utfg.r3](#utfgr3) — 8×8 bitmap font terminal output
13. [bfont.r3](#bfontr3) — Fixed-width bitmap font (SDL2)
14. [pcfont.r3](#pcfontr3) — PC/DOS-style 16×32 font (SDL2)
15. [ttfont.r3](#ttfontr3) — TrueType font rendering (SDL2_ttf)
16. [txfont.r3](#txfontr3) — TrueType atlas font with pseudo-UTF8
17. [ttext.r3](#ttextr3) — Tilesheet-based terminal text (SDL2)
18. [textb.r3](#textbr3) — Wrapped text box renderer (SDL2+TTF)
19. [sdlgui.r3](#sdlguir3) — Immediate-mode GUI with TTF (SDL2)
20. [sdlbgui.r3](#sdlbguir3) — Immediate-mode GUI with bitmap font (SDL2)
21. [sdlfiledlg.r3](#sdlfiledlgr3) — File dialog (sdlgui-based)
22. [dlgcol.r3](#dlgcolr3) — Color picker dialog (SDL2)
23. [dlgfile.r3](#dlgfiler3) — File browser dialog (SDL2)
24. [immi.r3](#immir3) — Modern grid-based immediate-mode GUI (SDL2, v3)
25. [imcolor.r3](#imcolorr3) — Color selector widget for immi
26. [imedit.r3](#imeditr3) — Code editor with syntax highlight for immi
27. [imfiledlg.r3](#imfiledlgr3) — File dialog for immi
28. [immdatetime.r3](#immdatetimer3) — Calendar/datetime widget for immi
29. [tui.r3](#tuir3) — Text UI framework (terminal)
30. [tuiedit.r3](#tuieditr3) — Full text editor widget (terminal)
31. [vscreen.r3](#vscreenr3) — Virtual resolution with auto-scaling
32. [tilesheet.r3](#tilesheetr3) — Tile map with scrolling
33. [bmap.r3](#bmapr3) — Multi-layer tile map for games
34. [loadobj.r3](#loadobjr3) — Wavefront OBJ/MTL 3D model loader
35. [datetime.r3](#datetimer3) — Date/time formatting
36. [db2.r3](#db2r3) — Text database v2 (ASCII 29/30/31 separators)
37. [dbtxt.r3](#dbtxtr3) — Text database v1 (pipe/caret separators)
38. [filedirs.r3](#filedirsrr3) — Filesystem scanner for UI trees

---

### arr8.r3

Fixed object pool for 8-value (64-byte) objects. Object index 0 is reserved as "null".

**Dependencies:** `^r3/lib/mem.r3`

```
::p8.ini   ( cantidad list -- )   initialize pool with `cantidad` slots
::p8.clear ( list -- )            reset pool (keep allocation)

-- Allocation --
::p8!+   ( 'act list -- adr )   allocate next; 'act = optional init callback
::p8!    ( list -- adr )        allocate next (no callback)

-- Access --
::p8.nro  ( nro list -- adr )    get object address by index (from start)
::p8.last ( nro list -- adr )    get from end (reverse index)
::p8.cnt  ( list -- cnt )        current count of active objects

-- Operations --
::p8.cpy    ( adr 'list -- )      copy object adr into list
::p8.del    ( adr list -- )       delete object (swap with last)
::p8.draw   ( list -- )           call default draw for all
::p8.drawo  ( list -- )           call default draw (ordered)
::p8.mapv   ( 'vector list -- )   call vector for each object
::p8.mapd   ( 'vector list -- )   call vector for each (reverse)
::p8.mapi   ( 'vector fin ini list -- )  map over range [ini..fin]
::p8.deli   ( fin ini list -- )   delete range
```

---

### arr16.r3

Fixed object pool for 16-value (128-byte) objects. Like arr8 but larger objects with sorting and mapping.

**Dependencies:** `^r3/lib/mem.r3`

```
::p.ini    ( cantidad list -- )   initialize pool
::p.clear  ( list -- )            reset pool

-- Allocation --
::p!+  ( 'act list -- adr )   allocate with init callback
::p!   ( list -- adr )        allocate without callback

-- Access --
::p.adr  ( nro list -- adr )   get object address by index
::p.nro  ( adr list -- nro )   get index from address
::p.cnt  ( list -- cnt )       active object count

-- Operations --
::p.del    ( adr list -- )      delete object (swap with last)
::p.draw   ( list -- )          call draw for all objects
::p.drawo  ( list -- )          call draw (ordered)
::p.mapv   ( 'vector list -- )  call vector for each
::p.mapd   ( 'vector list -- )  call vector for each (desc)
::p.map2   ( 'vec 'list --- )   call 'vec with list

-- Sorting --
::p.sort   ( col 'list -- )     sort by column `col` ascending
::p.isort  ( col 'list -- )     sort by column `col` descending
```

---

### blist.r3

Ordered byte list (sorted insertion/lookup).

**Dependencies:** `^r3/lib/console.r3`

```
::blistdel  ( 'list 'from -- )   delete item 'from from list
::blist!    ( f 'list -- )       insert f into list (sorted)
::blist-    ( f 'list -- )       remove f from list
::blist@    ( 'list -- f/0 )     get first item (or 0)
::blist?    ( f 'list -- f/0 )   find f in list (0 if not found)
```

---

### dlist.r3

Double-ended deque / FIFO queue.

**Dependencies:** `^r3/lib/mem.r3`

```
::dc.ini   ( max 'dc -- )    initialize deque with max capacity
::dc.clear ( list -- )       clear deque
::dc?      ( list -- cnt )   current item count
::dcn@     ( n l -- v )      get item at index n
::dc@      ( list -- val )   peek front item
::dc!      ( val list -- )   enqueue (add to back)
::dc@-     ( list -- val )   dequeue (remove from front)
```

---

### heap.r3

Min-heap priority queue.

**Dependencies:** `^r3/lib/mem.r3`

```
::heapini  ( max 'h -- )    initialize heap with max capacity
::heap!    ( nodo 'h -- )   insert node (smaller value = higher priority)
::heap@    ( 'h -- nodo )   remove and return min-priority node
```

---

### hash2d.r3

2D spatial hash for fast proximity/collision queries.

**Dependencies:** `^r3/lib/mem.r3`

```
##checkmax 32   maximum check radius in pixels

::H2d.ini   ( maxobj -- )    initialize for maxobj objects
::H2d.clear ( -- )           clear all entries
::H2d.list  ( -- 'adr cnt )  get all active entries

::h2d+!  ( nro r x y -- )              insert object nro at (x,y) with radius r
::h2d!   ( x y zoom nro sizepixel/2 -- x y zoom )   draw + collision update
```

---

### sort.r3

ShellSort with optimal gaps. Input arrays are key-value pairs.

**Dependencies:** `^r3/lib/math.r3`

```
::shellsort   ( len lista -- )   sort by key ascending (array: key value key value...)
::shellsort2  ( len lista -- )   sort by value ascending (array: value key value key...)
::shellsort1  ( len lista -- )   sort interleaved key|value
::sortstr     ( len lista -- )   sort by string pointer (pstr-value pairs)
```

---

### sortradix.r3

O(n) RadixSort for fixed-width integer keys. Sorts key-value pair arrays.

**Dependencies:** `^r3/lib/mem.r3`

```
::radixsort32  ( cnt '2array -- )   sort by 32-bit key
::radixsort16  ( cnt '2array -- )   sort by 16-bit key
::radixsort64  ( cnt '2array -- )   sort by 64-bit key
```

The `'2array` points to an array of (key, value) pairs, each 2 cells.

---

### sortradixm.r3

RadixSort variant with offset keys.

**Dependencies:** `^r3/lib/mem.r3`

```
::radixsort   ( cnt 'array -- )    sort with default offset
::radixsortm  ( cnt 'array -- )    sort with modified offset keys
```

---

### penner.r3

30 Penner easing functions in 48.16 fixed-point. Input `t` is in range `[0.0 .. 1.0]` (fixed-point), output is in `[0.0 .. 1.0]`.

**Dependencies:** `^r3/lib/math.r3`

```
-- Linear --
::Lineal         ( t. -- t. )

-- Quadratic --
::Quad_In        ::Quad_Out        ::Quad_InOut

-- Cubic --
::Cub_In         ::Cub_Out         ::Cub_InOut

-- Quartic --
::Quar_In        ::Quar_Out        ::Quar_InOut

-- Quintic --
::Quin_In        ::Quin_Out        ::Quin_InOut

-- Sinusoidal --
::Sin_In         ::Sin_Out         ::Sin_InOut

-- Exponential --
::Exp_In         ::Exp_Out         ::Exp_InOut

-- Circular --
::Cir_In         ::Cir_Out         ::Cir_InOut

-- Elastic --
::Ela_In         ::Ela_Out         ::Ela_InOut

-- Back (overshoot) --
::Bac_In         ::Bac_Out         ::Bac_InOut

-- Bounce --
::Bou_In         ::Bou_Out         ::Bou_InOut

-- Dispatch table --
##easet 0        pointer to ease function table
::ease   ( t. nro -- t'. )   apply ease function by index
::easem  ( t. nro -- t'. )   apply ease (mirror/inverse variant)

-- Interpolation --
::catmullRom  ( p0 p1 p2 p3 t. -- v. )   Catmull-Rom spline interpolation
```

---

### varanim.r3

Timeline-based variable animator. Drives values from `ini` to `fin` over time using a Penner ease.

**Dependencies:** `^r3/lib/mem.r3`, `^r3/lib/color.r3`, `^r3/util/penner.r3`

```
-- Global State --
##deltatime     time delta for current frame (ms)

-- Setup --
::vareset     ( -- )           reset all animations
::vaini       ( max -- )       initialize with max simultaneous animations
::vaempty     ( -- )           clear all active animations
::vkillgroup ( group -- )     clear all group events
::vkillvar    ( 'var -- )      clear all var events

-- Update --
::vupdate   ( -- )           advance all animations (call each frame)

-- Add Animations --
::+vanim    ( 'var ini fin ease dur. start -- )   animate scalar variable
::+vboxanim ( 'var fin ini ease dur. start -- )   animate scalar (reversed params)
::+vxyanim  ( 'var ini fin ease dur. start -- )   animate packed XY value
::+vcolanim ( 'var ini fin ease dur. start -- )   animate packed color
::+vexe     ( 'vector start -- )                  execute vector at time start
::+vvexe    ( v 'vector start -- )                execute with value
::+vvvexe   ( v v 'vector start -- )              execute with two values

-- with group (0..15)
::+vanimg    ( 'var ini fin ease dur. start gr -- )   animate scalar variable
::+vboxanimg ( 'var fin ini ease dur. start gr -- )   animate scalar (reversed params)
::+vxyanimg  ( 'var ini fin ease dur. start gr -- )   animate packed XY value
::+vcolanimg ( 'var ini fin ease dur. start gr -- )   animate packed color
::+vexeg     ( 'vector start gr -- )                  execute vector at time start
::+vvexeg    ( v 'vector start gr -- )                execute with value
::+vvvexeg   ( v v 'vector start gr -- )              execute with two values

-- Packed Value Helpers --
::64xy      ( b -- x y )         unpack XY from 64-bit value
::64wh      ( b -- w h )         unpack WH
::64xywh    ( b -- x y w h )     unpack X Y W H
::xywh64    ( x y w h -- b )     pack X Y W H
::64xyrz    ( b -- x y r z )     unpack X Y Rotation Z
::xyrz64    ( x y r z -- b )     pack X Y Rotation Z
::64box     ( b adr -- )         unpack box to address
::32xy      ( b -- x y )         unpack XY from 32-bit value
::xy32      ( x y -- b )         pack XY into 32-bit value
```

---

### utfg.r3

8×8 bitmap Unicode font for terminal output. Outputs to console buffer via `.write`.

**Dependencies:** `^r3/lib/console.r3`

```
-- Character Output --
::.xwrite ( str -- )    write string to terminal using bitmap font
::.awrite ( str -- )    write string (alternate mode)

-- Line Drawing --
::.vline  ( h -- )      draw vertical line h chars tall
::.hline  ( w -- )      draw horizontal line w chars wide
::.vlined ( h -- )      draw double vertical line
::.hlined ( w -- )      draw double horizontal line

-- Box Drawing --
::.boxl   ( x y w h -- )   draw box (single line)
::.boxc   ( x y w h -- )   draw box (corner style)
::.boxd   ( x y w h -- )   draw box (double line)
::.boxf   ( -- )            fill current box area

-- Text Alignment --
::lalign  ( cnt str -- )   left-align string in cnt columns
::calign  ( cnt str -- )   center-align
::ralign  ( cnt str -- )   right-align
::lwrite  ( w "str" -- )   left-aligned write in width w
::cwrite  ( w "str" -- )   centered write
::rwrite  ( w "str" -- )   right-aligned write
::xalign  ( $VH -- )       set alignment ($V=vertical bits, $H=horizontal bits)
::xwrite  ( w "str" -- )   write with current alignment
::xText   ( w h x y "" -- )  draw aligned text in box
```

---

### bfont.r3

Fixed-width bitmap font rendered to SDL2 from an image file.

**Dependencies:** `^r3/lib/sdl2gfx.r3`, `^r3/lib/sdl2image.r3`

```
##wp ##hp   glyph width, height (pixels)

-- Setup --
::bmfont  ( w h "filename" -- )   load font image (w×h pixels per glyph)
::bfont1  ( -- )                   activate font 1
::bfont2  ( -- )                   activate font 2

-- Colors --
::bcolor  ( rrggbb -- )    set font render color
::bfbox   ( -- )           fill background box
::bbox    ( -- )           draw background box
::bbox2   ( -- )           alternate background box

-- Cursor Positioning --
::bat    ( x y -- )        set pixel position
::ccx    ( -- x )          current cursor x (pixel)
::ccy    ( -- y )          current cursor y (pixel)
::gotoxy ( x y -- )        move cursor in character cells
::gotox  ( x -- )          move cursor to column (char cells)

-- Rendering --
::bemit       ( ascii -- )    draw single character
::bprint      ( -- )          print using format string from stack (like printf)
::bprintd     ( -- )          print double-size
::bprint2     ( -- )          alternate print
::bemits      ( "" -- )       print string
::bemitsd     ( "" -- )       print string double-size
::bemits2     ( "" -- )       alternate string print
::bprintz     ( .. "" size -- ) print at pixel size
::bemitsz     ( "" size -- )  print string at size
::bfillemit   ( "" -- "" )    print with fill
::bfcemit     ( cnt -- )      fill + emit count chars
::bcr         ( -- )           carriage return
::bcr2        ( -- )           double carriage return
::bcrz        ( size -- )      CR for given size
::bsp         ( -- )           space
::bnsp        ( n -- )         n spaces

-- Measurement --
::bsize  ( "" -- "" w h )    get string pixel dimensions
::bpos   ( -- x y )          get cursor position
::brect  ( "" -- "" x y w h ) get bounding rect
::bsrcsize ( x y w h -- x y w h )  source size clamp

-- Cursor Display --
::bcursor    ( n -- )    draw cursor of style n
::bcursori   ( n -- )    draw inverted cursor
::bcursor2   ( n -- )    draw alternate cursor
::bcursori2  ( n -- )    draw alternate inverted cursor
```

---

### pcfont.r3

PC/DOS-style font (16×32 grid per image) for SDL2.

**Dependencies:** `^r3/lib/sdl2gfx.r3`, `^r3/lib/sdl2image.r3`

Similar API to bfont.r3 but for PC-font-style rendering. Key words:

```
::pcfont  ( -- )           activate PC font
::pccolor ( rrggbb -- )    set color
::pcemit  ( ascii -- )     draw character
::pcprint ( -- )           print formatted
::pcemits ( "" -- )        print string
::pcat    ( x y -- )       set position
::gotoxy  ( x y -- )       move cursor
::gotox   ( x -- )         move to column
::pccr    ( -- )           carriage return
::pcsp    ( -- )           space
::pcnsp   ( n -- )         n spaces
::pcsize  ( "" -- "" w h ) measure string
::pcrect  ( "" -- "" x y w h )  bounding rect
::pcpos   ( -- x y )       cursor position
::pccursor   ( n -- )      draw cursor
::pccursori  ( n -- )      inverted cursor
::pcfbox  ( -- )           fill box
::pcbox   ( -- )           outline box
::pcbox2  ( -- )           alternate box
::pcfillline ( x y w h -- ) fill horizontal band
::pcprintz   ( .. "" size -- )  print at size
::pcemitsz   ( "" size -- )  print string at size
```

---

### ttfont.r3

TrueType font rendering for SDL2 using SDL2_ttf.

**Dependencies:** `^r3/lib/sdl2gfx.r3`, `^r3/lib/sdl2ttf.r3`

```
##ttx ##tty   current text cursor position

::ttcolor    ( rrggbb -- )        set text color
::ttfont!    ( font -- )          set active TTF font handle
::ttprint    ( "" -- )            print formatted text at (ttx,tty)
::ttemits    ( "" -- )            print string
::ttat       ( x y -- )           set cursor position
::+ttat      ( dx dy -- )         move cursor by delta
::ttsize     ( "" -- "" w h )     measure string dimensions
::ttcursor   ( str strcur -- str ) draw cursor at character position
::ttcursori  ( str strcur -- str ) draw inverted cursor
::ttrect     ( "" -- "" x y w h ) get bounding rect
```

---

### txfont.r3

TrueType font atlas renderer with pseudo-UTF8 support and glyph caching.

**Dependencies:** `^r3/lib/sdl2gfx.r3`, `^r3/lib/sdl2ttf.r3`

```
-- Font Loading --
::txloadwicon ( "font" size -- nfont )   load font including icon glyphs
::txload      ( "font" size -- nfont )   load font
::txfont      ( font -- )                set active font
::txfont@     ( -- font )                get current font

-- Color --
::txrgb  ( c -- )    set text color

-- Measurement --
::txcw   ( car -- width )    width of single character
::txw    ( "" -- "" width )  width of string
::txch   ( car -- height )   height of character
::txh    ( -- height )       current line height

-- Positioning --
::txat   ( x y -- )     set cursor
::tx+at  ( x y -- )     move cursor by delta
::txpos  ( -- x y )     get cursor

-- Rendering --
::txemit   ( utf8' -- )       draw single UTF-8 character
::txwrite  ( "" -- )          draw string
::txemitr  ( "" -- )          draw string (right-to-left)
::txprint  ( .. "" -- )       draw formatted string
::txprintr ( .. "" -- )       draw formatted (right-to-left)
::txcur    ( str cur -- )     draw cursor at position
::txcuri   ( str cur -- )     draw inverted cursor
::lwrite   ( w "str" -- )     left-aligned in width
::cwrite   ( w "str" -- )     centered in width
::rwrite   ( w "str" -- )     right-aligned in width
::txalign  ( $VH -- )         set alignment flags
::txText   ( w h x y "" -- )  draw aligned text in box
```

---

### ttext.r3

Tilesheet-based terminal text renderer for SDL2. Uses a sprite sheet for characters.

**Dependencies:** `^r3/lib/sdl2gfx.r3`, `^r3/lib/sdl2image.r3`

```
##advx ##advy   character advance width/height

-- Font Setup --
::tfnt  ( size w h "filename" -- )  load tilesheet font
::tini  ( -- )                       initialize/reset state
::tsize ( zoom -- )                  set display zoom

-- Colors / Palette --
::trgb  ( c -- )     set color from 24-bit RGB
::tpal  ( c -- rgb ) get palette entry c
::tcol  ( c -- )     set color from palette index
::tfbox ( -- )       fill background box
::tbox  ( -- )       draw background box

-- Positioning --
::tat   ( x y -- )    set cursor (pixel)
::tatx  ( x -- )      set x only
::txy   ( x y -- )    set cursor (tile grid)
::tx    ( x -- )      set x (tile grid)
::tcx   ( -- x )      cursor x (pixel)
::tcy   ( -- y )      cursor y (pixel)
::tpos  ( -- x y )    get cursor position
::tcr   ( -- )        carriage return
::tsp   ( -- )        space
::tnsp  ( n -- )      n spaces

-- Rendering --
::temit  ( ascii -- )    draw single character
::tprint ( -- )          print formatted (uses stack)
::temits ( "" -- )       print string

-- Measurement --
::tsbox  ( "" -- "" w h )       string dimensions
::trect  ( "" -- "" x y w h )   bounding rect
::tsrcsize ( x y w h -- x y w h ) source size for tilemap

-- Cursor Rendering --
::tcursor   ( n -- )    draw cursor style n
::tcursori  ( n -- )    inverted cursor
```

---

### textb.r3

Renders text into a box with word wrapping, color, and offset parameters.

**Dependencies:** `^r3/lib/math.r3`, `^r3/lib/color.r3`, `^r3/lib/sdl2gfx.r3`, `^r3/lib/sdl2ttf.r3`

```
::textbox ( str $colb-colo-ofvh-colf w h font -- texture )
```

Parameters: `str`=text string, `$colb`=background color, `$colo`=text outline color, `$ofvh`=packed vertical/horizontal offset, `$colf`=foreground color, `w h`=box dimensions, `font`=TTF font handle. Returns SDL texture.

---

### sdlgui.r3

Immediate-mode GUI framework with TrueType font rendering for SDL2.

**Dependencies:** `^r3/lib/gui.r3`, `^r3/lib/sdl2gfx.r3`, `^r3/util/ttfont.r3`

#### Theme Variables
```
##padx 2  ##pady 2         padding between widgets
##curx 10  ##cury 10        current cursor position
##boxw 100  ##boxh 20       default widget size
##immcolorwin  $666666      window background color
##immcolortwin $444444      title bar background color
##immcolortex  $ffffff      text color
##immcolorbtn  $0000ff      button color
```

#### Setup and Layout
```
::immgui    ( -- )            initialize GUI state each frame
::immSDL    ( font -- )       initialize with TTF font
::immat     ( x y -- )        set cursor position
::immat+    ( dx dy -- )      move cursor by delta
::immbox    ( w h -- )        set widget size
::immfont!  ( font -- )       change active font
::immpad!   ( px py -- )      set padding
::immwinxy  ( x y -- )        set window origin + update cursor
::imm>>     ( -- )            indent right by box width
::imm<<     ( -- )            unindent
::immdn     ( -- )            move cursor down one row
::immcr     ( -- )            carriage return (new row)
::immln     ( -- )            new line
::plgui     ( -- )            placeholder layout
::plxywh    ( -- )            placeholder x y w h

-- Cursor Save/Restore --
::immcur    ( x y w h -- )   set cursor state
::immcur>   ( -- cur )       save cursor
::imm>cur   ( cur -- )       restore cursor

::immwidth  ( w -- )          override widget width
```

#### Widget Words
```
::immlabel   ( "" -- )      display text label
::immlabelc  ( "" -- )      centered label
::immlabelr  ( "" -- )      right-aligned label
::imm.       ( "" -- )      print text inline
::immStrC    ( "" -- )      centered string
::immListBox ( lines -- )   scrollable list box
::immback    ( color -- )   filled color background
::immblabel  ( "" -- )      bold label
::immicon    ( nro x y -- ) draw icon by number at offset
::immiconb   ( nro -- )     draw icon (block style)
::immbtn     ( 'click "" -- )   button; executes 'click on click
::immibtn    ( 'click nro -- )  icon button
::immtbtn    ( 'click "" -- )   toggle button
::immebtn    ( 'click "" -- )   edit-style button
::immzone    ( 'click -- )      clickable zone (no visual)
::immSliderf ( 0.0 1.0 'value -- )  float slider [min..max]
::immSlideri ( 0 255 'value -- )    integer slider
::immCheck   ( 'val "opt1|opt2" -- ) checkbox group
::immScrollv ( 0 max 'value -- )    vertical scroll bar
::immRadio   ( 'val "opt1|opt2|opt3" -- ) radio button group
::immCombo   ( 'val "opt1|opt2|opt3" -- ) combo/dropdown
::immInputLine  ( 'buff max -- )    single-line text input
::immInputInt   ( 'var -- )         integer input
```

#### Window Management
```
::immwin!   ( win -- )        set window pointer
::immwin    ( 'win -- 0/1 )   begin window (returns 1 if visible)
::immnowin  ( xini yini w h -- )  window without title bar
::immwinbottom ( ywin -- )    pin window to bottom
::winexit   ( -- )            close current window
::immRedraw ( -- )            force redraw
::immwins   ( -- )            end of window frame
```

---

### sdlbgui.r3

Immediate-mode GUI framework using bitmap font instead of TTF.

**Dependencies:** `^r3/lib/gui.r3`, `^r3/lib/sdl2gfx.r3`, `^r3/lib/input.r3`

Same widget API as sdlgui.r3 but renders with bfont. Key differences: no `immfont!`, no `immSDL` — uses preloaded bitmap font. Has `immInputLine2` (two-line input variant).

---

### sdlfiledlg.r3

File open/save dialog using sdlgui.r3.

**Dependencies:** `^r3/util/sdlgui.r3`

```
::immlist       ( cnt -- )           render file list (cnt visible lines)
::filedlgini    ( -- )               initialize file dialog state
::immfileload   ( 'vecload 'file -- ) show load dialog; calls 'vecload on confirm
::immfilesave   ( 'vecload 'file -- ) show save dialog; calls 'vecload on confirm
::fullfilename  ( -- )               push full path to stack
```

---

### dlgcol.r3

Interactive color picker dialog for SDL2.

**Dependencies:** `^r3/lib/sdl2gfx.r3`, `^r3/lib/color.r3`, `^r3/lib/gui.r3`, `^r3/util/bfont.r3`

```
##colord 0        currently selected color

::color!        ( color -- )       set current color
::dlgColor      ( x y -- )         render color picker at x,y
::dlgColorIni   ( -- )             initialize picker state
::xydlgColor!   ( x y -- )         set picker position
```

---

### dlgfile.r3

File browser dialog for SDL2 (uses gui.r3 input system).

**Dependencies:** `^r3/lib/sdl2gfx.r3`, `^r3/lib/gui.r3`, `^r3/lib/input.r3`

```
::dlgFileLoad  ( -- fn/0 )          show file open dialog; returns filename or 0
::dlgFileSave  ( -- fn/0 )          show file save dialog
::dlgSetPath   ( "path" -- )        set initial directory
```

---

### immi.r3

Modern grid-layout immediate-mode GUI for SDL2 (version 3, 2025). Uses txfont for rendering.

**Dependencies:** `^r3/lib/sdl2gfx.r3`, `^r3/util/txfont.r3`

#### Layout System
The layout cursor `(cx, cy, cw, ch)` tracks current widget position. The frame stack allows push/pop for nested layouts.

```
##cx ##cy ##cw ##ch    current widget cursor (position + size)
::%cw  ( -- w )        percent of frame width
::%ch  ( -- h )        percent of frame height

-- Frame Management --
::uiBox     ( x y w h -- )   set frame
::uiFull    ( -- )            fill entire window
::uiPush    ( -- )            push frame state
::uiPop     ( -- )            pop frame state
::uiRest    ( -- )            restore frame
::uiPading  ( x y -- )       set padding
::uiAt      ( x y -- )       absolute position within frame
::uiTo      ( w h -- )       set widget size

-- Splits (divide current frame) --
::uiN  ( lines -- )    take N lines from top
::uiS  ( lines -- )    take N lines from bottom
::uiE  ( cols -- )     take N columns from right
::uiO  ( cols -- )     take N columns from left
::uiGrid ( c r -- )    divide into grid (c columns, r rows)
::uiNext   ( -- )      advance to next grid cell
::uiNextV  ( -- )      advance vertically

-- Input State Queries --
::uiEx?    ( -- 0/1 )   mouse over?
::uiOvr    ( 'v -- )    execute if mouse over
::uiDwn    ( 'v -- )    execute if mouse down in widget
::uiSel    ( 'v -- )    execute if selected
::uiClk    ( 'v -- )    execute if clicked
::uiUp     ( 'v -- )    execute on mouse release
::uiFocusIn ( 'v -- )   execute when focus enters
::uiFocus   ( 'v -- )   execute while focused

-- Frame Lifecycle --
::uiStart      ( -- )    begin UI frame
::uiEnd        ( -- )    end UI frame
::uiZone       ( -- )    create interaction zone (cx cy cw th)
::uiZoneL      ( n -- )  zone spanning n lines
::uiZoneW      ( -- )    zone filling cw×ch
::uiZoneBox    ( x y w h -- )  explicit zone rect
::uiSaveLast   ( x y w h 'v -- ) save last zone dimensions
::uiBackBox    ( -- )    draw background box
::uiExitWidget ( -- )    early exit from widget
::uiPlace      ( n -- )  place widget at grid position n
```

#### Focus
```
::uiRefocus     ( -- )    reset focus
::uiFocus>>     ( -- )    move to next focusable
::uiFocus<<     ( -- )    move to previous
::tabfocus      ( -- )    advance focus on Tab key
```

#### Drawing Helpers
```
::uiFill     ( -- )     fill cx cy cw ch
::uiRect     ( -- )     outline cx cy cw ch
::uiRFill    ( -- )     rounded filled
::uiRRect    ( -- )     rounded outline
::uiCRect    ( -- )     circle outline (uses min of w,h)
::uiCFill    ( -- )     circle filled
::uiTex      ( tex -- ) draw texture in widget area
::uiWinBox   ( -- x y w h )  window bounds
::uiLineGridV ( -- )    draw vertical grid lines
::uiLineGridH ( -- )    draw horizontal grid lines
::uiLineGrid  ( -- )    draw both grid lines
```

#### Status Styles
```
::stDang ( -- )   danger style (red)
::stWarn ( -- )   warning style (amber)
::stSucc ( -- )   success style (green)
::stInfo ( -- )   info style (blue)
::stLink ( -- )   link style
::stDark ( -- )   dark style
::stLigt ( -- )   light/white style
```

#### Widgets
```
-- Labels and Text --
::uiTlabel   ( -- )            text label from stack
::uiLabel    ( -- )            centered label
::uiLabelC   ( -- )            explicitly centered
::uiLabelR   ( -- )            right-aligned
::uiText     ( "" align -- )   text with alignment
::ttwrite    ( "text" -- )     write text (left)
::ttwritec   ( "text" -- )     write centered
::ttwriter   ( "text" -- )     write right

-- Buttons --
::uiBtn   ( 'click "" -- )    standard button
::uiRBtn  ( 'click "" -- )    rounded button
::uiCBtn  ( 'click "" -- )    circular button
::uiTBtn  ( 'click "" align -- )  text button with alignment
::uiNBtn  ( v "" -- )         button width from text

-- Input --
::uiInputLine  ( 'buff max -- )   single-line text input
::uiCheck      ( 'var 'list -- )  checkbox (list = option strings)
::uiRadio      ( 'var 'list -- )  radio group
::uiCombo      ( 'var 'list -- )  combo box / dropdown
::uiList       ( 'var cntl 'list -- ) scrollable list
::uiTree       ( 'var cntl list -- ) collapsible tree
::uiNindx      ( n -- str )        get list item string n

-- Sliders and Progress --
::uiSliderf    ( 0.0 1.0 'value -- )   horizontal float slider
::uiSlideri    ( 0 255 'value -- )     horizontal integer slider
::uiVSliderf   ( 0.0 1.0 'value -- )  vertical float slider
::uiVSlideri   ( 0 255 'value -- )    vertical integer slider
::uiProgressf  ( 0.0 1.0 'value -- )  float progress bar
::uiProgressi  ( 0 255 'value -- )    integer progress bar
```

> **Note:** `immi.r3` (v3) is single-window/full-screen — it has no `immwin`/`immnowin`-style multi-window API. That API (`immwin`, `immwin!`, `immnowin`, `winexit`, `immRedraw`, `immwins`, `immSDL`, `immblabel`, `immicon`, `immiconb`, `immwidth`, etc.) belongs to `sdlgui.r3`, which is documented in its own section above. An earlier version of this reference mistakenly duplicated that list here.

---

### imcolor.r3

Color selector widget for immi.

**Dependencies:** `^r3/lib/color.r3`, `^r3/util/immi.r3`

```
::color!     ( color -- )    set current color
::uiColor    ( 'var -- )     full color selector widget (HSV + RGB sliders)
::uiColorH   ( 'var -- )     compact horizontal color selector
```

---

### imedit.r3

Code editor widget for immi with syntax highlighting and marks.

**Dependencies:** `^r3/lib/parse.r3`, `^r3/lib/color.r3`, `^r3/util/immi.r3`

```
##ycursor ##xcursor    cursor row, column
##edfilename * 1024    current file path
##inisel               selection start
##finsel               selection end
##fuente               editable text buffer
##fuente>              cursor pointer into buffer

-- Syntax Marks --
::clearmark   ( -- )               clear all syntax marks
::addmark     ( -- )               add mark at current position
::addsrcmark  ( src color -- )     add colored mark
::showmark    ( -- )               render marks

-- Editor Display --
::edcodedraw  ( -- )    draw code with syntax highlighting
::edfill      ( -- )    fill editor background
::edtoolbar   ( -- )    render editor toolbar

-- Focus --
::edfocus     ( -- )    interactive code editor (focused)
::edfocusro   ( -- )    read-only editor

-- Editor RAM Management --
::edram       ( -- )    allocate editor RAM

-- Widget Setup --
::edwin      ( x y w h -- )  set editor window position/size
::edloadmem  ( "" -- )       load text from string into editor
::edload     ( "" -- )       load file into editor
::edsave     ( -- )          save editor contents to file
```

---

### imfiledlg.r3

File open/save dialog for immi.

**Dependencies:** `^r3/util/immi.r3`

```
::immfileload  ( 'vecload 'file -- )  show load dialog
::immfilesave  ( 'vecload 'file -- )  show save dialog
::fullfilename ( -- )                 push current full path
::uiFileName   ( 'var -- )            file name input widget
```

---

### immdatetime.r3

Calendar and time picker widgets for immi.

**Dependencies:** `^r3/lib/jul.r3`, `^r3/util/immi.r3`, `^r3/util/datetime.r3`

```
::uiDateTime  ( 'var -- )   full date+time picker widget
::uiDate      ( 'var -- )   date-only calendar widget
::uiTime      ( 'var -- )   time-only picker widget
```

The variable stores packed date/time as a 64-bit value; use `datetime.r3` words to interpret it.

---

### tui.r3

Text UI layout framework for terminal interfaces.

**Dependencies:** `^r3/lib/console.r3`, `^r3/util/utfg.r3`

#### Frame Layout
A "frame" defines a rectangular region of the terminal. Frames can be split and nested.

```
##fx ##fy ##fw ##fh   current frame (x y width height)

-- Frame Setup --
::flx!     ( x y w h -- )   set frame
::flx      ( -- )            restore frame from stack
::flxpush  ( -- )            push current frame
::flxpop   ( -- )            pop frame
::flxRest  ( -- )            restore last
::flxvalid? ( -- 0 )         0 = frame is not valid

-- Frame Splits --
::flxN  ( lines -- )   take from top
::flxS  ( lines -- )   take from bottom
::flxE  ( cols -- )    take from right
::flxO  ( cols -- )    take from left
::fw%   ( -- w. )      percent of frame width (48.16)
::fh%   ( -- h. )      percent of frame height

-- Utilities --
::flpad  ( x y -- )    add padding to frame
::flcr   ( -- )        carriage return within frame
::flin?  ( x y -- f )  is x,y inside current frame?
::flin?1 ( x y -- f )  inside? (alternate)
```

#### Event Flags
```
##uikey            current key code

::exit    ( -- )   request application exit
::tuX?    ( -- f ) check for pending action (local flag)
::tuR!    ( -- )   request redraw
::tuC!    ( -- )   enable cursor
```

#### Main Loop
```
::tui         ( -- )           run TUI event loop
::onTui       ( 'vector -- )   set main TUI handler
::onTuia      ( 'vector -- )   set TUI handler (alternate, no clear)
::tuiw        ( -- flag )      is current widget active? (interactive zone)
::tuiw1       ( -- flag )      single-line interactive zone
::tuif        ( -- flag )      is focused?
::tuRefocus   ( -- )           reset focus
```

#### Window Drawing
```
::.wfill    ( -- )             fill current frame
::.wborde   ( -- )             single-line border
::.wborded  ( -- )             double-line border
::.wbordec  ( -- )             corner-style border
::.wtitle   ( place "" -- )    draw title in frame
::tuWin     ( -- )             draw window (border+fill)
::tuWina    ( -- )             draw window (no fill)
::.tdebug   ( -- )             show debug info
```

#### Widgets
```
-- Buttons and Labels --
::tuTBtn   ( 'ev "" -- )      toggle button
::tuBtn    ( -- )             standard button
::tuLabel  ( "" -- )          left-aligned label
::tuLabelC ( "" -- )          centered label
::tuLabelR ( "" -- )          right-aligned label
::tuText   ( "" align -- )    text with alignment

-- Lists --
::tuList      ( 'var list -- )    scrollable list
::tuTree      ( 'var list -- )    collapsible tree
::uiNindx     ( n -- str )        get list item n

-- Input --
::tuInputLine ( 'buff max -- )   single-line text input
::tuCheck     ( 'var "label" -- ) checkbox
::tuRadio     ( n 'var "label" -- ) radio button (option n)
::tuSlider    ( 'var min max -- )  slider
::tuProgress  ( percent -- )      progress bar (0..100)

-- Write helpers --
::xwrite!       ( -- )    reset write state
::xwrite.reset  ( -- )    reset accumulated write
##padi>                   write start offset

```

---

### tuiedit.r3

Full-featured text editor widget for TUI framework. Supports selection, clipboard, and undo.

**Dependencies:** `^r3/util/tui.r3`, `^r3/lib/clipboard.r3`

```
##filename * 1024     current file path
##fuente              text buffer pointer
##fuente>             cursor pointer
##$fuente             end of text pointer

-- Cursor Control --
::tuiecursor! ( cursor -- )   set cursor to pointer
::tuipos!     ( pos -- )      set cursor to integer position

-- Hash / Change Detection --
::editfasthash ( -- fh )      compute fast hash of text (change detection)

-- Key Handlers --
::tueKeyMove  ( -- )    process cursor movement keys

-- Display --
::tuEditShowCursor ( -- )   display cursor
::tuecursor.       ( -- )   render cursor indicator

-- Editor Modes --
::tuEditCode     ( -- )    interactive code editor (normal fonts)
::tuReadCode     ( -- )    read-only code display
::tuEditCodeMono ( -- )    interactive code editor (monospace)
::tuReadCodeMono ( -- )    read-only monospace display

-- File Operations --
::TuLoadMem    ( "" -- )    load text from string
::TuLoadMemC   ( "" -- )    load text (already sanitized)
::TuLoadCode   ( "" -- )    load from file
::TuNewCode    ( -- )       new/empty file
::TuSaveCode   ( -- )       save to current ##filename

-- Marks (Syntax / Search) --
::tokenCursor  ( 'mark -- )   set cursor to mark
```

---

### vscreen.r3

Virtual resolution rendering. Renders to an internal texture at logical size, then scales to the actual window.

**Dependencies:** `^r3/lib/sdl2.r3`

```
::vscreen ( w h -- )   set virtual resolution (w×h logical pixels)
::vini    ( -- )       initialize virtual screen (call after SDLinit)
::vredraw ( -- )       copy virtual texture to window (call at end of frame)
::vfree   ( -- )       free virtual screen resources

::sdlx    ( -- x )     convert screen x to virtual x
::sdly    ( -- y )     convert screen y to virtual y
::%w      ( -- w. )    virtual width as fixed-point fraction
::%h      ( -- h. )    virtual height as fixed-point fraction
```

---

### tilesheet.r3

Tile map system with scrolling view.

**Dependencies:** `^r3/lib/mem.r3`, `^r3/lib/math.r3`, `^r3/lib/sdl2image.r3`, `^r3/lib/sdl2gfx.r3`

```
::[map]      ( x y -- adr )         address of tile at x,y in map
::loadtilemap ( "" -- amap )         load tile map from file

-- Rendering --
::drawtile   ( y x tile -- y x )    draw single tile
::tiledraw   ( w h x y sx sy 'amap -- )        draw tilemap (sx/sy = scroll offset)
::tiledrawv  ( w h x y sx sy 'amap 'vec -- )   draw + call 'vec for each tile
::tiledraws  ( w h x y sx sy sw sh 'amap -- )  draw subregion of map
::tiledrawvs ( w h x y sx sy sw sh 'amap 'v -- ) draw subregion + callback

-- Coordinate Conversion --
::scr2view  ( xs ys -- xv yv )    screen to view coordinates
::scr2tile  ( x y -- adr )        screen to tile address (valid after tiledraw)
```

---

### bmap.r3

Multi-layer tile map for 2D games with isometric and z-sorted sprite rendering.

**Dependencies:** `^r3/lib/console.r3`, `^r3/lib/sdl2gfx.r3`, `^r3/util/sdlgui.r3`, `^r3/util/arr16.r3`, `^r3/lib/rand.r3`

```
##bsprdraw  draw sprite function pointer (redefine for custom sprite drawing)

::inisprite ( -- )             initialize sprite system
::+sprite   ( N x y -- )       add sprite N at position (x,y) to draw list
::drawmaps  ( xvp yvp -- )     draw all map layers at viewport position
::loadmap   ( filename -- )    load tile map from file
::bmap2xy   ( x y -- x' y' )  convert map coords to screen coords
::whbmap    ( -- w h )         get map dimensions in tiles
::xyinmap@  ( x y -- map )     read map value at tile (x,y)
::xytrigger ( x y -- x y )     check trigger at tile position
```

---

### loadobj.r3

Wavefront OBJ/MTL 3D model loader.

**Dependencies:** `^r3/lib/mem.r3`, `^r3/lib/parse.r3`, `^r3/lib/sdl2image.r3`

```
-- Vertex Data (after loadobj) --
##verl  ##nver        vertex list, count
##facel ##nface       face list, count (triangles or quads)
##norml #nnorm        normal list, count (nnorm is private, unlike its siblings)
##texl  ##ntex        UV coordinate list, count
##paral #npara        parameter list, count (npara is private, unlike its siblings)
##colorl ##ncolor     color list, count

-- Accessors --
::]face  ( nro -- adr )   address of face nro (fields: p1 p2 p3 color)
::]vert  ( nro -- adr )   address of vertex nro
::]norm  ( nro -- adr )   address of normal nro
::]uv    ( nro -- adr )   address of UV coord nro

-- Material (MTL) Accessors --
::]Ka@  ::]Kd@  ::]Ks@  ::]Ke@   ambient/diffuse/specular/emission
::]Ns@  ::]Ni@  ::]d@   ::]i@    shininess/refraction/dissolve/illumination
::]Mkd@ ::]MNs@ ::]Mbp@           texture map filenames

-- Loading --
::loadobj  ( "" -- mem )    load OBJ file, return memory base

-- Geometry Operations --
##xmin ##ymin ##zmin ##xmax ##ymax ##zmax   bounding box (after objminmax)
::objminmax    ( -- )           compute bounding box of all vertices
::objmove      ( x y z -- )    translate all vertices
::objcentra    ( -- )           center model at origin
::objescala    ( por div -- )  scale all vertices by por/div
::objescalax   ( por div -- )  scale X only
::objescalay   ( por div -- )  scale Y only
::objescalaz   ( por div -- )  scale Z only
::objcube      ( lado -- )     generate a unit cube of side `lado`
::getpath      ( str -- str )  extract directory path from filepath
::>>cr         ( adr -- adr'/0 ) advance to next line in text
::cnt/         ( -- )          count faces
```

---

### datetime.r3

Date and time formatting in Spanish. Provides string output words.

**Dependencies:** `^r3/lib/mem.r3`

```
-- Append to Heap (,time / ,date style) --
::,time       ( -- )    append current time HH:MM:SS
::,ti:me      ( -- )    append time with colon separators
::,date       ( -- )    append current date DD/MM/YYYY
::,date-      ( -- )    append date with dash separators

-- Raw String Generation --
::str_DMA     ( -- str )  "D/M/A" formatted date
::str_HMS     ( -- str )  "H:M:S" formatted time
::str_HM      ( -- str )  "H:M" time
::str_fullday ( -- str )  full day name (e.g. "Lunes")
::str_hhmmss  ( -- str )  "HH:MM:SS"

-- Day and Month Names --
::>dianame    ( n -- str )  day name by number (0=Domingo..6=Sábado)
::>mesname    ( n -- str )  month name by number (1..12)

-- SQL / Database Formats --
::dt2timesql  ( 'sysdate -- )   format as SQL datetime string

-- 64-bit Packed DateTime --
::dt>64     ( datetime -- dt64 )   pack system datetime to 64-bit
::,64>dtf   ( dt64 -- "d/m/y h:m" )  format packed to display string
::,64>dtd   ( dt64 -- "d/m/y" )       date only
::,64>dtt   ( dt64 -- "h:m:s" )       time only
::64>dtc    ( dt64 -- "y-m-d h:m:s" ) ISO format (for databases)
```

---

### db2.r3

Text database version 2. Records separated by ASCII 30 (RS), fields by ASCII 31 (US), rows by ASCII 29 (GS).

**Dependencies:** `^r3/lib/console.r3`

```
##rowdb    current row pointer after search

-- File Loading --
::getnfilename ( n "path" -- filename/0 )   get nth file in path
::loadnfile    ( "" -- filename )            load next file in series
::loaddb-i     ( "filename" -- )             load DB into global (indexed)
::prevdb-i     ( "filename" -- )             load previous version
::loaddb       ( "filename" -- 'db )         load DB, return pointer

-- Record Iteration --
::>>line  ( adr -- adr'/0 )   advance to next record (0 = end)

-- Field Access --
::dbfld     ( nro -- string )           get field nro from current row
::getdbrow  ( id 'db -- 'row )          find row by ID
::findbrow  ( hash 'db -- 'row/0 )      find row by hash key (0=not found)
::cntdbrow  ( 'db -- cnt )              count records in database
::>>fld     ( adr -- adr' )             advance to next field
::getdbfld  ( nro 'row -- 'fld )        get field nro from row
::cpydbfld  ( 'fld 'str -- )            copy field to string buffer
::cpydbfldn ( max 'fld 'str -- )        copy field with max length
```

---

### dbtxt.r3

Text database version 1. Records separated by newline, fields by `|`, rows by `^`.

**Dependencies:** `^r3/lib/console.r3`

Same API as db2.r3. Same word names:
`getnfilename`, `loadnfile`, `>>line`, `loaddb-i`, `prevdb-i`, `dbfld`, `loaddb`, `getdbrow`, `findbrow`, `cntdbrow`, `>>fld`, `getdbfld`, `cpydbfld`, `cpydbfldn`.

Use `dbtxt.r3` for pipe-delimited flat text, `db2.r3` for binary-delimited packed format.

---

### filedirs.r3

Filesystem scanner providing file/directory trees for UI list and tree widgets.

**Dependencies:** `^r3/lib/mem.r3`, `^r3/util/datetime.r3`, `^r3/util/tui.r3`

```
##uiDirs     pointer to directory list
##uiFiles    pointer to file list

-- File Path Operations --
::flcpy       ( 'file 'str -- )        copy file entry to string
::flTreePath  ( n -- str )             get path of tree item n

-- Scanning --
::FlGetFiles   ( filename -- )         populate file list for given path
::flScanDir    ( "" -- )               scan directory into uiDirs/uiFiles
::flScanFullDir ( "" -- )              full recursive scan
::flOpenFullPath ( str -- place )      open/expand to given path in tree
```

---

*End of r3forth `util/` Library Reference*
