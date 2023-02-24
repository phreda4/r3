| 3dmath - PHREDA
|-------------------------

^r3/lib/vec3.r3
^r3/win/sdl2.r3

##xf ##yf
##ox ##oy

#mati | matrix id
1.0 0 0 0		| 1.0 = $10000
0 1.0 0 0
0 0 1.0 0
0 0 0 1.0
#mats * 2560 | 20 matrices
##mat> 'mats

::matini
	'mats dup 'mat> ! 'mati 16 move ;

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

::mcpyf | fmat --
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

::mper 
	mat> dup >a 'mati 16 move 
	rot pick3 *. 1.0 swap /. 	a!+	0 a!+ 0 a!+ 0 a!+ 	| ang near far	[1 1] !
	0 a!+ rot 1.0 swap /. 		a!+	0 a!+ 0 a!+			| near far		[2 2] !
	swap
	0 a!+ 0 a!+
	2dup + neg pick2 pick2 - /. 	a!+ -1.0 a!+ 
	0 a!+ 0 a!+ 
	2dup *. 1 << neg rot rot - /.	a!+ 0 a!+
	;

::mperspective | near far contang aspect  --
	mat> dup >a 'mati 16 move 
	over *. a!		|mat[0] = cotangent / aspect;
	5 a]!			|mat[5] = cotangent;
	2dup -			| near far deltaz
	pick2 pick2 + over /. 10 a]!	|mat[10] = (zFar + zNear) / deltaZ;
	-1.0 11 a]! 					|mat[11] = -1;
	rot rot *. 1 << swap /. 14 a]!	|mat[14] = (2 * zFar * zNear) / deltaZ;
	0 15 a]!						|mat[15] = 0;
	;
	
::mortho | r l t b f n --
	mat> dup >a 'mati 16 move 
	2dup - -2.0 over /. 10 a]!		| 	mat[10] = -2 / (farVal - nearVal);
	rot rot + swap /. neg 14 a]!	| mat[14] = -((farVal + nearVal) / (farVal - nearVal));
	2dup - 2.0 over /. 5 a]!		| mat[5] = 2 / (top - bottom);
	rot rot + swap /. neg 13 a]!	| mat[13] = -((top + bottom) / (top - bottom));
	2dup - 2.0 over /. a> !			| mat[0] = 2 / (right - left);
	rot rot + swap /. neg 12 a]!	| mat[12] = -((right + left) / (right - left));
	;
	
#fx 0 #fy 0 #fz 0 
#sx 0 #sy 0 #sz 0
#ux 0 #uy 0 #uz 0 

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

|-- mat mult	
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
	
::mcpy | 'mat --	
	mat> 16 move ;
	
|-----------------------------
::mtrans | x y z --
	mat> >a
	pick2 a> 96 + @ *. a@ + a!+
	pick2 a> 96 + @ *. a@ + a!+
	pick2 a> 96 + @ *. a@ + a!+
	rot a@ + a!+
	over a> 64 + @ *. a@ + a!+
	over a> 64 + @ *. a@ + a!+
	over a> 64 + @ *. a@ + a!+
	swap a@ + a!+
	dup a> 32 + @ *. a@ + a!+
	dup a> 32 + @ *. a@ + a!+
	dup a> 32 + @ *. a@ + a!+
	a> +! ;

::mtransi | x y z -- ;pre
	mat> >a
	pick2 a@+ *. pick2 a@+ *. + over a@+ *. + a@ + a!+
	pick2 a@+ *. pick2 a@+ *. + over a@+ *. + a@ + a!+
	rot a@+ *. rot a@+ *. + swap a@+ *. + a@ + a! ;

::mtran | x y z --
	mat> >a
	pick2 0 a]@ *. pick2 4 a]@ *. + over 8 a]@ *. + 12 a]+!
	pick2 1 a]@ *. pick2 5 a]@ *. + over 9 a]@ *. + 13 a]+!
	pick2 2 a]@ *. pick2 6 a]@ *. + over 10 a]@ *. + 14 a]+!
	pick2 3 a]@ *. pick2 7 a]@ *. + over 11 a]@ *. + 15 a]+!
	3drop
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

