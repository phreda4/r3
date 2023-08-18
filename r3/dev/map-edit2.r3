| demo map2 - PHREDA 2023
| map with 64bits per cell
| info|tile|tile|tile..
|------------------
^r3/win/console.r3
^r3/win/sdl2gfx.r3
^r3/util/sdlgui.r3

#modod

#ts_spr

#tilenow 11

#map * $fffff
#mapx 32 #mapy 32
#mapw 32 #maph 32

#tilew 24 #tileh 24
#tilefile "media/img/classroom.png"

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
	;

#win2 1 [ 600 0 200 512 ] "Tiles"

:chtile
	sdlx curx - 
	sdly cury - 
	ts_spr
	point2ts 
	'tilenow !
	;
	
:wintiles
	'win2 immwin 0? ( drop ; ) drop
	curx cury ts_spr @ SDLImage
|	sdlb sdlx sdly "%d %d %d" sprint immLabel
	tilenow "%d" sprint immLabel
	'chtile 'chtile 'chtile guiMap
	curx cury tilenow ts_spr ts2rec
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
	mapw * + 3 << 'map + ;
	
:tile! | --
	tilenow 
	sdlx sdly scr2tile 
	-? ( 2drop ; ) | don't set outside
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
		
			|2dup swap mapw * + 
			0 a!+
			
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
	"media/ttf/Roboto-Medium.ttf" 14 TTF_OpenFont immSDL
	
|	32 32 "media/img/rpg2.png" tsload 'ts_spr !
	tilew tileh 'tilefile tsload 'ts_spr !
	resetmap
	
	'demo SDLshow
	
	SDLquit
	;
	
: main ;