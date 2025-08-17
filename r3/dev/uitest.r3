| r3d4 sdl debbuger
| PHREDA 2024
|
^r3/lib/gui.r3
^r3/lib/sdl2gfx.r3
^r3/util/ui.r3
^r3/util/uiDatetime.r3
^r3/util/uiedit.r3
	
#font1
#font2

#pad * 1024
#pad2 * 1024
		
#tablist "A" "B" "C" "D" 0

#listex "uno" "dos" "tres" "cuatro" "cinco" 0

#treeex
"@uno" "Aaaa" "Abbb" "Blksdhfl" "Blksdhfl" "Axnb"
"@dos" 
"@tres"
"@listado" "Auno" "Ados"
0

#vc
#vt
#vh
#vr
#si #sf

#vlist 0 0
#vtree 0 0

#folders 0

#vdatetime
#vtime1

#folderdisk
#path "r3/"
#filename * 1024

:ui--
	$444444 sdlcolor uiLineH ;
	
#tabnow	

|-----------------------------
:main
	0 SDLcls
	font1 txfont
	uiStart
	3 4 uiPad
	0.01 %w 0.05 %h 0.5 %w 0.9 %h uiWin!
	4 22 uiGridA uiH
	$222222 sdlcolor uiFillW |	$3f sdlcolor uiTitleF
	"Tabs" uiTitle 		| $uiRectW uiFil uiRect
	$ffffff sdlcolor 	
	'vlist 'tablist uiTab
	
	0 2 uiGAt uiV
	'vlist 3 'listex uiList | 8
	'vh 'tablist uiCheck
	'vdatetime uiDate
	'vtime1 uiTime
	|'filename 'volume uiFilename
	|'path 'volume uiPath
	
	1 2 uiGAt
	stDang 'exit "btn1"  uiBtn 
	stWarn 'exit "btn2"  uiRBtn 
	stSucc 'exit "btn3"  uiCBtn 
	stInfo 'exit "btn4"  uiBtn 
	stLink 'exit "btn4"  uiBtn 
	stDark 'exit "btn4"  uiBtn 
	ui--
	'vtree 5 'treeex uiTree
	
	2 2 uiGat

	0 255 'si uiSlideri
	ui--
	-1.0 1.0 'sf uiSliderf
		uiPush
	16 22 uiGridA uiH
	uiPush 8 5 uiGat 1 4 uiGto
	0 255 'si uiVSlideri
	uiPop
	uiPush 9 5 uiGat 2 4 uiGto
	-1.0 1.0 'sf uiVSliderf
	uiPop
	uiPush 11 5 uiGat 1 4 uiGto
	0 255 'si uiVProgressi
	uiPop
		
		uiPop
	
	
	3 2 uiGat uiV
	'vc 'listex uiCombo | 'var 'list --
	ui--
	'vr 'tablist uiRadio
	ui--
	0.0 1.0 'sf uiProgressF
	0 255 'si uiProgressI
	
	1 22 uiGridA uiV
	0 20 uiGAt
	'pad 512 uiInputLine
	'pad2 512 uiInputLine
	

	font2 txfont
	edfocus
	edcodedraw


|	0.4 %w 0.5 %h 0.3 %w 0.2 %h uiWin!
|	$111111 sdlcolor uiFillW 
|	3 3 uiGridA
|	1 2 uiGAt
|	[ "click" .println ; ] "boton" uiBtn
	
	uiEnd
	
	SDLredraw
	sdlkey
	>esc< =? ( exit )
	drop
	;
	
|-----------------------------
|-----------------------------	
:	
	|"R3d4" 0 SDLfullw | full windows | 
	"R3d4" 1280 720 SDLinit
	
	"media/ttf/Roboto-bold.ttf" 19 txload 'font1 !
	|"media/ttf/ProggyClean.ttf" 16
	"media/ttf/RobotoMono-bold.ttf" 18 
	txload 'font2 !
 	
	edram 
	0.5 %w 32 550 550 edwin
	
	"r3/opengl/voxels/3-vox.r3" 
	'filename strcpy
	'filename edload	
	
	'main SDLshow
	SDLquit 
	;
