| demo map2 - PHREDA 2023
| map with 64bits per cell
| info|tile|tile|tile..
|------------------
^r3/win/console.r3
^r3/win/sdl2gfx.r3
^r3/util/sdlgui.r3


#ts_spr

#mgrid 1
#mapx 0 #mapy 0		| screen ini
#clevel 0
#cmode 0

#filename * 1024
#mapmem				| map adreess
#mapw 32 #maph 32	| w,h map

#tilew 24 #tileh 24
#tilefile "media/img/classroom.png"

#tileimgw #tileimgh #tilesww

#tilex1 #tiley1
#tilex2 #tiley2

#tilenow 11
#tx 0 #ty 0 #tw 1 #th 1

#rec [ 0 0 0 0 ]
#rdes [ 0 0 0 0 ]

|------ DRAW MAP
:]map | x y -- t
	mapw * + 3 << 'maph + ;

:setto | y x --
	'rdes d!+ d! ;
	
:drawtile | n map -- 
	@+ swap		| n texture 'ts 
	8 + rot 	| texture 'ts n 
	2dup $fff and 3 << + @ 'rec ! | texture 'ts n  r
	SDLrenderer pick3 'rec 'rdes SDL_RenderCopy | background
	2dup 12 >> $fff and 3 << + @ 'rec !
	SDLrenderer pick3 'rec 'rdes SDL_RenderCopy | background2
	2dup 24 >> $fff and 3 << + @ 'rec !
	SDLrenderer pick3 'rec 'rdes SDL_RenderCopy | From
	2dup 36 >> $fff and 3 << + @ 'rec !
	SDLrenderer pick3 'rec 'rdes SDL_RenderCopy | Up
	3drop
	;

:drawmap | map --
	dup 8 + @ 
	dup 'rdes 8 + ! 'rec 8 + ! | w h 
	mapmem
	0 ( maph <? 
		0 ( mapw <?
			over tileh * mapy + 
			over tilew * mapx + 
			setto | y x
			rot @+ pick4 
			drawtile 
			rot rot 1 + ) drop
		1 + ) 3drop ;

:grid
	$666666 SDLColor
	0 ( maph <=? 
		mapx 
		over tileh * mapy +
		mapw tilew * mapx + 
		over 
		SDLLine
		1 + ) drop 
	0 ( mapw <=?
		dup tilew * mapx + 
		mapy 
		over 
		maph tileh * mapy + 
		SDLLine
		1 + ) drop ;

	
|----  MAP
::scr2view | xs ys -- xv yv
	mapy - tilew / maph >=? ( -1 nip ) swap
	mapx - tileh / mapw >=? ( -1 nip ) swap ;
		
::scr2tile | x y -- adr : only after tilemapdraw (set the vars)
	scr2view 2dup or -? ( nip nip ; ) drop
::tile2map | xm ym -- adr	
	mapw * + 3 << mapmem + ;
	
:tile! | --
	tilenow 
	sdlx sdly scr2tile 
	-? ( 2drop ; ) | don't set outside
	! ;
	
:puttile | xi yi h w --	xi yi h w 
	pick3 over + pick3 pick3 + tile2map
	pick2 ty + tilesww * pick2 tx + + 
	$fff and clevel 12 * <<
	over @ $fff clevel 12 * << not and
	or swap !
	;
	
:tilebox! | --
	sdlx sdly scr2view | xm ym
	 2dup or -? ( 3drop ; ) drop | out of map
	0 ( th <? 
		0 ( tw <?  | xm ym h w
			puttile
			1 + ) drop
		1 + ) 3drop ;
	
:mdraw
|	'tile! dup onDnMove ;	
	'tilebox! dup onDnMove ;	


:drawmapedit
|	'pendn 'penmv 'pencopy guiMap
	mdraw
	ts_spr drawmap	
	mgrid 1? ( grid ) drop	
	;

|------------
:resizemap | w h --
	'maph ! 'mapw !
	mapmem 1? ( empty ) drop
	mark
	here 
	8 + dup 'mapmem !
	maph mapw * 3 << + 'here ! 
	mapw maph 32 << or mapmem 8 - !
	;
	
:resetmap	
	mapmem >a 
	0 ( maph <? 
		0 ( mapw <?
			0 a!+
			1 + ) drop
		1 + ) drop ;
		
:loadmap
	$ffff here + 'filename load drop
	here $ffff +
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
#wint 1 [ 0 400 512 512 ] "Tiles"

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
|	sdlb sdlx sdly "%d %d %d" sprint immLabel
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

:winconfig
	'wincon immwin 0? ( drop ; ) drop
	'filename immlabel immdn
	'tilefile immlabel immdn
	190 20 immbox
	4 254 'mapw immSlideri immdn
	4 254 'maph immSlideri immdn
	;

|---- settings
#winset 1 [ 824 0 200 300 ] "TILEMAP"

:winsetings
	'winset immwin 0? ( drop ; ) drop
	 [ wincon 1 xor 'wincon ! ; ] "CONFIG" immbtn imm>>
	|'loadmap "GRID" immbtn 
	imm<< immdn
	
	'savemap "SAVE" immbtn imm>>
	'loadmap "LOAD" immbtn imm<< immdn

	130 20 immbox
	'clevel "Background|Background2|Front|Up|Wall|Trigger" immRadio  immdn
|	'cmode "Write|Erase" immCombo  immdn
	
	28 24 immbox
|	'exit 11 immibtn imm>> | winclose
	
	'exit 192 immibtn imm>> | pencil edit
	'exit 115 immibtn imm>> | fill bucket
	
|	[ winl 1 xor 'winl ! ; ] 116 immibtn imm>> | 
	[ wint 1 xor 'wint ! ; ] 2 immibtn imm>>
	[ mgrid 1 xor 'mgrid ! ; ] 2 immibtn imm>>
	
|	tilenow "%d" sprint immLabel	
	;
	


|----- MAIN
:editor
	0 SDLcls
	immgui		| ini IMMGUI	

	drawmapedit
	
	wintiles	
	winsetings
	winconfig
	
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	<g> =? ( mgrid 1 xor 'mgrid ! )
	
	<a>	=? ( map<< )
	<d> =? ( map>> )
	<w> =? ( mapup )
	<s> =? ( mapdn )	
	drop
	;

:main
	"r3sdl" 1024 600 SDLinit
	"media/ttf/Roboto-Medium.ttf" 12 TTF_OpenFont immSDL
	
	tilew tileh 'tilefile tsload 'ts_spr !
	tileinfo
	
|	16 16 resizemap resetmap
	"mem/mapedit2.mem" 'filename strcpy
	loadmap
	
	'editor SDLshow
	savemap
	
	SDLquit
	;
	
: main ;