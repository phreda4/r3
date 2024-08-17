| 3dmath for opengl 
| PHREDA
|-------------------------
^r3/lib/vec3.r3

#mati | matrix id
1.0 0 0 0		| 1.0 = $10000
0 1.0 0 0
0 0 1.0 0
0 0 0 1.0
#mats * 2560 | 20 matrices
##mat> 'mats

::matini
	'mats dup 'mat> ! 'mati 16 move ;

::matinim | 'mat --
	'mats dup 'mat> ! swap 16 move ;

::mpush | --
	mat> dup 128 + dup 'mat> ! swap 16 move ;
	
::mpushi | --  ; push new id
	mat> 128 + dup 'mat> ! 'mati 16 move ;

::mpop | --
	mat> |'mats =? ( drop ; )
	128 - 'mat> ! ;

::nmpop | n --
	7 << mat> swap - |'mats <? ( 'mats nip )
	'mat> ! ;

|----------- generate floating point matrix

::getfmat | -- fmat ; make float point mat
	mat> dup 128 + >b >a
	16 ( 1? 1 - a@+ f2fp db!+ ) drop 
	mat> 128 + ;
	
::gettfmat |  -- fmat ; transpose
	mat> dup 128 + >b
	@+ f2fp db!+ 24 + @+ f2fp db!+ 24 + @+ f2fp db!+ 24 + @+ f2fp db!+ 96 -
	@+ f2fp db!+ 24 + @+ f2fp db!+ 24 + @+ f2fp db!+ 24 + @+ f2fp db!+ 96 -
	@+ f2fp db!+ 24 + @+ f2fp db!+ 24 + @+ f2fp db!+ 24 + @+ f2fp db!+ 96 -
	@+ f2fp db!+ 24 + @+ f2fp db!+ 24 + @+ f2fp db!+ 24 + @+ f2fp db! 
	;

::mcpyf | fmat --	; copy floating opoint mat to mem
	>b mat> >a 16 ( 1? 1 - a@+ f2fp db!+ ) drop ;

::mcpyft | fmat -- ; transpose
	>b mat> 
	@+ f2fp db!+ 24 + @+ f2fp db!+ 24 + @+ f2fp db!+ 24 + @+ f2fp db!+ 96 -
	@+ f2fp db!+ 24 + @+ f2fp db!+ 24 + @+ f2fp db!+ 24 + @+ f2fp db!+ 96 -
	@+ f2fp db!+ 24 + @+ f2fp db!+ 24 + @+ f2fp db!+ 24 + @+ f2fp db!+ 96 -
	@+ f2fp db!+ 24 + @+ f2fp db!+ 24 + @+ f2fp db!+ 24 + @+ f2fp db! 
	;	
	
::midf | fmat --
	>b 'mati >a 16 ( 1? 1 - a@+ f2fp db!+ ) drop ;

| Projection matrix : 45° Field of View, 4:3 ratio, display range : 0.1 unit <-> 100 units
| glm::radians(45.0f), 4.0f / 3.0f, 0.1f, 100.0f);
|--- from kazmath/mat4.c

:a]! 3 << a> + ! ;
:a]+! 3 << a> + +! ;
:a]@ 3 << a> + @ ;

::mperspective | near far contang aspect  --
	mat> dup >a 'mati 16 move 
	over *. a!		|mat[0] = cotangent / aspect;
	5 a]!			|mat[5] = cotangent;
	2dup -			| near far deltaz
	pick2 pick2 + over /. 10 a]!	|mat[10] = (zFar + zNear) / deltaZ;
	-1.0 11 a]! 					|mat[11] = -1;
	-rot *. 1 << swap /. 14 a]!	|mat[14] = (2 * zFar * zNear) / deltaZ;
	0 15 a]!						|mat[15] = 0;
	;
	
|#preload * 128	
|:makematcte
|	mperspective mat> 'preload 16 move ;
|:mperspectivestatic
|	'preload 'mat 16 move ;	
	
