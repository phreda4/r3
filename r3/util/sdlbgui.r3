| immg develop with SDL backend
| bfont 
| PHREDA 2023

^r3/lib/gui.r3
^r3/win/sdl2gfx.r3
^r3/lib/input.r3

#winx 0 #winy 0
#winw 10 #winh 10

#padx 2 #pady 2
##curx 10 ##cury 10
##boxw 100 ##boxh 20

##immcolorwin $666666	| window 
##immcolortwin $444444	| title window (back)
##immcolortex $ffffff	| text
##immcolorbtn $0000ff	| button

::immgui 
	0 'winx ! 0 'winy !
	0 'cury ! 0 'curx !
	200 'boxw ! 20 'boxh !
	gui ;

::immat 'cury ! 'curx ! ;
::immat+ 'cury +! 'curx +! ;
::immbox 'boxh ! 'boxw ! ;
::immwinxy 2dup 'winy ! 'winx ! immat ;

|----------------------	
::imm>>
	padx 1 << boxw + 'curx +! ;	
::imm<<
	padx 1 << boxw + neg 'curx +! ;	
::immdn
	pady 1 << boxh + 'cury +! ;
::immcr
	winx padx + 'curx ! 
	pady 1 << boxh + 'cury +! ;	

::immln
	winx padx + 'curx ! boxh 'cury +! ;	
	
|--- place
:plgui
	curx padx + cury pady + boxw boxh guiBox ;

::plxywh
	curx padx + cury pady + boxw boxh ;

::immcur | x y w h --
	pick3 winx + pick3 winy + pick3 pick3 guiBox
	$999999 sdlcolor pick3 pick3 pick3 pick3 SDLRect
	'boxh ! 'boxw ! 'cury ! 'curx ! 
	;
	
::immcur> | -- cur
	curx cury 16 << or boxw 32 << or boxh 48 << or ;
	
::imm>cur | cur --
	dup $ffff and 'curx !
	16 >> dup $ffff and 'cury !
	16 >> dup $ffff and 'boxw !
	16 >> $ffff and 'boxh ! ;
	
|--- label
::immlabel | "" --
	immcolortex bcolor
	curx padx + 
	boxh 16 - 1 >> cury + pady + 
	bat bprint ;
	
::immlabelc | "" --
	immcolortex bcolor
	bsize boxw rot - 1 >> curx + padx +
	boxh rot - 1 >> cury + pady + 
	bat bprint ;

::immlabelr | "" --
	immcolortex bcolor
	bsize boxw rot - curx + padx -
	boxh rot - 1 >> cury + pady +
	bat bprint ;

::imm. | "" --
	immcolortex bcolor
	curx padx + 
	boxh 16 - 1 >> cury + pady + 
	bat sprint dup bprint
	bsize drop nip padx 1 << + 'curx +!
	;

::immListBox | lines --
	boxh * curx cury rot boxw swap guiBox ;

|--- text in list, no pad
::immback | color --
	SDLColor curx padx + cury boxw boxh SDLFRect ;

::immblabel | "" --
	immcolortex bcolor
	curx padx + 
	boxh 16 - 1 >> cury + 
	bat bprint ;
	
|--- widget	
::immbtn | 'click "" --
	plgui
	immcolorbtn [ $808080 xor ; ] guiI SDLColor
	plxywh SDLFRect
	immlabelc
	onClick ;	

::immtbtn | 'click "" --
	bsize drop 'boxw !
	plgui
	[ immcolorbtn SDLColor plxywh SDLFRect ; ] guiI
	imm.
	onClick ;

::immzone | 'click --
	plgui onClick ;

|---- Horizontal slide
:slideh | 0.0 1.0 'value --
	sdlx curx padx + - boxw clamp0max 
	2over swap - | Fw
	boxw */ pick3 +
	over ! ;
	
:slideshow | 0.0 1.0 'value --
	$7f SDLColor
	curx padx + cury pady + boxw boxh SDLFRect
	$3f3fff [ $7f7fff nip ; ] guiI SDLColor
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
:checkic | 'var ""
	over @ 1 nand? ( "x" nip ; ) drop " " ;
	
::immCheck | 'val "op1" -- ; v op1  v op2  x op3
	plgui
	$ffffff [ $7f7fff nip ; ] guiI bcolor
	checkic imm.
	20 'padx +!
	immLabel
	-20 'padx +!
	[ dup @ 1 xor over ! ; ] onClick
	drop ;
	
|---- Vertical slide *** incorrect
:slidev | 0.0 1.0 'value --
	sdly cury - boxh 4 - clamp0max 
	2over swap - 1 + | Fw
	boxh */ pick3 +
	over ! ;
	
#wid	

:scrollshowv | 0.0 1.0 'value --
|	$ff00007f SDLColor
|	curx padx + cury pady + boxw boxh SDLFRect
	$7f7f7f [ $1f1f1f nip ; ] guiI SDLColor
	
	dup @ pick3 - 
	boxh 4 - pick4 pick4 swap - 1 + */ 
	curx padx + 
	cury pady + rot + 
	boxw 4 - wid 1 - SDLFRect ;
	
