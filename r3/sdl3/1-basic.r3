^r3/sdl3/sdl3.r3

#win
#screen

:main
	SDL_INIT_AUDIO SDL_INIT_VIDEO or SDL_INIT_EVENTS or
	SDL_Init 1? ( drop ; ) drop
	
	"a" .println
	|"Shapes" 800 600 SDL_WINDOW_HIDDEN SDL_CreateWindow 'win !
	"Shapes" 800 600 0 SDL_CreateWindow 'win !
	"a2" .println
	win SDL_ShowWindow
	"a1" .println
	win 0 0 SDL_CreateRenderer 'screen !
	"b" .println
	screen 255 255 25 255 SDL_SetRenderDrawColor
	"c" .println
	screen SDL_RenderClear
	"d" .println
	screen SDL_RenderPresent
	"e" .println
	2000 SDL_Delay
	"f" .println
	win SDL_DestroyWindow
	"g" .println
	SDL_Quit
	;

: main ;
