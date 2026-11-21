| bmap editor - PHREDA 2023
| map with 64bits per cell
| info|tile|tile|tile..
| RIMM version: rimmsdl + rimmwid + rimmfile
|------------------
^r3/lib/console.r3
^r3/lib/parse.r3
^r3/rimm/rimmsdl.r3
^r3/rimm/rimmwid.r3
^r3/rimm/rimmfile.r3

#clevel -1
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


#font 0
#wasp 0				| a pop-up was open in this frame
#tilesel * 1024		| buffer of the file dialog
#lsw 0 #lsh 0		| last size of the window

#tpshow 0			| tileset panel open
#tpw 0 #tph 0		| tileset panel size

#nl 0				| layer list: 0 = all, n = layer n-1

#tilewS * 16 #tilehS * 16	| text of the numeric fields
#mapwS * 16 #maphS * 16

:uiSelA | 'v -- ; while the button is held, also with the mouse outside
	uistate $f and 3 <? ( 2drop ; ) 5 >=? ( 2drop ; ) drop ex ;

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
	$1 nand? ( drop ; ) drop
	SDLRenderer 'rdes SDL_RenderFillRect 
	;
	
:allayer
	dup dlayer			| back
	dup 12 >> dlayer	| back2
	dup 24 >> dlayer	| front
	dup 36 >> dlayer	| front2
	;

:backall $888888 'tsimg tscolor allayer $ffffff 'tsimg tscolor ;

|--------------	
:mapx+! | dx --
	mapsx + mapw mapsw - 2 + clamp0max 'mapsx ! ;
:mapy+! | dy --
	mapsy + maph mapsh - 2 + clamp0max 'mapsy ! ;
:map> | x y -- adr
	mapw * + 3 << mapmem + ;

|	     up from bk2 bk
| $ffff fff f.ff fff fff	
:l0 allayer ; 
:l1 backall dup dlayer ; 
:l2 backall dup 12 >> dlayer ;
:l3 backall dup 24 >> dlayer ;
:l4 backall dup 36 >> dlayer ;
:l5 backall $7fff0000 colorA dup 48 >> bitlayer ;
:l6 backall $7f00ff00 colorA dup 49 >> bitlayer ;
:l7 backall $7f0000ff colorA dup 50 >> bitlayer ;

#viewlevel l0 l1 l2 l3 l4 l5 l6 l7

