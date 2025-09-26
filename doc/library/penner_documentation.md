# R3 Penner Easing Functions Library Documentation

## Overview

`penner.r3` implements the complete collection of Robert Penner's easing functions for smooth animation transitions. These mathematical curves provide natural-feeling motion by varying the rate of change over time, essential for creating polished animations in games and user interfaces.

## Dependencies
- `r3/lib/math.r3` - Mathematical operations including trigonometry, powers, and roots

## Easing Function Categories

### Linear
```r3
Lineal       | t -- t               // No easing (constant rate)
```

### Quadratic (t²)
```r3
Quad_In      | t -- eased_t         // Accelerating from zero
Quad_Out     | t -- eased_t         // Decelerating to zero  
Quad_InOut   | t -- eased_t         // Acceleration then deceleration
```

### Cubic (t³)
```r3
Cub_In       | t -- eased_t         // Stronger acceleration
Cub_Out      | t -- eased_t         // Stronger deceleration
Cub_InOut    | t -- eased_t         // Smooth acceleration/deceleration
```

### Quartic (t⁴)
```r3
Quar_In      | t -- eased_t         // Very strong acceleration
Quar_Out     | t -- eased_t         // Very strong deceleration
Quar_InOut   | t -- eased_t         // Sharp acceleration/deceleration curve
```

### Quintic (t⁵)
```r3
Quin_In      | t -- eased_t         // Extreme acceleration
Quin_Out     | t -- eased_t         // Extreme deceleration
Quin_InOut   | t -- eased_t         // Most dramatic acceleration/deceleration
```

### Sinusoidal
```r3
Sin_In       | t -- eased_t         // Gentle acceleration (sine curve)
Sin_Out      | t -- eased_t         // Gentle deceleration
Sin_InOut    | t -- eased_t         // Smooth S-curve transition
```

### Exponential
```r3
Exp_In       | t -- eased_t         // Exponential acceleration
Exp_Out      | t -- eased_t         // Exponential deceleration  
Exp_InOut    | t -- eased_t         // Combined exponential curve
```

### Circular
```r3
Cir_In       | t -- eased_t         // Circular arc acceleration
Cir_Out      | t -- eased_t         // Circular arc deceleration
Cir_InOut    | t -- eased_t         // Circular S-curve
```

### Elastic
```r3
Ela_In       | t -- eased_t         // Elastic snap-in effect
Ela_Out      | t -- eased_t         // Elastic overshoot effect
Ela_InOut    | t -- eased_t         // Elastic both directions
```

### Back (Overshoot)
```r3
Bac_In       | t -- eased_t         // Pulls back before moving forward
Bac_Out      | t -- eased_t         // Overshoots then settles
Bac_InOut    | t -- eased_t         // Back effect both directions
```

### Bounce
```r3
Bou_In       | t -- eased_t         // Bouncing acceleration
Bou_Out      | t -- eased_t         // Bouncing deceleration
Bou_InOut    | t -- eased_t         // Bouncing both directions
```

## Function Selection Systems

### Standard Easing Selection
```r3
ease         | t function_id -- eased_t
```

**Function IDs:**
- `1-3`: Quadratic (In, Out, InOut)
- `4-6`: Cubic
- `7-9`: Quartic  
- `10-12`: Quintic
- `13-15`: Sinusoidal
- `16-18`: Exponential
- `19-21`: Circular
- `22-24`: Elastic
- `25-27`: Back
- `28-30`: Bounce

### Compact Easing Selection
```r3
easem        | t function_id -- eased_t
```
Uses a more compact function table with fewer options.

## Advanced Functions

### Catmull-Rom Interpolation
```r3
catmullRom   | p0 p1 p2 p3 t -- interpolated_value
```
Smooth interpolation through control points, useful for complex animation paths.

## Complete Usage Examples

### Basic Animation
```r3
#animation-time 0.0
#start-position 100.0
#end-position 400.0
#current-position 100.0

:update-animation | dt --
    'animation-time +!
    animation-time 2.0 >=? ( 2.0 'animation-time ! )
    
    animation-time 2.0 /.           // Normalize to 0-1
    3 ease                          // Apply Quad_Out easing
    
    end-position start-position -   // Calculate range
    *. start-position +             // Apply to range
    'current-position ! ;

| Usage:
0.016 update-animation              // 60 FPS update
```

### Multi-Phase Animation
```r3
#phase 0
#phase-time 0.0

:complex-animation | dt --
    'phase-time +!
    
    phase
    0 =? ( | Phase 1: Ease in
        phase-time 1.0 >=? ( 1 'phase ! 0.0 'phase-time ! )
        phase-time 1 ease               // Quad_In
    )
    1 =? ( | Phase 2: Constant speed  
        phase-time 2.0 >=? ( 2 'phase ! 0.0 'phase-time ! )
        phase-time 2.0 /.               // Linear
    )
    2 =? ( | Phase 3: Bounce out
        phase-time 1.0 >=? ( 0 'phase ! 0.0 'phase-time ! )
        phase-time 30 ease              // Bou_Out
    )
    
    | Apply to object position
    300.0 *. 100.0 + 'object-x ! ;
```

