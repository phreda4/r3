# R3 2D Hash Collision Detection Library Documentation

## Overview

`hash2d.r3` provides an efficient spatial hash-based collision detection system for 2D objects. It uses hash tables to organize objects spatially, enabling fast nearest-neighbor queries and collision detection for games and simulations with many moving objects.

## Dependencies
- `r3/lib/mem.r3` - Memory management for dynamic data structures

## Core Concepts

### Spatial Hashing
Objects are mapped to hash table buckets based on their 2D coordinates, allowing:
- **O(1) insertion** of objects into spatial grid
- **Fast proximity queries** by checking only nearby grid cells  
- **Scalable collision detection** that doesn't degrade with object count
- **Dynamic object management** with efficient updates

### Data Format
Objects are stored with packed coordinates and linking information:
- **54 bits**: Combined x,y coordinates and radius
- **16 bits**: Link to next object in same hash bucket

## Memory Layout

### Hash Table Structure
```r3
#arraylen        // Hash table size (power of 2 minus 1)
#matrix         // Hash table array (16-bit indices)
#matlist        // Object data array (64-bit packed objects)
#H2dlist        // Contact pair results
#H2dlist>       // Current position in contact list
```

### Coordinate Packing
Objects use a compressed 64-bit format:
- **Bits 54-63**: Radius (10 bits, max 1024 pixels)
- **Bits 35-53**: X coordinate (19 bits, max 524k pixels)  
- **Bits 16-34**: Y coordinate (19 bits, max 524k pixels)
- **Bits 0-15**: Link to next object (16 bits, max 65k objects)

## System Functions

### Initialization
```r3
H2d.ini    | max_objects --          // Initialize hash table
H2d.clear  | --                      // Clear all objects
H2d.list   | -- contacts count       // Get contact pair list
```

**Example:**
```r3
1000 H2d.ini                         // Initialize for 1000 objects
H2d.clear                            // Start with empty hash table
```

### Object Management
```r3
h2d+!      | id radius x y --        // Add object to hash table
h2d!       | x y zoom id radius --   // Add with zoom transformation
```

## Hash Functions

### Primary Hash
```r3
hash       | x y -- hash_index       // Hash coordinates (divide by 32)
hash2      | x y -- hash_index       // Alternative hash (no division)
```

The hash functions use large prime multipliers (92837111, 689287499) to distribute objects evenly across the hash table.

## Collision Detection System

### Contact Detection Parameters
```r3
#checkmax 32     // Maximum check distance in pixels
#x1 #x2 #y1 #y2 // Bounding box for current query
```

### Contact Collection Process
1. **Calculate search area** around target object
2. **Iterate through hash cells** in the search region
3. **Check distance** between objects using Manhattan distance  
4. **Store contacts** that are within interaction range

## Complete Usage Examples

### Basic Particle System
```r3
#particles * 1000
#particle-count 0

:init-collision-system
    1000 H2d.ini                     // Support up to 1000 particles
    H2d.clear ;

:add-particle | x y vx vy --
    particle-count 3 << 'particles + | Get particle slot
    !+ !+ !+ !                       // Store x, y, vx, vy
    
    particle-count                   // Particle ID
    8                                // Radius (8 pixels)
    pick3 pick3                      // x y coordinates
    h2d+!                           // Add to hash table
    
    1 'particle-count +! ;

:update-particles
    H2d.clear                        // Clear previous frame
    
    0 ( particle-count <? 
        dup 4 << 'particles +        // Get particle data
        @+ @+ @+ @                   // x y vx vy
        
        | Update position  
        rot + rot + swap             // x' y' vx vy
        
        | Store back
        pick3 4 << 'particles + !+ !+ !+ !
        
        | Add to collision system
        over 8                       // radius
        pick3 pick3                  // x y
        h2d+!
        
        1+
    ) drop ;

| Usage:
init-collision-system
100 100 5 3 add-particle            // Add particle at (100,100) moving (5,3)
200 150 -2 4 add-particle           // Add another particle
```

