| demo map2 - PHREDA 2023
| map with 64bits per cell
| info|tile|tile|tile..
|------------------
^r3/win/console.r3
^r3/win/sdl2gfx.r3
^r3/util/sdlgui.r3

#modod

#ts_spr

#map * $fffff
#mapx 32 #mapy 32
#mapw 32 #maph 32

#tilew 24 #tileh 24
#tilefile "media/img/classroom.png"
#tileimgw #tileimgh #tilesww

#tilex1 #tiley1
#tilex2 #tiley2
#tilenow 11
#tw 1 #th 1
#tx 0 #ty 0
#rec [ 0 0 0 0 ]
#rdes [ 0 0 0 0 ]

|------ DRAW MAP
:]map | x y -- t
	mapw * + 3 << 'maph + ;

:setto | y x --
	'rdes d!+ d! ;
	
:drawtile | n map -- 
	@+ swap		| n texture 'ts 
	8 + rot 

	3 << + @ 'rec !
	SDLrenderer swap 'rec 'rdes SDL_RenderCopy 
	;

:drawmap | map --
	dup 8 + @ 
	dup 'rdes 8 + ! 'rec 8 + ! | w h 
	'map 
	0 ( maph <? 
		0 ( mapw <?
			over tileh * mapy + 
			over tilew * mapx + 
			setto | y x
			rot @+ pick4 drawtile rot rot 
			1 + ) drop
		1 + ) 3drop ;


|---- MODO
:wintools
|	'win1 immwin 0? ( drop ; ) drop
	0 0 immat
	28 24 immbox
	'exit 11 immibtn imm>> | winclose
	
	'exit 192 immibtn imm>> | pencil edit
	'exit 115 immibtn imm>> | fill bucket
	
	'exit 116 immibtn imm>> | 
	
	'exit 2 immibtn imm>>
	
	tilenow "%d" sprint immLabel

	;

|---- tileset
#wint 1 [ 32 32 512 512 ] "Tiles"

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
	
|------------------------ MAP
::scr2view | xs ys -- xv yv
	mapy - tilew / 
	maph >=? ( -1 nip )
	swap
	mapx - tileh / 
	mapw >=? ( -1 nip ) 
	swap ;
		
::scr2tile | x y -- adr : only after tilemapdraw (set the vars)
	scr2view 2dup or -? ( nip nip ; ) drop
::tile2map | xm ym -- adr	
	mapw * + 3 << 'map + ;
	
:tile! | --
	tilenow 
	sdlx sdly scr2tile 
	-? ( 2drop ; ) | don't set outside
	! ;
	
:puttile | xi yi h w --	xi yi h w 
	pick3 over + 
	pick3 pick3 +
	tile2map
	;
	
:tilebox! | --
	sdlx sdly scr2view | xm ym
	 2dup or -? ( 3drop ; ) drop | out of map
	0 ( tileh <? 
		0 ( tilew <?  | xm ym h w
			|puttile
			1 + ) drop
		1 + ) 3drop ;
	
:mdraw
	'tile! dup onDnMove ;	

:drawmapedit
|	'pendn 'penmv 'pencopy guiMap
	mdraw
	ts_spr drawmap	
	;

|------------
:resetmap
	'map >a
	0 ( maph <? 
		0 ( mapw <?
			|2dup swap mapw * + 
			0 a!+
			1 + ) drop
		1 + ) drop 
	;
	
|----- MAIN
:editor
	0 SDLcls
	immgui		| ini IMMGUI	

	drawmapedit
	wintiles	
	wintools
	
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	drop
	;

:main
	"r3sdl" 800 600 SDLinit
	"media/ttf/Roboto-Medium.ttf" 14 TTF_OpenFont immSDL
	tilew tileh 'tilefile tsload 'ts_spr !
	tileinfo
	resetmap
	'editor SDLshow
	
	SDLquit
	;
	
: main ;