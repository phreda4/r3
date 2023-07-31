| Edit sdl example
| PHREDA 2023
^r3/win/sdl2gfx.r3
^r3/util/sdlgui.r3
^r3/r3vm/simple-edit.r3

:play
	;
	
:main
	0 SDLcls
	edshow
	
	immgui 	
	$ffffff sdlcolor
	100 20 immbox
	680 16 immat
	"r3Arena" immlabelc		immdn
	'play "Play" immbtn 	immdn
	'exit "Exit" immbtn 
	
	
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	drop ;
	
:	
	"SDLEdit" 800 600 SDLinit
	"media/ttf/Roboto-Medium.TTF" 19 TTF_OpenFont immSDL
	
	bfont1
	1 1 80 35 edwin
	edram
	"r3/r3vm/testedit.r3" edload
|	edrun
	'main SDLshow

	SDLquit 
	;
