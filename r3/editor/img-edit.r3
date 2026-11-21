| Editor de imagenes
| PHREDA 2020
|--------------------------------------------------
^r3/lib/sdl2gfx.r3
^r3/util/bfont.r3
^r3/lib/gui.r3
^r3/lib/vdraw.r3

^r3/rimm/rimmsdl.r3
^r3/rimm/rimmwid.r3
^r3/rimm/rimmcolor.r3
^r3/rimm/rimmfile.r3

#nombre * 256

#colord $ffffff	| selected color $RRGGBB
#filesel * 1024	| name written by the file dialog
#fnt			| font of the rimm widgets
#ppopen 0		| 1 while a rimm pop-up is open
#mblock 0

:mouseblk | -- flag ; 1 while a pop-up is open, and until the button is released after it closes
	uiPopup? 1? ( drop 1 'mblock ! 1 ; ) drop
	SDLb 0? ( drop 0 'mblock ! 0 ; ) drop
	mblock ;

#imagen
#imagenw 320
#imagenh 200
#textura

#limx 60 #limy 24

#zoom 0
#xi 60 #yi 24 | donde esta el pixel 0,0
#size 1

:scr2img | x y -- xi yi
	yi - zoom >> swap
	xi - zoom >> swap ;

:imagena | x y -- adr
	imagenw * + 2 << imagen + ;

:imagenset | x y --
	imagena colord swap d! ;

:imagenget | x y -- c
	imagena d@ ;

#xa #ya
#xs1 #ys1
#xs2 #ys2

:xypen SDLx SDLy  ;

#mpixel #mpitch

:buffercopy
	textura 0 'mpixel 'mpitch SDL_LockTexture
	mpixel imagen imagenh imagenw * dmove
	textura SDL_UnlockTexture ;
	
|----------- DRAW
:mododraw
	[ xypen scr2img vop ; ] [ xypen scr2img vline buffercopy ; ]  onDnMove ;

|----------- FILL
:modofill
	[ colord xypen scr2img vfill buffercopy ; ] onClick ;

|----------- LINE
:modoline
	[ xypen 'ya ! 'xa ! ; ]
	[ colord color xa ya xypen line ; ]
	[ xa ya scr2img vop xypen scr2img vline buffercopy ; ] onMap ;

|----------- BOX
:modobox
	[ xypen 'ya ! 'xa ! ; ]
	[ colord color xa ya xypen pick2 - swap pick3 - swap rect ; ]
	[ xa ya scr2img xypen scr2img vrect buffercopy ; ] onMap ;

|----------- CIRCLE
:border2cenrad
	rot 2dup + 1 >> >r - abs 1 >> >r
	2dup + 1 >> >r - abs 1 >>
	r> r> swap r> ;			| xr yr xm ym

:modocircle
	[ xypen 'ya ! 'xa ! ; ]
	[ colord color xa ya xypen border2cenrad ellipse ; ]
	[ xa ya scr2img xypen scr2img 	| x y x y
		border2cenrad vellipseb buffercopy ; ] onMap ;

|----------- PICKER
:modopicker
	[ xypen scr2img imagenget 'colord ! ; ] onClick ;

|----------- ERASER
:modoeraser
	[ xypen scr2img vop ; ] [ xypen scr2img vline buffercopy ; ]  onDnMove ;

|----------- SELECT
:modoselect
	[ xypen 'ys1 ! 'xs1 ! ; ]
	[ xs1 ys1 xypen pick2 - swap pick3 - swap  rect ; ]
	[ xypen scr2img 'ys2 ! 'xs2 ! ; ] onMap ;

|------------------------------
#modo 0
#modoex 'mododraw

#xtool 0 #ytool 24

#imgtoolbar
#modos
	'mododraw 'modopicker
	'modoline 'modofill
	'modobox 'modocircle
	'modoeraser 'modoselect 0 0 0 0 0 0

:modo2xy | modo -- x y 
	dup $1 and 30 * xtool +
	swap 1 >> 30 * ytool + ;
	
:xytool
	SDLx xtool - 30 / 
	SDLy ytool - 30 / 1 << +
	;
	
:intool
	$ffffff color
	xytool modo2xy 30 30 rect 
	;
	
:settool
	xytool dup 'modo ! 
	3 << 'modos + @ 'modoex !
	;

:toolbar
    xtool ytool imgtoolbar image
	$ff00 color
	modo modo2xy 30 30 rect |box.inv

	mouseblk 0? ( xtool ytool 60 180 guiBox 'intool guiI 'settool onClick ) drop
	;

:imagen.draw | --
|	bmrm 1 and? ( imagenw imagenh xi yi drawalphagrid ) drop
	xi yi
	imagenw zoom <<
	imagenh zoom <<
	textura
	images 
	;

:teclado
	SDLkey
	ppopen 1? ( 2drop ; ) drop

	<up> =? ( 1 zoom << neg 'yi +! )
	<dn> =? ( 1 zoom << 'yi +! )
	<le> =? ( 1 zoom << neg 'xi +! )
	<ri> =? ( 1 zoom << 'xi +! )

|	<f1> =? ( 1 'modo +! )
	>esc< =? ( exit )
	drop
	;

:canvassize | w h --
	2dup 'imagenh ! 'imagenw !
	2dup SDLframebuffer 'textura !	
	vsize!
	
	mark
	here dup >a 'imagen !
	imagenh imagenw *
	( 1? 1 - $ffffff da!+ ) drop
	a> 'here !
	"new" 'nombre strcpy
	;
	
:canvasresize | w h --
	textura SDL_DestroyTexture
	empty
	2dup 'imagenh ! 'imagenw !
	2dup SDLframebuffer 'textura !	
	vsize!
	mark
	here 'imagen !
	imagenh imagenw * 2 << 'here +! 
	;

:loadfile | --
	'filesel 1024 1 uiFileAsk	| 1 = the file must exist
	;

:openimg | --
	'filesel 'nombre strcpy
	'filesel loadImg 0? ( drop ; )	| suface
	dup 0 0 'imagenw 'imagenh SDL_queryTexture
	
	imagenw imagenh canvasresize
	
	dup 0 'mpixel 'mpitch SDL_LockTexture
	imagen mpixel imagenw imagenh * dmove
	
	imagen >a
	imagenh imagenw *
	( 1? 1 - $ff00 da!+ ) drop
	
|	mpixel "%h" .print
	dup SDL_UnLockTexture
	SDL_DestroyTexture
	buffercopy
	;

:filedone | --
	uiFileDone? 1? ( openimg ) drop ;

:btnt | exe "text" --
	bsize bpos 2swap guibox
		
	$7f 
	[ $ff nip ; ] guiI
	color
	xr1 yr1 xr2 pick2 - yr2 pick2 -
	frect	
	
	$ffffff color
	bsize | w h
	xr2 xr1 + 1 >> rot 1 >> - 
	yr2 yr1 + 1 >> rot 1 >> -
	bat
	bprint
	mouseblk 1? ( 2drop ; ) drop
	onClick
	;

|----------- COLOR PANEL
#pal60 * 240	| 60 colors $RRGGBB
#palnow -1

:palini | -- ; black, gray, white and 19 hues in 3 shades
	'pal60 >a
	$000000 da!+ $888888 da!+ $ffffff da!+
	0 ( 19 <?
		dup 1.0 19 */ 1.0 0.5 hsv2rgb $ffffff and da!+
		dup 1.0 19 */ 1.0 1.0 hsv2rgb $ffffff and da!+
		dup 1.0 19 */ 0.5 1.0 hsv2rgb $ffffff and da!+
		1 + ) drop ;

:colorpal | -- ; palette of 3 x 20 colors
	1 1 uiPad
	3 20 uiGrid
	0 ( 60 <?
		'pal60 over 2 << + d@ color uiFill
		palnow =? ( $ffffff color uiRect )
		uiZoneW
		[ dup 'palnow ! 'pal60 over 2 << + d@ 'colord ! ; ] uiClk
		uiNext
		1 + ) drop ;

:colorpanel | --
	0 200 60 380 uiBox
	uiPanelBg
	4 4 uiPad
	rh 6 + uiN
	'colord uiColor
	uiRest
	colorpal ;

|-----------------------------
:main
	gui
	$0 cls
	uiStart
	fnt txfont
    imagen.draw

	$454545 color
	0 0 sw 20 frect

	$ffffff color
	4 4 bat
	":r3 Img Editor [ " bprint
	'nombre bprint
	imagenh imagenw " | %dx%d ] " sprint bprint
	$7f7f7f color
	[ 0 'zoom ! ; ] "x1" btnt " " bprint
	[ 1 'zoom ! ; ] "x2" btnt " " bprint
	[ 2 'zoom ! ; ] "x4" btnt " " bprint
	[ 3 'zoom ! ; ] "x8" btnt " " bprint
	'loadfile " load " btnt
	toolbar
	colorpanel

	xi limx clampmin
	yi limy clampmin
	imagenw zoom << xi + sw clampmax
	imagenh zoom << yi + sh clampmax
	guiRect
	mouseblk 0? ( modoex 1? ( dup guiI ) drop ) drop

	uiPopup? 'ppopen !
	uiEnd
	filedone

	teclado
	SDLredraw 
	;	


:inimem
	'imagenset vset!
	'imagenget vget!
	mark
	palini
	"media/img/img-toolbar.png" loadimg 'imgtoolbar !
	mark
	here 'imagen !
	320 240 canvassize
	"media/img/" 'filesel strcpy
	;

:   
	"r3paint" 800 600 SDLinit
	bfont1
	"media/ttf/Roboto-Medium.ttf" 16 txload 'fnt !
	inimem
|	"mem/img-edit.mem" bmr.load
	buffercopy
	
	'main SDLShow
|	"mem/img-edit.mem" bmr.save
	SDLquit
	;