### Game Object Collision
```r3
#enemies * 100
#bullets * 50
#enemy-count 0
#bullet-count 0

:add-enemy | x y health --
    enemy-count 3 << 'enemies +
    !+ !+ !                          // Store x, y, health
    
    enemy-count 100 +                // Enemy ID (offset from bullets)
    16                               // Enemy radius
    pick3 pick3 h2d+!               // Add to spatial hash
    
    1 'enemy-count +! ;

:add-bullet | x y --
    bullet-count 2 << 'bullets +
    !+ !                             // Store x, y
    
    bullet-count                     // Bullet ID  
    4                                // Small bullet radius
    pick3 pick3 h2d+!               // Add to spatial hash
    
    1 'bullet-count +! ;

:check-collisions
    H2d.list                         // Get contact pairs
    ( 1? 1-
        @+ 16 >> swap $ffff and      // Extract two object IDs
        
        | Check if bullet-enemy collision
        over 100 <? over 100 >=? and
        ? ( process-bullet-hit )     // Bullet ID < 100, Enemy ID >= 100
        drop
    ) drop ;

:process-bullet-hit | bullet-id enemy-id --
    | Remove bullet and damage enemy
    over remove-bullet
    swap damage-enemy ;

:game-frame
    H2d.clear
    update-enemies                   // Move enemies, add to hash
    update-bullets                   // Move bullets, add to hash
    check-collisions                 // Process all collisions
    ;
```

### Spatial Query System
```r3
:find-nearby-objects | x y radius -- 'contacts count
    32 'checkmax !                   // Set search radius
    
    H2d.clear
    | ... add all objects to hash ...
    
    | Query around point
    999 swap                         // Use special query ID
    pick3 pick3 h2d+!               // Add query point
    
    H2d.list ;                       // Return contact list

:draw-influence-map | x y --
    dup 50 find-nearby-objects       // Find objects within 50 pixels
    
    | Draw connections
    ( 1? 1-
        @+ 16 >> swap $ffff and      // Get object pair
        999 =? ( draw-connection )   // Draw if connected to query point
        2drop
    ) drop ;
```

### Advanced Collision Response
```r3
#collision-pairs * 500
#pair-count 0

:collect-collisions
    0 'pair-count !
    H2d.list
    
    ( 1? 1-
        @+ 16 >> swap $ffff and      // Extract IDs
        
        | Store collision pair for later processing
        'collision-pairs pair-count 2 << + !+ !
        1 'pair-count +!
        
        pair-count 500 >=? ( ; )     // Prevent overflow
    ) drop ;

:resolve-collisions  
    0 ( pair-count <?
        dup 2 << 'collision-pairs +  // Get pair
        @+ @                         // id1 id2
        
        | Get object positions and velocities
        resolve-collision-pair
        
        1+
    ) drop ;

:resolve-collision-pair | id1 id2 --
    | Calculate collision response
    | Update velocities based on masses and positions
    | ... collision physics code ...
    ;
```

## Performance Characteristics

### Hash Table Sizing
The system automatically sizes the hash table to be larger than the maximum object count:
```r3
maxobj 4 << nextpow2 1 -            // Hash table = 16 × max_objects (rounded up)
```

This provides good distribution while minimizing collisions.

### Spatial Resolution
- **Grid cell size**: 32 pixels (configurable via hash function)
- **Search efficiency**: Only checks 9 cells maximum for small objects
- **Memory usage**: 2 bytes per hash bucket + 8 bytes per object

### Complexity Analysis
- **Insertion**: O(1) average case
- **Query**: O(k) where k is objects in nearby cells
- **Memory**: O(n) where n is maximum objects

## Advanced Features

### Multi-Resolution Hashing
```r3
:hash-large | x y -- hash
    7 >> 92837111 * swap            // Larger grid cells for big objects
    7 >> 689287499 * xor
    arraylen and ;
```

### Dynamic Grid Sizing  
```r3
:adaptive-checkmax | object-density --
    10 max 100 min 'checkmax ! ;    // Adjust search radius based on density
```

## Best Practices

1. **Grid Resolution**: Set grid size to average object size for optimal performance
2. **Hash Table Size**: Use 4-16× object count for good distribution
3. **Update Frequency**: Clear and rebuild hash table each frame for moving objects
4. **Memory Management**: Pre-allocate contact list to avoid dynamic allocation
5. **Query Optimization**: Use appropriate search radius to balance accuracy vs performance

## Integration Patterns

### With Physics System
```r3
:physics-step
    H2d.clear
    add-all-objects-to-hash
    resolve-all-collisions
    apply-physics-updates ;
```

### With Rendering System
```r3
:cull-invisible-objects | camera-x camera-y view-radius --
    find-nearby-objects               // Get objects near camera
    render-object-list ;              // Only render nearby objects
```

This spatial hashing system provides efficient collision detection for games and simulations requiring real-time performance with hundreds or thousands of moving objects.