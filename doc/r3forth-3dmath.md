
# 3dgl.r3 Matrix Stack System 

## Overview

The `3dgl.r3` library implements a **matrix stack** — a LIFO stack of 4×4 matrices stored in a fixed-size buffer. This is essential for hierarchical transformations (skeletal animation, scene graphs) where child objects need transformations relative to their parent.

---

## Matrix Stack Architecture

### Memory Layout

```
#mats * 2560     | 20 matrices × 128 bytes (16 floats × 8 bytes)
#mati            | Identity matrix (template)

Matrix Stack (grows upward):
┌─────────────────┐
│ Matrix 19       │ ← mat> + 2432
├─────────────────┤
│ ...             │
├─────────────────┤
│ Matrix 1        │ ← mat> + 128
├─────────────────┤
│ Matrix 0        │ ← mat> (current matrix pointer)
└─────────────────┘
```

**Each matrix:** 16 fixed-point (48.16) values = 128 bytes

**Stack size:** 20 matrices (enough for typical skeletal hierarchies)

---

## Core Words

### Matrix Pointer Management

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `matini` | `--` | Reset pointer to matrix 0, copy identity to it |
| `mpush` | `--` | Push current matrix: copy it to next slot, move pointer up |
| `mpop` | `--` | Pop current matrix: move pointer down (overwrites popped) |
| `mpushi` | `--` | Push identity matrix to next slot (instead of copying current) |

### Implementation Analysis

From `3dgl.r3`:

```forth
::matini
    'mats dup 'mat> ! 'mati 16 move ;
    | 'mat> = pointer to current matrix
    | Copies 16 qwords from 'mati to 'mats

::mpush
    mat> dup 128 + dup 'mat> ! swap 16 move ;
    | 1. mat> = address of current matrix
    | 2. dup 128 + = address of next matrix slot
    | 3. swap 16 move = copy current to next
    | 4. 'mat> ! = move pointer to next

::mpop
    mat> |'mats =? ( drop ; )
    128 - 'mat> ! ;
    | Guard: cannot pop below base
    | Subtract 128 (matrix size) from pointer
```

**Key observation:** `mpush` **copies** the current matrix to the next slot. This preserves parent transformations for children.

---

## Stack Visualization

### Push/Pop Mechanics

```
Initial state (matini):
┌─────────────┐
│ Matrix 0    │ ← mat> (identity)
│ (empty)     │
│ (empty)     │
└─────────────┘

After mpush:
┌─────────────┐
│ Matrix 0    │ (identity, preserved)
│ Matrix 1    │ ← mat> (copy of identity)
│ (empty)     │
└─────────────┘

After modifying current (e.g., mrotx):
┌─────────────┐
│ Matrix 0    │ (identity)
│ Matrix 1    │ ← mat> (rotated)
│ (empty)     │
└─────────────┘

After mpush again:
┌─────────────┐
│ Matrix 0    │ (identity)
│ Matrix 1    │ (rotated, preserved)
│ Matrix 2    │ ← mat> (copy of rotated)
└─────────────┘
```

---

## Matrix Operations and Their Stack Effects

### Construction Words (replace current matrix)

These words **overwrite** the current matrix:

| Word | Stack Effect | Implementation |
|------|--------------|----------------|
| `mrot` | `rx ry rz --` | Replace current with rotation matrix |
| `mtra` | `x y z --` | Replace current with translation matrix |
| `mati` | `--` | Replace current with identity (via `'mati 16 move`) |

**From source:**
```forth
::mrot | rx ry rz --
    mat> dup >a 'mati 16 move   | Start with identity
    sincos ...                  | Then fill rotation values
    ;                            | Current matrix now = rotation
```

### Transformation Words (multiply with current)

These words **modify** the current matrix by multiplication:

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `mrotx` | `rx --` | Current = Current × RotX |
| `mroty` | `ry --` | Current = Current × RotY |
| `mrotz` | `rz --` | Current = Current × RotZ |
| `mtran` | `x y z --` | Current = Current × Translation |
| `mscale` | `x y z --` | Current = Current × Scale |
| `m*` | `--` | Current = Current × Previous (pop previous) |

