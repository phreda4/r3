^r3/win/sdl2gfx.r3

#sprites
#x 320.0 #y 380.0
#xv 0 #yv 0
	
:jugador
	x int. y int. 2.0 0 sprites sspritez 
	xv 'x +! yv 'y +! ;

:juego
	0 SDLcls
	jugador
	SDLredraw

	SDLkey 
	>esc< =? ( exit )
	<le> =? ( -1.0 'xv ! ) >le< =? ( 0 'xv ! )
	<ri> =? ( 1.0 'xv ! ) >ri< =? ( 0 'xv ! )
	drop ;

:main
	"r3sdl" 640 480 SDLinit
	16 16 "media/img/manual.png" ssload 'sprites !
	'juego SDLshow
	SDLquit ;	
	
: main ;
