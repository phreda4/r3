| 3dmath - PHREDA
|-------------------------
^r3/lib/math.r3

##xf ##yf
##ox ##oy

#mati | matrix id
1.0 0 0 0		| 1.0 = $10000
0 1.0 0 0
0 0 1.0 0
0 0 0 1.0
#mats * 1280 | 20 matrices
#mat> 'mats

::matini
	'mats dup 'mat> ! 'mati 16 move ;

::mpush | --
	mat> dup 128 + dup 'mat> ! swap 16 move ;

::mpop | --
	mat> |'mats =? ( drop ; )
	128 - 'mat> ! ;

::nmpop | n --
	7 << mat> swap - |'mats <? ( 'mats nip )
	'mat> ! ;

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

|-----------------------------
::mscale | x y z -- ; post
	mat> >a
	pick2 a@ *. a!+ pick2 a@ *. a!+ pick2 a@ *. a!+ rot a@ *. a!+
	over a@ *. a!+ over a@ *. a!+ over a@ *. a!+ swap a@ *. a!+
	dup a@ *. a!+ dup a@ *. a!+ dup a@ *. a!+ a@ *. a! ;

::mscalei | x y z --
	mat> >a
	pick2 a@ *. a!+ over a@ *. a!+ dup a@ *. a!+ 4 a+
	pick2 a@ *. a!+ over a@ *. a!+ dup a@ *. a!+ 4 a+
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
	pick2 *. >r pick2 neg *. r> + a> 8 + ! 12 a+
	a@ a> 16 + @ | s c a c
	pick2 pick2 *. pick4 pick2 *. + a!+
	pick2 *. >r pick2 neg *. r> + a> 8 + ! 12 a+
	a@ a> 16 + @ | s c a c
	pick2 pick2 *. pick4 pick2 *. + a!+
	pick2 *. >r pick2 neg *. r> + a> 8 + ! 12 a+
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
	transform
	0? ( 3drop ox oy ; )
	>r
	yf r@ */ oy + swap
	xf r> */ ox + swap ;

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

|------- vectores
::normInt2Fix | x y z -- xf yf zf
	pick2 dup * pick2 dup * + over dup * + sqrt
	1? ( 1.0 swap /. ) >r rot r@ *. rot r@ *. rot r> *. ;

::normFix | x y z -- x y z
	pick2 dup *. pick2 dup *. + over dup *. + sqrt.
	1? ( 1.0 swap /. ) >r rot r@ *. rot r@ *. rot r> *. ;
