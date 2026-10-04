# R3Forth Console Guide

A practical guide to writing terminal programs with `r3/lib/console.r3`.
For the complete word list see [libs/r3forth-lib-console.md](libs/r3forth-lib-console.md);
for widgets (tables, menus, inputs) see [libs/r3forth-lib-tui.md](libs/r3forth-lib-tui.md).

Every snippet below was compiled and run on Linux.

---

## 1. Minimal program

```forth
^r3/lib/console.r3

:main
	.cls
	.Green "Success: " .write
	.Reset "Operation completed" .write .cr
	255 128 0 .fgrgb "orange" .write .Reset .cr
	rows cols "terminal: %dx%d" .println
	"press any key" .write
	waitkey ;

: .hidec main .showc .free ;
```

- `^r3/lib/console.r3` loads the right backend for the platform (`|LIN|`, `|WIN|`,
  `|MAC|` lines inside the library are compiled only on that platform).
- While the program runs the terminal is in **raw mode**: no echo, no line buffering,
  and Ctrl+C does not stop the program (it arrives as key `$03`). Always give the user
  a way out (usually ESC).
- Finish with `.free`. It restores the terminal and shows the cursor. It does **not** flush the
  output buffer: end with `.flush` (or `.println`, `getch`) or the last text is lost.