|-----------------------------
::mrotx | x -- ; posmultiplica
	0? ( drop ; )
	mat> 32 + >a
	dup sin swap cos
	a@ a> 32 + @ | s c e i
	pick2 pick2 *. pick4 pick2 *. + a!+
	pick2 *. >r pick2 neg *. r> + a> 24 + !
	a@ a> 32 + @ | s c f j
	pick2 pick2 *. pick4 pick2 *. + a!+
	pick2 *. >r pick2 neg *. r> + a> 24 + !
	a@ a> 32 + @ | s c g k
	pick2 pick2 *. pick4 pick2 *. + a!+
	pick2 *. >r pick2 neg *. r> + a> 24 + !
	a@ a> 32 + @ | s c h l
	pick2 pick2 *. pick4 pick2 *. + a!+
	rot *. >r *. r> + a> 24 + ! ;

::mrotxi |x -- ; premultiplica
	0? ( drop ; )
	mat> 8 + >a
	dup sin swap cos
	a@ a> 8 + @ | s c b c
	pick2 pick2 *. pick4 neg pick2 *. + a!+ | s c b c
	pick2 *. >r pick2 *. r> + a!+ 16 a+
	a@ a> 8 + @ | s c f g
	pick2 pick2 *. pick4 neg pick2 *. + a!+
	pick2 *. >r pick2 *. r> + a!+ 16 a+
	a@ a> 8 + @ | s c j k
	pick2 pick2 *. pick4 neg pick2 *. + a!+
	pick2 *. >r pick2 *. r> + a!+ 16 a+
	a@ a> 8 + @ | s c m o
	pick2 pick2 *. pick4 neg pick2 *. + a!+
	rot *. >r *. r> + a! ;

|-----------------------------
::mroty | y  --
	0? ( drop ; )
	mat> >a
	dup sin swap cos
	a@ a> 64 + @ pick2 pick2 *. pick4 pick2 *. + a!+
	pick2 *. >r pick2 neg *. r> + a> 56 + !
	a@ a> 64 + @ pick2 pick2 *. pick4 pick2 *. + a!+
	pick2 *. >r pick2 neg *. r> + a> 56 + !
	a@ a> 64 + @ pick2 pick2 *. pick4 pick2 *. + a!+
	pick2 *. >r pick2 neg *. r> + a> 56 + !
	a@ a> 64 + @ pick2 pick2 *. pick4 pick2 *. + a!+
	rot *. >r swap neg *. r> + a> 56 + ! ;

::mrotyi | y --
	0? ( drop ; )
	mat> >a
	dup sin swap cos
	a@ a> 16 + @ | s c a c
	pick2 pick2 *. pick4 pick2 *. + a!+
	pick2 *. >r pick2 neg *. r> + a> 8 + ! 24 a+
	a@ a> 16 + @ | s c a c
	pick2 pick2 *. pick4 pick2 *. + a!+
	pick2 *. >r pick2 neg *. r> + a> 8 + ! 24 a+
	a@ a> 16 + @ | s c a c
	pick2 pick2 *. pick4 pick2 *. + a!+
	pick2 *. >r pick2 neg *. r> + a> 8 + ! 24 a+
	a@ a> 16 + @ | s c a c
	pick2 pick2 *. pick4 pick2 *. + a!+
	rot *. >r swap neg *. r> + a> 8 + ! ;

|-----------------------------
::mrotz | z --
	0? ( drop ; )
	mat> >a
	dup sin swap cos
	a@ a> 32 + @ | s c e i
	pick2 pick2 *. pick4 pick2 *. + a!+
	pick2 *. >r pick2 neg *. r> + a> 24 + !
	a@ a> 32 + @ | s c e i
	pick2 pick2 *. pick4 pick2 *. + a!+
	pick2 *. >r pick2 neg *. r> + a> 24 + !
	a@ a> 32 + @ | s c e i
	pick2 pick2 *. pick4 pick2 *. + a!+
	pick2 *. >r pick2 neg *. r> + a> 24 + !
	a@ a> 32 + @ | s c e i
	pick2 pick2 *. pick4 pick2 *. + a!+
	rot *. >r *. r> + a> 24 + ! ;

::mrotzi | z --
	0? ( drop ; )
	mat> >a
	dup sin swap cos
	a@ a> 8 + @ | s c a b
	pick2 pick2 *. pick4 neg pick2 *. + a!+
	pick2 *. >r pick2 *. r> + a!+ 16 a+
	a@ a> 8 + @ | s c a b
	pick2 pick2 *. pick4 neg pick2 *. + a!+
	pick2 *. >r pick2 *. r> + a!+ 16 a+
	a@ a> 8 + @ | s c a b
	pick2 pick2 *. pick4 neg pick2 *. + a!+
	pick2 *. >r pick2 *. r> + a!+ 16 a+
	a@ a> 8 + @ | s c a b
	pick2 pick2 *. pick4 neg pick2 *. + a!+
	rot *. >r *. r> + a! ;