::immScrollv | 0 max 'value --
	plgui
	'slidev dup onDnMoveA | 'dn 'move --	
	boxh pick3 pick3 swap - 1 + / 'wid !
	scrollshowv	
	3drop ;	
	
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
:radioic | 'var nro "" -- 'var nro "" 
	pick2 @ pick2 <>? ( "x" nip ; ) drop " " ;
	
:iglRadio | val nro str -- val nro str
	plgui
	$ffffff [ $7f7fff nip ; ] guiI bcolor
	checkic imm.
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

|----------------------	
::immCombo | 'val "op1|op2|op3" -- ; [op1  v]
	mark
	makelist
	$7f SDLColor
	plgui
	plxywh SDLFRect
	$ffffff [ $7f7fff nip ; ] guiI bcolor
	268	curx boxw + 24 - cury bat "v" bprint
	over @ nlist immLabel
	[ dup @ 1 + cntlist >=? ( 0 nip ) over ! ; ] onClick
	drop
	empty
	;
	
|--------- input text	

|--- Edita linea
#cmax
#padi>	| inicio
#pad>	| cursor
#padf>	| fin

:lins  | c -- ;
	padf> padi> - cmax >=? ( 2drop ; ) drop
	pad> dup 1 - padf> over - 1 + cmove> 1 'padf> +!
:lover | c -- ;
	pad> c!+ dup 'pad> !
	padf> >? (
		dup padi> - cmax >=? ( swap 1 - swap -1 'pad> +! ) drop
		dup 'padf> ! ) drop
:0lin 0 padf> c! ;
:kdel pad> padf> >=? ( drop ; ) drop 1 'pad> +! | --;
:kback pad> padi> <=? ( drop ; ) dup 1 - swap padf> over - 1 + cmove -1 'padf> +! -1 'pad> +! ;
:kder pad> padf> <? ( 1 + ) 'pad> ! ;
:kizq pad> padi> >? ( 1 - ) 'pad> ! ;
:kup
	pad> ( padi> >?
		1 - dup c@ $ff and 32 <? ( drop 'pad> ! ; )
		drop ) 'pad> ! ;
:kdn
	pad> ( c@+ 1?
		$ff and 32 <? ( drop 'pad> ! ; )
		drop ) drop 1 - 'pad> ! ;

#modo 'lins

:cursor | 'var max
	msec $100 and? ( drop ; ) drop
	$a0a0a0 SDLColor
	modo 'lins =? ( drop padi> pad> bcursor drop ; ) drop
	padi> pad> bcursori drop ;
	
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
	$ffffff SDLColor
	curx cury boxw padx 1 << + boxh pady 1 << + sdlRect

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
::immInputLine | 'buff max --
	plgui
	$222222 SDLColor
	curx cury boxw padx 1 << + boxh pady 1 << + sdlFRect
|	boxh 16 - 1 >> + bat
|	$7f7f7f [ $ffffff nip ; ] guiI glcolor
	curx padx + 
	boxh 16 - 1 >> cury + pady + 
	bat 
	'proinputa 'iniinput w/foco
	'clickfoco onClick
	$ffffff bcolor
	drop
	bprint ;


|----- ENTERO
:iniinputi
	pick2 'cmax ! ;

:knro
	SDLchar 0? ( drop ; ) $30 <? ( drop ; ) $39 >? ( drop ; )
	$30 - cmax @ 10 * + cmax ! ;

:proinputi
	$ffffff SDLColor
	curx cury boxw padx 1 << + boxh pady 1 << + sdlRect
	|1 cursor drop
	knro
	sdlkey
	<back> =? ( cmax @ 10 / cmax ! )
	<del> =? ( cmax @ 10 / cmax ! )
	|<-> =? ( cmax neg 'cmax ! )
	<tab> =? ( nextfoco )
	<ret> =? ( nextfoco )
	drop ;

|************************************
::immInputInt | 'var --
	plgui
	$222222 SDLColor
	curx cury boxw padx 1 << + boxh pady 1 << + sdlFRect
	curx padx + 
	boxh 16 - 1 >> cury + pady + 
	bat 
	'proinputi 'iniinputi w/foco
	'clickfoco onClick
	$ffffff bcolor
	@ "%d" bprint ;

|----- static windows
:winxy!
	dup 32 << 32 >> 'winx ! 32 >> 'winy ! ;
	
:winwh!
	dup 32 << 32 >> 'winw ! 32 >> 'winh ! ;
	
:wintitles | "" --
	immcolorwin SDLColor
	winx winy winw winh 
	pick3 pick3 pick3 pick3 SDLFRect
	pick3 pick3 pick3 pick3 guiBox
	0 SDLColor SDLRect
	winx 'curx ! winy 'cury !
	winw padx 1 << - 'boxw ! 16 pady + 'boxh !
	immcolortwin SDLColor
	plxywh SDLFRect 
	immlabelc
	winx winy 16 pady + + winw winh 16 pady + - guiBox 
	;	
	
::immwins
	|dup @ |$2 and? ( winnow 'winhot ! ) drop | all in top
	|wintit
	dup 8 + @+ winxy! @+ winwh! wintitles
	@ 
	winx padx + 'curx ! 
	winy pady 2 << + 16 + 'cury ! 
	winw 1 >> padx 1 << - padx - 'boxw !
	;