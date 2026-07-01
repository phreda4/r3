# R3 Forth Graphics — Examples

A step-by-step walkthrough of six increasingly complete SDL2 graphics programs.

**Official Repository:** https://github.com/phreda4/r3

## Table of Contents

1. [Example 1: Red Box](#example-1-red-box)
2. [Example 2: Graphics Primitives](#example-2-graphics-primitives)
3. [Example 3: Text Rendering](#example-3-text-rendering)
4. [Example 4: Ball Movement](#example-4-ball-movement)
5. [Example 5: Character Animation](#example-5-character-animation)
6. [Example 6: Multiple Objects](#example-6-multiple-objects)
7. [Program Structure Template](#program-structure-template)
8. [Common Patterns](#common-patterns)

---

## Example 1: Red Box

**Goal:** Create a simple window with a red rectangle in the corner.

### Complete Code

```forth
| program 1
| red box

^r3/lib/sdl2gfx.r3

:main
    0 sdlcls
    $ff0000 sdlcolor
    10 10 100 100 sdlfrect
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

### Code Breakdown

#### 1. Import Graphics Library
```forth
^r3/lib/sdl2gfx.r3
```
Imports the SDL2 graphics library, which provides all drawing functions.

#### 2. Main Loop
```forth
:main
    0 sdlcls                    | Clear screen with black (color 0)
    $ff0000 sdlcolor            | Set color to red (#FF0000)
    10 10 100 100 sdlfrect      | Draw filled rectangle at (10,10) size (100x100)
    sdlredraw                   | Update the screen
    sdlkey                      | Get keyboard input
    >esc< =? ( exit )           | If ESC pressed, exit
    drop ;                      | Drop the key value and loop
```

#### 3. Program Entry Point
```forth
:
    "red box in the corner" 800 600 SDLinit    | Initialize 800x600 window
    'main SDLShow                               | Run main loop
    SDLquit                                     | Clean up and quit
    ;
```

### Key Concepts

- **sdlcls**: Clears the screen with a color
- **sdlcolor**: Sets the current drawing color (RGB hex format)
- **sdlfrect**: Draws a filled rectangle (x, y, width, height)
- **sdlredraw**: Must be called to actually display what you've drawn
- **SDLShow**: Runs a loop, calling your function repeatedly
- **Anonymous word** (`:` without a name): The program's entry point

### Running the Program

1. Save as `1-redbox.r3`
2. Run with R3: `r3 1-redbox.r3`
3. Press ESC to exit

---

## Example 2: Graphics Primitives

**Goal:** Learn to draw various shapes with random colors and positions.

### Complete Code

```forth
| program 2 
| more graphics

^r3/lib/sdl2gfx.r3
^r3/lib/rand.r3

:waitkey
    SDLkey >esc< =? ( exit ) drop ;
    
:puntos
    $ffffff randmax SDLColor 
    sw randmax 
    sh randmax 
    SDLPoint
            
    SDLredraw 
    waitkey ;

:lineas
    $ffffff randmax SDLColor 
    sw randmax sh randmax 
    sw randmax sh randmax 
    SDLLine
    
    SDLredraw 
    waitkey ;

:cajas
    $ffffff randmax SDLColor 
    sw randmax sh randmax 
    sw over - randmax sh over - randmax 
    SDLRect
    
    SDLredraw 
    waitkey ;

:fillcajas
    $ffffff randmax SDLColor 
    sw randmax sh randmax 
    sw over - randmax sh over - randmax 
    SDLFRect
    
    SDLredraw 
    waitkey ;

:elipse
    $ffffff randmax SDLColor 
    sw 3 >> randmax sh 3 >> randmax     | radii
    sw randmax sh randmax               | center
    SDLEllipse
    
    SDLredraw 
    waitkey ;

:fillelipse
    $ffffff randmax SDLColor 
    sw 3 >> randmax sh 3 >> randmax     | radii
    sw randmax sh randmax               | center
    SDLFEllipse
    
    SDLredraw 
    waitkey ;

:filltri
    $ffffff randmax SDLColor 
    sw randmax sh randmax 
    sw randmax sh randmax 
    sw randmax sh randmax 
    SDLTriangle

    SDLredraw 
    waitkey ;
    
:   
    "r3 graphics" 800 600 SDLinit

    0 SDLcls
    'puntos SDLShow

    0 SDLcls
    'lineas SDLShow

    0 SDLcls
    'cajas SDLShow
    
    0 SDLcls
    'fillcajas SDLShow
    
    0 SDLcls
    'elipse  SDLShow
    
    0 SDLcls
    'fillelipse SDLShow

    0 SDLcls
    'filltri SDLShow
    
    SDLquit 
    ;
```

### Code Breakdown

#### Random Number Generation
```forth
^r3/lib/rand.r3

$ffffff randmax    | Random color (0 to $ffffff)
sw randmax         | Random x coordinate (0 to screen width)
sh randmax         | Random y coordinate (0 to screen height)
```
`randmax` is one of several generators in `rand.r3` — see the Reference for the
others (`rnd`/`rndmax`, `rand8`, `rnd128`, `loopMix128`).

#### Drawing Points
```forth
:puntos
    $ffffff randmax SDLColor    | Random color
    sw randmax                  | Random x
    sh randmax                  | Random y
    SDLPoint                    | Draw point
    SDLredraw 
    waitkey ;
```

#### Drawing Lines
```forth
:lineas
    $ffffff randmax SDLColor    | Random color
    sw randmax sh randmax       | Start point (x1, y1)
    sw randmax sh randmax       | End point (x2, y2)
    SDLLine                     | Draw line
    SDLredraw 
    waitkey ;
```

#### Drawing Rectangles
```forth
:cajas
    $ffffff randmax SDLColor    | Random color
    sw randmax sh randmax       | Top-left corner (x, y)
    sw over - randmax           | Width (calculated from x)
    sh over - randmax           | Height (calculated from y)
    SDLRect                     | Draw rectangle outline
    SDLredraw 
    waitkey ;
```

#### Drawing Filled Rectangles
```forth
:fillcajas
    $ffffff randmax SDLColor    | Random color
    sw randmax sh randmax       | Top-left corner
    sw over - randmax           | Width
    sh over - randmax           | Height
    SDLFRect                    | Draw filled rectangle
    SDLredraw 
    waitkey ;
```

#### Drawing Ellipses
```forth
:elipse
    $ffffff randmax SDLColor    | Random color
    sw 3 >> randmax             | Horizontal radius (small, up to sw/8)
    sh 3 >> randmax             | Vertical radius (small, up to sh/8)
    sw randmax sh randmax       | Random center point (cx, cy)
    SDLEllipse                  | Draw ellipse outline
    SDLredraw 
    waitkey ;
```
> `SDLEllipse` takes the radii *before* the center: `rx ry cx cy --`.

#### Drawing Triangles
```forth
:filltri
    $ffffff randmax SDLColor    | Random color
    sw randmax sh randmax       | Point 1 (x1, y1)
    sw randmax sh randmax       | Point 2 (x2, y2)
    sw randmax sh randmax       | Point 3 (x3, y3)
    SDLTriangle                 | Draw filled triangle
    SDLredraw 
    waitkey ;
```

### Key Concepts

- **randmax**: Generates a random number from 0 to the value on the stack
- **sw** / **sh**: Screen width / height variables (bare-fetch)
- **over**: Stack operation (a b -- a b a)
- **>>**: Right bit shift (divide by power of 2)
- Each shape type is demonstrated in its own `SDLShow` sub-loop, one after another

---

## Example 3: Text Rendering

**Goal:** Display text on screen with custom fonts and formatting.

### Complete Code

```forth
| draw text

^r3/lib/sdl2gfx.r3
^r3/util/txfont.r3

:demo
    0 SDLcls
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

### Code Breakdown

#### Font System Import
```forth
^r3/util/txfont.r3
```
Imports the text font utility for TrueType font rendering.

#### Font Initialization
```forth
:main
    "r3 text" 800 600 SDLinit
    "media/ttf/VictorMono-Bold.ttf" 32 txload txfont
    'demo SDLshow
    SDLquit ;
```
- **txload**: Loads a TrueType font file at the given size (32 px) and returns a font handle
- **txfont**: Sets the loaded font as current

#### Setting Text Color
```forth
$ff4c4c txrgb    | Set text color to RGB hex value
```

#### Positioning Text
```forth
10 10 txat       | Set text cursor to x=10, y=10
"Tx Font lib" txprint    | Print text at cursor position
```

#### Formatted Text Output
```forth
msec "ms: %d" txprint    | Print milliseconds with format string
```
- **msec**: Gets current millisecond count (not part of the five files reviewed here — presumably from `console.r3`)
- **%d**: Format specifier for decimal integer

#### Text Alignment
```forth
$11 txalign      | Set alignment mode
```
`txalign` combines two independent 2-bit fields with `or`: bits 0–1 pick the
horizontal mode (`0`=left, `1`=center, `2`=right), bits 4–5 pick the vertical mode
(`0`=top, `1`=center, `2`=bottom). `$11` sets center+center.

#### Multi-line Text Block
```forth
$4cff4c txrgb
$11 txalign  | Center horizontally and vertically
200 100 300 250 | w h x y
"Welcome to the application
This is a multi-line message
[ESC] to exit" 
txText
```
- **txText**: Renders multi-line text within a `w × h` box at `(x, y)`
- Automatically wraps text to fit the box width
- Aligns text according to `txalign`

### Key Concepts

- **txrgb**: Set text color (RGB hex format)
- **txat**: Position text cursor (x, y)
- **txprint**: Print text at cursor (supports `%d`/`%f`-style leading args)
- **txprintr**: Print text right-aligned from cursor
- **txText**: Render multi-line text in a box (`w h x y "str"`)
- **txalign**: Set text alignment mode (combinable bit flags)

---

## Example 4: Ball Movement

**Goal:** Create an interactive sprite that bounces and responds to keyboard input.

### Complete Code

```forth
| move sprite

^r3/lib/sdl2gfx.r3
^r3/util/txfont.r3

#sprPelota  | sprite
#xp 400.0 #yp 300.0     | pos
#xv #yv     | speed

:hitx xv neg 'xv ! ;
:hity yv neg 'yv ! ;

:main
    0 SDLcls
    xp int. yp int. sprPelota sprite
    
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
    "media/img/ball.png" loadimg 'sprpelota !
    'main SDLshow
    SDLquit 
    ;
```

### Code Breakdown

#### Variables and State
```forth
#sprPelota           | Sprite image handle
#xp 400.0 #yp 300.0  | Position (fixed point)
#xv #yv              | Velocity (speed in x and y)
```
- Fixed-point values (`.0`) allow smooth sub-pixel movement

#### Loading Sprites
```forth
"media/img/ball.png" loadimg 'sprpelota !
```
- **loadimg**: Loads a PNG file, returns a texture handle
- **'sprpelota**: Gets the address of the variable
- **!**: Stores the handle at that address

#### Drawing Sprites
```forth
xp int. yp int. sprPelota sprite
```
- **int.**: Converts a fixed-point value to an integer for pixel positioning
- **sprite**: Draws a sprite centered at `(x, y)` given an image handle

#### Movement and Physics
```forth
xv 'xp +!    | Add velocity to position
yv 'yp +!
```

#### Boundary Detection
```forth
xp 100.0 <? ( hitx ) 700.0 >? ( hitx ) drop
```
- **<?**: If less than, execute the code in parentheses
- **>?**: If greater than, execute the code in parentheses
- **hitx**: Reverses horizontal velocity (bounce)

#### Collision Response
```forth
:hitx xv neg 'xv ! ;
:hity yv neg 'yv ! ;
```
- **neg**: Negates a value (changes direction)

#### Keyboard Input
```forth
SDLkey
>esc< =? ( exit )
<w> =? ( -0.1 'yv +! )
<s> =? ( 0.1 'yv +! )
<a> =? ( -0.1 'xv +! )
<d> =? ( 0.1 'xv +! )
drop
```
- **SDLkey**: Holds the last key event code
- **`<w>`**, **`<s>`**, **`<a>`**, **`<d>`**: Key-pressed constants
- **`=?`**: If equal, execute the code in parentheses

#### Displaying Debug Information
```forth
$ffff4c txrgb
790 10 txat
yv xv "%f %f" txprintr
```
- **%f**: Format specifier for fixed-point numbers
- **txprintr**: Prints right-aligned from the cursor position

### Key Concepts

- **Fixed-point arithmetic**: Use the `.0` suffix for fixed-point literals
- **Sprite rendering**: `sprite` takes x, y, and an image handle
- **Velocity-based movement**: Separate velocity and position variables
- **Boundary checking**: `<?` and `>?` for conditional execution
- **Input handling**: Check keys in the main loop
- **State modification**: `+!` to add to a variable

---

## Example 5: Character Animation

**Goal:** Animate a character with sprite sheets, gravity, and direction changes.

### Complete Code

```forth
| Animation example
| aswd for move

^r3/lib/sdl2gfx.r3
^r3/util/txfont.r3

#tsguy  | spritesheet
#nroguy 12  | frame ini
#sumguy 0   | add for animation
#maxguy 0   | frame max

#xp 100.0 #yp 400.0     | pos

#xv #yv     | speed

:animacion  | cnt nro -- 
    16 << 
    nroguy =? ( 2drop ; )
    'nroguy ! 
    'maxguy ! 
    0 'sumguy !
    ;
    
:nroimagen  | -- nro
    0.09 'sumguy +!     | speed frame change
    
    nroguy sumguy + int.
    maxguy >? ( drop nroguy int. 0 'sumguy ! ) 
    ;
    
:gravity
    yp 400.0 =? ( drop ; ) 
    400.0 >? ( drop 400.0 'yp ! ; ) 
    drop
    0.3 'yv +!
    ;
    
:demo
    $323262 SDLcls
    
    $326232 SDLcolor
    0 400 800 200 sdlfrect
    xp int. yp int. 3.0 nroimagen tsguy sspritez    
    
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
    <a> =? ( -1.0 'xv ! 8 1 animacion )
    >a< =? ( 0 'xv ! 0 0 animacion )
    <d> =? ( 1.0 'xv ! 17 10 animacion )
    >d< =? ( 0 'xv ! 0 9 animacion )
    <w> =? ( yp 400.0 =? ( -8.0 'yv ! ) drop )
    drop ;
    
:main
    "sdl animation" 800 600 SDLinit
    "media/ttf/VictorMono-Bold.ttf" 32 txload txfont   
    16 32 "media/img/p2.png" ssload 'tsguy !
    'demo SDLshow
    SDLquit ;   
    
: main ;
```

### Code Breakdown

#### Sprite Sheet System
```forth
#tsguy       | Sprite sheet handle
#nroguy 12   | Starting frame number
#sumguy 0    | Animation accumulator
#maxguy 0    | Maximum frame number
```

#### Loading Sprite Sheets
```forth
16 32 "media/img/p2.png" ssload 'tsguy !
```
- **ssload**: Loads a sprite sheet with frame dimensions 16×32
- Returns a handle to the sprite sheet

#### Animation Control
```forth
:animacion  | cnt nro -- 
    16 << 
    nroguy =? ( 2drop ; )
    'nroguy ! 
    'maxguy ! 
    0 'sumguy !
    ;
```
- **16 <<**: Shift the frame count 16 bits left (encode into the upper word)
- **nroguy**: Starting frame
- **maxguy**: Maximum frame (encoded together with the count)
- **sumguy**: Animation timer/accumulator

#### Frame Selection
```forth
:nroimagen  | -- nro
    0.09 'sumguy +!         | Increment animation timer
    
    nroguy sumguy + int.     | Calculate current frame
    maxguy >? ( drop nroguy int. 0 'sumguy ! )  | Loop animation
    ;
```
- Gradually increments the frame counter
- Loops back to the start frame when reaching max

#### Sprite Sheet Rendering
```forth
xp int. yp int. 3.0 nroimagen tsguy sspritez
```
- **sspritez**: Draws a sprite-sheet frame with zoom
- Parameters: x, y, zoom, frame, sheet

#### Gravity System
```forth
:gravity
    yp 400.0 =? ( drop ; )          | On ground, stop
    400.0 >? ( drop 400.0 'yp ! ; )  | Clamp to ground
    drop
    0.3 'yv +!                       | Apply gravity
    ;
```
- Applies constant downward acceleration
- Stops at ground level

#### Direction-Based Animation
```forth
SDLkey
<a> =? ( -1.0 'xv ! 8 1 animacion )   | Move left, frames 1-8
>a< =? ( 0 'xv ! 0 0 animacion )      | Stop left
<d> =? ( 1.0 'xv ! 17 10 animacion )  | Move right, frames 10-17
>d< =? ( 0 'xv ! 0 9 animacion )      | Stop right
<w> =? ( yp 400.0 =? ( -8.0 'yv ! ) drop )  | Jump if on ground
```
- Different key press/release states trigger different animation sequences
- **`<key>`**: Key pressed down
- **`>key<`**: Key released

#### Background and Ground
```forth
$323262 SDLcls          | Clear with dark purple
$326232 SDLcolor        | Set ground color
0 400 800 200 sdlfrect  | Draw ground rectangle
```

### Key Concepts

- **Sprite sheets**: Multiple frames in one image
- **Frame animation**: Cycle through frames over time
- **State-based animation**: Different animations for different actions
- **Gravity simulation**: Constant downward acceleration
- **Ground collision**: Detect and respond to the floor
- **Key states**: Detect both press and release events
- **Animation looping**: Reset to the start frame when reaching the end

---

## Example 6: Multiple Objects

**Goal:** Manage many animated sprites with dynamic arrays and sorting.

### Complete Code

```forth
| Animation example
| with multiple objects
^r3/lib/rand.r3
^r3/lib/sdl2gfx.r3
^r3/util/arr16.r3
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
    $323262 SDLcls
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
    <esp> =? ( +randpeople )
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

> **Note:** the `txText` call above uses `200 100 300 20` — under the corrected
> `w h x y` order that's a 200×100 box at position `(300, 20)`. The original demo
> listed `300 20 200 100` under the (incorrect) `x y w h` label; the numbers here
> have been reordered so the box still ends up positioned the same place near the
> top of the screen. If you're copying this file verbatim, either order works as
> long as it's internally consistent with the label you use.

### Code Breakdown

#### Dynamic Array System
```forth
^r3/util/arr16.r3

#people 0 0 | dynamic array for sort
```
- `arr16.r3` provides the fixed-stride dynamic-array words (`p.ini`, `p!+`,
  `p.drawo`, `p.sort`, and more — see the Reference for the full list)
- `#people 0 0` reserves the two cells (`first`, `last` pointers) the list header needs

#### Object Structure
```forth
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
```
- Each person object has 8 fields
- **ncell+**: Computes the address offset to a numbered field in the struct (not
  in `arr16.r3` itself — presumably from `mem.r3`, which wasn't available to verify)
- Accessor words give each field a readable name

#### Loading Multiple Sprite Sheets
```forth
'spritesheet 
16 32 "media/img/p1.png" ssload swap !+
16 32 "media/img/p2.png" ssload swap !+
16 32 "media/img/p3.png" ssload swap !
```
- Loads three different sprite sheets
- Stores their handles in an array for random per-object selection

#### Array Initialization
```forth
2000 'people p.ini
```
- **p.ini**: Initializes the array with capacity for 2000 objects

#### Object Update Function
```forth
:person | v -- 
    dup 8 + >a
    a@+ int. a@+ int.   | x y
    a@+ dup 32 >> swap $ffffffff and | rot zoom
    dup .ani ani+timer!               | advance animation in place
    dup .ani @ aniFrame                | n
    a@+ drop                           | skip register past .ani (already handled above)
    a@+ sspriterz
```
- **>a**: Copy an address into the `a` register for fast sequential access
- **a@+**: Fetch through the `a` register and advance it
- **.ani ani+timer!**: Advance this object's packed animation value in place
- **.ani @ aniFrame**: Read the (now-advanced) animation value and convert it to a frame number
- **between**: Check whether a value is within a range (from `rand.r3`/elsewhere — not directly verified here)
- **2drop 0**: Drop this object's working values and return `0`, telling `p.drawo` to remove it

> **Confirmed against a real project** (`malasuerte.r3`): the correct animation
> pattern is
> ```forth
> 'ajug ani+timer!    | 'V --  advance the packed value in place
> ajug aniFrame        | V -- f  get current frame from it
> ```
> `ani+timer!` takes the *address* of the packed value and updates it directly —
> it does not work by fetching the value, adding elapsed time, and storing it back.
> `:person` above uses `.ani` (the field's address) for this, rather than the `a`
> register, since `a` only ever holds fetched values here.

#### Adding New Objects
```forth
:+people | vx vy sheet anim zoom ang x y --
    'person 'people p!+ >a 
    swap a!+ a!+    | x y 
    32 << or a!+    | ang zoom
    a!+ a!+         | anim sheet
    swap a!+ a!+    | vx vy
    0 a!            | vrz
    ;
```
- **p!+**: Reserves a new element in the array and stores the given draw/update word (`'person`) into it
- Packs angle and zoom into a single field via `32 << or`

#### Random Sprite Selection
```forth
:+randpeople
    toright rand $1000 and? ( toleft ) drop
    vx 0.2 randmax 0.1 - + 0.2 randmax 0.1 -
    'spritesheet 3 randmax 3 << + @
    a 2.0 0 
    x 400.0 randmax 150.0 + 
    +people ;
```
- Randomly chooses a left- or right-facing starting state
- Randomly selects one of the three loaded sprite sheets
- Randomizes the y spawn position

#### Animation Encoding
```forth
10 8 14.0 aniInit | ini cnt fps -- V
```
- **aniInit**: Encodes animation parameters into a single packed value `V`
- `ini`: starting frame, `cnt`: frame count, `fps`: playback speed (fixed point)

#### Drawing All Objects
```forth
timer.
'people p.drawo     | draw sprites
2 'people p.sort    | sort for draw (y coord)
```
- **timer.**: Advances the global frame timer
- **p.drawo**: Draws (and order-preserving-removes) all objects in the array
- **p.sort**: One bubble-sort pass over field 2 (y coordinate), for back-to-front overlap ordering — called every frame so the array gradually converges to fully sorted

#### Timer System
```forth
timer<              | Start timer
timer.              | Advance timer
timer+              | Add elapsed time to a value
```

### Key Concepts

- **Dynamic arrays**: Manage collections of objects
- **Object-oriented approach**: Structures with per-object "methods" (the stored update word)
- **Depth sorting**: Draw back-to-front based on y coordinate
- **Automatic culling**: Remove objects outside the screen
- **Multiple sprite sheets**: Variety through random selection
- **Encoded data**: Pack multiple values into a single field
- **Timer-based animation**: Frame-rate-independent animation
- **Register**: Simplify complex data access with `>a`/`a@+`

---

## Program Structure Template

```forth
| Program description

^r3/lib/sdl2gfx.r3
^r3/lib/rand.r3              | If needed
^r3/util/txfont.r3           | If using text

| Variables
#variable1
#variable2 initial_value

| Helper functions
:helper1
    code here
    ;

:helper2
    code here
    ;

| Main loop
:main
    | Clear and draw
    0 SDLcls
    | ... drawing code ...
    SDLredraw
    
    | Update logic
    | ... update code ...
    
    | Handle input
    SDLkey
    >esc< =? ( exit )
    | ... other keys ...
    drop ;

| Entry point
:
    "Window Title" 800 600 SDLinit
    
    | Load resources
    "font.ttf" 32 txload txfont
    "image.png" loadimg 'sprite !
    
    | Run
    'main SDLShow
    
    | Cleanup
    SDLquit 
    ;
```

### Best Practices

1. **Use meaningful variable names** with the `#` prefix
2. **Comment your code** with `|` for clarity
3. **Keep functions small** and focused
4. **Clear the screen** every frame with `sdlcls`
5. **Call sdlredraw** after all drawing
6. **Handle ESC key** for a clean exit
7. **Use fixed point** (`.0`) for smooth movement
8. **Load resources** before entering the main loop
9. **Check boundaries** to prevent objects going off-screen
10. **Use registers** (`>a`, `a@+`) for complex structures or mem traverse

## Common Patterns

### Simple Animation Loop
```forth
:main
    0 SDLcls
    | draw code here
    SDLredraw
    SDLkey >esc< =? ( exit ) drop ;
```

### Velocity-Based Movement
```forth
#x #y #vx #vy

:update
    vx 'x +!
    vy 'y +!
    ;
```

### Boundary Checking
```forth
x 0 <? ( 0 'x ! ) 800.0 >? ( 800.0 'x ! ) drop | warning, if use fixed point  !!
```

### Key Handler
```forth
SDLkey
>esc< =? ( exit )
<w> =? ( do_something )
drop
```

### Timer-Based Animation
```forth
#anim

0 8 6.0 aniInit 'anim !    | ini cnt fps -- V   (once, when starting the animation)

:update
    'anim ani+timer!        | 'V --  advance in place, call every frame
    anim aniFrame            | V -- f  get current frame to draw
    ;
```