::mortho | r l t b f n --
	mat> dup >a 'mati 16 move 
	2dup - -2.0 over /. 10 a]!		| 	mat[10] = -2 / (farVal - nearVal);
	-rot + swap /. neg 14 a]!	| mat[14] = -((farVal + nearVal) / (farVal - nearVal));
	2dup - 2.0 over /. 5 a]!		| mat[5] = 2 / (top - bottom);
	-rot + swap /. neg 13 a]!	| mat[13] = -((top + bottom) / (top - bottom));
	2dup - 2.0 over /. a> !			| mat[0] = 2 / (right - left);
	-rot + swap /. neg 12 a]!	| mat[12] = -((right + left) / (right - left));
	;
	
#fx 0 0 0 |#fy 0 #fz 0 | compiler remove constant problem!!
:fy 'fx 8 + @ ;
:fz 'fx 16 + @ ;
#sx 0 0 0 |#sy 0 #sz 0
:sy 'sx 8 + @ ;
:sz 'sx 16 + @ ;
#ux 0 0 0 |#uy 0 #uz 0 
:uy 'ux 8 + @ ;
:uz 'ux 16 + @ ;


::mlookat | eye to up --
	swap
	'fx dup rot v3= dup pick3 v3- v3Nor | eye up
	'sx dup 'fx v3= dup rot v3vec v3Nor | eye
	'ux dup 'sx v3= 'fx v3vec
	mat> >b
	sx b!+ |mat[0] = s.x;
    ux b!+ |mat[1] = u.x;
    fx neg b!+ |mat[2] = -f.x;
    0 b!+ |mat[3] = 0.0;
    sy b!+ |mat[4] = s.y;
    uy b!+ |mat[5] = u.y;
    fy neg b!+ |mat[6] = -f.y;
    0 b!+ |mat[7] = 0.0;
    sz b!+ |mat[8] = s.z;
    uz b!+ |mat[9] = u.z;
    fz neg b!+ |mat[10] = -f.z;
    0 b!+ |mat[11] = 0.0;
    'sx over v3ddot neg b!+ |mat[12] = -kmVec3Dot(&s, pEye);
    'ux over v3ddot neg b!+ |mat[13] = -kmVec3Dot(&u, pEye);
    'fx swap v3ddot b!+ |mat[14] = kmVec3Dot(&f, pEye);
    1.0 b! |mat[15] = 1.0;
	;
	
|-----------------------------
::mtran | x y z --
	mat> >a
	pick2 0 a]@ *. pick2 4 a]@ *. + over 8 a]@ *. + 12 a]+!
	pick2 1 a]@ *. pick2 5 a]@ *. + over 9 a]@ *. + 13 a]+!
	pick2 2 a]@ *. pick2 6 a]@ *. + over 10 a]@ *. + 14 a]+!
	rot 3 a]@ *. rot 7 a]@ *. + swap 11 a]@ *. + 15 a]+! ;

::mtranx | x --
	mat> >a
	dup 0 a]@ *. 12 a]+!
	dup 1 a]@ *. 13 a]+!
	dup 2 a]@ *. 14 a]+!
	3 a]@ *. 15 a]+! ;

::mtrany | y --
	mat> >a
	dup 4 a]@ *. 12 a]+!
	dup 5 a]@ *. 13 a]+!
	dup 6 a]@ *. 14 a]+!
	7 a]@ *. 15 a]+! ;

::mtranz | z --
	mat> >a
	dup 8 a]@ *. 12 a]+!
	dup 9 a]@ *. 13 a]+!
	dup 10 a]@ *. 14 a]+!
	11 a]@ *. 15 a]+! ;

::mrotx	| rx --
	mat> dup >a 128 + >b
	sincos | sin cos
    4 a]@ over *. 8 a]@ pick3 *. + b!+
    5 a]@ over *. 9 a]@ pick3 *. + b!+
	6 a]@ over *. 10 a]@ pick3 *. + b!+
    7 a]@ over *. 11 a]@ pick3 *. + b!+
	swap neg | cos sin
	4 a]@ over *. 8 a]@ pick3 *. + b!+
	5 a]@ over *. 9 a]@ pick3 *. + b!+
	6 a]@ over *. 10 a]@ pick3 *. + b!+
	7 a]@ over *. 11 a]@ pick3 *. + b!+
	2drop 
	mat> 4 3 << + mat> 128 + 8 move
	;
	
