# R3 Variable Animator Library Documentation

## Overview

`varanim.r3` is a comprehensive animation system for R3 that provides time-based variable interpolation with easing functions. It allows you to animate any variable over time using various interpolation methods and execute callbacks at specific times.

## Core Concepts

### Timeline System
The library uses a timeline-based approach where animations are scheduled to start at specific times and execute over defined durations. All animations are processed in a single update loop for optimal performance.

### Animation Types
- **Value Animation**: Interpolate between two numeric values
- **Box Animation**: Animate 4-component packed values (x, y, w, h)
- **XY Animation**: Animate 2D coordinates
- **Color Animation**: Animate color values with blending
- **Execution Events**: Execute functions at specific times

## Initialization

### `vaini | max --`
Initializes the animation system.

**Parameters:**
- `max` - Maximum number of concurrent animations

**Example:**
```r3
100 vaini  // Initialize for up to 100 concurrent animations
```

### `vareset | --`
Resets the animation system, clearing all active animations and resetting the timeline.

## Basic Animation Functions

### `+vanim | 'var ini fin ease dur. start --`
Creates a basic value animation.

**Parameters:**
- `'var` - Address of variable to animate
- `ini` - Initial value
- `fin` - Final value  
- `ease` - Easing function (0-15, see Penner easing functions)
- `dur.` - Duration in seconds (fixed-point)
- `start` - Start time in seconds (fixed-point)

**Example:**
```r3
'myvar 0 100 1 2.0 1.0 +vanim  // Animate myvar from 0 to 100 over 2 seconds, starting at 1 second
```

### `+vboxanim | 'var fin ini ease dur. start --`
Animates a 64-bit packed value containing 4 16-bit components (typically x, y, w, h).

**Parameters:**
- Same as `+vanim` but `ini` and `fin` are 64-bit packed values

**Example:**
```r3
'rect 0 0 100 50 xywh64 10 10 200 100 xywh64 2 3.0 0.5 +vboxanim  // Animate rectangle
```

### `+vxyanim | 'var ini fin ease dur. start --`
Animates XY coordinates stored as a 64-bit value (two 32-bit coordinates).

**Example:**
```r3
'position 100 200 xy32 300 400 xy32 3 1.5 0 +vxyanim  // Animate position
```

### `+vcolanim | 'var ini fin ease dur. start --`
Animates color values with proper color blending.

**Example:**
```r3
'color $ff0000 $00ff00 1 2.0 0 +vcolanim  // Animate from red to green
```

## Execution Functions

### `+vexe | 'vector start --`
Executes a function at a specific time.

**Parameters:**
- `'vector` - Address of function to execute
- `start` - Time to execute (in seconds)

**Example:**
```r3
:dosomething "Action executed!" print ;
'dosomething 3.0 +vexe  // Execute function after 3 seconds
```

### `+vvexe | v 'vector start --`
Executes a function with one parameter at a specific time.

**Parameters:**
- `v` - Parameter value to pass to function
- `'vector` - Address of function
- `start` - Execution time

### `+vvvexe | v1 v2 'vector start --`
Executes a function with two parameters at a specific time.

## Update Loop

### `vupdate | --`
Updates all active animations. Call this once per frame in your main loop.

**Example:**
```r3
:gameloop
    cls
    vupdate     // Update all animations
    render
    'gameloop onkey ;
```

## Utility Functions

### Packing/Unpacking Functions

#### 64-bit Box Values (4 × 16-bit)
```r3
xywh64 | x y w h -- b       // Pack 4 values into 64-bit
64xywh | b -- x y w h       // Unpack to 4 values  
64xy   | b -- x y           // Get first two values
64wh   | b -- w h           // Get last two values
64box  | b adr --           // Store unpacked values to address
```

#### 64-bit XY+RZ Values (for sprites)
```r3
xyrz64 | x y r z -- b       // Pack with scaling (r<<2, z<<4)
64xyrz | b -- x y r z       // Unpack with scaling
```

#### 32-bit XY Values
```r3
xy32   | x y -- b           // Pack two 32-bit values
32xy   | b -- x y           // Unpack two 32-bit values
```

### System Status

#### `vaempty | -- count`
Returns the number of free animation slots.

## Easing Functions

The system supports 16 different easing functions (0-15) from the Penner easing library:

- `0` - Linear
- `1` - Ease In Quad
- `2` - Ease Out Quad  
- `3` - Ease In/Out Quad
- `4` - Ease In Cubic
- `5` - Ease Out Cubic
- `6` - Ease In/Out Cubic
- `7` - Ease In Quart
- `8` - Ease Out Quart
- `9` - Ease In/Out Quart
- `10` - Ease In Quint
- `11` - Ease Out Quint
- `12` - Ease In/Out Quint
- `13` - Ease In Sine
- `14` - Ease Out Sine
- `15` - Ease In/Out Sine

## Memory Management

The system uses pre-allocated memory pools:
- **Timeline**: Stores scheduled animations in chronological order
- **Variable Pool**: Stores animation parameters and target variables
- Memory is reused automatically as animations complete

## Performance Characteristics

### Advantages
- **Fixed Memory**: No dynamic allocation during runtime
- **Sorted Timeline**: Efficient processing of time-based events
- **Batch Processing**: All animations updated in single pass
- **Hardware Friendly**: Optimized for real-time applications

### Limitations
- **Fixed Pool Size**: Maximum concurrent animations set at initialization
- **Memory Overhead**: Pre-allocates full pool even if unused

## Complete Example

```r3
| Initialize animation system
100 vaini

| Variables to animate
#player-x 100
#player-y 100
#player-color $ffffff
#ui-alpha 0

:setup-animations
    | Move player from (100,100) to (300,200) over 2 seconds with ease-out
    100 200 xy32 300 200 xy32 2 2.0 0.5 +vxyanim
    
    | Fade in UI over 1 second
    'ui-alpha 0 255 1 1.0 0 +vanim
    
    | Change player color from white to red over 3 seconds
    'player-color $ffffff $ff0000 3 3.0 1.0 +vcolanim
    
    | Execute sound effect at 1.5 seconds
    'playsound 1.5 +vexe ;

:main-loop
    cls
    vupdate          // Update all animations
    
    | Use animated values for rendering
    player-color SDLRenderer SDL_SetDrawColor
    player-x player-y 32 32 fillrect
    
    | Continue loop
    'main-loop onkey ;

| Start the animation system
vareset
setup-animations
main-loop
```

## Best Practices

1. **Initialize Once**: Call `vaini` only once at program startup
2. **Regular Updates**: Call `vupdate` once per frame
3. **Pool Management**: Monitor `vaempty` to avoid exceeding animation limits
4. **Time Coordination**: Use consistent time units (seconds) for all animations
5. **Memory Efficiency**: Reset system with `vareset` when changing scenes

This animation system provides a powerful foundation for creating smooth, time-based animations in R3 applications with minimal performance overhead.