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
#cmode 0

#filename * 1024
#mapmem				| map adreess
#mapw 32 #maph 32	| w,h map

#mapx 0 #mapy 0		| screen x,y pixel start
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
		
:tilebox! | --
	sdlx sdly scr2view | xm ym
	2dup or -? ( 3drop ; ) drop | out of map
	sdlb 1 nand? ( drop erasetile ; ) drop
	0 ( th <? 
		0 ( tw <?  | xm ym h w
			puttile
			1 + ) drop
		1 + ) 3drop ;
	
|-------------	
:tilewall!	
	sdlx sdly scr2view | xm ym
	2dup or -? ( 3drop ; ) drop | out of map
	map>
	sdlb 1 and? ( drop dup @ $1000000000000 or swap ! ; ) drop
	dup @ $1000000000000 not and swap !
	;

#exeondnmv 'tilebox!

:drawmapedit
	exeondnmv dup onDnMove
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
#wint 1 [ 0 0 512 512 ] "Tiles"

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
#wincon 0 [ 824 300 200 200 ] "CONFIG"
#mapwn 
#maphn

:getconfig
	mapw 'mapwn !
	maph 'maphn !
	wincon 1 xor 'wincon ! 
	;

:setconfig
	wincon 1 xor 'wincon ! 
	;
	
:winconfig
	'wincon immwin 0? ( drop ; ) drop
	[ wincon 1 xor 'wincon ! ; ] "CANCEL" immbtn imm>>
	'setconfig  "OK" immbtn immcr
	[ mapwn maphn resizemap resetmap ; ] "CLEAR" immbtn immcr
	
	'filename immlabel immcr
	'tilefile immlabel immcr
	190 20 immbox
	4 254 'mapwn immSlideri immcr
	4 254 'maphn immSlideri immcr
	
	;

	
|---- settings
#winset 1 [ 824 0 200 300 ] "TILEMAP"

#nlayer "Background" "Background2" "Front" "Up" "Wall" "Trigger"

:clevel!
	4 <? ( 'tilebox! 'exeondnmv ! )
	4 =? ( 'tilewall! 'exeondnmv ! )
	'clevel ! ;

:colbtn 
	clevel =? ( $3f00 'immcolorbtn ! ; ) 
	$666666 'immcolorbtn ! ;
	
:icoview
	1 pick2 << mlevel and? ( 112 nip ; ) 
	154 nip ;
	
:layers
	'nlayer
	0 ( 5 <? 
		colbtn
		150 18 immbox
		[ dup clevel! ; ] 
		pick2 immbtn imm>>
		26 18 immbox
		$666666 'immcolorbtn !
		[ 1 over << mlevel xor 'mlevel ! ; ] 
		icoview immibtn
		immln
		swap >>0 swap 1 + ) 2drop ;

		
:winsetings
	'winset immwin 0? ( drop ; ) drop
	$7f 'immcolorbtn !
	28 24 immbox
	'exit 192 immibtn imm>> | pencil edit
	'exit 115 immibtn imm>> | fill bucket
	'getconfig 71 immibtn imm>>
	[ wint 1 xor 'wint ! ; ] 0 immibtn imm>>
	[ mgrid 1 xor 'mgrid ! ; ] 2 immibtn imm>>
	$7f0000 'immcolorbtn !
	'exit 185 immibtn  | winclose
	immcr
	$7f 'immcolorbtn !
	94 18 immbox
	'savemap "SAVE" immbtn imm>>
	'loadmap "LOAD" immbtn immcr
	layers
	'filename immLabel immcr
|	maph mapw mapsy mapsx "%d %d %d %d" sprint immLabel
|	tilenow "%d" sprint immLabel	
	;
	
	

|----- MAIN
:keymain
	SDLkey
	>esc< =? ( exit )
	<1> =? ( 0 clevel! )
	<2> =? ( 1 clevel! )
	<3> =? ( 2 clevel! )
	<4> =? ( 3 clevel! )
	<5> =? ( 4 clevel! )
	
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
	drop
	;
	
:editor
	0 SDLcls
	immgui		| ini IMMGUI	
	'keymain immkey!

	drawmapedit
	
	wintiles	
	winsetings
	winconfig
	
	|filedlg
	
	immRedraw
	SDLredraw
	;

:main
	"r3sdl" 1024 600 SDLinit
	SDLblend
	"media/ttf/Roboto-Medium.ttf" 12 TTF_OpenFont immSDL
	
	tilew tileh 'tilefile tsload 'ts_spr !
	tileinfo
	
	32 32 resizemap resetmap
	
	"mem/mapedit2.mem" 'filename strcpy
	loadmap
	
	"r3" filedlgini
	
	'editor SDLshow
	savemap
	
	SDLquit
	;
	
: main ;