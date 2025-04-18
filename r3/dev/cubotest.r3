| draw cube
| PHREDA 2025
^r3/lib/sdl2gfx.r3
^r3/lib/color.r3
^r3/lib/3d.r3
^r3/lib/rand.r3
^r3/util/pcfont.r3
^r3/util/sortradixm.r3
^r3/util/sort.r3

|------------------------------
#xcam 0 #ycam 0 #zcam 40.0
#xr #yr

#rotsum * 64

#x0 #y0 #z0
#x1 #y1 #z1
#x2 #y2 #z2
#x4 #y4 #z4

#x7 #y7 #z7	| centro del cubo

#vert [ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ]
#index [ 0 1 2 2 3 0 ]

#facecolor $ff00

:aclara
    facecolor $f0f0f colavg 'facecolor ! ;

:fillcube | --
	'rotsum >b
	0.5 0.5 0.5			| 111
	transform dup 'z0 ! over 'y0 ! pick2 'x0 ! project db!+ db!+
	0.5 0.5 -0.5		| 110
	transform dup 'z1 ! over 'y1 ! pick2 'x1 ! project db!+ db!+
	0.5 -0.5 0.5		| 101
	transform dup 'z2 ! over 'y2 ! pick2 'x2 ! project db!+ db!+
	0.5 -0.5 -0.5		| 100
	transform project db!+ db!+
	-0.5 0.5 0.5		| 011
	transform dup 'z4 ! over 'y4 ! pick2 'x4 ! project db!+ db!+
	-0.5 0.5 -0.5		| 010
	transform project db!+ db!+	
	-0.5 -0.5 0.5		| 001
	transform project db!+ db!+	
	-0.5 -0.5 -0.5		| 000
	transform dup z0 + 2/ 'z7 ! over y0 + 2/ 'y7 ! pick2 x0 + 2/ 'x7 !
	project db!+ db!+
	;

:getn | n -- u v
	3 << 'rotsum + d@+ swap d@ ;
	
:setn | u v --
	i2fp da!+ i2fp da!+ facecolor da!+ 8 a+ ;
	
:cara
	'vert >a
	dup $7 and getn 
	2dup 'y0 ! 'x0 !
	setn
	4 >> dup $7 and getn 
	2dup y0 - 'y1 ! x0 - 'x1 !
	setn
	4 >> dup $7 and getn 
	2dup y0 - 'y2 ! x0 - 'x2 !
	
	x1 y2 * y1 x2 * -
	|x1 x0 - y2 y0 - * y1 y0 - x2 x0 - * - 
	+? ( 3drop 8 >> ; ) drop | CCW?

	setn
	4 >> dup $7 and getn setn
	4 >>
	SDLrenderer 0 'vert 4 'index 6 SDL_RenderGeometry 
	;

#caras 
$015446202310 $540113750231 $673220462310 $326775133102 
$015446204576 $401551377645 $732662046457 $732675137645

:drawc | --
	x0 x1 - x7 * y0 y1 - y7 * + z0 z1 - z7 * + 63 >> $1 and
	x0 x2 - x7 * y0 y2 - y7 * + z0 z2 - z7 * + 63 >> $2 and or
	x0 x4 - x7 * y0 y4 - y7 * + z0 z4 - z7 * + 63 >> $4 and or
	$7 xor 3 << 'caras + @ 
	cara aclara cara aclara cara 
	drop ;

|------------------------------	
#paleta [ | uchu
$080a0d $0949ac $b56227 $2e943a
$542690 $a30d30 $fdfdfd $b59944
$878a8b $3984f2 $ff9f5b $64d970
$915ad3 $ea3c65 $cbcdcd $fedf7b ]

#voxels * $ffff

|-------------- v1 without sort
#imask

:o1 |123
	;
:o2 |132
	dup 4 << $f0 and over 4 >> $f and or swap $f00 and or ;
:o3 |213
	dup 4 << $f00 and over 4 >> $f0 and or swap $f and or ;
:o4 |231
	dup 8 >> $f and swap 4 << $ff0 and or ;
:o5 |312
	dup 8 << $f00 and swap 4 >> $ff and or ;
:o6 |321
	dup 8 >> $f and over 8 << $f00 and or swap $f0 and or ;
	

#nn	
#oo 'o1

:testkey
	<f2> =? ( 'o1 'oo ! )
	<f3> =? ( 'o2 'oo ! )
	<f4> =? ( 'o3 'oo ! )
	<f5> =? ( 'o4 'oo ! )
	<f6> =? ( 'o5 'oo ! )
	<f7> =? ( 'o6 'oo ! )
	;
	
:xyz2tran | n - x y z
	dup $f and 16 << 7.5 -
	over 4 >> $f and 16 << 7.5 -
	rot 8 >> $f and 16 << 7.5 -
	;
| 8*8*8	
|	dup $7 and 16 << 3.5 -
|	over 3 >> $7 and 16 << 3.5 -
|	rot 6 >> $7 and 16 << 3.5 -


:drawv | adr v -- adr
	$f and 0? ( drop ; ) 
	2 << 'paleta + d@ 'facecolor !
	dup imask xor oo ex 
	mpush
	xyz2tran mtransi
	fillcube drawc 
	mpop
	;
	
