| demo map2 - PHREDA 2023
| map with 64bits per cell
| info|tile|tile|tile..
|------------------
^r3/win/console.r3
^r3/win/sdl2gfx.r3
^r3/util/sdlgui.r3
^r3/util/sdlfiledlg.r3

#clevel 0
#mlevel $ff
#slevel 0
#cmode 0

#filename * 1024

#mapw 32 #maph 32	| w,h map
#mapmem	0			| map adreess

#mapx 180 #mapy 32		| screen x,y pixel start
#mapsx 0 #mapsy 0	| screen x,y map start
#mapsw 30 #mapsh 16	| screen w,h 
#maptw 64 #mapth 64 | screen tile size

#ts_spr	| tileset
#tsimg	| tiles image
#tsmap	| tiles box array

|#tilew 32 #tileh 32 #tilefile "r3/itinerario/diciembre/tiles.png"
#tilew 32 #tileh 32 #tilefile * 1024

#tileimgw #tileimgh #tilesww

#tilex1 #tiley1
#tilex2 #tiley2

#tilenow 0
#tx 0 #ty 0 #tw 1 #th 1

#rec [ 0 0 0 0 ]
#rdes [ 0 0 0 0 ]

#tilescale 0
#tilescalen 8

:tilescalecalc
	tilescalen tilescale =? ( drop ; ) 
	dup 'tilescale !
	tilew over 3 *>> 'maptw !
	tileh swap 3 *>> 'mapth !
	sw maptw / 1 + 'mapsw !
	sh mapth / 1 + 'mapsh !
	;
	
|------ DRAW MAP
:dlayer | n -- 
	$fff and 0? ( drop ; )
	3 << tsmap + @ 'rec ! | texture 'ts n  r
	SDLrenderer tsimg 'rec 'rdes SDL_RenderCopy 
	;

:BITlayer
	$1 and 0? ( drop ; ) drop
	SDLRenderer 'rdes SDL_RenderFillRect 
	;
	
|--------------	
:mapx+! | dx --
	mapsx + mapw mapsw - 2 + clamp0max 'mapsx ! ;
:mapy+! | dy --
	mapsy + maph mapsh - 2 + clamp0max 'mapsy ! ;
:map> | x y -- adr
	mapw * + 3 << mapmem + ;

|	     up from bk2 bk
| $ffff fff f.ff fff fff	

:drawtile | y x -- 
	mapsx over + -? ( drop ; ) mapw >=? ( drop ; )
	mapsy pick3 + -? ( 2drop ; ) maph >=? ( 2drop ; ) 
	map> @ 
	mlevel 
	$1 and? ( over dlayer )			| back
	$2 and? ( over 12 >> dlayer ) | back2
	$4 and? ( over 24 >> dlayer ) | front
	$8 and? ( over 36 >> dlayer ) | front2
		
	$10 and? ( $7fff0000 SDLColorA over 48 >> bitlayer ) | WALL
	$20 and? ( $7f00ff00 SDLColorA over 49 >> bitlayer ) | up
	$40 and? ( $7f0000ff SDLColorA over 50 >> bitlayer ) | TRIGGER
	2drop
	;

:setxy | y x --	
	over mapth * |tileh * 
	mapy + 32 << 
	over maptw * |tilew * 
	mapx + $ffffffff and or
	'rdes ! ;
	
:drawmap | map --
	0? ( drop ; )
	@+ 'tsimg !
	@+ 'rec 8 + !
	mapth 32 << maptw or 'rdes 8 + !  | w h 
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
	mgrid 0? ( drop ; ) drop		
	$7f666666 SDLColorA
	maph mapsy - mapth * mapy + sh min
	mapw mapsx - maptw * mapx + sw min
	mapy ( pick2 <=? 
		mapx over pick3 over SDLline
		mapth + ) drop
	mapx ( over <=? 
		dup pick3 over mapy SDLLine
		maptw + ) 3drop ;

	
