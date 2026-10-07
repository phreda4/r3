# R3Forth VarAnim Library (varanim.r3)

A powerful variable animation system for R3Forth that provides time-based interpolation of values with easing functions, enabling smooth transitions and scheduled code execution.

## Overview

VarAnim manages a timeline of animations and scheduled events. It supports:
- **Value interpolation** - Smooth transitions between numeric values
- **Multiple data types** - Single values, boxes (4 values), XY pairs, colors
- **Easing functions** - 30+ easing curves via Penner equations
- **Scheduled execution** - Time-delayed code execution
- **Efficient updates** - Single update call processes all animations

**Dependencies:**
- `r3/lib/mem.r3` - Memory management
- `r3/lib/color.r3` - Color blending utilities
- `r3/util/penner.r3` - Easing functions

**Time format**: All durations use fixed-point seconds (1.0 = 1 second)

---

## Initialization

### System Setup

- **`vaini`** `( max -- )` - Initialize animation system
  - `max`: Maximum number of concurrent animations/events
  - Allocates memory for timeline and animation variables
  - Must be called before using any animation functions
  ```
  100 vaini  | Support up to 100 animations
  ```

- **`vareset`** `( -- )` - Reset animation system
  - Clears all active animations
  - Resets timeline to current time
  - Useful for scene transitions or level resets

---

## Animation Updates

- **`vupdate`** `( -- )` - Update all animations
  - Must be called once per frame
  - Processes elapsed time since last update
  - Executes scheduled events and interpolates values
  - Automatically removes completed animations
  ```
  vupdate  | Call in main loop
  ```

### Time Variables

- **`deltatime`** - Time elapsed since last update (milliseconds). Set by `vupdate`, `timer<` and `timer.`
- `timenow` - Current animation system time (milliseconds from start); **private** (`#`), not exported

### Standalone Timer

Independent of the animation timeline; they only write `deltatime` (used by `timer+`, `timer-` and `ani+timer!`). Do not call `timer.` in the same loop as `vupdate`, both update `deltatime`.

- **`timer<`** `( -- )` - Reset timer: stores current `msec` and sets `deltatime` to 0
- **`timer.`** `( -- )` - Advance timer: `deltatime` = `msec` - previous `msec`
- **`timer+`** `( t -- t' )` - Add `deltatime` to `t`
- **`timer-`** `( t -- t' )` - Subtract `deltatime` from `t`
  ```r3forth
  timer<                 | once, at start
  :loop timer. ... pos timer+ 'pos ! ;
  ```

### Internal Pointers (exported)

`timeline`, `timeline<`, `timeline>` and `exevar` are exported variables holding internal pointers: `timeline` is the start of the event array (8 bytes per event, sorted by start time), `timeline<` the boundary between pending and running events, `timeline>` the end, and `exevar` the base of the slot table (32 bytes per event). Not meant to be modified; `timeline> timeline - 3 >>` is what `vaempty` computes.

---

## Value Animation

### Single Value Interpolation

- **`+vanim`** `( 'var ini fin ease dur start -- )` - Animate single value
  - `'var`: Address of variable to animate
  - `ini`: Initial value (fixed-point)
  - `fin`: Final value (fixed-point)
  - `ease`: Easing function index (0-30, see Penner library)
  - `dur`: Duration in seconds (fixed-point)
  - `start`: Start time in seconds (fixed-point, 0.0 = now)
  ```
  'xpos 100.0 500.0 1 2.0 0.0 +vanim
  | Animate xpos from 100 to 500 over 2 seconds with ease 1
  ```

### Packed Data Animation

- **`+vboxanim`** `( 'var ini fin ease dur start -- )` - Animate 4×16-bit box
  - Interpolates 4 signed 16-bit values packed in 64 bits
  - Format: x, y, w, h (each 16 bits)
  - Useful for animating rectangles
  ```
  'boxvar 
  100 100 200 150 xywh64  | Initial: x=100 y=100 w=200 h=150
  300 200 250 200 xywh64  | Final: x=300 y=200 w=250 h=200
  2 1.5 0.5 +vboxanim
  ```

- **`+vxyanim`** `( 'var ini fin ease dur start -- )` - Animate 2×32-bit XY pair
  - Interpolates X and Y as two 32-bit signed integers
  - Format: X in high 32 bits, Y in low 32 bits
  ```
  'position 
  100 200 xy32  | Initial position
  500 400 xy32  | Final position
  5 1.0 0.0 +vxyanim
  ```

- **`+vcolanim`** `( 'var ini fin ease dur start -- )` - Animate RGBA color
  - Interpolates 4 color channels (8 bits each)
  - Uses color mixing for smooth transitions
  - Format: $AARRGGBB
  ```
  'color 
  $ff0000ff  | Initial: blue
  $ffff0000  | Final: red
  10 2.0 0.0 +vcolanim
  ```

