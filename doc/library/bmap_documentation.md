# R3 Bitmap Tile Map Library Documentation

## Overview

`bmap.r3` provides a comprehensive tile-based map rendering system for 2D games. It supports multi-layered tilemaps with sprite rendering, conditional tile drawing, trigger systems, and optimized viewport-based rendering. The library is designed for tile-based games, RPGs, and 2D platformers requiring efficient large-world rendering.

## Dependencies
- `r3/lib/console.r3` - Console output for debugging
- `r3/lib/sdl2gfx.r3` - SDL2 graphics primitives
- `r3/util/sdlgui.r3` - SDL GUI utilities
- `r3/util/arr16.r3` - Dynamic array management
- `r3/lib/rand.r3` - Random number generation

## Core Concepts

### Multi-Layer Tile System
Each tile can contain multiple layers stored in a 64-bit value:
- **Background layers**: Base terrain and decorative elements
- **Collision layers**: Interactive elements and triggers
- **Foreground layers**: Elements that render above sprites
- **Conditional rendering**: Tiles that appear/disappear based on game state

### Sprite Rendering Order
The system maintains proper depth sorting by rendering sprites between tile layers, ensuring correct visual layering in isometric or pseudo-3D environments.

## Data Structures

### Map Configuration
```r3
#mapgame              // Pointer to map data
#mapw #maph          // Map dimensions in tiles
#mapx #mapy          // Current viewport offset in pixels
#maptw #mapth        // Tile size in pixels (typically 32×32)
#mapsx #mapsy        // Current viewport position in tiles
#mapsw #mapsh        // Screen size in tiles
```

### Tileset Configuration
```r3
#tileset             // Tileset data structure
#tilew #tileh        // Individual tile dimensions in tileset
#tsimg               // Tileset texture/image
#tsmap               // Tile mapping data
```

### Sprite System
```r3
#sprinscr            // Sprite render list
#sprinscr>           // Current position in sprite list
#sprinscr<           // Processing position
```

## Core Functions

### Map Loading and Setup
```r3
loadmap      | "filename" --         // Load map from file
bmap2xy      | x y -- x_pixels y_pixels // Convert tile to pixel coordinates
whbmap       | -- width height       // Get map dimensions
```

### Viewport Management
```r3
drawmaps     | x_viewport y_viewport -- // Render visible portion of map
```

The rendering system automatically handles:
- **Viewport culling**: Only renders visible tiles
- **Layer ordering**: Renders background, sprites, then foreground
- **Sprite depth sorting**: Maintains correct rendering order

### Tile Access and Queries
```r3
xyinmap@     | x y -- tile_data      // Get tile data at pixel coordinates
xytrigger    | x y --                // Activate trigger at coordinates
```

## Tile Data Format

### 64-bit Tile Encoding
```
Bits 0-11:   Background tile (4096 tile IDs)
Bits 12-23:  Background layer 2 
Bits 24-35:  Foreground tile
Bits 36-47:  Foreground layer 2
Bit 49:      No-draw flag (skip rendering)
Bit 50:      Conditional flag (state-dependent)
Bit 51:      Triggered flag (activated)
```

## Sprite Integration System

### Sprite Registration
```r3
inisprite    | --                    // Initialize sprite rendering system
+sprite      | tile_id x y --        // Add sprite to render queue
```

### Custom Sprite Rendering
```r3
#bsprdraw 'defsprite                 // Sprite drawing callback
```

The sprite callback signature is:
```r3
sprite_callback | x y tile_id --     // Render sprite at position
```

## Complete Usage Examples

### Basic Map Setup
```r3
:init-game-map
    "maps/level1.map" loadmap
    0? ( "Failed to load map" .println ; )
    
    inisprite                        // Initialize sprite system
    
    | Setup custom sprite renderer
    :my-sprite-renderer | x y tile_id --
        | Custom sprite drawing logic
        draw-game-sprite ;
        
    'my-sprite-renderer 'bsprdraw ! ;
```

### Game Loop with Map Rendering
```r3
#camera-x 0
#camera-y 0
#player-x 512
#player-y 384

:update-camera
    | Center camera on player
    player-x 400 - 'camera-x !
    player-y 300 - 'camera-y !
    
    | Clamp camera to map bounds
    camera-x 0 clampmin 'camera-x !
    camera-y 0 clampmin 'camera-y !
    
    camera-x mapw 32 * 800 - clampmax 'camera-x !
    camera-y maph 32 * 600 - clampmax 'camera-y ! ;

:render-game
    update-camera
    camera-x camera-y drawmaps       // Render visible map area
    
    | Add game sprites to render queue
    player-x camera-x - player-y camera-y - PLAYER_SPRITE +sprite
    
    | Add enemies, items, etc.
    render-enemies
    render-items ;

:game-loop
    cls
    render-game
    SDLredraw
    'game-loop onkey ;
```