**From source (mrotx):**
```forth
::mrotx | rx --
    mat> dup >a 128 + >b      | a = current, b = next (temp)
    sincos | sin cos
    | Compute new column values using current matrix
    4 a]@ over *. 8 a]@ pick3 *. + b!+   | column 1
    5 a]@ over *. 9 a]@ pick3 *. + b!+   | column 2
    6 a]@ over *. 10 a]@ pick3 *. + b!+  | column 3
    7 a]@ over *. 11 a]@ pick3 *. + b!+  | column 4
    swap neg
    4 a]@ over *. 8 a]@ pick3 *. + b!+
    5 a]@ over *. 9 a]@ pick3 *. + b!+
    6 a]@ over *. 10 a]@ pick3 *. + b!+
    7 a]@ over *. 11 a]@ pick3 *. + b!+
    2drop
    mat> 4 3 << + mat> 128 + 8 move   | Copy back
    ;
```
**Key insight:** Uses a temporary buffer (next stack slot) to compute result, then copies back.

---

## Matrix Multiplication (`m*`)

The most complex word — implements `Current = Current × Previous` and pops the stack:

```forth
::m* | --
    mat> dup 128 - >a dup >b 128 +
    | mat> = current matrix (TOS after call)
    | a = previous matrix (mat> - 128)
    | b = temp buffer (mat> + 128)
    
    mrow mrow mrow mrow drop   | Compute all 4 rows
    128 'mat> +!                | Move pointer to temp (new current)
    ;
```

**Row multiplication helper (`mrow`):**
```forth
:mrow | adr -- adr'
    mline swap !+ -88 b+ -32 a+
    mline swap !+ -88 b+ -32 a+
    mline swap !+ -88 b+ -32 a+
    mline swap !+ -96 b+ -24 b+ ;
```

**Line multiplication (`mline`):**
```forth
:mline | -- v
    a@+ b@ *. 32 b+   | a0 * b0
    a@+ b@ *. + 32 b+ | + a1 * b1
    a@+ b@ *. + 32 b+ | + a2 * b2
    a@+ b@ *. +       | + a3 * b3
    ;
```

This computes one row of the product matrix by iterating through the 4 columns.

---

## Hierarchical Transformations (Skeleton / Bones)

### Pattern for Bone Hierarchy

```forth
| Data: bone matrices
#bone0 * 128
#bone1 * 128
#bone2 * 128

| Word to render a bone with its children
:render-bone | bone-addr child1 child2 ... --
    | Save current matrix
    mpush
    
    | Apply this bone's local transform
    bone-addr mm*            | Multiply current by bone matrix
    
    | Store result for this bone (if needed)
    'fmodel mcpyf            | Copy float version for shader
    
    | Render bone geometry here
    draw-bone-mesh
    
    | Render children (they inherit parent transform)
    child1 render-bone
    child2 render-bone
    
    | Restore parent matrix
    mpop
;
```

### Stack Trace for Hierarchical Rendering

**Initial:** Matrix stack contains identity at position 0

```
render-bone root (shoulder)
    mpush     → copies identity to slot 1, pointer at 1
    apply shoulder matrix → slot 1 = shoulder transform
    render shoulder
    render-bone elbow (child)
        mpush     → copies shoulder to slot 2, pointer at 2
        apply elbow matrix → slot 2 = shoulder × elbow
        render elbow
        render-bone wrist (child)
            mpush     → copies (shoulder×elbow) to slot 3
            apply wrist matrix → slot 3 = shoulder×elbow×wrist
            render wrist
            mpop      → pointer back to slot 2
        mpop          → pointer back to slot 1
    mpop              → pointer back to slot 0
```

**Stack contents during rendering:**
```
Slot 0: identity
Slot 1: shoulder
Slot 2: shoulder × elbow
Slot 3: shoulder × elbow × wrist
```

---

## Converting to Float (OpenGL)

The library works with fixed-point internally but provides conversion words:

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `mcpyf` | `fmat --` | Copy current matrix to float buffer |
| `mcpyft` | `fmat --` | Copy transpose of current matrix |
| `getfmat` | `-- fmat` | Create float matrix from current (uses temp buffer) |

**Implementation:**
```forth
::mcpyf | fmat --
    >b mat> >a 16 ( 1? 1 - a@+ f2fp db!+ ) drop ;
```

