# R3 Vector Mathematics Libraries Documentation

## Overview

The R3 vector mathematics libraries (`vec2.r3` and `vec3.r3`) provide comprehensive support for 2D and 3D vector operations essential for graphics programming, physics simulations, and geometric calculations. These libraries implement efficient fixed-point arithmetic operations optimized for real-time applications.

## Dependencies
- `r3/lib/math.r3` - Fixed-point arithmetic and trigonometric functions

## 2D Vector Operations (`vec2.r3`)

### Vector Structure
2D vectors are stored as consecutive memory locations:
```r3
#my-vector 0.0 0.0        // x-component, y-component (64-bit each)
```

### Basic Operations

#### Assignment and Copying
```r3
v2=       | 'v1 'v2 --    // Copy v2 to v1 (v1 = v2)
```

#### Arithmetic Operations
```r3
v2+       | 'v1 'v2 --    // Add vectors (v1 = v1 + v2)
v2-       | 'v1 'v2 --    // Subtract vectors (v1 = v1 - v2)
v2+*      | scalar 'v1 'v2 -- // Scaled addition (v1 = v1 + v2 × scalar)
v2-*      | scalar 'v1 'v2 -- // Scaled subtraction (v1 = v1 - v2 × scalar)
```

#### Scalar Operations
```r3
v2*       | 'v n --       // Scale vector (v = v × n)
v2/       | 'v n --       // Divide vector (v = v ÷ n)
```

### Vector Properties

#### Length and Normalization
```r3
v2len     | 'v -- length // Calculate vector magnitude
v2nor     | 'v --         // Normalize vector to unit length
v2lim     | 'v limit --   // Limit vector length to maximum
```

#### Geometric Operations
```r3
v2dot     | 'v1 'v2 -- dot    // Dot product (scalar result)
v2perp    | 'v1 'v2 --        // Set v2 perpendicular to v1
v2rot     | 'v angle --       // Rotate vector by angle (bangles)
```

### 2D Vector Usage Examples

#### Basic Vector Math
```r3
#velocity 5.0 3.0         // Moving right-up
#acceleration -0.1 -0.2   // Gravity-like deceleration
#position 100.0 200.0     // Starting position

:update-physics | dt --
    | Apply acceleration to velocity
    dt 'velocity 'acceleration v2+*
    
    | Apply velocity to position  
    dt 'position 'velocity v2+*
    
    | Limit maximum speed to 10.0
    'velocity 10.0 v2lim ;
```

#### Collision Detection
```r3
#ball1-pos 100.0 150.0
#ball2-pos 200.0 180.0
#separation 0.0 0.0

:check-collision | radius1 radius2 -- colliding?
    'separation 'ball2-pos v2=    // separation = ball2-pos
    'separation 'ball1-pos v2-    // separation = ball2-pos - ball1-pos
    
    separation v2len              // Get distance
    rot +                         // total-radius = radius1 + radius2
    <? ( 1 ; ) 0 ;               // Return true if distance < total-radius

| Usage:
25.0 30.0 check-collision ? ( handle-collision )
```

#### Vector Reflection
```r3
#incident-ray -1.0 -1.0   // Ray hitting surface
#normal 0.0 1.0           // Surface normal (pointing up)
#reflected 0.0 0.0        // Result vector

:reflect-vector
    | reflected = incident - 2 × (incident · normal) × normal
    'incident-ray 'normal v2dot  // dot product
    2.0 *.                       // 2 × dot
    'reflected 'normal v2=       // reflected = normal
    dup 'reflected swap v2*      // reflected = normal × (2 × dot)
    'reflected 'incident-ray v2- ; // reflected = incident - (2 × dot × normal)
```

## 3D Vector Operations (`vec3.r3`)

### Vector Structure
3D vectors use three consecutive memory locations:
```r3
#my-3d-vector 0.0 0.0 0.0 // x, y, z components
```

### Basic 3D Operations

#### Assignment and Properties
```r3
v3=       | 'v1 'v2 --        // Copy v2 to v1
v3len     | 'v -- length      // Calculate 3D vector magnitude  
v3nor     | 'v --             // Normalize to unit length
```

#### Arithmetic Operations
```r3
v3+       | 'v1 'v2 --        // Add vectors (v1 = v1 + v2)
v3-       | 'v1 'v2 --        // Subtract vectors (v1 = v1 - v2)
v3*       | 'v scalar --      // Scale vector (v = v × scalar)
```

#### Advanced 3D Operations
```r3
v3ddot    | 'v1 'v2 -- dot    // Dot product
v3vec     | 'v1 'v2 --        // Cross product (v1 = v1 × v2)
```

### Utility Functions
```r3
normInt2Fix | x y z -- xf yf zf  // Normalize integer coordinates to fixed-point
normFix     | x y z -- x y z     // Normalize fixed-point coordinates
```

### 3D Vector Usage Examples

#### 3D Physics
```r3
#object-position 0.0 0.0 0.0
#object-velocity 5.0 2.0 1.0
#gravity 0.0 -9.8 0.0

:update-3d-object | dt --
    | Apply gravity to velocity
    dt 'object-velocity 'gravity v3+*
    
    | Update position
    dt 'object-position 'object-velocity v3+* ;
```

