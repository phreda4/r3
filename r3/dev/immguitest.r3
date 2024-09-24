^r3/lib/console.r3
^r3/lib/sdl2gfx.r3
^r3/util/sdlgui.r3
^r3/util/sdlfiledlg.r3

|---- config
#filename * 1024
#tilefile * 1024

#inputtxt * 512
#inputtxt2 * 512

#wincon 1 [ 0 30 200 400 ] "CONFIG"
#mapwn 
#maphn

:cku ;

:winconfig
	'wincon immwin 0? ( drop ; ) drop
	[ ; ] "CANCEL" immbtn imm>>
	[ ; ]  "OK" immbtn immcr
	[ ; ] "CLEAR" immbtn immcr
	192 24 immbox
	'cku "unos" immtbtn ">" imm. 
	'cku "dos" immtbtn immcr
	192 24 immbox	
	'filename immlabel immcr
	'tilefile immlabel immcr
	
	'inputtxt 256 immInputLine immcr
	'inputtxt2 256 immInputLine immcr
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
	
:loadfile1
	fullfilename 'filename strcpy 
	'filename .println
	;

:loadfile2
	fullfilename 'tilefile strcpy 
	'tilefile .println
|	'tilefile strcpy 
	;
	
:editor
	0 SDLcls
	immGui		| ini IMMGUI	
	'keymain immkey!

	200 20 immbox
	200 200 immat
	$ff0000 'immcolorbtn !
	$ffffff 'immcolortex !
	[ 'loadfile1 'filename immfileload ; ] "dlg load" immbtn 
	immdn
	[ 'loadfile2 'tilefile immfilesave ; ] "dlg save" immbtn 
	immdn
	sdlb sdly sdlx "%d %d %d" immlabelc	immdn
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
	'winconfig immwin!
	
	"media/img/tiles.png" 'tilefile strcpy
	"media/img/tiles.png" 'filename strcpy

	filedlgini

	'editor SDLshow
	SDLquit
	;
	
: main ;