^r3/win/sdl2.r3
^r3/win/sdl2image.r3

#sprPelota	| dibujo
#xp 100.0 #yp 100.0		| posicion
#xv #yv		| velocidad

:int. 16 >> ;

:teclado
	SDLkey
	>esc< =? ( exit )
	<w> =? ( -1.0 'yv ! )
	<s> =? ( 1.0 'yv ! )
	<a> =? ( -1.0 'xv ! )
	<d> =? ( 1.0 'xv ! )
	drop ;

	
:demo
	0 SDLClear
	xp int. yp int. sprPelota SDLImage
	SDLRedraw

	xv 'xp +!
	yv 'yp +!
	
	teclado
	;

	
:main
	"r3sdl" 800 600 SDLinit
	"media/img/ball.png" loadimg 'sprpelota !
	'demo SDLshow
	SDLquit ;	
	
: main ;