# R3Forth Penner Library (penner.r3)

A comprehensive easing function library for R3Forth implementing Robert Penner's classic animation equations, providing smooth interpolation curves for natural-looking animations and transitions.

## Overview

The Penner library provides 30 easing functions organized into 10 families, each with In, Out, and InOut variants. These functions transform linear time progression (0.0 to 1.0) into accelerated, decelerated, or complex motion curves.

**Key Features:**
- 30 easing functions (10 families × 3 variants)
- Fixed-point math for precision
- Normalized input/output (0.0 to 1.0)
- Optimized implementations
- Direct function calls or indexed access
- Catmull-Rom spline interpolation

**Dependencies:**
- `r3/lib/math.r3` - Fixed-point arithmetic

**Input/Output:** All functions take time `t` (0.0 to 1.0) and return interpolated value (typically 0.0 to 1.0, some may overshoot)

---

## Easing Function Families

### 1. Linear

- **`Lineal`** `( t -- t )` - No easing, constant speed
  - Simple linear interpolation
  - Returns input unchanged
  ```
  0.5 Lineal  | → 0.5 (no change)
  ```

---

### 2. Quadratic (Quad)

Gentle acceleration/deceleration using `t²` curve.

- **`Quad_In`** `( t -- t' )` - Accelerate from zero
  - Formula: `t²`
  - Starts slow, ends fast
  ```
  0.5 Quad_In  | → 0.25 (slower at start)
  ```

- **`Quad_Out`** `( t -- t' )` - Decelerate to zero
  - Formula: `1 - (1-t)²`
  - Starts fast, ends slow
  ```
  0.5 Quad_Out  | → 0.75 (faster at start)
  ```

- **`Quad_InOut`** `( t -- t' )` - Accelerate then decelerate
  - Combination of In and Out
  - Smooth S-curve

---

### 3. Cubic (Cub)

Medium acceleration/deceleration using `t³` curve.

- **`Cub_In`** `( t -- t' )` - Cubic acceleration
  - Formula: `t³`
  - Stronger than Quad_In

- **`Cub_Out`** `( t -- t' )` - Cubic deceleration
  - Formula: `1 + (t-1)³`

- **`Cub_InOut`** `( t -- t' )` - Cubic ease both ends

---

### 4. Quartic (Quar)

Strong acceleration/deceleration using `t⁴` curve.

- **`Quar_In`** `( t -- t' )` - Quartic acceleration
  - Formula: `t⁴`

- **`Quar_Out`** `( t -- t' )` - Quartic deceleration
  - Formula: `1 - (1-t)⁴`

- **`Quar_InOut`** `( t -- t' )` - Quartic ease both ends

---

### 5. Quintic (Quin)

Very strong acceleration/deceleration using `t⁵` curve.

- **`Quin_In`** `( t -- t' )` - Quintic acceleration
  - Formula: `t⁵`

- **`Quin_Out`** `( t -- t' )` - Quintic deceleration
  - Formula: `1 + (t-1)⁵`

- **`Quin_InOut`** `( t -- t' )` - Quintic ease both ends

---

### 6. Sinusoidal (Sin)

Smooth acceleration/deceleration using sine curve.

- **`Sin_In`** `( t -- t' )` - Sinusoidal acceleration
  - Formula: `1 - cos(t × π/2)`
  - Very smooth curve

- **`Sin_Out`** `( t -- t' )` - Sinusoidal deceleration
  - Formula: `sin(t × π/2)`

- **`Sin_InOut`** `( t -- t' )` - Sinusoidal ease both ends
  - Formula: `(1 - cos(π × t)) / 2`

---

### 7. Exponential (Exp)

Dramatic acceleration/deceleration using exponential curve.

- **`Exp_In`** `( t -- t' )` - Exponential acceleration
  - Formula: `2^(10(t-1))`
  - Very slow start, explosive end

