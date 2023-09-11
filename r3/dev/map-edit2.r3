| demo map2 - PHREDA 2023
| map with 64bits per cell
| info|tile|tile|tile..
|------------------
^r3/win/console.r3
^r3/win/sdl2gfx.r3
^r3/util/sdlgui.r3
^r3/util/sdlfiledlg.r3

#ts_spr


#clevel 0
#mlevel $ff
#slevel 0
#cmode 0

#filename * 1024
#mapmem				| map adreess
#mapw 32 #maph 32	| w,h map

#mapx 0 #mapy 32		| screen x,y pixel start
#mapsx 0 #mapsy 0	| screen x,y map start
#mapsw 30 #mapsh 16	| screen w,h 

#xm #ym		

|#tilew 24 #tileh 24 #tilefile "media/img/classroom.png"
#tilew 32 #tileh 32 #tilefile "r3/itinerario/diciembre/tiles.png"

#tileimgw #tileimgh #tilesww

#tilex1 #tiley1
#tilex2 #tiley2

#tilenow 11
#tx 0 #ty 0 #tw 1 #th 1

#rec [ 0 0 0 0 ]
#rdes [ 0 0 0 0 ]

|------ DRAW MAP

#tsimg
#tsmap

:dlayer | n -- 
	$fff and 0? ( drop ; )
	3 << tsmap + @ 'rec ! | texture 'ts n  r
	SDLrenderer tsimg 'rec 'rdes SDL_RenderCopy 
	;

:BITlayer
	$fff and 0? ( drop ; )
	drop
	$7fff0000 SDLColorA
	SDLRenderer 'rdes SDL_RenderFillRect 
	;
	
|--------------	

:mapx+! | dx --
	mapsx + mapw mapsw - clamp0max 'mapsx ! ;
:mapy+! | dy --
	mapsy + maph mapsh - clamp0max 'mapsy ! ;
:map> | x y -- adr
	mapw * + 3 << mapmem + ;

|	     up from bk2 bk
| $ffff fff f.ff fff fff	

:drawtile | y x -- 
	mapsx over + -? ( drop ; ) mapw >=? ( drop ; )
	mapsy pick3 + -? ( 2drop ; ) maph >=? ( 2drop ; ) 
	map> @ 
	mlevel 
	$1 and? ( over dlayer )	| background
	$2 and? ( over 12 >> dlayer ) | background2
	$4 and? ( over 24 >> dlayer ) | From
	$8 and? ( over 36 >> dlayer ) | Up
		
	$10 and? ( over 48 >> bitlayer ) | WALL
|	$20 and? ( over 36 >> dlayer ) | TRIGGER
	2drop
	;

:setxy | y x --	
	over tileh * mapy + 32 << 
	over tilew * mapx + $ffffffff and or
	'rdes ! ;
	
:drawmap | map --
	@+ 'tsimg !
	@+ dup 'rdes 8 + ! 'rec 8 + ! | w h 
	'tsmap !
	0 ( mapsh <? 
		0 ( mapsw <?
			setxy 
			drawtile 
			1 + ) drop
		1 + ) drop ;

|-----	
#mgrid 1

:drawgrid
	$666666 SDLColor
	mgrid 0? ( drop ; ) drop		
	0 ( mapsh <=? 
		mapx 
		over tileh * mapy +
		mapsw tilew * pick2 + 
		over 
		SDLLine
		1 + ) drop 
	0 ( mapsw <=?
		dup tilew * mapx + 
		mapy 
		over 
		mapsh tileh * pick2 + 
		SDLLine
		1 + ) drop ;

	
|----  MAP
::scr2view | xs ys -- xv yv
	mapy - tilew / mapsy + maph >=? ( -1 nip ) swap
	mapx - tileh / mapsx + mapw >=? ( -1 nip ) swap ;
		
::scr2tile | x y -- adr : only after tilemapdraw (set the vars)
	scr2view 2dup or -? ( nip nip ; ) drop
	map> ;

|-------------	
:tile! | --
	tilenow 
	sdlx sdly scr2tile 
	-? ( 2drop ; ) | don't set outside
	! ;
	
:puttile | xi yi h w --	xi yi h w 
	pick3 over + pick3 pick3 + map>
	pick2 ty + tilesww * pick2 tx + + 
	$fff and clevel 12 * <<
	over @ $fff clevel 12 * << not and
	or swap !
	;
	
:erasetile | x y --
	map>
	dup @ $fff clevel 12 * << not and swap ! ;
		

