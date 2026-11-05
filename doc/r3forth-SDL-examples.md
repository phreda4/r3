# R3 Forth Graphics — Examples

Six short SDL2 programs, from a red box to many animated sprites. Run each one with
`r3 file.r3` (`./r3lin file.r3` on Linux). The words are listed in the Graphics
Reference. Repository: https://github.com/phreda4/r3

---

## Example 1: Red box

A window with a red rectangle.

```forth
| program 1
| red box

^r3/lib/sdl2gfx.r3

:main
    0 cls
    $ff0000 color
    10 10 100 100 frect
    sdlredraw
    sdlkey
    >esc< =? ( exit )
    drop ;

:
    "red box in the corner" 800 600 SDLinit
    'main SDLShow
    SDLquit
    ;
```

- `SDLinit` opens the window, `SDLshow` calls `main` once per frame until `exit`,
  `SDLquit` closes everything. The unnamed `:` word is the entry point.
- `0 cls` clears the screen with black, `color` sets the draw color (`$RRGGBB`) and
  `frect` draws a filled rectangle (`x y w h`).
- `sdlredraw` shows the frame; without it nothing appears.
- `sdlkey` leaves the last key event code. `<esc>` is the key-down code and `>esc<`
  the key-up code (`$1000` added), so this program exits when ESC is released.

---

## Example 2: Graphics primitives

Random points, lines, boxes, ellipses and triangles. Each shape has its own `SDLshow`
loop; press ESC to go to the next one.

```forth
| program 2
| more graphics

^r3/lib/sdl2gfx.r3
^r3/lib/rand.r3

:checkesc
    SDLkey >esc< =? ( exit ) drop ;

:points
    $ffffff randmax color
    sw randmax
    sh randmax
    point

    SDLredraw
    checkesc ;

:lines
    $ffffff randmax color
    sw randmax sh randmax
    sw randmax sh randmax
    line

    SDLredraw
    checkesc ;

:boxes
    $ffffff randmax color
    sw randmax sh randmax
    sw over - randmax sh over - randmax
    rect

    SDLredraw
    checkesc ;

:fillboxes
    $ffffff randmax color
    sw randmax sh randmax
    sw over - randmax sh over - randmax
    frect

    SDLredraw
    checkesc ;

:ellipses
    $ffffff randmax color
    sw 3 >> randmax sh 3 >> randmax     | radii
    sw randmax sh randmax               | center
    ellipse

    SDLredraw
    checkesc ;

:fillellipses
    $ffffff randmax color
    sw 3 >> randmax sh 3 >> randmax     | radii
    sw randmax sh randmax               | center
    fellipse

    SDLredraw
    checkesc ;

:filltri
    $ffffff randmax color
    sw randmax sh randmax
    sw randmax sh randmax
    sw randmax sh randmax
    triangle

    SDLredraw
    checkesc ;

:
    "r3 graphics" 800 600 SDLinit

    0 cls
    'points SDLShow

    0 cls
    'lines SDLShow

    0 cls
    'boxes SDLShow

    0 cls
    'fillboxes SDLShow

    0 cls
    'ellipses  SDLShow

    0 cls
    'fillellipses SDLShow

    0 cls
    'filltri SDLShow

    SDLquit
    ;
```

- `n randmax` returns a random number from 0 to n-1 (`rand.r3`).
- `sw` and `sh` hold the window size (a bare name fetches its value).
- `ellipse` and `fellipse` take the radii first: `rx ry x y --`.

---

## Example 3: Text

Text with a TTF font: color, position, formatting and a centered block.

```forth
| draw text

^r3/lib/sdl2gfx.r3
^r3/util/txfont.r3

:demo
    0 cls
    $ff4c4c txrgb
    10 10 txat
    "Tx Font lib" txprint
    $ffff4f txrgb
    10 40 txat
    msec "ms: %d" txprint

    $4cff4c txrgb
    $11 txalign  | Center horizontally and vertically
    200 100 300 250
"Welcome to the application
This is a multi-line message
[ESC] to exit"
    txText

    SDLredraw
    SDLkey >esc< =? ( exit ) drop ;

:main
    "r3 text" 800 600 SDLinit
    "media/ttf/VictorMono-Bold.ttf" 32 txload txfont
    'demo SDLshow
    SDLquit ;

: main ;
```

- `txload` loads the font at 32 pixels, `txfont` selects it.
- `txrgb` sets the color, `txat` the cursor position, `txprint` prints with the
  format codes of `.print` (`%d`, `%f`, ...). `msec` (from `core.r3`) is the time in milliseconds.