---

## Scheduled Execution

### Execute Functions at Time

- **`+vexe`** `( 'vector start -- )` - Execute function at specified time
  - Schedules code execution for future time
  - The word is called with an address on the stack that it must leave balanced (it is dropped afterwards); it has no parameters of its own
  ```
  [ "Event triggered!" print ; ] 3.0 +vexe
  | Execute in 3 seconds
  ```

- **`+vvexe`** `( v 'vector start -- )` - Execute with 1 parameter
  - The word receives the **address** of the stored value, not the value: read it with `dup @` (leaving the address on the stack)
  ```
  42 [ dup @ "Value: %d" .println ; ] 2.0 +vvexe
  | Execute in 2 seconds with value 42
  ```

- **`+vvvexe`** `( v1 v2 'vector start -- )` - Execute with 2 parameters
  - The word receives the address of the stored pair: `dup @+ swap @` gives `v2 v1` (as in `chipa.r3`: `dup @+ swap @ swap`)
  ```
  100 200 [ dup @+ swap @ "%d %d" .println ; ] 1.5 +vvvexe
  | Execute in 1.5 seconds with values 100 and 200
  ```

---

## Groups

Every event has a group tag (0-15; only the low 4 bits are used). The non-`g` words use group 0. The `g` variants take one extra `group` argument at the end:

- **`+vanimg`**, **`+vboxanimg`**, **`+vxyanimg`**, **`+vcolanimg`** `( 'var ini fin ease dur start group -- )`
- **`+vexeg`** `( 'vector start group -- )`
- **`+vvexeg`** `( v 'vector start group -- )`
- **`+vvvexeg`** `( v1 v2 'vector start group -- )`

```r3forth
'xpos 0.0 500.0 2 1.0 0.0 1 +vanimg   | group 1
'ypos 0.0 300.0 2 1.0 0.0 1 +vanimg   | group 1
1 vkillgroup                          | cancel both
```

### Cancelling Events

- **`vkillgroup`** `( group -- )` - Remove all pending events of that group (`0 vkillgroup` removes all events created with the non-`g` words). The animated variables keep their current value
- **`vkillvar`** `( 'var -- )` - Remove all animation events targeting that variable address
- **`vareset`** `( -- )` - Remove all events

---

## Packing/Unpacking Utilities

### Box Format (4×16-bit)

Used for rectangles, sprites, and packed coordinate data.

- **`xywh64`** `( x y w h -- packed )` - Pack 4 values into 64 bits
  - Each value: signed 16-bit (-32768 to 32767)
  - Order: X (bits 48-63), Y (bits 32-47), W (bits 16-31), H (bits 0-15)

- **`64xywh`** `( packed -- x y w h )` - Unpack all 4 values
  - Returns all components as separate values

- **`64xy`** `( packed -- x y )` - Extract X and Y only
- **`64wh`** `( packed -- w h )` - Extract W and H only

- **`64box`** `( packed addr -- )` - Unpack to memory
  - Stores the 4 values (x y w h) as 32-bit integers (`d!+`) at address
  - Useful for direct structure updates

**Example:**
```r3forth
#mybox 0

| Pack initial values
100 200 300 150 xywh64 'mybox !

| Animate to new values
'mybox 
100 200 300 150 xywh64  | From
500 400 350 200 xywh64  | To
2 2.0 0.0 +vboxanim

| Later, unpack for rendering
mybox 64xywh  | -- 100 200 300 150 (interpolated)
rect
```

### XY Format (2×32-bit)

Used for positions and 2D coordinates.

- **`xy32`** `( x y -- packed )` - Pack X,Y into 64 bits
  - X: high 32 bits (signed)
  - Y: low 32 bits (signed)

- **`32xy`** `( packed -- x y )` - Unpack X,Y values

**Example:**
```r3forth
#position 0

| Set initial position
100 200 xy32 'position !

| Animate movement
'position
100 200 xy32  | From (100, 200)
500 400 xy32  | To (500, 400)
5 1.0 0.0 +vxyanim

| Use position
position 32xy drawSprite
```

### Sprite Format (X,Y,R,Z)

Special format for sprite positioning with rotation and scale.

- **`xyrz64`** `( x y r z -- packed )` - Pack sprite data
  - x, y: position (16-bit)
  - r: rotation in bangles (stored divided by 4, 16-bit)
  - z: scale factor (stored divided by 16, 16-bit)

- **`64xyrz`** `( packed -- x y r z )` - Unpack sprite data
  - Returns r multiplied by 4 and z multiplied by 16 (precision loss: the low 2 and 4 bits are discarded when packing)