|-------------	
:modewall
	map>
	sdlb 1 and? ( drop dup @ $1000000000000 or swap ! ; ) drop
	dup @ $1000000000000 not and swap !
	;
		
:modeedit | --
	sdlx sdly scr2view | xm ym
	2dup or -? ( 3drop ; ) drop | out of map
	clevel 4 =? ( drop modewall ; ) drop
	sdlb 1 nand? ( drop erasetile ; ) drop
	0 ( th <? 
		0 ( tw <?  | xm ym h w
			puttile
			1 + ) drop
		1 + ) 3drop ;
	

|-------------
:moderect
	sdlx sdly scr2view | xm ym
	2dup or -? ( 3drop ; ) drop | out of map
	'tiley1 ! 'tilex1 !
	|'tiley2 ! 'tiley2 ! 
	;

|-------------
:modefill
	;
	
|------------
#modexe 'modeedit
#modexem 'modeedit

:drawmapedit
	mapx mapy mapsw tilew * mapsh tileh * guiBox
	modexe dup onDnMove
	ts_spr drawmap
	drawgrid
	;

|------------

:resizemap | w h --
	'maph ! 'mapw !
	mapmem 1? ( empty ) drop
	mark
	maph mapw here d!+ d!+ 
	dup 'mapmem !
	maph mapw * 3 << + 
	'here ! 
	;

:resetmap	
	mapmem >a 
	0 ( maph <? 
		0 ( mapw <?
			0 a!+
			1 + ) drop
		1 + ) drop ;
	
:loadmap
	here dup 'filename load | inimem endmem
	over =? ( 2drop ; ) drop
	d@+ swap d@+ rot swap resizemap
	mapmem swap maph mapw * 3 << move
	;
	
:savemap
	mapmem 8 - mapw maph * 1 + 3 << 'filename save
	;		

:mapup
	mapmem >a
	here a> mapw move | d s c
	a> dup mapw 3 << + maph 1 - mapw * move
	a> maph 1 - mapw * 3 << + here mapw move
	;
	
:mapdn
	mapmem >a
	here a> maph 1 - mapw * 3 << + mapw move
	a> dup mapw 3 << + swap maph 1 - mapw * move>	
	a> here mapw move | d s c
	;
	
:map<<
	mapmem dup >a @
	a> dup 8 + mapw maph * 1 - move
	a> mapw maph * 1 - 3 << + >b
	maph ( 1? 1 -
		b> mapw 3 << - @ b! 
		mapw 3 << neg b+
		) drop
	a> mapw 1 - 3 << + ! ;
	
:map>>
	mapmem >a
	a> mapw maph * 1 - 3 << + @
	a> dup 8 + swap mapw maph * 1 - move>
	a> >b
	maph ( 1 - 1? 
		b> mapw 3 << + @ b! 
		mapw 3 << b+
		) drop
	b! ;

|---- tileset
#wint 1 [ 0 32 512 512 ] "Tiles"

:point2ts | x y -- nts
	tileh / tilesww * swap tilew / + ;
	
:chdn
	sdlx curx - 'tilex1 ! 
	sdly cury - 'tiley1 !
	;
	
:chmv
	sdlx curx - 'tilex2 !
	sdly cury - 'tiley2 !
	
	tilex1 tilex2 min dup tilew / 'tx !
	tiley1 tiley2 min dup tileh / 'ty !
	point2ts 
	'tilenow !
	tilex1 tilex2 - abs tilew / 1 + 'tw !
	tiley1 tiley2 - abs tileh / 1 + 'th !
	;
	
:wintiles
	'wint immwin 0? ( drop ; ) drop
	curx cury ts_spr @ SDLImage
|	sdlb sdlx sdly "%d %d %d" sprint immLabel immcr
|	
	'chdn 'chmv dup guiMap
	
	$ffffff sdlcolor	| cursor
	curx tx tilew * + cury ty tileh * +
	tw tilew * th tileh * 
	SDLRect
	;

:tileinfo
	ts_spr @ 0 0 'tileimgw 'tileimgh SDL_QueryTexture
	tileimgw tilew / 'tilesww !
	tileimgw 4 + 'wint 16 + d!
	tileimgh 28 + 'wint 20 + d!
	;

|---- config
#wincon 1 [ 824 300 200 200 ] "CONFIG"
#mapwn 
#maphn

:setconfig

	;
	
:winconfig
	'wincon immwin 0? ( drop ; ) drop
	'setconfig  "OK" immbtn imm>>
	[ mapwn maphn resizemap resetmap ; ] "CLEAR" immbtn immcr
	
