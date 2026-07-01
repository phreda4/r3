# R3 Forth Graphics — Reference


---

## 1. Basic R3 Syntax

```forth
| This is a comment
^lib/file.r3     | Import library

#name             | Declare a local/file-scope variable
##name            | Declare a global variable (visible across files, used by the
                  | library itself for shared state like screen size, key state)
'name             | Get the address of a variable or word
!                 | Store value at address
@                 | Fetch value from address
+!                | Add value to variable (at address)
name              | A bare variable name FETCHES its current value
                  | (e.g. `sw`, `sh`, `SDLkey` are used bare throughout the library)

:word_name        | Define a private word (only usable within the same file/module)
    code here
    ;
::word_name       | Define an exported/public word (usable from any file that
    code here     | imports this one — this is the convention used for every
    ;             | public API word in the library, e.g. `::SDLColor`, `::sprite`)
```

### Stack Notation

```forth
10 20 +    | Pushes 10, then 20, then adds them (result: 30)
```

Stack comments in this reference use the form `| in1 in2 -- out1`, read left-to-right,
bottom-of-stack to top-of-stack. Where a word takes a string, the string address is
always the top item (pushed last).

---

## 2. Window & Main Loop

| Word | Stack | Description |
|---|---|---|
| `SDLinit` | `"title" w h --` | Create a window + renderer of the given size. |
| `SDLmini` | `"title" w h --` | Same as `SDLinit` but does not raise/focus the window. |
| `SDLfullw` | `"title" display --` | Create a fullscreen window on the given display index. |
| `SDLfull` | `--` | Switch the current window to fullscreen. |
| `SDLdfullsw` | `display -- w h` | Get the current display mode's width/height. |
| `SDLquit` | `--` | Destroy renderer/window and shut down SDL. |
| `SDLshow` | `'word --` | Run `word` every frame (polling events first) until `exit` is called from inside it. |
| `exit` | `--` | Ends the current `SDLshow` loop after the current frame. |
| `SDLupdate` | `--` | Poll and process one batch of SDL events, updating `SDLkey`, `SDLchar`, `SDLx/SDLy`, `SDLb`, `SDLw`. Called automatically by `SDLshow`; rarely called directly. |
| `sdlbreak` | `--` | Convenience: redraw, then block until F12 or ESC is pressed. |
| `SDLeventR` | `'vec --` | Register a callback vector for raw events. |
| `SDLClick` | `'event --` | Click-and-hold helper built on the mouse-button state. |
| `SDLframebuffer` | `w h -- texture` | Create an off-screen render target texture. |
| `SDLblend` | `--` | Enable alpha blending on the renderer. |
| `SDLTexwh` | `tex -- w h` | Get a texture's width/height. |
| `%w` | `-- px` | Convert a screen-relative fixed-point fraction to a pixel width (`sw` scaled). |
| `%h` | `-- px` | Same as `%w` for screen height (`sh`). |

### Variables

| Name | Description |
|---|---|
| `sw` / `sh` | Current window width / height (bare-fetch). Updated automatically on window resize. |
| `SDLkey` | Last key event code (bare-fetch). Key-down codes are the raw scancode; key-up codes have `$1000` OR'd in. |
| `SDLchar` | Last text-input character code. |
| `SDLx` / `SDLy` | Last mouse position. |
| `SDLb` | Mouse button bitmask. |
| `SDLw` | Mouse wheel delta for this frame. |

`msec` is **not defined** in any of the five files reviewed — it's presumably a thin wrapper over `SDL_GetTicks` living in `console.r3`, which wasn't provided.

---

## 3. Drawing Primitives

### Color

| Word | Stack | Description |
|---|---|---|
| `SDLColor` | `col --` | Set the draw color from a `$RRGGBB` value (opaque). |
| `SDLColorA` | `col --` | Set the draw color from a `$AARRGGBB` value (with alpha). |
| `SDLcls` | `col --` | Clear the screen to `col` (calls `SDLColor` then clears). |

### Points, Lines, Rects

| Word | Stack | Description |
|---|---|---|
| `SDLPoint` | `x y --` | Draw a single pixel. |
| `SDLGetPixel` | `x y -- v` | Read back a pixel's color from the render target. |
| `SDLLine` | `x1 y1 x2 y2 --` | Draw a line between two points. |
| `SDLLineH` | `x1 y x2 --` | Fast path for a horizontal line. |
| `SDLLineV` | `x y1 y2 --` | Fast path for a vertical line. |
| `SDLRect` | `x y w h --` | Draw a rectangle outline. |
| `SDLFRect` | `x y w h --` | Draw a filled rectangle. |
| `SDLRound` | `r x y w h --` | Draw a rounded-rectangle outline with corner radius `r`. |
| `SDLFRound` | `r x y w h --` | Draw a filled rounded rectangle. |

