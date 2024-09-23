| 3dworld - no opengl
| PHREDA 2023
|-----
^r3/lib/rand.r3
^r3/lib/3d.r3
^r3/lib/sdl2gfx.r3
^r3/util/arr16.r3
^r3/util/varanim.r3
^r3/util/boxtext.r3
^r3/util/sdlgui.r3

#listobj 0 0
#listfx 0 0

|-------------------------------		
#xcam 0 #ycam 0 #zcam -40.0
#xr 0 #yr 0

:freelook
	sdlb 0? ( drop ; ) drop
	SDLx SDLy
	sh 1 >> - 7 << swap
	sw 1 >> - neg 7 << swap
	neg 'xr ! 'yr ! ;

|---------------------------------	
#xop #yop
:xxop 'yop ! 'xop ! ;
:xxline 2dup xop yop SDLLine 'yop ! 'xop ! ;

:3dop project3d xxop ;
:3dline project3d xxline ;

:drawboxz | z --
	-1.0 -1.0 pick2 3dop
	1.0 -1.0 pick2 3dline
	1.0 1.0 pick2 3dline
	-1.0 1.0 pick2 3dline
	-1.0 -1.0 rot 3dline ;

:drawlinez | x1 x2 --
	2dup -1.0 3dop 1.0 3dline ;

:drawcube |
	-1.0 drawboxz
	1.0 drawboxz
	-1.0 -1.0 drawlinez
	1.0 -1.0 drawlinez
	1.0 1.0 drawlinez
	-1.0 1.0 drawlinez ;	
	
	
:packscale | x y z -- s
	rot 8 >> rot 8 >> rot 8 >> pack21 ;

:unpackscale | s -- x y z 
	dup 42 >> $1fffff and 8 <<
	over 21 >> $1fffff and 8 <<
	rot $1fffff and 8 << ;

:unpackrot
	dup 32 >> $ffff and mrotxi 
	dup 16 >> $ffff and mrotyi 
	$ffff and mrotzi ;
	
|---------------------------------
|disparo
| x y z rxyz sxyz vxyz vrxyz
| 1 2 3 4    5    6    7     
:.x		1 ncell+ ;
:.y		2 ncell+ ;
:.z		3 ncell+ ;
:.rxyz 	4 ncell+ ;
:.sxyz	5 ncell+ ;
:.vxyz	6 ncell+ ;
:.vrxyz	7 ncell+ ;
:.anim	8 ncell+ ;
:.va	9 ncell+ ;

:ocube | adr -- adr
	mpush
	8 + >b
	b@+ b@+ b@+ mtransi
	b@+ unpackrot
	b@+ unpackscale mscalei
	drawcube
	mpop
	;
	
:+obj | s r x y z --
	'ocube 'listobj p!+ >a
	rot a!+ swap a!+ a!+
	a!+ a!+
	;
	
|-------------------------------	
:juego
	0 sdlcls
	$ff00 sdlcolor

	freelook
	
	1.0 3dmode
	xr mrotx yr mroty 
	xcam ycam zcam mtrans
	
	'listobj p.draw

	SDLredraw
	SDLkey
	>esc< =? ( exit )
	drop
	;	
	
:jugar 
	'listfx p.clear
	'listobj p.clear
	20 ( 1? 1-
		2.0 randmax 0.1 +
		2.0 randmax 0.1 +
		2.0 randmax 0.1 +
		packscale
		1.0 randmax
		1.0 randmax
		1.0 randmax
		packrota
		20.0 randmax 10.0 -
		20.0 randmax 10.0 -
		20.0 randmax 10.0 -
		+obj
		) drop
	'juego SDLShow 
	;
	
|-------------------------------------
:main
	"3d world" 1024 600 SDLinit
	
	100 'listfx p.ini
	200 'listobj p.ini
	jugar
	SDLquit ;	
	
: main ;