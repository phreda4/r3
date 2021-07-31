 | About timeline
| framerate independient event animation system
| PHREDA 2020
|------------------
|MEM $fff
^r3/win/console.r3
^r3/win/sdl2.r3
^r3/win/sdl2ttf.r3
^r3/win/sdl2image.r3	

^r3/lib/mem.r3
^r3/lib/key.r3
^r3/util/timeline.r3

#imagen | an imge


|-------------------- asorted animations
:example1 | --
	timeline.clear

	|........................
	0.1 0.1 0.8 0.8 xywh%64
	$ff00 +box
	
	0.5 +fx.on

	0.1 0.1 0.8 0.8 xywh%64
	0.4 0.2 0.2 0.6 xywh%64
	'Ela_InOut 3.0
	2.0 +fx.box

	0.4 0.2 0.2 0.6 xywh%64
	0.1 0.1 0.8 0.8 xywh%64
	'Ela_InOut 3.0
	6.0 +fx.box
	
|	$ff00 $0000ff 'Ela_InOut 7.0 2.0 +fx.color
	
	9.5 +fx.off
	
	|........................
	0.2 0.2 0.3 0.4 xywh%64
	$ff +box
	
	0.0 +fx.on
	
	0.2 0.2 0.3 0.4 xywh%64
	1.2 0.4 0.3 0.4 xywh%64	
	'Quad_In 4.0
	1.0 +fx.box
	
	|........................
	|imagen
	0.1 0.3 0.5 0.5 xywh%64
	|+img
	$ff +box
	
	0.0 +fx.on
	
	0.1 0.3 0.1 0.1 xywh%64
	1.1 1.8 0.3 0.3 xywh%64
	'Quad_In 1.0
	1.0 +fx.box

	1.1 1.8 0.3 0.3 xywh%64
	0.1 0.3 0.1 0.1 xywh%64	
	'Quad_In 2.0
	3.0 +fx.box
	
	10.0 +fx.off


	|........................
|	$00 "Hola_a todos" $10d003f $0 100 100 300 300 $ff00ff +textbox
|	0.0 +fx.on
|	100 100 2xy 300 300 2xy 200 200 2xy 500 500 2xy 3.0 2.0 +fx.QuaOut
|	9.0 +fx.off

	|........................
	|son 4.0 +sound

	|........................
	10.0 +restart

	timeline.start
	;

|-----------------------------
:loadtexture | render "" -- text
	IMG_Load | ren surf
	swap over SDL_CreateTextureFromSurface
	swap SDL_FreeSurface ;
	
|-----------------------------
#pfont 
#wp #hp
#op 0 0
#dp 0 0

:bmfont | w h "" --
	SDLrenderer swap loadtexture 'pfont !
	2dup 32 << or dup
	'dp 8 + ! 'op 8 + !
	'hp ! 'wp ! 
	;
	
:bcolor	| rrggbb --
	pfont swap
	dup 16 >> $ff and over 8 >> $ff and rot $ff and
	SDL_SetTextureColorMod
	;
	
:bemit | ascii --
	dup $f and wp * swap 4 >> $f and hp * 32 << or 'op !
	SDLrenderer pfont 'op 'dp SDL_RenderCopy
	wp 'dp d+!
	;
	
:bmprint | "" --
	( c@+ 1? bemit ) 2drop ;
	
:bmat | x y --
	32 << or 'dp ! ;
	
|-----------------------------

:sdlcolor | col --
	SDLrenderer swap
	dup 16 >> $ff and swap dup 8 >> $ff and swap $ff and 
	$ff SDL_SetRenderDrawColor ;

:demo
	0 sdlcolor
	SDLrenderer SDL_RenderClear
	
	timeline.draw
	
	$ffffff bcolor 
	0 0 bmat "<f1> example 1" bmprint
	|0 16 bmat  "<f2> example 2" bmprint
	
	SDLrenderer SDL_RenderPresent
	SDLkey
	<f1> =? ( example1 )
	
	>esc< =? ( exit )
	drop
	debugtimeline
	;
	
:main
	"r3sdl" 640 480 SDLinit

	SDLrenderer $ff $ff $ff $ff SDL_SetRenderDrawColor
	$3 IMG_Init

	SDLrenderer "media/img/lolomario.png" loadtexture 'imagen !
	
	|16 24 "media/img/font16x24.png" bmfont
	8 16 "media/img/VGA8x16.png" bmfont
	
	'demo SDLshow
	
	SDLquit
	;

:memory
	windows
	sdl2
	sdl2image
	mark
	timeline.inimem
	;

: memory main  ;


