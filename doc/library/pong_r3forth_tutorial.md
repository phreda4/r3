# Programming Pong in R3forth - Real Code Analysis

**Learning Game Development from Actual Working Code**

This tutorial analyzes the complete pong.r3 implementation by PHREDA, teaching R3forth programming through the original arcade game that started it all.

---

## Table of Contents

1. [Game Overview](#game-overview)
2. [Project Structure](#project-structure)
3. [Custom Score Display](#custom-score-display)
4. [Player System](#player-system)
5. [Ball Physics](#ball-physics)
6. [Collision Detection](#collision-detection)
7. [Game States and Reset](#game-states-and-reset)
8. [Input Handling](#input-handling)
9. [Complete Code Analysis](#complete-code-analysis)
10. [Learning Exercises](#learning-exercises)

---

## Game Overview

**Pong Rules:**
- Two paddles control vertical movement on opposite sides
- Ball bounces between paddles and top/bottom walls
- Ball speeds up when hit at paddle edges (spin effect)
- Score increases when opponent misses the ball
- Classic arcade-style competitive gameplay

**Programming Concepts This Game Teaches:**
- **Bitmap Graphics**: Custom digit rendering with binary patterns
- **Physics Simulation**: Ball trajectory with paddle interaction
- **Two-Player Input**: Independent control systems
- **Score Management**: Digital display and game state tracking
- **Classic Game Design**: Fundamental arcade game mechanics

---

## Project Structure

### Library Dependencies

```forth
| r3 pong
| PHREDA
^r3/lib/sdl2gfx.r3
^r3/lib/rand.r3
```

**Libraries Used:**
- `sdl2gfx.r3` - Graphics primitives and rectangle drawing
- `rand.r3` - Random ball direction generation

### Game State Variables

```forth
#yj1 #v1 #p1    | Player 1: position, velocity, points
#yj2 #v2 #p2    | Player 2: position, velocity, points
#x #y #vx #vy   | Ball: position and velocity
#xx #yy         | Graphics helpers for digit drawing
#startx #starty | Digit rendering position
```

---

## Custom Score Display

### Binary Digit Patterns

```forth
#dig0 ( %1111 %1001 %1001 %1001 %1111 )
#dig1 ( %0001 %0001 %0001 %0001 %0001 )
#dig2 ( %1111 %0001 %1111 %1000 %1111 )
#dig3 ( %1111 %0001 %1111 %0001 %1111 )
#dig4 ( %1001 %1001 %1111 %0001 %0001 )
#dig5 ( %1111 %1000 %1111 %0001 %1111 )
#dig6 ( %0001 %0001 %1111 %1001 %1111 )
#dig7 ( %1111 %0001 %0001 %0001 %0001 )
#dig8 ( %1111 %1001 %1111 %1001 %1111 )
#dig9 ( %1111 %1001 %1111 %0001 %0001 )

#digits 'dig0 'dig1 'dig2 'dig3 'dig4 'dig5 'dig6  'dig7 'dig8 'dig9
```

**Bitmap Analysis:**
- Each digit defined as 5×4 bitmap using binary literals
- `%1111` represents row of 4 pixels (1=on, 0=off)
- Classic 7-segment display appearance
- Lookup table `#digits` for array access

### Bitmap Rendering System

```forth
:** | 0/1 --
	and? ( xx yy 20 dup SDLFRect ) 
	20 'xx +! ;

:drawd | addr --
	starty 'yy !
	5 ( 1? 1 - swap 
		c@+ startx 'xx !
		%1000 ** %0100 ** %0010 ** %0001 ** 
		drop 20 'yy +! swap ) 2drop ;
```

**Rendering Algorithm:**
1. `**` function tests bit and draws 20×20 pixel if set
2. `%1000 ** %0100 ** %0010 ** %0001 **` - Test each bit in 4-bit row
3. `20 'xx +!` advances to next pixel column
4. `20 'yy +!` advances to next row
5. Result: 5×4 grid of 20×20 pixel squares = 100×80 digit

### Score Display Functions

```forth
:drawdigit | n --
  3 << 'digits + @ drawd ;

:drawnumber | n x y --
  'starty ! 'startx !
  dup 10 / 10 mod drawdigit
  100 'startx +! 10 mod drawdigit ;
```

**Two-Digit Display:**
- `10 / 10 mod` extracts tens digit
- `100 'startx +!` spaces digits 100 pixels apart
- `10 mod` extracts ones digit
- Handles scores 0-99 with leading zeros

---

## Player System

### Paddle Physics

```forth
#yj1 #v1 #p1

:j1 $ff0000 SDLColor 10 yj1 20 80 SDLFRect v1 'yj1 +! ;

#yj2 #v2 #p2

:j2 $ff SDLColor 770 yj2 20 80 SDLFRect v2 'yj2 +! ;
```

**Player Implementation:**
- **Player 1**: Red paddle at x=10, controlled by Q/A keys
- **Player 2**: Blue paddle at x=770, controlled by arrow keys
- **Physics**: `v1 'yj1 +!` applies velocity to position each frame
- **Size**: 20×80 pixel rectangles

### Position Management

```forth
	260 'yj1 ! 260 'yj2 !    | Reset to center positions
```

Paddles start at y=260 (center of 600-pixel screen height)

---

## Ball Physics

### Ball State and Movement

```forth
#x #y #vx #vy | ball pos

:pelota
	$ffffff SDLColor
	x int. y int. 20 20 SDLFRect
	vx 'x +! vy 'y +!
	y 0 <? ( hity ) 580.0 >? ( hity ) drop
	x 
	30.0 <? ( hit1 ) 0 <? ( pierde1 )
	750.0 >? ( hit2 ) 780.0 >? ( pierde2 ) 
	drop
	;
```

**Ball Physics:**
1. **Rendering**: White 20×20 pixel square
2. **Position Update**: `vx 'x +!` and `vy 'y +!` (Euler integration)
3. **Wall Bouncing**: Top (y<0) and bottom (y>580) trigger `hity`
4. **Paddle Zones**: 
   - x<30: Player 1 paddle area
   - x>750: Player 2 paddle area
   - x<0 or x>780: Out of bounds (score)

### Ball Reset and Initialization

```forth
:reset 
	400.0 'x ! 290.0 'y ! 
	3.0 randmax 1.0 + 
	%1000 and? ( neg )
	'vx ! 0 'vy ! 
	260 'yj1 ! 260 'yj2 !
	;
```

**Reset Algorithm:**
1. Center ball at (400, 290)
2. Random horizontal velocity: 1.0 to 4.0
3. `%1000 and?` - 50% chance to negate (random direction)
4. Zero vertical velocity (horizontal start)
5. Reset paddles to center positions

---

## Collision Detection

### Paddle-Ball Interaction

```forth
:hit1 | x -- x
	y int.
	yj1 30 + -        | ball_y - (paddle_center + 30)
	-40 <? ( drop ; ) 40 >? ( drop ; )
	0.1 * 'vy +!      | Add spin based on hit position
	30.0 'x ! hitx ;  | Move ball away from paddle, reverse x velocity

:hit2
	y int.
	yj2 30 + -        | Same for player 2
	-40 <? ( drop ; ) 40 >? ( drop ; )
	0.1 * 'vy +! 
	750.0 'x ! hitx ;
```

**Collision Physics:**
1. **Hit Detection**: Ball position relative to paddle center
2. **Hit Zone**: ±40 pixels from paddle center (80-pixel paddle height)
3. **Spin Effect**: `0.1 *` applies velocity based on hit position
   - Hit near top: Negative vy (ball goes up)
   - Hit near bottom: Positive vy (ball goes down)
   - Hit in center: Little velocity change
4. **Ball Positioning**: Move ball away from paddle to prevent sticking
5. **Velocity Reversal**: `hitx` reverses horizontal velocity

### Collision Response

```forth
:hitx vx neg 'vx ! ;
:hity vy neg 'vy ! ;
```

Perfect elastic collision - velocity component perpendicular to surface is negated.

---

## Game States and Scoring

### Score Events

```forth
:pierde1 1 'p2 +! reset ;
:pierde2 1 'p1 +! reset ;
```

**Scoring Logic:**
- Player 1 misses (ball x<0): Player 2 gets point
- Player 2 misses (ball x>780): Player 1 gets point
- Automatic reset after each score

### Game State Display

```forth
	$ff0000 SDLColor p1 sw 1 >> 220 - 20 drawnumber
	$ff SDLColor p2 sw 1 >> 20 + 20 drawnumber
```

**Score Positioning:**
- `sw 1 >> 220 -` = screen_center - 220 (left side)
- `sw 1 >> 20 +` = screen_center + 20 (right side)
- Scores positioned symmetrically around center

---

## Input Handling

### Two-Player Control System

```forth
	SDLkey 
	>esc< =? ( exit )
	<q> =? ( -3 'v1 ! ) >q< =? ( 0 'v1 ! )
	<a> =? ( 3 'v1 ! ) >a< =? ( 0 'v1 ! )
	<up> =? ( -3 'v2 ! ) >up< =? ( 0 'v2 ! )
	<dn> =? ( 3 'v2 ! ) >dn< =? ( 0 'v2 ! )
	drop ;
```

**Control Mapping:**
- **Player 1**: Q (up), A (down)
- **Player 2**: Arrow keys (up/down)
- **Velocity**: ±3 pixels per frame
- **Key Release**: Set velocity to 0 (immediate stop)

---

## Key R3forth Patterns

### Binary Pattern Processing

```forth
| Binary literals for bitmap data:
%1111    | 4-bit binary pattern
%1001    | Represents pixel row

| Bit testing:
value %1000 and?  | Test specific bit
```

### Fixed Point Arithmetic

```forth
| Fixed point positions and velocities:
#x #y #vx #vy          | Ball state
400.0 'x !             | Fixed point literal
3.0 randmax 1.0 +      | Fixed point arithmetic
```

### Array Indexing

```forth
| Lookup table access:
digit 3 << 'digits + @ | Multiply by 8 for address array
n 10 / 10 mod          | Extract decimal digits
```

### Graphics State Management

```forth
| Color setting before drawing:
$ff0000 SDLColor       | Set red color
x int. y int. w h SDLFRect  | Convert fixed point to pixels
```

---

## Algorithm Analysis

### Time Complexity
- **Physics Update**: O(1) - Fixed calculations per frame
- **Collision Detection**: O(1) - Fixed number of collision checks
- **Digit Rendering**: O(1) - Fixed 5×4 bitmap per digit
- **Input Processing**: O(1) - Fixed number of keys

### Space Complexity
- **Game State**: O(1) - Fixed variables for players and ball
- **Digit Bitmaps**: O(1) - Fixed 10 digits × 5 rows each
- **Graphics Buffers**: O(1) - Screen-dependent, not game-dependent
- **Total**: O(1) - Constant memory usage

### Performance Characteristics
- **Frame Rate**: Stable - all operations are O(1)
- **Input Latency**: Single frame (immediate response)
- **Memory Usage**: Minimal - only essential game state
- **Deterministic**: Fixed computation time per frame

---

## Learning Exercises

### Beginner Level
1. **Visual Improvements**: Paddle and ball textures, background patterns
2. **Sound Effects**: Paddle hits, wall bounces, scoring sounds
3. **Game Enhancements**: Pause feature, score limits, win conditions
4. **AI Opponent**: Computer-controlled paddle with difficulty levels

### Intermediate Level
1. **Power-ups**: Speed changes, paddle size changes, multi-ball
2. **Visual Effects**: Ball trails, particle effects, screen shake
3. **Game Modes**: Tournament mode, time-limited games
4. **Statistics**: Shot accuracy, average rally length, game duration

### Advanced Level
1. **Advanced AI**: Neural network or minimax computer opponent
2. **Network Play**: Online multiplayer with prediction/rollback
3. **Physics Enhancement**: Realistic ball physics with spin persistence
4. **Tournament System**: Bracket-based competition with rankings

### Programming Challenges
1. **Optimization**: 60+ FPS with complex visual effects
2. **Precision Physics**: Sub-pixel collision detection
3. **State Prediction**: Client-side prediction for network play
4. **Custom Graphics**: Hardware-accelerated sprite rendering

---

## Code Quality Analysis

### Strengths
1. **Classic Simplicity**: Pure gameplay with no unnecessary features
2. **Efficient Rendering**: Custom bitmap system for score display
3. **Responsive Physics**: Immediate paddle response and ball interaction
4. **Clean Architecture**: Each component has single responsibility

### Areas for Enhancement
1. **Magic Numbers**: Hard-coded coordinates and speeds throughout
2. **Game States**: Missing menu, pause, and game over screens
3. **Bounds Checking**: Paddle positions can go off-screen
4. **Configuration**: No easy way to adjust game parameters

### R3forth Techniques Demonstrated
1. **Binary Literals**: Using `%` prefix for bitmap pattern data
2. **Bit Manipulation**: Testing bits with `and?` for graphics
3. **Fixed Point Math**: Sub-pixel precision for smooth movement
4. **Array Processing**: Lookup tables and indexed access

---

## Key Programming Insights

### Classic Game Design Principles
1. **Simplicity**: Core gameplay loop with minimal complexity
2. **Immediate Feedback**: Every action has instant visual response
3. **Progressive Difficulty**: Ball speed increases with paddle edge hits
4. **Competitive Balance**: Symmetric gameplay for fair competition

### Real-Time Programming Fundamentals
1. **Fixed Timestep**: Consistent physics regardless of frame rate
2. **State Consistency**: Complete update before rendering
3. **Input Sampling**: Process input once per frame
4. **Deterministic Behavior**: Same inputs produce same results

### Graphics Programming Patterns
1. **Custom Rendering**: Bitmap-based digit display system
2. **Efficient Drawing**: Minimal state changes and draw calls
3. **Coordinate Systems**: Screen-space calculations with centering
4. **Visual Feedback**: Color coding for different players/elements

This Pong implementation showcases the essence of game programming - taking simple rules and creating engaging, responsive gameplay through careful attention to physics, timing, and player feedback. It demonstrates how fundamental programming concepts combine to create timeless entertainment.

---

**Original Code**: PHREDA  
**Repository**: https://github.com/phreda4/r3  
**Tutorial**: Educational analysis for learning R3forth programming