^r3/win/sdl2gfx.r3

#spr1
#x 320.0 #y 380.0
#xv 0 #yv 0
	
:juego
	0 SDLcls
	x int. y int. spr1 SDLImage
	
	xv 'x +!
	yv 'y +!

	SDLredraw

	SDLkey 
	>esc< =? ( exit )
	<le> =? ( -1.0 'xv ! ) >le< =? ( 0 'xv ! )
	<ri> =? ( 1.0 'xv ! ) >ri< =? ( 0 'xv ! )
	
	drop ;

:main
	"r3sdl" 640 480 SDLinit
	"media/img/ball.png" loadimg 'spr1 ! 	
	'juego SDLshow
	SDLquit ;	
	
: main ;
