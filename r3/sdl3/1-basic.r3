^r3/sdl3/sdl3.r3

#win
#screen

:main
	SDL_INIT_VIDEO or SDL_INIT_EVENTS or
	SDL_Init 1? ( drop ; ) drop
	
	"Shapes" 800 600 0 SDL_CreateWindow 'win !
	win SDL_ShowWindow
	win 0 
	SDL_RENDERER_ACCELERATED SDL_RENDERER_PRESENTVSYNC or
	SDL_CreateRenderer 'screen !
	screen 255 255 25 255 SDL_SetRenderDrawColor
	screen SDL_RenderClear
	screen SDL_RenderPresent
	3000 SDL_Delay
	win SDL_DestroyWindow
	SDL_Quit
	;

: main ;