- **`Exp_Out`** `( t -- t' )` - Exponential deceleration
  - Formula: `1 - 2^(-10t)`
  - Fast start, very slow end

- **`Exp_InOut`** `( t -- t' )` - Exponential ease both ends

---

### 8. Circular (Cir)

Acceleration/deceleration based on circular arc.

- **`Cir_In`** `( t -- t' )` - Circular acceleration
  - Formula: `1 - √(1 - t²)`
  - Moderate acceleration

- **`Cir_Out`** `( t -- t' )` - Circular deceleration
  - Formula: `√(1 - (t-1)²)`

- **`Cir_InOut`** `( t -- t' )` - Circular ease both ends

---

### 9. Elastic (Ela)

Spring-like motion with overshoot and oscillation.

- **`Ela_In`** `( t -- t' )` - Elastic acceleration
  - Oscillates before reaching target
  - Spring pulls back then forward

- **`Ela_Out`** `( t -- t' )` - Elastic deceleration
  - Overshoots target and bounces back
  - Spring effect at end

- **`Ela_InOut`** `( t -- t' )` - Elastic ease both ends

---

### 10. Back (Bac)

Slight overshoot creating anticipation effect.

- **`Bac_In`** `( t -- t' )` - Back acceleration
  - Pulls back slightly before accelerating
  - Anticipation effect

- **`Bac_Out`** `( t -- t' )` - Back deceleration
  - Overshoots target slightly
  - Natural overshoot

- **`Bac_InOut`** `( t -- t' )` - Back ease both ends

---

### 11. Bounce (Bou)

Bouncing ball effect with decreasing amplitude.

- **`Bou_In`** `( t -- t' )` - Bounce acceleration
  - Bounces before settling

- **`Bou_Out`** `( t -- t' )` - Bounce deceleration
  - Bounces after reaching target
  - Natural drop and bounce

- **`Bou_InOut`** `( t -- t' )` - Bounce ease both ends

---

## Indexed Access

### Full Easing Table

- **`ease`** `( t index -- t' )` - Apply easing by index
  - `index`: 0-30 (see table below)
  - Returns eased value
  - Returns `t` unchanged if index is 0
  ```
  0.5 5 ease  | Apply Cub_Out to 0.5
  ```

**Easing Index Table:**

| Index | Function | Index | Function | Index | Function |
|-------|----------|-------|----------|-------|----------|
| 0 | None (pass through) | 10 | Quin_Out | 20 | Ela_Out |
| 1 | Quad_In | 11 | Quin_InOut | 21 | Ela_InOut |
| 2 | Quad_Out | 12 | Sin_In | 22 | Bac_In |
| 3 | Quad_InOut | 13 | Sin_Out | 23 | Bac_Out |
| 4 | Cub_In | 14 | Sin_InOut | 24 | Bac_InOut |
| 5 | Cub_Out | 15 | Exp_In | 25 | Bou_In |
| 6 | Cub_InOut | 16 | Exp_Out | 26 | Bou_Out |
| 7 | Quar_In | 17 | Exp_InOut | 27 | Bou_InOut |
| 8 | Quar_Out | 18 | Cir_In | | |
| 9 | Quar_InOut | 19 | Cir_Out | | |

### Compact Easing Table

- **`easem`** `( t index -- t' )` - Mini easing table (motion-focused)
  - Compact table with 15 motion-focused easings
  - Optimized for common animation needs
  - Index 0 returns `t` unchanged

**EaseM Index Table:**

| Index | Function | Index | Function | Index | Function |
|-------|----------|-------|----------|-------|----------|
| 0 | None | 5 | Exp_InOut | 10 | Ela_Out |
| 1 | Sin_In | 6 | Bac_In | 11 | Ela_InOut |
| 2 | Sin_Out | 7 | Bac_Out | 12 | Bou_In |
| 3 | Sin_InOut | 8 | Bac_InOut | 13 | Bou_Out |
| 4 | Exp_In | 9 | Ela_In | 14 | Bou_InOut |