`f2fp` converts fixed-point (48.16) to 32-bit float.

---

## Complete Example: Rotating Cube with Camera

```forth
^r3/lib/3dgl.r3

#fmodel * 64
#fmvp   * 64

:calc-mvp | yaw pitch rot --
    matini
    
    | Apply cube rotation (modifies current)
    rot 0 0 mrot
    'fmodel mcpyf
    
    | Build view matrix
    'pEye >a
    over cos over cos *. 4.5 *. a!+ | ex
    over sin 4.5 *. a!+             | ey
    rot sin rot cos *. 4.5 *. a!    | ez
    2drop
    
    'pEye 'pTo 'pUp mlookat
    m*                              | current = view × model
    
    | Projection
    0.05 100.0 0.8 800.0 600.0 /. mperspective
    m*                              | current = proj × view × model
    
    'fmvp mcpyf
;
```

---

## Debugging the Matrix Stack

To inspect current matrix:

```forth
:show-mat | --
    mat> 16 0 do
        dup @+ "%f " .print
        i 3 =? ( .cr ) drop
    loop drop ;
```

To see stack depth:

```forth
:mat-depth | -- n
    mat> 'mats - 7 >> ;   | divide by 128 (matrix size)
```

---

## Summary Table

| Word | Stack Effect | Action | Use Case |
|------|--------------|--------|----------|
| `matini` | `--` | Reset to identity | Start new frame |
| `mpush` | `--` | Copy current to next slot | Enter bone/child |
| `mpop` | `--` | Move pointer down | Exit bone/child |
| `mrot` | `rx ry rz --` | Set rotation matrix | Object orientation |
| `mrotx` | `rx --` | Multiply by X rotation | Rotate around X |
| `mtran` | `x y z --` | Multiply by translation | Position object |
| `mscale` | `x y z --` | Multiply by scale | Scale object |
| `m*` | `--` | Multiply by previous | Compose transforms |
| `mlookat` | `eye to up --` | Set view matrix | Camera placement |
| `mperspective` | `near far cot asp --` | Set projection | 3D to 2D |
| `mcpyf` | `fmat --` | Convert to float | Send to OpenGL |

---

## Key Insights

1. **Matrix stack is separate from data stack** — uses global pointer `mat>`
2. **`mpush` copies, doesn't just move** — preserves parent transforms
3. **`m*` consumes the previous matrix** — after multiplication, you can't recover it without `mpush` first
4. **All internal math is fixed-point (48.16)** — converted to float only for OpenGL
5. **Temporary buffer** (`mat> + 128`) is used during multiplication
6. **Row-major order** — matches OpenGL's expected layout

This system is ideal for skeletal animation, scene graphs, and any hierarchical 3D transformations where children need to inherit parent transforms.

---

# vec3.r3 Vector Library — Complete Reference

## Overview

The `vec3.r3` library provides operations on 3D vectors stored as **three consecutive fixed-point (48.16) values** in memory. Vectors are 24 bytes each (3 × 8 bytes) and are always passed by **address**.

---

## Vector Memory Layout

```
A vector is 3 consecutive fixed-point numbers:
┌──────────────┐
│ x (8 bytes)  │ ← address
├──────────────┤
│ y (8 bytes)  │ ← address + 8
├──────────────┤
│ z (8 bytes)  │ ← address + 16
└──────────────┘
```

**Example vector definition:**
```forth
| Define a vector at compile time
#position 1.0 2.0 3.0

| Define a zero vector (buffer)
#velocity * 24
```

---

## Core Vector Words

### Vector Assignment

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `v3=` | `dest src --` | Copy src vector to dest vector |

**From source:**
```forth
::v3= | v1 v2 -- ; v1=v2
    3 move ;           | Copy 3 qwords (24 bytes)
```

### Vector Arithmetic (in-place)

All operations modify the **first vector** (dest) using the second vector or scalar:

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `v3+` | `dest src --` | dest = dest + src |
| `v3-` | `dest src --` | dest = dest - src |
| `v3*` | `dest scalar --` | dest = dest × scalar |
| `v3vec` | `dest src --` | dest = dest × src (cross product) |

**Source analysis:**