### Ellipses & Circles

| Word | Stack | Description |
|---|---|---|
| `SDLEllipse` | `rx ry cx cy --` | Draw an ellipse outline. **Radii come before the center point.** |
| `SDLFEllipse` | `rx ry cx cy --` | Draw a filled ellipse. |
| `SDLCircle` | `r x y --` | Draw a circle outline. |
| `SDLFCircle` | `r x y --` | Draw a filled circle. |

### Triangle

| Word | Stack | Description |
|---|---|---|
| `SDLTriangle` | `x1 y1 x2 y2 x3 y3 --` | Draw a filled, solid-color triangle. |

`SDLredraw` (`-- `) presents the frame — call it once per frame after drawing.

---

## 4. Images & Sprites (single image)

| Word | Stack | Description |
|---|---|---|
| `loadimg` | `"file" -- img` | Load a PNG (etc.) file into a texture handle. **(unverified — from `sdl2image.r3`)** |
| `SDLImage` | `x y img --` | Draw an image at its native size. |
| `SDLImages` | `x y w h img --` | Draw an image scaled into a `w × h` box. |
| `SDLImageb` | `box img --` | Draw an image into a packed destination rect. |
| `SDLImagebb` | `srcbox dstbox img --` | Draw a sub-rect of an image into a destination rect. |
| `sprite` | `x y img --` | Draw an image centered on `(x, y)`. |
| `spriteZ` | `x y zoom img --` | Centered sprite draw with zoom (16.16 fixed point). |
| `spriteR` | `x y ang img --` | Centered sprite draw, rotated (fixed-point angle). |
| `spriteRZ` | `x y ang zoom img --` | Centered sprite draw, rotated and zoomed. |

---

## 5. Sprite Sheets

A sprite sheet is a single image cut into a grid of equal `w × h` frames.

| Word | Stack | Description |
|---|---|---|
| `ssload` | `w h "file" -- ssprite` | Load an image and slice it into `w × h` frames. |
| `sscnt` | `ssprite -- ssprite nframes` | Get the frame count. Only valid immediately after `ssload`, before more memory is allocated. |
| `sspritewh` | `adr -- h w` | Internal: get a sheet's per-frame height/width. |
| `sstint` | `color --` | Tint the *current* sprite-sheet quad (with alpha: `$AARRGGBB`). |
| `ssnotint` | `--` | Reset tint to opaque white (no tint). |
| `ssprite` | `x y n sheet --` | Draw frame `n`, centered on `(x, y)`. |
| `sspriter` | `x y ang n sheet --` | Draw frame `n`, rotated. |
| `sspritez` | `x y zoom n sheet --` | Draw frame `n`, zoomed. |
| `sspriterz` | `x y ang zoom n sheet --` | Draw frame `n`, rotated and zoomed. |

---

## 6. Tilesets

A tileset packs many same-size tiles from one image, indexed by number, and is meant
to be drawn with an explicit destination position each time (as opposed to sprite
sheets, which auto-center).

| Word | Stack | Description |
|---|---|---|
| `tsload` | `w h "file" -- ts` | Load a tile image cut into `w × h` tiles. |
| `tscolor` | `rrggbb 'ts --` | Tint a tileset's texture. |
| `tsalpha` | `alpha 'ts --` | Set a tileset's overall alpha. |
| `tsdraw` | `n 'ts x y --` | Draw tile `n` at its native size at `(x, y)` (top-left). |
| `tsdraws` | `n 'ts x y w h --` | Draw tile `n` scaled into a `w × h` box at `(x, y)`. |
| `tsbox` | `'boxsrc n 'ts --` | Copy a tile's source-rect metadata into a custom box. |
| `tsfree` | `ts --` | Destroy a tileset's texture. |

---

## 7. Textures & Surfaces (advanced / off-screen rendering)

| Word | Stack | Description |
|---|---|---|
| `createSurf` | `w h -- surface` | Allocate a blank 32-bit ARGB surface. |
| `Surf>pix` | `surface -- surf pixels` | Get a surface's pixel buffer pointer. |
| `Surf>wha` | `surface -- addr` | Address of a surface's width/height/pitch header. |
| `Surf>wh` | `surface -- surf w h` | Get a surface's width/height. |
| `Surf>pixpi` | `surface -- 'pixel pitch` | Get pixel pointer and row pitch together. |
| `texIni` | `w h --` | Begin rendering into a new off-screen texture of size `w × h` (redirects the renderer). |
| `texEnd` | `-- texture` | Stop redirecting the renderer; return the finished texture. |
| `texEndAlpha` | `-- texture` | Same as `texEnd`, and also enables alpha blend mode on the result. |
| `Tex2Surface` | `tex -- tex surface` | Copy a texture's pixels into a new CPU-side surface. |
| `Tex2Static` | `tex -- newtexture` | Convert a (possibly render-target) texture into a static texture; frees the intermediate surface. |

