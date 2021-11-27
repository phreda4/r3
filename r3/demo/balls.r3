| bubles
| PHREDA 2021

^r3/win/sdl2.r3
^r3/win/sdl2image.r3

^r3/lib/rand.r3
^r3/lib/3d.r3
^r3/util/arr16.r3

#spr_ball
#bubles 0 0	| array

|---------
:r.01 0.001 randmax ;
:r.1 1.0 randmax ;
:r.8 8.0 randmax ;

|---------
:drawball | -- 
	0 0 0 project3d 
	14 - swap 14 - swap
	28 28 spr_ball SDLimages ;
	
:hitwall | limit --
	b> 8 - !
	b> 8 + dup @ neg swap ! ;
	
:bub | adr -- adr/adr 0 delete
 	>b
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
	over 8 + @ over 8 + @ - dup *. | (x1-x2)^2
	pick2 16 + @ pick2 16 + @ - dup *. +
	4.0 >=? ( drop ; ) sqrt. 2.0 swap -
	1 >> >a
	over 8 + @ over 8 + @ -
	pick2 16 + @ pick2 16 + @ -
	atan2 sincos 				| p1 p2 si co
	
	a> *.
	dup pick4 16 + +!
	dup pick4 32 + +!
	neg dup pick3 16 + +!
	pick2 32 + +!

	a> *. 
	dup pick3 8 + +! 
	dup pick3 24 + +!
	neg dup pick2 8 + +! 
	over 24 + +!
	;

:main

	$0 SDLclear
	
	800 600 whmode
	
	0 0 -45.0 mtrans
	'bubles p.draw
	SDLRedraw
	
	'collision 'bubles p.map2
	
	SDLkey
	>esc< =? ( exit )
	<f1> =? ( +buble )
	drop
	;

:inicio
	1000 'bubles p.ini
	"r3sdl" 800 600 SDLinit

	"media/img/ball.png" loadimg 'spr_ball !
	1000 'bubles p.ini
	'bubles p.clear
	
	'main SDLshow
	
	SDLquit ;
	
: inicio ;

