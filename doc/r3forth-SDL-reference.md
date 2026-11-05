# R3 Forth Graphics — Reference

---

## 1. Basics

Include `^r3/lib/sdl2gfx.r3` (it includes `sdl2.r3`). Stack comments read `in -- out`;
the top of the stack is the last value. For the syntax see the language manual.

```forth
^r3/lib/sdl2gfx.r3

:main
	0 cls  $ff0000 color  10 10 100 100 frect
	SDLredraw ;

: "demo" 800 600 SDLinit  'main SDLshow  SDLquit ;
```

---

## 2. Window & Main Loop

| Word | Stack | Description |
|---|---|---|
| `SDLinit` | `"title" w h --` | initialize SDL, create a centered window w x h with its renderer (SDL_windows, SDLrenderer, sw, sh) and raise it |
| `SDLmini` | `"title" w h --` | like SDLinit without raising the window |
| `SDLfullw` | `"title" display --` | borderless window with the size of the display (sets sw sh) |
| `SDLfull` | `--` | switch the window to fullscreen |
| `SDLdfullsw` | `display -- sw sh` | current resolution of the display |
| `SDLquit` | `--` | destroy the renderer and the window and quit SDL |
| `SDLshow` | `'word --` | main loop: SDLupdate and execute 'word every frame until exit is called |
| `exit` | `--` | end the SDLshow loop |
| `SDLupdate` | `--` | wait 10 ms and process the pending events, updating SDLkey, SDLchar, SDLx, SDLy, SDLb and SDLw |
| `sdlbreak` | `--` | debug stop: redraw and wait until F12 or ESC is pressed |
| `SDLeventR` | `'vec --` | word to execute when the window is resized (sw and sh are updated first) |
| `SDLClick` | `'event --` | execute 'event once when the mouse button is released after being pressed (call it every frame) |
| `SDLframebuffer` | `w h -- texture` | streaming texture w x h in ARGB8888 format, to draw pixels |
| `SDLblend` | `--` | enable alpha blending for the renderer drawing |
| `SDLTexwh` | `tex -- w h` | width and height of a texture (reads the SDL_Texture structure) |
| `%w` | `frac -- px` | fixed point fraction of the screen width (1.0 = sw) in pixels |
| `%h` | `frac -- px` | fixed point fraction of the screen height (1.0 = sh) in pixels |

### Variables

| Name | Description |
|---|---|
| `sw` / `sh` | Current window width / height (bare-fetch). Updated automatically on window resize. |
| `SDLkey` | Last key event code (bare-fetch). Key-down codes are the raw scancode; key-up codes have `$1000` OR'd in. |
| `SDLchar` | Last text-input character code. |
| `SDLx` / `SDLy` | Last mouse position. |
| `SDLb` | Mouse button bitmask. |
| `SDLw` | Mouse wheel delta for this frame. |

`msec` (milliseconds) is defined in `core.r3`.

---

## 3. Drawing Primitives

### Color

| Word | Stack | Description |
|---|---|---|
| `color` | `rgb --` | set the draw color from $RRGGBB (alpha 255) |
| `colorA` | `argb --` | set the draw color from $AARRGGBB |
| `cls` | `rgb --` | clear the target with the color $RRGGBB |

### Points, Lines, Rects

| Word | Stack | Description |
|---|---|---|
| `point` | `x y --` | draw a point |
| `getpixel` | `x y -- rgb` | color $RRGGBB of the pixel |
| `line` | `x1 y1 x2 y2 --` | draw a line |
| `lineH` | `x1 y x2 --` | horizontal line from x1 to x2 (both included) at y |
| `lineV` | `x y1 y2 --` | vertical line from y1 to y2 (both included) at x |
| `rect` | `x y w h --` | rectangle outline (same area as frect) |
| `frect` | `x y w h --` | filled rectangle (it covers x..x+w-1, y..y+h-1) |
| `round` | `r x y w h --` | outline of a rectangle x y w h with rounded corners of radius r |
| `fround` | `r x y w h --` | filled rectangle x y w h with rounded corners of radius r |

### Ellipses & Circles

| Word | Stack | Description |
|---|---|---|
| `ellipse` | `rx ry x y --` | ellipse outline with radii rx ry centered at x y |
| `fellipse` | `rx ry x y --` | filled ellipse with radii rx ry centered at x y |
| `circle` | `r x y --` | circle outline of radius r centered at x y |
| `fcircle` | `r x y --` | filled circle of radius r centered at x y |

### Triangle

| Word | Stack | Description |
|---|---|---|
| `triangle` | `x1 y1 x2 y2 x3 y3 --` | filled triangle |

`SDLredraw` (`-- `) presents the frame — call it once per frame after drawing.

---

## 4. Images & Sprites (single image)