|----  MAP
::scr2view | xs ys -- xv yv
	mapy - maptw / mapsy + maph >=? ( -1 nip ) swap
	mapx - mapth / mapsx + mapw >=? ( -1 nip ) swap ;
		
::scr2tile | x y -- adr : only after tilemapdraw (set the vars)
	scr2view 2dup or -? ( nip nip ; ) drop
	map> ;

:tile! | --
	tilenow 
	sdlx sdly scr2tile 
	-? ( 2drop ; ) | don't set outside
	! ;

|-------------  PAINT
:puttile | xi yi h w --	xi yi h w 
	pick3 over + pick3 pick3 + map>
	pick2 ty + tilesww * pick2 tx + + 
	$fff and clevel 12 * <<
	over @ $fff clevel 12 * << nand
	or swap !
	;
	
:erasetile | x y --
	map>
	dup @ $fff clevel 12 * << nand swap ! ;
		
:modewall
	map>
	sdlb 1 and? ( drop dup @ $1000000000000 or swap ! ; ) drop
	dup @ $1000000000000 nand swap !
	;

:modeup
	map>
	sdlb 1 and? ( drop dup @ $2000000000000 or swap ! ; ) drop
	dup @ $2000000000000 nand swap !
	;

:modetr
	map>
	sdlb 1 and? ( drop dup @ $4000000000000 or swap ! ; ) drop
	dup @ $4000000000000 nand swap !
	;

:paint
	1 clevel << slevel and? ( drop ; ) drop | safe mark 
	sdlx sdly scr2view | xm ym
	2dup or -? ( 3drop ; ) drop | out of map
	clevel 4 =? ( drop modewall ; ) drop	| draw wall
	clevel 5 =? ( drop modeup ; ) drop	| draw up
	clevel 6 =? ( drop modetr ; ) drop	| draw up
	sdlb 1 nand? ( drop erasetile ; ) drop
	0 ( th <? 
		0 ( tw <?  | xm ym h w
			puttile
			1 + ) drop
		1 + ) 3drop ;
		
:modeedit | --
	|'paint dup onDnMove 
	'paint onMove 
	;

|------------- SELECT
:select1
	sdlx sdly scr2view | xm ym
	2dup or -? ( 3drop ; ) drop | out of map
	2dup 'tiley1 ! 'tilex1 !
	'tiley2 ! 'tilex2 !	;

:select2
	sdlx sdly scr2view | xm ym
	2dup or -? ( 3drop ; ) drop | out of map
	'tiley2 ! 'tilex2 ! ;

:moderect
	'select1 'select2 onDnMoveA 
	$7f007f00 SDLColorA
	tilex1 tilex2 2dup min | x1 x2 x
	mapsx - maptw * mapx + -rot - abs | x w
	tiley1 tiley2 2dup min | x w y1 y2 y
	mapsy - mapth * mapy + -rot - abs | x w y h
	rot 1 + maptw * | x y h w
	swap 1 + mapth * 
	SDLFRect ;

|------------- FILL
#last>
#rrtile

:changetile | val -- nval
	$fff clevel 12 * << nand | clear level
	tilenow $fff and clevel 12 * << or
	;

:addcell | x y -- 
	2dup map> @ rrtile <>? ( 3drop ; ) drop
	2dup swap last> w!+ w!+ 'last> !
	map> dup @ changetile swap !
	;
	
:addcellc | x y --
	swap -? ( 2drop ; ) mapw >=? ( 2drop ; )
	swap -? ( 2drop ; ) maph >=? ( 2drop ; )
	addcell ;
	
:markcell | x y --
	over 1 - over addcellc
	over 1 + over addcellc
	over over 1 - addcellc
	1 + addcellc ;
	
:filltile | --
	1 clevel << slevel and? ( drop ; ) drop | safe mark 
	sdlx sdly scr2view | xm ym
	2dup or -? ( 3drop ; ) drop | out of map
	2dup map> @ 
	dup 'rrtile ! | tile to reeplace
	dup changetile =? ( 3drop ; ) drop | only is diferent
	here 'last> !
	addcell
	here ( last> <? 
		w@+ swap w@+ rot swap markcell
		) drop ;
		
