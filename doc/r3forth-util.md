# r3forth `util/` Library Reference

High-level utility libraries built on top of r3forth's core (`lib/`) libraries — object pools, sorting,
easing, animation timelines, fonts and text rendering, GUI widgets (both TTF-based `sdlgui.r3` and the
newer grid-based `immi.r3`), terminal UI, tile maps, 3D model loading, and simple text databases.

Source: [github.com/phreda4/r3/tree/main/r3/util](https://github.com/phreda4/r3/tree/main/r3/util)

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
20. [sdlfiledlg.r3](#sdlfiledlgr3) — File dialog (sdlgui-based)
21. [dlgcol.r3](#dlgcolr3) — Color picker dialog (SDL2)
22. [dlgfile.r3](#dlgfiler3) — File browser dialog (SDL2)
23. [immi.r3](#immir3) — Modern grid-based immediate-mode GUI (SDL2, v3)
24. [imcolor.r3](#imcolorr3) — Color selector widget for immi
25. [imedit.r3](#imeditr3) — Code editor with syntax highlight for immi
26. [imfiledlg.r3](#imfiledlgr3) — File dialog for immi
27. [immdatetime.r3](#immdatetimer3) — Calendar/datetime widget for immi
28. [tui.r3](#tuir3) — Text UI framework (terminal)
29. [tuiedit.r3](#tuieditr3) — Full text editor widget (terminal)
30. [vscreen.r3](#vscreenr3) — Virtual resolution with auto-scaling
31. [tilesheet.r3](#tilesheetr3) — Tile map with scrolling
32. [bmap.r3](#bmapr3) — Multi-layer tile map for games
33. [loadobj.r3](#loadobjr3) — Wavefront OBJ/MTL 3D model loader
34. [datetime.r3](#datetimer3) — Date/time formatting
35. [dbtxt.r3](#dbtxtr3) — Text database v1 (pipe/caret separators)
36. [filedirs.r3](#filedirsr3) — Filesystem scanner for UI trees

---

### arr8.r3

Fixed object pool for 8-value (64-byte) objects. Object index 0 is reserved as "null".

**Dependencies:** `^r3/lib/mem.r3`

```
::p8.ini ( cnt list -- )       initialize pool with `cantidad` slots
::p8.clear ( list -- )         reset pool (keep allocation)

-- Allocation --
::p8!+ ( 'act list -- adr )    allocate next; 'act = optional init callback
::p8! ( list -- adr )          allocate next (no callback)

-- Access --
::p8.nro ( adr list -- nro )   get object address by index (from start)
::p8.last ( ;ist -- adr )      get from end (reverse index)
::p8.cnt ( list -- cnt )       current count of active objects

-- Operations --
::p8.cpy ( adr 'list -- )      copy object adr into list
::p8.del ( adr list -- )       delete object (swap with last)
::p8.draw ( list -- )          call default draw for all
::p8.drawo ( list -- )         call default draw (ordered)
::p8.mapv ( 'vector list -- )  call vector for each object
::p8.mapd ( 'vector list -- )  call vector for each (reverse)
```

---

```
::p8.adr ( nro list -- adr )
::p8.map2 ( 'vec 'list --- )
::p8.sort ( col 'list -- )
::p8.isort ( col 'list -- )
```

### arr16.r3

Fixed object pool for 16-value (128-byte) objects. Like arr8 but larger objects with sorting and mapping.

**Dependencies:** `^r3/lib/mem.r3`

```
::p.ini ( cnt list -- )       initialize pool
::p.clear ( list -- )         reset pool

-- Allocation --
::p!+ ( 'act list -- adr )    allocate with init callback
::p! ( list -- adr )          allocate without callback

-- Access --
::p.adr ( nro list -- adr )   get object address by index
::p.nro ( adr list -- nro )   get index from address
::p.cnt ( list -- cnt )       active object count

-- Operations --
::p.del ( adr list -- )       delete object (swap with last)
::p.draw ( list -- )          call draw for all objects
::p.drawo ( list -- )         call draw (ordered)
::p.mapv ( 'vector list -- )  call vector for each
::p.mapd ( 'vector list -- )  call vector for each (desc)
::p.map2 ( 'vec 'list --- )   call 'vec with list

-- Sorting --
::p.sort ( col 'list -- )     sort by column `col` ascending
::p.isort ( col 'list -- )    sort by column `col` descending
```

---

### blist.r3

Ordered byte list (sorted insertion/lookup).

**Dependencies:** `^r3/lib/console.r3`

```
::blistdel ( 'list 'from -- )  delete item 'from from list
::blist! ( f 'list -- )        insert f into list (sorted)
::blist- ( f 'list -- )        remove f from list
::blist@ ( 'list -- f/0 )      get first item (or 0)
::blist? ( f 'list -- f/0 )    find f in list (0 if not found)
```

---

### dlist.r3

Double-ended deque / FIFO queue.

**Dependencies:** `^r3/lib/mem.r3`

```
::dc.ini ( max 'dc -- )  mac 'dc dc.ini
::dc.clear ( list -- )   clear deque
::dc? ( list -- cnt )    current item count
::dcn@ ( n l -- v )      get item at index n
::dc@ ( list -- val )    peek front item
::dc! ( val list -- )    enqueue (add to back)
::dc@- ( list -- val )   dequeue (remove from front)
```

---

### heap.r3

Min-heap priority queue.

**Dependencies:** `^r3/lib/mem.r3`

```
::heapini ( max 'h -- )  initialize heap with max capacity
::heap! ( nodo 'h -- )   insert node (smaller value = higher priority)
::heap@ ( 'h -- nodo )   remove and return min-priority node
```

---

### hash2d.r3

2D spatial hash for fast proximity/collision queries.

**Dependencies:** `^r3/lib/mem.r3`

```
##checkmax 32   maximum check radius in pixels

::H2d.ini ( maxobj -- )                   reserve at here the hash table, the object list and the contact list for up to maxobj objects (ids 0..65534)
::H2d.clear ( -- )                        empty the hash table and the contact list (call it every frame before adding the objects)
::H2d.list ( -- 'adr cnt )                list of contacts found: cnt dwords, each (newer object nro << 16) | older object nro

::h2d+! ( nro r x y -- )                  add object nro (0..65534) with radius r (0..1023) at x y (pixels, 19 bits) and add to the list its contacts with the objects already added (square test: max(|dx|,|dy|) < r1 + r2)
::h2d! ( x y zoom nro size -- x y zoom )  add object nro at x y with the radius size*zoom (zoom fixed point) and leave x y zoom
```

---

### sort.r3

ShellSort with optimal gaps. Input arrays are key-value pairs.

**Dependencies:** `^r3/lib/math.r3`

```
::shellsort ( len list -- )   list of value-data pairs
::shellsort2 ( len list -- )  list of data-value pairs
::shellsort1 ( len list -- )  list of cells packed as data|value
::sortstr ( len list -- )     list of pstr-value pairs (string pointer, value)
```

---

### sortradix.r3

O(n) RadixSort for fixed-width integer keys. Sorts key-value pair arrays.

**Dependencies:** `^r3/lib/mem.r3`

```
::radixsort32 ( cnt '2array -- )  sort by 32-bit key
::radixsort16 ( cnt '2array -- )  sort by 16-bit key
::radixsort64 ( cnt '2array -- )  sort by 64-bit key
```

The `'2array` points to an array of (key, value) pairs, each 2 cells.

---

### sortradixm.r3

RadixSort variant with offset keys.

**Dependencies:** `^r3/lib/mem.r3`

```
::radixsort ( cnt 'array -- )   sort with default offset
::radixsortm ( cnt 'array -- )  sort with modified offset keys
```

---

### penner.r3

30 Penner easing functions in 48.16 fixed-point. Input `t` is in range `[0.0 .. 1.0]` (fixed-point), output is in `[0.0 .. 1.0]`.

**Dependencies:** `^r3/lib/math.r3`

```
-- Linear --
::Lineal ( t -- t )                  no easing (linear): t unchanged; all the easing words take and return t in fixed point 0..1.0

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
::ease ( t nro -- t' )               apply the easing number nro to t: 0 linear, then In Out InOut of 1-3 Quad, 4-6 Cub, 7-9 Quar, 10-12 Quin, 13-15 Sin, 16-18 Exp, 19-21 Cir, 22-24 Ela, 25-27 Bac, 28-30 Bou (no range check above 30)
::easem ( t nro -- t' )              like ease with a short table, only the low 4 bits of nro count: 0 linear, then In Out InOut of 1-3 Sin, 4-6 Exp, 7-9 Bac, 10-12 Ela, 13-15 Bou

-- Interpolation --
::catmullRom ( p0 p1 p2 p3 t -- v )  Catmull-Rom spline value between p1 (t = 0) and p2 (t = 1.0) using the neighbours p0 and p3
```

---

### varanim.r3

Timeline-based variable animator. Drives values from `ini` to `fin` over time using a Penner ease.

**Dependencies:** `^r3/lib/mem.r3`, `^r3/lib/color.r3`, `^r3/util/penner.r3`

```
-- Global State --
##deltatime     time delta for current frame (ms)

::timer< ( -- )                               reset the timer (deltatime = 0)
::timer. ( -- )                               update the timer: deltatime = milliseconds since the previous call
::timer+ ( n -- n' )                          add deltatime to n
::timer- ( n -- n' )                          subtract deltatime from n

-- Setup --
::vareset ( -- )                              remove all the events and restart the animation clock
::vaini ( max -- )                            reserve at here the memory for up to max events at the same time and reset
::vaempty ( -- n )                            number of events in the list (waiting or running)
::vkillgroup ( group -- )                     remove all the events of the group (0..15)
::vkillvar ( 'var -- )                        remove the animations of the variable 'var

-- Update --
::vupdate ( -- )                              advance the animations with the time elapsed since the last call (once per frame): starts the events whose time has come, updates the variables and removes the finished ones

-- Add Animations --
::+vanim ( 'var fin ini ease dur. start -- )  animate the cell 'var from ini to fin (the first value is the destination); ease = easing number (0 linear, 1 Quad_In... see ease in penner.r3), dur. and start in seconds (fixed point); the animation starts at the first vupdate after start
::+vboxanim ( 'var fin ini ease dur. start -- )  animate the four 16-bit values packed in the cell (see xywh64), each one on its own
::+vxyanim ( 'var fin ini ease dur. start -- )  animate the two 32-bit values packed in the cell (see xy32), each one on its own
::+vcolanim ( 'var fin ini ease dur. start -- )  animate a color $AARRGGBB mixing ini and fin channel by channel (alpha included)
::+vexe ( 'exe start -- )                     execute 'exe once after start seconds; 'exe receives the address of the stored parameters and must leave it on the stack
::+vvexe ( v 'exe start -- )                  like +vexe with a parameter: 'exe receives an address and reads v with dup @
::+vvvexe ( v1 v2 'exe start -- )             like +vexe with two parameters: 'exe reads them with dup @+ swap @ (v2 deeper, v1 on top) and leaves the address

-- with group (0..15)
::+vanimg ( 'var fin ini ease dur. start group -- )  like +vanim in a group (0..15) that vkillgroup can remove
::+vboxanimg ( 'var fin ini ease dur. start group -- )  like +vboxanim in a group (0..15)
::+vxyanimg ( 'var fin ini ease dur. start group -- )  like +vxyanim in a group (0..15)
::+vcolanimg ( 'var fin ini ease dur. start group -- )  like +vcolanim in a group (0..15)
::+vexeg ( 'exe start group -- )              like +vexe in a group (0..15)
::+vvexeg ( v 'exe start group -- )           like +vvexe in a group (0..15)
::+vvvexeg ( v1 v2 'exe start group -- )      like +vvvexe in a group (0..15)

-- Packed Value Helpers --
::64xy ( b -- x y )                           unpack the first two signed 16-bit values (x in the highest 16 bits)
::64wh ( b -- w h )                           unpack the last two signed 16-bit values
::64xywh ( b -- x y w h )                     unpack four signed 16-bit values
::xywh64 ( x y w h -- b )                     pack four 16-bit values (x in the highest 16 bits)
::64xyrz ( b -- x y r z )                     unpack a sprite: x y in 16 bits, r (rotation) with 2 bits less of precision and z (zoom) with 4 bits less
::xyrz64 ( x y r z -- b )                     pack a sprite (see 64xyrz)
::64box ( b adr -- )                          write the four 16-bit values of b as four dwords x y w h at adr (an SDL_Rect)
::32xy ( b -- x y )                           unpack two signed 32-bit values (x in the high half)
::xy32 ( x y -- b )                           pack two 32-bit values (x in the high half)
```

---

```
::aniInit ( ini cnt fps -- V )  value of a frame animation: first frame ini (12 bits), cnt frames (up to 256) and fps in fixed point (10.0 = 10 frames per second, 0 = still)
::ani+! ( dt 'V -- )            advance the frame animation in 'V by dt milliseconds: as many frames as dt covers (the time left over is kept); after the last frame it goes back to the first
::aniFrame ( V -- f )           current frame number (ini + step)
::aniCnt ( V -- n )             current step 0..cnt-1 of the animation (it is not the number of frames)
::ani+timer! ( 'V -- )          advance the frame animation in 'V by deltatime
```

### utfg.r3

8×8 bitmap Unicode font for terminal output. Outputs to console buffer via `.write`.

**Dependencies:** `^r3/lib/console.r3`

```
-- Character Output --
::.xwrite ( str -- )       write string to terminal using bitmap font
::.awrite ( str -- )       write string (alternate mode)

-- Line Drawing --
::.vline ( h -- )          draw vertical line h chars tall
::.hline ( w -- )          draw horizontal line w chars wide
::.vlined ( h -- )         draw double vertical line
::.hlined ( w -- )         draw double horizontal line

-- Box Drawing --
::.boxl ( x y w h -- )     draw box (single line)
::.boxc ( x y w h -- )     draw box (corner style)
::.boxd ( x y w h -- )     draw box (double line)
::.boxf ( x y w h -- )     fill current box area

-- Text Alignment --
::lalign ( cnt str -- )    left-align string in cnt columns
::calign ( cnt str -- )    center-align
::ralign ( cnt str -- )    right-align
::lwrite ( w "str" -- )    left aligned text for txText (ignores w)
::cwrite ( w "str" -- )    centered text in w pixels for txText
::rwrite ( w "str" -- )    right aligned text in w pixels for txText
::xalign ( $VH -- )        set alignment ($V=vertical bits, $H=horizontal bits)
::xwrite ( w "str" -- )    write with current alignment
::xText ( w h x y "" -- )  draw aligned text in box
```

---

```
::.vline2 ( h -- )
::.vlined2 ( h -- )
::rgb4t ( col12 -- col256 )
```

### bfont.r3

Fixed-width bitmap font rendered to SDL2 from an image file.

**Dependencies:** `^r3/lib/sdl2gfx.r3`, `^r3/lib/sdl2image.r3`

```
##wp ##hp   glyph width, height (pixels)

-- Setup --
::bmfont ( w h "file" -- )         load the font image (a 16x16 grid of 256 characters of w x h pixels: column = low nibble, row = high nibble of the ASCII code) and set the character size
::bfont1 ( -- )                    load the font media/img/VGA8x16.png (8x16 characters)
::bfont2 ( -- )                    load the font media/img/font16x24.png (16x24 characters)

-- Colors --
::bcolor ( rgb -- )                color $RRGGBB of the font texture (color modulation)
::bfbox ( -- )                     fill the character cell at the cursor with the draw color
::bbox ( -- )                      outline of the character cell at the cursor
::bbox2 ( -- )                     outline of the lower half of the character cell at the cursor

-- Cursor Positioning --
::bat ( x y -- )                   move the cursor to the pixel position x y
::ccx ( -- x )                     cursor x in pixels (also defined in pcfont)
::ccy ( -- y )                     cursor y in pixels (also defined in pcfont)
::gotoxy ( x y -- )                move the cursor to the character cell x y (also defined in pcfont)
::gotox ( x -- )                   move the cursor to the character column x, same y (also defined in pcfont)

-- Rendering --
::bemit ( ascii -- )               draw the character at the cursor and move the cursor one character to the right
::bprint ( .. "" -- )              formatted print (see sprint) at the cursor
::bprintd ( .. "" -- )             formatted print with double width
::bprint2 ( .. "" -- )             formatted print with double width and height
::bemits ( "" -- )                 print the string at the cursor
::bemitsd ( "" -- )                print the string with double width
::bemits2 ( "" -- )                print the string with double width and height
::bprintz ( .. "" size -- )        formatted print scaled by size (fixed point, 1.0 = normal)
::bemitsz ( "" size -- )           print the string scaled by size (fixed point, 1.0 = normal)
::bfillemit ( "" -- "" )           fill with the draw color the area the string would use at the cursor
::bfcemit ( cnt -- )               fill with the draw color the area of cnt characters at the cursor
::bcr ( -- )                       new line: x = 0 and y down one character
::bcr2 ( -- )                      new line for double height text (y down two characters)
::bcrz ( size -- )                 new line for text scaled by size (fixed point)
::bsp ( -- )                       move the cursor one character to the right
::bnsp ( n -- )                    move the cursor n characters to the right

-- Measurement --
::bsize ( "" -- "" w h )           size in pixels of the string (count * wp, hp)
::bpos ( -- x y )                  cursor position in pixels
::brect ( "" -- "" x y w h )       rectangle (position and size in pixels) of the string at the cursor
::bsrcsize ( x y w h -- x y w h )  convert the two pairs from character cells to pixels (x*wp y*hp w*wp h*hp)

-- Cursor Display --
::bcursor ( n -- )                 fill with the draw color the character cell n characters to the right of the cursor (block cursor)
::bcursori ( n -- )                like bcursor but a bar of a quarter of the height at the bottom (insert cursor)
::bcursor2 ( n -- )                like bcursor for double size characters
::bcursori2 ( n -- )               like bcursori for double size characters
```

---

```
::bfillline ( x y w h -- )  fill with the draw color the rectangle given in character cells (x y w h)
```

### pcfont.r3

PC/DOS-style font (16×32 grid per image) for SDL2.

**Dependencies:** `^r3/lib/sdl2gfx.r3`, `^r3/lib/sdl2image.r3`

Similar API to bfont.r3 but for PC-font-style rendering. Key words:

```
::pcfont ( -- )                load the font media/img/VGA8x16.png (8x16 characters in a 16x16 grid) and set the cursor size
::pccolor ( rgb -- )           color $RRGGBB of the font texture (color modulation)
::pcemit ( ascii -- )          draw the character (8x16) at the cursor and move the cursor one character to the right
::pcprint ( .. "" -- )         formatted print (see sprint) at the cursor
::pcemits ( "" -- )            print the string at the cursor
::pcat ( x y -- )              move the cursor to the pixel position x y
::gotoxy ( x y -- )            move the cursor to the character cell x y (also defined in pcfont)
::gotox ( x -- )               move the cursor to the character column x, same y (also defined in pcfont)
::pccr ( -- )                  new line: x = 0 and y down 16 pixels
::pcsp ( -- )                  move the cursor one character (8 pixels) to the right
::pcnsp ( n -- )               move the cursor n characters to the right
::pcsize ( "" -- "" w h )      size in pixels of the string (count * 8, 16)
::pcrect ( "" -- "" x y w h )  rectangle (position and size in pixels) of the string at the cursor
::pcpos ( -- x y )             cursor position in pixels
::pccursor ( n -- )            fill with the draw color the character cell n characters to the right of the cursor (block cursor)
::pccursori ( n -- )           like pccursor but a bar of a quarter of the height at the bottom (insert cursor)
::pcfbox ( -- )                fill the character cell at the cursor with the draw color
::pcbox ( -- )                 outline of the character cell at the cursor
::pcbox2 ( -- )                outline of the lower half of the character cell at the cursor
::pcfillline ( x y w h -- )    fill with the draw color the rectangle given in character cells (x y w h)
::pcprintz ( .. "" size -- )   formatted print scaled by size (fixed point, 1.0 = normal)
::pcemitsz ( "" size -- )      print the string scaled by size (fixed point, 1.0 = normal)
```

---

```
::pcsrcsize ( x y w h -- x y w h )  convert the two pairs from character cells to pixels (x*8 y*16 w*8 h*16)
::pcfillemit ( "" -- "" )           fill with the draw color the area the string would use at the cursor
::pcprintd ( .. "" -- )             formatted print with double width
::pcemitsd ( "" -- )                print the string with double width
::pcprint2 ( .. "" -- )             formatted print with double width and height
::pcemits2 ( "" -- )                print the string with double width and height
```

### ttfont.r3

TrueType font rendering for SDL2 using SDL2_ttf.

**Dependencies:** `^r3/lib/sdl2gfx.r3`, `^r3/lib/sdl2ttf.r3`

```
##ttx ##tty   current text cursor position

::ttcolor ( rrggbb -- )            text color (stored with red and blue swapped, as SDL_Color wants it)
::ttfont! ( font -- )              set the font (from TTF_OpenFont) used by the tt words
::ttprint ( .. "" -- )             formatted print (see sprint) at the cursor
::ttemits ( "" -- )                draw the string at the cursor and move the cursor to its end (a texture is created for each call)
::ttat ( x y -- )                  move the cursor to the pixel position x y
::+ttat ( x y -- )                 move the cursor by x y pixels
::ttsize ( size -- )               set the point size of the current font
::ttcursor ( str strcur -- str )   fill with the draw color the block cursor of the character at strcur (an address inside str); the string is cut there temporarily
::ttcursori ( str strcur -- str )  like ttcursor but a bar of 2 pixels at the bottom (insert cursor)
::ttrect ( "" -- "" x y w h )      rectangle (position and size in pixels) of the string at the cursor
```

---

```
::ttwh ( "" -- "" w h )    size in pixels of the string with the current font
::ttstyle ( style -- )     set the style of the current font: bit 0 bold, 1 italic, 2 underline, 3 strikethrough
::ttemitc ( width "" -- )  draw the string centered in width pixels starting at the cursor
::ttemitr ( "" -- )        draw the string right aligned: it ends at the cursor x
::ttboxcc ( w h "" -- )    draw the string centered in a box w x h starting at the cursor
```

### txfont.r3

TrueType font atlas renderer with pseudo-UTF8 support and glyph caching.

**Dependencies:** `^r3/lib/sdl2gfx.r3`, `^r3/lib/sdl2ttf.r3`

```
-- Font Loading --
::txloadwicon ( "font" size -- nfont )  load a TTF font at that size into an atlas texture (ASCII 32..127, the accented letters of the utf8 list and the Font Awesome icons of media/ttf/Font Awesome 7 Free-Solid-900.otf from code 192); returns the atlas (texture and table kept at here)
::txload ( "font" size -- nfont )       like txloadwicon without the icons
::txfont ( font -- )                    select the atlas font (from txload) used by the tx words
::txfont@ ( -- font )                   the atlas font selected now

-- Color --
::txrgb ( c -- )                        color $RRGGBB of the font texture (color modulation)

-- Measurement --
::txcw ( adr car -- adr' width )        width in pixels of a character: car is the byte just read at adr-1; a two byte accented character reads its second byte (adr' is after it)
::txw ( "" -- "" width )                width in pixels of the string
::txch ( adr car -- adr' h )            height of a character (same protocol as txcw)
::txh ( -- h )                          height of the font (line height)

-- Positioning --
::txat ( x y -- )                       move the cursor to the pixel position x y
::tx+at ( x y -- )                      move the cursor by x y pixels
::txpos ( -- x y )                      cursor position in pixels

-- Rendering --
::txemit ( adr car -- adr' )            draw one character at the cursor and advance it (same protocol as txcw)
::txwrite ( "" -- )                     draw the string at the cursor
::txemitr ( "" -- )                     draw the string right aligned: it ends at the cursor x
::txprint ( .. "" -- )                  formatted print (see sprint) at the cursor
::txprintr ( .. "" -- )                 formatted print right aligned
::txcur ( str cur -- )                  fill with the draw color the block cursor of the character at cur (an address inside str); it moves the cursor x to that character
::txcuri ( str cur -- )                 like txcur but a bar of a quarter of the height at the bottom (insert cursor)
::lwrite ( w "str" -- )                 left aligned text for txText (ignores w)
::cwrite ( w "str" -- )                 centered text in w pixels for txText
::rwrite ( w "str" -- )                 right aligned text in w pixels for txText
::txalign ( $VH -- )                    alignment for txText: low 2 bits horizontal (0 left, 1 center, 2 right), bits 4-5 vertical (0 top, 1 center, 2 bottom)
::txText ( w h x y "" -- )              draw the string wrapped by words in the box x y w h with the txalign alignment; CR, LF and ; start a new line
```

---

```
::txfit ( w "" -- ncar )              number of bytes of the string that fit in w pixels
::txcr ( -- )                         new line: x = 0 and y down one line height
::txemitc ( w "" -- )                 draw the string centered in w pixels starting at the cursor x
::pad.reset ( 'var max -- 'var max )  prepare the line editor on the buffer 'var of max bytes: cursor at the end, insert mode
::pad.draw ( 'buff -- )               draw the edited line at the cursor with a blinking cursor and handle the keys: SDLchar to insert or overwrite, left, right, backspace, delete, home, end and insert to change the mode
```

### ttext.r3

Tilesheet-based terminal text renderer for SDL2. Uses a sprite sheet for characters.

**Dependencies:** `^r3/lib/sdl2gfx.r3`, `^r3/lib/sdl2image.r3`

```
##advx ##advy   character advance width/height

-- Font Setup --
::tfnt ( size w h "file" -- )      load a font image (16x16 grid of characters of w x h pixels) and set its zoom size (fixed point)
::tini ( -- )                      load the default font media/img/VGA8x16.png (8x16) at size 1.0
::tsize ( zoom -- )                set the character size as the font size times zoom (fixed point, 1.0 = normal)

-- Colors / Palette --
::trgb ( c -- )                    color $RRGGBB of the font texture (color modulation)
::tpal ( c -- rgb )                color of the palette entry c (low 4 bits: 0 black, 1 blue, 2 cyan, 3 green, 4 purple, 5 red, 6 white, 7 yellow, 8..15 the bright ones) of the style in termcolor (style0 Campbell)
::tcol ( c -- )                    set the text color from the palette entry c
::tfbox ( -- )                     fill the character cell at the cursor with the draw color
::tbox ( -- )                      outline of the character cell at the cursor

-- Positioning --
::tat ( x y -- )                   move the cursor to the pixel position x y
::tatx ( x -- )                    set the cursor x in pixels
::txy ( x y -- )                   move the cursor to the character cell x y
::tx ( x -- )                      move the cursor to the character column x
::tcx ( -- x )                     cursor x in pixels
::tcy ( -- y )                     cursor y in pixels
::tpos ( -- x y )                  cursor position in pixels
::tcr ( -- )                       new line: x = 0 and y down one character
::tsp ( -- )                       move the cursor one character to the right
::tnsp ( n -- )                    move the cursor n characters to the right

-- Rendering --
::temit ( ascii -- )               draw the character at the cursor and move the cursor one character to the right
::tprint ( .. "" -- )              formatted print (see sprint) at the cursor
::temits ( "" -- )                 print the string at the cursor

-- Measurement --
::tsbox ( 'box n ts -- )           fill the 'box (x y w h, four int32) with the source rectangle of tile n
::trect ( "" -- "" x y w h )       rectangle (position and size in pixels) of the string at the cursor
::tsrcsize ( x y w h -- x y w h )  convert the two pairs from character cells to pixels

-- Cursor Rendering --
::tcursor ( n -- )                 fill with the draw color the character cell n characters to the right of the cursor (block cursor)
::tcursori ( n -- )                like tcursor but a bar of a quarter of the height at the bottom (insert cursor)
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
::immgui ( -- )             start of a gui frame, once per frame before the widgets: calls gui and resets the layout (cursor at 0 0, box = screen width by font height + 8)
::immSDL ( font -- )        start the gui with the TTF font and load the icons media/img/icong16.png (tiles of 24x21)
::immat ( x y -- )          set the cursor (position of the next widget)
::immat+ ( x y -- )         move the cursor by x y pixels
::immbox ( x y w h -- )     set widget size
::immfont! ( font -- )      set the TTF font used by the widgets and measure its height
::immpad! ( padx pady -- )  set the padding around the widgets
::immwinxy ( x y -- )       set the origin of the window and put the cursor inside it with the padding
::imm>> ( -- )              move the cursor one widget to the right (box width plus the padding of both sides)
::imm<< ( -- )              move the cursor one widget to the left
::immdn ( -- )              move the cursor one widget down (box height plus the padding of both sides)
::immcr ( -- )              new line: x back to the left of the window and y down one widget
::immln ( -- )              new line: x back to the left of the window and y down only the box height
::plgui ( -- )              start a widget at the cursor: guiBox of the current box with the padding
::plxywh ( -- x y w h )     rectangle of the widget at the cursor, with the padding

-- Cursor Save/Restore --
::immcur ( x y w h -- )     set the guiBox of the rectangle x y w h (relative to the window), draw a gray outline around it and make it the cursor and the box
::immcur> ( -- cur )        pack the cursor and the box in one value: curx | cury<<16 | boxw<<32 | boxh<<48
::imm>cur ( cur -- )        restore the cursor and the box packed by immcur>

::immwidth ( w -- )         set the width of the next widgets
```

#### Widget Words
```
::immlabel ( "" -- )                  draw the text (formatted, see ttprint) at the left of the current box, vertically centered
::immlabelc ( "" -- )                 draw the text centered in the current box
::immlabelr ( "" -- )                 draw the text right aligned in the current box
::imm. ( "" -- )                      draw the text (formatted with sprint) at the cursor and move the cursor right by its width plus padding (inline text)
::immStrC ( "" -- )                   draw the text centered in the current box (no format)
::immListBox ( lines -- )             guiBox of a list area of that many box heights
::immback ( color -- )                fill the current box with the color (for the lines of a list)
::immblabel ( "" -- )                 text of a list line at the left of the current box (without the vertical padding)
::immicon ( nro x y -- )              draw the icon nro of the icon set at x y
::immiconb ( nro -- )                 draw the icon nro centered in the current box with the text color
::immbtn ( 'click "" -- )             button with centered text: moves 2 pixels while the mouse is over it and executes 'click when clicked
::immibtn ( 'click nro -- )           button with the icon nro
::immtbtn ( 'click "" -- )            button as wide as its text; the background shows only while the mouse is over it
::immebtn ( 'click "" -- )            button with the text only (no background), as wide as its text
::immzone ( -- )                      Interaction is cx,cy,cw,th
::immSliderf ( min max 'value -- )    horizontal slider of a fixed point value between min and max (it shows the value with 2 decimals)
::immSlideri ( min max 'value -- )    horizontal slider of an integer value between min and max
::immCheck ( 'val "text" -- )         check box: a click toggles bit 0 of the variable
::immScrollv ( 0 max 'value -- )      vertical scroll bar for the value between 0 and max (the code notes it is incorrect)
::immRadio ( 'val "op1|op2|op3" -- )  radio buttons, one line per option: the variable holds the number (0 is the first) of the chosen one
::immCombo ( 'val "op1|op2|op3" -- )  shows the chosen option; a click goes to the next one (it is not a drop down list)
::immInputLine ( 'buff max -- )       line editor of the text in 'buff (max bytes): insert or overwrite (Ins), left, right, home, end, backspace and delete; tab and enter go to the next widget
::immInputInt ( 'var -- )             integer input: the digits typed are appended, backspace or delete divide by 10 (no negative numbers)
```

#### Window Management
```
::immwin! ( 'winword -- )     add a window to the list drawn by immRedraw ('winword draws the window and its widgets); it is not added twice
::immwin ( 'win -- 0/flags )  draw the window of the record 'win (flags, x y w h in four dwords, title): flag 1 = open, flag 2 = comes to the front; handles dragging by the title and the close button; returns 0 if it is closed, else puts the cursor and the box inside the window
::immnowin ( x y w h -- )     set the region for the widgets without a window frame
::immwinbottom ( 'win -- )    set the height of the window record to the cursor y reached (the window fits its content)
::winexit ( -- )              close the window that has the mouse over it (it is the action of the close button)
::immRedraw ( -- )            execute the word of every window of the list, bring the clicked window to the front and execute the key handler set with immkey!
::immwins ( 'win -- )         like immwin for a fixed window: no dragging, no close button
```

---

```
::immwin$ ( 'winword -- )  remove the window from the list
```

### sdlfiledlg.r3

File open/save dialog using sdlgui.r3.

**Dependencies:** `^r3/util/sdlgui.r3`

```
::immlist ( cnt -- )                 the list of files of the dialog with cnt lines: a click selects, a second click on the same line enters the folder or accepts the file; it has a scroll bar
::filedlgini ( -- )                  start the file dialog: 15 lines and memory reserved at here (a table of 1024 entries and 64 KB of names)
::immfileload ( 'vecload 'file -- )  show load dialog; calls 'vecload on confirm
::immfilesave ( 'vecload 'file -- )  show save dialog; calls 'vecload on confirm
::fullfilename ( -- )                push full path to stack
```

---

### dlgcol.r3

Interactive color picker dialog for SDL2.

**Dependencies:** `^r3/lib/sdl2gfx.r3`, `^r3/lib/color.r3`, `^r3/lib/gui.r3`, `^r3/util/bfont.r3`

```
##colord 0        currently selected color

::color! ( color -- )     set the selected color $RRGGBB and move the marks of the picker to it
::dlgColor ( -- )         draw the color dialog: the current color box (a click opens or closes the picker with hue bar, saturation and value square and alpha bar) and the palette of 3x20 colors (the old comment x y is not used, see xydlgColor!)
::dlgColorIni ( -- )      start the color dialog: build the 128 step hue bar and the palette, color white, alpha 127
::xydlgColor! ( x y -- )  position of the color dialog and rebuild its geometry
```

---

### dlgfile.r3

File browser dialog for SDL2 (uses gui.r3 input system).

**Dependencies:** `^r3/lib/sdl2gfx.r3`, `^r3/lib/gui.r3`, `^r3/lib/input.r3`

```
::dlgFileLoad ( -- fn/0 )   modal dialog to choose a file to load (it runs its own SDLshow loop; up, down, enter and esc keys, click on a line); returns the full file name, or 0 if it was cancelled
::dlgFileSave ( -- fn/0 )   modal dialog to write the name of a file to save (editable name, 64 characters); returns the full file name, or 0 if it was cancelled
::dlgSetPath ( "path" -- )  set the folder where the file dialogs start
```

---

### immi.r3

Modern grid-layout immediate-mode GUI for SDL2 (version 3, 2025). Uses txfont for rendering.

**Dependencies:** `^r3/lib/sdl2gfx.r3`, `^r3/lib/color.r3`, `^r3/util/txfont.r3`

#### Layout System
The layout cursor `(cx, cy, cw, ch)` tracks current widget position. The frame stack allows push/pop for nested layouts.

```
##cx ##cy ##cw ##ch    current widget cursor (position + size)
::%cw ( -- w )                                percent of frame width
::%ch ( -- h )                                percent of frame height

-- Frame Management --
::uiBox ( x y w h -- )                        set frame
::uiFull ( -- )                               fill entire window
::uiPush ( -- )                               push frame state
::uiPop ( -- )                                pop frame state
::uiRest ( -- )                               restore frame
::uiPading ( x y -- )                         set padding
::uiAt ( x y -- )                             absolute position within frame
::uiTo ( w h -- )                             set widget size

-- Splits (divide current frame) --
::uiN ( lineas -- )                           take N lines from top
::uiS ( lineas -- )                           take N lines from bottom
::uiE ( cols -- )                             take N columns from right
::uiO ( cols -- )                             take N columns from left
::uiGrid ( c r -- )                           adjust for fit
::uiNext ( -- )                               advance to next grid cell
::uiNextV ( -- )                              advance vertically

-- Input State Queries --
::uiEx? ( -- 0/1 )                            mouse over?
::uiOvr ( 'v -- )                             execute if mouse over
::uiDwn ( 'v -- )                             execute if mouse down in widget
::uiSel ( 'v -- )                             execute if selected
::uiClk ( 'v -- )                             execute if clicked
::uiUp ( 'v -- )                              execute on mouse release
::uiFocusIn ( 'v -- )                         execute when focus enters
::uiFocus ( 'v -- )                           execute while focused

-- Frame Lifecycle --
::uiStart ( -- )                              begin UI frame
::uiEnd ( -- )                                end UI frame
::uiZone ( -- )                               Interaction is cx,cy,cw,th
::uiZoneL ( nlines -- )                       Interaction is cx,cy,cw,th*lines
::uiZoneW ( --	; Interaction is cx,cy,cw,ch ) zone filling cw×ch
::uiZoneBox ( x y w h -- )                    explicit zone rect
::uiSaveLast ( x y w h 'vector -- )           save last zone dimensions
::uiBackBox ( -- )                            draw background box
::uiExitWidget ( -- )                         early exit from widget
::uiPlace ( n -- )                            place widget at grid position n
```

#### Focus
```
::uiRefocus ( -- )  reset focus
::uiFocus>> ( -- )  move to next focusable
::uiFocus<< ( -- )  move to previous
::tabfocus ( -- )   advance focus on Tab key
```

#### Drawing Helpers
```
::uiFill ( -- )            fill cx cy cw ch
::uiRect ( -- )            outline cx cy cw ch
::uiRFill ( -- )           rounded filled
::uiRRect ( -- )           rounded outline
::uiCRect ( -- )           circle outline (uses min of w,h)
::uiCFill ( -- )           circle filled
::uiTex ( tex -- )         draw texture in widget area
::uiWinBox ( -- x y w h )  window bounds
::uiLineGridV ( -- )       draw vertical grid lines
::uiLineGridH ( -- )       draw horizontal grid lines
::uiLineGrid ( -- )        draw both grid lines
```

#### Status Styles
```
::stDang ( -- )  danger style (red)
::stWarn ( -- )  warning style (amber)
::stSucc ( -- )  success style (green)
::stInfo ( -- )  info style (blue)
::stLink ( -- )  link style
::stDark ( -- )  dark style
::stLigt ( -- )  light/white style
```

#### Widgets
```
-- Labels and Text --
::uiTlabel ( -- )                    text label from stack
::uiLabel ( -- )                     centered label
::uiLabelC ( -- )                    explicitly centered
::uiLabelR ( -- )                    right-aligned
::uiText ( "" align -- )             text with alignment
::ttwrite ( "text" -- )              write text (left)
::ttwritec ( "text" -- )             write centered
::ttwriter ( "text" -- )             write right

-- Buttons --
::uiBtn ( 'click "" -- )             standard button
::uiRBtn ( 'click "" -- )            rounded button
::uiCBtn ( 'click "" -- )            circular button
::uiTBtn ( 'click "" align -- )      text button with alignment
::uiNBtn ( v "" -- )                 width from text

-- Input --
::uiInputLine ( 'buff max -- )       single-line text input
::uiCheck ( 'var 'list -- )          checkbox (list = option strings)
::uiRadio ( 'var 'list -- )          radio group
::uiCombo ( 'var 'list -- )          combo box / dropdown
::uiList ( 'var cntl 'list -- )      scrollable list
::uiTree ( 'var cntl list -- )       collapsible tree
::uiNindx ( n -- str )               get list item string n

-- Sliders and Progress --
::uiSliderf ( 0.0 1.0 'value -- )    horizontal float slider
::uiSlideri ( 0 255 'value -- )      horizontal integer slider
::uiVSliderf ( 0.0 1.0 'value -- )   vertical float slider
::uiVSlideri ( 0 255 'value -- )     vertical integer slider
::uiProgressf ( 0.0 1.0 'value -- )  float progress bar
::uiProgressi ( 0 255 'value -- )    integer progress bar
```

> **Note:** `immi.r3` (v3) is single-window/full-screen — it has no `immwin`/`immnowin`-style multi-window API. That API (`immwin`, `immwin!`, `immnowin`, `winexit`, `immRedraw`, `immwins`, `immSDL`, `immblabel`, `immicon`, `immiconb`, `immwidth`, etc.) belongs to `sdlgui.r3`, which is documented in its own section above. An earlier version of this reference mistakenly duplicated that list here.

---

```
::stColor ( rgb -- )
```

### imcolor.r3

Color selector widget for immi.

**Dependencies:** `^r3/lib/color.r3`, `^r3/util/immi.r3`

```
::color! ( color -- )   set the selected color $RRGGBB and move the marks of the picker to it
::uiColor ( 'var -- )   full color selector widget (HSV + RGB sliders)
::uiColorH ( 'var -- )  compact horizontal color selector
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
::clearmark ( -- )             clear all syntax marks
::addmark ( -- )               add mark at current position
::addsrcmark ( src color -- )  add colored mark
::showmark ( -- )              render marks

-- Editor Display --
::edcodedraw ( -- )            draw code with syntax highlighting
::edfill ( -- )                fill editor background
::edtoolbar ( -- )             render editor toolbar

-- Focus --
::edfocus ( -- )               interactive code editor (focused)
::edfocusro ( -- )             read-only editor

-- Editor RAM Management --
::edram ( -- )                 allocate editor RAM

-- Widget Setup --
::edwin ( x y w h -- )         set editor window position/size
::edloadmem ( "" -- )          load text from string into editor
::edload ( "" -- )             load file into editor
::edsave ( -- )                save editor contents to file
```

---

```
::edlinenum! ( 0/1 -- )  show or hide the line number
::edlinenum ( -- 0/1 )
```

### imfiledlg.r3

File open/save dialog for immi.

**Dependencies:** `^r3/util/immi.r3`

```
::immfileload ( 'vecload 'file -- )  show load dialog
::immfilesave ( 'vecload 'file -- )  show save dialog
::fullfilename ( -- )                push current full path
::uiFileName ( 'var -- )             file name input widget
```

---

### immdatetime.r3

Calendar and time picker widgets for immi.

**Dependencies:** `^r3/lib/jul.r3`, `^r3/util/immi.r3`, `^r3/util/datetime.r3`

```
::uiDateTime ( 'var -- )  full date+time picker widget
::uiDate ( 'var -- )      date-only calendar widget
::uiTime ( 'var -- )      time-only picker widget
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
::flx! ( x y w h -- )            set frame
::flx ( -- )                     restore frame from stack
::flxpush ( -- )                 push current frame
::flxpop ( -- )                  pop frame
::flxRest ( -- )                 restore last
::flxvalid? ( -- 0= not valid )  0 = frame is not valid

-- Frame Splits --
::flxN ( lineas -- )             take from top
::flxS ( lineas -- )             take from bottom
::flxE ( cols -- )               take from right
::flxO ( cols -- )               take from left
::fw% ( -- w. )                  percent of frame width (48.16)
::fh% ( -- h. )                  percent of frame height

-- Utilities --
::flpad ( x y -- )               add padding to frame
::flin? ( x y -- 0/-1 )          is x,y inside current frame?
::flin?1 ( x y -- 0/-1 )         inside? (alternate)
```

#### Event Flags
```
##uikey            current key code

::exit ( -- )    end the SDLshow loop
::tuX? ( -- f )  check for pending action (local flag)
::tuR! ( -- )    request redraw
::tuC! ( -- )    enable cursor
```

#### Main Loop
```
::tui ( -- )             run TUI event loop
::onTui ( 'vector -- )   set main TUI handler
::onTuia ( 'vector -- )  set TUI handler (alternate, no clear)
::tuiw ( -- flag )       is current widget active? (interactive zone)
::tuiw1 ( -- flag )      1 line only zone
::tuif ( -- flag )       is focused?
::tuRefocus ( -- )       reset focus
```

#### Window Drawing
```
::.wfill ( -- )            fill current frame
::.wborde ( -- )           single-line border
::.wborded ( -- )          double-line border
::.wbordec ( -- )          corner-style border
::.wtitle ( place "" -- )  draw title in frame
::tuWin ( -- )             draw window (border+fill)
::tuWina ( -- )            draw window (no fill)
::.tdebug ( -- )           show debug info
```

#### Widgets
```
-- Buttons and Labels --
::tuTBtn ( 'ev "" -- )           toggle button
::tuBtn ( -- )                   standard button
::tuLabel ( "" -- )              left-aligned label
::tuLabelC ( "" -- )             centered label
::tuLabelR ( "" -- )             right-aligned label
::tuText ( "" align -- )         text with alignment

-- Lists --
::tuList ( 'var list -- )        scrollable list
::tuTree ( 'var list -- )        collapsible tree
::uiNindx ( n -- str )           get list item n

-- Input --
::tuInputLine ( 'buff max -- )   single-line text input
::tuCheck ( 'var "label" -- )    checkbox
::tuRadio ( n 'var "label" -- )  radio button (option n)
::tuSlider ( 'var min max -- )   slider
::tuProgress ( percent -- )      progress bar (0..100)

-- Write helpers --
::xwrite! ( -- )                 reset write state
::xwrite.reset ( -- )            reset accumulated write
##padi>                   write start offset

```

---

```
::fhome ( -- )                              top-left of the panel
::tuiexit                                   exit from tui
::onTuiResize ( vec -- )
::tuListN ( 'var listn -- )
::flVisibleIndex ( listadr adr -- idx/-1 )  adr debe ser un item de listadr
::pal! ( 'pal -- )
::cbg ( n -- )
::cfg ( n -- )
::fcr ( -- )                                next line (and reset the table columns)
::pan ( "title" -- )                        fondo bg1, padding 1, titulo en acento
::.lines ( 'v n -- )
::tcols ( 'def -- )
::hdr ( "a|b|c" -- )
::tbw ( -- n )                              total width of the boxed table
::tbrowc ( "a|b|c" 'color -- )              boxed table row, 'color = color word
::tbrow ( "a|b|c" -- )                      boxed table row
::tbhdr ( "a|b|c" -- )                      boxed table header
::flxRoot ( -- )                            fullscr
::flxC ( w h -- )                           frame w x h cent
::tuDlg ( "title" w h -- )
::tuDlgEnd ( -- )
```

### tuiedit.r3

Full-featured text editor widget for TUI framework. Supports selection, clipboard, and undo.

**Dependencies:** `^r3/util/tui.r3`, `^r3/lib/clipboard.r3`

```
##filename * 1024     current file path
##fuente              text buffer pointer
##fuente>             cursor pointer
##$fuente             end of text pointer

-- Cursor Control --
::tuiecursor! ( cursor -- )  set cursor to pointer
::tuipos! ( pos -- )         set cursor to integer position

-- Hash / Change Detection --

-- Key Handlers --
::tueKeyMove ( -- )          process cursor movement keys

-- Display --
::tuEditShowCursor ( -- )    display cursor
::tuecursor. ( -- )          render cursor indicator

-- Editor Modes --
::tuEditCode ( -- )          interactive code editor (normal fonts)
::tuReadCode ( -- )          read-only code display
::tuReadCodeMono ( -- )      read-only monospace display

-- File Operations --
::TuLoadMem ( "" -- )        load text from string
::TuLoadMemC ( "" -- )       load text (already sanitized)
::TuLoadCode ( "" -- )       load from file
::TuNewCode ( -- )           new/empty file
::TuSaveCode ( -- )          save to current ##filename

-- Marks (Syntax / Search) --
::tokenCursor ( 'mark -- )   set cursor to mark
```

---

```
::tuTheme! ( 'theme -- )     'themeold / 'themenew
::tuiposq! ( pos -- )
::tuelstart ( adr -- adr' )  start of the line of adr
::tuejpush ( -- )            saves the place of the cursor
::tuejdepth ( -- n )         how many places are saved (32 at most)
::tuejback ( -- )            back to the last saved place
::tuegodef ( -- )            goes to the definition of the word under the cursor, saving the place to come back
::tuefindword ( -- )         the next whole word like the one under the cursor (wraps), the place is saved
::tueinsat ( 'str adr -- )
::tuEditLN! ( n -- )         line number place
```

### vscreen.r3

Virtual resolution rendering. Renders to an internal texture at logical size, then scales to the actual window.

**Dependencies:** `^r3/lib/sdl2.r3`

```
::vscreen ( w h -- )  create a virtual screen of w x h pixels (a render target) shown in the window centered with the aspect ratio kept and linear filtering; it follows the window resizes
::vini ( -- )         start drawing into the virtual screen (it becomes the render target)
::vredraw ( -- )      draw the virtual screen in the window and present it
::vfree ( -- )        free the virtual screen texture

::sdlx ( -- x )       mouse x position (16 bits)
::sdly ( -- y )       mouse y position
::%w ( frac -- px )   fixed point fraction of the screen width (1.0 = sw) in pixels
::%h ( frac -- px )   fixed point fraction of the screen height (1.0 = sh) in pixels
```

---

```
::vscreenf ( w h -- )  like vscreen with nearest neighbor scaling (sharp pixels)
```

### tilesheet.r3

Tile map system with scrolling view.

**Dependencies:** `^r3/lib/mem.r3`, `^r3/lib/math.r3`, `^r3/lib/sdl2image.r3`, `^r3/lib/sdl2gfx.r3`

```
::[map] ( x y -- ad )                         address of tile at x,y in map
::loadtilemap ( "" -- amap )                  load tile map from file

-- Rendering --
::drawtile ( y x tile -- y x )                draw single tile
::tiledraw ( w h x y sx sy 'amap -- )         draw tilemap (sx/sy = scroll offset)
::tiledrawv ( w h x y sx sy 'amap 'vec -- )   draw + call 'vec for each tile
::tiledraws ( w h x y sx sy sw sh 'amap -- )  draw subregion of map
::tiledrawvs ( w h x y sx sy sw sh 'amap 'v -- )  draw subregion + callback

-- Coordinate Conversion --
::scr2view ( xs ys -- xv yv )                 screen to view coordinates
::scr2tile ( x y -- adr : only after tilemapdraw (set the vars) )  screen to tile address (valid after tiledraw)
```

---

### bmap.r3

Multi-layer tile map for 2D games with isometric and z-sorted sprite rendering.

**Dependencies:** `^r3/lib/rand.r3`, `^r3/lib/console.r3`, `^r3/lib/sdl2gfx.r3`, `^r3/util/arr16.r3`

```
##bsprdraw  draw sprite function pointer (redefine for custom sprite drawing)

::inisprite ( -- )           start the list of sprites drawn in order with the map rows (call it every frame before +sprite); the list is in free memory at here
::+sprite ( N x y -- )       add the sprite N at screen position x y to the sorted list; it is ignored if it is outside the screen
::drawmaps ( xvp yvp -- )    draw the map with its sprites from the viewport position xvp yvp in pixels (tiles of 32x32): back layers, then the sprites row by row, then the front layers
::loadmap ( "filename" -- )  load a map file (8 bytes header, mapw maph, mapw*maph cells of 64 bits, tilew tileh, tileset image name) and its tileset; the view is 34x23 tiles of 32 pixels
::bmap2xy ( x y -- x y )     tile position x y to the pixel position in the tileset size (x*tilew, y*tileh) as fixed point
::whbmap ( -- w h )          size of the map in tiles
::xyinmap@ ( x y -- cell )   map cell (64 bits) at the position x y given as fixed point pixels (no range check)
::xytrigger ( x y -- x y )   mark with the trigger flag (bit 51) the conditional tiles (bit 50) of the cells around x y; drawmaps clears the flag at the end of the frame
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
::]face ( nro -- FACE ( p1 p2 p3 color) )  address of face nro (fields: p1 p2 p3 color)
::]vert ( nro -- vertex )                  address of vertex nro
::]norm ( nro -- normal )                  address of normal nro
::]uv ( nro -- uv )                        address of UV coord nro

-- Material (MTL) Accessors --
::]Ka@  ::]Kd@  ::]Ks@  ::]Ke@   ambient/diffuse/specular/emission
::]Ns@  ::]Ni@  ::]d@   ::]i@    shininess/refraction/dissolve/illumination
::]Mkd@ ::]MNs@ ::]Mbp@           texture map filenames

-- Loading --
::loadobj ( "" -- mem )                    load OBJ file, return memory base

-- Geometry Operations --
##xmin ##ymin ##zmin ##xmax ##ymax ##zmax   bounding box (after objminmax)
::objminmax ( -- )                         compute bounding box of all vertices
::objmove ( x y z -- )                     translate all vertices
::objcentra ( -- )                         center model at origin
::objescala ( mul div -- )                 scale all vertices by mul/div
::objescalax ( mul div -- )                scale X only
::objescalay ( mul div -- )                scale Y only
::objescalaz ( mul div -- )                scale Z only
::objcube ( lado -- )                      generate a unit cube of side `lado`
::getpath ( str -- str )                   extract directory path from filepath
::>>cr ( adr -- adr' )                     address of the next CR or LF, or of the final 0
::cnt/ ( -- )                              count faces
```

---

### datetime.r3

Date and time formatting in Spanish. Provides string output words.

**Dependencies:** `^r3/lib/mem.r3`

```
-- Append to Heap (,time / ,date style) --
::,time ( -- )                 write the current time as h:mm:ss (hour without leading zero)
::,ti:me ( -- )                write the current time as h:mm with a blinking colon (a space on odd seconds)
::,date ( -- )                 write the current date as d/m/yyyy
::,date- ( -- )                write the current date as yyyy-mm-dd

-- Raw String Generation --
::str_DMA ( -- str )           the current date as " d/m/yyyy " in a temporary string (at here, valid until the next write to memory)
::str_HMS ( -- str )           the current time as " h:mm:ss " in a temporary string (at here)
::str_HM ( -- str )            the current time as " h:mm " (blinking colon) in a temporary string (at here)
::str_fullday ( -- str )       current date as "weekday, d month yyyy " in Spanish, zero-terminated, in a temporary string (BUG: the month name is one too far: date.m is 1..12 and >mesname takes 0..11)
::str_hhmmss ( -- str )        current time as hh:mm:ss (2 digits each), zero-terminated, in a temporary string (at here)

-- Day and Month Names --
::>dianame ( n -- str )        Spanish name of the weekday n (0 = domingo .. 6 = sabado), no range check
::>mesname ( n -- str )        Spanish name of the month n (0 = enero .. 11 = diciembre), no range check

-- SQL / Database Formats --
::dt2timesql ( 'timedate -- )  write a timedate (address from sysdate or filetimeD) as yyyy-mm-dd hh:mm:ss at here (no final 0)

-- 64-bit Packed DateTime --
::dt>64 ( 'timedate -- dt64 )  pack a timedate in 64 bits: year<<48 | month<<44 | weekday<<40 | day<<32 | hour<<24 | minute<<16 | second<<8 | ms>>2
::,64>dtf ( dt64 -- )          write a dt64 as dd/mm/yyyy hh:mm
::,64>dtd ( dt64 -- )          write the date of a dt64 as d/m/yyyy followed by a space
::,64>dtt ( dt64 -- )          write the time of a dt64 as hh:mm:ss
::64>dtc ( dt64 -- )           write a dt64 as date and time (BUG: it writes "yyyy mm-dd-hh:mm:ss"; the separator after the year should be - and the one after the day a space)
```

---

### dbtxt.r3

Text database: fields are separated by `|` and records by `^`.

**Dependencies:** `^r3/lib/console.r3`

```
##rowdb    current row pointer after search

-- File Loading --
::getnfilename ( n "path" -- filename/0 )  name of the nth file of a folder (Windows only: it uses the Windows directory entry layout); 0 if there are fewer
::loadnfile ( "path" -- filename )         incremental: each call returns the next file name of the folder, the position is kept in the file "path.now" and wraps to the first (Windows only)
::loaddb-i ( "filename" -- )               incremental: load the record number kept in "filename.now" and split it in fields (read them with dbfld), then advance to the next record (wraps at the end)
::prevdb-i ( "filename" -- )               step the position kept in "filename.now" back one record (the next loaddb-i loads the previous one)
::loaddb ( "filename" -- 'db )             load a text database (records field|field|..^) at here, where it stays, and return its address; 0 if the file is empty or missing

-- Record Iteration --
::>>line ( adr -- adr' )                   address after the next ^ (end of record), or the final 0 if there is none

-- Field Access --
::dbfld ( nro -- str )                     field nro (0 is the first) of the record loaded with loaddb-i; an empty string if there are fewer fields
::getdbrow ( id 'db -- 'row )              address of record number id (0 is the first) of a database loaded with loaddb
::findbrow ( 'key 'db -- 'row/0 )          first record whose first 8 bytes equal the 8 bytes at 'key (the original comment called it hash); 0 if none
::cntdbrow ( 'db -- cnt )                  number of records (count of ^); 0 if 'db is 0
::>>fld ( adr -- adr' )                    address after the next | (next field); it stops at a ^ (end of record) without skipping it
::getdbfld ( nro 'row -- 'fld )            address of field nro (0 is the first) of a record; the field ends at | or ^, not at a 0
::cpydbfld ( 'fld 'str -- )                copy the text of a field (up to | or ^) to 'str with a final 0
::cpydbfldn ( max 'fld 'str -- )           like cpydbfld copying at most max characters
```

---

### filedirs.r3

Filesystem scanner providing file/directory trees for UI list and tree widgets.

**Dependencies:** `^r3/lib/mem.r3`, `^r3/util/datetime.r3`, `^r3/util/tui.r3`

```
##uiDirs     pointer to directory list
##uiFiles    pointer to file list

-- File Path Operations --
::flcpy ( 'file 'str -- )                 copy a list entry up to | or the final 0 into 'str, with a final 0
::flTreePath ( n -- str )                 path of node n of the tree shown by the tui tree widget (it uses the widget state of tui: only meaningful inside it)

-- Scanning --
::FlGetFiles ( "path" -- )                fill uiFiles with the names of the files (no folders) of the folder; the memory was reserved by flScanDir
::flScanDir ( "path" -- )                 scan the folders under path recursively into uiDirs and reserve 64 KB for uiFiles; call it only once
::flScanFullDir ( "path" -- )             like flScanDir but uiDirs also has the files (the folders end with /)
::flOpenFullPath ( "root/a/b" -- place )  open the folders of a path in the uiDirs list of flScanFullDir (the first component, the root, is skipped; the string is modified); returns the row of the last entry in the visible tree
```

---

*End of r3forth `util/` Library Reference*

```
::flOpenSearch ( "text" -- adr/0 )  first entry of uiDirs that contains the text (ignoring case): its folders are opened and its address is returned; 0 if not found
::flCloseAll ( -- )                 close all the folders of uiDirs
```

