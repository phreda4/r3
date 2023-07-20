| demo map2 - PHREDA 2023
| map with 64bits per cell
| info|tile|tile|tile..
|------------------
^r3/win/console.r3
^r3/win/sdl2gfx.r3
^r3/util/sdlgui.r3

#modod

#ts_spr
#tilenow 16

#map * $fffff
#mapx 0 #mapy 0
#mapw 32 #maph 32
#tilew 16 #tileh 16

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
			over 4 << mapy +
			over 4 << mapx + 
			setto | y x
			rot @+ pick4 drawtile rot rot 
			1 + ) drop
		1 + ) 3drop ;


|---- MODO
#win1 1 [ 532 0 64 128 ] "Tools"

:wintools
	'win1 immwin 0? ( drop ; ) drop

	'exit 11 immibtn imm<<dn | winclose
	
	'exit 192 immibtn imm<<dn | pencil edit
	'exit 115 immibtn imm<<dn | fill bucket
	
	'exit 2 immibtn imm<<dn
	
	;

#win2 1 [ 600 0 200 512 ] "Tiles"

:wintiles
	'win2 immwin 0? ( drop ; ) drop
	curx cury ts_spr @ SDLImage
	;

|------------------------ MAP
#xm #ym

::scr2view | xs ys -- xv yv
	ym - tilew / mapy +
	maph >=? ( -1 nip )
	swap
	xm - tileh / mapx +
	mapw >=? ( -1 nip ) 
	swap ;
		
::scr2tile | x y -- adr : only after tilemapdraw (set the vars)
	scr2view 2dup or -? ( nip nip ; ) drop
	mapw * + 3 << 'map + ;
	
:tile! | --
	tilenow 
	sdlx sdly scr2tile 
	-? ( 2drop ; ) 
	! ;
	
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
		
			2dup swap mapw * + a!+
			
			1 + ) drop
		1 + ) drop 
		
	ts_spr @ SDLimagewh
	16 + | title in window
	swap 'win2 16 + d!+ d!
	;
	
|----- MAIN
:demo
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
	"media/ttf/Roboto-Medium.ttf" 14 immSDL
	
	16 16 "media/img/First Asset pack.png" tsload 'ts_spr !
	resetmap
	
	'demo SDLshow
	
	SDLquit
	;
	
: main ;