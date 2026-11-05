# 3D Math — `3dgl.r3` and `vec3.r3`

`3dgl.r3` (includes `vec3.r3`) keeps a **stack of 4x4 matrices** in OpenGL layout and
transforms points with the current one. All values are fixed point (`1.0 = $10000`) and
angles are in turns (`1.0` = full turn). A matrix is 16 cells of 8 bytes; `mat>` holds the
address of the current one. The stack has 20 levels and `mpop` does not check the bottom.

```forth
^r3/lib/3dgl.r3
```

---

## Matrix stack

| Word | Stack | Description |
|---|---|---|
| `matini` | `--` | reset the matrix stack: one identity matrix as the current one |
| `matinim` | `'mat --` | reset the matrix stack: a copy of 'mat (16 cells) as the only matrix |
| `mpush` | `--` | push a copy of the current matrix on the matrix stack (20 levels) |
| `mpushi` | `--` | push a new identity matrix on the matrix stack |
| `mpop` | `--` | pop the current matrix (there is no check for the bottom of the stack) |
| `nmpop` | `n --` | pop n matrices (there is no check for the bottom of the stack) |
| `mcpy` | `'mat --` | copy the current matrix (16 cells) to 'mat |

## Set the current matrix

| Word | Stack | Description |
|---|---|---|
| `mtra` | `x y z --` | set the current matrix to an identity with the translation x y z (m12 m13 m14) |
| `mpos` | `x y z --` | set the translation m12 m13 m14 of the current matrix, the rest is unchanged |
| `mrot` | `rx ry rz --` | set the current matrix to the rotation of three angles (1.0 = full turn), no translation |
| `mrpos` | `r16 x y z --` | set the current matrix to a rotation and the position x y z; r16 packs the angles as $xxxxyyyyzzzz (16 bits each, $10000 = full turn) |
| `mperspective` | `near far cot aspect --` | make the current matrix an OpenGL perspective projection: m0 = cot*aspect, m5 = cot (cot = cotangent of half the field of view; aspect acts as height/width) |
| `mortho` | `r l t b f n --` | make the current matrix an OpenGL orthographic projection (right left top bottom far near) |
| `mlookat` | `eye to up --` | make the current matrix an OpenGL view matrix looking from eye toward to; eye, to and up are addresses of vec3 |

## Modify the current matrix

Translations and rotations act along the **local** axes of the current matrix.

| Word | Stack | Description |
|---|---|---|
| `mtran` | `x y z --` | translate the current OpenGL matrix by x y z along its local axes (changes m12 to m15) |
| `mtranx` | `x --` | like mtran along the local x axis only |
| `mtrany` | `y --` | like mtran along the local y axis only |
| `mtranz` | `z --` | like mtran along the local z axis only |
| `mrotx` | `rx --` | rotate the current OpenGL matrix around its local X axis (1.0 = full turn) |
| `mroty` | `ry --` | rotate the current OpenGL matrix around its local Y axis (1.0 = full turn) |
| `mrotz` | `rz --` | rotate the current OpenGL matrix around its local Z axis (1.0 = full turn) |
| `mscale` | `x y z --` | multiply the four values of row 0 by x, of row 1 by y and of row 2 by z (translation included) |
| `mscalei` | `x y z --` | scale the local axes: multiply the columns of the 3x3 part by x y z (translation unchanged) |
| `muscalei` | `s --` | uniform scale of the 3x3 part of the matrix by s (translation unchanged) |

## Multiply and invert

| Word | Stack | Description |
|---|---|---|
| `m*` | `--` | multiply the two top matrices (previous * current) and push the result as a new matrix |
| `mm*` | `'mat --` | push current * 'mat as a new matrix |
| `mmi*` | `'mat --` | push 'mat * current as a new matrix |
| `matinv` | `--` | push the inverse of the current 4x4 matrix as a new matrix; nothing is pushed if it has no inverse |
| `mview` | `eye to up --` | mpush, mlookat and m*: pushes the view matrix and the product previous * view (arguments of mlookat) |
| `mproj` | `near far cot aspect --` | mpush, mperspective and m*: pushes the projection and the product previous * projection (the arguments are the ones of mperspective, not fov asp zn zf) |

## Transform points

| Word | Stack | Description |
|---|---|---|
| `transform` | `x y z -- x y z` | transform a point by the current matrix: x' = x*m0 + y*m1 + z*m2 + m3, y' = x*m4 + y*m5 + z*m6 + m7, z' = x*m8 + y*m9 + z*m10 + m11 |
| `transformr` | `x y z -- x y z` | like transform without the translation (for directions) |
| `ztransform` | `x y z -- z` | only the z of transform |
| `oxyztransform` | `-- x y z` | the transformed origin (m3 m7 m11) |
| `oztransform` | `-- z` | z of the transformed origin (m11) |

## Output for OpenGL (float32)

