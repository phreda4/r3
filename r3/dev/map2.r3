| demo map2 - PHREDA 2023
| map with 64bits per cell
| info|tile|tile|tile..
|------------------
^r3/win/console.r3
^r3/win/sdl2gfx.r3

#ts_spr

#wmap 32
#hmap 32

#map * $ffff

|------ DRAW MAP

:]map | x y -- t
	wmap 3 << * + 'map + ;

#rec [ 0 0 0 0 ]
#rdes [ 0 0 0 0 ]

:setto | x y --
	swap 'rdes d!+ d! ;
	
:drawtile | n map -- 
	@+ swap		| n texture 'ts 
	8 + rot 
	
	3 << + @ 'rec !
	SDLrenderer swap 'rec 'rdes SDL_RenderCopy 
	;
	
:drawmap | map 
	dup 8 + @ 
	dup 'rdes 8 + ! 'rec 8 + ! | w h 
	'map 
	0 ( 16 <? 
		0 ( 16 <?
			over 4 << over 4 << setto
			rot @+ pick4 drawtile rot rot 
			1 + ) drop
		1 + ) 3drop ;

:setmapall
	'map >a
	0 ( 16 <? 
		0 ( 16 <?
			2dup 16 * + a!+
			1 + ) drop
		1 + ) 2drop ;


|----- MAIN
:demo
	0 SDLcls
	ts_spr drawmap
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	drop
	;

:main
	"r3sdl" 800 600 SDLinit

	16 16 "media/img/First Asset pack.png" tsload 'ts_spr !
	setmapall
	'demo SDLshow
	
	SDLquit
	;
	
: main ;