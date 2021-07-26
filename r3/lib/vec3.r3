| 3dmath - PHREDA
|-------------------------
^r3/lib/math.r3

::v3len | v1 -- l
	@+ dup *. swap @+ dup *. swap @ dup *. + + sqrt. ;

::v3nor | v1 --
	dup v3len 1? ( 1.0 swap /. ) swap >a
	a@ over *. a!+ a@ over *. a!+ a@ *. a! ;

::v3ddot | v1 v2 -- r ; r=v1.v2
	>a @+ a@+ *. swap @+ a@+ *. swap @ a@ *. + +  ;

::v3vec | v1 v2 -- ; v1=v1 x v2
	>a dup @ a> 4 + @ *. over 4 + @ a@ *. -
	over 8 + @ a@ *. pick2 @ a> 8 + @ *. -
	pick2 4 + @ a> 8 + @ *. pick3 8 + @ a> 4 + @ *. -
	>r rot r> swap !+ !+ ! ;

::v3- | v1 v2 -- ; v1=v1-v2
	>a dup @ a@+ - swap !+ dup @ a@+ - swap !+ dup @ a@ - swap ! ;

::v3+ | v1 v2 -- ; v1=v1+v2
	>a dup @ a@+ + swap !+ dup @ a@+ + swap !+ dup @ a@ + swap ! ;

::v3* | v1 s -- ; v1=v1*s
	swap >a a@ over *. a!+ a@ over *. a!+ a@ *. a! ;

::v3= | v1 v2 --
	3 move ;

|-------------- rota directo -----------------------------
#cox #coy #coz
#six #siy #siz

::calcrot | rx ry rz --
	sincos 'coz ! 'siz !
	sincos 'coy ! 'siy !
	sincos 'cox ! 'six !
	;

::makerot | x y z -- x' y' z'
	rot rot | z x y
	over cox *. over six *. +	| z x y x'
	rot six *. rot cox *. - 	| z x' y'
	swap rot 					| y' x' z
	over coy *. over siy *. +	| y' x' z x''
	rot siy *. rot coy *. -		| y' x'' z'
	rot							| x'' y' z'
	over coz *. over siz *. +	|  x'' y' z' y''
	rot siz *. rot coz *. -		| x'' y'' z''
	;

#m11 #m12 #m13
#m21 #m22 #m23
#m31 #m32 #m33

::calcvrot | rx ry rz --
	sincos 'coz ! 'siz !
	sincos 'coy ! 'siy !
	sincos 'cox ! 'six !
    coz coy *. 'm11 !
    cox siz *. coy *. six siy *. + 'm12 !
    six siz *. coy *. cox siy *. - 'm13 !
	siz neg 'm21 !
    cox coz *. 'm22 !
    six coz *. 'm23 !
    coz siy *. 'm31 !
    cox siz *. siy *. six coy *. - 'm32 !
    six siz *. siy *. cox coy *. + 'm33 !
	;

::mrotxyz | x y z --
 	calcvrot
	mat> >a
	a@+ a@+ a@+ -12 a+
	pick2 m11 *. pick2 m21 *. + over m31 *. + a!+
	pick2 m12 *. pick2 m22 *. + over m32 *. + a!+
	rot m13 *. rot m23 *. + swap m33 *. + a!+ 4 a+
	a@+ a@+ a@+ -12 a+
	pick2 m11 *. pick2 m21 *. + over m31 *. + a!+
	pick2 m12 *. pick2 m22 *. + over m32 *. + a!+
	rot m13 *. rot m23 *. + swap m33 *. + a!+ 4 a+
	a@+ a@+ a@+ -12 a+
	pick2 m11 *. pick2 m21 *. + over m31 *. + a!+
	pick2 m12 *. pick2 m22 *. + over m32 *. + a!+
	rot m13 *. rot m23 *. + swap m33 *. + a! 4 a+
	a@+ a@+ a@+ -12 a+
	pick2 m11 *. pick2 m21 *. + over m31 *. + a!+
	pick2 m12 *. pick2 m22 *. + over m32 *. + a!+
	rot m13 *. rot m23 *. + swap m33 *. + a! 4 a+
	;

::mrotxyzi | x y z --
 	calcrot
	mat> >a
	a@ a> 16 + @ a> 32 + @
	pick2 m11 *. pick2 m12 *. + over m13 *. + a! 16 a+
	pick2 m21 *. pick2 m22 *. + over m23 *. + a! 16 a+
	rot m31 *. rot m32 *. + swap m33 *. + a! -28 a+
	a@ a> 16 + @ a> 32 + @
	pick2 m11 *. pick2 m12 *. + over m13 *. + a! 16 a+
	pick2 m21 *. pick2 m22 *. + over m23 *. + a! 16 a+
	rot m31 *. rot m32 *. + swap m33 *. + a! -28 a+
   	a@ a> 16 + @ a> 32 + @
	pick2 m11 *. pick2 m12 *. + over m13 *. + a! 16 a+
	pick2 m21 *. pick2 m22 *. + over m23 *. + a! 16 a+
	rot m31 *. rot m32 *. + swap m33 *. + a! -28 a+
   	a@ a> 16 + @ a> 32 + @
	pick2 m11 *. pick2 m12 *. + over m13 *. + a! 16 a+
	pick2 m21 *. pick2 m22 *. + over m23 *. + a! 16 a+
	rot m31 *. rot m32 *. + swap m33 *. + a!
	;


#oh #ow
::3dnorm | w h xc yc --
	rot 'oh !
	rot 'ow !
	'oy !
	'ox !
	;

::3dpp | x y z -- x y
	rot over / ox + >r / oy + r> ;