---

## 8. Timers & Frame Animation

| Word | Stack | Description |
|---|---|---|
| `timer<` | `--` | Reset the global frame timer. |
| `timer.` | `--` | Advance the timer; call once per frame (usually first thing in your draw word). |
| `timer+` | `n -- n'` | Add the last frame's delta time to `n`. |
| `timer-` | `n -- n'` | Subtract the last frame's delta time from `n`. |

Packed animation values (`V`) encode a start frame, frame count, and playback speed
into one 64-bit cell:

| Word | Stack | Description |
|---|---|---|
| `aniInit` | `ini cnt fps -- V` | Build a packed animation value. `fps = 0` makes a still frame. |
| `ani+!` | `dt 'v --` | Advance the packed value at address `'v` by `dt` milliseconds, in place. |
| `ani+timer!` | `'V --` | Convenience: advance the packed value at `'V` by this frame's delta time, in place. Call once per frame. |
| `aniFrame` | `V -- f` | Get the current frame number from a packed value. |
| `aniCnt` | `V -- c` | Get the frame count encoded in a packed value. |

---

## 9. Text & Fonts

### Loading & selecting a font

| Word | Stack | Description |
|---|---|---|
| `txload` | `"file" size -- font` | Load a TrueType font at `size` and build a glyph atlas for ASCII 32+ plus the accented/Latin set in `#utf8`. |
| `txloadwicon` | `"file" size -- font` | Same as `txload`, plus a bundled Font Awesome icon set appended to the atlas. |
| `txfont` | `font --` | Set the current font (from `txload`/`txloadwicon`). |
| `txfont@` | `-- font` | Get the current font. |

### Color, cursor, metrics