:drawv1
	mpush
	 1.0 1.0 1.0 transform 'z0 ! 'y0 ! 'x0 !
	1.0 1.0 -1.0 transform 'z1 ! 'y1 ! 'x1 !
	1.0 -1.0 1.0 transform 'z2 ! 'y2 ! 'x2 !
	-1.0 1.0 1.0 transform 'z4 ! 'y4 ! 'x4 !
	0 0 0 transform 'z7 ! 'y7 ! 'x7 !
	
| 8*8*8	
|	x0 x1 - x7 * y0 y1 - y7 * + z0 z1 - z7 * + 63 >> $7 and 6 << 
|	x0 x2 - x7 * y0 y2 - y7 * + z0 z2 - z7 * + 63 >> $7 and 3 << or
|	x0 x4 - x7 * y0 y4 - y7 * + z0 z4 - z7 * + 63 >> $7 and or
|	$1ff xor

	x0 x1 - x7 * y0 y1 - y7 * + z0 z1 - z7 * + 63 >> $f and 8 << 
	x0 x2 - x7 * y0 y2 - y7 * + z0 z2 - z7 * + 63 >> $f and 4 << or
	x0 x4 - x7 * y0 y4 - y7 * + z0 z4 - z7 * + 63 >> $f and or
	$fff xor
	'imask !
	mpop

	0 ( $fff <=? | xx yy zz | 8=1ff
		dup imask xor oo ex   | invert mask
		'voxels + c@ drawv
		1+ ) drop ;
		
		
|--- 3D x y z . 10 bits
:m1 | x -- v
	$f and
	dup 4 << or $c3 and
	dup 2 << or $249 and ;

:morton3d | xyz -- Z
	dup m1
	over 4 >> m1 1 << or
	swap 8 >> m1 2 << or ;

:drawv | adr v -- adr
	$f and 0? ( drop ; ) 
	2 << 'paleta + d@ 'facecolor !
	dup imask xor
	morton3d
	mpush
	xyz2tran mtransi
	fillcube drawc 
	mpop
	;

:drawv3
	mpush
	 1.0 1.0 1.0 transform 'z0 ! 'y0 ! 'x0 !
	1.0 1.0 -1.0 transform 'z1 ! 'y1 ! 'x1 !
	1.0 -1.0 1.0 transform 'z2 ! 'y2 ! 'x2 !
	-1.0 1.0 1.0 transform 'z4 ! 'y4 ! 'x4 !
	0 0 0 transform 'z7 ! 'y7 ! 'x7 !
	x0 x1 - x7 * y0 y1 - y7 * + z0 z1 - z7 * + 63 >> $f and 8 << 
	x0 x2 - x7 * y0 y2 - y7 * + z0 z2 - z7 * + 63 >> $f and 4 << or
	x0 x4 - x7 * y0 y4 - y7 * + z0 z4 - z7 * + 63 >> $f and or
	$fff xor
	'imask !
	mpop

	0 ( $fff <=? | xx yy zz | 8=1ff
		dup imask xor    | invert mask
		morton3d
		'voxels + c@ drawv
		1+ ) drop ;

|------ version 2 with sort
:+voxel | adr vox -- ; add to voxel list
	over xyz2tran 
	transform 
	dup * swap dup * + swap dup * +  | real distance 
	|abs swap abs + swap abs + | manhatan distance
|	dup * swap abs + swap abs +
	neg 16 >>
	$ffff nand or over 4 << or | add pos and color
	dup b!+	
	;
	
:dvoxel | va -- ; draw voxel
	dup $f and 2 << 'paleta + d@ 'facecolor !
	mpush
	4 >> $fff and xyz2tran mtransi
	fillcube drawc 
	mpop
	;
	
:drawv2
	here >b
	0 ( $fff <=? | xx yy zz | 8=1ff
		dup 'voxels + c@ 
		1? ( +voxel ) 
		drop 1+ ) drop 
	0 b!
	here b> over - 3 >> swap shellsort1
	here ( @+ 1? dvoxel ) 2drop
	;
		
:randvoxel
	'voxels >a 
	$1000 ( 1? | 8=1ff
		|256 randmax 
		14 randmax 1+
		15 >? ( 0 nip )
		ca!+ 
		1- ) drop ;

|------------------------------	
:freelook
	sdlb 0? ( drop ; ) drop
	SDLx SDLy	
	sh 1 >> - 7 << swap
	sw 1 >> - neg 7 << swap
	neg 'xr ! 'yr ! 
	;


:main
	0 sdlcls
	$ff00 sdlcolor

	$ffffff pccolor
	0 0 pcat
	"cube" pcprint pccr
	
	freelook

	1.0 3dmode
	xr mrotx yr mroty 
	xcam ycam zcam mtrans

	|drawv1
	drawv2
	|drawv3
	
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	<f1> =? ( randvoxel )
	|testkey	
	drop 
	;

: 
	"cube" 1024 720 SDLinit
	pcfont
	'main sdlshow
	SDLquit ;
