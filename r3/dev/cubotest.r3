| draw cube
| PHREDA 2025
^r3/lib/sdl2gfx.r3
^r3/lib/color.r3
^r3/lib/3d.r3

|------------------------------
#xcam 0 #ycam 0 #zcam 8.0
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

:getn | n --
	3 << 'rotsum + d@+ swap d@
	i2fp da!+ i2fp da!+ facecolor da!+ 8 a+ ;

:cara
	'vert >a
	dup $7 and getn
	4 >> dup $7 and getn
	4 >> dup $7 and getn
	4 >> dup $7 and getn
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
	$7 xor | mask
	3 << 'caras + @ 
	cara aclara cara aclara cara 
	drop ;

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

	freelook

	1.0 3dmode
	xr mrotx yr mroty 
	xcam ycam zcam mtrans

	mpush
	-1.0 -1.0 0  mtransi
	$ff00 'facecolor !
	fillcube drawc 
	mpop

	mpush
	$ff00ff 'facecolor !
	fillcube drawc 
	mpop
	
	mpush
	1.0 1.0 0  mtransi
	$ff 'facecolor !
	fillcube drawc 
	mpop

	
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	drop 
	;

: 
	"cube" 1024 720 SDLinit
	'main sdlshow
	SDLquit ;