::mroty
	mat> dup >a 128 + >b
	sincos swap | cos sin
    0 a]@ over *. 8 a]@ pick3 *. + b!+ 
    1 a]@ over *. 9 a]@ pick3 *. + b!+ 
	2 a]@ over *. 10 a]@ pick3 *. + b!+
    3 a]@ over *. 11 a]@ pick3 *. + b!+
	neg swap | sin cos
    0 a]@ over *. 8 a]@ pick3 *. + b!+
    1 a]@ over *. 9 a]@ pick3 *. + b!+
	2 a]@ over *. 10 a]@ pick3 *. + b!+
    3 a]@ over *. 11 a]@ pick3 *. + b!+
	2drop 
	mat> mat> 128 + 4 3 << + 4 move | 0..3
	mat> 8 3 << + mat> 128 + 4 move | 8..11
	;
	
::mrotz	
	mat> dup >a 128 + >b
	sincos | sin cos
    0 a]@ over *. 4 a]@ pick3 *. + b!+ 
	1 a]@ over *. 5 a]@ pick3 *. + b!+ 
	2 a]@ over *. 6 a]@ pick3 *. + b!+ 
	3 a]@ over *. 7 a]@ pick3 *. + b!+ 
	swap neg | cos -sin
	0 a]@ over *. 4 a]@ pick3 *. + b!+ 
	1 a]@ over *. 5 a]@ pick3 *. + b!+ 
	2 a]@ over *. 6 a]@ pick3 *. + b!+ 
	3 a]@ over *. 7 a]@ pick3 *. + b!+ 
	2drop 
	mat> mat> 128 + 8 move
	;
	
|-----------------------------
::mscale | x y z -- ; post
	mat> >a
	pick2 a@ *. a!+ pick2 a@ *. a!+ pick2 a@ *. a!+ rot a@ *. a!+
	over a@ *. a!+ over a@ *. a!+ over a@ *. a!+ swap a@ *. a!+
	dup a@ *. a!+ dup a@ *. a!+ dup a@ *. a!+ a@ *. a! ;

::mscalei | x y z --
	mat> >a
	pick2 a@ *. a!+ over a@ *. a!+ dup a@ *. a!+ 8 a+
	pick2 a@ *. a!+ over a@ *. a!+ dup a@ *. a!+ 8 a+
	rot a@ *. a!+ swap a@ *. a!+ a@ *. a! ;

::muscalei | s --
	mat> >a
	dup a@ *. a!+ dup a@ *. a!+ dup a@ *. a!+ 8 a+
	dup a@ *. a!+ dup a@ *. a!+ dup a@ *. a!+ 8 a+
	dup a@ *. a!+ dup a@ *. a!+ a@ *. a! ;

|-----------------------------
::transform | x y z -- x y z
	mat> >a pick2 a@+ *. pick2 a@+ *. + over a@+ *. + a@+ +
	>r pick2 a@+ *. pick2 a@+ *. + over a@+ *. + a@+ +
	>r rot a@+ *. rot a@+ *. + swap a@+ *. + a@ +
	r> r> swap rot ;

::transformr | x y z -- x y z
	mat> >a pick2 a@+ *. pick2 a@+ *. + over a@+ *. + 8 a+
	>r pick2 a@+ *. pick2 a@+ *. + over a@+ *. + 8 a+
	>r rot a@+ *. rot a@+ *. + swap a@ *. +
	r> r> swap rot ;

::ztransform | x y z -- z
	mat> 64 + >a
	rot a@+ *. rot a@+ *. + swap a@+ *. + a@ + ;

::oztransform | -- z
	mat> 88 + @ ;

::oxyztransform | -- x y z
	mat> dup 24 + @ over 56 + @ rot 88 + @ ;
	
:b]@ 3 << a> + 256 + @ ;
	
