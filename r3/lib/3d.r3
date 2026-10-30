| 3dmath - PHREDA
|-------------------------
^r3/lib/sdl2.r3
^r3/lib/3dgl.r3

##xf | horizontal scale (focal length in pixels) used by the projections
##yf | vertical scale (focal length in pixels) used by the projections
##ox | x of the screen origin (center) in pixels, added by the projections
##oy | y of the screen origin (center) in pixels, added by the projections

|-----------------------------
::2dmode | -- ; 2d mode: put the origin ox oy at the center of the screen
	sw 1 >> 'ox !
	sh 1 >> 'oy !
	;

::3dmode | fov -- ; perspective mode: xf = yf = fov * screen height (fixed point), origin at the screen center, matrix reset (matini)
	sh *. dup 'yf ! 'xf !
	sw 1 >> 'ox !
	sh 1 >> 'oy !
	matini
	;

|----------------------------
::Omode | -- ; orthogonal mode: 1.0 unit = the smaller side of the screen (xf = yf = min(sw, sh)), origin at the center, matrix reset
	sw dup 1 >> 'ox !
	sh dup 1 >> 'oy !
	min dup 'xf ! 'yf !
	matini
	;
	

::whmode | w h -- ; like Omode for an area of w x h pixels: origin at its center, xf = yf = min(w, h), matrix reset
	over 1 >> 'ox ! 
	dup 1 >> 'oy !
	min dup 'xf ! 'yf !
	matini
	;

|----------------------------
::o3dmode | w h -- ; same as whmode
	dup 1 >> 'oy !
	over 1 >> 'ox !
	min dup 'xf ! 'yf !
	matini ;

::p3d | x y z -- x y ; perspective projection: x*xf/z + ox, y*yf/z + oy (z = 0 crashes)
	dup >r
	yf swap */ oy + swap
	xf r> */ ox + swap ;

::p3dz | x y z -- x y z ; like p3d, keeping z
	rot xf pick2 */ ox + | y z x'
	rot yf pick3 */ oy +
	rot ;

::p3di | x y z -- z y x ; like p3d but returns z y' x' (x' on top)
	swap yf pick2 */ oy +	| x z y'
	rot xf pick3 */ ox + ;	| z y' x'

|----------------------------
::project3d | x y z -- u v ; transform the point with the current matrix and project it (the center ox oy if the transformed z is 0)
	transform 0? ( 3drop ox oy ; ) | x y z
	rot xf pick2 */ ox + | y z x'
	-rot yf swap */ oy + ;

::project3dz | x y z -- z x y ; like project3d, also returns the transformed z (y' on top)
	transform
	0? ( 3drop ox oy 1 ; )
	rot xf pick2 */ ox + | y z X
	rot yf pick3 */ oy + ;

::invproject3d | x y z -- x y ; screen point x y at depth z back to the 3d plane: (x-ox)*z/xf, (y-oy)*z/yf
	>r
	oy - r@ yf */ swap
	ox - r> xf */ swap ;

::projectdim | x y z -- u v ; project a size (no ox oy): transform with the current matrix, then x*xf/z', y*yf/z'; 0 0 if z' = 0
	transform
	0? ( 3drop 0 0 ; )
	>r
	yf r@ */ swap
	xf r> */ swap ;

::project | x y z -- u v ; project an already transformed point (no matrix): x*xf/z + ox, y*yf/z + oy; the center if z = 0
	0? ( 3drop ox oy ; )
	rot xf pick2 */ ox +
	-rot yf swap */ oy +
	;

::projectv | x y z -- u v ; like project without the z = 0 check
	rot xf pick2 */ ox +
	-rot yf swap */ oy +
	;

::inscreen | -- x y ; screen position of the origin of the current matrix (the center if its z is 0)
	oxyztransform
	0? ( 3drop ox oy ; )
	>r
	yf r@ */ oy + swap
	xf r> */ ox + swap ;

::proyect2d | x y z -- x y ; no projection: x+ox, y+oy (z is dropped)
	drop oy + swap ox + swap ;

::aspect | -- a ; screen aspect ratio sw/sh (fixed point)
	sw sh 16 <</ ;

|----------------------------
::mtrans | x y z -- ; translate the current matrix by x y z along the parent (world) axes: adds to its translation
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

::mtransi | x y z -- ; translate the current matrix by x y z along its own (local) axes
	mat> >a
	pick2 a@+ *. pick2 a@+ *. + over a@+ *. + a@ + a!+
	pick2 a@+ *. pick2 a@+ *. + over a@+ *. + a@ + a!+
	rot a@+ *. rot a@+ *. + swap a@+ *. + a@ + a! ;
	
::mrotxi | x -- ; rotate the current matrix around X by x (1.0 = full turn), translation unchanged; at 0.25 (0,1,0) goes to (0,0,-1)
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
	
::mrotyi | y -- ; rotate the current matrix around Y by y (1.0 = full turn), translation unchanged; at 0.25 (1,0,0) goes to (0,0,1)
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
	
::mrotzi | z -- ; rotate the current matrix around Z by z (1.0 = full turn), translation unchanged; at 0.25 (1,0,0) goes to (0,-1,0)
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

|::p3d1 | x y z -- x y ; like p3d with a fixed focal length of 512 pixels (xf yf are not used)
|	dup >r
|	9 <</ oy + swap
|	r> 9 <</ ox + swap ;

|::p3di1 | x y z -- z y x ; like p3di with a fixed focal length of 512 pixels
|	swap over 9 <</ oy +	| x z y'
|	rot pick2 9 <</ ox + ;	| z y' x'

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