# R3 Array16 Library Documentation

## Overview

`arr16.r3` is a high-performance dynamic array library for R3 that manages collections of 16-value (128-byte) records. It provides efficient operations for adding, removing, traversing, and sorting array elements with optimized memory management.

## Core Concepts

### Array Structure
Each array consists of:
- **Header**: 8 bytes containing current position and start address
- **Elements**: Fixed-size 128-byte records (16 × 32-bit values)
- **Memory Layout**: Contiguous allocation for cache efficiency

### Element Format
Each element is exactly 128 bytes (32 × 32-bit words), allowing storage of:
- 32 integers
- 16 doubles/fixed-point numbers  
- 8 quad-precision values
- Mixed data types as needed

## Initialization and Setup

### `p.ini | cantidad list --`
Initializes a new array with specified capacity.

**Parameters:**
- `cantidad` - Maximum number of elements
- `list` - Array header address (2 words: current, start)

**Memory Usage:** `cantidad × 128 + 8 bytes`

**Example:**
```r3
#myarray 0 0              // Array header
100 'myarray p.ini        // Initialize for 100 elements
```

### `p.clear | list --`
Clears all elements from the array, resetting it to empty state.

**Example:**
```r3
'myarray p.clear          // Remove all elements
```

## Adding Elements

### `p!+ | 'act list -- adr`
Adds a new element and executes initialization function.

**Parameters:**
- `'act` - Address of function to initialize the element
- `list` - Array address
- **Returns:** Address of new element

**Example:**
```r3
:init-player | adr --
    100 over !+           // x position
    200 over !+           // y position  
    50 over !+            // health
    drop ;

'init-player 'players p!+ drop  // Add new player
```

### `p! | list -- adr`
Allocates a new element without initialization.

**Returns:** Address of new element for manual setup

**Example:**
```r3
'enemies p!               // Get new enemy slot
100 over !+               // Set x
200 over !+               // Set y
drop                      // Finish setup
```

## Querying and Access

### `p.cnt | list -- cnt`
Returns the current number of elements in the array.

**Example:**
```r3
'players p.cnt            // Get player count
"Players: %d" print
```

### `p.adr | nro list -- adr`
Converts element index to memory address.

**Parameters:**
- `nro` - Element index (0-based)
- `list` - Array address
- **Returns:** Element address

**Example:**
```r3
0 'players p.adr          // Get first player address
@ "First player X: %d" print
```

### `p.nro | adr list -- nro`
Converts memory address to element index.

**Parameters:**
- `adr` - Element address
- `list` - Array address  
- **Returns:** Element index

**Example:**
```r3
player-addr 'players p.nro
"Player index: %d" print
```

## Traversal and Processing

### `p.draw | list --`
Traverses array executing each element's function. Elements returning 0 are deleted (unordered).

**Element Function Signature:** `adr -- flag`
- Return non-zero to keep element
- Return 0 to delete element

**Example:**
```r3
:update-bullet | adr -- flag
    dup @ 5 +            // Move bullet right
    dup swap !
    800 <? ( 1 ; )       // Keep if on screen
    0 ;                  // Delete if off screen

'bullets p.draw          // Update all bullets
```

### `p.drawo | list --`
Traverses array executing each element's function. Elements returning 0 are deleted (ordered).

**Note:** Slower than `p.draw` but maintains element order.

**Example:**
```r3
:update-enemy | adr -- flag  
    dup @ 1 -             // Reduce health
    dup swap !
    0 >? ( 1 ; )          // Keep if alive
    0 ;                   // Delete if dead

'enemies p.drawo          // Update maintaining order
```

## Element Removal

### `p.del | adr list --`
Removes specific element by address.

**Parameters:**
- `adr` - Address of element to remove
- `list` - Array address

**Example:**
```r3
dead-enemy 'enemies p.del  // Remove specific enemy
```

## Mapping Operations

### `p.mapv | 'vector list --`
Applies function to every element without deletion capability.

**Element Function Signature:** `adr --`

**Example:**
```r3
:draw-sprite | adr --
    dup @ over 4 + @      // Get x, y
    over 8 + @ swap       // Get sprite ID
    sprite.draw ;

'sprites p.mapv           // Draw all sprites
```

