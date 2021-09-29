| bubles
| PHREDA 2021

^r3/win/console.r3
^r3/win/sdl2.r3
^r3/win/sdl2image.r3
^r3/lib/key.r3

^r3/lib/rand.r3
^r3/lib/3d.r3
^r3/util/arr16.r3

#spr_ball
#bubles 0 0

|---------
:r.01 0.001 randmax ;
:r.1 1.0 randmax ;
:r.8 8.0 randmax ;

|---------
#rbox [ 0 0 64 64 ]

:drawball | -- 
	0 0	0 project3d 
	2dup "%d %d " .print
	32 - swap 32 - 'rbox d!+ d!
	SDLrenderer 'spr_ball 0 'rbox SDL_RenderCopy ;
	
:bub | adr -- adr/adr 0 delete
 	>b
	mpush
	b@+
	18.0 >? ( 18.0 b> 4 - ! b> 8 + dup @ neg swap ! )
	-18.0 <? ( -18.0 b> 4 - ! b> 8 + dup @ neg swap ! )
	b@+
	-18.0 <? ( -18.0 b> 4 - ! b> 8 + dup @ neg swap ! )
	0 mtransi
	b@+ b> 24 - +!
	b@ 0.01 - b> ! | gravedad
	b@+ b> 24 - +!
	drawball
	mpop
	;

:+buble
	'bub 'bubles p!+ >a
	r.8 r.8 a!+ a!+
	r.1 r.1 a!+ a! ;

:collision | p1 p2 -- p1 p2
	over 8 + @ over 8 + @ - dup *. | (x1-x2)^2
	pick2 16 + @ pick2 16 + @ - dup *. +
	4.0 >=? ( drop ; ) sqrt. 2.0 swap -
	1 >> >r
	over 8 + @ over 8 + @ -
	pick2 16 + @ pick2 16 + @ -
	atan2 sincos swap				| p1 p2 si co
	dup r@ *. pick4 8 + +!
	dup r@ *. neg pick3 8 + +!
	over r@ *. pick4 16 + +!
	over r@ *. neg pick3 16 + +!

	dup r@ *. pick4 24 + +!
	dup r@ *. neg pick3 24 + +!
	over r@ *. pick4 32 + +!
	over r@ *. neg pick3 32 + +!

	2drop
	r> drop
	;

:main
	$0 SDLColor
	SDLrenderer SDL_RenderClear
	
	800 600 whmode
	
	0 0 -40.0 mtrans
	'bubles p.draw
	
	SDLrenderer SDL_RenderPresent
	
	'collision 'bubles p.map2
	
	SDLkey
	>esc< =? ( exit )
	<f1> =? ( +buble )
	drop
	;

:inicio
	mark
	1000 'bubles p.ini

	"r3sdl" 800 600 SDLinit

	"media/img/ball.png" loadimg 'spr_ball !
	1000 'bubles p.ini
	'bubles p.clear
	
	'main SDLshow
	
	SDLquit ;
	
: inicio ;