| Word | Stack | Description |
|---|---|---|
| `loadimg` | `"" -- texture` | Load a PNG (etc.) file into a texture handle. |
| `image` | `x y img --` | draw the texture at x y with its own size |
| `images` | `x y w h img --` | draw the texture scaled to the rectangle x y w h |
| `imageb` | `'dst img --` | draw the whole texture into the box 'dst (x y w h, four int32) |
| `imagebb` | `'src 'dst img --` | draw the box 'src of the texture into the box 'dst (x y w h, four int32 each) |
| `sprite` | `x y img --` | draw the texture centered at x y |
| `spriteZ` | `x y zoom img --` | draw the texture centered at x y with zoom (fixed point, 1.0 = normal size) |
| `spriteR` | `x y ang img --` | draw the texture centered at x y rotated by ang (1.0 = full turn) |
| `spriteRZ` | `x y ang zoom img --` | draw the texture centered at x y rotated by ang (1.0 = full turn) with zoom (fixed point) |

---

## 5. Sprite Sheets

A sprite sheet is a single image cut into a grid of equal `w × h` frames.

| Word | Stack | Description |
|---|---|---|
| `ssload` | `w h "file" -- ssprite` | load an image as a spritesheet of frames w x h (left to right, top to bottom) for the ssprite words; the table is kept in memory at here |
| `sscnt` | `ssprite -- ssprite n` | number of frames (only right after ssload, while here has not changed) |
| `sspritewh` | `ssprite -- w h` | size of a frame |
| `sstint` | `argb --` | tint color $AARRGGBB (with alpha) used by the ssprite words |
| `ssnotint` | `--` | no tint for the ssprite words ($ffffffff) |
| `ssprite` | `x y n ssprite --` | draw frame n of the spritesheet centered at x y |
| `sspriter` | `x y ang n ssprite --` | draw frame n centered at x y rotated by ang (1.0 = full turn) |
| `sspritez` | `x y zoom n ssprite --` | draw frame n centered at x y with zoom (fixed point, 1.0 = normal size) |
| `sspriterz` | `x y ang zoom n ssprite --` | draw frame n centered at x y rotated by ang (1.0 = full turn) with zoom |

---

## 6. Tilesets

A tileset packs many same-size tiles from one image, indexed by number, and is meant
to be drawn with an explicit destination position each time (as opposed to sprite
sheets, which auto-center).

| Word | Stack | Description |
|---|---|---|
| `tsload` | `w h "file" -- ts` | load an image as a tileset of tiles w x h (left to right, top to bottom); the table is kept in memory at here |
| `tscolor` | `rgb ts --` | color modulation $RRGGBB of the tileset texture |
| `tsalpha` | `alpha ts --` | alpha modulation (0..255) of the tileset texture |
| `tsdraw` | `n ts x y --` | draw tile n of the tileset at x y (its own size) |
| `tsdraws` | `n ts x y w h --` | draw tile n scaled to the rectangle x y w h |
| `tsbox` | `'box n ts --` | fill the 'box (x y w h, four int32) with the source rectangle of tile n |
| `tsfree` | `ts --` | free the texture of the tileset (the table stays in memory) |

---

## 7. Textures & Surfaces (advanced / off-screen rendering)

| Word | Stack | Description |
|---|---|---|
| `createSurf` | `w h -- surface` | create a 32-bit ARGB surface |
| `Surf>pix` | `surface -- surface pixels` | also leave the address of the pixels |
| `Surf>wha` | `surface -- surface 'wh` | also leave the address of w and h (two int32) |
| `Surf>wh` | `surface -- surface w h` | also leave the width and the height |
| `Surf>pixpi` | `surface -- pixels pitch` | address of the pixels and bytes per row (the surface is consumed) |
| `texIni` | `w h --` | create a target texture w x h and draw into it (instead of the window) until texEnd; only one at a time |
| `texEnd` | `-- texture` | stop drawing into the texture, back to the window, and return the texture |
| `texEndAlpha` | `-- texture` | like texEnd with alpha blending enabled on the texture |
| `Tex2Surface` | `tex -- tex surface` | copy the pixels of a target texture into a new surface |
| `Tex2Static` | `tex -- newtex` | convert a target texture into a static one (the original texture is freed) |

---

## 8. Timers & Frame Animation

| Word | Stack | Description |
|---|---|---|
| `timer<` | `--` | reset the timer (deltatime = 0) |
| `timer.` | `--` | update the timer: deltatime = milliseconds since the previous call |
| `timer+` | `n -- n'` | add deltatime to n |
| `timer-` | `n -- n'` | subtract deltatime from n |

Packed animation values (`V`) encode a start frame, frame count, and playback speed
into one 64-bit cell:

| Word | Stack | Description |
|---|---|---|
| `aniInit` | `ini cnt fps -- V` | value of a frame animation: first frame ini (12 bits), cnt frames (up to 256) and fps in fixed point (10.0 = 10 frames per second, 0 = still) |
| `ani+!` | `dt 'V --` | advance the frame animation in 'V by dt milliseconds: as many frames as dt covers (the time left over is kept); after the last frame it goes back to the first |
| `ani+timer!` | `'V --` | advance the frame animation in 'V by deltatime |
| `aniFrame` | `V -- f` | current frame number (ini + step) |
| `aniCnt` | `V -- n` | current step 0..cnt-1 of the animation (it is not the number of frames) |

---

## 9. Text & Fonts

### Loading & selecting a font

| Word | Stack | Description |
|---|---|---|
| `txload` | `"font" size -- nfont` | like txloadwicon without the icons |
| `txloadwicon` | `"font" size -- nfont` | load a TTF font at that size into an atlas texture (ASCII 32..127, the accented letters of the utf8 list and the Font Awesome icons of media/ttf/Font Awesome 7 Free-Solid-900.otf from code 192); returns the atlas (texture and table kept at here) |
| `txfont` | `font --` | select the atlas font (from txload) used by the tx words |
| `txfont@` | `-- font` | the atlas font selected now |

### Color, cursor, metrics

| Word | Stack | Description |
|---|---|---|
| `txrgb` | `c --` | color $RRGGBB of the font texture (color modulation) |
| `txat` | `x y --` | move the cursor to the pixel position x y |
| `tx+at` | `x y --` | move the cursor by x y pixels |
| `txpos` | `-- x y` | cursor position in pixels |
| `txcr` | `--` | new line: x = 0 and y down one line height |
| `txcw` | `adr car -- adr' width` | width in pixels of a character: car is the byte just read at adr-1; a two byte accented character reads its second byte (adr' is after it) |
| `txw` | `"" -- "" width` | width in pixels of the string |
| `txch` | `adr car -- adr' h` | height of a character (same protocol as txcw) |
| `txh` | `-- h` | height of the font (line height) |

### Drawing text

| Word | Stack | Description |
|---|---|---|
| `txemit` | `adr car -- adr'` | draw one character at the cursor and advance it (same protocol as txcw) |
| `txwrite` | `"" --` | draw the string at the cursor |
| `txemitr` | `"" --` | draw the string right aligned: it ends at the cursor x |
| `txprint` | `.. "" --` | formatted print (see sprint) at the cursor |
| `txprintr` | `.. "" --` | formatted print right aligned |
| `lwrite` | `w "str" --` | left aligned text for txText (ignores w) |
| `cwrite` | `w "str" --` | centered text in w pixels for txText |
| `rwrite` | `w "str" --` | right aligned text in w pixels for txText |
| `txalign` | `$VH --` | alignment for txText: low 2 bits horizontal (0 left, 1 center, 2 right), bits 4-5 vertical (0 top, 1 center, 2 bottom) |
| `txText` | `w h x y "" --` | draw the string wrapped by words in the box x y w h with the txalign alignment; CR, LF and ; start a new line |


### Text cursor / caret drawing

| Word | Stack | Description |
|---|---|---|
| `txcur` | `str cur --` | fill with the draw color the block cursor of the character at cur (an address inside str); it moves the cursor x to that character |
| `txcuri` | `str cur --` | like txcur but a bar of a quarter of the height at the bottom (insert cursor) |

### Single-line text input widget

`txfont.r3` includes a small line editor:

| Word | Stack | Description |
|---|---|---|
| `pad.reset` | `'var max -- 'var max` | prepare the line editor on the buffer 'var of max bytes: cursor at the end, insert mode |
| `pad.draw` | `'buff --` | draw the edited line at the cursor with a blinking cursor and handle the keys: SDLchar to insert or overwrite, left, right, backspace, delete, home, end and insert to change the mode |

---

## 10. Random numbers and lists

`rand.r3` (random numbers) and `arr16.r3` (object lists) are described in the library
reference (`r3forth-libs.md`, `r3forth-util.md`).

---

## 11. Key constants (`sdlkeys.r3`)

`SDLkey` holds the last key event. `<key>` is the key-down code and `>key<` the key-up
code (`$1000` added). Examples: `<esc> >esc<`, `<ret> >ret<`, `<spc> >spc<`,
`<back>`, `<tab>`, `<del>`, `<home> <end> <pgup> <pgdn>`, `<ins>`, `<up> <dn> <le> <ri>`,
`<F1>`..`<F12>`, the letters `<a>`..`<z>`, the digits `<0>`..`<9>` and `<ctrl> <shift> <alt>`.

---

## 12. Raw `SDL_*` bindings

`sdl2.r3` also wraps most of the SDL2 C API (`SDL_CreateWindow`, `SDL_RenderCopy`,
`SDL_SetRenderDrawColor`, ...). The words above are built on them; use them directly only
for something the high-level words do not offer.