#### Surface Normal Calculation
```r3
#triangle-a 0.0 0.0 0.0
#triangle-b 1.0 0.0 0.0  
#triangle-c 0.0 1.0 0.0
#edge1 0.0 0.0 0.0
#edge2 0.0 0.0 0.0
#normal 0.0 0.0 0.0

:calculate-triangle-normal
    'edge1 'triangle-b v3=      // edge1 = b
    'edge1 'triangle-a v3-      // edge1 = b - a
    
    'edge2 'triangle-c v3=      // edge2 = c
    'edge2 'triangle-a v3-      // edge2 = c - a
    
    'normal 'edge1 v3=          // normal = edge1
    'normal 'edge2 v3vec        // normal = edge1 × edge2
    'normal v3nor ;             // Normalize result
```

#### 3D Rotation (Rodrigues' Formula)
```r3
#rotation-axis 0.0 1.0 0.0    // Y-axis rotation
#vector-to-rotate 1.0 0.0 0.0 // X-axis vector
#temp1 0.0 0.0 0.0
#temp2 0.0 0.0 0.0

:rotate-around-axis | angle --
    | v_rot = v×cos(θ) + (k×v)×sin(θ) + k×(k·v)×(1-cos(θ))
    dup cos >r sin >r           // Store cos and sin
    
    'temp1 'rotation-axis v3=   
    'temp1 'vector-to-rotate v3vec  // temp1 = axis × vector
    temp1 r> v3*                    // temp1 = (axis × vector) × sin(θ)
    
    'rotation-axis 'vector-to-rotate v3ddot  // dot product
    1.0 r@ - *.                     // (1 - cos(θ)) × dot
    'temp2 'rotation-axis v3=        // temp2 = axis  
    temp2 over v3*                   // temp2 = axis × dot × (1-cos(θ))
    
    vector-to-rotate r> v3*          // vector × cos(θ)
    'vector-to-rotate 'temp1 v3+     // + (axis × vector) × sin(θ)  
    'vector-to-rotate 'temp2 v3+ ;   // + axis × dot × (1-cos(θ))
```

## Quaternion Operations (`vec3.r3`)

### Quaternion Structure
Quaternions use four components: x, y, z, w
```r3
#my-quaternion 0.0 0.0 0.0 1.0  // x, y, z, w (identity quaternion)
```

### Quaternion Operations
```r3
q4=       | 'q1 'q2 --        // Copy quaternion
q4W       | 'q 'dest --       // Calculate W component from XYZ
q4dot     | 'q1 'q2 -- dot    // Quaternion dot product
q4inv     | 'q1 'q2 --        // Quaternion inverse
q4conj    | 'q1 'q2 --        // Quaternion conjugate
q4len     | 'q -- length      // Quaternion magnitude
q4nor     | 'q --             // Normalize quaternion
```

### Quaternion Usage Example

#### 3D Rotation with Quaternions
```r3
#rotation-quat 0.0 0.0 0.0 1.0  // Identity rotation
#temp-quat 0.0 0.0 0.0 0.0

:create-rotation-quaternion | x y z angle --
    2/ dup sin >r cos          // half-angle, sin(half), cos(half)
    'rotation-quat 12 + !      // Store w component
    r@ pick3 *. 'rotation-quat !     // x × sin(half-angle)
    r@ pick2 *. 'rotation-quat 4 + ! // y × sin(half-angle)  
    r> *. 'rotation-quat 8 + ! ;     // z × sin(half-angle)

| Create 45-degree rotation around Y-axis
0.0 1.0 0.0 $2000 create-rotation-quaternion  // 45° in bangles
```

## Performance Optimization

### Memory Layout
- **Contiguous Storage**: Vectors stored in consecutive memory for cache efficiency
- **In-Place Operations**: Most operations modify vectors in-place to reduce copying
- **Fixed-Point Math**: Consistent use of fixed-point arithmetic for predictable performance

### Common Optimizations
```r3
| Fast 2D distance comparison (avoids sqrt)
:distance-squared | 'v1 'v2 -- dist²
    'temp-vector 'v2 v2=
    'temp-vector 'v1 v2-
    temp-vector @ dup *.
    temp-vector 8 + @ dup *. + ;

| Fast normalization check
:is-unit-vector | 'v -- flag
    v2len 1.0 - abs 0.001 <? ( 1 ; ) 0 ;
```

## Integration Patterns

### With Animation System
```r3
:animate-vector | 'start 'end 'current t --
    rot rot over v2=              // current = start
    rot over v2-                  // end = end - start (delta)  
    rot dup 'temp-vector v2= t v2* // temp = delta × t
    swap 'temp-vector v2+ ;       // current = start + delta × t
```

### With Physics Engine
```r3
:apply-force | 'force 'velocity mass dt --
    rot pick2 /. v2*              // force = force / mass
    rot 'temp-vector v2= dt v2*   // temp = force × dt
    swap 'temp-vector v2+ ;       // velocity += force × dt / mass
```

## Best Practices

1. **Memory Management**: Pre-allocate temporary vectors for intermediate calculations
2. **Precision**: Use appropriate fixed-point precision for your application's needs
3. **Normalization**: Check vector lengths before normalization to avoid division by zero
4. **Performance**: Use squared distances for comparisons when possible
5. **Quaternions**: Prefer quaternions over Euler angles for complex 3D rotations

These vector mathematics libraries provide the essential foundation for any graphics, physics, or geometric computation in R3, maintaining the system's commitment to predictable performance through fixed-point arithmetic and efficient memory usage patterns.