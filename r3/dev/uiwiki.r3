| uiwiki
| PHREDA 2025
|
^r3/lib/gui.r3
^r3/lib/sdl2gfx.r3

^r3/lib/rand.r3
^r3/util/varanim.r3
^r3/util/textb.r3

^r3/util/arr16.r3
^r3/util/ui.r3
^r3/util/sdledit.r3
	
#filename * 1024
#pad * 1024

#tabnow	

#pages 0 0

#curx #cury #curz

|--- objs
:.pos 1 ncell+ ;
:.vel 2 ncell+ ;
:.ani 3 ncell+ ;
:.tex 4 ncell+ ;
:.atr 5 ncell+ ;
:.hash 6 ncell+ ;
:.str 7 ncell+ ;

|---------------
:img >a | adr -- adr/0
	a> .pos @ 64xyrz 
	a> .tex @ spriterz
	;

:+cosa | "" xyrz64 --
	'img 'pages p!+ >a
	a!+ | posicion
	0 a!+ | velocidad
	0 a!+ | animacion
	$f070f0000025ffff 0.25 %w 0.1 %h 
	uifont |dup 0.1 %h TTF_SetFontSize dup %1 TTF_SetFontStyle | KUIB %0001
	textbox a!+ | textura
	;

:.chetex
	a> .tex dup @ 1? ( SDL_DestroyTexture 0 over ! dup ) 2drop
	
	;
	
:+img | "filename" pos --
	'img 'pages p!+ >a
	a!+ | posicion
	0 a!+ | velocidad
	0 a!+ | animacion
	loadimg a!+ | textura
	;	

|::textbox | str $colb-colo-ofvh-colf w h font -- texture
#colb #colo #colf
#bor #pad #align

:paneltextb
	1 14 uiGrid uiV
	"Label" uiLabel
	'pad 512 uiInputLine
	uicr
	
	5 14 uiGrid uiH
	0 2 uiGat
	0 15 'colf 3 + uiSlideri8
	0 15 'colf 2 + uiSlideri8
	0 15 'colf 1 + uiSlideri8
	0 15 'colf uiSlideri8 
	colf dup 4 << or sdlcolor uiFill
|	colb "%h" sprint uiLabelc 
	uicr
	0 15 'colo 3 + uiSlideri8
	0 15 'colo 2 + uiSlideri8
	0 15 'colo 1 + uiSlideri8
	0 15 'colo uiSlideri8 
	colo dup 4 << or sdlcolor uiFill
	uicr
	0 15 'colb 3 + uiSlideri8
	0 15 'colb 2 + uiSlideri8
	0 15 'colb 1 + uiSlideri8
	0 15 'colb uiSlideri8 
	colb dup 4 << or sdlcolor uiFill
	uicr
	;

#botonera "1" "2" "3" "4" "5" "6" "7" "8" "9" "0" "." " " 0

#varbot 0 $0404

:paneltex
	1 14 uiGrid uiV
	"Imagen" uiLabel 
	'varbot 'botonera 4 4 UIGridBtn
	
	;

#modo 'paneltextb 'paneltex
#paneln	

#btn

:panel
	0.02 %w 0.2 %h 0.3 %w 0.6 %h uiWin
	$111111 sdlcolor uiFillR
	18 uiFontSize
	stDark

	'modo paneln ncell+ @ ex
	;
	
|-----------------------------
:main
	0 SDLcls
	uiStart
	3 4 uiPad
	0.1 %w 0.1 %h 0.8 %w 0.8 %h uiWin
	$222222 sdlcolor uiFillR

	38 uifontsize
	10 10 uiGrid 
	0 0 uiGAt stSucc 'exit "+" uiRBtn 
	9 9 uiGAt stDang 'exit "Exit" uiRBtn 
|	stWarn 'exit ">>"  uiRBtn 
|	stSucc 'exit "btn3"  uiCBtn 
|	stInfo 'exit "btn4"  uiBtn 
|	stLink 'exit "btn4"  uiBtn 
|	stDark 'exit "btn4"  uiBtn 

	panel

	'pages p.draw 

	SDLredraw
	sdlkey
	>esc< =? ( exit )
	<f1> =? ( 0 'paneln ! )
	<f2> =? ( 1 'paneln ! )
	<f5> =? ( 
		"cosa" 
		sw randmax sh randmax 0 1.0	xyrz64 
		+cosa )
	<f6> =? (
		"media/img/wood.jpg"
		sw randmax sh randmax 1.0 randmax 0.1 0.6 randmax +
		xyrz64 
		+img )
	drop
	;
	

|<:::::::::::::::::::::::::::::::::::::>
:	
	|"R3d4" 0 SDLfullw | full windows | 
	"R3d4" 1280 720 SDLinit
	"media/ttf/Roboto-regular.ttf" 8 TTF_OpenFont 'uifont !
	24 21 "media/img/icong16.png" ssload 'uicons !
	
	
	
	1024 vaini
	1024 'pages p.ini
	
	bfont1
	edram 
	0 2 65 30 edwin
	
|	"r3/opengl/voxels/3-vox.r3" 
|	'filename strcpy 'filename edload	
	
	'main SDLshow
	SDLquit 
	;
