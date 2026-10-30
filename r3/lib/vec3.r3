| 3dmath - PHREDA
| 3d vector
|------------------------
^r3/lib/math.r3

::v3len | 'v -- l ; length of the 3d vector (fixed point)
	@+ dup *. swap @+ dup *. swap @ dup *. + + sqrt. ;

::v3nor | 'v -- ; scale the vector to length 1.0 (a zero vector stays 0 0 0)
	dup v3len 1? ( 1.0 swap /. ) swap >a
	a@ over *. a!+ a@ over *. a!+ a@ *. a! ;

::v3ddot | 'v1 'v2 -- r ; dot product v1.v2 (fixed point)
	>a @+ a@+ *. swap @+ a@+ *. swap @ a@ *. + + ;

::v3vec | 'v1 'v2 -- ; v1 = v1 x v2 (cross product)
	>a dup @ a> 8 + @ *. over 8 + @ a@ *. -
	over 16 + @ a@ *. pick2 @ a> 16 + @ *. -
	pick2 8 + @ a> 16 + @ *. pick3 16 + @ a> 8 + @ *. -
	>r rot r> swap !+ !+ ! ;

::v3- | 'v1 'v2 -- ; v1 = v1 - v2
	>a dup @ a@+ - swap !+ dup @ a@+ - swap !+ dup @ a@ - swap ! ;

::v3+ | 'v1 'v2 -- ; v1 = v1 + v2
	>a dup @ a@+ + swap !+ dup @ a@+ + swap !+ dup @ a@ + swap ! ;

::v3+* | 'v1 'v2 s -- ; v1 = v1 + v2 * s (s fixed point)
	rot >a swap >b  | a=s*b
	dup b@+ *. a> +! 8 a+
	dup b@+ *. a> +! 8 a+
	b@ *. a> +! ;

::v3* | 'v1 s -- ; v1 = v1 * s (s fixed point)
	swap >a a@ over *. a!+ a@ over *. a!+ a@ *. a! ;

::v3= | 'v1 'v2 -- ; v1 = v2 (copy)
	3 move ;

::normInt2Fix | x y z -- xf yf zf ; normalize the integer vector x y z (values on the stack) to a fixed point unit vector (0 0 0 stays 0 0 0)
	pick2 dup * pick2 dup * + over dup * + sqrt
	1? ( 1.0 swap /. ) >r rot r@ *. rot r@ *. rot r> *. ;

::normFix | x y z -- x y z ; normalize the fixed point vector x y z (values on the stack) to length 1.0 (0 0 0 stays 0 0 0)
	pick2 dup *. pick2 dup *. + over dup *. + sqrt.
	1? ( 1.0 swap /. ) >r rot r@ *. rot r@ *. rot r> *. ;

:ax a> @ ; :ay a> 8 + @ ; :az a> 16 + @ ;
:vx b> @ ; :vy b> 8 + @ ; :vz b> 16 + @ ;	

::v3rotX | 'dst 'src angle -- ; dst = src rotated around the X axis (angle: 1.0 = full turn): y' = y*cos - z*sin, z' = y*sin + z*cos
	rot >a swap >b
	sincos 
	vx a!+
	vy over *. vz pick3 *. - a!+
	vy rot *. swap vz *. + a! ;
	
::v3rotY | 'dst 'src angle -- ; dst = src rotated around the Y axis (angle: 1.0 = full turn): x' = x*cos + z*sin, z' = z*cos - x*sin
	rot >a swap >b
	sincos 
	vx over *. vz pick3 *. + a!+
	vy a!+
	vx neg rot *. swap vz *. + a! ;

::v3rotZ | 'dst 'src angle -- ; dst = src rotated around the Z axis (angle: 1.0 = full turn): x' = x*cos - y*sin, y' = x*sin + y*cos
	rot >a swap >b
	sincos 
	vx over *. vy pick3 *. - a!+
	vx rot *. swap vy *. + a!+ 
	vz a! ;
	
