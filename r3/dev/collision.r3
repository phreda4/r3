| try speed up collision
| PHREDA 2022

^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3

^r3/lib/rand.r3
^r3/util/arr16.r3
|^r3/util/bfont.r3

#spr_ball
#arr 0 0	| array

| 0 1  2    3   4  5   6  7  8  9 10   11    12		13
| x y ang zoom img rad h vx vy va mat maskx masky state

:.x 1 ncell+ ;
:.y 2 ncell+ ;
:.a 3 ncell+ ;
:.zoom 4 ncell+ ;

:.radio 6 ncell+ ;
:.vx 8 ncell+ ;
:.vy 9 ncell+ ;
:.va 10 ncell+ ;
:.maskx 12 ncell+ ;
:.masky 13 ncell+ ;
:.state 14 ncell+ ;

|---------
:bitmaskx | min max -- mask
	sw clamp0max 63 sw */ 1 swap << 1 - | 000001111
	swap
	sw clamp0max 63 sw */ 1 swap << 1 - | 000111111
	xor ;

:bitmasky | min max -- mask
	sh clamp0max 63 sh */ 1 swap << 1 - | 000001111
	swap
	sh clamp0max 63 sh */ 1 swap << 1 - | 000111111
	xor ;
	
:setmask | adr -- adr
	dup .radio @ over .zoom @ 16 *>> | radio
	over .x @ int. over 1 + 1 >> - 		| radio xmin
	2dup +							| radio xmin xmax
	bitmaskx pick2 .maskx !
	over .y @ int. over 1 + 1 >> - 		| radio ymin	
	swap over +						| ymin ymax
	bitmasky over .masky !
	;
	
:drawrect | adr -- adr
	$ffffff sdlcolor
	dup .radio @ over .zoom @ 16 *>> | radio
	over .x @ int. over 1 + 1 >> - 		| radio xmin
	pick2 .y @ int. pick2 1 + 1 >> - 	| radio ymin ymin
	rot dup SDLREct
	;

:hitx over .vx dup @ neg swap ! ;
:hity over .vy dup @ neg swap ! ;

:obj | adr -- adr/adr 0 delete
 	dup 
	dup .vx @ over .x +!
	dup .vy @ over .y +!
	dup .va @ over .a +!
	dup .x @ int. 0 <? ( hitx ) sw >? ( hitx ) drop
	dup .y @ int. 0 <? ( hity ) sh >? ( hity ) drop
	setmask	
	
	dup .state @ 1? ( over drawrect drop ) drop
	
	0 swap .state !
	
	8 + >a a@+ int. a@+ int. a@+ a@+ a@+ SDLspriteRZ | x y ang zoom img --
	;

:+obj | img zoom ang y x --
	'obj 'arr p!+ >a
	a!+ a!+ a!+ a!+ 
	dup a!+ | img
	SDLimagewh max a!+
	8 a+
	1.9 randmax a!+ | vx
	1.9 randmax a!+ | vy	
	0.1 randmax 0.05 - a!+ | va
	;

|----------------------------------------
| need 1+ because first is the vector to ex
|
|
:collision | p1 p2 -- p1 p2
	over .maskx @ over .maskx @ and 0? ( drop ; ) drop | maskx
	over .masky @ over .masky @ and 0? ( drop ; ) drop | masky

|	over .maskx over .maskx
|	@+ rot @+ rot and rot @ rot @ and or 0? ( drop ; ) drop

	1 pick2 .state !	| state
	1 over .state !
	;

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
	'arr p.draw
	SDLredraw
	
	'collision 'arr p.map2
	
	SDLkey
	>esc< =? ( exit )
	<f1> =? ( +randobj )
	drop
	;

:inicio
	"r3sdl" 800 600 SDLinit
|	bfont1	
	"media/img/ball.png" loadimg 'spr_ball !
	1000 'arr p.ini
	'arr p.clear
	insobj
	
	'main SDLshow
	
	SDLquit ;
	
: inicio ;