:drawtile | y x -- 
	mapsx over + -? ( drop ; ) mapw >=? ( drop ; )
	mapsy pick3 + -? ( 2drop ; ) maph >=? ( 2drop ; ) 
	map> @ 
	clevel 1+ 3 << 'viewlevel + @ ex
	drop ;

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
	$7f666666 colorA
	maph mapsy - mapth * mapy + sh min
	mapw mapsx - maptw * mapx + sw min
	mapy ( pick2 <=? 
		mapx over pick3 over line
		mapth + ) drop
	mapx ( over <=? 
		dup pick3 over mapy line
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
	|1 clevel << slevel and? ( drop ; ) drop | safe mark 
	sdlx sdly scr2view | xm ym
	2dup or -? ( 3drop ; ) drop | out of map
	clevel 
	4 =? ( drop modewall ; )	| draw wall
	5 =? ( drop modeup ; )		| draw up
	6 =? ( drop modetr ; )		| draw up
	drop
	sdlb 1 nand? ( drop erasetile ; ) drop
	0 ( th <? 
		0 ( tw <?  | xm ym h w
			puttile
			1 + ) drop
		1 + ) 3drop ;
		
:modeedit | --
	'paint uiDwn 'paint uiSel ;

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
	'select1 uiDwn 'select2 uiSelA
	$7f007f00 colorA
	tilex1 tilex2 2dup min | x1 x2 x
	mapsx - maptw * mapx + -rot - abs | x w
	tiley1 tiley2 2dup min | x w y1 y2 y
	mapsy - mapth * mapy + -rot - abs | x w y h
	rot 1 + maptw * | x y h w
	swap 1 + mapth * 
	frect ;

|------------- FILL
#last>
#rrtile

:changetile | val -- nval
	clevel 3 >? ( 12 4 * 4 - + $1 swap << or ; ) drop
	$fff clevel 12 * << nand | clear level
	tilenow $fff and clevel 12 * << or
	;
	
:maskgetile | val -- levelval | only the level
	clevel 
	3 >? ( 12 4 * 4 - + $1 swap << and ; ) 
	$fff swap 12 * << and
	;
	
:addcell | x y -- 
	2dup map> @ maskgetile rrtile <>? ( 3drop ; ) drop
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
	|1 clevel << slevel and? ( drop ; ) drop | safe mark 
	sdlx sdly scr2view | xm ym
	2dup or -? ( 3drop ; ) drop | out of map
	2dup map> @ 
	maskgetile | only the level
	dup 'rrtile ! | tile to reeplace
	dup changetile =? ( 3drop ; ) drop | only is diferent
	here 'last> !
	addcell
	here ( last> <? 
		w@+ swap w@+ rot swap markcell
		) drop ;
		
:modefill
	'filltile uiClk ;
	
|------------
#modexe 'modeedit

:overtiles? | -- flag ; the mouse is over the tileset panel
	tpshow 0? ( ; ) drop
	ts_spr 0? ( ; ) drop
	sdlx mapx <? ( drop 0 ; ) mapx tpw + >=? ( drop 0 ; ) drop
	sdly mapy <? ( drop 0 ; ) mapy tph + >=? ( drop 0 ; ) drop
	1 ;

:mapxz | -- x ; x of the map zone (out of the screen while a pop-up or the panel is over the map)
	uiPopup? 1? ( drop -10000 ; ) drop
	overtiles? 1? ( drop -10000 ; ) drop
	mapx ;

:mapzone
	mapxz mapy mapsw maptw * mapsh mapth * uiZoneBox
	modexe ex
	uiBackBox ;

:drawmapedit
	ts_spr drawmap
	drawgrid
	mapzone ;

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
	16 'tilew ! 16 'tileh ! 
	"media/img/tiles.png" 'tilefile strcpy
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
:point2ts | x y -- nts
	tileh / tilesww * swap tilew / + ;
	

:chdn
	sdlx cx - 'tilex1 !
	sdly cy - 'tiley1 !
	;

:chmv
	sdlx cx - 'tilex2 !
	sdly cy - 'tiley2 !
	tilex1 tilex2 min dup tilew / 'tx !
	tiley1 tiley2 min dup tileh / 'ty !
	point2ts
	'tilenow !
	tilex1 tilex2 - abs tilew / 1 + 'tw !
	tiley1 tiley2 - abs tileh / 1 + 'th !
	;

:chdnmv chdn chmv ;

:wintiles
	tpshow 0? ( drop ; ) drop
	ts_spr 0? ( drop ; ) drop
	mapx mapy tpw tph uiBox
	4 4 uiPad
	uiPanelBg
	cx cy ts_spr @ image
	cx cy tileimgw tileimgh uiZoneBox
	'chdnmv uiDwn 'chmv uiSel
	uiBackBox
	$7f0000ff colorA    | cursor
	cx tx tilew * + cy ty tileh * +
	tw tilew * th tileh *
	frect
	;

#bsrc 0 0
#bdst 0 0

:drawtilecursor | x y w h --
	ts_spr 0? ( drop 4drop ; ) drop
	$0 color
	pick3 pick3 pick3 pick3 frect
	swap 2swap swap 'bdst d!+ d!+ d!+ d!
	th tileh * tw tilew * ty tileh * tx tilew *
	'bsrc d!+ d!+ d!+ d!
	'bsrc 'bdst ts_spr @ imagebb | box box img --
	;

	
	
|---- config
#mapwn
#maphn
#tilewn
#tilehn

:n>buf | n 'buf --
	swap "%d" sprint swap strcpy ;

:buf>n | 'buf -- n
	str>nro nip 1 max 512 min ;

:syncbuf | -- ; numbers to the text of the fields
	tilewn 'tilewS n>buf
	tilehn 'tilehS n>buf
	mapwn 'mapwS n>buf
	maphn 'maphS n>buf ;

:tileinfo | --
	mapw 'mapwn !
	maph 'maphn !
	tilew 'tilewn !
	tileh 'tilehn !
	syncbuf
	ts_spr 0? ( drop ; )
	@ 0 0 'tileimgw 'tileimgh SDL_QueryTexture
	tileimgw tilew / 'tilesww !
	tileimgw 8 + 'tpw !
	tileimgh 8 + 'tph !
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
	0 'tilescale !    | force the new tile size
	tileinfo
	;

:applybuf | -- ; text of the fields to numbers
	'tilewS buf>n 'tilewn !
	'tilehS buf>n 'tilehn !
	'mapwS buf>n 'mapwn !
	'maphS buf>n 'maphn !
	recalc ;

:chkscale | -- ; scale of the tiles (also when the window changes size)
	sw lsw <>? ( 0 'tilescale ! ) drop
	sh lsh <>? ( 0 'tilescale ! ) drop
	sw 'lsw ! sh 'lsh !
	tilescalecalc ;

:loadall
	loadmap 0 'tilescale ! tileinfo ;

:asktile | -- ; file dialog for the tileset
	'tilefile 'tilesel strcpy
	'tilesel c@ 0? ( "r3/" 'tilesel strcpy ) drop
	'tilesel 1024 1 uiFileAsk ;

:tilefiledone | -- ; the dialog was accepted
	uiFileDone? 0? ( drop ; ) drop
	'tilesel 'tilefile strcpy
	recalc ;

|---- settings
#nlayer "** ALL **" "Back 1" "Back 2" "Front 1" "Front 2" "Wall" "Up" "Trigger" 0

:layers
	'nl 'nlayer uiRadio
	nl 1- 'clevel ! ;

#maskc


:clearlayer 
	clevel -? ( drop ; ) 
	4 <? ( $fff over 12 * << not 'maskc ! )
	3 >? ( $1 over 4 - 48 + << not 'maskc ! )
	drop
	mapmem >a
	mapw maph * ( 1? 1 -
		a@ maskc and a!+
		) drop ;
		
#wcol -46 1.0 1.0

:tilepreview
	170 uiRowH
	uiZone
	[ tpshow 1 xor 'tpshow ! ; ] uiClk
	cx cy cw rh drawtilecursor
	ui..
	0 uiRowH ;

:panelmain
	0 0 180 sh uiBox
	4 4 uiPad
	uiPanelBg
	"BMAP EDIT" uiLabelC
	layers
	"Tile Scale" 1 16 'tilescalen uiSlideriL
	2 uiCols
	'savemap "SAVE" uiBtn
	'loadall "LOAD" uiBtn
	1 uiCols
	'asktile "TILESET" uiBtn
	'wcol 3 uiColsW
	"Tile" uiLabel 'tilewS 16 uiInputLine 'tilehS 16 uiInputLine
	"Map" uiLabel 'mapwS 16 uiInputLine 'maphS 16 uiInputLine
	1 uiCols
	'applybuf "Recalc" uiBtn
	2 uiCols
	'clearlayer "Clear" uiBtn
	'resetmap "Reset" uiBtn
	1 uiCols
	th tw "%d x %d" sprint uiLabel
	tilepreview
	;

|----- MAIN
:inmap? | -- flag ; the mouse is over the map
	sdlx mapx <? ( drop 0 ; ) mapx mapsw maptw * + >=? ( drop 0 ; ) drop
	sdly mapy <? ( drop 0 ; ) mapy mapsh mapth * + >=? ( drop 0 ; ) drop
	1 ;

:keymain
	sdlkey 0? ( drop ; )
	wasp 1? ( 2drop ; ) drop        | the pop-up has the keys
	>esc< =? ( exit )
	inmap? 0? ( 2drop ; ) drop      | the rest only with the mouse over the map
	<g> =? ( mgrid 1 xor 'mgrid ! )

	<up> =? ( -1 mapy+! )
	<dn> =? ( 1 mapy+! )
	<le> =? ( -1 mapx+! )
	<ri> =? ( 1 mapx+! )

	<a> =? ( map<< )
	<d> =? ( map>> )
	<w> =? ( mapup )
	<s> =? ( mapdn )
	drop
	;

:stmode | 'mode -- ; green the button of the active mode
	modexe =? ( stSucc ) drop ;

:setedit 'modeedit 'modexe ! ;
:setrect 'moderect 'modexe ! ;
:setfill 'modefill 'modexe ! ;

:toolbar
	$ffffff txrgb
	500 0 txat sdlx sdly scr2view swap maph mapw "w:%d h:%d | x:%d y:%d" txprint
	200 0 txat 'filename "MAP: %s " txprint
	200 16 txat 'tilefile "TLS: %s " txprint

	sw 260 - 2 258 28 uiBox
	2 2 uiPad
	5 uiCols
	'modeedit stmode 'setedit "Pen" uiBtn stInfo
	'moderect stmode 'setrect "Rect" uiBtn stInfo
	'modefill stmode 'setfill "Fill" uiBtn stInfo
	[ mgrid 1 xor 'mgrid ! ; ] "Grid" uiBtn
	stDang 'exit "X" uiBtn stInfo
	1 uiCols
	;

:editor
	0 cls
	font txfont
	chkscale
	uiStart
	drawmapedit
	toolbar
	panelmain
	wintiles
	uiPopup? 'wasp !
	uiEnd
	tilefiledone
	keymain
	SDLredraw
	;

|------ MAIN
:main
	"BMAP EDIT" 1024 600 SDLinitR
	SDLblend
	"media/ttf/Roboto-Medium.ttf" 16 txload 'font !
	"png bmp jpg" uiFileFilter

	'filename "mem/bmapedit.mem" load drop
	loadmap tileinfo
	'editor SDLshow
	savemap

	SDLquit
	;

: main ;