### `p.mapd | 'vector list --`
Applies function to every element with deletion capability.

**Element Function Signature:** `adr -- flag`
- Return non-zero to keep
- Return 0 to delete

### `p.map2 | 'vec 'list --`
Applies function to every pair of elements (triangular traversal).

**Element Function Signature:** `adr1 adr2 --`

**Example:**
```r3
:collision-check | obj1 obj2 --
    | Check collision between two objects
    ... collision detection code ... ;

'collision-check 'objects p.map2  // Check all pairs
```

## Sorting

### `p.sort | col 'list --`
Performs one-pass ascending sort by specified column.

**Parameters:**
- `col` - Column index to sort by (0-based)
- `list` - Array address

**Note:** Single pass only. Repeat calls for full ordering.

**Example:**
```r3
2 'players p.sort         // Sort by 3rd column (health)
```

### `p.isort | col 'list --`
Performs one-pass descending sort by specified column.

**Example:**
```r3
0 'highscores p.isort     // Sort scores descending
```

## Complete Example: Bullet System

```r3
| Bullet structure: x, y, vx, vy, life, damage, ...
#bullets 0 0

:init-bullet | adr --
    player-x over !+      // x = player position
    player-y over !+      // y = player position  
    10 over !+            // vx = speed right
    0 over !+             // vy = no vertical speed
    120 over !+           // life = 2 seconds at 60fps
    25 over !+            // damage = 25
    drop ;

:update-bullet | adr -- keep?
    | Update position
    dup dup @ over 8 + @ +  swap !    // x += vx
    dup 4 + dup @ over 12 + @ + swap ! // y += vy
    
    | Decrease life
    dup 16 + dup @ 1 - dup swap !
    
    | Check if still alive and on screen
    0 >? ( dup @ 800 <? nip ; )  // Keep if life > 0 and x < 800
    0 ;                          // Delete otherwise

:fire-bullet
    'init-bullet 'bullets p!+ drop ;

:setup-bullets
    200 'bullets p.ini    // Initialize bullet array
    ;

:game-loop
    cls
    
    | Update bullets
    'update-bullet 'bullets p.mapd
    
    | Draw bullets  
    :draw-bullet | adr --
        dup @ over 4 + @  // Get x, y
        4 4 fillrect ;    // Draw 4x4 bullet
    
    'draw-bullet 'bullets p.mapv
    
    | Fire on spacebar
    32 keydown? ( fire-bullet ) 
    
    'game-loop onkey ;

setup-bullets
game-loop
```

## Memory Management

### Allocation Strategy
- **Pre-allocated**: Full array size allocated at initialization
- **No Fragmentation**: Fixed-size elements prevent memory fragmentation
- **Cache Friendly**: Contiguous memory layout optimizes cache usage

### Performance Characteristics

#### Advantages
- **O(1) Access**: Direct indexing by element number
- **O(1) Append**: Adding elements at end is constant time
- **Efficient Traversal**: Linear memory access pattern
- **Fast Deletion**: Unordered deletion is O(1)

#### Limitations
- **Fixed Element Size**: All elements must be exactly 128 bytes
- **Memory Overhead**: Pre-allocates full capacity
- **Ordered Operations**: Maintaining order during deletion is O(n)

## Best Practices

1. **Size Planning**: Choose initial capacity to avoid reallocations
2. **Element Design**: Structure data to fit efficiently in 128 bytes
3. **Update Patterns**: Use `p.draw` for performance, `p.drawo` for order
4. **Sorting Strategy**: Call sort functions multiple times for full ordering
5. **Memory Efficiency**: Clear unused arrays to free memory

## Common Patterns

### Game Objects
```r3
| Object: x, y, vx, vy, sprite, health, state, timer...
100 'gameobjects p.ini
```

### Particle Systems  
```r3
| Particle: x, y, vx, vy, life, size, color, type...
1000 'particles p.ini
```

### UI Elements
```r3
| Widget: x, y, w, h, type, state, callback, data...
50 'widgets p.ini
```

This array system provides an excellent foundation for managing collections of game objects, particles, UI elements, or any structured data requiring efficient batch operations.