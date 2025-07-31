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

#filename * 1024
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

:ui--
	$444444 sdlcolor uiLineH ;
	
#tabnow	

|-----------------------------
:main
	0 SDLcls
	font1 txfont
	uiStart
	3 4 uiPad
	0.45 %w 0.1 %h 0.5 %w 0.7 %h uiWin!
	4 16 uiGridA uiH
	$222222 sdlcolor uiFillW |	$3f sdlcolor uiTitleF
	"Tabs" uiTitle 		| $uiRectW uiFil uiRect
	$ffffff sdlcolor 	
	'vlist 'tablist uiTab
	
	0 2 uiGAt uiV
	'vlist 3 'listex uiList | 8
	ui--
	'vh 'tablist uiCheck
	ui--
	'vdatetime uiDateTime
	
	1 2 uiGAt
	stDang 'exit "btn1"  uiBtn 
	stWarn 'exit "btn2"  uiRBtn 
	stSucc 'exit "btn3"  uiCBtn 
	stInfo 'exit "btn4"  uiBtn 
	stLink 'exit "btn4"  uiBtn 
	stDark 'exit "btn4"  uiBtn 
	ui--
	
	2 2 uiGat
	'vtree 5 'treeex uiTree
	0 255 'si uiSlideri
	ui--
	-1.0 1.0 'sf uiSliderf
	
	3 2 uiGat
	'vc 'listex uiCombo | 'var 'list --
	ui--
	'vr 'tablist uiRadio
	ui--
	
	
	1 16 uiGridA uiV
	0 12 uiGAt
	'pad 512 uiInputLine
	'pad2 512 uiInputLine
	
	1 4 uiGridA uiV
	0 3 uiGat
	|'exit "hola" uiRbtn
	|'vtable 5 'cols 'tabla1 uiTable<
	

	
	font2 txfont
	edfocus
	edcodedraw

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
	
	24 21 "media/img/icong16.png" ssload 'uicons !
	
	"media/ttf/Roboto-bold.ttf" 19 txload 'font1 !
	|"media/ttf/ProggyClean.ttf" 16
	"media/ttf/RobotoMono-bold.ttf" 18 
	txload 'font2 !
 	
	edram 
	8 32 550 550 edwin
	
	"r3/opengl/voxels/3-vox.r3" 
	'filename strcpy
	'filename edload	
	
	'main SDLshow
	SDLquit 
	;