| Word | Stack | Description |
|---|---|---|
| `getfmat` | `-- fmat` | convert the current matrix to 16 float32 values written just after it in the stack; returns their address |
| `gettfmat` | `--` | like getfmat but transposed; the values are at mat> 128 + (the address is not returned) |
| `mcpyf` | `fmat --` | write the current matrix as 16 float32 values at fmat |
| `mcpyft` | `fmat --` | like mcpyf but transposed |
| `midf` | `fmat --` | write the identity matrix as 16 float32 values at fmat |

## Packed values

| Word | Stack | Description |
|---|---|---|
| `packrota` | `rx ry rz -- rp` | pack three angles of 16 bits: rx<<32 \| ry<<16 \| rz (for mrpos) |
| `+rota` | `ra rb -- rr` | add two packed rotations (the lowest bit of each 16 bit field is lost) |
| `pack21` | `vx vy vz -- vp` | pack three 21-bit values: vx<<42 \| vy<<21 \| vz |
| `+p21` | `va vb -- vr` | add two pack21 values (the lowest bit of each 21 bit field is lost) |

## Example: two bones

```forth
^r3/lib/3dgl.r3

#fmat * 64				| 16 float32 = 64 bytes

:arm
	mpush
	0.25 mrotz  1.0 0 0 mtran	| shoulder: rotate and move along local x
	'fmat mcpyf			| send this matrix to the shader
	mpush
	0.1 mrotz  1.0 0 0 mtran	| elbow, relative to the shoulder
	'fmat mcpyf
	mpop
	mpop ;

: matini arm ;
```

---

## Vectors (`vec3.r3`)

A vector is 3 cells (`x y z`) at an address; the words below work on addresses (`'v`) unless
the stack comment shows `x y z`.

| Word | Stack | Description |
|---|---|---|
| `v3len` | `'v -- l` | length of the 3d vector (fixed point) |
| `v3nor` | `'v --` | scale the vector to length 1.0 (a zero vector stays 0 0 0) |
| `v3ddot` | `'v1 'v2 -- r` | dot product v1.v2 (fixed point) |
| `v3vec` | `'v1 'v2 --` | v1 = v1 x v2 (cross product) |
| `v3+` | `'v1 'v2 --` | v1 = v1 + v2 |
| `v3-` | `'v1 'v2 --` | v1 = v1 - v2 |
| `v3+*` | `'v1 'v2 s --` | v1 = v1 + v2 * s (s fixed point) |
| `v3*` | `'v1 s --` | v1 = v1 * s (s fixed point) |
| `v3=` | `'v1 'v2 --` | v1 = v2 (copy) |
| `normInt2Fix` | `x y z -- xf yf zf` | normalize the integer vector x y z (values on the stack) to a fixed point unit vector (0 0 0 stays 0 0 0) |
| `normFix` | `x y z -- x y z` | normalize the fixed point vector x y z (values on the stack) to length 1.0 (0 0 0 stays 0 0 0) |
| `v3rotX` | `'dst 'src angle --` | dst = src rotated around the X axis (angle: 1.0 = full turn): y' = y*cos - z*sin, z' = y*sin + z*cos |
| `v3rotY` | `'dst 'src angle --` | dst = src rotated around the Y axis (angle: 1.0 = full turn): x' = x*cos + z*sin, z' = z*cos - x*sin |
| `v3rotZ` | `'dst 'src angle --` | dst = src rotated around the Z axis (angle: 1.0 = full turn): x' = x*cos - y*sin, y' = x*sin + y*cos |
| `v3rotAxis` | `'dst 'src 'axis angle --` | dst = src rotated around the vector axis, which must be a unit vector (angle: 1.0 = full turn) |

## Quaternions (`vec3.r3`)

A quaternion is 4 cells (`x y z w`) at an address.

| Word | Stack | Description |
|---|---|---|
| `q4=` | `'q1 'q2 --` | q1 = q2 (copy of the 4 cells x y z w) |
| `q4W` | `'q 'dest --` | copy x y z of q to dest and set w = -sqrt(\|1 - x*x - y*y - z*z\|) |
| `q4dot` | `'q1 'q2 -- dot` | 4d dot product of two quaternions (fixed point) |
| `q4inv` | `'q 'dest --` | dest = inverse of q (its conjugate divided by dot(q,q)) |
| `q4conj` | `'q 'dest --` | dest = conjugate of q (-x -y -z w) |
| `q4len` | `'q -- len` | length of the quaternion (fixed point) |
| `q4nor` | `'q --` | normalize the quaternion to length 1.0 (a zero quaternion becomes the identity 0 0 0 1.0) |
| `q4lenf` | `'q -- 1/len` | fast approximation of 1/length, only good for lengths near 1 |
| `q4norf` | `'q --` | fast normalization with q4lenf, only for quaternions already near unit length |
| `q4integrate` | `'q 'omega dt --` | advance quaternion q by the angular velocity vector omega during dt (fixed point), then renormalize with q4norf |

```forth
^r3/lib/3dgl.r3

#a 1.0 0 0
#b 0 1.0 0

: 'a 'b v3vec ;		| a = a x b = (0 0 1.0)
```
