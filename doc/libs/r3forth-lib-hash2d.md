# R3Forth Hash2D Library (hash2d.r3)

A spatial hashing collision detection library for R3Forth that efficiently finds nearby objects in 2D space using a hash table structure.

## Overview

Hash2D provides fast spatial queries for collision detection and proximity searches. It divides 2D space into a grid and uses hash tables to quickly find objects in nearby cells.

**Key Features:**
- Fast O(1) insertion and spatial queries
- Supports up to 65,535 objects (16-bit indices)
- Configurable cell size (default: 32 pixels)
- Radius-based proximity detection
- Memory-efficient packed representation

**Dependencies:**
- `r3/lib/mem.r3` - Memory management

**Data Format:**
- Objects stored as 64-bit values: `r(10)|x(19)|y(19)|link(16)`
- Collision list: pairs of 16-bit object indices

---

## Initialization

### System Setup

- **`H2d.ini`** `( maxobj -- )` - Initialize spatial hash system
  - `maxobj`: Maximum number of objects to support
  - Allocates hash table and object list
  - Hash table size automatically rounded to power of 2
  - Must be called before any other hash2d operations
  ```
  1000 H2d.ini  | Support up to 1000 objects
  ```

- **`H2d.clear`** `( -- )` - Clear all objects from hash
  - Resets hash table to empty state
  - Clears collision detection list
  - Call at start of each frame for dynamic objects
  ```
  H2d.clear  | Clear for new frame
  ```

---

## Adding Objects

### Insert Objects into Hash

- **`h2d+!`** `( nro r x y -- )` - Add object to spatial hash
  - `nro`: Object index/ID (0-65534)
  - `r`: Object radius in pixels (10-bit, max 1023)
  - `x`: X position in pixels (19-bit, ±262,143 range)
  - `y`: Y position in pixels (19-bit, ±262,143 range)
  - Object is inserted into appropriate hash cell
  - Automatically detects nearby objects within radius
  ```
  42 16 500 300 h2d+!  | Add object #42 at (500,300) with radius 16
  ```

- **`h2d!`** `( x y zoom nro radius -- x y zoom )` - Scaled object insertion
  - Convenience function for zoomed coordinates
  - Applies zoom to radius before insertion
  - Preserves x, y, zoom on stack for chaining
  - Useful when working with camera zoom
  ```
  400 200 2.0 5 8 h2d!  | Add object #5, radius 8, zoomed 2x
  ```

---

## Collision Detection

### Getting Collision Pairs

- **`H2d.list`** `( -- 'adr cnt )` - Get list of colliding pairs
  - Returns address and count of collision pairs
  - Each pair: two 16-bit object indices (32 bits total)
  - List populated automatically during `h2d+!` calls
  ```
  H2d.list  | -- addr count
  ( 1? 1-
      @+ 
      dup 16 >> swap $ffff and  | Extract pair indices
      processCollision
  ) drop
  ```

---

## Configuration

### Detection Parameters

- **`checkmax`** - Maximum check distance in pixels
  - Default: 32 pixels
  - Objects beyond this distance from hash cell are ignored
  - Modify before adding objects to change detection range
  ```
  64 'checkmax !  | Increase detection range to 64 pixels
  ```

---

## Internal Structure

### Hash Table Format

The system uses spatial hashing with the following layout:

**Object Storage (64 bits):**
```
Bits 0-15:   Link to next object in cell (16-bit index)
Bits 16-34:  Y position (19-bit signed)
Bits 35-53:  X position (19-bit signed)  
Bits 54-63:  Radius (10-bit unsigned)
```

**Hash Calculation:**
- Space divided into 32×32 pixel cells (configurable via shift)
- Cell coordinates hashed using prime number multiplication
- Collision resolved via linked lists

### Memory Layout

```
[Hash Table]  → Array of 16-bit head pointers (size = nextpow2(maxobj×16))
[Object List] → Array of 64-bit object data (size = maxobj×8)
[Collision]   → Dynamic list of 32-bit collision pairs
```

---

## Algorithm Details

### Spatial Hashing Process

1. **Cell Assignment**: Object position divided by cell size (32 pixels)
2. **Hash Calculation**: Cell coordinates hashed to table index
3. **Insertion**: Object linked into hash cell's list
4. **Proximity Check**: Neighboring cells checked for nearby objects
5. **Collision Recording**: Pairs within combined radii added to list