::matinv | --
	mat> dup >a 256 + >b | b store aux
    0 a]@ 5 a]@ *. 1 a]@ 4 a]@ *. - b!+
    0 a]@ 6 a]@ *. 2 a]@ 4 a]@ *. - b!+
    0 a]@ 7 a]@ *. 3 a]@ 4 a]@ *. - b!+
    1 a]@ 6 a]@ *. 2 a]@ 5 a]@ *. - b!+
    1 a]@ 7 a]@ *. 3 a]@ 5 a]@ *. - b!+
    2 a]@ 7 a]@ *. 3 a]@ 6 a]@ *. - b!+
    8 a]@ 13 a]@ *. 9 a]@ 12 a]@ *. - b!+
    8 a]@ 14 a]@ *. 10 a]@ 12 a]@ *. - b!+
    8 a]@ 15 a]@ *. 11 a]@ 12 a]@ *. - b!+
    9 a]@ 14 a]@ *. 10 a]@ 13 a]@ *. - b!+
    9 a]@ 15 a]@ *. 11 a]@ 13 a]@ *. - b!+
    10 a]@ 15 a]@ *. 11 a]@ 14 a]@ *. - b!+

    0 b]@ 11 b]@ *. 
	1 b]@ 10 b]@ *. -  
	2 b]@ 9 b]@ *. + 
	3 b]@ 8 b]@ *. + 
	4 b]@ 7 b]@ *. - 
	5 b]@ 6 b]@ *. + 
	0? ( drop ; )
	a> 128 + >b	| b store inv matrix
	1.0 swap /. 
	5 a]@ 11 b]@ *. 6 a]@ 10 b]@ *. - 7 a]@ 9 b]@ *. + over *. b!+
	2 a]@ 10 b]@ *. 3 a]@ 9 b]@ *. - 1 a]@ 11 b]@ *. - over *. b!+
    13 a]@ 5 b]@ *. 14 a]@ 4 b]@ *. - 15 a]@ 3 b]@ *. + over *. b!+
	10 a]@ 4 b]@ *. 11 a]@ 3 b]@ *. - 9 a]@ 5 b]@ *. - over *. b!+
	
	6 a]@ 8 b]@ *. 4 a]@ 11 b]@ *. - 7 a]@ 7 b]@ *. - over *. b!+
    0 a]@ 11 b]@ *. 2 a]@ 8 b]@ *. - 3 a]@ 7 b]@ *. + over *. b!+
	14 a]@ 2 b]@ *. 15 a]@ 1 b]@ *. - 12 a]@ 5 b]@ *. - over *. b!+
    8 a]@ 5 b]@ *. 10 a]@ 2 b]@ *. - 11 a]@ 1 b]@ *. + over *. b!+
	
    4 a]@ 10 b]@ *. 5 a]@ 8 b]@ *. - 7 a]@ 6 b]@ *. + over *. b!+
	1 a]@ 8 b]@ *. 3 a]@ 6 b]@ *. - 0 a]@ 10 b]@ *. - over *. b!+
    12 a]@ 4 b]@ *. 13 a]@ 2 b]@ *. - 15 a]@ 0 b]@ *. + over *. b!+
	9 a]@ 2 b]@ *. 11 a]@ 0 b]@ *. - 8 a]@ 4 b]@ *. - over *. b!+
	
	5 a]@ 7 b]@ *. 6 a]@ 6 b]@ *. - 4 a]@ 9 b]@ *. - over *. b!+
    0 a]@ 9 b]@ *. 1 a]@ 7 b]@ *. - 2 a]@ 6 b]@ *. + over *. b!+
	13 a]@ 1 b]@ *. 14 a]@ 0 b]@ *. - 12 a]@ 3 b]@ *. - over *. b!+
    8 a]@ 3 b]@ *. 9 a]@ 1 b]@ *. - 10 a]@ 0 b]@ *. + *. b!
	128 'mat> +! ;

	
|-------------- rota directo -----------------------------
#cox #coy #coz
#six #siy #siz

::calcrot | rx ry rz --
	sincos 'coz ! 'siz !
	sincos 'coy ! 'siy !
	sincos 'cox ! 'six !
	;

::makerot | x y z -- x' y' z'
	-rot | z x y
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