:modefill
	'filltile onClick ;
	
|------------
#modexe 'modeedit

:drawmapedit
	mapx mapy mapsw maptw * mapsh mapth * guiBox
	ts_spr drawmap
	drawgrid
	modexe ex
	;

:resetmap	
	mapmem 0 mapw maph * fill ;	

|------ SAVE/LOAD
:savemap
	mark
	"tilemap" ,s 0 ,c | 8 bytes
	mapw , maph , |warning ! is d!
	here mapmem mapw maph * move
	mapw maph * 3 << 'here +!
	tilew , tileh ,
	'tilefile ,s 0 ,c
	'filename savemem
	empty ;		

:emptymap
	32 'mapw ! 32 'maph !
	64 'tilew ! 64 'tileh ! 
	"media/img/sokoban_tilesheet.png" 'tilefile strcpy
	tilew tileh 'tilefile tsload 'ts_spr !	
	here 'mapmem !
	mapw maph * 3 << 'here +!
	resetmap	
	0 'mapsx ! 0 'mapsy !	| screen x,y map start	
	;
	
:loadmap
	mapmem 1? ( empty ) drop
	mark
	here 'filename load here =? ( drop emptymap ; ) drop | no file
	here "tilemap" = 0? ( drop emptymap ; ) drop | magic number
	here 8 + | "tilemap"0
	d@+ 'mapw ! d@+ 'maph !
	dup 'mapmem !
	mapw maph * 3 << +
	d@+ 'tilew ! d@+ 'tileh !
	dup 'here !
	'tilefile strcpy
	|... load tiles
	tilew tileh 'tilefile tsload 'ts_spr !
	0 'mapsx ! 0 'mapsy !	| screen x,y map start	
	;
	

|------ MOVE MAP
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
#wint 1 [ 0 300 512 512 ] "Tiles"

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
	curx cury ts_spr 0? ( 3drop ; ) @ SDLImage
|	sdlb sdlx sdly "%d %d %d" sprint immLabel immcr
|	
	'chdn 'chmv dup guiMap
	
	$7f0000ff sdlcolorA	| cursor
	curx tx tilew * + cury ty tileh * +
	tw tilew * th tileh * 
	SDLfRect
	;

|---- config
#mapwn 
#maphn
#tilewn
#tilehn

:tileinfo | -- 
	ts_spr 0? ( drop ; )
	@ 0 0 'tileimgw 'tileimgh SDL_QueryTexture
	tileimgw tilew / 'tilesww !
	tileimgw 4 + 'wint 16 + d!
	tileimgh 28 + 'wint 20 + d!
	mapw 'mapwn !
	maph 'maphn !
	tilew 'tilewn !
	tileh 'tilehn !
	;

|------------
:resizemap | --
	mark
	"tilemap" ,s 0 ,c | 8 bytes
	mapwn , maphn , |warning ! is d!
	
	here 0 mapwn maphn * fill | clear all

	maph maphn min
	mapw mapwn min
	0 ( pick2 <? | y
		here over mapwn * 3 << + | dest
		mapmem pick2 mapw * 3 << + | source
		pick3 move 
		1 + ) 3drop
		
	mapwn maphn * 3 << 'here +! | adv 
	tilew , tileh , 'tilefile ,s 0 ,c
	'filename savemem
	empty 
	loadmap
	tilescalecalc
	;		

:recalc
	resizemap
	tilewn 'tilew !
	tilehn 'tileh !
	mapwn 'mapw !
	maphn 'maph ! 
	tileinfo
	;

:settilefile
	fullfilename 'tilefile strcpy 
	recalc
	;

|---- settings
#winset 1 [ 0 2 180 400 ] "BMAP EDIT"

#nlayer "Back 1" "Back 2" "Front 1" "Front 2" "Wall" "Up" "Trigger"

:colbtn 
	clevel =? ( $3f00 ; ) $666666  ;
	
:icoview
	1 pick2 << mlevel and? ( 112 nip ; ) 154 nip ;
	
