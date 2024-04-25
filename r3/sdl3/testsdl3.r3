| sdl3 test program
| PHREDA 2024
^r3/sdl3/sdl3.r3

::SDLinit | "titulo" w h --
	'sh ! 'sw !
	$3231 SDL_init 
	sw sh $0 SDL_CreateWindow dup 'SDL_windows !
	SDL_GetWindowSurface 'SDL_screen !
|	0 SDL_ShowCursor | disable cursor
	SDL_windows -1 0 SDL_CreateRenderer 'SDLrenderer !
	|SDL_windows SDL_RaiseWindow
	;
	
:main
	$0 SDLcls
	SDLredraw
	
	SDLkey
	>esc< =? ( exit )
	drop ;

:
	"r3sdl3" 1024 600 SDLinit
	'main SDLshow 
	SDLquit
	;