| rotate vec3 by axis
#c #s #t
::v3rotAxis | 'dst 'src 'axis angle -- ; dst = src rotated around the vector axis, which must be a unit vector (angle: 1.0 = full turn)
	swap >a swap >b | a=axis b=src
	sincos 1.0 over - 't ! 'c ! 's !
	t ax *. ax *. c + vx *. 
	t ax *. ay *. s az *. - vy *. +
	t ax *. az *. s ay *. + vz *. + swap !+ |o[0]
	t ax *. ay *. s az *. + vx *.
	t ay *. ay *. c + vy *. +
	t ay *. az *. s ax *. - vz *. + swap !+
	t ax *. az *. s ay *. - vx *.
	t ay *. az *. s ax *. + vy *. +
	t az *. az *. c + vz *. + swap ! 
	;
	
|--- quaternios
|#q 0 0 0 1.0

::q4= | 'q1 'q2 -- ; q1 = q2 (copy of the 4 cells x y z w)
	4 move ;

::q4W | 'q 'dest -- ; copy x y z of q to dest and set w = -sqrt(|1 - x*x - y*y - z*z|)
	>a @+ dup a!+ dup *. | x*x
	swap @+ dup a!+ dup *. | y*y
	swap @ dup a!+ dup *. | z*z
	+ + 1.0 swap - abs sqrt. neg a!+
	;

::q4dot | 'q1 'q2 -- dot ; 4d dot product of two quaternions (fixed point)
	>a
	@+ a@+ *. swap @+ a@+ *. swap @+ a@+ *. swap @ a@+ *. 
	+ + + ;
	
::q4inv | 'q 'dest -- ; dest = inverse of q (its conjugate divided by dot(q,q))
	over dup q4dot 1.0 swap /.
	rot >a swap | invdot d
	over a@+ neg *. swap !+
	over a@+ neg *. swap !+
	over a@+ neg *. swap !+
	swap a@ *. swap !
	;

::q4conj | 'q 'dest -- ; dest = conjugate of q (-x -y -z w)
	>a
	@+ neg a!+
	@+ neg a!+
	@+ neg a!+
	@ a! ;

::q4len | 'q -- len ; length of the quaternion (fixed point)
	@+ dup *. swap
	@+ dup *. swap	
	@+ dup *. swap
	@ dup *. swap
	+ + + sqrt. ;
	
::q4nor | 'q -- ; normalize the quaternion to length 1.0 (a zero quaternion becomes the identity 0 0 0 1.0)
	dup q4len | q len
	0? ( drop >a 0 a!+ 0 a!+ 0 a!+ 1.0 a! ; )
	1.0 swap /.
	swap >a
	a@ over *. a!+
	a@ over *. a!+
	a@ over *. a!+
	a@ *. a! ;

::q4lenf | 'q -- 1/len ; fast approximation of 1/length, only good for lengths near 1 (0 if the length is 0)
	@+ dup *. swap
	@+ dup *. swap	
	@+ dup *. swap
	@ dup *. swap
	+ + + 0? ( ; ) 
	1.0 over /.	| n2 inv
	swap over dup *. *. 	| i n2*i*i
	neg 3.0 + 2/ *.
	;

::q4norf | 'q -- ; fast normalization with q4lenf, only for quaternions already near unit length (a zero one becomes the identity)
	dup q4lenf | q len
	0? ( drop >a 0 a!+ 0 a!+ 0 a!+ 1.0 a! ; )
	swap >a
	a@ over *. a!+
	a@ over *. a!+
	a@ over *. a!+
	a@ *. a! ;
	
#qx #qy #qz #qw	
#ox #oy #oz
::q4integrate | 'q 'omega dt -- ; advance quaternion q by the angular velocity vector omega during dt (fixed point), then renormalize with q4norf
	2/	
	swap @+ 'ox ! @+ 'oy ! @ 'oz !
	over dup >a 
	@+ 'qx ! @+ 'qy ! @+ 'qz ! @ 'qw !
	ox qw *. oz qy *. + oy qz *. - over *. a@ + a!+ | x
	oy qw *. ox qz *. + oz qx *. - over *. a@ + a!+ | y
	oz qw *. oy qx *. + ox qy *. - over *. a@ + a!+ | z
	ox qx *. oy qy *. + oz qz *. + neg *. a@ + a! | w
	q4norf ;
	