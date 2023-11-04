| MAPEDITOR
| PHREDA 2023

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

#mgrid 1
#tilenow 1
#scrw #scrh
#scrmw #scrmh

|--------------------------------
#paleta 1 0 2 3 4 5 6 7 8 9 10 11 12 13 14 15 

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

|--------------------------------
:recalc
	sw 40 - tilew / 1 + 'scrw !
	sh 40 - tileh / 1 + 'scrh !

	mapw scrw - 1 + 'scrmw	!
	maph scrh - 1 + 'scrmh	!
	;

#newmapw
#newmaph

:mapzero
	maph ( 1? mapw ( 1?  
		0 ,c 1 - ) drop 1 - ) drop ;
	
:mapmemmory
	mapamem 
	0? ( drop mapzero ; ) 
	24 + >b
	maph ( 1? 
		b> >a
		mapw ( 1?	
			ca@+ ,c 
			1 - ) drop 
		newmapw b+	
		1 - ) drop ;
	
:savemap | --
	mark
	0 ,q 			| "tilemap" ,s 0 ,c | 8 bytes
	mapw , maph ,
	tilew , tileh ,
	mapmemmory
	'filetile ,s 0 ,c
	'filemap savemem
	empty
	;

:loadmap
	mapamem 1? ( empty ) drop
	mark
	here 'filemap load here =? ( drop ; )
	
	here 8 + 
	d@+ 'mapw ! d@+ 'maph !
	d@+ 'tilew ! d@+ 'tileh !
	mapw maph * + 'filetile strcpy
	'filetile c@ 0? ( 'mapamem ! ; ) drop 
	tilew tileh 'filetile tsload 'tilemem !	
	
	here 'filemap load drop
	here dup 'mapamem ! 
	tilemem swap !
	24 mapw maph * + 'here +!
	
	recalc ;
		
:loadfile
	dlgFileLoad 
	0? ( drop ; )
	dup 'filemap strcpy
	drop
	;

|--------------------------------

:clearmap
	mapamem 24 + >a
	maph ( 1? mapw ( 1?  
		0 ca!+ 1 - ) drop 1 - ) drop ;
	
:actualiza
	'filemap count "mem/mapedit.mem" save 
	maph newmaph 'maph ! 'newmaph !
	mapw newmapw 'mapw ! 'newmapw !
	savemap
	exit
	;
	
:config
	gui
	0 SDLcls
	
	newmapw newmaph
	0 0 
	200 80 
	2 2	mapamem tiledraws
	
	$666699 SDLColor
|	50 60 bat 'loadfile "[ TILES ]" tbtn
	
	$ffffff bcolor 
	40 40 bat "TILEMAP:" bprint  
	
|	120 40 bat 'filemap bprint
	120 40 bat 'filemap 64 input
	
	40 60 bat "TILESET:" bprint  
|	120 60 bat 'filetile bprint
	120 60 bat 'filetile 64 input
	
	40 80 bat "Width:" bprint 
	110 80 bat 'newmapw inputint
	40 100 bat "Height:" bprint 
	110 100 bat 'newmaph inputint

	40 120 bat "tileW:" bprint
	110 120 bat 'tilew inputint
	40 140 bat "tileH:" bprint 
	110 140 bat 'tileh inputint
	
	40 200 bat 'clearmap "[ CLEAR ]" tbtn
	40 220 bat 'actualiza "[ SAVE ]" tbtn
	
	SDLredraw
	
	SDLkey 
	>esc< =? ( exit )
	drop ;
	;
	
:configuracion
	mapw 'newmapw !
	maph 'newmaph !
	'config SDLshow
	;

|--------------------------------
:mapup
	mapamem 24 + >a
	here a> mapw cmove | d s c
	a> dup mapw + maph 1 - mapw * cmove
	a> maph 1 - mapw * + here mapw cmove
	;