### Hash Function

Uses prime number multiplication for distribution:
```
hash = ((x >> 5) * 92837111 ^ (y >> 5) * 689287499) & arraylen
```

Two variants:
- `hash`: Uses 32-pixel cells (5-bit shift)
- `hash2`: Uses 1-pixel resolution (no shift)

---

## Usage Patterns

### Basic Collision Detection

```r3forth
| Initialize system
1000 H2d.ini

:gameLoop
    | Clear hash each frame
    H2d.clear
    
    | Add all objects
    0 ( numObjects <? 
        dup getObject  | -- i x y radius
        swap pick2     | -- i x radius y
        pick3          | -- i x radius y i
        h2d+!          | Add object
        1+
    ) drop
    
    | Process collisions
    H2d.list  | -- addr count
    ( 1? 1-
        @+ dup 16 >> swap $ffff and  | obj1 obj2
        handleCollision
    ) drop
    
    | Continue game loop
    ;
```

### With Zoom/Camera

```r3forth
#cameraZoom 1.0

:addVisibleObjects
    H2d.clear
    
    entities ( @+ 0? drop
        @+ @+  | x y
        cameraZoom 
        pick3  | object index
        8      | radius
        h2d!   | Add with zoom
        
        3drop  | Clean stack (x y zoom)
        8 +    | Next entity
    ) drop ;
```

### Spatial Query (Find Nearby)

```r3forth
| Find all objects near a point
:findNear | x y radius --
    H2d.clear
    
    | Add query point as object 0
    0 swap pick2 pick2 h2d+!
    
    | Check collision list
    H2d.list
    ( 1? 1-
        @+ 
        dup 16 >> 0 =? ( 
            | Object 0 in pair = nearby object
            drop $ffff and processNearby
        ) 2drop
    ) drop ;

500 300 50 findNear  | Find all within 50 pixels of (500,300)
```

---

## Complete Examples

### Simple Circle Collision

```r3forth
| Bouncing circles with collision
1000 H2d.ini

#circles * 100  | Array: x y vx vy radius

:initCircles
    'circles 100 ( 1? 1-
        rand 800 * sw +
        rand 600 * sh +
        rand 10 * 2 - 
        rand 10 * 2 -
        10  | radius
        rot !+ !+ !+ !+ !+
    ) drop ;

:updateCircles
    H2d.clear
    
    | Add all circles to hash
    'circles 100 0 ( swap 1? 1- >r
        @+ @+ @+ @+ @+  | x y vx vy r
        2over swap      | x y vx vy r y x
        pick2           | x y vx vy r y x r
        rot             | x y vx vy r r y x  
        pick4           | x y vx vy r r y x i
        h2d+!           | x y vx vy r
        
        | Simple physics
        pick3 pick3 + sw clamp0max
        pick4 pick4 + sh clamp0max
        
        | Store back
        rot >r >r 5 - 
        r> !+ r> !+ !+ !+
        
        r> swap 1+
    ) 3drop ;

:handleCollisions
    H2d.list
    ( 1? 1-
        @+ dup 16 >> swap $ffff and  | obj1 obj2
        
        | Bounce circles apart (simplified)
        | In real code: calculate collision normal
        | and adjust velocities
        
        2drop  | Skip for now
    ) drop ;

:drawCircles
    circles 100 ( 1? 1-
        @+ @+  | x y
        $ffffff SDLColor
        pick2 SDLCircle
        16 +
    ) drop ;

:gameLoop
    updateCircles
    handleCollisions
    
    $000000 SDLcls
    drawCircles
    SDLredraw
    
    SDLkey 0? ( drop gameLoop ; ) drop ;

initCircles
gameLoop
```

### Bullet-Enemy Collision

