| r3d4 sdl debbuger
| PHREDA 2024
|
^r3/lib/gui.r3
^r3/lib/sdl2gfx.r3
^r3/util/textb.r3
^r3/util/ui.r3
^r3/util/sdledit.r3
	
#filename * 1024
#pad * 1024
		
#listex "uno" "dos" "tres" "cuatro" 0

#treeex
"@uno"
	"Aaaa" "Abbb"
		"Blksdhfl" "Blksdhfl"
	"Axnb"
"@dos"
"@tres"
"@listado"
	"Auno" "Ados"
0

#vc
#vt
#vh
#vr
#si #sf

#vlist 0 0
#vtree 0 0

#folders 0

:ui--
	$444444 sdlcolor uiLineH ;

:test


	48 4 500 20 uiWin |	$ffffff sdlcolor uiRectW
	256 uiFonts 16 + uiBox 
	'exit "r3" uitbtn "/" uitlabel
	'exit "juegos" uitbtn "/" uitlabel
	'exit "2025" uitbtn
	
	48 uiFontS 16 + 500 20 uiWin |	uiRectW
	128 uiFonts 8 + uiBox
	
	'exit "btn1"  uiBtn 
	'exit "btn2"  uiBtn 
	uicr

	uiV | vertical
	256 uiFonts 8 + uiBox
	"* Widget *" uiLabelc
	ui--
	'vlist 4 'listex uiList | 8
	ui--
	'vtree 9 folders uiTree
	ui--
|	'vtree 9 'treeex uiTree

	308 uiFontS 16 + 400 300 uiWin |	$888888 sdlcolor uiRectW
	256 uiFonts 8 + uiBox
	'vc 'listex uiCombo | 'var 'list --
	ui--
	'vh 'listex uiCheck
	ui--
	'vr 'listex uiRadio
	ui--
	'pad 512 uiInputLine
	ui--
	0 255 'si uiSlideri
	ui--
	-1.0 1.0 'sf uiSliderf
	ui--
	;
	
	
#tabs "1" "2" "3" 0
#tabnow	
|-----------------------------
:main
	0 SDLcls
	uiStart
	3 4 uiPad

	580 4 1000 60 uiwin
	4 2 uiGrid
	$3F00 SDLCOLOR uiFillW
|	$3f sdlcolor uiTitleF
	"Tabs" uiTitle
	$ffffff SDLCOLOR uiRectW
	$7f00 sdlcolor uiFill
	$7f sdlcolor uiRect
	
	$ffffff SDLCOLOR 	
	'vlist 'listex uiTab
	
	'vlist 4 'listex uiList | 8
|	test
	
	edfocus
	edcodedraw
	
	SDLredraw
	sdlkey
	>esc< =? ( exit )
	drop
	;
	
:layout
	
	;	
|-----------------------------
|-----------------------------	
:	
	|"R3d4" 0 SDLfullw | full windows | 
	"R3d4" 1280 720 SDLinit
	"media/ttf/Roboto-bold.ttf" 8 TTF_OpenFont 'uifont !
	24 21 "media/img/icong16.png" ssload 'uicons !
	18 uifontsize
	
	bfont1
	edram 
	0 2 65 30 edwin
	
	"r3/opengl/voxels/3-vox.r3" 
	'filename strcpy
	'filename edload	
	
	'main SDLshow
	SDLquit 
	;