|	'filename immlabel immcr
|	'tilefile immlabel immcr
	190 20 immbox
	4 254 'mapwn immSlideri immcr
	4 254 'maphn immSlideri immcr
	
	;

:getconfig
	mapw 'mapwn !
	maph 'maphn !
	'winconfig immwin$
	;
	
|---- settings
#winset 1 [ 834 32 190 300 ] "LAYERS"

#nlayer "Back 1" "Back 2" "Front" "Up" "Wall" "Trigger"

:colbtn 
	clevel =? ( $3f00 ; ) $666666  ;
	
:icoview
	1 pick2 << mlevel and? ( 112 nip ; ) 154 nip ;
	
:icosafe
	1 pick2 << slevel and? ( 187 nip ; ) 165 nip ;
	
:layers
	'nlayer
	0 ( 5 <? 
		colbtn 'immcolorbtn !
		120 18 immbox
		[ dup 'clevel ! ; ] 
		pick2 immbtn imm>>
		25 18 immbox
		$666666 'immcolorbtn !
		[ 1 over << mlevel xor 'mlevel ! ; ] icoview immibtn imm>>
		[ 1 over << slevel xor 'slevel ! ; ] icosafe immibtn imm>>
		immln
		swap >>0 swap 1 + ) 2drop ;

		
:winmain
	'winset immwin 0? ( drop ; ) drop
	layers immln
	
	$7f 'immcolorbtn !
	89 18 immbox
	'savemap "SAVE" immbtn imm>>
	'loadmap "LOAD" immbtn immcr
	
|	'filename immLabel immcr
|	maph mapw mapsy mapsx "%d %d %d %d" sprint immLabel
|	tilenow "%d" sprint immLabel	
	;
	
	

|----- MAIN
:keymain
	SDLkey
	>esc< =? ( exit )
	<1> =? ( 0 'clevel ! )
	<2> =? ( 1 'clevel ! )
	<3> =? ( 2 'clevel ! )
	<4> =? ( 3 'clevel ! )
	<5> =? ( 4 'clevel ! )
	
	<t> =? ( wint 1 xor 'wint ! )
	<g> =? ( mgrid 1 xor 'mgrid ! )
	<up> =? ( -1 mapy+! )
	<dn> =? ( 1 mapy+! )
	<le> =? ( -1 mapx+! )
	<ri> =? ( 1 mapx+! )	
	<a>	=? ( map<< )
	<d> =? ( map>> )
	<w> =? ( mapup )
	<s> =? ( mapdn )	
	
	<f1> =? ( 'winmain immwin$ )
	<f2> =? ( 'wintiles immwin$ )
	<f3> =? ( 'winconfig immwin$ )
	drop
	;
	
:colorbtn | n -- c
	=? ( $7f00 ; ) $7f ;
	
:btnmode | nro adr --
	modexe colorbtn 'immcolorbtn !	
	[ dup 'modexe ! ; ] rot immibtn imm<< 
	drop ;
	
:toolbar	
	'keymain immkey!
	$ffffff ttcolor
	0 16 ttat sdlx sdly scr2view swap maph mapw "w:%d h:%d | x:%d y:%d" ttprint
	0 0 ttat 'tilefile 'filename "MAP [ %s ] TILESET [ %s ]" ttprint

	28 28 immbox
	990 0 immat

	$7f0000 'immcolorbtn !
	'exit 185 immibtn  imm<< | winclose
	imm<<
	$7f 'immcolorbtn !

	[ mgrid 1 xor 'mgrid ! ; ] 2 immibtn imm<<
	'getconfig 71 immibtn imm<<	
	[ 'winmain immwin$ ; ] 157 immibtn imm<<		
	[ 'wintiles immwin$ ; ] 0 immibtn imm<<		
	imm<<	
	115 'modefill btnmode 
	15 'moderect btnmode 
	192 'modeedit btnmode 
	;
		
:editor
	0 SDLcls
	immgui		| ini IMMGUI	
	toolbar
	drawmapedit
	immRedraw
	SDLredraw
	;

:main
	"r3sdl" 1024 600 SDLinit
	SDLblend
	"media/ttf/Roboto-Medium.ttf" 14 TTF_OpenFont immSDL
	
	tilew tileh 'tilefile tsload 'ts_spr !
	tileinfo
	
	32 32 resizemap resetmap
	
	"mem/mapedit2.mem" 'filename strcpy
	loadmap
	
	"r3" filedlgini
	'winmain immwin!
	
	'editor SDLshow
	savemap
	
	SDLquit
	;
	
: main ;