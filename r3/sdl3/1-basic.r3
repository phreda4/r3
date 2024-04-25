^r3/sdl3/sdl3.r3

#win
#screen

:main
	"sdl3 welcome" 1024 600 SDLInit
	
	$00ff00 SDLcls
	SDLredraw
	2000 SDL_Delay
	
	$0000ff SDLcls
	SDLredraw
	2000 SDL_Delay
	
	SDLquit
	;

: main ;
