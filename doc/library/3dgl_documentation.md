# R3 3D OpenGL Mathematics Library Documentation

## Overview

`3dgl.r3` provides comprehensive 3D matrix mathematics specifically optimized for OpenGL rendering. It implements a complete matrix stack system with transformations, projections, and conversions between R3's fixed-point format and OpenGL's floating-point requirements. This library serves as the bridge between R3's deterministic math system and modern GPU rendering.

## Dependencies
- `r3/lib/vec3.r3` - 3D vector operations and quaternion math

## Matrix Stack System

### Global State
```r3
#mati             // Identity matrix template
#mats * 2560      // Matrix stack (20 matrices × 128 bytes)
#mat>             // Current matrix pointer
```

### Stack Management
```r3
matini      | --              // Initialize matrix stack with identity
matinim     | 'matrix --      // Initialize with custom matrix
mpush       | --              // Push current matrix to stack
mpushi      | --              // Push identity matrix to stack
mpop        | --              // Pop matrix from stack
nmpop       | count --        // Pop multiple matrices
```

## Matrix Format Conversion

### Fixed-Point to Float Conversion
```r3
getfmat     | -- float_matrix     // Convert current matrix to float format
gettfmat    | -- float_matrix     // Convert and transpose to float format
mcpyf       | float_matrix --     // Copy float matrix to current
mcpyft      | float_matrix --     // Copy and transpose float matrix
midf        | float_matrix --     // Copy float matrix to identity
```

These functions handle the conversion between R3's 16.16 fixed-point format and OpenGL's 32-bit floating-point requirements, essential for GPU shader uniforms.

## Projection Matrices

### Perspective Projection
```r3
mperspective | near far cotangent aspect --  // Create perspective matrix
```

Implements the standard perspective projection used in 3D graphics:
- **near/far**: Clipping plane distances
- **cotangent**: Field of view control (cot(fov/2))
- **aspect**: Screen aspect ratio (width/height)

### Orthographic Projection
```r3
mortho      | right left top bottom far near --  // Create orthographic matrix
```

Creates parallel projection without perspective distortion, useful for UI elements and technical drawings.

## View Matrix

### Camera Setup
```r3
mlookat     | eye_pos target_pos up_vector --  // Create view matrix
```

Implements the classic "look-at" camera system:
- **eye_pos**: Camera position in world space
- **target_pos**: Point the camera looks at
- **up_vector**: Camera's up direction (usually Y-axis)

## Transformation Functions

### Translation
```r3
mtran       | x y z --        // Apply translation
mtranx      | x --            // Translate along X-axis only
mtrany      | y --            // Translate along Y-axis only
mtranz      | z --            // Translate along Z-axis only
```

### Rotation
```r3
mrotx       | angle --        // Rotate around X-axis
mroty       | angle --        // Rotate around Y-axis
mrotz       | angle --        // Rotate around Z-axis
mrotxyz     | x y z --        // Combined rotation (post-multiply)
mrotxyzi    | x y z --        // Combined rotation (pre-multiply)
```

### Scaling
```r3
mscale      | x y z --        // Non-uniform scaling
mscalei     | x y z --        // Inverse scaling
muscalei    | scale --        // Uniform inverse scaling
```

## Direct Matrix Creation

### Position and Rotation
```r3
mtra        | x y z --            // Create translation matrix
mrot        | rx ry rz --         // Create rotation matrix
mpos        | x y z --            // Set position in current matrix
mrpos       | packed_rot x y z -- // Position with packed rotation
```

### Matrix Operations
```r3
mcpy        | 'source_matrix --   // Copy matrix to current
m*          | --                  // Multiply top two matrices
mm*         | 'matrix --          // Multiply current with given matrix
mmi*        | 'matrix --          // Pre-multiply with given matrix
```

## Coordinate Transformations

### 3D Point Transformation
```r3
transform   | x y z -- x' y' z'   // Transform point by current matrix
transformr  | x y z -- x' y' z'   // Transform by rotation only
ztransform  | x y z -- z'         // Get transformed Z coordinate only
```

### Optimization Functions
```r3
oztransform    | -- z             // Get origin Z after transformation
oxyztransform  | -- x y z         // Get transformed origin coordinates
```

## Advanced Features

### Matrix Inversion
```r3
matinv      | --                  // Invert current matrix
```

Computes the inverse of the current 4×4 matrix using optimized algorithms suitable for transformation matrices.

### Quaternion Integration
```r3
matqua      | 'quaternion --      // Create matrix from quaternion
```

Converts quaternion rotation to transformation matrix, providing smooth interpolation capabilities.

### Packed Data Formats

#### Rotation Packing
```r3
packrota    | rx ry rz -- packed_rotation    // Pack 3 rotations into 48 bits
+rota       | rot_a rot_b -- combined_rot    // Add packed rotations
```

#### Velocity Packing
```r3
pack21      | vx vy vz -- packed_velocity    // Pack 3 velocities into 63 bits
+p21        | vel_a vel_b -- combined_vel    // Add packed velocities
```

## Complete Usage Examples

