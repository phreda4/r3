
^r3/lib/sdl2gfx.r3
^r3/lib/sdl2image.r3

#sprPelota	| dibujo
#xp 100.0 #yp 100.0		| posicion
#xv #yv		| velocidad

:teclado
	SDLkey
	>esc< =? ( exit )
	<w> =? ( -1.0 'yv ! )
	<s> =? ( 1.0 'yv ! )
	<a> =? ( -1.0 'xv ! )
	<d> =? ( 1.0 'xv ! )
	drop ;

	
:demo
	0 SDLcls
	xp int. yp int. sprPelota SDLImage
	SDLredraw

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