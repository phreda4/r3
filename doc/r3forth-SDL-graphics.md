# R3 Forth Graphics Programming 

A step-by-step guide to creating interactive graphics applications with R3 Forth.

**Official Repository:** https://github.com/phreda4/r3

---

## Table of Contents

1. [Introduction to R3 Forth](#introduction-to-r3-forth)
2. [Example 1: Red Box - Your First Graphics Program](#example-1-red-box)
3. [Example 2: Graphics Primitives - Drawing Shapes](#example-2-graphics-primitives)
4. [Example 3: Text Rendering - Adding Text to Graphics](#example-3-text-rendering)
5. [Example 4: Ball Movement - Interactive Sprites](#example-4-ball-movement)
6. [Example 5: Character Animation - Sprite Sheets](#example-5-character-animation)
7. [Example 6: Multiple Objects - Dynamic Sprite Management](#example-6-multiple-objects)
8. [Reference Guide](#reference-guide)

---

## Introduction to R3 Forth

R3 is a modern, minimalist Forth dialect designed for rapid application development. It features:

- Simple, stack-based syntax
- SDL2 graphics integration
- Fast compilation
- Colorful token-based language structure

### Basic R3 Syntax

```forth
| This is a comment
^lib/file.r3     | Import library

#variable_name    | Declares a variable
'word            | Gets the address of a word
!                | Store value at address
@                | Fetch value from address
:word_name       | Define a new word
    code here
    ;            | End word definition

```

### Stack Notation

R3 uses postfix notation where operations follow their operands:
```forth
10 20 +    | Pushes 10, then 20, then adds them (result: 30)
```

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
    sw 3 >> randmax sh 3 >> randmax 
    sw randmax sh randmax 
    SDLEllipse
    
    SDLredraw 
    waitkey ;

:fillelipse
    $ffffff randmax SDLColor 
    sw 3 >> randmax sh 3 >> randmax 
    sw randmax sh randmax 
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
    sw 3 >> randmax             | Random x within range
    sh 3 >> randmax             | Random y within range
    sw randmax sh randmax       | Horizontal and vertical radii
    SDLEllipse                  | Draw ellipse outline
    SDLredraw 
    waitkey ;
```

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

- **randmax**: Generates random number from 0 to the value on stack
- **sw**: Screen width variable
- **sh**: Screen height variable
- **over**: Stack operation (a b -- a b a)
- **>>**: Right bit shift (divide by power of 2)
- **Multiple demonstrations**: Each shape type is shown in sequence

### Graphics Primitives Reference

| Function | Parameters | Description |
|----------|------------|-------------|
| `SDLPoint` | x y | Draw a single pixel |
| `SDLLine` | x1 y1 x2 y2 | Draw a line |
| `SDLRect` | x y w h | Draw rectangle outline |
| `SDLFRect` | x y w h | Draw filled rectangle |
| `SDLEllipse` | cx cy rx ry | Draw ellipse outline |
| `SDLFEllipse` | cx cy rx ry | Draw filled ellipse |
| `SDLTriangle` | x1 y1 x2 y2 x3 y3 | Draw filled triangle |

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
    300 250 200 100 
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
- **txload**: Loads a TrueType font file at specified size (32 pixels)
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
- **msec**: Gets current millisecond count
- **%d**: Format specifier for decimal integer

#### Text Alignment
```forth
$11 txalign      | Set alignment mode
```
Alignment values:
- `$00`: Top-left (default)
- `$01`: Horizontally centered
- `$10`: Vertically centered
- `$11`: Both centered

#### Multi-line Text Block
```forth
$4cff4c txrgb
$11 txalign  | Center horizontally and vertically
300 250 200 100     | x y width height
"Welcome to the application
This is a multi-line message
[ESC] to exit" 
txText
```
- **txText**: Renders multi-line text within a bounding box
- Automatically wraps text to fit width
- Centers text according to alignment

### Key Concepts

- **txrgb**: Set text color (RGB hex format)
- **txat**: Position text cursor (x, y)
- **txprint**: Print text at cursor
- **txprintr**: Print text right-aligned from cursor
- **txText**: Render multi-line text in box
- **txalign**: Set text alignment mode
- **Format strings**: Use `%d` for integers, `%f` for fixedpoint

### Text Functions Reference

| Function | Parameters | Description |
|----------|------------|-------------|
| `txload` | filename size | Load TrueType font |
| `txfont` | font | Set current font |
| `txrgb` | color | Set text color |
| `txat` | x y | Set cursor position |
| `txprint` | string | Print text at cursor |
| `txprintr` | string | Print right-aligned |
| `txText` | x y w h string | Render text in box |
| `txalign` | mode | Set alignment |

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
- Using fixed-point values (`.0`) allows smooth sub-pixel movement

#### Loading Sprites
```forth
"media/img/ball.png" loadimg 'sprpelota !
```
- **loadimg**: Loads PNG image file, returns handle
- **'sprpelota**: Gets address of variable
- **!**: Stores handle at address

#### Drawing Sprites
```forth
xp int. yp int. sprPelota sprite
```
- **int.**: Converts fixedpoint to integer for pixel positioning
- **sprite**: Draws sprite at position (x, y, handle)

#### Movement and Physics
```forth
xv 'xp +!    | Add velocity to position
yv 'yp +!
```
- **+!**: Adds value to variable

#### Boundary Detection
```forth
xp 100.0 <? ( hitx ) 700.0 >? ( hitx ) drop
```
- **<?**: If less than, execute code in parentheses
- **>?**: If greater than, execute code in parentheses
- **hitx**: Reverses horizontal velocity (bounce)

#### Collision Response
```forth
:hitx xv neg 'xv ! ;
:hity yv neg 'yv ! ;
```
- **neg**: Negates value (changes direction)

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
- **SDLkey**: Returns key code
- **<w>**, **<s>**, **<a>**, **<d>**: Key constants
- **=?**: If equal, execute code

#### Displaying Debug Information
```forth
$ffff4c txrgb
790 10 txat
yv xv "%f %f" txprintr
```
- **%f**: Format specifier for fixed-point numbers
- **txprintr**: Prints right-aligned from position

### Key Concepts

- **fixed-point arithmetic**: Use `.0` suffix for fixedpoint literals
- **Sprite rendering**: `sprite` function takes x, y, and image handle
- **Velocity-based movement**: Separate velocity and position
- **Boundary checking**: Use `<?` and `>?` for conditional execution
- **Input handling**: Check keys in main loop
- **State modification**: Use `+!` to add to variables

### Physics and Input Reference

| Operation | Description |
|-----------|-------------|
| `+!` | Add to variable |
| `<?` | Execute if less than |
| `>?` | Execute if greater than |
| `neg` | Negate value |
| `int.` | Convert fixedpoint to int |
| `loadimg` | Load PNG image |
| `sprite` | Draw sprite |

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
- **ssload**: Load sprite sheet with frame dimensions (16x32 pixels)
- Returns handle to sprite sheet

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
- **16 <<**: Shift count 16 bits left (encode as upper word)
- **nroguy**: Starting frame
- **maxguy**: Maximum frame (encoded with count)
- **sumguy**: Animation timer/accumulator

#### Frame Selection
```forth
:nroimagen  | -- nro
    0.09 'sumguy +!         | Increment animation timer
    
    nroguy sumguy + int.     | Calculate current frame
    maxguy >? ( drop nroguy int. 0 'sumguy ! )  | Loop animation
    ;
```
- Gradually increments frame counter
- Loops back to start frame when reaching max

#### Sprite Sheet Rendering
```forth
xp int. yp int. 3.0 nroimagen tsguy sspritez
```
- **sspritez**: Draw sprite sheet frame with zoom
- Parameters: x, y, zoom, frame, spritesheet

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
- Different key press states trigger different animation sequences
- **<key>**: Key pressed down
- **>key<**: Key released

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
- **Ground collision**: Detect and respond to floor
- **Key states**: Detect both press and release events
- **Animation looping**: Reset to start frame when reaching end

### Sprite Sheet Reference

| Function | Parameters | Description |
|----------|------------|-------------|
| `ssload` | w h filename | Load sprite sheet |
| `ssprite` | x y n sheet | Draw sprite frame |
| `sspritez` | x y zoom n sheet | Draw with zoom |
| `<<` | value bits | Left bit shift |
| `2drop` | -- | Drop two values |

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
    a@ timer+ dup a!+ anim>n            | n
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
    10 8 $7f ICS>anim | init cnt scale -- val
    'a ! ;

:toleft
    -0.8 'vx ! 808.0 'x ! 
    1 8 $7f ICS>anim | init cnt scale -- val
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
    300 20 200 100 
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

### Code Breakdown

#### Dynamic Array System
```forth
^r3/util/arr16.r3

#people 0 0 | dynamic array for sort
```
- **arr16**: Array utility for managing collections
- Stores pointer and metadata

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
- **ncell+**: Calculate offset to field in structure
- Accessor words for cleaner code

#### Loading Multiple Sprite Sheets
```forth
'spritesheet 
16 32 "media/img/p1.png" ssload swap !+
16 32 "media/img/p2.png" ssload swap !+
16 32 "media/img/p3.png" ssload swap !
```
- Load three different sprite sheets
- Store in array for random selection

#### Array Initialization
```forth
2000 'people p.ini
```
- **p.ini**: Initialize array with capacity for 2000 objects

#### Object Update Function
```forth
:person | v -- 
    dup 8 + >a
    a@+ int. a@+ int.   | x y
    a@+ dup 32 >> swap $ffffffff and | rot zoom
    a@ timer+ dup a!+ anim>n            | n
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
```
- **>a**: Push to auxiliary register for easier access
- **a@+**: Fetch and increment auxiliary pointer
- **timer+**: Add elapsed time for animation
- **anim>n**: Convert animation value to frame number
- **between**: Check if value is within range
- **2drop 0**: Remove object if out of bounds, put 0 for remove for dynamic array

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
- **p!+**: Add object to array with update function
- Pack angle and zoom into single value

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
- Randomly choose left or right direction
- Randomly select one of three sprite sheets
- Random y position between 150-550

#### Animation Encoding
```forth
10 8 $7f ICS>anim | init cnt scale -- val
```
- **ICS>anim**: Encode animation parameters
- init: Starting frame
- cnt: Frame count
- scale: Animation speed

#### Drawing All Objects
```forth
timer.
'people p.drawo     | draw sprites
2 'people p.sort    | sort for draw (y coord)
```
- **timer.**: Update global timer
- **p.drawo**: Draw all objects in array
- **p.sort**: Sort by field 2 (y coordinate) for proper overlap (1 buble sort cycle)

#### Timer System
```forth
timer<              | Start timer
timer.              | Update timer
timer+              | Add elapsed time
```

### Key Concepts

- **Dynamic arrays**: Manage collections of objects
- **Object-oriented approach**: Structures with methods
- **Depth sorting**: Draw back-to-front based on y coordinate
- **Automatic culling**: Remove objects outside screen
- **Multiple sprite sheets**: Variety through random selection
- **Encoded data**: Pack multiple values into single field
- **Timer-based animation**: Frame-independent animation
- **Auxiliary stack**: Simplify complex data access

### Array and Timer Reference

| Function | Parameters | Description |
|----------|------------|-------------|
| `p.ini` | capacity array | Initialize array |
| `p!+` | function array | Add object |
| `p.drawo` | array | Draw all objects |
| `p.sort` | field array | Sort by field |
| `timer<` | -- | Start timer |
| `timer.` | -- | Update timer |
| `timer+` | value | Add time to value |
| `anim>n` | anim | Get frame number |
| `ICS>anim` | i c s | Create animation |
| `ncell+` | n | Calculate offset |
| `between` | val min max | Check range |

---

## Reference Guide

### Essential SDL2 Functions

#### Window Management
```forth
title width height SDLinit    | Initialize window
SDLquit                        | Clean up and close
'function SDLShow              | Run main loop
SDLkey                         | Get keyboard input
```

#### Drawing Functions
```forth
color sdlcls                   | Clear screen
color sdlcolor                 | Set draw color
x y w h sdlfrect              | Filled rectangle
x y w h sdlrect               | Rectangle outline
x1 y1 x2 y2 sdlline           | Line
x y sdlpoint                  | Point
cx cy rx ry SDLEllipse        | Ellipse outline
cx cy rx ry SDLFEllipse       | Filled ellipse
x1 y1 x2 y2 x3 y3 SDLTriangle | Filled triangle
sdlredraw                     | Update display
```

#### Image and Sprite Functions
```forth
filename loadimg              | Load PNG image
x y handle sprite             | Draw sprite
w h filename ssload           | Load sprite sheet
x y n sheet ssprite           | Draw frame
x y zoom n sheet sspritez     | Draw frame with zoom
x y zoom rot n sheet sspriterz | Draw with zoom and rotation
```

### Text Functions

```forth
filename size txload          | Load TrueType font
font txfont                   | Set current font
color txrgb                   | Set text color
x y txat                      | Set cursor position
string txprint                | Print text
string txprintr               | Print right-aligned
x y w h string txText         | Render in box
mode txalign                  | Set alignment
```

### Math and Logic

```forth
+ - * /                       | Basic arithmetic
neg                           | Negate value
<< >>                         | Bit shift
and or xor                    | Bitwise operations
< > =                         | Comparisons
<? >? =?                      | Conditional execution
int.                          | Fixed point to int
```

### Stack Operations

```forth
dup                           | Duplicate top
drop                          | Remove top
swap                          | Swap top two
over                          | Copy second
2dup                          | Duplicate top two
2drop                         | Remove top two
```

### Memory Operations

```forth
#name                         | Declare variable
'name                         | Get address
!                            | Store at address
@                            | Fetch from address
+!                           | Add to variable
```

### Variables and Constants

```forth
sw                           | Screen width
sh                           | Screen height
msec                         | Milliseconds
```

### Key Constants

```forth
>esc<                        | ESC key
<w> <a> <s> <d>             | WASD keys (down)
>w< >a< >s< >d<             | WASD keys (up)
<esp>                        | Space key
```

### Control Flow

```forth
:name ... ;                  | Define word
( ... )                      | Execute if true
exit                         | Exit program
```

### Program Structure Template

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

1. **Use meaningful variable names** with `#` prefix
2. **Comment your code** with `|` for clarity
3. **Keep functions small** and focused
4. **Clear the screen** every frame with `sdlcls`
5. **Call sdlredraw** after all drawing
6. **Handle ESC key** for clean exit
7. **Use fixed point** (.0) for smooth movement
8. **Load resources** before entering main loop
9. **Check boundaries** to prevent objects going off-screen
10. **Use auxiliary stack** (>a, a@+) for complex structures

### Common Patterns

#### Simple Animation Loop
```forth
:main
    0 SDLcls
    | draw code here
    SDLredraw
    SDLkey >esc< =? ( exit ) drop ;
```

#### Velocity-Based Movement
```forth
#x #y #vx #vy

:update
    vx 'x +!
    vy 'y +!
    ;
```

#### Boundary Checking
```forth
x 0 <? ( 0 'x ! ) 800.0 >? ( 800.0 'x ! ) drop | warning, if use fixed point  !!
```

#### Key Handler
```forth
SDLkey
>esc< =? ( exit )
<w> =? ( do_something )
drop
```

#### Timer-Based Animation
```forth
timer<                      | Initialize once
timer.                      | Update each frame
some_value timer+ anim>n    | Get current frame
```

