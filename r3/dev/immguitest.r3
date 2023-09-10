^r3/win/console.r3
^r3/win/sdl2gfx.r3
^r3/util/sdlgui.r3
^r3/util/sdlfiledlg.r3

|---- config
#filename "filename"
#tilefile "tilefile"

#wincon 0 [ 824 300 200 200 ] "CONFIG"
#mapwn 
#maphn

:getconfig
	wincon 1 xor 'wincon ! 
	;

:setconfig
	wincon 1 xor 'wincon ! 
	;
	
:winconfig
	'wincon immwin 0? ( drop ; ) drop
	[ wincon 1 xor 'wincon ! ; ] "CANCEL" immbtn imm>>
	'setconfig  "OK" immbtn immcr
	[ ; ] "CLEAR" immbtn immcr
	
	'filename immlabel immcr
	'tilefile immlabel immcr
	190 20 immbox
	4 254 'mapwn immSlideri immcr
	4 254 'maphn immSlideri immcr
	
	;
	
|----
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
	'winconfig immwin!
	'editor SDLshow
	SDLquit
	;
	
: main ;