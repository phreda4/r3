| 3dmath - PHREDA
|-------------------------
^r3/lib/sdl2.r3
^r3/lib/3dgl.r3

##xf ##yf
##ox ##oy

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
	-rot yf swap */ oy + ;

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
	-rot yf swap */ oy +
	;

::projectv | x y z -- u v
	rot xf pick2 */ ox +
	-rot yf swap */ oy +
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

|----------------------------
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


|------------- divisionless
| version r4
| debe haber una forma de optimizar esto mas

|::3dini
|	1024 sw - 1 >> neg 'ox !
|	1024 sh - 1 >> neg 'oy !
|	matini ;

|| 10 bit projection
|:c10 | x z -- x'
|	1 >> 0 swap over | x 0 z 0
|	pick3 >? ( over - rot )( over + rot 512 + ) rot 1 >> rot
|	pick3 >? ( over - rot )( over + rot 256 + ) rot 1 >> rot
|	pick3 >? ( over - rot )( over + rot 128 + ) rot 1 >> rot
|	pick3 >? ( over - rot )( over + rot 64 + ) rot 1 >> rot
|	pick3 >? ( over - rot )( over + rot 32 + ) rot 1 >> rot
|	pick3 >? ( over - rot )( over + rot 16 + ) rot 1 >> rot
|	pick3 >? ( over - rot )( over + rot 8 + ) rot 1 >> rot
|	pick3 >? ( over - rot )( over + rot 4+ ) rot 1 >> rot
|	pick3 >? ( over - rot )( over + rot 2 + ) rot 1 >> rot
|	pick3 >? ( 2drop )( 2drop 1 + )
|	nip ;

|::3dproject | x y z -- x y
|	rot over c10 ox + rot rot c10 oy + ;

|::3dproj | x y z -- x y
|	rot over c10 rot rot c10 ;