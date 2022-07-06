| MAPEDITOR
|PHREDA

^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3

^r3/lib/gui.r3

^r3/util/tilesheet.r3
^r3/util/bfont.r3
^r3/util/dlgfile.r3

#sprgui


#filemap * 1024
#mapx 0 #mapy 0
#mapw 32 #maph 32
#mapamem 0	| 0 when not allocate 

#filetile * 1024
#tilew 32 #tileh 32
#tilemem

#tilenow 0


|--------------------------------
:loadfile
	dlgFileLoad 
	0? ( drop ; )
	dup 'filemap strcpy
	
	;
	
|--------------------------------
#ntilepage 0

:xy2pal | -- x y 
	sdlx 40 - tilew 8 + / tilew 8 + * 40 +
	sdly 40 - tileh 8 + / tileh 8 + * 40 + ;
	
:inpal
	$403DFF SDLColor
	xy2pal tilew 8 + tileh 8 + SDLFRect ;	
	
:clpal
	sdlx 40 - tilew 8 + / 
	sdly 40 - tileh 8 + / 
	sw 40 - tilew 8 + /
	*
	+ 
	'tilenow !
	exit
	;
	
:pagetile
	40 40 sw sh guiBox
	SDLb SDLx SDLy guiIn
	
	'inpal guiI
	'clpal onClick

	ntilepage
	44 ( sh <? 
		44 ( sw <? 
			pick2 tilemem 2over swap tsdraw
			rot 1 + rot rot
			tilew 8 + + ) drop
		tileh 8 + + ) 2drop
	;

:stileset
	gui
	0 SDLcls

	$ffffff bcolor 
	44 4 bat "TILESET " bprint
	44 20 bat tileh tilew "tilew:%d tilew:%d" sprint bprint
	
	pagetile
	
	SDLredraw
	SDLkey 
	>esc< =? ( exit )
	drop ;

	
|--------------------------------
#paleta 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 

:pal? | color -- color nro
	'paleta >a 
	15 ( 1? 1 -
		a@+ pick2 =? ( 2drop a> 'paleta - 3 >> 1 - ; )
		drop ) drop 14 ;

:palins! | nro --
	pal?
	'paleta dup cell+ swap rot move>
	'paleta !
	;

:selectile
	'stileset SDLshow
	tilenow palins!
	;

:paldraw
	0 0 40 40 guiBox
	SDLb SDLx SDLy guiIn
	'selectile onClick
	
	0 40 40 sh guiBox
	SDLb SDLx SDLy guiIn
	[ $403DFF SDLColor sdly 40 / 0 swap 40 * 40 40 SDLFRect ; ] guiI
	[ 'paleta sdly 40 / ncell+ @ dup palins! 'tilenow ! ; ] onClick

	0
	0 ( 12 <?
		'paleta over ncell+ @ tilemem 4 pick4 4 + tsdraw
		swap 40 + swap
		1 + ) 2drop ;	
	
	
|--------------------------------
#modo 0

:Xinitool
	sw 8 40 * - ;
:xy2tool | -- btn
	sdlx Xinitool - 40 / ;
:tool2xy | btbn -- x y
	40 * Xinitool + 0 ;
:inbtn
	$403DFF SDLColor
	xy2tool tool2xy 40 40 SDLFRect ;	
	
:clicktool
	xy2tool 
	4 <? ( 'modo ! ; )
	4 =? ( drop ; )
	5 =? ( drop loadfile ; )
	6 =? ( drop ; )
	drop exit ;
	
:toolbar	
	$999999 SDLColor
	modo tool2xy 40 40 SDLFRect 

	Xinitool 0 sw 40 guiBox
	SDLb SDLx SDLy guiIn
	'inbtn guiI
	'clicktool onClick
	
	Xinitool
	0 ( 8 <?
		dup sprgui pick3 4 + 4 tsdraw
		swap 40 + swap
		1 + ) 2drop ;

|-------------------------------

:writetile	|  --
	tilenow
	sdlx sdly scr2tile c!
	;
	
:mdraw
	'writetile dup onDnMove ;
	
#ox #oy
#mx #my

:mmove
	[ sdlx 'ox ! sdly 'oy ! mapx 'mx ! mapy 'my ! ; ] 
	[ ox sdlx - tilew / mx + clamp0 'mapx !
	  oy sdly - tileh / my + clamp0 'mapy ! ; ] 
	onDnMove ;
	
:msele
	[ ; ] [ ; ] onDnMove ;
	
:mfill
	'writetile onClick
	;
	
#modelist 'mdraw 'mmove 'msele 'mfill

:grid
	$666666 SDLColor
	40 ( sh <? 
		40 over sw over SDLline
		tileh + ) drop
	40 ( sw	<? 
		dup 40 over sh SDLLine
		tilew + ) drop 
	;
	
:mapinscreen
	24 18 mapx mapy 40 40  	
	mapamem tiledraw	
	
	grid

	40 40 sw sh guiBox
	SDLb SDLx SDLy guiIn
	modo 3 << 'modelist + @ ex
	;
	
:teclado
	SDLkey 
	>esc< =? ( exit )
	<f1> =? ( 0 'modo ! )
	<f2> =? ( 1 'modo ! )
	<f3> =? ( 2 'modo ! )
	<f4> =? ( 3 'modo ! )
	drop 
	;
	
:demo
	gui
	0 SDLcls

	$ffffff bcolor 
	44 4 bat "MAPEDIT " bprint
	44 20 bat maph mapw mapy mapx "x:%d y:%d w:%d h:%d" sprint bprint
	
	mapinscreen
	toolbar
	paldraw

	SDLredraw
	teclado ;

:loadmap
	mapamem 1? ( empty ) drop
	mark
	tilew tileh 'filetile loadts 
	dup 'tilemem !	
	here dup >a 'mapamem !
	a!+ | tile
	mapw da!+ maph da!+ 
	tilew da!+ tileh da!+ 
	32 ( 1? 32 ( 1? 
		0 ca!+ 
		1 - ) drop 1 - ) drop
	;
	
:main
	"media/map" dlgSetPath
	"r3sdl" 800 600 SDLinit
	bfont1 
	|SDLfull
	
	32 32 "r3\j2022\mapeditor32.png" loadts 'sprgui !

	
	20 20 'tilew ! 'tileh !
	"r3\j2022\trebor\trebortiles.png" 
	'filetile strcpy
	loadmap
	
|	32 32 "media\img\open_tileset.png" loadts 
|	dup 'tilemem !	
|	'mapa1 !
	
	'demo SDLshow
	SDLquit ;	
	
: main ;