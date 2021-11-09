| lorenz
| GALILEOG 2016
| +3d PHREDA 2016
| r3 PHREDA 2019,2021
|-------------------------------------------
^r3/win/console.r3
^r3/win/sdl2.r3

^r3/lib/3d.r3

#xcam 0 #ycam 0 #zcam -100.0

:fcircle | xc yc r --
	dup 2swap SDLFillellipse ;
	
#xo #yo	
:3dop project3d 'yo ! 'xo ! ;
:3dline project3d 2dup xo yo SDLLine 'yo ! 'xo ! ;

:3dpoint project3d msec 6 >> $7 and 4 and? ( $7 xor ) 1 + fcircle ;

:grillaxy
	-50.0 ( 50.0 <=?
		dup -50.0 0 3dop dup 50.0 0 3dline
		-50.0 over 0 3dop 50.0 over 0 3dline
		10.0 + ) drop ;

:grillayz
	-50.0 ( 50.0 <=?
		0 over -50.0 3dop 0 over 50.0 3dline
		0 -50.0 pick2 3dop 0 50.0 pick2 3dline
		10.0 + ) drop ;

:grillaxz
	-50.0 ( 50.0 <=?
		dup 0 -50.0 3dop dup 0 50.0 3dline
		-50.0 0 pick2 3dop 50.0 0 pick2 3dline
		10.0 + ) drop ;


|---- lorenz

#s 10.0
#p 28.0
#b 2.6666
#zoom 6.0
#dt 0.004

#x 10.0
#y 0.0
#z 10.0

:asigna
	y x - s *. dt *. 'x +!
	p z - x *. y - dt *. 'y +!
	x y *. b z *. - dt *. 'z +!
	;

#lorenz * 240000	| 10000 puntos...  24 (3 puntos de 8 bytes)
#lorenz> 'lorenz	| cursor

:lorenz!+ | z y x --
	asigna
	x y z
	lorenz> 'lorenz> =? ( 'lorenz nip ) | la direccion del cursor sirve de limite en el array
	!+ !+ !+
	'lorenz> ! ;

:lorenz3d
	lorenz!+
	lorenz!+
	lorenz!+
	lorenz!+
	lorenz!+

	lorenz>
	'lorenz> =? ( 'lorenz nip )	| ultimo punto
	dup @ over 8 + @ pick2 16 + @ 3dop
	24 +
	( 'lorenz> <?
		dup @ over 8 + @ pick2 16 + @
		3dline
		24 +
		) drop
	'lorenz ( lorenz> <?
		dup @ over 8 + @ pick2 16 + @
		3dline
		24 +
		) drop

	lorenz> 24 -
	'lorenz <? ( 'lorenz> 24 - nip )	| ultimo punto
	$ffffff SDLColor
	@+ swap @+ swap @ 3dpoint
	;

:teclado
	SDLkey
	>esc< =? ( exit )
	<up> =? ( 0.1 'zcam +! )
	<dn> =? ( -0.1 'zcam +! )
	<le> =? ( 0.1 'xcam +! )
	<ri> =? ( -0.1 'xcam +! )
	<pgdn> =? ( 0.1 'ycam +! )
	<pgup> =? ( -0.1 'ycam +! )
	drop
	;

|------ vista
#xm #ym
#rx #ry

:xypen SDLx SDLy ;

:dnlook
	xypen 'ym ! 'xm ! ;

:movelook
	xypen
	ym over 'ym ! - neg 7 << 'rx +!
	xm over 'xm ! - 7 << neg 'ry +!  ;

:demo
	
	|'dnlook 'movelook onDnMove
	
	movelook
	
	1.0 3dmode
	rx mrotx ry mroty
	xcam ycam zcam mtrans

	$0 SDLclear
	
	$1f1f1f SDLColor
	grillaxy grillayz grillaxz

	$ff0000 SDLColor
	lorenz3d
	SDLRedraw
	
	teclado
	;

:
	"r3sdl" 800 600 SDLinit
	SDLrenderer  0 0 0 $ff SDL_SetRenderDrawColor 
	dnlook
	'demo SDLshow
	
	SDLquit ;