### 3D Scene Setup
```r3
:setup-3d-scene
    matini                              // Initialize matrix stack
    
    | Setup perspective projection
    0.1 100.0                          // Near/far planes
    45.0 deg cos 45.0 deg sin /.       // Cotangent of 45° FOV
    800.0 600.0 /.                     // Aspect ratio
    mperspective
    
    | Setup camera
    0.0 5.0 10.0                       // Eye position
    0.0 0.0 0.0                        // Look at origin  
    0.0 1.0 0.0                        // Up vector
    mlookat ;

:render-object | x y z rx ry rz --
    mpush                              // Save current matrix
    
    | Apply object transformation
    rot rot rot mtran                  // Translation
    rot rot rot mrotxyz                // Rotation
    
    | Send matrix to GPU
    getfmat                            // Convert to float format
    mvp-uniform-location 1 0 rot glUniformMatrix4fv
    
    | Render object geometry...
    draw-object-geometry
    
    mpop ;                             // Restore matrix
```

### Camera System
```r3
#camera-pos 0.0 2.0 5.0
#camera-target 0.0 0.0 0.0
#camera-up 0.0 1.0 0.0

:update-camera | dt --
    | Handle camera input
    sdlkey
    >w< =? ( 0.0 0.0 -1.0 camera-speed dt *. v3* 'camera-pos v3+ )
    >s< =? ( 0.0 0.0 1.0 camera-speed dt *. v3* 'camera-pos v3+ )
    >a< =? ( -1.0 0.0 0.0 camera-speed dt *. v3* 'camera-pos v3+ )
    >d< =? ( 1.0 0.0 0.0 camera-speed dt *. v3* 'camera-pos v3+ )
    drop ;

:setup-view-matrix
    'camera-pos 'camera-target 'camera-up mlookat ;
```

### Hierarchical Transformations
```r3
:render-robot
    mpush                              // Save world matrix
    robot-x robot-y robot-z mtran      // Robot position
    robot-rotation mrotxyz             // Robot orientation
    
    | Render body
    render-robot-body
    
    | Left arm
    mpush
    -1.5 0.5 0.0 mtran                // Shoulder offset
    left-arm-rotation mrotxyz          // Arm rotation
    render-arm
    mpop
    
    | Right arm  
    mpush
    1.5 0.5 0.0 mtran                 // Shoulder offset
    right-arm-rotation mrotxyz         // Arm rotation
    render-arm
    mpop
    
    mpop ;                             // Restore world matrix
```

### Animation Integration
```r3
#bone-matrices * 2048                  // Storage for bone matrices
#animation-time 0.0

:update-skeletal-animation | dt --
    dt 'animation-time +!
    
    | Calculate bone transformations
    0 ( bone-count <?
        | Calculate bone position and rotation based on animation-time
        dup calculate-bone-transform   // Returns x,y,z,rx,ry,rz
        
        | Create bone matrix
        mtra mrotxyz                   // Create transformation
        getfmat                        // Convert to float
        over 16 << 'bone-matrices + 16 move  // Store bone matrix
        
        1+
    ) drop ;

:render-skinned-mesh
    | Upload bone matrices to shader
    bone-array-uniform-location bone-count 0 'bone-matrices glUniformMatrix4fv
    
    | Render skinned geometry
    draw-skinned-mesh ;
```

### Instanced Rendering
```r3
#instance-matrices * 16384             // 1024 instances × 16 floats
#instance-count 0

:add-instance | x y z rx ry rz sx sy sz --
    instance-count 16 << 'instance-matrices +  // Get storage location
    
    | Build transformation matrix
    mpush mtra mrotxyz rot rot rot mscale
    getfmat swap 16 move               // Store float matrix
    mpop
    
    1 'instance-count +! ;

:render-instances
    | Upload instance matrices
    instance-matrix-uniform-location instance-count 0 'instance-matrices glUniformMatrix4fv
    
    | Draw instanced geometry
    GL_TRIANGLES vertex-count GL_UNSIGNED_SHORT 0 instance-count glDrawElementsInstanced ;
```

## Performance Optimization

### Matrix Stack Efficiency
- **Pre-allocation**: Fixed-size stack prevents dynamic allocation
- **Minimal copying**: Operations work on stack-resident matrices
- **Efficient conversion**: Optimized fixed-to-float conversion

### GPU Integration
- **Batch uploads**: Upload multiple matrices in single call
- **Format optimization**: Direct float format for GPU consumption
- **Memory alignment**: Proper alignment for GPU buffer objects

## Integration with OpenGL Pipeline

### Shader Uniforms
```glsl
// Vertex shader
uniform mat4 mvp_matrix;
uniform mat4 model_matrix;
uniform mat4 view_matrix;
uniform mat4 projection_matrix;

void main() {
    gl_Position = mvp_matrix * vec4(position, 1.0);
}
```

### Matrix Upload
```r3
:upload-matrices
    | Model matrix
    getfmat model-uniform-location 1 0 rot glUniformMatrix4fv
    
    | View matrix (camera)
    mpush setup-view-matrix
    getfmat view-uniform-location 1 0 rot glUniformMatrix4fv
    mpop
    
    | Combined MVP
    m* getfmat mvp-uniform-location 1 0 rot glUniformMatrix4fv ;
```

This 3D mathematics library provides the essential bridge between R3's deterministic fixed-point calculations and modern GPU rendering pipelines, maintaining precision while enabling hardware-accelerated 3D graphics.