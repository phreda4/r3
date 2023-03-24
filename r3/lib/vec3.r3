| 3dmath - PHREDA
| 3d vector
|------------------------
^r3/lib/math.r3

::v3len | v1 -- l
	@+ dup *. swap @+ dup *. swap @ dup *. + + sqrt. ;

::v3nor | v1 --
	dup v3len 1? ( 1.0 swap /. ) swap >a
	a@ over *. a!+ a@ over *. a!+ a@ *. a! ;

::v3ddot | v1 v2 -- r ; r=v1.v2
	>a @+ a@+ *. swap @+ a@+ *. swap @ a@ *. + + ;

::v3vec | v1 v2 -- ; v1=v1 x v2
	>a dup @ a> 8 + @ *. over 8 + @ a@ *. -
	over 16 + @ a@ *. pick2 @ a> 16 + @ *. -
	pick2 8 + @ a> 16 + @ *. pick3 16 + @ a> 8 + @ *. -
	>r rot r> swap !+ !+ ! ;

::v3- | v1 v2 -- ; v1=v1-v2
	>a dup @ a@+ - swap !+ dup @ a@+ - swap !+ dup @ a@ - swap ! ;

::v3+ | v1 v2 -- ; v1=v1+v2
	>a dup @ a@+ + swap !+ dup @ a@+ + swap !+ dup @ a@ + swap ! ;

::v3* | v1 s -- ; v1=v1*s ; cross
	swap >a a@ over *. a!+ a@ over *. a!+ a@ *. a! ;

::v3= | v1 v2 -- ; v1=v2
	3 move ;

::normInt2Fix | x y z -- xf yf zf
	pick2 dup * pick2 dup * + over dup * + sqrt
	1? ( 1.0 swap /. ) >r rot r@ *. rot r@ *. rot r> *. ;

::normFix | x y z -- x y z
	pick2 dup *. pick2 dup *. + over dup *. + sqrt.
	1? ( 1.0 swap /. ) >r rot r@ *. rot r@ *. rot r> *. ;
	
	
|--- quaternios
|#q 0 0 0 0

::q4= | v1 v2 -- ; v1=v2
	4 move ;

::q4W | q dest --
	>a @+ dup a!+ dup *. | x*x
	swap @+ dup a!+ dup *. | y*y
	swap @ dup a!+ dup *. | z*z
	+ + 1.0 swap - abs sqrt. neg a!+
	;

::q4dot | q1 q2 -- dot
	>a
	@+ a@+ *. swap @+ a@+ *. swap @+ a@+ *. swap @ a@+ *. 
	+ + + ;
	
::q4inv | q1 q2d --
	2dup q4dot 1.0 swap /.
	rot >a swap | invdot d
	over a@+ neg *. swap !+
	over a@+ neg *. swap !+
	over a@+ neg *. swap !+
	swap a@ *. swap !
	;

::q4conj | q1 q2d --
	>a
	@+ neg a!+
	@+ neg a!+
	@+ neg a!+
	@ a! ;

::q4len | q -- len
	@+ dup *. swap
	@+ dup *. swap	
	@+ dup *. swap
	@ dup *. swap
	+ + + sqrt. ;
	
::q4nor | q --
	dup q4len | q len
	0? ( drop 0 4 fill ; )
	1.0 swap /.
	swap >a
	a@ over *. a!+
	a@ over *. a!+
	a@ over *. a!+
	a@ *. a! ;
	