### UI Element Transitions
```r3
#menu-state 0      // 0=hidden, 1=showing, 2=visible, 3=hiding
#menu-progress 0.0
#menu-x -200       // Off-screen position

:update-menu | dt --
    menu-state
    1 =? ( | Showing
        menu-progress dt 3.0 */ +  'menu-progress !
        menu-progress 1.0 >=? ( 2 'menu-state ! 1.0 'menu-progress ! )
        menu-progress 27 ease      // Bac_Out for overshoot
        200.0 *. -200.0 + 'menu-x !
    )
    3 =? ( | Hiding  
        menu-progress dt 2.0 */ - 'menu-progress !
        menu-progress 0.0 <=? ( 0 'menu-state ! 0.0 'menu-progress ! )
        menu-progress 6 ease       // Cub_Out for smooth exit
        200.0 *. -200.0 + 'menu-x !
    ) ;

:show-menu 1 'menu-state ! 0.0 'menu-progress ! ;
:hide-menu 3 'menu-state ! 1.0 'menu-progress ! ;
```

### Particle Effects with Easing
```r3
#particles * 100   // Array of particles
#particle-count 0

:create-particle | x y life --
    particle-count 4 << 'particles +  // Get particle slot
    !+ !+ !+                          // Store x, y, life
    0.0 over !                        // Initial scale = 0
    1 'particle-count +! ;

:update-particles | dt --
    0 ( particle-count <?
        dup 4 << 'particles +         // Get particle
        dup 8 + @+ dt - dup          // Update life
        0.0 <=? ( | Particle died
            particle-count 1- 4 << 'particles +  // Last particle
            pick2 4 << 'particles +   // Current slot
            4 move                    // Move last to current
            -1 'particle-count +!
            drop 
        ; )
        over 8 + !                    // Store new life
        
        | Update scale with easing
        1.0 over /.                   // Normalize life (1.0 to 0.0)
        22 ease                       // Ela_In for dramatic effect
        over 12 + !                   // Store scale
        
        1+
    ) drop ;

:draw-particles
    0 ( particle-count <?
        dup 4 << 'particles +
        @+ @+ @+ @                    // x y life scale
        | Draw particle with scale
        rot rot                       // scale x y
        pick2 16 *. int. dup         // Calculate pixel size
        fillcircle
        drop
        1+
    ) drop ;
```

### Camera Smooth Following
```r3
#camera-x 0.0
#camera-y 0.0  
#target-x 0.0
#target-y 0.0
#camera-speed 2.0

:update-camera | dt --
    | Calculate distance to target
    target-x camera-x -
    target-y camera-y -
    
    | Calculate smooth movement
    over abs over abs max            // Max distance
    camera-speed dt *. /.            // Progress ratio
    1.0 min                          // Clamp to 1.0
    15 ease                          // Sin_InOut for smooth following
    
    | Apply movement
    dup rot *. 'camera-x +!
    *. 'camera-y +! ;

:set-camera-target | x y --
    'target-y ! 'target-x ! ;
```

### Advanced Spline Animation
```r3
#control-points [ 0.0 100.0 200.0 100.0 300.0 50.0 400.0 200.0 ]
#spline-time 0.0

:animate-along-spline | dt --
    spline-time dt + 4.0 mod 'spline-time !  // 4-second loop
    
    spline-time floor int.           // Current segment
    spline-time frac                 // Local t
    
    | Get four control points
    dup 2 << 'control-points + @    // p0
    over 1+ 2 << 'control-points + @ // p1
    over 2 + 2 << 'control-points + @ // p2
    over 3 + 2 << 'control-points + @ // p3
    
    rot catmullRom                   // Smooth interpolation
    'sprite-x ! ;
```

## Easing Function Characteristics

### Speed Curves
- **In**: Slow start, fast end
- **Out**: Fast start, slow end  
- **InOut**: Slow start, fast middle, slow end

### Visual Effects
- **Quadratic**: Subtle, natural feeling
- **Cubic**: More pronounced curves
- **Sine**: Very smooth, organic
- **Exponential**: Dramatic acceleration/deceleration
- **Elastic**: Springy, playful effects
- **Back**: Anticipation and overshoot
- **Bounce**: Energetic, fun animations

## Performance Considerations

### Function Complexity
- **Simple**: Quadratic, Cubic (polynomial math)
- **Moderate**: Sine, Circular (trigonometry)  
- **Complex**: Exponential, Elastic (power functions)

### Optimization Tips
- **Pre-calculate**: For repeated animations, pre-calculate easing curves
- **Table lookup**: Store commonly used easing values in tables
- **Function selection**: Use simpler functions when subtle differences aren't noticeable

## Integration Patterns

### With Animation System
```r3
:create-smooth-animation | start end duration easing --
    'animation-end ! 'animation-start !
    'animation-duration ! 'animation-easing !
    0.0 'animation-time !
    1 'animation-active ! ;

:update-animation
    animation-active 0? ( ; )
    animation-time frame-time + 'animation-time !
    
    animation-time animation-duration >=? (
        0 'animation-active !
        animation-end 'current-value !
        ;
    )
    
    animation-time animation-duration /.
    animation-easing ease
    animation-end animation-start - *.
    animation-start + 'current-value ! ;
```

### With User Interface
```r3
:fade-in-widget | widget --
    0.0 1.0 0.5 15 create-smooth-animation  // Sin_InOut over 0.5s
    'widget-alpha bind-animation ;

:slide-in-menu | menu --
    -200.0 0.0 0.8 27 create-smooth-animation  // Bac_Out
    'menu-x bind-animation ;
```

## Best Practices

1. **Choose Appropriate Functions**: Match easing to the desired feel
2. **Consistent Timing**: Use similar durations for related animations
3. **Layer Effects**: Combine different easing functions for complex motion
4. **Performance Awareness**: Use simpler functions for many simultaneous animations
5. **User Experience**: Consider accessibility - some users may prefer reduced motion

This easing library provides the mathematical foundation for creating smooth, professional-quality animations that enhance user experience through natural-feeling motion.