:mapdn
	mapamem 24 + >a
	here a> maph 1 - mapw * + mapw cmove
	a> dup mapw + swap maph 1 - mapw * cmove>	
	 a> here mapw cmove | d s c
	;
:maple
	mapamem 24 + >a
	ca@
	a> dup 1 + mapw maph * 1 - cmove
	a> mapw maph * + 1 - >b
	maph ( 1? 1 - 
		b> mapw - c@ cb! 
		mapw neg b+
		) drop
	a> mapw + 1 - c!
	;
:mapri
	mapamem 24 + >a
	a> mapw maph * + 1 - c@
	a> dup 1 + swap mapw maph * 1 - cmove>
	a> >b
	maph ( 1? 1 - 
		b> mapw + c@ cb! 
		mapw b+
		) drop
	cb!	
	;
	
|--------------------------------
#ntilepage 0
#ntilew 8
#ntileh 8

:xy2pal | -- x y 
	sdlx 40 - tilew / ntilew 1 - clamp0max tilew * 40 +
	sdly 40 - tileh / ntileh 1 - clamp0max tileh * 40 + ;
	
:blink
	msec $80 and 1? ( $ffffff nip ; )
	0 nip ;
	
:inpal
	blink SDLColor
	xy2pal tilew tileh SDLRect ;	
	
:xy2tile
	sdlx 40 - tilew / ntilew 1 - clamp0max
	sdly 40 - tileh / ntileh 1 - clamp0max
	ntilew * +
	;
:clpal
	xy2tile 'tilenow ! exit ;
	
:pagetile
	40 40 sw sh guiBox
		
	40 40 tilemem @ sdlimage
	
	'inpal guiI
	'clpal onClick

	paleta tilemem 4 4 32 32 tsdraws
	;

:stileset
	gui
	0 SDLcls

	$ffffff bcolor 
	44 4 bat 'filetile "TILESET [ %s ]" sprint bprint
	44 20 bat tileh tilew "tilew:%d tilew:%d" sprint bprint
	200 20 bat xy2tile "tile:%d " sprint bprint 

	pagetile
	
	SDLredraw
	SDLkey 
	>esc< =? ( exit )
	drop ;

:selectile
	tilemem @ 0 0 'ntilew 'ntileh SDL_QueryTexture
	ntilew tilew / 'ntilew !
	ntileh tileh / 'ntileh !
	'stileset SDLshow
	tilenow palins!
	;

:paldraw
	mapamem 0? ( drop ; ) drop
	0 0 40 40 guiBox
	'selectile onClick
	
	0 40 40 sh guiBox
	[ $403DFF SDLColor sdly 40 / 0 swap 40 * 40 40 SDLFRect ; ] guiI
	[ 'paleta sdly 40 / ncell+ @ dup palins! 'tilenow ! ; ] onClick

	0 0 ( 12 <?
		'paleta over ncell+ @ tilemem 4 pick4 4 + 
		32 32 tsdraws
		swap 40 + swap
		1 + ) 2drop ;	
|--------------------------------
:viewscr
	gui
	0 SDLcls

	$ffffff bcolor 
	44 4 bat "FULLMAP" bprint
	44 20 bat maph mapw "maxx:%d maxy:%d" sprint bprint
	
	mapw maph 0 0 0 40 2 2	mapamem tiledraws	
	
	SDLredraw
	SDLkey 
	>esc< =? ( exit )
	drop ;

:viewfull	
	'viewscr SDLshow ;
	
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
	4 =? ( drop viewfull ; )
	5 =? ( drop loadfile ; )
	6 =? ( drop configuracion ; ) |savemap 
	drop exit ;
	
:toolbar	
	$999999 SDLColor
	modo tool2xy 40 40 SDLFRect 

	Xinitool 0 sw 40 guiBox
	'inbtn guiI
	'clicktool onClick
	
	Xinitool
	0 ( 8 <?
		dup sprgui pick3 4 + 4 tsdraw
		swap 40 + swap
		1 + ) 2drop ;

