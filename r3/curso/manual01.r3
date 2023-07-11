^r3/win/sdl2gfx.r3

#sprites
#x 320 #y 380
	
:juego
	0 SDLcls
	x y 2.0 0 sprites sspritez 
	SDLredraw

	SDLkey 
	>esc< =? ( exit )
	<le> =? ( -1 'x +! )
	<ri> =? ( 1 'x +! )
	drop ;

:main
	"r3sdl" 640 480 SDLinit
	16 16 "media/img/manual.png" ssload 'sprites !
	'juego SDLshow
	SDLquit ;	
	
: main ;