- `txalign` combines two fields: bits 0-1 horizontal (0 left, 1 center, 2 right) and
  bits 4-5 vertical (0 top, 1 center, 2 bottom). `$11` is center-center.
- `txText` draws a string wrapped inside the box `w h x y`.

---

## Example 4: Moving ball

A sprite that bounces and changes speed with W, A, S, D.

```forth
| move sprite

^r3/lib/sdl2gfx.r3
^r3/util/txfont.r3

#sprBall  | sprite
#xp 400.0 #yp 300.0     | pos
#xv #yv     | speed

:hitx xv neg 'xv ! ;
:hity yv neg 'yv ! ;

:main
    0 cls
    xp int. yp int. sprBall sprite

    $ffff4c txrgb
    10 10 txat
    "awsd - move sprite" txprint
    790 10 txat
    yv xv "%f %f" txprintr

    SDLredraw

    xv 'xp +!
    yv 'yp +!

    xp 100.0 <? ( hitx ) 700.0 >? ( hitx ) drop
    yp 100.0 <? ( hity ) 500.0 >? ( hity ) drop

    SDLkey
    >esc< =? ( exit )
    <w> =? ( -0.1 'yv +! )
    <s> =? ( 0.1 'yv +! )
    <a> =? ( -0.1 'xv +! )
    <d> =? ( 0.1 'xv +! )
    drop ;

:
    "r3 sprite" 800 600 SDLinit
    "media/ttf/VictorMono-Bold.ttf" 32 txload txfont
    "media/img/ball.png" loadimg 'sprBall !
    'main SDLshow
    SDLquit
    ;
```

- `loadimg` loads a PNG into a texture, `sprite` draws it centered at `x y`.
- Position and speed are fixed point (`400.0`); `int.` converts to pixels.
- `<w> <a> <s> <d>` are the key-down codes. `neg` reverses the speed at the borders.

---

## Example 5: Character animation

A character from a sprite sheet with gravity. A and D move, W jumps.

```forth
| Animation example
| aswd for move

^r3/lib/sdl2gfx.r3
^r3/util/txfont.r3

#guysheet  | spritesheet
#guyini 12  | frame ini
#guyadd 0   | add for animation
#guymax 0   | frame max

#xp 100.0 #yp 400.0     | pos

#xv #yv     | speed

:setanim  | max ini --
    16 <<
    guyini =? ( 2drop ; )
    'guyini !
    'guymax !
    0 'guyadd !
    ;

:curframe  | -- nro
    0.09 'guyadd +!     | speed frame change

    guyini guyadd + int.
    guymax >? ( drop guyini int. 0 'guyadd ! )
    ;

:gravity
    yp 400.0 =? ( drop ; )
    400.0 >? ( drop 400.0 'yp ! ; )
    drop
    0.3 'yv +!
    ;

:demo
    $323262 cls

    $326232 color
    0 400 800 200 frect
    xp int. yp int. 3.0 curframe guysheet sspritez

    $ffff4c txrgb
    10 10 txat
    "awd - move sprite" txprint
    790 10 txat
    yp xp "%f %f" txprintr

    SDLredraw
    xv 'xp +!
    yv 'yp +!

    gravity

    SDLkey
    >esc< =? ( exit )
    <a> =? ( -1.0 'xv ! 8 1 setanim )
    >a< =? ( 0 'xv ! 0 0 setanim )
    <d> =? ( 1.0 'xv ! 17 10 setanim )
    >d< =? ( 0 'xv ! 0 9 setanim )
    <w> =? ( yp 400.0 =? ( -8.0 'yv ! ) drop )
    drop ;

:main
    "sdl animation" 800 600 SDLinit
    "media/ttf/VictorMono-Bold.ttf" 32 txload txfont
    16 32 "media/img/p2.png" ssload 'guysheet !
    'demo SDLshow
    SDLquit ;

: main ;
```

- `ssload` cuts the image into frames of `w h` pixels; `sspritez` draws frame `n`
  centered at `x y` with zoom.
- `setanim` chooses the frames of the current action: the frame number advances by
  0.09 per update and returns to the first one after the last.
- The key-up codes (`>a<`, `>d<`) stop the movement and go back to the idle frames.

---

## Example 6: Many objects

Up to 2000 animated sprites in a list (`arr16.r3`), sorted by `y`. Press SPACE to add one.

