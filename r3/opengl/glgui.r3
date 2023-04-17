| OpenGL example
| PHREDA 2023
|MEM 64
^r3/lib/gui.r3
^r3/lib/3dgl.r3
^r3/win/sdl2gl.r3

^r3/opengl/glfont.r3

| opengl Constant
#GL_DEPTH_TEST $0B71
#GL_CULL_FACE $0B44
#GL_BLEND $0BE2
#GL_SRC_ALPHA $0302
#GL_ONE_MINUS_SRC_ALPHA $0303

|-------------------------------------
##guicolorbtn $ff0000ff
##guicolortex $ffffffff


#winx 10 #winy 10
#winh 10 #winh 10 
	
|--------------	GUI
#padx 2 #pady 2

#curx 10 #cury 10
#boxw 100 #boxh 20

::glgui |
	gui 
	winx 'curx ! winy 'cury !
	
	GL_DEPTH_TEST glDisable 
	GL_CULL_FACE glDisable
	GL_BLEND glEnable
	GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA glBlendFunc
	;

::glnowin | xini yini w h --
	'boxh ! 'boxw !
	dup 'winy ! 'cury ! 
	dup 'winx ! 'curx ! ;

::glwidth
	'boxw ! ;
	
|----------------------	
::gl>>
	padx 1 << boxw + 'curx +! ;	
::gldn
	pady 1 << boxh + 'cury +! ;
::gl<<dn
	winx 'curx !
	pady 1 << boxh + 'cury +! ;
	
|----------------------	
::gllabel | "" --
	guicolortex glcolor
	curx padx + 
	boxh glFontSize 16 >> - 2 >> cury + pady + 
	glat
	glText
	;
	
::gllabelC | "" --
	guicolortex glcolor
	GlTextW 16 >> boxw swap - 1 >> curx + padx +
	boxh glFontSize 16 >> - 2 >> cury + pady + 
	glat
	glText ;

::gllabelR | "" --
	guicolortex glcolor
	GlTextW 16 >> boxw swap - curx + padx +
	boxh glFontSize 16 >> - 2 >> cury + pady + 
	glat
	glText ;
	
|----------------------	
::gltbtn | 'click "" --
	curx padx + cury pady + boxw boxh 
	2over 2over guiBox
	guicolorbtn [ $808080 xor ; ] guiI glcolor
	frect
	glLabelC
	onClick ;
	
|----------------------
:slideh | 0.0 1.0 'value --
	sdlx curx padx + - boxw clamp0max 
	2over swap - | Fw
	boxw */ pick3 +
	over ! ;
	
:slideshow | 0.0 1.0 'value --
	$ff00007f glcolor
	curx padx + cury pady + boxw boxh frect
	$ff3f3fff [ $ff7f7fff nip ; ] guiI glcolor
	dup @ pick3 - 
	boxw 8 - pick4 pick4 swap - */ 
	curx padx + 1 + +
	cury pady + 2 + 
	6 
	boxh 4 - 
	frect ;
	
::glSliderf | 0.0 1.0 'value --
	curx padx + cury pady + boxw boxh guiBox
	'slideh dup onDnMoveA | 'dn 'move --	
	slideshow
	@ .f2 glLabelC
	2drop ;

::glSlideri | 0 255 'value --
	curx padx + cury pady + boxw boxh guiBox
	'slideh dup onDnMoveA | 'dn 'move --	
	slideshow	
	@ .d glLabelC
	2drop ;

|----------------------	
:check | 'var ""
	curx padx + cury pady + 14 boxh frect
	over @ 1 nand? ( drop ; ) drop 
	$ff7f7fff glcolor 
	curx padx + 4 + cury pady + 4 + 8 boxh 8 - frect
	;
	
::glCheck | 'val "op1" -- ; v op1  v op2  x op3
	curx padx + cury pady + boxw boxh guiBox
	$ff00007f [ $ff0000ff nip ; ] guiI glcolor 
	check
	guicolortex glcolor
	curx padx + 20 + cury pady + glat
	gltext
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
	curx padx + cury pady + 14 boxh fcirc
	pick2 @ pick2 <>? ( drop ; ) drop 
	$ff7f7fff glcolor 
	curx padx + 3 + cury pady + 3 + 9 boxh 7 - fcirc
	;
	
