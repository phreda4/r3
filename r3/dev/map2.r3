| demo map2
| PHREDA 2021
|------------------

^r3/win/console.r3
^r3/win/sdl2gfx.r3

#ts_spr

#wmap 32
#hmap 32

#map 
$10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 
$10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 
$10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 
$10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 
$10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 
$10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 
$10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 
$10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 
$10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 
$10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 
$10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 
$10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 
$10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 
$10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 
$10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 
$10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 $10 

|------ DRAW MAP

:gettilea | x y -- t
	32 * + 'map + ;

:gettile | x y -- t
	32 * + 'map + c@ ;

:drawtile | x y adr tile -- y x adr  
	ts_spr 
	pick4 4 << pick4 4 << swap
	tsdraw ;

#rec [ 0 0 0 0 ]
#rdes [ 0 0 0 0 ]

:setto | x y --
	swap 'rdes d!+ d! ;
:setfr | x y --
	swap 'rec d!+ d! ;
	
:tsdraw | n 'ts x y --
	
	dup 8 + @ dup 'rdes 8 + ! 'rec 8 + !
	SDLrenderer 	| n 'ts ren
	rot rot @+		| ren n 'ts texture
	rot 3 << rot 8 + + 
	@ 'rec ! | ren txture rsrc
	'rec 'rdes 
	SDL_RenderCopy
	;
	
:drawtile | n -- 

	SDLrenderer ts_spr 'rec 'rdes SDL_RenderCopy ;
	
:drawmap
	'map 
	0 ( 16 <? 
		0 ( 16 <?
			over 4 << over 4 << setto
			rot @+ drawtile rot rot 
			1 + ) drop
		1 + ) 2drop ;

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
	
	drawmap

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