**Example:**
```r3forth
#spriteData 0

| Initial sprite state
100 200 0 1.0 xyrz64 'spriteData !

| Animate to rotated and scaled
'spriteData
100 200 0 1.0 xyrz64     | From
300 400 0.25 2.0 xyrz64  | To (rotated 90°, scaled 2x)
3 2.0 0.5 +vboxanim

| Render sprite
spriteData 64xyrz drawRotatedSprite
```

---

## System Status

- **`vaempty`** `( -- n )` - Number of events currently in the timeline (pending + running)
  - `0` means no active animations or events
  - Useful for detecting when sequences complete
  ```
  vaempty 0? ( "All animations finished" .println ) drop
  ```

---

## Frame Animation (packed value)

A frame animation is a single 64-bit value, independent from the event timeline. Layout: `init` (12 bits, 63..52), `cnt` (8 bits, 51..44), `now` (8 bits, 43..36), `ms` per frame (12 bits, 35..24), accumulator (24 bits, 23..0).

- **`aniInit`** `( ini cnt fps -- V )` - Create the animation value
  - `ini`: first frame number
  - `cnt`: number of frames (`0` = static, shows `ini`)
  - `fps`: frames per second in **fixed point** (`7.0`, not `7`); `0.0` also gives a static animation
  ```r3forth
  0 4 7.0 aniInit 'anim !   | frames 0..3 at 7 fps
  ```
- **`ani+timer!`** `( 'V -- )` - Advance the animation stored at `'V` by `deltatime`
  ```r3forth
  'anim ani+timer!         | each frame (after timer. or vupdate)
  ```
- **`ani+!`** `( dt 'v -- )` - Same, with an explicit `dt` in milliseconds
- **`aniFrame`** `( V -- f )` - Current frame number (`ini` + current index)
  ```r3forth
  anim aniFrame 'sprites + c@
  ```
- **`aniCnt`** `( V -- c )` - Current index inside the animation (0-based, without `ini`); despite the name it is not the frame count

---

## Easing Functions

`ease` is the index into the `ease` table of `penner.r3` (`ease ( t nro -- t' )`). Only the low 8 bits of the index are used. Index 0 is linear (no easing); indices 1-30 are:

| Index | Easing | Index | Easing | Index | Easing |
|-------|--------|-------|--------|-------|--------|
| 0 | Linear | 10 | Quin_In | 20 | Cir_Out |
| 1 | Quad_In | 11 | Quin_Out | 21 | Cir_InOut |
| 2 | Quad_Out | 12 | Quin_InOut | 22 | Ela_In |
| 3 | Quad_InOut | 13 | Sin_In | 23 | Ela_Out |
| 4 | Cub_In | 14 | Sin_Out | 24 | Ela_InOut |
| 5 | Cub_Out | 15 | Sin_InOut | 25 | Bac_In |
| 6 | Cub_InOut | 16 | Exp_In | 26 | Bac_Out |
| 7 | Quar_In | 17 | Exp_Out | 27 | Bac_InOut |
| 8 | Quar_Out | 18 | Exp_InOut | 28 | Bou_In |
| 9 | Quar_InOut | 19 | Cir_In | 29 | Bou_Out |
| | | | | 30 | Bou_InOut |

See `r3forth-lib-penner.md` for the functions.

-------|-------------|-------------|
| 0 | Linear | Constant speed |
| 1 | Quad In | Accelerating from zero |
| 2 | Quad Out | Decelerating to zero |
| 3 | Quad InOut | Acceleration then deceleration |
| 4 | Cubic In | Stronger acceleration |
| 5 | Cubic Out | Stronger deceleration |
| 10 | Expo In | Exponential acceleration |
| 11 | Expo Out | Exponential deceleration |
| 20 | Elastic Out | Spring-like overshoot |
| 25 | Bounce Out | Bouncing effect |

See Penner library documentation for complete list of 30+ easing functions.

---

## Advanced Features

### Timeline Management

The system maintains an internal timeline with scheduled events:
- Events sorted by execution time
- Automatic removal when complete
- Efficient insertion for maintaining order
- Support for overlapping animations

### Animation Priority

- Animations execute in order of start time
- Multiple animations on same variable allowed
- Last animation "wins" by overwriting value
- Use scheduled execution for sequencing

---

## Complete Examples

### Basic Value Animation

```r3forth
| Setup
100 vaini
vareset

#xpos 0.0
#ypos 0.0

| Animate horizontal movement
:anih
	'xpos 0.0 500.0 2 1.0 0.0 +vanim    | 0→500 in 1 sec, quad-out
	;

| Animate vertical after 0.5 seconds
:aniv
	'ypos 0.0 300.0 5 1.5 0.5 +vanim    | 0→300 in 1.5 sec, cubic-out
	;

| Main loop
:game
    vupdate
    
    | Clear screen
    $000000 cls
    
    | Draw object
    $ffffff color
    xpos ypos 20 20 frect
    
    SDLredraw
    SDLkey 
	>esc< =? ( exit )
	<f1> =? ( aniv )
	<f2> =? ( anih )
	drop ;

'game sdlshow
```