```forth
::v3- | v1 v2 -- ; v1=v1-v2
    >a dup @ a@+ - swap !+   | x = x1 - x2
    dup @ a@+ - swap !+      | y = y1 - y2
    dup @ a@ - swap !        | z = z1 - z2
    ;

::v3* | v1 s -- ; v1=v1*s
    swap >a a@ over *. a!+   | x = x × s
    a@ over *. a!+           | y = y × s
    a@ *. a!                 | z = z × s
    ;
```

**Note:** `v3*` multiplies by a scalar, not component-wise vector multiplication.

### Dot Product

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `v3ddot` | `v1 v2 -- dot` | Dot product (returns fixed-point) |

**Source:**
```forth
::v3ddot | v1 v2 -- r ; r=v1.v2
    >a @+ a@+ *.          | x1 × x2
    swap @+ a@+ *. +      | + y1 × y2
    swap @ a@ *. +        | + z1 × z2
    ;
```

### Cross Product (Vector Product)

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `v3vec` | `dest src --` | dest = dest × src (cross product) |

**Source (careful analysis):**
```forth
::v3vec | v1 v2 -- ; v1=v1 x v2
    >a dup @ a> 8 + @ *. over 8 + @ a@ *. -
    over 16 + @ a@ *. pick2 @ a> 16 + @ *. -
    pick2 8 + @ a> 16 + @ *. pick3 16 + @ a> 8 + @ *. -
    >r rot r> swap !+ !+ ! ;
```

This computes:
```
new_x = v1.y × v2.z - v1.z × v2.y
new_y = v1.z × v2.x - v1.x × v2.z
new_z = v1.x × v2.y - v1.y × v2.x
```
And stores back to v1.

---

## Vector Length and Normalization

### Length (Magnitude)

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `v3len` | `vec -- len` | Euclidean length (fixed-point) |

**Source:**
```forth
::v3len | v1 -- l
    @+ dup *.          | x²
    swap @+ dup *. +   | + y²
    swap @ dup *. +    | + z²
    sqrt. ;            | square root
```

### Normalization

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `v3nor` | `vec --` | Normalize vector (in-place) |

**Source:**
```forth
::v3nor | v1 --
    dup v3len 1? ( 1.0 swap /. ) swap >a
    a@ over *. a!+   | x = x / len
    a@ over *. a!+   | y = y / len
    a@ *. a!         | z = z / len
    ;
```

**Guard:** If length is 0, the vector remains unchanged.

---

## Normalization of Integer Coordinates

For vectors stored as integers (not fixed-point), the library provides specialized words:

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `normInt2Fix` | `x y z -- xf yf zf` | Convert integer vector to normalized fixed-point |
| `normFix` | `x y z -- x y z` | Normalize fixed-point vector on stack |

**Source:**
```forth
::normInt2Fix | x y z -- xf yf zf
    pick2 dup * pick2 dup * + over dup * + sqrt
    1? ( 1.0 swap /. ) >r rot r@ *. rot r@ *. rot r> *. ;

::normFix | x y z -- x y z
    pick2 dup *. pick2 dup *. + over dup *. + sqrt.
    1? ( 1.0 swap /. ) >r rot r@ *. rot r@ *. rot r> *. ;
```

---

## Quaternion Support

The library also includes basic quaternion operations. Quaternions are 4 consecutive fixed-point values (32 bytes).

### Quaternion Words

| Word | Stack Effect | Description |
|------|--------------|-------------|
| `q4=` | `dest src --` | Copy quaternion |
| `q4W` | `quat dest --` | Compute w component from xyz (assumes unit quat) |
| `q4dot` | `q1 q2 -- dot` | Dot product |
| `q4inv` | `src dest --` | Inverse (requires normalization) |
| `q4conj` | `src dest --` | Conjugate |
| `q4len` | `quat -- len` | Length |
| `q4nor` | `quat --` | Normalize in-place |

**q4W implementation (reconstructs w from xyz):**
```forth
::q4W | q dest --
    >a @+ dup a!+ dup *. | x, x²
    swap @+ dup a!+ dup *. | y, y²
    swap @ dup a!+ dup *. | z, z²
    + + 1.0 swap - abs sqrt. neg a!+ | w = -√(1 - x² - y² - z²)
```

