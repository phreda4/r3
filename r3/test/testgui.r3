| immg develop with SDL backend
| PHREDA 2023

^r3/lib/gui.r3

^r3/win/sdl2gfx.r3
^r3/util/bfont.r3
^r3/lib/input.r3


#winx 10 #winy 10
#winw 10 #winh 10

#padx 2 #pady 2
#curx 10 #cury 10
#boxw 100 #boxh 20

#immcolortex $ffffff
#immcolorbtn $0000ff

#immfontsh 16
:immfontsw count 3 << ;

:immgui
	gui
	;
	
:immat
	'cury ! 'curx ! ;
:immbox
	'boxh ! 'boxw ! ;
	
|--- place
:plgui
	curx padx + cury pady + boxw boxh guiBox ;

:plxywh
	curx padx + cury pady + boxw boxh ;

	
|--- label

:immlabel
	immcolortex SDLColor
	curx padx + 
	boxh immfontsh - 1 >> cury + pady + 
	bat bprint ;
	
:immlabelc
	immcolortex SDLColor
	immfontsw boxw swap - 1 >> curx + padx +
	boxh immfontsh - 1 >> cury + pady + 
	bat	bprint ;

:immlabelr
	immcolortex SDLColor
	immfontsw boxw swap - curx + padx +
	boxh immfontsh - 1 >> cury + pady + 
	bat	bprint ;
	
|--- win
:winxy!
	dup $ffffffff and 'winx ! 32 >> 'winy ! ;
	
:winwh!
	dup $ffffffff and 'winw ! 32 >> 'winh ! ;

:winhome
	winx padx + 'curx ! 
	winy pady 1 << + immfontsh + | bfont1 h
	'cury ! ;

:wintitle | "" --
	$00007f SDLColor
	winx winy winw winh SDLFRect
	winx 'curx ! winy 'cury !
	winw padx 1 << - 'boxw ! immfontsh pady 1 << + 'boxh !
	$00001f SDLColor
	plxywh SDLFRect
	immlabelc
	
	;	
	
#px #py 	
:movwin
	sdlx dup px - swap 'px ! over 8 + d+!
	sdly dup py - swap 'py ! over 12 + d+! ;
	
:immwin | 'win -- 0/1
	dup 8 + @+ winxy! @+ winwh! wintitle
	curx padx + cury pady + boxw boxh guiBox
	[ sdlx 'px ! sdly 'py ! ; ] 'movwin onDnMoveA
	@ winhome
	100 'boxw !
	;		

|--- widget	
::immbtn | 'click "" --
	plgui
	immcolorbtn [ $808080 xor ; ] guiI SDLColor
	plxywh SDLFRect
	immlabelc
	onClick ;	
	
|--------------------------------

#win1 1 [ 10 10 300 500 ] "Ventana de prueba"

|--------------------------------	
#cv 0
#buffer * 100
#otrob * 50
	
:main
	0 SDLcls
	immgui
	
	'win1 immwin drop
	'exit "salir" immbtn
	
	SDLredraw 
	SDLkey
	>esc< =? ( exit )
	drop ;	
	

: 	|<<<<<<<<<<<<<< BOOT
	"r3sdl" 800 600 SDLinit
	bfont1
	
	'main SDLShow 
	SDLquit
	;