::matqua | 'quat --
	dup q4nor
	@+ dup dup + 'cox ! 'six !
	@+ dup dup + 'coy ! 'siy !
	@+ dup dup + 'coz ! 'siz !
	@ | w
	dup cox *. 'm31 ! dup coy *. 'm32 ! coz *. 'm33 !
	siy coy *. 'm21 ! siy coz *. 'm22 ! siz coz *. 'm23 !
	six cox *. 'm11 ! six coy *. 'm12 ! six coz *. 'm13 !
	mat> >a
	1.0 m21 m23 + - a!+
	m12 m33 + a!+
	m13 m32 - a!+
	0 a!+
    m12 m33 - a!+
    1.0 m11 m23 + - a!+
    m22 m31 + a!+
    0 a!+
    m13 m32 + a!+
    m22 m31 - a!+
    1.0 m11 m21 + - a!+
    0 a!+
	0 a!+ 0 a!+ 0 a!+ 1.0 a!
	;
	
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

|-- mat mult	
::mcpy | 'mat --	
	mat> 16 move ;

:mline | -- v
	a@+ b@ *. 32 b+
	a@+ b@ *. + 32 b+
	a@+ b@ *. + 32 b+
	a@+ b@ *. + ;
	
:mrow | adr -- adr'
	mline swap !+ -88 b+ -32 a+
	mline swap !+ -88 b+ -32 a+
	mline swap !+ -88 b+ -32 a+
	mline swap !+ -96 b+ -24 b+ ;
	
::m* | -- ; mult two prev mat and generate a new one
	mat> dup 128 - >a dup >b 128 +
	mrow mrow mrow mrow drop
	128 'mat> +!
	;

::mm* | 'mat --
	>b mat> dup >a 128 +
	mrow mrow mrow mrow drop
	128 'mat> +! ;

::mmi* | 'mat --
	>a mat> dup >b 128 +
	mrow mrow mrow mrow drop
	128 'mat> +! ;

::mtra | x y z -- ; traslate
	mat> dup >a 'mati 16 move 
	14 a]! 13 a]! 12 a]! ;

::mrot | rx ry rz -- ; rotate
	mat> dup >a 'mati 16 move 
	sincos 'coz ! 'siz !
	sincos 'coy ! 'siy !
	sincos 'cox ! 'six !
    coz coy *. 0 a]! |'m11 !
    cox siz *. coy *. six siy *. + 1 a]! |'m12 !
    six siz *. coy *. cox siy *. - 2 a]! |'m13 !
	siz neg 4 a]! |'m21 !
    cox coz *. 5 a]! |'m22 !
    six coz *. 6 a]! |'m23 !
    coz siy *. 8 a]! |'m31 !
    cox siz *. siy *. six coy *. - 9 a]! |'m32 !
    six siz *. siy *. cox coy *. + 10 a]! |'m33 !
	;

::mpos | x y z --
	mat> >a 14 a]! 13 a]! 12 a]! ;

::mrpos | r16 x y z -- ; r=....xxxxyyyyzzzz rot
	mat> >a 
	1.0 15 a]! 14 a]! 13 a]! 12 a]!  | pos
	dup $ffff and sincos 'coz ! 'siz !
	dup 16 >> $ffff and sincos 'coy ! 'siy !
	32 >> $ffff and sincos 'cox ! 'six !
    coz coy *. a!+ |'m11 !
    cox siz *. coy *. six siy *. + a!+ |'m12 !
    six siz *. coy *. cox siy *. - a!+ |'m13 !
	0 a!+
	siz neg a!+ |'m21 !
    cox coz *. a!+ |'m22 !
    six coz *. a!+ |'m23 !
	0 a!+
    coz siy *. a!+ |'m31 !
    cox siz *. siy *. six coy *. - a!+ |'m32 !
    six siz *. siy *. cox coy *. + a!+ |'m33 !
	0 a!+
	;

|------ pack 3 rot in 48bits (16x3)	- gain space+vel (paralel add and rotation from here)
::packrota | rx ry rz -- rp
	$ffff and swap $ffff and 16 << or swap $ffff and 32 << or ;

::+rota | ra rb -- rr
	+ $100010001 nand ;

|------ pack 3 vel in 63bits (21x3)
::pack21 | vx vy vz -- vp
	$1fffff and swap
	$1fffff and 21 << or swap
	$1fffff and 42 << or ;
	
::+p21 | va vb -- vr
	+ $40000200001 nand ;

