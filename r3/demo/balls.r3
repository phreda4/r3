| bubles
| PHREDA 2021

^r3/lib/sdl2gfx.r3
^r3/lib/sdl2image.r3

^r3/lib/rand.r3
^r3/lib/3d.r3
^r3/util/arr16.r3

#spr_ball
#bubles 0 0	| array

|--- bubles list
| x y vx vy
:.x 1 ncell+ ;
:.y 2 ncell+ ;
:.vx 3 ncell+ ;
:.vy 4 ncell+ ;

|---------
:r.01 0.001 randmax ;
:r.1 1.0 randmax ;
:r.8 8.0 randmax ;

	
|---------
:drawball | -- 
	0 0 0 project3d
	14 - swap 14 - swap
	28 28 spr_ball SDLImages ;
	
:hitwall | limit --
	b> 8 - !
	b> 8 + dup @ -0.8 *. | lose impulse
	swap ! ;
	
:bub | adr -- adr/adr 0 delete
 	8 + >b
	mpush
	b@+
	26.0 >? ( 26.0  hitwall )
	-26.0 <? ( -26.0 hitwall )
	b@+
	-20.0 <? ( -20.0 hitwall )
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
	over .x @ over .x @ - dup *. | (x1-x2)^2
	pick2 .y @ pick2 .y @ - dup *. +
	4.0 >=? ( drop ; ) sqrt. 2.0 swap -
	1 >> >a | lose impulse
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

:main
	$0 SDLcls
	800 600 whmode
	0 0 -45.0 mtrans
	'bubles p.draw
	SDLredraw
	
	'collision 'bubles p.map2
	
	SDLkey
	>esc< =? ( exit )
	<f1> =? ( +buble )
	drop
	;

:inicio
	"r3sdl" 800 600 SDLinit

	"media/img/ball.png" loadimg 'spr_ball !
	1000 'bubles p.ini
	'bubles p.clear
	"<f1> add ball" .println
	+buble
	+buble
	'main SDLshow
	
	SDLquit ;
	
: inicio ;

