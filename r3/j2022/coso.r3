| r3 sdl program
^r3/win/sdl2gfx.r3
	
:demo
	0 SDLcls
	$ff0000 SDLColor
	10 10 20 20 SDLFRect
	SDLredraw
	
	SDLkey 
	>esc< =? ( exit )
	drop ;

:main
	"r3sdl" 800 600 SDLinit
	'demo SDLshow
	SDLquit ;	
	
: main ;