^r3/win/console.r3
^r3/win/sdl2gfx.r3
^r3/util/sdlgui.r3
^r3/util/sdlfiledlg.r3

:keymain
	SDLkey
	>esc< =? ( exit )
	drop
	;
	
:editor
	0 SDLcls
	immGui		| ini IMMGUI	
	'keymain immkey!

	200 20 immbox
	200 200 immat
	$ff0000 'immcolorbtn !
	$ffffff 'immcolortex !
	[ immfileload ; ] "dlg load" immbtn 
	immdn
	[ immfilesave ; ] "dlg save" immbtn 
	immdn
	sdlb sdly sdlx "%d %d %d" sprint immlabelc	
	100 20 immat
	$ff00 'immcolorbtn !
	$0 'immcolortex !
	0 'immcolortex !
	'exit 0 immibtn 

	immRedraw
	SDLredraw
	;
	
:main
	"r3sdl" 1024 600 SDLinit
	"media/ttf/Roboto-Medium.ttf" 16 TTF_OpenFont immSDL
	"r3" filedlgini
	'editor SDLshow
	SDLquit
	;
	
: main ;