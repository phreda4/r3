^r3/sdl3/sdl3.r3

:scr
	$00ff00 SDLcls
	SDLredraw
	sdlkey
	>esc< =? ( exit )
	drop
	;
	
:main
	"sdl3 welcome" 1024 600 SDLInit
	'scr sdlshow
	SDLquit
	;

: main ;
