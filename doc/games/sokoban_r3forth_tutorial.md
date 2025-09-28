# Programming Sokoban in R3forth - Real Code Analysis

**Learning Advanced Game Development from Actual Working Code**

This tutorial analyzes the complete sokoban.r3 implementation by PHREDA, teaching advanced R3forth programming through real, tested code.

---

## Table of Contents

1. [Game Overview](#game-overview)
2. [Project Structure](#project-structure)
3. [Data Compression System](#data-compression-system)
4. [Coordinate Systems](#coordinate-systems)
5. [Undo System](#undo-system)
6. [Game Logic](#game-logic)
7. [Level Management](#level-management)
8. [Graphics and Rendering](#graphics-and-rendering)
9. [Complete Code Analysis](#complete-code-analysis)
10. [Learning Exercises](#learning-exercises)

---

## Game Overview

**Sokoban Rules:**
- Push boxes onto goal positions (storage locations)
- Player can only push, not pull boxes
- Only one box can be pushed at a time
- Player cannot push box into wall or another box
- Win by placing all boxes on goal positions
- Minimize moves for perfect score

**Advanced Programming Concepts This Game Teaches:**
- **Data Compression**: Custom bit-stream decompression for level storage
- **Undo Systems**: Reversible action recording and playback
- **Multi-Modal Rendering**: Layered graphics with background and foreground elements
- **Complex State Management**: Multiple game states with validation
- **Level Loading**: Dynamic content loading and parsing

---

## Project Structure

### Library Dependencies

```forth
| sokoban
| PHREDA 2023
| MC 2020
| Sprites from: https://kenney.nl/assets/
| Levels  from: https://github.com/begoon/sokoban-maps

^r3/lib/rand.r3
^r3/lib/sdl2gfx.r3
^r3/util/ttfont.r3
^r3/games/sokoban.levels.r3
```

**Libraries Used:**
- `rand.r3` - Random number generation
- `sdl2gfx.r3` - Graphics and sprite rendering
- `ttfont.r3` - TrueType font rendering for UI
- `sokoban.levels.r3` - Compressed level data (separate file)

### Global Game State

```forth
#sprites		| sprites
#nlevel 0		| map level
#xp 1 #yp 1 	| position
#fp				| face
#strstate * 32
#xmap #ymap
#zmap #zspr

#undo. #undo>	| undo buffer
```

**State Variables Analysis:**
- `#sprites` - Loaded sprite sheet reference
- `#nlevel` - Current level number (0-61)
- `#xp #yp` - Player position on grid
- `#fp` - Player facing direction (0=up, 1=down, 2=right, 3=left)
- `#strstate * 32` - Status message buffer (32 bytes)
- `#xmap #ymap` - Screen offset for centering map
- `#zmap #zspr` - Zoom factor and adjusted sprite size
- `#undo. #undo>` - Undo buffer start and current position

---

## Data Compression System

### Level Data Structure

From `sokoban.levels.r3`:

```forth
#lvlaz ( 8 3 246 5 3 122 1 1 ) 
#lvlbz ( 12 3 246 150 10 132 27 218 64 6 1 )
...
#levels 'lvlaz 'lvlbz 'lvlcz 'lvl1z ...
```

**Compression Analysis:**
- Each level starts with width and height
- Followed by compressed tile data using bit-stream encoding
- Ends with player starting position
- 62 levels total stored in compressed format

### Decompression Algorithm

```forth
:getmapwh | ( adr1 -- adr2 )
	c@+ 'mapw ! c@+ 'maph ! ;

:get1bit | ( -- 0/1 )
	ptr bitn
	dup rot swap getbyte swap
	$7 and 1 + 8 swap - >>     | 8-((i%8)+1)
	1 and
	1 'bitn +! ;

:getcounter | ( -- counter )
	get1bit 0? ( drop 1 ; ) drop
	get3bits
	calccounter ;

:getcharacter | ( -- character )
	get1bit 0? ( drop get1bit 0? ( ; ) drop 1 ; ) drop
	get1bit 0? ( drop 2 ; ) drop
	get1bit 0? ( drop 4 ; ) drop 3 ;
```

**Compression Format:**
- **Run-length encoding** with bit-stream representation
- First bit: 0 = single character, 1 = run of characters
- Character encoding:
  - 0 bits: Ground (empty space)
  - 1 bit + 0: Wall
  - 1 bit + 1: Box or Goal (context dependent)
  - Additional bits for complex tiles

### Decompression Process

```forth
::mapdecomp |  lvl -- adrplayerpos
	3 << 'levels + @
	getmapwh 'ptr ! 0 'bitn !
	'map 'map> !
	mapw maph * 0 ( over <? readpair + ) 2drop
	| bitn is sometimes not at the end of a byte
	bitn $7 and 1? ( bitn dup $7 and 8 swap - + 'bitn ! ) drop
	ptr bitn 3 >> + |getplayerxy
	;
```

**Algorithm Steps:**
1. Get level data address from levels array
2. Extract map width and height
3. Initialize decompression state
4. Decompress tile data using run-length encoding
5. Extract player starting position
6. Return pointer to player position data

---

## Coordinate Systems

### Dynamic Scaling System

```forth
:loadlevel | n --
	mapdecomp 			| level decompress
	c@+ 'xp ! c@ 'yp !	| player pos
	undo. 'undo> !		| reset undo
	"" 'strstate strcpy
	sw 100 - mapw / 
	sh 100 - maph / 
	min  | size
	dup	'zmap !
	10 << $800 + 'zspr ! | adjust for space in sprites
	sw mapw zmap * - 1 >> zmap 1 >> + 'xmap !
	sh maph zmap * - 1 >> zmap 1 >> + 'ymap !
	;
```

**Auto-Scaling Analysis:**
1. **Calculate maximum scale**: `(screen_size - 100) / map_dimension`
2. **Choose minimum scale**: Ensures map fits both width and height
3. **Calculate sprite size**: `zspr = zmap * 1024 + 2048` (fixed point math)
4. **Center map**: Calculate x,y offsets to center map on screen

**Coordinate Transformations:**

```forth
:]map | x y -- adr
	mapw * + 'map + ;

:xymap | x y -- x y 
	swap zmap * xmap + 
	swap zmap * ymap + ;
```

- `]map` - Convert grid coordinates to memory address
- `xymap` - Convert grid coordinates to screen pixels

---

## Undo System

### Undo Data Structure

```forth
#pmove ( 0 -1 ) ( 0 1 ) ( 1 0 ) ( -1 0 ) 

:face2move | face -- x y 
	1 << 'pmove + c@+ swap c@ ;

:>>stream | floor tipo --
	swap 3 << or 2 << fp or undo> c!+ 'undo> ! ;
```

**Undo Encoding:**
- Each undo entry is 1 byte packed with:
  - Bits 0-1: Player facing direction
  - Bits 2-3: Move type (0=walk, 1=push box, 2=push box to goal)
  - Bits 4-6: Floor type at destination (for restoration)

### Undo Actions

```forth
:t0
	$3 and dup 'fp ! 1 xor face2move
	'yp +! 'xp +! ;
:t1
	dup $3 and dup dup 'fp ! 1 xor 
	face2move 'yp +! 'xp +! 
	face2move
	2dup 2 test!
	rot 5 >> $7 and test2!
	;
:t2
	dup $3 and dup dup 'fp ! 1 xor 
	face2move 'yp +! 'xp +! 
	face2move
	2dup 3 test!
	rot 5 >> $7 and test2!
	;

#tlist 't0 't1 't2

:<<undo
	undo> 1 - undo. <? ( drop ; ) 
	dup c@ dup 2 >> $7 and 3 << 'tlist + @ ex
	'undo> ! ;
```

**Undo Types:**
- **t0**: Simple player movement
- **t1**: Push box onto empty ground
- **t2**: Push box onto goal position

**Undo Process:**
1. Read packed undo byte
2. Extract move type (bits 2-4)
3. Execute corresponding undo function
4. Restore player position and facing direction
5. Restore floor and box positions

---

## Game Logic

### Movement System

```forth
:test@ | x y -- c
	yp + swap xp + swap ]map c@ ;

:test! | x y c -- 
	rot xp + rot yp + ]map c! ;

:test2@ | x y -- c
	1 << yp + swap 1 << xp + swap ]map c@ ;
	
:test2! | x y c --
	rot 1 << xp + rot 1 << yp + ]map c! ;
```

**Coordinate Helpers:**
- `test@/test!` - Access tiles relative to player position
- `test2@/test2!` - Access tiles two steps away (for box pushing)

### Movement Actions

```forth
:pgr | ground 0/ groundgoal 4
	0 0 >>stream
	'yp +! 'xp +! ;
:gwa | wall 1
	2drop ;
:pbo | box 2
	2dup test2@ $3 and 1? ( 3drop ; ) drop 
	2dup test2@ 1 >>stream 
	2dup 2dup test2@ 2 >> 2 + test2!
	2dup 0 test!
	'yp +! 'xp +! ;
:pbg | boxingoal 3
	2dup test2@ $3 and 1? ( 3drop ; ) drop
	2dup test2@ 2 >>stream 
	2dup 2dup test2@ 2 >> 2 + test2!
	2dup 4 test!
	'yp +! 'xp +! ;

#psig 'pgr 'gwa 'pbo 'pbg 'pgr
```

**Movement Types:**
- **pgr**: Move onto ground or goal (simple movement)
- **gwa**: Hit wall (no movement, no undo entry)
- **pbo**: Push box onto ground
- **pbg**: Push box onto goal position

**Box Movement Logic:**
1. Check if destination for box is free (`test2@`)
2. Record undo information
3. Move box to new position
4. Clear old box position
5. Move player to box's old position

### Main Movement Function

```forth
:plmove | fa --
	dup 'fp ! 
	face2move
	2dup test@ 
	3 << 'psig + @ ex 
	win? 1? ( "- You Win !! press F3" 'strstate strcpy ) drop
	; | dx dy 
```

**Movement Process:**
1. Set player facing direction
2. Get movement vector from direction
3. Test destination tile
4. Execute appropriate movement function via jump table
5. Check win condition

---

## Graphics and Rendering

### Tile Mapping

```forth
#nrocell ( 89 98 6 9 102 )	| ground wall box boxgoal groundgoal
#nroplay ( 55 52 78 81 ) 	| up dn ri le
```

**Sprite Indices:**
- **Ground tiles**: 89 (ground), 98 (wall), 6 (box), 9 (box on goal), 102 (goal)
- **Player sprites**: 55 (up), 52 (down), 78 (right), 81 (left)

### Layered Rendering

```forth
:drawc	| x y -- x y
	2dup ]map c@ 'nrocell + c@
	pick2 pick2 xymap 
	2dup zspr 89 sprites sspritez | always stone back
	rot zspr swap sprites sspritez ;

:drawmap
	0 ( mapw <? 0 ( maph <? drawc 1 + ) drop 1 + ) drop ;

:drawplay
	xp yp xymap zspr fp 'nroplay + c@ sprites sspritez ;
```

**Rendering Pipeline:**
1. **Background layer**: Always draw ground sprite (89)
2. **Tile layer**: Draw appropriate tile sprite based on cell value
3. **Player layer**: Draw player sprite based on facing direction

**Why Layered Rendering:**
- Ground texture shows through transparent parts of other sprites
- Consistent visual appearance across all tile types
- Player drawn separately to appear above all tiles

---

## Win Condition

```forth
:win? | -- 1/0
	mapw maph * 
	'map >a
	( 1? 1 - ca@+
		4 =? ( 2drop 0 ; ) drop
		) drop 1 ;
```

**Win Algorithm:**
- Scan entire map looking for boxes not on goals
- Cell value 4 = box not on goal position
- If any cell equals 4, player hasn't won yet
- If no cells equal 4, all boxes are on goals = win

---

## Level Management

```forth
:nexl
	nlevel 1 + 62 min dup 'nlevel ! loadlevel ;
:prel
	nlevel 1 - 0 max dup 'nlevel ! loadlevel ;
```

**Level Navigation:**
- 62 total levels (0-61)
- F3 advances to next level (clamped at 62)
- F2 goes to previous level (clamped at 0)
- Each level change triggers `loadlevel`

---

## User Interface

### Status Display

```forth
	$ffffff ttcolor
	10 0 ttat
	'strstate
	undo> undo. -
	nlevel 
	"Sokoban - level:%d - step:%d %s" ttprint
	10 560 ttat
	"ESC Exit | F1 Reset | F2 -Level | F3 +Level | z UNDO" ttprint
```

**UI Elements:**
- **Status line**: Level number, step count, win message
- **Help line**: Key bindings for all game functions
- **Step counting**: `undo> undo. -` calculates moves made

### Input Handling

```forth
	SDLkey
	<up> =? ( 0 plmove )
	<dn> =? ( 1 plmove )
	<ri> =? ( 2 plmove )
	<le> =? ( 3 plmove )
	<z> =? ( <<undo )
	<f1> =? ( nlevel loadlevel )
	<f2> =? ( prel )
	<f3> =? ( nexl )
	>esc< =? ( exit )
	drop ;
```

**Control Scheme:**
- Arrow keys: Move/push in four directions
- Z: Undo last move
- F1: Restart current level
- F2/F3: Previous/next level
- Escape: Exit game

---

## Complete Program Flow

### Initialization

```forth
: |<<<<< BOOT >>>>>
	msec time rerand
	"Sokoban" 1024 600 SDLinit
	64 64 "media\img\sokoban_tilesheet.png" ssload 'sprites !
	ttf_init
	"media/ttf/Roboto-Medium.ttf" 32 TTF_OpenFont ttfont!
	here 'undo. !
	0 loadlevel
	'game SDLshow
	SDLquit 
	;
```

**Startup Sequence:**
1. Initialize random seed
2. Create 1024×600 window
3. Load 64×64 sprite sheet
4. Initialize TrueType font system
5. Set undo buffer to free memory
6. Load first level
7. Run main game loop

---

## Key R3forth Patterns

### Bit Manipulation

```forth
| Bit extraction:
value $3 and          | Get bits 0-1
value 5 >> $7 and     | Get bits 5-7
value 1 << 8 swap -   | Bit shift calculations

| Bit packing:
floor 3 << type or face 2 << or   | Pack multiple values
```

### Jump Tables

```forth
#tlist 't0 't1 't2
move_type 3 << 'tlist + @ ex

#psig 'pgr 'gwa 'pbo 'pbg 'pgr  
tile_type 3 << 'psig + @ ex
```

### Memory Management

```forth
| Dynamic buffer allocation:
here 'undo. !         | Use free memory for undo buffer

| Relative addressing:
undo> c!+ 'undo> !    | Store and advance pointer
undo> 1 - undo. <?    | Bounds checking with comparison
```

### String Operations

```forth
"" 'strstate strcpy                           | Clear string
"- You Win !! press F3" 'strstate strcpy    | Set message
'strstate ... "format:%d" ttprint           | Formatted output
```

---

## Algorithm Analysis

### Time Complexity
- **Level Loading**: O(n) where n = compressed data size
- **Movement**: O(1) - Constant time operations
- **Win Check**: O(w×h) - Must scan entire map
- **Undo**: O(1) - Direct state restoration
- **Rendering**: O(w×h) - Draw every tile

### Space Complexity
- **Level Storage**: O(c) where c = compressed size (much smaller than raw)
- **Game Map**: O(w×h) - Proportional to map size
- **Undo Buffer**: O(m) where m = number of moves
- **Total**: O(w×h + m) - Map plus move history

### Performance Characteristics
- **Memory Efficient**: Compressed levels save significant space
- **Fast Undo**: O(1) undo operations with direct state restoration
- **Scalable Graphics**: Auto-scaling maintains performance across map sizes
- **Responsive Input**: Single frame input latency

---

## Learning Exercises

### Beginner Level
1. **Visual Improvements**: Custom sprites, animations, better UI
2. **Sound Effects**: Movement sounds, box push audio, win fanfare
3. **Statistics**: Track best scores, time taken, move efficiency
4. **Save Progress**: Remember completed levels and best scores

### Intermediate Level
1. **Level Editor**: Create new levels with mouse interface
2. **Hint System**: Show optimal move suggestions
3. **Multiple Undo**: Undo multiple moves with single key
4. **Move Animation**: Smooth movement instead of instant teleport

### Advanced Level
1. **Solver Algorithm**: Implement automatic puzzle solver
2. **Network Play**: Share levels online, compete for best scores
3. **3D Graphics**: Isometric or full 3D rendering
4. **Mobile Port**: Touch controls and mobile-optimized UI

### Programming Challenges
1. **Better Compression**: Improve level compression ratio
2. **Pathfinding**: Implement A* for hint system
3. **Undo Optimization**: Minimize undo memory usage
4. **Performance**: Optimize rendering for very large levels

---

## Code Quality Analysis

### Strengths
1. **Efficient Compression**: Clever bit-stream compression saves memory
2. **Complete Undo System**: Full state restoration with minimal storage
3. **Scalable Graphics**: Auto-scaling adapts to different map sizes
4. **Clean Architecture**: Separated concerns for logic, graphics, and data

### Areas for Enhancement
1. **Error Handling**: Limited bounds checking and error recovery
2. **Magic Numbers**: Hard-coded sprite indices and bit patterns
3. **Modularity**: Some functions handle multiple responsibilities
4. **Documentation**: Compression format could use better explanation

### R3forth Techniques Demonstrated
1. **Bit Manipulation**: Advanced bit packing and extraction
2. **Jump Tables**: Efficient dispatch for different movement types
3. **Memory Efficiency**: Compressed data and circular buffers
4. **State Management**: Complex game state with undo capability

---

## Key Programming Insights

### Game Architecture Patterns
1. **Data-Driven Design**: Levels stored as data, not code
2. **Command Pattern**: Undo system implementing reversible commands
3. **State Pattern**: Different movement behaviors based on tile types
4. **Observer Pattern**: Win condition checking after each move

### Compression Techniques
1. **Run-Length Encoding**: Efficient for sparse tile patterns
2. **Bit-Stream Processing**: Minimize storage with variable-bit encoding
3. **Custom Formats**: Application-specific compression optimized for use case
4. **Memory Management**: Decompression directly into working memory

### Advanced R3forth Programming
1. **Complex State Machines**: Multi-layered game state management
2. **Bit-Level Programming**: Direct bit manipulation for efficiency
3. **Dynamic Scaling**: Mathematical coordinate transformations
4. **Memory Optimization**: Careful memory usage with large data sets

This Sokoban implementation showcases professional-level game development techniques. The compression system, undo mechanism, and scalable graphics demonstrate sophisticated programming approaches that create a polished, efficient game from complex requirements.

---

**Original Code**: PHREDA 2023, MC 2020  
**Repository**: https://github.com/phreda4/r3  
**Tutorial**: Educational analysis for learning R3forth programming