### Interactive Elements and Triggers
```r3
#door-open 0

:check-door-trigger | player-x player-y --
    xyinmap@ $4000000000000 and     // Check if tile has trigger flag
    ? ( 
        1 'door-open !               // Open door
        player-x player-y xytrigger  // Activate trigger
    ) ;

:update-conditional-tiles
    | Update tiles based on game state
    door-open ? ( 
        | Door is open - modify door tiles
        update-door-tiles
    ) ;
```

### Multi-Layer Rendering Example
```r3
:complex-tile-setup
    | Create a tile with multiple layers
    | Background: grass (tile 1)
    | Background 2: flowers (tile 15) 
    | Foreground: tree top (tile 200)
    | Conditional flag set
    
    1                               // Base grass
    15 12 << or                     // Flowers on layer 2
    200 24 << or                    // Tree top on foreground
    $4000000000000 or              // Mark as conditional
    
    | Store in map at position (10,15)
    15 10 map> ! ;
```

### Advanced Sprite Depth Sorting
```r3
#game-sprites * 1000
#sprite-count 0

:add-game-sprite | x y z sprite_id --
    | Store sprite with depth information
    sprite-count 4 << 'game-sprites +
    !+ !+ !+ !                      // x, y, z, sprite_id
    1 'sprite-count +! ;

:render-sprites-by-depth
    | Sort sprites by Y coordinate for proper layering
    'game-sprites sprite-count sort-by-y
    
    | Add sorted sprites to render queue
    0 ( sprite-count <?
        dup 4 << 'game-sprites +
        @+ @+ @+ @                  // x y z sprite_id
        rot drop                    // Ignore z for 2D
        +sprite
        1+
    ) drop ;
```

### Map Editor Integration
```r3
#editor-mode 0
#selected-tile 1

:map-editor-click | mouse-x mouse-y --
    editor-mode 0? ( 2drop ; )
    
    | Convert mouse to map coordinates
    camera-x + 32 / swap camera-y + 32 / swap
    
    | Bounds check
    dup 0 mapw between? over 0 maph between? and 0? ( 2drop ; )
    
    | Place selected tile
    map> selected-tile swap ! ;

:toggle-editor
    editor-mode 0 =? ( 1 ; 0 ) 'editor-mode ! ;
```

## Performance Optimization

### Viewport Culling
The system only processes tiles within the visible screen area:
```r3
:is-tile-visible | tile-x tile-y -- flag
    mapsy over + maph >=? ( 2drop 0 ; )  // Below map
    mapsx pick2 + mapw >=? ( 2drop 0 ; ) // Right of map
    mapsy + 0 <? ( drop 0 ; )            // Above screen
    mapsx + 0 <? ( 0 ; )                 // Left of screen
    1 ;                                  // Visible
```

### Sprite Batching
Sprites are collected and sorted before rendering to minimize state changes:
```r3
:batch-sprites-by-texture
    | Group sprites by texture to reduce binding calls
    sort-sprites-by-texture
    render-sprite-batches ;
```

### Conditional Rendering
Uses bitwise operations for efficient tile state checking:
```r3
:check-tile-flags | tile-data mask -- flag
    and 0<> ;                           // Fast bitwise test

| Usage:
tile-data $2000000000000 check-tile-flags  // Check no-draw flag
```

## Memory Management

### Map Data Layout
```
Map File Format:
- Header: width, height (8 bytes each)
- Tile data: width × height × 8 bytes per tile
- Tileset info: tile width, height (8 bytes each)
- Tileset image data
```

### Sprite Memory
```r3
:cleanup-sprites
    0 'sprite-count !
    sprinscr 'sprinscr> ! ;
```

## Integration Patterns

### With Physics System
```r3
:check-tile-collision | x y -- solid?
    xyinmap@ $fff and                  // Get base tile
    collision-table + c@ ;             // Look up collision flag
```

### With Audio System
```r3
:trigger-tile-sound | x y --
    xyinmap@ $4000000000000 and       // Check trigger flag
    ? ( play-trigger-sound ) ;
```

### With Save System
```r3
:save-map-state
    | Save only modified tile flags
    mapgame >a
    mapw maph * ( 1? 1-
        a@ $e000000000000 and          // Extract state flags
        save-tile-state
        8 a+
    ) drop ;
```

## Best Practices

1. **Tile Size**: Use power-of-2 dimensions (32×32, 64×64) for optimal performance
2. **Layer Usage**: Reserve foreground layers for elements that need to appear above sprites
3. **Sprite Batching**: Group sprites by texture to minimize draw calls
4. **Memory**: Pre-allocate sprite arrays to avoid dynamic allocation during gameplay
5. **Culling**: Implement additional culling for very large maps or complex scenes

This tilemap system provides a robust foundation for 2D games requiring efficient rendering of large, layered worlds with proper sprite integration and interactive elements.