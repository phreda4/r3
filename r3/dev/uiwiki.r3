| uiwiki
| PHREDA 2025
|
^r3/lib/gui.r3
^r3/lib/sdl2gfx.r3

^r3/util/varanim.r3
^r3/util/textb.r3

^r3/util/arr16.r3
^r3/util/ui.r3
^r3/util/sdledit.r3
	
#filename * 1024
#pad * 1024

#tabnow	

#pages 0 0

|--- objs
:.pos 1 ncell+ ;
:.vel 2 ncell+ ;
:.ani 3 ncell+ ;
:.tex 4 ncell+ ;
:.atr 5 ncell+ ;
:.hash 6 ncell+ ;
:.str 7 ncell+ ;

|---------------
:img 	
	>a
	a> .pos @ 64xyrz 
	a> .tex @ 
	spriterz
	;

:+cosa | "" --
	'img 'pages p!+ >a
	
	0.5 %w 0.5 %h 0 1.0 xyrz64
	a!+ | posicion
	0 a!+ | velocidad
	0 a!+ | animacion
	$f070f0000025ffff 0.25 %w 0.1 %h 
	uifont |dup 0.1 %h TTF_SetFontSize dup %1 TTF_SetFontStyle | KUIB %0001
	textbox a!+ | textura
	;
	
|-----------------------------
:main
	0 SDLcls
	
	uiStart
	3 4 uiPad
	0.1 %w 0.1 %h 0.8 %w 0.8 %h uiWin
	$161616 sdlcolor uiFillR

	
	10 10 uiGrid 
	0 0 uiGAt stSucc 'exit "+" uiRBtn 
	9 9 uiGAt stDang 'exit "Exit" uiRBtn 
|	stWarn 'exit ">>"  uiRBtn 
|	stSucc 'exit "btn3"  uiCBtn 
|	stInfo 'exit "btn4"  uiBtn 
|	stLink 'exit "btn4"  uiBtn 
|	stDark 'exit "btn4"  uiBtn 

	'pages p.draw 

	SDLredraw
	sdlkey
	>esc< =? ( exit )
	<f1> =? ( "cosa" +cosa )
	drop
	;
	

|<:::::::::::::::::::::::::::::::::::::>
:	
	|"R3d4" 0 SDLfullw | full windows | 
	"R3d4" 1280 720 SDLinit
	"media/ttf/Roboto-regular.ttf" 8 TTF_OpenFont 'uifont !
	24 21 "media/img/icong16.png" ssload 'uicons !
	
	38 uifontsize
	
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
