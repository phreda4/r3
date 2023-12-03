^r3/win/sdl2gfx.r3
^r3/util/sdlgui.r3

	
:menu
	0 SDLcls
	immgui		| ini IMMGUI
	
	400 40 immbox
	200 200 immat
	$ff0000 'immcolorbtn !
	$ffffff 'immcolortex !
	'exit "Salir" immbtn 
	immdn
	'exit "coso" immbtn 
	immdn
	sdlb sdly sdlx "%d %d %d" immlabelc	
	
	40 40 immbox
	100 20 immat
	$ff00 'immcolorbtn !
	$0 'immcolortex !
	0 'immcolortex !
	'exit 0 immibtn 
	
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	drop
	;
	
:main
	"r3sdl" 800 600 SDLinit
	"media/ttf/Roboto-Medium.ttf" 20 TTF_OpenFont immSDL	
	'menu SDLshow
	SDLquit ;	
	
: main ;