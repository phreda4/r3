# Programming Flood It! in R3forth - Real Code Analysis

**Learning Game Development from Actual Working Code**

This tutorial analyzes the complete floodit.r3 implementation by PHREDA, teaching R3forth programming through real, tested code.

---

## Table of Contents

1. [Game Overview](#game-overview)
2. [Project Structure](#project-structure)
3. [Data Structures](#data-structures)
4. [Map Generation](#map-generation)
5. [Graphics and Colors](#graphics-and-colors)
6. [Flood Fill Algorithm](#flood-fill-algorithm)
7. [Game Logic](#game-logic)
8. [User Interface](#user-interface)
9. [Complete Code Analysis](#complete-code-analysis)
10. [Learning Exercises](#learning-exercises)

---

## Game Overview

**Flood It! Rules:**
- Grid filled with colored squares
- Click a color to flood-fill from top-left corner
- Goal: Make entire grid the same color
- Win in minimum number of moves

**Why This Game Teaches Important Concepts:**
- **Flood Fill Algorithm**: Classic computer graphics technique
- **Color Management**: Working with RGB values and arrays
- **Iterative vs Recursive**: Queue-based flood fill implementation
- **Game State**: Turn counting and win conditions
- **Dynamic UI**: Color buttons generated from data

---

## Project Structure

### Library Dependencies

```forth
| floodit ! 
| PHREDA 2023
^r3/lib/sdl2gfx.r3
^r3/util/sdlgui.r3
^r3/lib/rand.r3
```

**Libraries Used:**
- `sdl2gfx.r3` - Graphics primitives and color management
- `sdlgui.r3` - Immediate mode GUI system
- `rand.r3` - Random number generation for map creation

### Global Variables

```forth
#map * $ffff
#w 8 #h 8 
#turn 0
#state * 32
```

**Data Analysis:**
- `#map * $ffff` - Game grid (65535 bytes for large grids)
- `#w #h` - Board dimensions (default 8x8)
- `#turn` - Move counter for scoring
- `#state * 32` - String buffer for status messages (32 bytes)

**Programming Concepts:**
- **Scalable Memory**: Large allocation supports different grid sizes
- **Global State**: Shared variables across all functions
- **String Buffers**: Fixed-size memory for text operations

---

## Data Structures

### Board Access Function

```forth
:]map | x y -- adr
	w * + 'map + ;
```

**Code Analysis:**
- **2D to 1D Mapping**: `y * width + x` formula
- **Variable Width**: Uses `w` for dynamic board sizes
- **Direct Memory**: Returns actual memory address for efficiency

**Why This Pattern:**
- Supports different board sizes (8x8, 20x20, 30x30)
- Direct memory access faster than function calls
- Simple arithmetic for coordinate conversion

### Map Generation

```forth
:makemap | --
	'map w h * ( 1? 1 - 
		6 randmax rot c!+
		swap ) 2drop ;
```

**Code Analysis:**
1. `'map` - Start at map memory address
2. `w h *` - Calculate total cells (width × height)  
3. `( 1? 1 -` - Countdown loop for each cell
4. `6 randmax` - Generate color 0-5 (6 colors total)
5. `rot c!+` - Store color and increment address pointer
6. `swap` - Prepare for next iteration

**Programming Concepts:**
- **Memory Iteration**: Using address increment `c!+`
- **Random Generation**: `6 randmax` gives 0-5 range
- **Efficient Loops**: Countdown pattern `( 1? 1 -`
- **Stack Management**: `rot`, `swap` for data manipulation

---

## Graphics and Colors

### Color Array

```forth
#colors $ff0000 $ff00 $ff $ffff00 $ffff $ff00ff
```

**Color Analysis:**
- `$ff0000` - Red
- `$ff00` - Green  
- `$ff` - Blue
- `$ffff00` - Yellow (Red + Green)
- `$ffff` - Cyan (Green + Blue)
- `$ff00ff` - Magenta (Red + Blue)

**Programming Concepts:**
- **Color Representation**: RGB values in hexadecimal
- **Color Theory**: Primary and secondary colors for visual distinction
- **Array Access**: Colors accessed by index calculation

### Coordinate Transformation

```forth
:xymap | x y -- x y xs ys
	over 4 << 8 + over 4 << 8 + ;
```

**Code Analysis:**
- `over` - Copy x coordinate from stack
- `4 <<` - Multiply by 16 (bit shift for cell size)
- `8 +` - Add 8 pixels for centering (16/2 = 8)
- Result: Board coordinates → Screen pixel coordinates

**Mathematical Relationship:**
- Board cell (x,y) → Screen pixel (x*16+8, y*16+8)
- Each cell is 16x16 pixels
- +8 offset centers the square within the cell

### Cell Drawing

```forth
:drawc	| x y -- x y
	2dup ]map c@ 3 << 'colors + @ SDLColor
	xymap 16 dup SDLFRect ;
```

**Code Analysis:**
1. `2dup ]map c@` - Get color index from board cell
2. `3 << 'colors +` - Multiply by 8 (color array stride), add to colors base
3. `@ SDLColor` - Load color value and set SDL drawing color
4. `xymap` - Convert coordinates to screen pixels
5. `16 dup SDLFRect` - Draw 16x16 filled rectangle

**Programming Concepts:**
- **Array Indexing**: `index * 8 + base_address` for 64-bit values
- **Bit Shifting**: `3 <<` equivalent to `* 8` but faster
- **Graphics Pipeline**: Set color, then draw shape

### Complete Board Drawing

```forth
:drawmap
	0 ( w <? 0 ( h <? drawc 1 + ) drop 1 + ) drop ;
```

**Code Analysis:**
- **Nested Loops**: x from 0 to w-1, y from 0 to h-1
- **Range Testing**: `w <?` means "less than w"
- **Increment Pattern**: `1 +` advances to next coordinate
- **Stack Cleanup**: `drop` removes loop counters

---

## Flood Fill Algorithm

### Win Condition Check

```forth
:mapwin? | -- 0/1
	'map c@+ swap 
	w h * 1 - over + swap 
	( over <? 
		c@+ pick3 <>? ( 4drop 0 ; ) drop
		) 3drop 1 ; 
```

**Algorithm Analysis:**
1. `'map c@+ swap` - Read first cell color, get next address
2. `w h * 1 -` - Calculate number of remaining cells
3. `( over <?` - Loop through all remaining cells
4. `c@+ pick3 <>?` - Compare each cell with first cell color
5. `( 4drop 0 ; )` - If different, return false (not won)
6. `3drop 1` - If all same, return true (won)

**Programming Concepts:**
- **Early Exit**: Return false immediately on first difference
- **Memory Traversal**: Using `c@+` to walk through array
- **Comparison Logic**: All cells must match first cell
- **Stack Management**: Complex stack operations for efficiency

### Flood Fill Variables

```forth
#colnow
#colold
#last>
```

**Algorithm State:**
- `colnow` - New color being flood-filled
- `colold` - Original color being replaced  
- `last>` - Queue pointer for iterative flood fill

### Cell Addition Logic

```forth
:addcell | x y -- 
	swap 0 <? ( 2drop ; ) w >=? ( 2drop ; ) 
	swap 0 <? ( 2drop ; ) h >=? ( 2drop ; )
	2dup ]map c@ colold <>? ( 3drop ; ) drop
	2dup last> c!+ c!+ 'last> !
	]map colnow swap c! ;
```

**Code Analysis:**
1. **Bounds Checking**: `0 <?` and `w >=?` ensure coordinates are valid
2. **Color Matching**: Only process cells with `colold` color
3. **Queue Addition**: `last> c!+ c!+` adds x,y to processing queue
4. **Color Update**: `]map colnow swap c!` changes cell to new color

**Programming Concepts:**
- **Bounds Validation**: Four separate checks for x,y limits
- **Queue Management**: Dynamic list of cells to process
- **Conditional Processing**: Skip cells that don't match criteria

### Neighbor Processing

```forth
:markcell | x y --
	over 1 - over addcell
	over 1 + over addcell
	over over 1 - addcell
	1 + addcell ;
```

**Code Analysis:**
- Adds four neighbors: left, right, up, down
- `over 1 -` creates (x-1, y) coordinate
- `over 1 +` creates (x+1, y) coordinate  
- `over over 1 -` creates (x, y-1) coordinate
- `1 +` modifies stack to create (x, y+1) coordinate

**Algorithm Pattern:**
- Traditional 4-connected flood fill (not 8-connected)
- Stack manipulation avoids temporary variables
- Each neighbor gets bounds-checked by `addcell`

### Main Flood Fill Function

```forth
:fillcol | x y --
	2dup ]map c@ colnow =? ( 3drop ; )
	'colold !
	here 'last> !
	addcell
	here ( last> <? 
		c@+ swap c@+ rot markcell
		) drop ;
```

**Algorithm Walkthrough:**
1. **Early Exit**: If starting cell already target color, quit
2. **Initialize**: Save original color, set queue pointer
3. **Seed Queue**: Add starting cell to processing queue
4. **Process Queue**: While queue not empty:
   - Read x,y coordinates from queue
   - Process neighbors with `markcell`

**Programming Concepts:**
- **Queue-Based Algorithm**: Avoids recursion stack overflow
- **Dynamic Memory**: Uses `here` for temporary queue storage
- **Iterative Processing**: Loop continues until queue empty

---

## Game Logic

### Difficulty Levels

```forth
:reset	'h ! 'w ! makemap  0 'turn ! "" 'state strcpy ;
:reset1 10 10 reset ;
:reset2 20 20 reset ;
:reset3 30 30 reset ;
```

**Code Analysis:**
- `'h ! 'w !` - Store height and width from stack
- `makemap` - Generate new random grid
- `0 'turn !` - Reset move counter
- `"" 'state strcpy` - Clear status message

**Game Balance:**
- **Beginner**: 10×10 = 100 cells
- **Intermediate**: 20×20 = 400 cells  
- **Advanced**: 30×30 = 900 cells

### Main Game Action

```forth
:floodit | color --
	'colnow ! 
	0 0 fillcol 
	1 'turn +!
	mapwin? 1? ( "Win !" 'state strcpy ) 
	drop ;
```

**Game Flow:**
1. Store selected color in `colnow`
2. Start flood fill from top-left corner (0,0)
3. Increment turn counter
4. Check win condition and update status

**Programming Concepts:**
- **State Updates**: Multiple global variables modified
- **Action Sequence**: Logical order of operations
- **Conditional Actions**: Win message only if game won

---

## User Interface

### Dynamic Color Buttons

```forth
'colors 0 ( 6 <? 
	swap @+ 'immcolorbtn !
	swap [ dup floodit ; ] "" immbtn imm>>
	1 + ) 2drop
```

**Code Analysis:**
1. `'colors 0` - Start at color array, index 0
2. `( 6 <?` - Loop for 6 colors
3. `swap @+` - Get next color value, advance pointer
4. `'immcolorbtn !` - Set button color
5. `[ dup floodit ; ]` - Create button callback function
6. `"" immbtn imm>>` - Create button with callback, move to next position

**Programming Concepts:**
- **Dynamic UI**: Buttons generated from data array
- **Callback Functions**: `[ code ]` creates executable code
- **Array Traversal**: Walking through color array with `@+`
- **GUI Layout**: `imm>>` positions next element

### Status Display

```forth
'state immlabelc			immdn
turn "turn:%d" immlabelc immdn
```

**Code Analysis:**
- `'state immlabelc` - Display status message (win/lose)
- `turn "turn:%d" immlabelc` - Format and display turn counter
- `immdn` - Move to next line in GUI layout

**String Formatting:**
- `"turn:%d"` - Format string with %d placeholder
- `immlabelc` - Centered label display
- Automatic number-to-string conversion

---

## Complete Program Flow

### Main Loop

```forth
:game
	0 SDLcls
	immgui 	
	drawmap

	32 32 immbox
	16 500 immat
	'colors 0 ( 6 <? 
		swap @+ 'immcolorbtn !
		swap [ dup floodit ; ] "" immbtn imm>>
		1 + ) 2drop
		
	$ff 'immcolorbtn !
	200 28 immbox
	500 16 immat
	"Floodit !" immlabelc		immdn
	'reset1 "Beginner" immbtn 	immdn
	'reset2 "Intermediate" immbtn 	immdn
	'reset3 "Advance" immbtn 		immdn 
	'state immlabelc			immdn
	turn "turn:%d" immlabelc immdn
	'exit "Exit" immbtn 
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	drop ;
```

**Game Loop Analysis:**
1. **Clear Screen**: `0 SDLcls` - Black background
2. **Initialize GUI**: `immgui` - Start immediate mode GUI
3. **Draw Game**: `drawmap` - Render colored grid
4. **Color Buttons**: Dynamic button generation from color array
5. **Menu Buttons**: Difficulty and exit options
6. **Status Display**: Game state and move counter
7. **Update Display**: `SDLredraw` - Present frame to screen
8. **Input Handling**: `SDLkey` - Check for escape key

### Program Initialization

```forth
:	
	msec time rerand
	"Floodit!" 800 600 SDLinit
	"media/ttf/ProggyClean.ttf" 24 TTF_OpenFont immSDL
	reset1
	'game SDLshow
	SDLquit 
	;
```

**Startup Sequence:**
1. **Random Seed**: `msec time rerand` - Initialize random generator
2. **Create Window**: 800×600 pixel window with title
3. **Load Font**: TrueType font for GUI text
4. **Start Game**: Begin with beginner difficulty
5. **Main Loop**: Run game loop until exit
6. **Cleanup**: Close SDL resources

---

## Key R3forth Patterns

### Memory Management Patterns

```forth
| Dynamic allocation:
here 'last> !              | Use free memory for queue

| Array access:
'colors + @               | Base + offset access
3 << 'colors + @          | Index * size + base

| String operations:
"" 'state strcpy          | Copy empty string
"turn:%d" immlabelc       | Format string with number
```

### Loop and Control Patterns

```forth
| Countdown loop:
w h * ( 1? 1 - actions ) drop

| Range loop:
0 ( w <? actions 1 + ) drop

| Array traversal:
'array ( end <? c@+ process ) drop

| Conditional execution:
condition? ( true-action ; )
condition? ( true-action ) else-action
```

### Stack Management Patterns

```forth
| Coordinate manipulation:
2dup                      | Duplicate x,y pair
over 1 - over            | Create (x-1, y) from (x, y)
rot c!+                   | Rotate and store with increment

| Cleanup patterns:
2drop                     | Remove 2 items
3drop                     | Remove 3 items  
4drop 0 ;                 | Clean up and return 0
```

---

## Algorithm Analysis

### Flood Fill Complexity

**Time Complexity**: O(n) where n is number of cells
- Each cell processed at most once
- Queue operations are O(1)
- Total work proportional to grid size

**Space Complexity**: O(n) worst case
- Queue can contain up to all cells
- Memory allocated dynamically from `here`
- More memory efficient than recursive approach

### Comparison: Iterative vs Recursive

**Iterative (Used in Code):**
- ✅ No stack overflow for large grids
- ✅ Controlled memory usage
- ✅ Can be paused/resumed
- ❌ More complex implementation

**Recursive (Alternative):**
- ✅ Simpler code
- ✅ Natural algorithm expression
- ❌ Stack overflow on large areas
- ❌ Limited by system stack size

---

## Learning Exercises

### Beginner Level
1. **Color Modification**: Change the 6 colors to different RGB values
2. **Grid Size**: Experiment with different initial dimensions
3. **Visual Effects**: Add border lines between cells
4. **Score Display**: Show optimal move count vs actual moves

### Intermediate Level
1. **Animation**: Animate the flood fill spreading
2. **Sound Effects**: Add audio feedback for moves and win
3. **Save/Load**: Implement game state persistence
4. **Undo Function**: Allow taking back the last move

### Advanced Level
1. **Solver Algorithm**: Implement optimal move calculator  
2. **AI Player**: Create computer player using greedy or optimal strategy
3. **Network Play**: Multi-player shared grid
4. **Custom Shapes**: Non-rectangular grid patterns

### Algorithm Challenges
1. **Memory Optimization**: Reduce memory usage with bit packing
2. **Performance**: Profile and optimize flood fill for huge grids
3. **Alternative Algorithms**: Implement recursive version with stack protection
4. **Path Visualization**: Show optimal solution path

---

## Key Programming Insights

### Design Patterns Demonstrated
1. **Immediate Mode GUI**: UI drawn fresh each frame
2. **Queue-Based Processing**: Avoiding recursion with iterative approach
3. **Data-Driven UI**: Buttons generated from color array
4. **Separation of Concerns**: Graphics, logic, and UI cleanly separated

### R3forth Advantages Shown
1. **Memory Control**: Direct allocation with `here` and `* $ffff`
2. **Performance**: Bit operations, direct memory access
3. **Simplicity**: Complex algorithms in compact code
4. **Integration**: Seamless library usage for graphics and GUI

### Game Design Lessons
1. **Progressive Difficulty**: Multiple grid sizes for different skill levels
2. **Immediate Feedback**: Visual and textual response to actions  
3. **Clear Goals**: Simple rules with obvious win condition
4. **Replayability**: Random generation creates new challenges

### Code Quality Factors
1. **Modularity**: Each function has single responsibility
2. **Efficiency**: Algorithms chosen for performance characteristics
3. **Robustness**: Bounds checking prevents crashes
4. **Maintainability**: Clear naming and logical organization

This flood fill implementation demonstrates sophisticated algorithm design in a compact, efficient package. The queue-based approach avoids recursion pitfalls while maintaining algorithmic clarity. Study these patterns to master both R3forth programming and computer graphics fundamentals.

---

**Original Code**: PHREDA 2023  
**Repository**: https://github.com/phreda4/r3  
**Tutorial**: Educational analysis for learning R3forth programming