|-----------------------------
:invierte
	over @ over @ swap rot ! swap ! ;

::matinv
	mat> >a
	a> 24 + @  neg a> 56 + @  neg a> 88 + @ neg | tx ty tz
	a> 8 + dup 24 + invierte a> 16 + dup 48 + invierte a> 48 + dup 24 + invierte
	pick2 a@  *. pick2 a> 8 + @ *. + over a> 16 + @  *. + a> 24 + !
	pick2 a> 32 + @  *. pick2 a> 40 + @  *. + over a> 48 + @  *. + a> 56 + !
	rot a> 64 + @  *. rot a> 72 + @  *. + swap a> 80 + @  *. + a> 88 + !
	;

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

|-----------------------------
::2dmode | --
	sw 1 >> 'ox !
	sh 1 >> 'oy !
	;

::3dmode | fov --
	sh *. dup 'yf ! 'xf !
	sw 1 >> 'ox !
	sh 1 >> 'oy !
	matini
	;

|----------------------------
::Omode | --
	sw dup 1 >> 'ox !
	sh dup 1 >> 'oy !
	min dup 'xf ! 'yf !
	matini
	;
	

::whmode | w h --
	over 1 >> 'ox ! 
	dup 1 >> 'oy !
	min dup 'xf ! 'yf !
	matini
	;

|----------------------------
::o3dmode | w h --
	dup 1 >> 'oy !
	over 1 >> 'ox !
	min dup 'xf ! 'yf !
	matini ;

::p3d | x y z -- x y
	dup >r
	yf swap */ oy + swap
	xf r> */ ox + swap ;

::p3dz | x y z -- x y z
	rot xf pick2 */ ox + | y z x'
	rot yf pick3 */ oy +
	rot ;

::p3di | x y z -- z y x
	swap yf pick2 */ oy +	| x z y'
	rot xf pick3 */ ox + ;	| z y' x'

::p3ditest | x y z -- z y x
	xf over 20 <</ >r | 20 bits
	swap r@ 20 *>> oy +
	rot r> 20 *>> ox + ;

::p3dizb | x y z -- z y x
	swap over 20 *>> oy +
	rot pick2 20 *>> ox + ;

::p3dcz | z -- 1/z
	0? ( 1 nip )
	xf swap 20 <</ ;

|----------------------------

::p3d1 | x y z -- x y
	dup >r
	9 <</ oy + swap
	r> 9 <</ ox + swap ;

::p3di1 | x y z -- z y x
	swap over 9 <</ oy +	| x z y'
	rot pick2 9 <</ ox + ;	| z y' x'

::project3d | x y z -- u v
	transform 0? ( 3drop ox oy ; ) | x y z
	rot xf pick2 */ ox + | y z x'
	rot rot yf swap */ oy + ;

::project3dz | x y z -- z x y
	transform
	0? ( 3drop ox oy 1 ; )
	rot xf pick2 */ ox + | y z X
	rot yf pick3 */ oy + ;

::invproject3d | x y z -- x y
	>r
	oy - r@ yf */ swap
	ox - r> xf */ swap ;

::projectdim | x y z -- u v
	transform
	0? ( 3drop 0 0 ; )
	>r
	yf r@ */ swap
	xf r> */ swap ;

::project | x y z -- u v
	0? ( 3drop ox oy ; )
	rot xf pick2 */ ox +
	rot rot yf swap */ oy +
	;

::projectv | x y z -- u v
	rot xf pick2 */ ox +
	rot rot yf swap */ oy +
	;

::inscreen | -- x y
	oxyztransform
	0? ( 3drop ox oy ; )
	>r
	yf r@ */ oy + swap
	xf r> */ ox + swap ;

::proyect2d | x y z -- x y
	drop oy + swap ox + swap ;

::aspect | -- a
	sw sh 16 <</ ;

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

|-------- with matrix in var
::mmcpy | 'mat --
	mat> 16 move ;

::mm* | 'mat --
	>b mat> dup >a 128 +
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

::mrpos | r x y z -- ; r=....xxxxyyyyzzzz rot
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
	+ $100010001 not and ;

|------ pack 3 vel in 60bits (20x3) - gain space
::packvpos | vx vy vz -- vp
	8 >> $fffff and swap
	8 >> $fffff and 20 << or swap
	8 >> $fffff and 40 << or ;
	
::+vpos | va vb -- vr
	+ $10000100001 not and ;

::vpos.x 4 << 36 >> ;
::vpos.y $fffff00000 and 24 << 36 >> ;
::vpos.z $fffff and 44 << 36 >> ;