| Word | Stack | Description |
|---|---|---|
| `txrgb` | `color --` | Set text color (tints the font atlas texture). |
| `txat` | `x y --` | Set the text cursor position. |
| `tx+at` | `dx dy --` | Move the text cursor by a relative offset. |
| `txpos` | `-- x y` | Get the current cursor position. |
| `txcr` | `--` | Move cursor to `x=0` and down one line (current font's line height). |
| `txcw` | `char -- w` | Width of a single character. |
| `txw` | `"str" -- "str" w` | Total pixel width of a string. |
| `txch` | `char -- h` | Height of a single character. |
| `txh` | `-- h` | Current font's line height. |

### Drawing text

| Word | Stack | Description |
|---|---|---|
| `txemit` | `char --` | Draw a single decoded character at the cursor and advance the cursor. |
| `txwrite` | `"str" --` | Draw a string at the cursor (no wrapping), advancing the cursor. |
| `txemitr` | `"str" --` | Draw a string ending at the cursor (right-aligned from cursor), i.e. offsets left by the string width first. |
| `txprint` | `.. "str" --` | Format (`%d`/`%f`-style args before the string, printf-style) and draw at the cursor. |
| `txprintr` | `.. "str" --` | Same as `txprint`, right-aligned from the cursor. |
| `lwrite` | `w "str" --` | Internal: left-aligned line writer used by `txText`. |
| `cwrite` | `w "str" --` | Internal: horizontally-centered line writer used by `txText`. |
| `rwrite` | `w "str" --` | Internal: right-aligned line writer used by `txText`. |
| `txalign` | `$VH --` | Set alignment for `txText`. Low 2 bits = horizontal (`0`=left,`1`=center,`2`=right); bits 4–5 = vertical (`0`=top,`1`=center,`2`=bottom). Combine with `or`, e.g. `$11` = centered both ways, `$02` = right-aligned/top, `$20` = left-aligned/bottom. |
| `txText` | **`w h x y "str" --`** | Render (auto-wrapped, multi-line) text inside a `w × h` box positioned at `(x, y)`, honoring `txalign`. |


### Text cursor / caret drawing

| Word | Stack | Description |
|---|---|---|
| `txcur` | `str cur --` | Draw a solid block caret at character index `cur` in `str` (insert-mode look). |
| `txcuri` | `str cur --` | Draw a thin underline-style caret (overwrite-mode look). |

### Single-line text input widget

Not covered anywhere in the original doc — `txfont.r3` includes a small line-editor:

| Word | Stack | Description |
|---|---|---|
| `pad.reset` | `'buffer max --` | Initialize an editable text buffer of capacity `max`. |
| `pad.draw` | `'buffer --` | Draw the buffer at the cursor, blink the caret, and handle character input plus arrow keys/Home/End/Backspace/Delete/Insert (toggles insert vs. overwrite mode) for that frame. Call every frame while the field is focused. |

---

## 10. Random Numbers (`rand.r3`)

The library ships four independent generators; `rand`/`randmax` (a 64-bit
multiply-add LCG) is the one used throughout the example programs.

| Word | Stack | Description |
|---|---|---|
| `rand` | `-- r` | Next raw random 64-bit value (multiply-add generator). |
| `randmax` | `max -- r` | Random value in `0 .. max` inclusive-ish (masks off the sign). |
| `randminmax` | `min max -- r` | Random value in `min .. max`. |
| `rand8` | `-- r8` | Small 8-bit noise generator, separate seed (`seed8`). |
| `rerand` | `s1 s2 --` | Re-seed the main `rand` generator from two values. |
| `rnd` | `-- r` | Alternate xorshift-based generator. |
| `rndmax` | `max -- r` | `randmax` equivalent using `rnd`. |
| `rndminmax` | `min max -- r` | `randminmax` equivalent using `rnd`. |
| `rnd128` | `-- n` | xorshift128+ generator (separate `state0`/`state1` seed). |
| `loopMix128` | `-- rand` | LoopMix128 generator (see the source comment's linked reference). |

---

## 11. Dynamic Arrays / Object Lists (`arr16.r3`)

A "list" here is a fixed-stride (128-byte element) dynamic array with fast
unordered or order-preserving removal, backed by `mem.r3` (not provided). Declare
one with `#mylist 0 0`.

| Word | Stack | Description |
|---|---|---|
| `p.ini` | `capacity list --` | Allocate storage for `capacity` elements. |
| `p.clear` | `list --` | Empty the list (keeps allocated storage). |
| `p.cnt` | `list -- cnt` | Number of elements currently in the list. |
| `p!` | `list -- adr` | Reserve space for one new element and return its address (caller fills fields manually). |
| `p!+` | `'act list -- adr` | Same as `p!`, but also stores an update/draw word `'act` into the element's first field. |
| `p.adr` | `nro list -- adr` | Element index → address. |
| `p.nro` | `adr list -- nro` | Element address → index. |
| `p.del` | `adr list --` | Remove the element at `adr` (order-preserving). |
| `p.draw` | `list --` | Traverse all elements calling each one's stored word; **fast/unordered** removal when it returns `0`. |
| `p.drawo` | `list --` | Same as `p.draw`, but removal preserves the order of remaining elements. |
| `p.mapv` | `'vector list --` | Call `'vector` for every element (no removal support). |
| `p.mapd` | `'vector list --` | Same as `p.mapv`, but removes an element if the call returns `0`. |
| `p.map2` | `'vector list --` | Call `'vector` for every *pair* of elements (triangular traversal — e.g. pairwise collision checks). |
| `p.sort` | `col list --` | One bubble-sort pass over column `col` (an `ncell+`-style field index). Call every frame for an animated/converging sort. |
| `p.isort` | `col list --` | Same as `p.sort`, descending. |

`ncell+` (used by example object-accessor words like `.x`, `.y`, `.ani`) is **not
defined** in `arr16.r3` — it most likely comes from `mem.r3`, which wasn't provided.

---

## 12. Generic Forth (not library-specific, listed for completeness)

```forth
+ - * /            | Basic arithmetic
neg                | Negate
<< >> >>>           | Bit shifts (>>> likely unsigned/logical)
and or xor         | Bitwise ops
< > =              | Comparisons
<? >? =? <>?       | Conditional execution: consumes/tests, runs ( ... ) if true
dup drop swap over 2dup 2drop pick2/pick3/pick4
int.               | Fixed-point to integer
```

### Key Constants **(unverified — from `sdlkeys.r3`)**

```forth
>esc<                 | ESC key released
<w> <a> <s> <d>       | WASD keys pressed
>w< >a< >s< >d<       | WASD keys released
<spc>                 | Space key pressed
```
By convention seen in `SDLupdate`: `<key>` (pressed) reads as the raw scancode;
`>key<` (released) is the same scancode with `$1000` OR'd in. Exact constant
values weren't in the files reviewed.

---

## 13. Note on the raw `SDL_*` bindings

`sdl2.r3` also defines a direct 1:1 wrapper for most of the SDL2 C API
(`SDL_CreateWindow`, `SDL_RenderCopy`, `SDL_SetRenderDrawColor`, …). These are what
the higher-level `SDLxxx` words above are built from; application code normally
never calls them directly, so they're intentionally left out of the word tables
above. They're listed here only so you know they exist if you need something the
higher-level API doesn't expose.