:icosafe
	1 pick2 << slevel and? ( 187 nip ; ) 165 nip ;
	
:layers
	'nlayer
	0 ( 7 <? 
		colbtn 'immcolorbtn !
		90 18 immbox
		[ dup 'clevel ! ; ] 
		pick2 immbtn imm>>
		20 18 immbox
		$666666 'immcolorbtn !
		[ 1 over << mlevel xor 'mlevel ! ; ] icoview immibtn imm>>
		[ 1 over << slevel xor 'slevel ! ; ] icosafe immibtn imm>>
		immln
		swap >>0 swap 1 + ) 2drop ;

		
:winmain
	'winset immwins 0? ( drop ; ) drop
	layers 

	$7f 'immcolorbtn !
	
	172 18 immbox
	1 16 'tilescalen immSlideri
	tilescalecalc
	
	" Tile Scale" immLabel immcr

	50 18 immbox
	'savemap "SAVE" immbtn imm>>
	'loadmap "LOAD" immbtn immcr
	
|	$7f 'immcolorbtn !
	160 18 immbox
	[ 'settilefile 'tilefile immfileload ; ] "TILESET" immbtn immcr	
|	'tilefile immLabel immcr
	50 18 immbox
	"Tile:" imm.
	'tilewn immInputInt imm>> ":" imm. 
	'tilehn immInputInt immcr
	"Map:" imm.
	'mapwn immInputInt imm>> ":" imm. 
	'maphn immInputInt immcr
	immcr
	60 18 immbox
	[ recalc ; ] "RECALC" immbtn imm>>
	[ resetmap ; ] "CLEAR" immbtn immcr

	;

|----- MAIN
:keymain
	SDLkey
	>esc< =? ( exit )
|	<1> =? ( 0 'clevel ! )
|	<2> =? ( 1 'clevel ! )
|	<3> =? ( 2 'clevel ! )
|	<4> =? ( 3 'clevel ! )
|	<5> =? ( 4 'clevel ! )
	
	<g> =? ( mgrid 1 xor 'mgrid ! )
	
	<up> =? ( -1 mapy+! )
	<dn> =? ( 1 mapy+! )
	<le> =? ( -1 mapx+! )
	<ri> =? ( 1 mapx+! )	
	
	<a>	=? ( map<< )
	<d> =? ( map>> )
	<w> =? ( mapup )
	<s> =? ( mapdn )	

|	<f2> =? ( 'wintiles immwin$ )
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
	500 0 ttat sdlx sdly scr2view swap maph mapw "w:%d h:%d | x:%d y:%d" ttprint
	200 0 ttat 'filename "MAP: %s " ttprint 
	200 16 ttat 'tilefile "TLS: %s " ttprint

	28 28 immbox
	990 0 immat

	$7f0000 'immcolorbtn !
	'exit 185 immibtn  imm<< | winclose
	imm<<
	$7f 'immcolorbtn !

	[ mgrid 1 xor 'mgrid ! ; ] 2 immibtn imm<<
|	'getconfig 71 immibtn imm<<	
|	[ 'winmain immwin$ ; ] 157 immibtn imm<<		
	|[ 'wintiles immwin$ ; ] 0 immibtn imm<<		
	imm<<	
	115 'modefill btnmode 
	15 'moderect btnmode 
	192 'modeedit btnmode 
	
	winmain
	wintiles
	;
	
:editor
	0 SDLcls
	immgui		| ini IMMGUI
	drawmapedit	
	toolbar
	immRedraw	| IMMGUI windows
	SDLredraw
	;

|------ MAIN
:main
	"r3sdl" 1024 600 SDLinit
	SDLblend
	"media/ttf/Roboto-Medium.ttf" 16 TTF_OpenFont immSDL
	
	'filename "mem/bmapedit.mem" load drop
|	'filename .println
|	"mem/bmapedit.mem" 'filename strcpy
	loadmap tilescalecalc 
	tileinfo
	|getconfig
	"r3/" filedlgini
	'editor SDLshow
	savemap
	
	SDLquit
	;
	
: main ;