:iglRadio | val nro str -- val nro str
	curx padx + cury pady + boxw boxh guiBox
	$ff00007f [ $ff0000ff nip ; ] guiI glcolor 
	radio
	guicolortex glcolor 
	curx padx + 20 + cury pady + glat
	dup gltext
	[ over pick3 ! ; ] onClick
	;

::glRadio | 'val "op1|op2|op3" -- ; ( ) op1  (x) op2 ( ) op3
	mark
	makelist
	0 ( cntlist <? swap
		iglRadio gldn |glri
		>>0 swap 1 + ) 3drop 
	empty ;
	
|----------------------	
::glCombo | 'val "op1|op2|op3" -- ; [op1  v]
	mark
	makelist
	$ff00007f glcolor
	curx padx + cury pady + boxw boxh
	2over 2over guiBox rect	
	$ff00007f [ $ff0000ff nip ; ] guiI glcolor 
	curx padx + boxw + 16 - cury 14 boxh ftridn	
	guicolortex glcolor 
	curx padx + 1 + cury pady + boxh 16 - 1 >> + glat	
	over @ nlist gltext
	
	[ dup @ 1 + cntlist >=? ( 0 nip ) over ! ; ] onClick
	drop
	empty
	;

|----------------------
:glwindow
	;
:gltab
	;
:glTable
	;

|--- Edita linea
#cmax
#padi>	| inicio
#pad>	| cursor
#padf>	| fin

:lins  | c --
	padf> padi> - cmax >=? ( 2drop ; ) drop
	pad> dup 1 - padf> over - 1 + cmove> 1 'padf> +!
:lover | c --
	pad> c!+ dup 'pad> !
	padf> >? (
		dup padi> - cmax >=? ( swap 1 - swap -1 'pad> +! ) drop
		dup 'padf> ! ) drop
:0lin | --
	0 padf> c! ;
:kdel
	pad> padf> >=? ( drop ; ) drop
	1 'pad> +!
:kback
	pad> padi> <=? ( drop ; )
	dup 1 - swap padf> over - 1 + cmove -1 'padf> +! -1 'pad> +! ;
:kder
	pad> padf> <? ( 1 + ) 'pad> ! ;
:kizq
	pad> padi> >? ( 1 - ) 'pad> ! ;
:kup
	pad> ( padi> >?
		1 - dup c@ $ff and 32 <? ( drop 'pad> ! ; )
		drop ) 'pad> ! ;
:kdn
	pad> ( c@+ 1?
		$ff and 32 <? ( drop 'pad> ! ; )
		drop ) drop 1 - 'pad> ! ;

#modo 'lins

::glcursoro | "" pos -- ""
	glCursorRect frect ;
	
::glcursori | "" pos -- ""
	glCursorRect 
	1 >> 2swap pick2 + 2swap 
	frect ;

:cursor
	msec $100 and? ( drop ; ) drop
	$ff00 glcolor
	modo 'lins =? ( drop pad> padi> - glcursori ; ) drop
	pad> padi> - glcursoro ;
	
|----- ALFANUMERICO
:iniinput | 'var max IDF -- 'var max IDF
	pick2 1 - 'cmax !
	pick3 dup 'padi> !
	( c@+ 1? drop ) drop 1 -
	dup 'pad> ! 'padf> !
	'lins 'modo !
	;

:chmode
	modo 'lins =? ( drop 'lover 'modo ! ; )
	drop 'lins 'modo ! ;

:proinputa | --
	cursor 
	SDLchar 1? ( modo ex ; ) drop
	SDLkey 0? ( drop ; )
	<ins> =? ( chmode )
	<le> =? ( kizq ) <ri> =? ( kder )
	<back> =? ( kback ) <del> =? ( kdel )
	<home> =? ( padi> 'pad> ! ) <end> =? ( padf> 'pad> ! )
	<tab> =? ( nextfoco )
	<ret> =? ( nextfoco )
|	<shift> =? ( 1 'mshift ! ) >shift< =? ( 0 'mshift ! )
|	<dn> =? ( nextfoco ) <up> =? ( prevfoco )
	drop
	;


|************************************
::glInput | 'buff max --
	$ff0000ff glcolor
	curx padx + cury pady + 2dup boxw boxh 
	2over 2over guiBox rect
	boxh 16 - 1 >> + glat
|	$7f7f7f [ $ffffff nip ; ] guiI glcolor
	'proinputa 'iniinput w/foco
	'clickfoco onClick
	guicolortex glcolor
	drop gltext ;

:glInputInt | 'buff  --
	;
:glInputFix | 'buff  --
	;