```forth
| Animation example
| with multiple objects
^r3/lib/rand.r3
^r3/lib/sdl2gfx.r3
^r3/util/arr16.r3
^r3/util/varanim.r3
^r3/util/txfont.r3

#spritesheet 0 0 0 | 3 spritessheet
#people 0 0 | dynamic array for sort

|person array
| x y ang anim ss vx vy ar
| 1 2 3   4    5  6  7  8
:.x 1 ncell+ ;
:.y 2 ncell+ ;
:.a 3 ncell+ ;
:.ani 4 ncell+ ;
:.ss 5 ncell+ ;
:.vx 6 ncell+ ;
:.vy 7 ncell+ ;
:.va 8 ncell+ ;

:person | v --
    dup 8 + >a
    a@+ int. a@+ int.   | x y
    a@+ dup 32 >> swap $ffffffff and | rot zoom
    dup .ani ani+timer!               | advance animation in place
    dup .ani @ aniFrame                | n
    a@+ drop                           | skip register past .ani (already handled above)
    a@+ sspriterz

    |..... remove when outside screen
    dup .x @ -17.0 817.0 between -? ( 2drop 0 ; ) drop
    dup .y @ 0 616.0 between -? ( 2drop 0 ; ) drop

    |..... add velocity to position
    dup .vx @ over .x +!
    dup .vy @ over .y +!
    dup .va @ over .a +!
    drop
    ;

|----------------------------
:+people | vx vy sheet anim zoom ang x y --
    'person 'people p!+ >a
    swap a!+ a!+    | x y
    32 << or a!+    | ang zoom
    a!+ a!+         | anim sheet
    swap a!+ a!+    | vx vy
    0 a!            | vrz
    ;

#vx #x #a

:toright
    0.8 'vx ! -8.0 'x !
    10 8 8.0 aniInit | ini cnt fps -- V
    'a ! ;

:toleft
    -0.8 'vx ! 808.0 'x !
    1 8 8.0 aniInit | ini cnt fps -- V
    'a ! ;

:+randpeople
    toright rand $1000 and? ( toleft ) drop
    vx 0.2 randmax 0.1 - + 0.2 randmax 0.1 -
    'spritesheet 3 randmax 3 << + @
    a 2.0 0
    x 400.0 randmax 150.0 +
    +people ;

:demo
    $323262 cls
    timer.
    'people p.drawo     | draw sprites
    2 'people p.sort    | sort for draw (y coord)

    $4cff4c txrgb
    $11 txalign  | Center horizontally and vertically
    200 100 300 20
"Multisprite demo
[SPC] add more people
[ESC] to exit"
    txText

    SDLredraw
    |+randpeople
    SDLkey
    >esc< =? ( exit )
    <spc> =? ( +randpeople )
    drop ;

:main
    "r3 multisprite" 800 600 SDLinit
    "media/ttf/VictorMono-Bold.ttf" 32 txload txfont
    'spritesheet
    16 32 "media/img/p1.png" ssload swap !+ | spritesheet[0]
    16 32 "media/img/p2.png" ssload swap !+ | spritesheet[1]
    16 32 "media/img/p3.png" ssload swap !  | spritesheet[2]
    2000 'people p.ini
    timer<
    'demo SDLshow
    SDLquit ;

: main ;
```

- `p.ini` reserves the list, `p!+` adds an element and stores its word (`'person`),
  `p.drawo` calls that word for every element and removes the ones that return 0.
- `p.sort` does one bubble-sort pass per frame on field 2 (`y`).
- `aniInit` packs a frame animation (first frame, count, fps); `ani+timer!` advances
  it with the time since the last `timer.` (`varanim.r3`).
- `>a` and `a@+` read the fields of the element in order.

---

## Program template

```forth
| description

^r3/lib/sdl2gfx.r3
^r3/util/txfont.r3		| only if you use text

#variable1
#variable2 100

:main
	0 cls
	| draw
	SDLredraw
	| update
	SDLkey
	>esc< =? ( exit )
	drop ;

:
	"Window title" 800 600 SDLinit
	"media/ttf/VictorMono-Bold.ttf" 32 txload txfont
	'main SDLshow
	SDLquit ;
```

## Patterns

```forth
| velocity
vx 'x +!
vy 'y +!

| keys: SDLkey is the last event, drop it at the end
SDLkey
>esc< =? ( exit )
<w> =? ( up )
drop

| frame animation
#anim
0 8 6.0 aniInit 'anim !		| once: first frame, count, fps
'anim ani+timer!		| every frame
anim aniFrame			| frame to draw
```

Fixed point values (`x 800.0 >? ...`) must be compared with fixed point limits.
