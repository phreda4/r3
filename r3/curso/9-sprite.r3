^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3

#sprPelota	| dibujo
#xp 400.0 #yp 300.0		| posicion
#xv #yv		| velocidad

#zoom 1.0

:int. 16 >> ;
  
:teclado
	SDLkey
	>esc< =? ( exit )
	<w> =? ( -1.0 'yv ! )
	<s> =? ( 1.0 'yv ! )
	<a> =? ( -1.0 'xv ! )
	<d> =? ( 1.0 'xv ! )
	<f1> =? ( -0.01 'zoom +! )
	<f2> =? ( 0.01 'zoom +! )
	drop ;

	
:demo
	0 SDLcls
	
	xp int. yp int. zoom sprPelota SDLspriteZ
	SDLredraw

	xv 'xp +!
	yv 'yp +!
	
	xp 0 <? ( xv neg 'xv ! ) 800.0 >? ( xv neg 'xv ! ) drop
	yp 0 <? ( yv neg 'yv ! ) 600.0 >? ( yv neg 'yv ! ) drop
	
	teclado
	;


:main
	"r3sdl" 800 600 SDLinit
	"media/img/ball.png" loadimg 'sprpelota !
	'demo SDLshow
	SDLquit ;	
	
: main ;