# Programming Minesweeper in R3forth - Real Code Analysis

**Learning Game Development from Actual Working Code**

This tutorial analyzes the complete minesweeper.r3 implementation by PHREDA, teaching R3forth programming through real, tested code.

---

## Table of Contents

1. [Code Overview](#code-overview)
2. [Project Structure](#project-structure)
3. [Data Structures](#data-structures)
4. [Map Generation](#map-generation)
5. [Graphics System](#graphics-system)
6. [Game Logic](#game-logic)
7. [User Interface](#user-interface)
8. [Complete Code Analysis](#complete-code-analysis)
9. [Learning Exercises](#learning-exercises)

---

## Code Overview

Let's examine the actual minesweeper code structure:

```forth
| BUscaminas
| PHREDA 2023
^r3/lib/sdl2gfx.r3
^r3/util/sdlgui.r3
^r3/lib/rand.r3
```

**Key Libraries Used:**
- `sdl2gfx.r3` - Graphics and window management
- `sdlgui.r3` - GUI elements (buttons, labels)  
- `rand.r3` - Random number generation

**Programming Concepts:**
- **Library Dependencies**: Real projects require multiple libraries
- **Comments**: `|` prefix for documentation in R3forth
- **Modular Design**: Using existing libraries rather than reinventing

---

## Project Structure

### Global Variables

```forth
#sprites
#map * $ffff
#w 8 #h 8 #bombs 2
#sb 0	
#sumw
#state * 32
```

**Data Analysis:**
- `#sprites` - Stores loaded sprite sheet reference
- `#map * $ffff` - Game board (64KB allocation for large grids)
- `#w #h #bombs` - Board dimensions and bomb count (default 8x8, 2 bombs)
- `#sb` - Game state flag (0=playing, 1=game over)
- `#sumw` - Win condition counter
- `#state * 32` - String buffer for status messages

**Programming Concepts:**
- **Memory Allocation**: `* $ffff` reserves 65535 bytes
- **Global State**: Variables shared across all functions
- **Naming Conventions**: Short, descriptive names

---

## Data Structures

### Board Access Function

```forth
:]map | x y -- adr
	8 << + 'map + ;
```

**Code Analysis:**
- **2D to 1D Mapping**: Converts x,y coordinates to memory address
- **Bit Shifting**: `8 <<` multiplies by 256 (fast alternative to `y * 256`)
- **Memory Arithmetic**: `+ 'map +` adds offset to base address
- **Stack Notation**: `| x y -- adr` documents input/output

**Why This Works:**
- Each row is 256 bytes apart in memory
- `8 <<` is equivalent to `* 256` but faster
- Adding x gives the exact cell address

### Cell Values
From analyzing the code, cell values use bit encoding:
- `20` = Empty hidden cell
- `21` = Bomb
- `22` = Flagged cell (`20` XOR `2`)
- `23` = Flagged bomb (`21` XOR `2`)
- Lower bits store mine count for revealed cells

---

## Map Generation

### Random Position Generator

```forth
:mrand | -- adr
	w randmax 1 + h randmax 1 + ]map ;
```

**Code Analysis:**
- `w randmax` generates 0 to w-1, `1 +` makes it 1 to w
- Same for height with `h randmax 1 +`
- `]map` calls the address function to get memory location

**Programming Concept:** Helper functions simplify complex operations

### Map Initialization

```forth
:makemap | --
	'map 20 $ffff cfill | clear all
	bombs ( 1? 1 -
		( mrand dup c@ 20 <>? 2drop ) drop | only empty
		21 swap c!
		) drop ;
```

**Code Analysis:**
1. `'map 20 $ffff cfill` - Fill entire map with value 20 (empty cells)
2. `bombs ( 1? 1 -` - Loop `bombs` times, counting down
3. `( mrand dup c@ 20 <>? 2drop ) drop` - Find empty cell (retry if occupied)
4. `21 swap c!` - Place bomb (value 21) at found location

**Programming Concepts:**
- **Memory Filling**: `cfill` sets bytes to a value
- **Retry Logic**: Inner loop continues until valid position found
- **Conditional Exit**: `<>?` means "not equal"
- **Stack Management**: `dup`, `swap`, `drop` manipulate data

---

## Graphics System

### Coordinate Transformation

```forth
:xymap | x y c -- x y c xs ys
	pick2 4 << 8 + pick2 4 << 8 + ;
```

**Code Analysis:**
- `pick2` gets the third stack item (x, then y)
- `4 <<` multiplies by 16 (pixel size of each cell)
- `8 +` centers the sprite in the 16x16 cell
- Results in screen coordinates `xs ys`

**Programming Concepts:**
- **Coordinate Systems**: Board coordinates vs screen pixels
- **Stack Manipulation**: `pick2` accesses deep stack items
- **Centering**: Adding half cell size for visual alignment

### Drawing Functions

```forth
:drawc	| x y c -- x y
	2dup ]map c@ xymap rot 1 >> sprites ssprite ;
```

**Code Analysis:**
- `2dup` duplicates x,y coordinates
- `]map c@` gets cell value at coordinates  
- `xymap` converts to screen coordinates
- `rot 1 >>` shifts sprite index (divide by 2)
- `sprites ssprite` draws the sprite

**Why Bit Shifting:**
- Cell values 20,21,22,23 become sprite indices 10,10,11,11
- This maps different cell states to appropriate sprite images

### Revealed Cell Drawing

```forth
:drawb	| x y c -- x y
	2dup ]map c@ 
	xymap rot 1 and 0? ( 3drop ; ) 
	8 + sprites ssprite ;
```

**Code Analysis:**
- `1 and` checks lowest bit (revealed state)
- `0? ( 3drop ; )` exits if cell not revealed  
- `8 +` uses different sprite range for revealed cells

**Programming Concepts:**
- **Bit Masking**: `1 and` extracts single bit
- **Early Exit**: `( 3drop ; )` cleans stack and returns
- **Sprite Indexing**: Adding 8 selects different sprite set

---

## Game Logic

### Neighbor Counting

```forth
:checkc | x y -- x y c
	0 >a
	-1 ( 1 <=? 
		-1 ( 1 <=? 
			pick3 pick2 + pick3 pick2 +
			]map c@ $1 and a+
			1 + ) drop
		1 + ) drop 
	a> ;
```

**Code Analysis:**
- `0 >a` initializes register A as counter
- `-1 ( 1 <=?` loops from -1 to 1 (3x3 grid around cell)
- `pick3 pick2 +` calculates neighbor coordinates
- `]map c@ $1 and` checks if neighbor is a bomb
- `a+` adds to register A counter
- `a>` returns final count

**Programming Concepts:**
- **Register Usage**: `>a` and `a>` for efficient counting
- **Nested Loops**: Checking all 8 neighbors
- **Coordinate Math**: Adding offsets to get neighbors
- **Bit Testing**: `$1 and` checks bomb flag

### Cell Revealing (Recursive)

```forth
:clearcell | x y --
	2dup ]map c@ 20 <>? ( 3drop ; ) drop
	checkc 1? ( 
		1 << -rot ]map c!
		; ) 
	pick2 pick2 ]map c!
	over 1 - 1 max over clearcell 
	over 1 + w min over clearcell
	over over 1 - 1 max clearcell
	1 + h min clearcell ;
```

**Code Analysis:**
1. `20 <>? ( 3drop ; )` - Exit if already revealed
2. `checkc 1? ( 1 << -rot ]map c! ; )` - If has neighbors, just reveal with count
3. **Recursive Calls**: If empty (0 neighbors), reveal all adjacent cells
4. `1 max` and `w min` ensure coordinates stay in bounds

**Programming Concepts:**
- **Recursion**: Function calls itself for flood-fill
- **Bounds Checking**: `max` and `min` prevent out-of-bounds
- **Stack Juggling**: `over`, `pick2`, `-rot` manage coordinates

### Non-Recursive Alternative

The code also shows a stack-based alternative to recursion:

```forth
:clearcell | x y --
	here 'last> !
	addcell
	here ( last> <? 
		c@+ swap c@+ rot 
		markcell
		) drop ;
```

**Programming Concepts:**
- **Stack-based Algorithm**: Uses memory buffer instead of recursion
- **Dynamic Memory**: `here` points to free memory  
- **Queue Processing**: Processes cells from a list

---

## User Interface

### Mouse Input Handling

```forth
:click
	SDLx 4 >> -? ( drop ; ) w >? ( drop ; )
	SDLy 4 >> -? ( 2drop ; ) h >? ( 2drop ; )
	clkbtn 1 >? ( drop marca ; ) drop
	checkc 0? ( drop clearcell ; )
	-rot ]map 
	dup c@ $1 and 
	1? ( 1 'sb ! "You Loose !" 'state strcpy ) 
	rot 1 << or 
	swap c!	;
```

**Code Analysis:**
1. `SDLx 4 >>` - Convert pixel to board coordinate (divide by 16)
2. Bounds checking with `-?` (negative) and `>?` (too large)
3. `clkbtn 1 >?` - Right click calls `marca` (flag function)
4. `checkc 0?` - If empty cell, call `clearcell` for flood fill
5. Bomb detection and game over logic

**Programming Concepts:**
- **Input Processing**: Converting screen coordinates to game coordinates
- **Bounds Validation**: Multiple checks prevent crashes
- **Game State Updates**: Setting win/lose conditions
- **String Operations**: `strcpy` for status messages

### Flag Toggle

```forth
:marca | x y --
	]map dup c@ 
	20 <? ( 2drop ; )
	$2 xor swap c!
	checkwin ;
```

**Code Analysis:**
- `20 <? ( 2drop ; )` - Only flag unrevealed cells (≥20)
- `$2 xor` - Toggle flag bit (20↔22, 21↔23)
- `checkwin` - Check if all non-bomb cells revealed

### Win Condition Check

```forth
:checkwin | -- 
	0 'sumw !
	1 ( w <=? 1 ( h <=? win? 1 + ) drop 1 + ) drop 
	sumw bombs <>? ( drop ; ) drop
	1 'sb ! "You WiN !" 'state strcpy ;
```

**Code Analysis:**
- Counts flagged bombs across entire board
- `win?` helper function increments counter for flagged bombs
- Win when flagged bomb count equals total bombs

---

## GUI Integration

### Difficulty Levels

```forth
:reset1
	9 'w ! 9 'h ! 10 'bombs !
	makemap 0 'sb ! "" 'state strcpy ;
:reset2
	16 'w ! 16 'h ! 40 'bombs !
	makemap 0 'sb ! "" 'state strcpy ;
:reset3
	24 'w ! 24 'h ! 99 'bombs !
	makemap 0 'sb ! "" 'state strcpy ;
```

**Programming Concepts:**
- **Configuration Functions**: Different difficulty presets
- **State Reset**: Clearing game state for new game
- **Standard Difficulties**: Classic minesweeper dimensions

### Main Game Loop

```forth
:game
	0 SDLcls
	immgui 0 0 sw sh guibox 
	drawmap
	showbomb?	
	'click onClick 
	200 28 immbox
	500 16 immat
	"Minesweeper" immlabelc		immdn
	'reset1 "Beginner" immbtn 	immdn
	'reset2 "Intermediate" immbtn 	immdn
	'reset3 "Advance" immbtn 		immdn 
	'state immlabelc			immdn
	'exit "Exit" immbtn 
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	drop ;
```

**Code Analysis:**
- `immgui` - Initialize immediate mode GUI system
- `drawmap` - Render game board  
- `'click onClick` - Register click handler
- GUI buttons with callbacks (`'reset1`, `'reset2`, etc.)
- `SDLredraw` - Update display

**Programming Concepts:**
- **Immediate Mode GUI**: UI drawn each frame
- **Event Callbacks**: Functions executed on button press
- **Game Loop Pattern**: Clear, update, draw, repeat

---

## Complete Program Flow

### Initialization

```forth
:	
	msec time rerand
	"Minesweeper" 800 600 SDLinit
	16 16 "media/img/mines.png" ssload 'sprites !
	"media/ttf/ProggyClean.ttf" 24 TTF_OpenFont immSDL
	reset1
	'game SDLshow
	SDLquit ;
```

**Program Flow:**
1. Initialize random seed with `msec time rerand`
2. Create 800x600 window with `SDLinit`
3. Load 16x16 sprite sheet for mine graphics
4. Load font for GUI text
5. Start beginner difficulty with `reset1`
6. Run main game loop with `SDLshow`
7. Clean up with `SDLquit`

---

## Key R3forth Patterns Learned

### Correct Conditional Syntax
```forth
| Correct patterns from real code:
value 20 <>? ( action ; )     | if not equal to 20
count 1? ( action )           | if not zero  
x -? ( drop ; )               | if negative
```

### Loop Patterns
```forth
| Counting loop:
bombs ( 1? 1 - actions ) drop

| Range loop:  
1 ( w <=? actions 1 + ) drop

| Coordinate loops:
-1 ( 1 <=? -1 ( 1 <=? actions 1 + ) drop 1 + ) drop
```

### Memory and Stack Operations
```forth
| Memory access:
]map c@        | get byte from calculated address
'map + c!      | store byte at offset
dup c@ 20 <>?  | duplicate, fetch, compare

| Stack manipulation:
2dup           | duplicate top 2 items
pick2 pick2    | copy 3rd item twice
-rot           | reverse rotate 3 items
3drop          | remove 3 items
```

### Register Usage
```forth
0 >a           | initialize register A
value a+       | add value to register A  
a>             | push register A value
```

---

## Learning Exercises

### Beginner Level
1. **Change Colors**: Modify sprite loading to use different graphics
2. **Debug Display**: Add code to show cell values as numbers
3. **Sound Effects**: Add click sounds using SDL2 mixer
4. **Custom Sizes**: Experiment with different w/h/bomb ratios

### Intermediate Level
1. **Timer**: Add game timer using `msec`
2. **High Scores**: Save best times to file
3. **Animations**: Animate bomb explosions
4. **Better Graphics**: Create custom sprite sheets

### Advanced Level
1. **Solver**: Implement algorithm to solve puzzles
2. **Network Play**: Multi-player shared board
3. **Undo System**: Allow taking back moves
4. **Custom Shapes**: Non-rectangular game boards

### Code Analysis Challenges
1. **Memory Usage**: Calculate exact memory requirements
2. **Performance**: Profile the flood-fill algorithm
3. **Alternative Algorithms**: Implement iterative flood-fill
4. **Error Handling**: Add bounds checking everywhere

---

## Key Insights from Real Code

### What Makes This Code Good:
1. **Compact**: Achieves full game in ~100 lines
2. **Efficient**: Direct memory access, bit manipulation
3. **Readable**: Clear function names and organization
4. **Robust**: Proper bounds checking and state management
5. **Extensible**: Easy to modify difficulty levels

### R3forth Advantages Demonstrated:
1. **Low-Level Control**: Direct memory manipulation
2. **Performance**: Bit operations, register usage
3. **Simplicity**: Minimal syntax, clear data flow
4. **Integration**: Easy library usage
5. **Rapid Development**: Complete game in small code base

### Programming Lessons:
1. **Start Simple**: Basic functionality first
2. **Use Libraries**: Don't reinvent graphics/GUI
3. **Test Incrementally**: Build piece by piece
4. **Handle Edge Cases**: Bounds checking everywhere
5. **Document Code**: Comments explain intent

This real code analysis shows how experienced R3forth programmers write production code - compact, efficient, and well-structured. Study these patterns to improve your own R3forth programming!

---

**Original Code**: PHREDA 2023  
**Repository**: https://github.com/phreda4/r3  
**Tutorial**: Educational analysis for learning R3forth programming