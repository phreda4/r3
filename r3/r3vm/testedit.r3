| Edit sdl example
| PHREDA 2023
^r3/win/sdl2gfx.r3
^r3/util/sdlgui.r3
^r3/r3vm/simple-edit.r3

#font

:main
	0 SDLcls
	
	$ffffff ttcolor
	10 10 ttat
	"prueba" tt.
	
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	drop ;
	
:	
	"SDLEdit" 800 600 SDLinit
|	"media/ttf/ProggyClean.TTF" 16 TTF_OpenFont ttfont 
	
	bfont1
	1 2 80 25 edwin
	edram
	"r3/r3vm/testedit.r3" edload
	edrun
|	'main SDLshow

	SDLquit 
	;