---

## Spline Interpolation

### Catmull-Rom Spline

- **`catmullRom`** `( p0 p1 p2 p3 t -- v )` - Smooth curve through points
  - `p0, p1, p2, p3`: Four control points
  - `t`: Position on curve (0.0 to 1.0)
  - Returns interpolated value between `p1` and `p2`
  - `p0` and `p3` influence curve shape
  - Creates smooth curves through multiple points
  ```
  100 200 300 400 0.5 catmullRom  | Interpolate at t=0.5
  ```

**Properties:**
- Passes through `p1` at `t=0.0`
- Passes through `p2` at `t=1.0`
- `p0` affects curve entry
- `p3` affects curve exit
- Smooth continuous first derivative

---

## Usage Examples

### Basic Animation

```r3forth
#startTime
#duration 2.0  | 2 seconds

:animate | currentTime --
    currentTime startTime - 
    duration /. 1.0 clampmax  | Normalize to 0.0-1.0
    
    Quad_Out  | Apply easing
    
    | Use eased value
    100 * 200 +  | Scale: 200-300 range
    'xpos ! ;
```

### Comparing Easings

```r3forth
:testEasing | t --
    dup "Linear: " print . cr
    dup Quad_Out "Quad_Out: " print . cr
    dup Exp_Out "Exp_Out: " print . cr
    Ela_Out "Ela_Out: " print . cr ;

0.5 testEasing
```

### Smooth Movement

```r3forth
#startX 100
#endX 500
#progress 0.0

:updatePosition
    progress 1.0 >=? ( drop ; )
    
    progress 0.01 + 1.0 clampmax 'progress !
    
    | Calculate position with easing
    progress Sin_InOut  | Smooth start and stop
    endX startX - *. startX +
    'xpos ! ;
```

### Bouncing Ball

```r3forth
#ballY 100
#groundY 400

:animateBall | t --
    Bou_Out  | Bounce easing
    groundY ballY - *. ballY +
    'currentY ! ;
```

### UI Transitions

```r3forth
#menuX -200  | Off-screen
#targetX 0   | On-screen
#slideProgress 0.0

:slideInMenu
    slideProgress 1.0 >=? ( drop ; )
    
    0.02 + 'slideProgress !
    
    slideProgress Cub_Out  | Smooth deceleration
    targetX menuX - *. menuX +
    'menuPosition ! ;
```

### Camera Smooth Follow

```r3forth
#cameraX #playerX

:updateCamera
    playerX cameraX - | Distance
    0.1 *.  | Damping factor
    Sin_Out  | Smooth approach
    cameraX + 'cameraX ! ;
```

---

## Advanced Examples

### Chain Multiple Easings

```r3forth
:complexMove | t --
    0.5 <? (
        | First half: accelerate
        2* Quad_In 0.5 *. 
		; ) 
    | Second half: decelerate  
    0.5 - 2* Quad_Out 0.5 *. 0.5 +
    ;
```

### Oscillation

```r3forth
:oscillate | t frequency amplitude --
    rot pick2 *. sin *.  | amplitude * sin(t * frequency)
    ;

0.5 5.0 50.0 oscillate  | 5 cycles, ±50 amplitude
```

### Catmull-Rom Path

```r3forth
#pathPoints [ 0 100 300 400 600 500 800 ]

:followPath | t --
    | t from 0.0 to 1.0 over entire path
    dup 3.0 *. int.  | Which segment (0-2 for 4 points)
    3 >=? ( drop 2 0.99 ) | Clamp to last segment
    
    | Get 4 points for segment
    over 8 * 'pathPoints +
    dup @ over 8 + @ over 16 + @ over 24 + @
    
    | Get fractional t within segment
    pick4 3.0 *. int. - 
    
    catmullRom ;
```

### Elastic Spring