|-------------------------------
:writetile	|  --
	tilenow sdlx sdly scr2tile c! ;
	
:mdraw
	'writetile dup onDnMove ;
	
#ox #oy
#mx #my

:mapx! scrmw clamp0max 'mapx ! ;
:mapy! scrmh clamp0max 'mapy ! ;

:mmove
	[ sdlx 'ox ! sdly 'oy ! mapx 'mx ! mapy 'my ! ; ] 
	[ ox sdlx - tilew / mx + mapx! oy sdly - tileh / my + mapy! ; ] 
	onDnMove ;
	
:drawselect | --
	blink SDLColor
	sdlx sdly mx pick2 - my pick2 -  SDLRect
	;
	
:sort1d | m1 m2 -- mm mM
	over <? ( swap )
	;
	
:fillmap | --
	sdlx sdly scr2view | x y
	oy sort1d 'oy ! 'my !
	ox sort1d 'ox ! 'mx !
	mx ( ox <=?  
		my ( oy <=?
			2dup [map] tilenow swap c!
			1 + ) drop
		1 + ) drop ;
	
:msele
	[ sdlx sdly 2dup 'my ! 'mx ! scr2view 'oy ! 'ox ! ; ] 
	[ drawselect ; ] 
	[  fillmap ; ] guiMap ;
	
	
:mfill
	'writetile onClick
	;
	
#modelist 'mdraw 'mmove 'msele 'mfill

:grid
	$666666 SDLColor
	maph mapy - tileh * 40 + sh min
	mapw mapx - tilew * 40 + sw min
	40 ( pick2 <=? 
		40 over pick3 over SDLline
		tileh + ) drop
	40 ( over <=? 
		dup pick3 over 40 SDLLine
		tilew + ) 3drop ;
	
:mapinscreen
	scrw scrh mapx mapy 40 40  	
	mapamem 0? ( 4drop 3drop ; )
	tiledraw	
	
	mgrid 1? ( grid ) drop

	40 40 sw sh guiBox
	modo 3 << 'modelist + @ ex
	;
	
:teclado
	SDLkey 
	>esc< =? ( exit )
	<f1> =? ( 0 'modo ! )
	<f2> =? ( 1 'modo ! )
	<f3> =? ( 2 'modo ! )
	<f4> =? ( 3 'modo ! )
	<up> =? ( mapy 1 - mapy! )
	<dn> =? ( mapy 1 + mapy! )
	<le> =? ( mapx 1 - mapx! )
	<ri> =? ( mapx 1 + mapx! )
	<g> =? ( mgrid 1 xor 'mgrid ! )
	
	<a>	=? ( maple )
	<d> =? ( mapri )
	<w> =? ( mapup )
	<s> =? ( mapdn )
	drop 
	;
	
:upbar
	$ffffff bcolor 
	44 4 bat 
	'filemap "MAPEDIT [ %s ]" sprint bprint
	44 20 bat 
	maph mapw mapy mapx "(%d,%d) [%d:%d]" sprint bprint
	200 20 bat 
	sdly 40 - tileh / mapy +
	sdlx 40 - tilew / mapx +
	
	sdlx sdly scr2tile 1? ( c@ $ff and )
	tilenow
	"%d > [%d] (%d,%d)" sprint bprint 
	toolbar
	;
	
:editing
	gui
	0 SDLcls

	mapinscreen
	upbar
	paldraw

	SDLredraw
	teclado ;
	
:main
	"media/map" dlgSetPath
	"r3sdl" 800 600 SDLinit
	bfont1 
	| SDLfull	
	32 32 "r3\editor\mapeditor32.png" tsload 'sprgui !	
	
	'filemap "mem/mapedit.mem" load drop
	loadmap
	
	'editing SDLshow
	
	SDLquit ;	
	
: main ;