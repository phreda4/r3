| draw cube
| PHREDA 2025
^r3/lib/sdl2gfx.r3
^r3/lib/color.r3
^r3/lib/3d.r3
^r3/lib/rand.r3
^r3/util/pcfont.r3

|------------------------------
#xcam 0 #ycam 0 #zcam 30.0
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

#voxels * 4096
#voxelso * 4096


|-- v0
:drawv | x y z v -- x y z
	$f and 0? ( drop ; )
	2 << 'paleta + d@ 'facecolor !

	mpush
	pick2 16 << 3.5 -
	pick2 16 << 3.5 -
	pick2 16 << 3.5 -
	mtransi
	fillcube drawc 
	mpop
	;

:drawv0
	'voxelso >b
	0 ( 8 <? 
		0 ( 8 <?
			0 ( 8 <?
				pick2 pick2 3 << or over 6 << or | x y z 
				'voxels + c@ drawv				
				1+ ) drop
			1+ ) drop
		1+ ) drop ;
	
|-- v1	
#imask
	
:drawv | adr v -- adr
	$f and 0? ( drop ; ) 
	2 << 'paleta + d@ 'facecolor !
	dup imask xor
	mpush
	dup $7 and 16 << 3.5 -
	over 3 >> $7 and 16 << 3.5 -
	rot 6 >> $7 and 16 << 3.5 -
	mtransi
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
	
	x0 x1 - x7 * y0 y1 - y7 * + z0 z1 - z7 * + 63 >> $7 and 6 << 
	x0 x2 - x7 * y0 y2 - y7 * + z0 z2 - z7 * + 63 >> $7 and 3 << or
	x0 x4 - x7 * y0 y4 - y7 * + z0 z4 - z7 * + 63 >> $7 and or
	$1ff xor
	'imask !
	mpop
	
	0 ( $1ff <? | xx yy zz
		dup imask xor  | invert mask
		'voxels + c@ drawv
		1+ ) drop ;
		
:randvoxel
	'voxels >a 
	$1ff ( 1? 
		64 randmax
		15 >? ( 0 nip )
		ca!+ 
		1- ) drop 
	;

|------------------------------	
:freelook
	sdlb 0? ( drop ; ) drop
	SDLx SDLy
	sh 1 >> - 7 << swap
	sw 1 >> - neg 7 << swap
	neg 'xr ! 'yr ! ;

:main
	0 sdlcls
	$ff00 sdlcolor

	$ffffff pccolor
	0 0 pcat
	"cube" pcprint pccr
	imask "%b" pcprint
	
	freelook

	1.0 3dmode
	xr mrotx yr mroty 
	xcam ycam zcam mtrans

	|drawv0
	drawv1
	
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	<f1> =? ( randvoxel )
	<f2> =? ( imask $7 xor 'imask ! )
	<f3> =? ( imask $38 xor 'imask ! )
	<f4> =? ( imask $1c0 xor 'imask ! )
	
	drop 
	;

: 
	"cube" 1024 720 SDLinit
	pcfont
	
	'main sdlshow
	SDLquit ;
