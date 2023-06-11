| immg develop with SDL backend
| PHREDA 2023

^r3/lib/gui.r3

^r3/win/sdl2gfx.r3
^r3/util/ttfont.r3
^r3/lib/input.r3

#winx 10 #winy 10
#winw 10 #winh 10

#padx 2 #pady 2
##curx 10 ##cury 10
#boxw 100 #boxh 20

##immcolorwin $666666	| window 
##immcolortwin $444444	| title window (back)
##immcolortex $ffffff	| text
##immcolorbtn $0000ff	| button

#icons
#font	
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
	winx padx + 'curx !
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
	
|--- icon
::immicon | nro x y --
	icons rot rot tsdraw ;
	
::immiconb
	immcolortex ttColor
	curx padx +
	cury  
	immicon ;
	
	
|--- win
:winxy!
	dup $ffffffff and 'winx ! 32 >> 'winy ! ;
	
:winwh!
	dup $ffffffff and 'winw ! 32 >> 'winh ! ;

:wintitle | "" --
	immcolorwin SDLColor
	winx winy winw winh SDLFRect
	0 SDLColor
	winx winy winw winh SDLRect
	
	winx 'curx ! winy 'cury !
	winw padx 2 << - 'boxw ! immfontsh pady 1 << + 'boxh !
	immcolortwin SDLColor
	plxywh SDLFRect
	immlabelc
	;	
	
#px #py 	
:movwin
	sdlx dup px - swap 'px ! over 8 + d+!
	sdly dup py - swap 'py ! over 12 + d+! ;

:wintit
	dup 8 + 
	@+ dup $ffffffff and 'curx ! 32 >> 'cury ! 
	@ $ffffffff and padx 1 << - 'boxw !
	immfontsh pady 1 << + 'boxh !
	plgui
	[ sdlx 'px ! sdly 'py ! ; ] 'movwin onDnMoveA
	;
	
::immwin | 'win -- 0/1
	wintit
	dup 8 + @+ winxy! @+ winwh! wintitle
	@ 
	winx padx + 'curx ! 
	winy pady 2 << + immfontsh + 'cury ! 

	winw 1 >> 'boxw !
	;	

::immnowin | xini yini w h --
	'boxh ! 'boxw !
	dup 'winy ! 'cury ! 
	dup 'winx ! 'curx ! ;
	
::immwidth |w -- 
	'boxw ! ;	

|--- widget	
::immbtn | 'click "" --
	plgui
	immcolorbtn [ $808080 xor ; ] guiI SDLColor
	plxywh SDLFRect
	immlabelc
	onClick ;	

::immibtn | 'click nro --
	plgui
	immcolorbtn [ $808080 xor ; ] guiI SDLColor
	plxywh SDLFRect
	immiconb
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
:checkic | 'var ""
	over @ 1 nand? ( 60 nip ; ) drop 59 ;
	
::immCheck | 'val "op1" -- ; v op1  v op2  x op3
	plgui
	$ffffff [ $7f7fff nip ; ] guiI icons TSColor
	checkic curx cury immicon
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
:radioic | 'var nro "" -- 'var nro "" 
	pick2 @ pick2 <>? ( 238 nip ; ) drop 236 ;
	
:iglRadio | val nro str -- val nro str
	plgui
	$ffffff [ $7f7fff nip ; ] guiI icons TSColor
	radioic curx cury immicon
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
::glCombo | 'val "op1|op2|op3" -- ; [op1  v]
	mark
	makelist
	$ff00007f SDLColor
	plgui
	plxywh SDLFRect
	$ffffff [ $7f7f7fff nip ; ] guiI icons TSColor
	268	curx boxw + 24 - cury immicon
	over @ nlist immLabel
	[ dup @ 1 + cntlist >=? ( 0 nip ) over ! ; ] onClick
	drop
	empty
	;
	
|--------------------------------
::immSDL | "font" size --
	ttf_init	
|	"media/ttf/ProggyClean.ttf" 16
	TTF_OpenFont 'font !	
	font ttfont
	24 21 "media/img/icong16.png" tsload 'icons !
	;