```r3forth
#velocity 0.0
#position 0.0
#target 100.0

:updateSpring | stiffness damping --
    target position -  | Displacement
    pick2 *.           | Apply stiffness
    velocity pick2 *.  | Damping
    - 'velocity !
    
    velocity 'position +! ;

0.1 0.9 updateSpring  | Soft spring
```

---

## Easing Characteristics

### Speed Comparison

| Type | Start Speed | Mid Speed | End Speed |
|------|-------------|-----------|-----------|
| In | Slow | Fast | Very Fast |
| Out | Very Fast | Fast | Slow |
| InOut | Slow | Very Fast | Slow |

### Overshoot Behavior

- **No overshoot**: Quad, Cub, Quar, Quin, Sin, Exp, Cir
- **Slight overshoot**: Bac (1-10%)
- **Strong overshoot**: Ela (20-30%)
- **Multiple bounces**: Bou (diminishing)

### Recommended Uses

| Easing | Best For |
|--------|----------|
| Quad_Out | General UI, buttons, menus |
| Cub_Out | Smooth motion, camera movement |
| Sin_InOut | Natural motion, breathing effects |
| Exp_Out | Dramatic entrances, attention grabbing |
| Ela_Out | Playful UI, game objects |
| Bac_Out | Natural overshoot, character movement |
| Bou_Out | Drop animations, impact effects |

---

## Visual Curves

```
Linear:        /           Quad_In:     _/
              /                        _/
             /                       _/

Quad_Out:    ___          Sin_InOut:  ___
            /                      __/   \__
           /                     _/         \

Exp_Out:   ___           Ela_Out:    /\/\___
          /                        _/
         /                       _/

Bac_Out:   _^            Bou_Out:    ___/\_/\
         _/  \                      _/
       _/     ‾‾                  _/
```

---

## Integration with VarAnim

```r3forth
^r3/util/varanim.r3
^r3/util/penner.r3

| Easing indices work directly with varanim
'xpos 0.0 100.0 5 2.0 0.0 +vanim  | Cub_Out easing
'ypos 0.0 200.0 13 1.5 0.5 +vanim  | Sin_Out easing
```

---

## Best Practices

### 1. Choose Appropriate Easing

```r3forth
| UI elements - quick and responsive
Quad_Out

| Natural motion - smooth
Sin_InOut

| Attention grabbing - dramatic
Exp_Out

| Playful - bouncy
Bou_Out
```

### 2. Normalize Time

```r3forth
| CORRECT - normalize to 0.0-1.0
elapsedTime duration /. 1.0 clampmax
Quad_Out

| WRONG - time not normalized
elapsedTime Quad_Out  | Undefined for values > 1.0
```

### 3. Clamp Results

```r3forth
| Some easings overshoot
t Ela_Out 
0.0 1.0 in? ( ; ) 1.0 clampmax  | Clamp if needed
```

---

## Performance Notes

- **Fast**: Quad, Cub, Quar, Quin (polynomial only)
- **Medium**: Sin, Cir (trigonometric)
- **Slow**: Exp (power function)
- **Complex**: Ela, Bac, Bou (multiple operations)

For performance-critical code, prefer polynomial easings (Quad, Cub).

---

## Notes

- **Input range**: 0.0 to 1.0 (fixed-point)
- **Output range**: Usually 0.0 to 1.0, some overshoot
- **Fixed-point**: Uses 48.16 format (1.0 = $10000)
- **Direct calls**: Faster than indexed access
- **Index 0**: Always returns input unchanged
- **Overshoot**: Elastic and Back go beyond 0-1 range
- **Smoothness**: InOut variants smoothest at both ends

## Limitations

- No custom easing curve creation
- Fixed overshoot amounts (not configurable)
- No reverse/mirror functions built-in
- Integer indices only (no interpolation between easings)

## Tips

1. **Experiment**: Try different easings to find the right feel
2. **Combine**: Chain easings for complex effects
3. **Scale**: Use result to interpolate between any values
4. **Preview**: Always test visually
5. **Document**: Note which easing was used for future tweaks

