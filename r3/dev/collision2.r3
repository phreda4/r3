| speed up collision
| PHREDA 2024

^r3/win/sdl2gfx.r3
^r3/lib/rand.r3
^r3/util/arr16.r3
^r3/util/sdlgui.r3
^r3/util/hash2d.r3

#spr_ball

#arr 0 0

|---------- struct sprite
| 1 2  3    4   5   6  7  8  9
| x y ang zoom img rad vx vy va

:.x 1 ncell+ ;
:.y 2 ncell+ ;
:.a 3 ncell+ ;
:.zoom 4 ncell+ ;
:.image 5 ncell+ ;
:.radio 6 ncell+ ;
:.vx 7 ncell+ ;
:.vy 8 ncell+ ;
:.va 9 ncell+ ;

|--------------------
:drawrect | n --
	'arr p.adr
	dup .radio @
	over .x @ int. over 1 + 1 >> - 		| radio xmin
	pick2 .y @ int. pick2 1 + 1 >> - 	| radio ymin ymin
	rot dup SDLRect
	drop
	;
	
:collision | p1 p2 -- p1 p2
	over .x @ over .x @ - dup *. | (x1-x2)^2
	pick2 .y @ pick2 .y @ - dup *. +
	
	pick2 dup .radio @ swap .zoom @ * 
	pick2 dup .radio @ swap .zoom @ * + dup *.
	
	>=? ( drop ; ) sqrt. |2.0 swap -
	0.02 *. >a 
	over .x @ over .x @ -
	pick2 .y @ pick2 .y @ -
	atan2 sincos 				| p1 p2 si co
	
	a> *.
	dup pick4 .y +!
	dup pick4 .vy +!
	neg dup pick3 .y +!
	pick2 .vy +!

	a> *. 
	dup pick3 .x +! 
	dup pick3 .vx +!
	neg dup pick2 .x +! 
	over .vx +!
	;	

:drawhit
	$ffffff sdlcolor
	H2d.list
	( 1? 1 - swap
		d@+ dup
		
		dup
		16 >>> drawrect
		$ffff and drawrect
		
		dup	16 >>> 'arr p.adr
		swap $ffff and 'arr p.adr
		collision
		2drop
		
		swap ) 2drop ;

|--------------------
:hitx a> .vx dup @ neg swap ! ;
:hity a> .vy dup @ neg swap ! ;

#minx 40.0
#maxx 1000.0 
#maxy 700.0

:obj | adr -- adr/adr 0 delete
 	>a
	
	0.03 a> .vy +!
	a> .vx @ a> .x +!
	a> .vy @ a> .y +!
	a> .va @ a> .a +!
	a> .x @ minx <? ( minx a> .x ! hitx ) maxx >? ( maxx a> .x ! hitx ) drop
	a> .y @ 0 <? ( hity ) maxy >? ( maxy a> .y ! hity ) drop
	
	a> 'arr p.nro | nro
	32
	a> .x @ int. a> .y @ int. 
	h2d+!
	
	8 a+ 
	a@+ int. a@+ int. a@+ a@+ 0 a@+ 
	sspriterz | x y ang zoom img --
	;

:+obj | img zoom ang y x --
	'obj 'arr p!+ >a
	a!+ a!+ | x y 
	a!+ 	| ang
	dup a!+ | img zoom
	swap dup a!+ | zoom img
	sspritewh max *. a!+ | radio in pixel
|	0 0 0 a!+ a!+ a!+
	0.9 randmax a!+ | vx
	0.9 randmax a!+ | vy	
	0
	|0.1 randmax 0.05 - 
	a!+ | va
	;

|----------------------------------------
:+randobj
	spr_ball 			| img
	0.6 randmax 0.2 +	| zoom
|1.0 randmax			| ang
	0
	600.0 randmax 		| y
	800.0 randmax		| x 
	+obj ;
	
:insobj
	60 ( 1? 1 -
		+randobj
		) drop ;
	
|------------------------------
:main
	$0 SDLcls
	
	H2d.clear
	'arr p.draw
	drawhit
	
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	<f1> =? ( +randobj )
	drop
	;

:inicio
	"Collision" 1024 720 SDLinit
	bfont1	
	64 64 "media/img/ball.png" ssload 'spr_ball !
	1000 'arr p.ini
	1000 H2d.ini 
	
	'arr p.clear
	insobj
	
	'main SDLshow
	
	SDLquit ;
	
: inicio ;