```r3forth
500 H2d.ini

#bullets * 1000  | x y vx vy active
#enemies * 500   | x y health

:updateBullets
    'bullets 100 ( 1? 1-
        dup 16 + @ 0? ( drop 20 + ; ) drop  | Skip inactive
        
        @+ @+ @+ @+ drop  | x y vx vy
        | Update position
        2over + swap pick3 + swap
        
        | Check bounds
        dup 0 <? ( 5 - 0 swap ! 20 + ; ) drop
        dup sh >? ( 5 - 0 swap ! 20 + ; ) drop
        
        | Add to hash (bullets = 0-99)
        2over swap pick4 100 / 5 h2d+!
        
        | Store back
        rot >r >r 8 -
        r> !+ r> !+ !+ !+
        
        20 +
    ) drop ;

:updateEnemies  
    'enemies 50 ( 1? 1-
        @+ @+  | x y
        
        | Add to hash (enemies = 100-149)
        2dup swap pick3 50 / 100 + 10 h2d+!
        
        8 +  | Skip health
    ) drop ;

:processHits
    H2d.list
    ( 1? 1-
        @+ dup 16 >> swap $ffff and  | obj1 obj2
        
        | Check if bullet-enemy collision
        over 100 <? (  | obj1 is bullet
            dup 100 >=? (  | obj2 is enemy
                | Bullet hit enemy
                swap 20 * bullets + 16 + 0 swap !  | Deactivate bullet
                100 - 12 * enemies + 8 + dup @ 1 - swap !  | Damage enemy
            ) drop
        ) drop
        2drop
    ) drop ;

:gameLoop
    H2d.clear
    updateBullets
    updateEnemies
    processHits
    
    | Render...
    ;
```

### Grid-based Object Lookup

```r3forth
| Use hash2d for fast spatial queries without collision
1000 H2d.ini

:findObjectsInArea | x y w h --
    H2d.clear
    
    | Add center point as object 0
    2over + 2/ swap 2over + 2/ swap  | cx cy
    pick3 pick3 max 2/ | radius
    0 swap pick2 pick2 h2d+!
    
    | Now add all game objects
    gameObjects ( @+ 0? drop
        @+ @+  | x y
        2dup swap pick3  | x y y x i
        10 swap h2d+!
        8 +
    ) drop
    
    | Collect results
    here >a
    H2d.list
    ( 1? 1-
        @+ dup 16 >>  | pair obj1
        0 =? ( drop $ffff and a!+ ; )  | Store obj2 if obj1=0
        2drop
    ) drop
    a> here over - 2 >> ;  | Return list and count
```

---

## Notes

- **Frame clearing**: Call `H2d.clear` each frame for moving objects
- **Static objects**: Can be added once and kept across frames
- **Radius limits**: 10-bit radius (0-1023 pixels maximum)
- **Position limits**: 19-bit coordinates (±262,143 pixels)
- **Cell size**: Default 32 pixels, modify hash function for different sizes
- **Performance**: O(1) insertion, O(n) proximity checks where n = objects per cell
- **Memory**: Approximately 10 bytes per object + hash table overhead
- **Collision pairs**: Automatically generated during insertion
- **Order matters**: Add query object first to find nearby objects

## Performance Tips

1. **Right-size hash table**: Use `H2d.ini` with accurate maximum object count
2. **Clear per frame**: Only for dynamic objects, keep static geometry
3. **Batch insertions**: Add all objects before processing collisions
4. **Tune cell size**: Modify hash function shift for object size distribution
5. **Radius accuracy**: Use smallest valid radius to reduce false positives
6. **Check distance**: Set `checkmax` appropriately for your game scale

## Coordinate System

- **Origin**: Top-left (0, 0)
- **Positive X**: Right direction
- **Positive Y**: Down direction  
- **19-bit range**: ±262,143 pixels
- **Cell grid**: Aligned to 32-pixel boundaries

## Advanced: 3D Extension

The code includes comments about 3D extension:
```
| in 3d (16)(16)(16)(16) . with 128bits (1)(21)(21)(21)(16)
```

This suggests the system could be extended to 3D using 128-bit values with:
- 21 bits per coordinate (±1 million range)
- 16-bit linking
- Similar hash-based spatial partitioning

## Common Pitfalls

1. **Forgetting H2d.clear**: Results in stale collision data
2. **Wrong radius scale**: Forgetting zoom when using `h2d!`
3. **Index overflow**: Using object indices > 65534
4. **Position overflow**: Coordinates beyond ±262,143
5. **Radius too large**: > 1023 pixels causes wraparound
6. **Not processing pairs**: Collision list must be explicitly iterated