- `cols` and `rows` hold the terminal size (see [Resize](#6-events-mouse-and-resize)).

---

## 2. Output

All `.xxx` output words write to an internal buffer (about 8 KB). Nothing is visible
until the buffer is flushed.

| Word | Stack | Flushes? | Use |
|---|---|---|---|
| `.write` | `"str" --` | no | plain text, **no format** |
| `.print` | `args.. "fmt" --` | no | formatted text |
| `.println` | `args.. "fmt" --` | yes | formatted text + newline |
| `.fwrite` / `.fprint` | same as above | yes | write/print + flush |
| `.type` | `str cnt --` | no | raw bytes, needs the length |
| `.emit` | `char --` | no | one byte |
| `.uemit` | `codepoint --` | no | one Unicode character (UTF-8) |
| `.cr` `.sp` | `--` | no | newline, space |
| `.nch` | `char n --` | no | repeat a byte `n` times (not multibyte) |
| `.rep` | `n "str" --` | no | repeat a string `n` times |
| `.flush` | `--` | - | send the buffer to the terminal |

The buffer is flushed by `.println`, `.flush`, `getch` (and so `waitkey`, `.input`),
and automatically when it fills up. A full-screen frame should be drawn with many
`.write`/`.print` calls and **one** `.flush` at the end.

### Format codes (`.print`, `.println`, `sprint`)

| Code | Prints |
|---|---|
| `%d` | decimal integer |
| `%h` | hexadecimal |
| `%b` / `%o` | binary / octal |
| `%s` | string |
| `%k` | one character |
| `%f` / `%m` / `%a` | fixed point (16.16) with 4 / 2 / 1 decimals |
| `%w` | one word of a string |
| `%l` | one line of a string |
| `%%` | a `%` |

```forth
65 10 5 255 "hex %h  bin %b  oct %o  chr %k" .println	| hex FF  bin 101  oct 12  chr A
3.25 3.25 "fixed %f / %m" .println						| fixed 3.2500 / 3.25
50 "100%%" .println
```

### Argument order

Arguments are pushed in the **reverse order** of the `%` codes: the first `%` takes
the value on top of the stack.

```forth
1 2 3 "%d %d %d" .println			| prints: 3 2 1
rows cols "%dx%d" .println			| prints: <cols>x<rows>
```

To get `a b c` printed in that order, push `c b a`.

---

## 3. Cursor and screen

Coordinates are **1-based**: `1 1 .at` is the top-left cell. The order is `x y`
(column, row).

| Word | Stack | Effect |
|---|---|---|
| `.at` | `x y --` | move the cursor |
| `.col` | `x --` | move to column x |
| `.home` | `--` | cursor to 1,1 (does not clear) |
| `.cls` | `--` | clear screen and go home |
| `.eline` | `--` | erase from the cursor to end of line |
| `.escreen` / `.escreenup` | `--` | erase to end / to start of screen |
| `.nsp` | `n --` | blank `n` cells **without moving** the cursor |
| `.savec` / `.restorec` | `--` | save / restore cursor position |
| `.hidec` / `.showc` | `--` | hide / show cursor |
| `.insc` `.blockc` `.underc` `.ovec` | `--` | cursor shape |
| `.alsb` / `.masb` | `--` | enter / leave the alternate screen |
| `.scrolloff` / `.scrollon` | `rows --` / `--` | restrict / restore the scrolling region |

**Alternate screen.** Full-screen programs should wrap everything in
`.alsb` ... `.masb`: the user's shell history is restored on exit.

**`.home` vs `.cls`.** For animation redraw with `.home` and overwrite; `.cls` on
every frame flickers.

### Status bar idiom

`.nsp` paints the cells with the current attributes but leaves the cursor where it
was, so the text written next lands on top of the painted bar:

```forth
:statusbar | "text" --
	.savec
	1 rows .at .Rever cols .nsp .write .Reset
	.restorec ;
```

### Box drawing and Unicode

Text in the source is UTF-8, so box characters can be written directly. `.uemit` takes a
code point.

```forth
^r3/lib/console.r3

#bx #by #bw #bh

:hline | n --
	( 1? 1- "─" .write ) drop ;

:box | x y w h --			; w h = inner size
	'bh ! 'bw ! 'by ! 'bx !
	bx by .at "┌" .write bw hline "┐" .write
	0 ( bh <?
		bx over by + 1+ .at "│" .write 32 bw .nch "│" .write
		1+ ) drop
	bx by bh + 1+ .at "└" .write bw hline "┘" .write ;

:main
	.cls
	10 3 20 3 box
	12 4 .at "héllo wörld " .write $263a .uemit
	1 9 .at .flush
	waitkey ;

: .hidec main .showc .free ;
```

---

## 4. Colors and attributes

Word names are not case sensitive (`.Reset` = `.reset`).

| Group | Words |
|---|---|
| Foreground 8 colors | `.Black .Red .Green .Yellow .Blue .Magenta .Cyan .White` |
| Foreground bright | same names with `l`: `.Redl .Greenl ...` |
| Background | `.BBlack .BRed ...` and `.BRedl ...` |
| 256 colors | `n .fc` (foreground), `n .bc` (background) |
| True color | `r g b .fgrgb`, `r g b .bgrgb` |
| Attributes | `.Bold .Dim .Ital .Under .Blink .Rever .Hidden .Strike`; `.NBold .NItal .NUnder .NRever` turn off |
| Reset | `.Reset` |

Colors and attributes **stay active** until changed. Call `.Reset` before leaving a
colored region, and before `.free`.

```forth
.Redl "error" .write .Reset
196 .fc "256 color" .write .Reset
255 128 0 .fgrgb "orange" .write .Reset
```

For per-pixel true color (plasma, fire, etc.) draw two pixels per cell with the half
block `▀`: foreground = upper pixel, background = lower pixel. A complete example is
`r3/term/colorscene.r3`.

---

## 5. Keyboard

| Word | Stack | Behavior |
|---|---|---|
| `inkey` | `-- key` | key pressed now, `0` if none (does not wait) |
| `getch` | `-- key` | flushes the output, waits for a key |
| `waitkey` | `--` | wait for any key |
| `waitesc` | `--` | wait for ESC |
| `.input` | `--` | read a line into `'pad` (128 bytes); ESC cancels and leaves it empty |

A key is the raw bytes the terminal sends, packed into one number (first byte in the
lowest byte):

| Key | Value |
|---|---|
| `a` | `$61` |
| ESC | `$1b` (`[ESC]`) |
| Up arrow | `$415b1b` (`[UP]`) |
| Delete | `$7e335b1b` (`[DEL]`) |
| `ñ` | `$b1c3` (two bytes) |
| Ctrl+A | `$01` |
| Alt+A | `$1b` followed by `A` |

Constants: `[ESC] [ENTER] [BACK] [TAB] [DEL] [INS] [UP] [DN] [LE] [RI] [HOME] [END]
[PGUP] [PGDN] [F1]..[F12]` and the `[SHIFT+...]` variants. They are the same on every
platform. Compare with `=?`:

```forth
^r3/lib/console.r3

:keys
	( getch [esc] <>? "%h " .print ) drop ;

:main
	.cls
	"name? " .write .input
	'pad "hello %s" .println
	"keys (ESC to end): " .println
	keys ;

: main .free ;
```

Typing `a`, then the up arrow, `ñ`, Ctrl+C and Delete prints `61 415B1B B1C3 3 7E335B1B`.

### A menu

```forth
^r3/lib/console.r3

:draw
	.cls
	1 1 .at .Bold "=== MENU ===" .write .Reset
	1 3 .at "1. Option One"  .write
	1 4 .at "2. Option Two"  .write
	1 5 .at "q. Quit"        .write ;

:option | key --
	$31 =? ( 1 7 .at "one chosen" .write )
	$32 =? ( 1 7 .at "two chosen" .write )
	drop ;

:menu
	draw
	( getch $71 <>? option ) drop ;

: .hidec menu .showc .free ;
```

---

## 6. Events: mouse and resize

For mouse events use `inevt` instead of `inkey`: `inkey` and `getch` return only keys
(mouse and resize events are consumed and ignored). `inevt` returns the event type, or `0`
if nothing happened:

| Type | Event | Data |
|---|---|---|
| `0` | nothing | |
| `1` | key | `evtkey` |
| `2` | mouse | `evtmxy` (x y, 1-based, same as `.at`), `evtmb`, `evtmw` |
| `4` | terminal resized | `cols` `rows` already updated |

`getevt` is the waiting version.

- `evtmb` is a bit mask: `1` left, `2` right, `4` middle. It is `0` when no button is
  down (plain movement also reports `0`).
- `evtmw` is the wheel: `1` up, `-1` down (otherwise `0`).
- Call `.enable-mouse` before and `.disable-mouse` after.
- **Linux: register a resize callback** with `.onresize` to receive event `4`, even
  if the callback does nothing: `[ ; ] .onresize`. Without it a resize is never
  reported.
- The size is checked every time the program polls: `inevt`, `getevt`, `inkey` and
  `getch` all do it, so a loop that only uses `inkey` still runs the callback and sees
  the new `cols`/`rows` (as on Windows).

```forth
^r3/lib/console.r3

#running 1
#clicks 0

:onkey evtkey [esc] =? ( 0 'running ! ) drop ;

:onmouse
	evtmb 1 and? ( 1 'clicks +! evtmxy .at "*" .write ) drop
	1 1 .at clicks "clicks: %d" .print .flush ;

:onsize .cls 1 2 .at rows cols "size %dx%d" .print .flush ;

:main
	[ ; ] .onresize | needed on Linux to receive event 4
	.cls .enable-mouse
	( running 1? drop
		inevt
		1 =? ( onkey )
		2 =? ( onmouse )
		4 =? ( onsize )
		drop
		10 ms ) drop
	.disable-mouse ;

: .hidec main .showc .free ;
```

The loop is written `( running 1? drop ... )` on purpose: a block repeats only if it
contains an exit test that is not followed by its own `( )`. The `1 =?`, `2 =?` and
`4 =?` above have their own blocks, so without `running 1?` this loop would run once
and the program would end immediately.

---

## 7. Animation loop

Draw the whole frame, flush once, sleep, repeat. `inkey` polls the keyboard without
blocking.

```forth
^r3/lib/console.r3

#x 1 #dx 1

:frame
	.cls
	.Cyanl x 5 .at "O" .write .Reset
	1 1 .at "ESC = exit" .write
	.flush ;

:step
	x dx + 'x !
	x 1 <=? ( 1 'dx ! )
	cols >=? ( -1 'dx ! )
	drop ;

:main
	( inkey [esc] <>? drop
		frame step 30 ms
		) drop ;

: .alsb .hidec main .masb .showc .free ;
```

Tips taken from the examples in `r3/term`:

- Use `.home` instead of `.cls` when every cell is rewritten each frame (`matrix.r3`,
  `conway.r3`, `fire.r3`).
- Keep the simulation state in plain memory (`cols * rows` bytes, reserved from
  `here`) and draw from it (`conway.r3`).
- Update `cols`/`rows`-dependent buffers inside a resize callback, not in the middle
  of a frame.

### Progress bar

```forth
^r3/lib/console.r3

| statusbar: see section 3
:statusbar | "text" --
	.savec
	1 rows .at .Rever cols .nsp .write .Reset
	.restorec ;

:progress | pct --			; 0..100, 20 cells
	5 /
	1 3 .at "[" .write
	.Green 35 over .nch .Reset
	45 over 20 swap - .nch
	"]" .write drop ;

:main
	.cls
	0 ( 101 <? dup progress "working..." statusbar .flush 1+ 20 ms ) drop
	1 5 .at "done" .write .flush
	waitkey ;

: .hidec main .showc .free ;
```

---

## 8. Common mistakes

| Mistake | Symptom | Fix |
|---|---|---|
| `"text" .type` | crash | `.type` needs `str cnt`; for a string use `.write` |
| `.write` with `%d` in the text | prints the `%d` literally | use `.print` |
| `.fprintln` | `word not found` | the names are `.fwrite`, `.fprint`, `.println` |
| Args in reading order for `.print` | values swapped | push them in reverse order |
| Forgetting `.flush` before a long wait, `ms` or `.free` | text does not appear, or is lost at exit | flush, or use `.println` / `getch` |
| `.cls` in every frame | flicker | `.home` and overwrite |
| Forgetting `.Reset` | the terminal keeps the color after the program ends | `.Reset` before `.free` |
| `inevt` loop without a free exit test | loop runs once | `( running 1? drop ... )` |
| `.onresize` missing (Linux) | no event `4`, `cols`/`rows` never change | `[ ; ] .onresize` |
| No ESC handling | cannot exit (Ctrl+C is a key in raw mode) | always test `[esc]` |
| Writing UTF-8 with `.emit` | broken characters | `.write` for literals, `.uemit` for code points |
| `.nch` with a multibyte char | garbage | use `.rep` |

---

## 9. Platform notes

- Source lines starting with `|LIN|`, `|WIN|`, `|MAC|`, `|RPI|` are compiled only on
  that platform (see the include lines in `console.r3`).
- `cols` and `rows` are available on every platform. `.getterminfo` (re-read the size
  by hand) is exported only by the Linux backend, so guard calls with `|LIN|`.

---

## 10. Where to see it used

| File | Shows |
|---|---|
| `r3/term/testkey.r3` | key codes, `inevt`/`getevt`, `.onresize` |
| `r3/term/matrix.r3` | per-column animation with 256 colors, `.home` redraw |
| `r3/term/conway.r3` | alternate screen, state buffer, `inkey` loop |
| `r3/term/fire.r3` | full-frame animation |
| `r3/term/mouse_draw_demo.r3` | mouse buttons, `evtmxy`, brushes, `.enable-mouse` |
| `r3/term/colorscene.r3` | true color with half blocks, off-screen pixel buffer, scene switching |
| `r3/term/tui-t0.r3`, `tui-t1.r3` | widgets from `r3/util/tui.r3` |
| `r3/dev/riv.r3` | a full text editor: scrolling, status bar, modal keys |
