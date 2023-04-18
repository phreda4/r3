| immg develop with SDL backend
| PHREDA 2023

^r3/lib/gui.r3

^r3/win/sdl2gfx.r3
|^r3/util/bfont.r3
^r3/util/ttfont.r3
^r3/lib/input.r3

#winx 10 #winy 10
#winw 10 #winh 10

#padx 2 #pady 2
#curx 10 #cury 10
#boxw 100 #boxh 20

#immcolorwin $666666	| window 
#immcolortwin $444444	| title window (back)
#immcolortex $ffffff	| text
#immcolorbtn $0000ff	| button

#immfontsh 16

::immgui gui ;
	
::immat 'cury ! 'curx ! ;
::immbox 'boxh ! 'boxw ! ;
	
|----------------------	
::imm>>
	padx 1 << boxw + 'curx +! ;	
::immdn
	pady 1 << boxh + 'cury +! ;
::imm<<dn
	winx 'curx !
	pady 1 << boxh + 'cury +! ;	
	
|--- place
:plgui
	curx padx + cury pady + boxw boxh guiBox ;

:plxywh
	curx padx + cury pady + boxw boxh ;
	
|--- label
::immlabel | "" --
	immcolortex ttColor
	curx padx + 
	boxh immfontsh - 2 >> cury + pady + 
	ttat ttprint ;
	
::immlabelc | "" --
	immcolortex ttColor
	ttsize boxw rot - 1 >> curx + padx +
	boxh rot - 2 >> cury + pady + 
	ttat ttprint ;

::immlabelr | "" --
	immcolortex ttColor
	ttsize boxw rot - curx + padx +
	boxh rot - 2 >> cury + pady + 
	ttat ttprint ;
	
|--- win
:winxy!
	dup $ffffffff and 'winx ! 32 >> 'winy ! ;
	
:winwh!
	dup $ffffffff and 'winw ! 32 >> 'winh ! ;

:winhome
	winx padx + 'curx ! 
	winy pady 2 << + immfontsh + | bfont1 h
	'cury ! ;

:wintitle | "" --
	immcolorwin SDLColor
	winx winy winw winh SDLFRect
	winx 'curx ! winy 'cury !
	winw padx 1 << - 'boxw ! immfontsh pady 1 << + 'boxh !
	immcolortwin SDLColor
	plxywh SDLFRect
	immlabelc
	;	
	
#px #py 	
:movwin
	sdlx dup px - swap 'px ! over 8 + d+!
	sdly dup py - swap 'py ! over 12 + d+! ;
	
::immwin | 'win -- 0/1
	dup 8 + @+ winxy! @+ winwh! wintitle
	plgui
	[ sdlx 'px ! sdly 'py ! ; ] 'movwin onDnMoveA
	@ winhome

	winw 1 >> 'boxw !
	;		

|--- widget	
::immbtn | 'click "" --
	plgui
	immcolorbtn [ $808080 xor ; ] guiI SDLColor
	plxywh SDLFRect
	immlabelc
	onClick ;	

|----------------------
:slideh | 0.0 1.0 'value --
	sdlx curx padx + - boxw clamp0max 
	2over swap - | Fw
	boxw */ pick3 +
	over ! ;
	
:slideshow | 0.0 1.0 'value --
	$ff00007f SDLColor
	curx padx + cury pady + boxw boxh SDLFRect
	$ff3f3fff [ $ff7f7fff nip ; ] guiI SDLColor
	dup @ pick3 - 
	boxw 8 - pick4 pick4 swap - */ 
	curx padx + 1 + +
	cury pady + 2 + 
	6 
	boxh 4 - 
	SDLFRect ;
	
::immSliderf | 0.0 1.0 'value --
	plgui
	'slideh dup onDnMoveA | 'dn 'move --	
	slideshow
	@ .f2 immLabelC
	2drop ;

::immSlideri | 0 255 'value --
	plgui
	'slideh dup onDnMoveA | 'dn 'move --	
	slideshow	
	@ .d immLabelC
	2drop ;	

|----------------------	
:check | 'var ""
	curx padx + cury pady + 14 boxh SDLFRect
	over @ 1 nand? ( drop ; ) drop 
	$ff7f7fff SDLColor 
	curx padx + 4 + cury pady + 4 + 6 boxh 8 - SDLFRect
	;
	
::immCheck | 'val "op1" -- ; v op1  v op2  x op3
	plgui
	$ff00007f [ $ff0000ff nip ; ] guiI SDLColor 
	check
	20 'padx +!
	immLabel
	-20 'padx +!
	[ dup @ 1 xor over ! ; ] onClick
	drop ;
	
|----------------------
#cntlist
	
:makelist | "" -- list
	1 'cntlist !
	here >a
	a> swap
	( c@+ 1?
		$7c =? ( 1 'cntlist +! 0 nip )
		ca!+ ) ca!+ 
	a> 'here !
	drop ;
	
:nlist | here n -- str
	( 1? 1 - swap >>0 swap ) drop ;	
	
|----------------------
:radio | 'var nro "" -- 'var nro "" 
	boxh 1 >> pady - dup
	curx boxh 1 >> + cury boxh 1 >> + pady +
	SDLfEllipse
	pick2 @ pick2 <>? ( drop ; ) drop 
	$ff7f7fff SDLColor 
	boxh 1 >> pady - 4 - dup
	curx boxh 1 >> + cury boxh 1 >> + pady +
	SDLfEllipse
	;
	
:iglRadio | val nro str -- val nro str
	plgui
	$ff00007f [ $ff0000ff nip ; ] guiI SDLColor 
	radio
	20 'padx +!
	dup immLabel
	-20 'padx +!
	[ over pick3 ! ; ] onClick
	;

::immRadio | 'val "op1|op2|op3" -- ; ( ) op1  (x) op2 ( ) op3
	mark
	makelist
	0 ( cntlist <? swap
		iglRadio immdn |glri
		>>0 swap 1 + ) 3drop 
	empty ;
	
|--------------------------------

#win1 1 [ 10 10 300 500 ] "Ventana de prueba"

|--------------------------------	
#cv 0
#buffer * 100
#otrob * 50
#vchek
#vradio
#vcombo
	
:main
	0 SDLcls
	immgui
	
	'win1 immwin drop

	'exit "salir" immbtn immdn
	0 255 'cv immSlideri immdn
	'vchek "Check" immCheck immdn
	'vradio "Radio 1|Radio 2|Radio 3" immRadio  
|	'vcombo "Combo 1|Combo 2|Combo 3|Combo 4" glCombo gldn	
	
	SDLredraw 
	SDLkey
	>esc< =? ( exit )
	drop ;	
	
#font	

: 	|<<<<<<<<<<<<<< BOOT
	"r3sdl" 800 600 SDLinit
	ttf_init	
|	"media/ttf/ProggyClean.ttf" 
	"media/ttf/Roboto-Medium.ttf" 
	16 TTF_OpenFont 'font !	
	font ttfont
|	bfont1
	
	'main SDLShow 
	SDLquit
	;