### Quaternion vs Vector Memory

```
Vector (24 bytes):  [x][y][z]
Quaternion (32 bytes): [x][y][z][w]
```

---

## Vector Usage Patterns

### Creating Vectors

```forth
| Static vectors (compile-time)
#position 1.0 2.0 3.0
#velocity 0.1 0.2 0.0

| Dynamic vectors (runtime buffers)
#tempVec * 24
#resultVec * 24

| Initialize dynamic vector
0.0 0.0 0.0 'tempVec 3 move   | or:
'tempVec >a 0.0 a!+ 0.0 a!+ 0.0 a!
```

### Vector Operations

```forth
| Add two vectors: dest = dest + src
'position 'velocity v3+

| Subtract: dest = dest - src
'position 'gravity v3-

| Scale: dest = dest × scalar
'velocity 0.5 v3*

| Cross product: dest = dest × src
'direction 'up v3vec

| Dot product
'lightDir 'normal v3ddot

| Normalize in-place
'direction v3nor

| Get length
'direction v3len
```

### Vector Movement Pattern

```forth
| Update position by velocity (Euler integration)
:move-object | vel-addr pos-addr --
    over @+ swap @+ over *. + swap !+   | x += vx × dt
    over @+ swap @+ over *. + swap !+   | y += vy × dt
    swap @ swap @ *. + swap !           | z += vz × dt
    drop drop ;

| Usage with fixed timestep
#dt 0.016                       | 16ms timestep
#position 0.0 0.0 0.0
#velocity 1.0 0.0 0.0

:update
    'velocity 'position
    dt v3*                       | Scale velocity by dt
    v3+                          | Add to position
;
```

---

## Vector to Matrix Integration

The vector library integrates with `3dgl.r3` for camera setup:

```forth
| Vectors for lookat
#eye 0.0 0.0 5.0
#to  0.0 0.0 0.0
#up  0.0 1.0 0.0

| Use in matrix calculation
:setup-view
    'eye 'to 'up mlookat
    m*
;
```

---

## Common Vector Operations Reference

| Operation | Word | Stack Effect | Formula |
|-----------|------|--------------|---------|
| Copy | `v3=` | `dest src --` | dest ← src |
| Add | `v3+` | `dest src --` | dest ← dest + src |
| Subtract | `v3-` | `dest src --` | dest ← dest - src |
| Scalar multiply | `v3*` | `dest s --` | dest ← dest × s |
| Dot product | `v3ddot` | `v1 v2 -- dot` | Σ(v1ᵢ × v2ᵢ) |
| Cross product | `v3vec` | `dest src --` | dest ← dest × src |
| Length | `v3len` | `vec -- len` | √(x² + y² + z²) |
| Normalize | `v3nor` | `vec --` | vec ← vec / |vec| |
| Integer normalize | `normInt2Fix` | `x y z -- xf yf zf` | Convert ints to normalized fixed-point |

---

## Debugging Vectors

```forth
:print-vec | vec --
    dup @+ "x: %f " .print
    dup @+ "y: %f " .print
    @    "z: %f" .print .cr
;

:print-quat | quat --
    dup @+ "x: %f " .print
    dup @+ "y: %f " .print
    dup @+ "z: %f " .print
    @    "w: %f" .print .cr
;
```

---

## Performance Notes

1. **All operations are in-place** — no temporary vectors are created (except during cross product where registers are used)
2. **Fixed-point arithmetic** — uses `*.` and `/.` from math library
3. **Register A** is heavily used for pointer operations — wrap calls with `ab[` / `]ba` if mixing with other register-using code
4. **3 `move`** for copy uses optimized block copy

---

## Summary Table

| Category | Words |
|----------|-------|
| **Assignment** | `v3=` |
| **Arithmetic** | `v3+` `v3-` `v3*` |
| **Products** | `v3ddot` `v3vec` |
| **Normalization** | `v3len` `v3nor` |
| **Integer helpers** | `normInt2Fix` `normFix` |
| **Quaternion** | `q4=` `q4W` `q4dot` `q4inv` `q4conj` `q4len` `q4nor` |

This library provides a complete set of 3D vector operations optimized for the fixed-point math system, with all operations working in-place for performance and memory efficiency.