^r3/win/sdl2gfx.r3

#spr1
#x 320 #y 380
	
:juego
	0 SDLcls
	x y spr1 SDLImage
	SDLredraw

	SDLkey 
	>esc< =? ( exit )
	<le> =? ( -1 'x +! )
	<ri> =? ( 1 'x +! )
	drop ;

:main
	"r3sdl" 640 480 SDLinit
	"media/img/ball.png" loadimg 'spr1 ! 	
	'juego SDLshow
	SDLquit ;	
	
: main ;
