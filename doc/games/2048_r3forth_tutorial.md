# Programming 2048 in R3forth - Real Code Analysis

**Learning Game Development from Actual Working Code**

This tutorial analyzes the complete 2048.r3 implementation by PHREDA, teaching R3forth programming through real, tested code.

---

## Table of Contents

1. [Game Overview](#game-overview)
2. [Project Structure](#project-structure)
3. [Data Structures](#data-structures)
4. [Graphics System](#graphics-system)
5. [Game Logic](#game-logic)
6. [Movement Algorithm](#movement-algorithm)
7. [Tile Generation](#tile-generation)
8. [Win/Lose Detection](#winlose-detection)
9. [Complete Code Analysis](#complete-code-analysis)
10. [Learning Exercises](#learning-exercises)

---

## Game Overview

**2048 Rules:**
- 4×4 grid starts with two tiles (value 2)
- Arrow keys slide all tiles in chosen direction
- Adjacent tiles with same value merge into one tile (sum of both)
- New tile (value 2) appears after each move
- Goal: Create a tile with value 2048
- Lose when no moves possible (grid full, no merges available)

**Programming Concepts This Game Teaches:**
- **Array Processing**: Efficient manipulation of 2D grid data
- **Mathematical Algorithms**: Tile merging and sliding logic
- **State Management**: Game state tracking and validation
- **Visual Scaling**: Proportional graphics and text positioning
- **Score Calculation**: Mathematical progression (powers of 2)

---

## Project Structure

### Library Dependencies

```forth
| 2048 game
| PHREDA 2024
^r3/lib/sdl2gfx.r3
^r3/util/sdlgui.r3
^r3/lib/rand.r3
```

**Libraries Used:**
- `sdl2gfx.r3` - Graphics primitives and color management
- `sdlgui.r3` - UI elements (score display, buttons)
- `rand.r3` - Random placement of new tiles

### Global Game State

```forth
#colors $afa192 $eee4da $ede0c8 $f2b179 $ffcea4 $e8c064 $ffab6e $fd9982 $ead79c $76daff $beeaa5 $d7d4f0
#map * 16 | 4 * 4 
#score
#moves
#state * 32
```

**Data Analysis:**
- `#colors` - 12 colors for different tile values (empty, 2, 4, 8, 16, ..., 2048)
- `#map * 16` - 4×4 grid (16 bytes total)
- `#score` - Current game score
- `#moves` - Number of moves made
- `#state * 32` - Status message buffer ("Win!", "Lose!", etc.)

---

## Data Structures

### Grid Layout

The grid is stored as a linear array where each byte represents a tile:
- Value 0: Empty tile
- Value 1: Tile with value 2 (2^1)
- Value 2: Tile with value 4 (2^2)
- Value 3: Tile with value 8 (2^3)
- ...
- Value 11: Tile with value 2048 (2^11)

**Memory Layout:**
```
Position:  0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15
Grid:     [0][1][2][3]
          [4][5][6][7]
          [8][9][A][B]
          [C][D][E][F]
```

### Color Mapping

```forth
#colors $afa192 $eee4da $ede0c8 $f2b179 $ffcea4 $e8c064 $ffab6e $fd9982 $ead79c $76daff $beeaa5 $d7d4f0
```

**Color Analysis:**
- Index 0: Gray ($afa192) - Empty tile
- Index 1: Light beige ($eee4da) - Value 2
- Index 2: Beige ($ede0c8) - Value 4
- Index 3-11: Progressive warm to cool colors for higher values

---

## Graphics System

### Coordinate Transformation

```forth
:postile | x y -- x y xs ys
	over 6 << 500 4 6 << - 2/ 1+ +
	over 6 << 600 4 6 << - 2/ 1+ +
	;
```

**Mathematical Analysis:**
- `6 <<` = multiply by 64 (tile size in pixels)
- `500 4 6 << - 2/ 1+` = `(500 - 4*64) / 2 + 1` = horizontal centering
- `600 4 6 << - 2/ 1+` = `(600 - 4*64) / 2 + 1` = vertical centering
- Result: Grid centered on 500×600 screen with 64×64 pixel tiles

### Tile Rendering

```forth
:tile | x y -- x y 
	ca@+ dup 3 << 'colors + @ sdlColor
	-rot
	postile 62 dup SDLFrect
	rot 0? ( drop ; ) 
	-rot
	$000000 ttcolor
	postile	8 + swap 8 + swap ttat
	rot 1 swap << "%d" ttprint
	;
```

**Rendering Pipeline:**
1. `ca@+` - Read tile value and advance register A
2. `3 << 'colors + @` - Get color (value * 8 + colors_base)
3. `SDLFrect` - Draw filled rectangle (62×62 pixels)
4. Early exit if tile empty (`0? ( drop ; )`)
5. Position text at center (`8 + swap 8 +`)
6. `1 swap <<` - Calculate display value (2^n)
7. `ttprint` - Draw formatted number

### Complete Grid Drawing

```forth
:drawmap
	'map >a
	0 ( 4 <?
		0 ( 4 <?
			tile
			1+ ) drop
		1+ ) drop ;
```

**Grid Traversal:**
- Load map address into register A
- Nested loops: y from 0 to 3, x from 0 to 3
- `tile` function reads from register A and auto-advances

---

## Game Logic

### New Tile Generation

```forth
:newn
	state 1? ( drop ; ) drop
	1 'moves +!
	( 16 randmax 'map + dup c@ 1? 2drop ) drop | search a random place
	1 swap c! 
	'map ( 'score <?
		c@+ 0? ( 2drop ; ) drop		| any empty place?
		) drop 
	"Lose !" 'state strcpy 
	;
```

**Algorithm Breakdown:**
1. `state 1?` - Skip if game already won/lost
2. `1 'moves +!` - Increment move counter
3. **Find empty spot**: Loop until `16 randmax` finds empty tile
4. `1 swap c!` - Place tile with value 1 (represents 2^1 = 2)
5. **Check game over**: Scan map for any empty tiles
6. If no empty tiles found, set "Lose!" message

### Win/Lose Detection

```forth
:win
	"Win !" 'state strcpy ;
```

Win condition is checked during tile merging - when value 11 (2^11 = 2048) is created.

---

## Movement Algorithm

### Core Movement Logic

The movement system uses a sophisticated falling/merging algorithm:

```forth
#l0 0 #l1 0 #l2 0 0

:add | adr c1 --
	1+ 1 over << 'score +! 	
	11 =? ( win )
	0 				| ....
:down | adr c1 c2 --
	pick2 @ c! swap 8 + @ c! ;
	
:ck | adr -- 
	dup @ 
	c@ 0? ( 2drop ; )		| adr c1
	over 8 + @ 
	c@ 0? ( down ; ) 		| adr c1 c2
	=? ( add ; ) 
	2drop ;

:fall | delta ini --
	'l0 >a
	4 ( 1? swap 
		dup 'map + a!+
		pick2 + swap 1- ) 3drop 
	'l2 ck
	'l1 ck 'l2 ck
	'l0 ck 'l1 ck 'l2 ck
	;
```

**Data Structures:**
- `#l0 #l1 #l2` - Array of 4 addresses pointing to tiles in movement line

**Algorithm Steps:**

1. **Setup line** (`fall` function):
   - Create array of addresses for tiles in movement direction
   - `delta` = address increment between tiles
   - `ini` = starting position

2. **Process merges** (`ck` function):
   - Check each adjacent pair of tiles
   - If both tiles have same value, merge them (`add`)
   - If second tile empty, move first tile down (`down`)

3. **Scoring** (`add` function):
   - Increment tile value
   - Add 2^value to score
   - Check for win condition (value 11 = 2048)

### Directional Movement

```forth
:le	
	12 ( 16 <? 
		-4 over fall
		1+ ) drop 	
	newn ;
:ri
	0 ( 4 <? 
		4 over fall
		1+ ) drop 	
	newn ;
:dn	
	0 ( 16 <?
		1 over fall
		4 + ) drop
	newn ;
:up	
	3 ( 16 <?
		-1 over fall
		4 + ) drop
	newn ;
```

**Movement Patterns:**

**Left Movement (`le`):**
- Process positions 12,13,14,15 (rightmost column)
- `delta = -4` (move left by one column)
- Each row processed independently

**Right Movement (`ri`):**
- Process positions 0,1,2,3 (leftmost column)  
- `delta = 4` (move right by one column)

**Down Movement (`dn`):**
- Process positions 0,4,8,12 (top row)
- `delta = 1` (move down by one position)
- Each column processed independently

**Up Movement (`up`):**
- Process positions 3,7,11,15 (bottom row)
- `delta = -1` (move up by one position)

---

## Score Calculation

### Mathematical Progression

```forth
1+ 1 over << 'score +!
```

**Score Formula:**
- When tiles merge, add 2^(new_value) to score
- Example: Merging two 4-tiles (value 2) creates 8-tile (value 3)
- Score increase: 2^3 = 8 points
- This matches original 2048 scoring system

---

## User Interface

### Game Loop

```forth
:play
	immgui 	
	0 SDLcls
	drawmap

	$ff 'immcolorbtn !
	200 28 immbox
	500 16 immat
	"* 2048 *" immlabelc immdn immdn
	
	moves "Moves:%d" immlabelc immdn
	score "Score:%d" immlabelc immdn 
	immdn
	'state immlabelc immdn 
	immdn
	'reset "New Game" immbtn immdn 
	'exit "Exit" immbtn 	
	
	sdlredraw
	sdlkey 
	>esc< =? ( exit )
	<up> =? ( up )
	<dn> =? ( dn )
	<le> =? ( le )
	<ri> =? ( ri )
	drop
	;
```

**UI Elements:**
- Game title centered
- Move counter and score display
- Status messages (Win/Lose)
- New Game and Exit buttons
- Arrow key input handling

### Game Reset

```forth
:reset
	'map 0 16 cfill 
	0 'state ! newn newn 
	0 'score ! 0 'moves ! 
	;
```

**Reset Process:**
1. Clear entire map (16 bytes to zero)
2. Clear status message
3. Add two initial tiles with `newn newn`
4. Reset score and move counters

---

## Complete Program Flow

### Initialization

```forth
:
	"2048" 800 600 SDLinit
	"media/ttf/Roboto-Medium.ttf" 24 ttf_OpenFont ttfont!
	reset
	'play sdlshow
	SDLquit 
	;
```

**Startup Sequence:**
1. Create 800×600 window with title "2048"
2. Load TrueType font for text rendering
3. Initialize game state with `reset`
4. Run main game loop
5. Clean up on exit

---

## Key R3forth Patterns

### Array Processing

```forth
| Linear array traversal:
'map >a               | Load array base into register A
( condition ca@+ process )  | Read and advance automatically

| 2D grid access:
x y + 4 * 'map +      | Convert (x,y) to memory address

| Bulk operations:
'map 0 16 cfill       | Fill 16 bytes with zero
```

### Mathematical Operations

```forth
| Powers of 2:
1 value <<            | Calculate 2^value
value 3 <<            | Multiply by 8 (for color array indexing)

| Centering calculations:
screen_size grid_size tile_size * - 2/ 1+  | Center grid on screen
```

### State Management

```forth
| Conditional execution:
state 1? ( drop ; ) drop    | Skip if game ended

| Status tracking:
'state strcpy              | Set status message
0 'moves !                 | Reset counters
```

---

## Algorithm Analysis

### Time Complexity
- **Movement**: O(1) - Fixed 4×4 grid, constant operations
- **Tile Generation**: O(n) worst case where n = empty tiles (max 16)
- **Rendering**: O(1) - Always draw 16 tiles
- **Win/Lose Check**: O(1) - Checked during other operations

### Space Complexity
- **Grid Storage**: O(1) - Fixed 16 bytes
- **Color Array**: O(1) - Fixed 12 colors
- **Temporary Variables**: O(1) - Small set of working variables
- **Total**: O(1) - Constant memory usage

### Performance Characteristics
- **Memory Efficient**: Only 16 bytes for game state
- **Fast Operations**: Direct memory access, bit operations
- **Scalable Graphics**: Mathematical positioning adapts to screen size
- **Responsive**: Immediate feedback for all moves

---

## Learning Exercises

### Beginner Level
1. **Visual Improvements**: Different color schemes, tile animations
2. **Sound Effects**: Tile movement and merge sounds
3. **High Score**: Track and display best score
4. **Theme Variants**: Different tile designs and backgrounds

### Intermediate Level
1. **Undo Feature**: Allow taking back moves
2. **Hint System**: Show best move suggestions
3. **Different Grid Sizes**: 3×3, 5×5, or 6×6 variants
4. **Custom Goals**: Reach 4096 or higher values

### Advanced Level
1. **AI Player**: Implement expectimax or Monte Carlo tree search
2. **Network Play**: Online leaderboards and competitions
3. **Mobile Version**: Touch controls and gesture recognition
4. **3D Version**: Cube-based 3D puzzle variant

### Programming Challenges
1. **Memory Optimization**: Pack multiple tiles into single bytes
2. **Algorithm Improvement**: Optimize movement and merge logic
3. **Performance Analysis**: Profile and optimize rendering
4. **Alternative Algorithms**: Different approaches to tile sliding

---

## Code Quality Analysis

### Strengths
1. **Elegant Simplicity**: Complex game logic in ~100 lines
2. **Mathematical Precision**: Correct 2048 mechanics and scoring
3. **Efficient Rendering**: Smart coordinate calculations and caching
4. **Clean Architecture**: Separated concerns for logic, graphics, UI

### Areas for Enhancement
1. **Magic Numbers**: Hard-coded values could be named constants
2. **Error Handling**: No bounds checking or input validation
3. **Code Comments**: Complex algorithms need better documentation
4. **Modularity**: Some functions handle multiple responsibilities

### R3forth Techniques Demonstrated
1. **Register Usage**: Efficient array traversal with register A
2. **Bit Operations**: Powers of 2 calculations with bit shifting
3. **Memory Management**: Direct memory access and bulk operations
4. **Mathematical Programming**: Coordinate transformations and centering

---

## Key Programming Insights

### Game Design Principles
1. **Simple Rules, Complex Emergent Behavior**: Four directions create infinite strategy
2. **Progressive Difficulty**: Game naturally gets harder as board fills
3. **Clear Feedback**: Visual and numerical feedback for every action
4. **Elegant Mathematics**: Powers of 2 create satisfying progression

### Algorithm Design Patterns
1. **Separation of Concerns**: Movement logic separate from graphics
2. **State Validation**: Check game state after each operation
3. **Efficient Processing**: Process lines independently for parallelization potential
4. **Mathematical Optimization**: Use bit operations for power calculations

### R3forth Programming Philosophy
1. **Direct Memory Access**: No abstraction layers between code and data
2. **Mathematical Thinking**: Coordinate transformations as first-class operations
3. **Efficient Resource Usage**: Minimal memory footprint with maximum functionality
4. **Code Density**: Express complex algorithms in compact, readable form

This 2048 implementation demonstrates how mathematical precision and algorithmic elegance can create engaging games with minimal code. The movement algorithm, in particular, showcases sophisticated array processing techniques that apply to many grid-based games and puzzles.

---

**Original Code**: PHREDA 2024  
**Repository**: https://github.com/phreda4/r3  
**Tutorial**: Educational analysis for learning R3forth programming