### Sequential Animation

```r3forth
100 vaini

#scale 1.0

| Animation sequence:
| 1. Scale up (0-1 sec)
'scale 1.0 2.0 5 1.0 0.0 +vanim

| 2. Hold (1-2 sec)

| 3. Scale down (2-3 sec)  
'scale 2.0 1.0 5 1.0 2.0 +vanim

| 4. Execute callback at end
[ "Sequence complete!" .write ; ] 3.0 +vexe
```

### Box Animation

```r3forth


#box 0


:render
    vupdate
    
    $000000 cls
    $ff00ff color
    
    box 64xywh frect  | Unpack and draw
    
    SDLredraw
    SDLkey 
	>esc< =? ( exit )
	<f1> =? ( aniv )
	<f2> =? ( anih )
	drop ;

100 vaini
| Initial box: x=50 y=50 w=100 h=100
50 50 100 100 xywh64 'box !
| Animate to larger box in different position
'box
50 50 100 100 xywh64      | From
200 150 300 200 xywh64    | To
3 2.0 0.0 +vboxanim        | Cubic ease, 2 seconds
'render sdlshow

```

### Color Fade

```r3forth

#bgColor $ff000000  | Black

:draw
    vupdate
    bgColor cls
    SDLredraw
    SDLkey 0? ( drop draw ; ) drop ;

:main
100 vaini
| Fade to white over 3 seconds
'bgColor 
$ff000000  | From: black
$ffffffff  | To: white
10 3.0 0.0 +vcolanim
draw
```

### Complex Sequence

```r3forth
#xpos 100.0
#ypos 100.0
#alpha 0.0

:main
100 vaini
| Fade in
'alpha 0.0 1.0 2 0.5 0.0 +vanim

| Move right
'xpos 100.0 500.0 5 1.0 0.5 +vanim

| Move down while moving right
'ypos 100.0 400.0 5 1.0 0.5 +vanim

| Print message when movement completes
[ "Movement finished" .write ; ] 1.5 +vexe

| Fade out
'alpha 1.0 0.0 2 0.5 2.0 +vanim

| Clean up when done
[ "Sequence complete" .write vareset ; ] 2.5 +vexe
```

### Sprite Animation

```r3forth
#sprite 0

:render
    vupdate
    
    $000000 cls
    
    sprite 64xyrz   | -- x y r z
    myTexture       | Add texture
    drawRotScaleSprite
    
    SDLredraw
    SDLkey 
	>esc< =? ( exit )
	drop ;
	
:main
100 vaini
| Initial: position (100,100), no rotation, scale 1.0
100 100 0 1.0 xyrz64 'sprite !
| Animate: move, rotate 180°, scale to 2x
'sprite
100 100 0 1.0 xyrz64       | From
400 300 0.5 2.0 xyrz64     | To (0.5 = 180°)
3 2.0 0.0 +vboxanim
'render sdlshow
```

---

## Notes

- **Memory management**: Pre-allocate with `vaini`, no dynamic allocation
- **Time precision**: Uses milliseconds internally for accuracy
- **Concurrent animations**: Multiple animations can target same variable
- **Completion detection**: Use `vaempty` or scheduled callback
- **Performance**: Insertion is a linear scan plus a memory move (O(n)); O(n) update per frame
- **Fixed-point math**: All durations and start times in fixed-point seconds
- **Easing functions**: Index 0-30 (table above)
- **Variable safety**: Ensure animated variables persist (not stack-allocated)
- **Reset caution**: `vareset` clears ALL animations immediately

## Common Patterns

### Wait for Animation

```r3forth

| Poll until done
:waitAnim
    vupdate
    vaempty 0? ( drop ; ) drop | Exit when empty
    waitAnim ;

| Start animation
'value 0.0 100.0 2 1.0 0.0 +vanim
waitAnim
"Animation complete!" .write
```

### Chain Animations

```r3forth
| Use start times to chain
'x 0.0 100.0 2 1.0 0.0 +vanim    | 0.0-1.0s
'x 100.0 200.0 2 1.0 1.0 +vanim  | 1.0-2.0s
'x 200.0 0.0 2 1.0 2.0 +vanim    | 2.0-3.0s
```

### Looping Animation

```r3forth
:startLoop
    'x 0.0 100.0 2 1.0 0.0 +vanim
    'startLoop 1.0 +vexe ;  | Restart at end

startLoop
```

## Limitations

- Maximum concurrent animations set by `vaini`
- No pause/resume functionality (must restart)
- Cannot modify running animations
- Single global timeline (no separate timers)
- 16-bit limits for packed box values (-32768 to 32767)

