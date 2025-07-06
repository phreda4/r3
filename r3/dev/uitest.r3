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
#pad2 * 1024
		
#tablist "A" "B" "C" "D" 0

#listex "uno" "dos" "tres" "cuatro" "sdjh" "21739832" "dsjhds" 0

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

:ui--
	$444444 sdlcolor uiLineH ;
	
#tabnow	

|-----------------------------
:main
	0 SDLcls
	uiStart
	3 4 uiPad
	0.45 %w 0.1 %h 0.5 %w 0.5 %h uiWin
	4 12 uiGrid uiH
	$222222 sdlcolor uiFillW |	$3f sdlcolor uiTitleF
	"Tabs" uiTitle 		| $uiRectW uiFil uiRect
	$ffffff sdlcolor 	
	'vlist 'tablist uiTab
	
	0 2 uiGAt uiV
	'vlist 4 'listex uiList | 8
	ui--
	'vh 'tablist uiCheck
	
	
	1 2 uiGAt
stDang 
	'exit "btn1"  uiBtn 
stWarn 
	'exit "btn2"  uiRBtn 
stSucc 
'exit "btn3"  uiCBtn 
stInfo 
'exit "btn4"  uiBtn 
stLink 
'exit "btn4"  uiBtn 
stDark 
'exit "btn4"  uiBtn 
	ui--
	0 255 'si uiSlideri
	ui--
	-1.0 1.0 'sf uiSliderf
	
	2 2 uiGat
	'vtree 8 'treeex uiTree
	3 2 uiGat
	'vc 'listex uiCombo | 'var 'list --
	ui--
	'vr 'tablist uiRadio
	ui--

	0.45 %w 0.6 %h 0.5 %w 0.1 %h uiWin
	$222222 sdlcolor uiFillW |	$3f sdlcolor uiTitleF
	1 2 uiGrid uiV
	'pad 512 uiInputLine
	'pad2 512 uiInputLine
	ui--
	
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
	"media/ttf/Roboto-regular.ttf" 8 TTF_OpenFont 'uifont !
	24 21 "media/img/icong16.png" ssload 'uicons !
	18 uifontsize

	0.6 16 32 "media/img/robotomm.png" tfnt	
	
	edram 
	0 2 65 30 edwin
	
	"r3/opengl/voxels/3-vox.r3" 
	'filename strcpy
	'filename edload	
	
	'main SDLshow
	SDLquit 
	;
