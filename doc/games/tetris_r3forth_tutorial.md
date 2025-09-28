# Programming Tetris in R3forth - Real Code Analysis

**Learning Advanced Game Development from Actual Working Code**

This tutorial analyzes the complete tetris.r3 implementation by PHREDA, teaching advanced R3forth programming through real, tested code.

---

## Table of Contents

1. [Game Overview](#game-overview)
2. [Project Structure](#project-structure)
3. [Data Structures](#data-structures)
4. [Piece Representation](#piece-representation)
5. [Coordinate Systems](#coordinate-systems)
6. [Collision Detection](#collision-detection)
7. [Line Clearing Logic](#line-clearing-logic)
8. [Rotation System](#rotation-system)
9. [Game State Management](#game-state-management)
10. [Complete Code Analysis](#complete-code-analysis)
11. [Learning Exercises](#learning-exercises)

---

## Game Overview

**Classic Tetris Rules:**
- Seven different piece types (I, O, T, S, Z, J, L pieces)
- Pieces fall down the playfield automatically
- Player can move left/right, rotate, and drop pieces faster
- Complete horizontal lines disappear and award points
- Game speeds up as player progresses
- Game ends when pieces reach the top

**Advanced Programming Concepts This Game Teaches:**
- **Complex Data Structures**: Multi-dimensional arrays and lookup tables
- **Coordinate Transformations**: Multiple coordinate systems working together
- **State Machines**: Piece states, rotation states, game states
- **Algorithm Optimization**: Efficient collision detection and line clearing
- **Pattern Matching**: Template-based piece definitions

---

## Project Structure

### Library Dependencies

```forth
| tetris r3
| PHREDA 2020
|-------------------
^r3/lib/sdl2gfx.r3
^r3/util/sdlgui.r3
^r3/lib/rand.r3
```

**Libraries Used:**
- `sdl2gfx.r3` - Graphics primitives for drawing blocks
- `sdlgui.r3` - UI elements (score, next piece preview)
- `rand.r3` - Random piece generation

### Global Game State

```forth
#grid * 800 | 10 * 20 *4

#colors [ 0 $ffff $ff $ff8040 $ffff00 $ff00 $ff0000 $800080 ]

#pieces (
	1 5 9 13
	1 5 9 8
	1 5 9 10
	0 1 5 6
	1 2 4 5
	1 4 5 6
	0 1 4 5 )

#rotate> (
	8 4 0 0
	9 5 1 13
	10 6 2 0
	0 7 0 0 )

#mask [
	$000 $001 $002 $003
	$100 $101 $102 $103
	$200 $201 $202 $203
	$300 $301 $302 $303 ]
```

**Data Structure Analysis:**

**Grid Layout:**
- `#grid * 800` - Playfield: 10 columns × 20 rows × 4 bytes = 800 bytes
- Each cell stores color value (0 = empty, 1-7 = piece colors)

**Color Palette:**
- Index 0: Black (empty)
- Index 1: Cyan ($ffff) - I piece
- Index 2: Blue ($ff) - J piece  
- Index 3: Orange ($ff8040) - L piece
- Index 4: Yellow ($ffff00) - O piece
- Index 5: Green ($ff00) - S piece
- Index 6: Red ($ff0000) - Z piece
- Index 7: Purple ($800080) - T piece

**Piece Definitions:**
- Each piece defined as 4 coordinate offsets from center
- Coordinates packed as single bytes (x + y×16)
- 7 pieces × 4 blocks each = 28 values total

---

## Piece Representation

### Piece Templates

```forth
#pieces (
	1 5 9 13    | I piece: vertical line
	1 5 9 8     | J piece: L-shape backwards  
	1 5 9 10    | L piece: L-shape forward
	0 1 5 6     | O piece: square
	1 2 4 5     | S piece: zigzag
	1 4 5 6     | Z piece: zigzag reverse
	0 1 4 5 )   | T piece: T-shape
```

**Coordinate Encoding Analysis:**
- Each number represents a block position relative to pivot
- Coordinates packed: `x + y * 16`
- Example for I-piece: `1 5 9 13`
  - 1 = (1,0) - one right
  - 5 = (5,0) - five right  
  - 9 = (9,0) - nine right
  - 13 = (13,0) - thirteen right

Wait, this encoding seems incorrect for typical Tetris pieces. Let me reanalyze:

Looking at the `inmask` function and `#mask` array, these are likely indices into a 4×4 grid:
- 0-3: Top row (y=0, x=0-3)
- 4-7: Second row (y=1, x=0-3)  
- 8-11: Third row (y=2, x=0-3)
- 12-15: Bottom row (y=3, x=0-3)

So I-piece `1 5 9 13` = positions (1,0), (1,1), (1,2), (1,3) = vertical line!

### Rotation System

```forth
#rotate> (
	8 4 0 0
	9 5 1 13
	10 6 2 0
	0 7 0 0 )
```

**Rotation Table Analysis:**
- Each piece has 4 rotation states (0°, 90°, 180°, 270°)
- `rotate>` maps current block position to rotated position
- Some positions map to 0 (invalid/unused rotations)

### Mask Translation

```forth
#mask [
	$000 $001 $002 $003
	$100 $101 $102 $103
	$200 $201 $202 $203
	$300 $301 $302 $303 ]

:inmask | ( v1 -- v2)
	2 << 'mask + d@ ;
```

**Coordinate Conversion:**
- Converts 4×4 grid index to packed coordinate
- `$201` = x=1, y=2 in packed format
- Allows pieces to be defined in simple 4×4 template

---

## Coordinate Systems

### Multiple Coordinate Representations

```forth
:packed2xy | n -- x y
	dup $ff and 4 << 50 +
	swap 8 >> 4 << 100 +
	;

:packed2grid | coord -- realcoord
	dup $f and 1 - | x
	swap 8 >> 10 * +
	2 << 'grid + ;
```

**Three Coordinate Systems:**

1. **Template Coordinates**: 4×4 grid indices (0-15)
2. **Game Coordinates**: Packed format (x + y×256)
3. **Screen Coordinates**: Pixel positions for drawing

**Conversion Pipeline:**
```
Template Index → inmask → Game Coordinate → packed2xy → Screen Pixels
Template Index → packed2grid → Memory Address
```

### Player State Variables

```forth
#player 0 0 0 0
#playeryx 0
#playercolor 0
#points 0
#nextpiece 0
#speed 300
```

**State Analysis:**
- `#player` - Current piece template (4 block positions)
- `#playeryx` - Piece position on playfield  
- `#playercolor` - Color index for current piece
- `#points` - Score accumulation
- `#nextpiece` - Preview piece type
- `#speed` - Drop timing (milliseconds between drops)

---

## Collision Detection

### Block Collision Check

```forth
:block_collision? | pos -- 0/pos
	$1400 >? ( drop 0 ; )
	dup packed2grid d@ 1? ( 2drop 0 ; ) drop
	$ff and
	0? ( drop 0 ; )
	10 >? ( drop 0 ; )
	;
```

**Collision Analysis:**
1. `$1400 >?` - Check if below playfield (out of bounds vertically)
2. `packed2grid d@` - Get grid cell value at position
3. `1? ( 2drop 0 ; )` - If cell occupied (non-zero), collision detected
4. `$ff and` - Extract x coordinate
5. `0? ( drop 0 ; )` - If x < 0, collision (left wall)
6. `10 >? ( drop 0 ; )` - If x ≥ 10, collision (right wall)

**Return Values:**
- 0 = collision detected
- Original position = no collision

### Piece Collision Check

```forth
:piece_collision? | ( v -- v/0 )
	'player
	@+ translate_block pick2 + block_collision? 0? ( nip nip ; ) drop
	@+ translate_block pick2 + block_collision? 0? ( nip nip ; ) drop
	@+ translate_block pick2 + block_collision? 0? ( nip nip ; ) drop
	@  translate_block over  + block_collision? 0? ( nip ; ) drop
	;
```

**Algorithm:**
- Check all 4 blocks of current piece
- `translate_block` converts template to game coordinates
- `pick2 +` adds movement offset to position
- Early exit on first collision detected
- Returns 0 if any block collides, offset if all clear

### Translation Helper

```forth
:translate_block | ( v -- )
	inmask playeryx + ;
```

**Function:**
- `inmask` - Convert template index to packed coordinate
- `playeryx +` - Add current piece position
- Result: Absolute position on playfield

---

## Line Clearing Logic

### Line Detection and Removal

```forth
:removeline |
	'grid dup 40 + swap a> pick2 - 2 >> dmove>
	-1 'speed +!
	1 'combo +! ;

:testline
	0 'combo !
	'grid >a
	0 ( $1400 <?
		0 1 ( 11 <?
			da@+ 1? ( rot 1 + -rot ) drop
			1 + ) drop
		10 =? ( removeline ) drop
		$100 + ) drop
	'combop combo 3 << + @ 'points +!
	;
```

**Algorithm Breakdown:**

**testline Function:**
1. Iterate through all 20 rows of playfield
2. For each row, count non-empty blocks
3. If count equals 10 (full line), call `removeline`
4. Award points based on combo multiplier

**removeline Function:**
1. `'grid dup 40 + swap` - Setup source and destination for move
2. `a> pick2 - 2 >> dmove>` - Shift all rows above down by one
3. `-1 'speed +!` - Increase game speed (decrease delay)
4. `1 'combo +!` - Increment combo counter

### Scoring System

```forth
#combo
#combop 0 40 100 300 1200
```

**Point Values:**
- 0 lines: 0 points
- 1 line: 40 points
- 2 lines: 100 points  
- 3 lines: 300 points
- 4 lines (Tetris): 1200 points

**Combo System:**
- `combo` tracks consecutive line clears in single drop
- `combop` array provides score multipliers
- Classic Tetris scoring with bonus for multiple lines

---

## Rotation System

### Piece Rotation

```forth
:rotate_piece | ( --- )
	'player
	rotate_block !+
	rotate_block !+
	rotate_block !+
	rotate_block ! ;

:rotate_block | ( --- )
	'rotate> + c@ ;
```

**Rotation Algorithm:**
1. For each of 4 blocks in current piece
2. Look up rotated position in `rotate>` table
3. Replace original position with rotated position
4. Update entire piece template

### Rotation Collision Check

```forth
:piece_rcollision? | ( -- 0/x )
	'player
	@+ rotate_block translate_block block_collision? 0? ( nip ; ) drop
	@+ rotate_block translate_block block_collision? 0? ( nip ; ) drop
	@+ rotate_block translate_block block_collision? 0? ( nip ; ) drop
	@  rotate_block translate_block block_collision? ;
```

**Smart Rotation:**
- Test rotation before applying it
- If rotation would cause collision, rotation is blocked
- Prevents pieces from rotating into walls or other pieces

---

## Game State Management

### Piece Creation

```forth
:new_piece
	nextpiece
	'player
	over 1 - 2 << 'pieces +
	c@+ rot !+ swap
	c@+ rot !+ swap
	c@+ rot !+ swap
	c@ swap !
	| dst src cnt
	nthcolor 'playercolor !
	5 'playeryx !
	6 randmax 1 + 'nextpiece !
	;
```

**New Piece Algorithm:**
1. Take piece type from `nextpiece`
2. Copy 4 block positions from `pieces` template to `player`
3. Set piece color using `nthcolor`
4. Position at top-center of playfield (x=5)
5. Generate random next piece (1-6, corresponding to piece types)

### Piece Placement

```forth
:write_block | ( v -- )
	translate_block packed2grid playercolor swap d! ;

:blocked
	'player
	@+ write_block
	@+ write_block
	@+ write_block
	@ write_block
	testline
	new_piece
	;
```

**Block Placement:**
1. Convert each piece block to grid memory address
2. Write piece color to grid at those positions
3. Check for completed lines (`testline`)
4. Create new falling piece

### Game Loop Logic

```forth
:logic
	$100 piece_collision? 0? ( drop blocked ; )
	'playeryx +!
	;

:translate
	piece_collision? 'playeryx +! ;

:rotate
	piece_rcollision? 0? ( drop ; ) drop
	rotate_piece ;
```

**Movement Logic:**
- `logic` - Automatic downward movement (gravity)
- `translate` - Horizontal movement (left/right keys)
- `rotate` - Piece rotation (up key)
- All movements check collision before applying

---

## Graphics and User Interface

### Drawing Functions

```forth
:draw_block | ( x y -- )
	15 15 SDLFRect ;

:visit_block | ( y x -- y x )
	da@+ 0? ( drop ; ) SDLColor
	2dup or packed2xy draw_block ;

:draw_grid | ( --- )
	'grid >a
	0 ( $1400 <?
		1 ( 11 <?
			visit_block
			1 + ) drop
		$100 + ) drop ;
```

**Rendering Pipeline:**
1. `visit_block` - Read grid cell color, set SDL color
2. `packed2xy` - Convert grid coordinates to screen pixels  
3. `draw_block` - Draw 15×15 pixel rectangle
4. `draw_grid` - Iterate through entire playfield

### Player Piece Drawing

```forth
:draw_player_block | ( v -- )
	translate_block packed2xy draw_block ;

:draw_player | ( --- )
	playercolor SDLColor
	'player
	@+ draw_player_block
	@+ draw_player_block
	@+ draw_player_block
	@ draw_player_block ;
```

**Active Piece Rendering:**
- Set color to current piece color
- Draw all 4 blocks at their current positions
- Uses same coordinate translation as collision detection

### Next Piece Preview

```forth
:draw_nextpiece_block | ( v -- )
	inmask 15 + packed2xy draw_block ;
	  
:draw_nextpiece
	nextpiece dup nthcolor SDLColor
	1 - 2 << 'pieces +
	c@+ draw_nextpiece_block
	c@+ draw_nextpiece_block
	c@+ draw_nextpiece_block
	c@ draw_nextpiece_block ;
```

**Preview System:**
- Show next piece in fixed position (offset +15)
- Uses piece template directly (not affected by rotation)
- Gives player strategic planning information

---

## Input and Timing

### Input Processing

```forth
	SDLkey
	>esc< =? ( exit )
	<dn> =? ( 250 'dtime +! )
	<ri> =? ( 1 translate )
	<le> =? ( -1 translate )
	<up> =? ( rotate )
	drop ;
```

**Control Mapping:**
- Down arrow: Soft drop (add 250ms to time accumulator)
- Left/Right arrows: Move piece horizontally
- Up arrow: Rotate piece clockwise
- Escape: Exit game

### Timing System

```forth
	msec dup ntime - 'dtime +! 'ntime !
	dtime speed >? ( dup speed - 'dtime !
		logic
		) drop
```

**Frame-Rate Independent Timing:**
- Accumulate time between frames
- When accumulated time exceeds speed threshold, drop piece
- Speed decreases as game progresses (faster falling)

---

## Complete Program Flow

### Game Loop

```forth
:game | ( --- )
	$444444 SDLcls
	
	immgui 	
	200 28 immbox
	500 50 immat
	"Tetris R3" immlabelc immdn
	points "Points:%d" sprint
	immlabelC immdn	
	'Label immlabelc immdn
	'reset "Reset" immbtn immdn
	'exit "Exit" immbtn 

	$0 SDLColor
	286 96 128 70 SDLFRect
	62 96 166 326 SDLFRect

	draw_grid
	draw_player
	draw_nextpiece

	SDLredraw
	
	msec dup ntime - 'dtime +! 'ntime !
	dtime speed >? ( dup speed - 'dtime !
		logic
		) drop

	SDLkey
	>esc< =? ( exit )
	<dn> =? ( 250 'dtime +! )
	<ri> =? ( 1 translate )
	<le> =? ( -1 translate )
	<up> =? ( rotate )
	drop ;
```

**Game Loop Structure:**
1. Clear screen with gray background
2. Draw GUI (score, buttons, labels)
3. Draw black rectangles for play areas
4. Render game grid, active piece, and next piece
5. Update display
6. Handle timing and automatic piece dropping
7. Process keyboard input

---

## Key R3forth Patterns

### Lookup Table Patterns

```forth
| Color array access:
index 2 << 'colors + d@

| Piece template access:  
piece_type 1 - 2 << 'pieces +

| Rotation mapping:
position 'rotate> + c@

| Scoring table:
combo 3 << 'combop + @
```

### Memory Management

```forth
| Grid addressing:
coordinate packed2grid    | Convert to memory address

| Array operations:
'grid dup 40 + swap ... dmove>  | Bulk memory move

| Register usage:
'grid >a                  | Load address into register A
da@+                      | Fetch and advance register A
```

### Stack Manipulation

```forth
| Complex stack operations:
pick2 + block_collision? 0? ( nip nip ; ) drop

| Coordinate handling:
2dup or packed2xy draw_block

| Multi-value returns:
piece_collision? 0? ( nip ; ) drop
```

---

## Algorithm Analysis

### Time Complexity
- **Collision Detection**: O(1) - Check 4 blocks
- **Line Clearing**: O(w×h) - Scan entire grid  
- **Memory Move**: O(w×h) - Shift rows down
- **Rendering**: O(w×h) - Draw all grid cells

### Space Complexity
- **Grid Storage**: O(w×h) - 10×20×4 = 800 bytes
- **Piece Templates**: O(1) - Fixed 28 values
- **Lookup Tables**: O(1) - Fixed rotation/mask tables
- **Total**: O(w×h) - Dominated by grid size

### Performance Characteristics
- **Frame Rate**: Independent of piece count
- **Memory Usage**: Constant regardless of game progress
- **Input Latency**: Single frame delay
- **Drop Speed**: Configurable timing system

---

## Learning Exercises

### Beginner Level
1. **Visual Improvements**: Better block graphics, backgrounds, animations
2. **Sound Effects**: Line clear sounds, piece placement audio
3. **Difficulty Levels**: Different starting speeds and progression rates
4. **High Scores**: Persistent score tracking and display

### Intermediate Level
1. **Hold Piece**: Ability to save current piece for later use
2. **Ghost Piece**: Show where piece will land
3. **Line Clear Animation**: Visual effects for disappearing lines
4. **Pause Feature**: Ability to pause and resume game

### Advanced Level
1. **T-Spin Detection**: Advanced scoring for T-piece rotations
2. **Wall Kicks**: Allow rotation near walls with position adjustment
3. **Multiplayer**: Two-player competitive mode
4. **AI Player**: Computer player using board evaluation

### Programming Challenges
1. **Memory Optimization**: Reduce memory usage with bit packing
2. **Performance**: Optimize line clearing for large grids
3. **Modern Tetris**: Implement official Tetris guidelines
4. ** 3D Tetris**: Extend to three-dimensional gameplay

---

## Code Quality Analysis

### Strengths
1. **Compact Design**: Full Tetris in ~200 lines of code
2. **Efficient Algorithms**: Smart lookup tables and bit operations
3. **Clean Separation**: Logic, rendering, and input clearly separated
4. **Robust Collision**: Comprehensive boundary and piece checking

### Areas for Enhancement
1. **Magic Numbers**: Hard-coded values could be constants (The VM has constnt folding!!)
2. **Error Handling**: No bounds checking on some array accesses (NO WAY!)
3. **Game Over**: Missing end-game detection and handling
4. **Modern Features**: Missing hold piece, ghost piece, etc.

### R3forth Techniques Demonstrated
1. **Lookup Tables**: Efficient mapping with array indexing
2. **Coordinate Packing**: Multiple coordinate systems with conversions
3. **Memory Management**: Direct grid manipulation with bulk operations
4. **State Machines**: Clean piece state transitions

---

## Key Programming Insights

### Game Architecture Patterns
1. **Data-Driven Design**: Pieces defined by template data
2. **Coordinate Abstraction**: Multiple coordinate systems working together
3. **State Management**: Clean separation of game state variables
4. **Event Processing**: Input, timing, and collision as separate concerns

### Algorithm Design Principles
1. **Lookup Table Optimization**: Pre-computed rotations and coordinate maps
2. **Early Exit Patterns**: Collision detection with immediate returns
3. **Bulk Operations**: Efficient line clearing with memory moves
4. **Template Systems**: Reusable piece definitions with transformations

### R3forth Best Practices
1. **Stack Discipline**: Consistent stack management throughout
2. **Memory Efficiency**: Direct addressing and packed coordinates
3. **Performance Awareness**: Bit operations and register usage
4. **Code Organization**: Logical grouping of related functions

This Tetris implementation showcases sophisticated game programming techniques in a compact, efficient package. The coordinate transformation system, lookup table optimizations, and clean state management demonstrate professional-level R3forth programming. Study these patterns to master complex game development and advanced programming concepts.

---

**Original Code**: PHREDA 2020  
**Repository**: https://github.com/phreda4/r3  
**Tutorial**: Educational analysis for learning R3forth programming