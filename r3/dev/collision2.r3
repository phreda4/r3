| try speed up collision
| PHREDA 2022

^r3/win/sdl2gfx.r3
^r3/lib/rand.r3
^r3/util/arr16.r3
^r3/util/sdlgui.r3
^r3/util/hash2d.r3

#spr_ball
#arr 0 0	| array

| 0 1  2    3   4  5   6  7  8  9
| x y ang zoom img rad h vx vy va

:.x 1 ncell+ ;
:.y 2 ncell+ ;
:.a 3 ncell+ ;
:.zoom 4 ncell+ ;
:.image 5 ncell+ ;
:.radio 6 ncell+ ;
:.vx 7 ncell+ ;
:.vy 8 ncell+ ;
:.va 9 ncell+ ;

:drawrect | n --
	'arr p.nro
	dup .radio @
	over .x @ int. over 1 + 1 >> - 		| radio xmin
	pick2 .y @ int. pick2 1 + 1 >> - 	| radio ymin ymin
	rot dup SDLFRect
	drop
	;

:drawhit
	$ff sdlcolor
	H2d.list
	( 1? 1 - swap
		d@+ dup
		16 >>> drawrect
		$ffff and drawrect
		swap ) 2drop ;

:hitx a> .vx dup @ neg swap ! ;
:hity a> .vy dup @ neg swap ! ;

:obj | adr -- adr/adr 0 delete
 	dup >a
	a> .vx @ a> .x +!
	a> .vy @ a> .y +!
	a> .va @ a> .a +!
	a> .x @ int. 0 <? ( hitx ) sw >? ( hitx ) drop
	a> .y @ int. 0 <? ( hity ) sh >? ( hity ) drop
	
	a> 'arr p.nnow | nro
	32
	a> .x @ int.  | x 
	a> .y @ int.  | y
	h2d+!
	
	8 + >a a@+ int. a@+ int. a@+ a@+ 0 a@+ sspriterz | x y ang zoom img --
	;

:+obj | img zoom ang y x --
	'obj 'arr p!+ >a
	a!+ a!+ | x y 
	a!+ 	| ang
	dup a!+ | img zoom
	swap dup a!+ | zoom img
	sspritewh max *. a!+ | radio in pixel
	1.9 randmax a!+ | vx
	1.9 randmax a!+ | vy	
	0.1 randmax 0.05 - a!+ | va
	;

|----------------------------------------
:+randobj
	spr_ball 			| img
	1.0 randmax 0.2 +	| zoom
	1.0 randmax			| ang
	600.0 randmax 		| y
	800.0 randmax		| x 
	+obj ;
	
:insobj
	30 ( 1? 1 -
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
	"r3sdl" 800 600 SDLinit
	bfont1	
	64 64 "media/img/ball.png" ssload 'spr_ball !
	1000 'arr p.ini
	1000 H2d.ini 
	
	'arr p.clear
	insobj
	
	'main SDLshow
	
	SDLquit ;
	
: inicio ;

