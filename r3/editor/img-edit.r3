| Editor de imagenes
| PHREDA 2020
|--------------------------------------------------
^r3/win/sdl2gfx.r3

^r3/util/bfont.r3

^r3/lib/gui.r3
^r3/lib/rand.r3
^r3/lib/vdraw.r3

^r3/lib/trace.r3

#nombre * 256

#imagen
#imagenw 320
#imagenh 200
#textura

#color $ff00

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
	imagena color swap d! ;

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
	[ color xypen scr2img vfill buffercopy ; ] onClick ;

|----------- LINE
:modoline
	[ xypen 'ya ! 'xa ! ; ]
	[ color SDLColor xa ya xypen SDLline ; ]
	[ xa ya scr2img vop xypen scr2img vline buffercopy ; ] guiMap ;

|----------- BOX
:modobox
	[ xypen 'ya ! 'xa ! ; ]
	[ color SDLColor xa ya xypen pick2 - swap pick3 - swap SDLRect ; ]
	[ xa ya scr2img xypen scr2img vrect buffercopy ; ] guiMap ;

|----------- CIRCLE
:border2cenrad
	rot 2dup + 1 >> >r - abs 1 >> >r
	2dup + 1 >> >r - abs 1 >>
	r> r> swap r> ;			| xr yr xm ym

:modocircle
	[ xypen 'ya ! 'xa ! ; ]
	[ color SDLColor xa ya xypen border2cenrad SDLEllipse ; ]
	[ xa ya scr2img xypen scr2img 	| x y x y
		border2cenrad vellipseb buffercopy ; ] guiMap ;

|----------- PICKER
:modopicker
	[ xypen scr2img imagenget 'color ! ; ] onClick ;

|----------- ERASER
:modoeraser
	[ xypen scr2img vop ; ] [ xypen scr2img vline buffercopy ; ]  onDnMove ;

|----------- SELECT
:modoselect
	[ xypen 'ys1 ! 'xs1 ! ; ]
	[ xs1 ys1 xypen pick2 - swap pick3 - swap  SDLRect ; ]
	[ xypen scr2img 'ys2 ! 'xs2 ! ; ] guiMap ;

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
	$ffffff SDLColor
	xytool modo2xy 30 30 SDLRect 
	;
	
:settool
	xytool dup 'modo ! 
	3 << 'modos + @ 'modoex !
	;

:toolbar
    xtool ytool imgtoolbar SDLimage
	$ff00 SDLColor
	modo modo2xy 30 30 SDLRect |box.inv

	xtool ytool 60 180 guiBox
	SDLb SDLx SDLy guiIn
	'intool guiI
	'settool onClick
	;

:imagen.draw | --
|	bmrm 1 and? ( imagenw imagenh xi yi drawalphagrid ) drop
	xi yi
	imagenw zoom <<
	imagenh zoom <<
	textura
	SDLimages 
	;

:teclado
	SDLkey
	>esc< =? ( exit )
	
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
	vsize
	here 'imagen !
	
	"new" 'nombre strcpy
	;

:loadfile
	|dlgFileLoad 
	0? ( drop ; )
	dup 'nombre strcpy
|	loadImg 
	0? ( drop ; )
|	dup spr.wh
	2dup 'imagenh ! 'imagenw !
	vsize
	imagen swap 
	|spr.cntmem 
	4 - swap 1 + move
	;

:btnt | exe "text" --
	bsize bpos 2swap guibox
	SDLb SDLx SDLy guiIn	
	
	$7f 
	[ $ff nip ; ] guiI
	SDLColor
	xr1 yr1 xr2 pick2 - yr2 pick2 -
	SDLFillRect	
	
	$ffffff SDLColor
	bsize | w h
	xr2 xr1 + 1 >> rot 1 >> - 
	yr2 yr1 + 1 >> rot 1 >> -
	bat
	bprint
	onClick
	;

|-----------------------------
:main
	gui
	$454545 SDLClear

	'imagenset vset!
    imagen.draw

	$454545 SDLColor
|	2 backlines

	$ffffff SDLColor
	4 4 bat
	":r3 Img Editor [ " bprint
	'nombre bprint
	imagenh imagenw " | %dx%d ] " sprint bprint
	$7f7f7f SDLColor
	[ 0 'zoom ! ; ] "x1" btnt " " bprint
	[ 1 'zoom ! ; ] "x2" btnt " " bprint
	[ 2 'zoom ! ; ] "x4" btnt " " bprint
	[ 3 'zoom ! ; ] "x8" btnt " " bprint
	'loadfile "load" btnt
	toolbar
	|dlgColor

	xi limx clampmin
	yi limy clampmin
	imagenw zoom << xi + sw clampmax
	imagenh zoom << yi + sh clampmax
	guiBox
	SDLb SDLx SDLy guiIn
	modoex 1? ( dup ex ) drop

	teclado
	SDLRedraw 
	;	


:inimem
	'imagenset vset!
	'imagenget vget!
	mark
|	dlgColorIni
	"media/img/img-toolbar.png" loadimg 'imgtoolbar !
	mark
	here 'imagen !
	320 240 canvassize
|	"media/img" dlgSetPath
	;

:   
	"r3paint" 800 600 SDLinit
	bfont1
	inimem
|	"mem/img-edit.mem" bmr.load
	'main SDLShow
|	"mem/img-edit.mem" bmr.save
	SDLquit
	;
