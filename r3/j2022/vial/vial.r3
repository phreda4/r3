| TILEMAP + ENEMY + PLAYER
| PHREDA 2022

^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3

^r3/lib/rand.r3

^r3/util/arr16.r3
^r3/util/tilesheet.r3
^r3/util/bfont.r3

#mapajuego

#sprplayer
#sprauto
#sprsemaforo
#sprvida
#base1 
#base2

#vidas 

#fx 0 0
#obj 0 0

#semaforoestado 0

|----------------- map 
| 1024*600 = 64*37 (16x16)
#mapa * 2368
#mapao * 2368
#mapaw 64

:mapa.ini
	'mapao 'mapa 2368 cmove
	'mapa 0 2368 cfill ;

:mapa. | x y -- amapa
	4 >> 6 << swap 4 >> + 'mapa + ;

:mapa.mem | x y -- adr
	0 <? ( 2drop 0 ; ) 600 >? ( 2drop 0 ; )
	4 >> 6 << swap | 16 / 64 *
	0 <? ( 2drop 0 ; ) 1024 >? ( 2drop 0 ; )
	4 >> + ;
	
:mapa@ | x y -- n
	mapa.mem 0? ( ; ) 'mapao + c@ ;

:mapa! | x y --
	mapa.mem 0? ( drop ; ) 'mapa + 1 swap c! ;

:mapa.show
	'mapa >a
	0 ( 37 <? 
		0 ( 64 <?
			ca@+ 1? ( over 4 << pick3 4 << 16 dup SDLRect ) drop
			1 + ) drop
		1 + ) drop ;
		
:mapa.rect | x y w h --
	( 1? 1 -
		over ( 1? 1 - 
			pick4 over 4 << + pick4 pick3 4 << + mapa!
			) drop
		) 4drop ;

:mapa!c | x y --
	mapa.mem 0? ( drop ; ) 'mapa + 2 swap c! ;

:mapa.car | x y w h --
	( 1? 1 -
		over ( 1? 1 - 
			pick4 over 4 << + pick4 pick3 4 << + mapa!c
			) drop
		) 4drop ;
	
:mapa.test | w h x y  -- nro
	swap 0 <? ( 4drop 0 ; ) 1024 >? ( 4drop 0 ; )
	swap 0 <? ( 4drop 0 ; ) 600 >? ( 4drop 0 ; )
	mapa. >a | w h
	0 >b
	( 1? 1 -
		over ( 1? 1 - 
			ca@+ b+
			) drop
		mapaw pick2 - a+
		) 2drop 
	b> ;
	
|-------------- tiempo
#prevt
#dtime
#reloj

:time.start
	msec 'prevt ! 0 'dtime ! 
	0 'reloj ! ;

:time.delta
	msec dup prevt - 'dtime ! 'prevt ! 
	dtime 'reloj +! ;

:animcntm | cnt msec -- 0..cnt-1
	55 << 1 >>> 63 *>> ; | 55 speed
	
:+obj | 'from 'vec --
	'obj p!+ >a >b
	0 a!+
	db@+ a!+
	db@+ db@+ randmax + a!+
	db@+ db@+ randmax + a!+
	db@+ db@+ randmax + a!+
	db@+ db@+ randmax + a!+
	1.0 a!
	;

|------------------------------------------- muerte
	
| msec addani|cntani x y vx vy lim|xy dest
:fantasma | a --
	>a
	a@ dup dtime + a!+ 
	a@+ dup 16 >> swap $ffff and rot |  add cnt msec
	animcntm + sprplayer | frame 'sprites
	a@+ 16 >> 32 -	
	a@+ 16 >> 64 -	
	tsdraw 
	-16 a+
	a@ 
	prevt 5 << sin 2 >> +
	a!+
	a@ 1.0 - 
	-? ( drop 0 ; )
	a!+
	;

:+fantasma | x y --
	'fantasma 'fx p!+ >a 
	0 a!+
	$00003 a!+
	swap 16 << a!+ 16 << a!+
	-1 'vidas +!
	;

:explo | a --
	>a
	a@ dup dtime + a!+ 
	a@+ dup 16 >> swap $ffff and rot |  add cnt msec
	1 >> animcntm + 
	$49 =? ( drop 0 ; ) sprplayer | frame 'sprites
	a@+ 16 >> 32 -	
	a@+ 16 >> 64 -	
	tsdraw ;

:+explo | x y --
	'explo 'fx p!+ >a 
	0 a!+
	$460004 a!+
	swap 16 << a!+ 16 << a!+
	;

:testchoque | x y -- t
	over 32 + over 50 + 
	mapa@ 
	2 <? ( 0 nip ; ) drop
	over 32 + over 50 + 
	2dup +explo
	+fantasma
	1
	;	
	
|------------- cursor
#hotnow

::cursor!!	| x y -- hit?
	SDLx pick2 - SDLy pick2 - distfast
	32 >? ( 3drop 0 ; ) drop
	0 SDLColor
	32 dup 2swap SDLfEllipse
	
	sdlb 1? ( a> hotnow =? ( 2drop 0 ; ) 'hotnow ! ; ) drop
	a> hotnow =? ( 0 'hotnow ! ) drop
	0
	;

	
|-------------- objeto animado	
| msec addani|cntani x y vx vy lim|xy dest
:estado
	0? ( 1.0 + ; ) dup xor ;
	
:quietoycamina
	a> 16 + dup @ estado swap ! ;
	
:robot | v a -- v
	>a
	a@ dup dtime + a!+ 
	a@+ dup 16 >> swap $ffff and rot |  add cnt msec
	animcntm + 
	
	sprplayer | frame 'sprites
	a@+ 16 >> 32 -	-64 <? ( 3drop 0 ; ) 1064 >? ( 3drop 0 ; )
	a@+ 16 >> 64 -	-64 <? ( 4drop 0 ; ) 664 >? ( 4drop 0 ; ) 
	
	testchoque 1? ( 4drop drop 0 ; ) drop
	
	over 32 + over 32 + cursor!! | hit?
	1? ( quietoycamina ) drop
	tsdraw 
	a> 16 + @ 
	a@+ over *. a> 24 - +!	| vx
	a@+ *. a> 24 - +!	| vy
	;


		| anim 	| xp	|dxp 	| yp	|dyp	| vx	|dvx	| vy	|dvy 	| limit | dlimit | test
#res1 [ $10005 -32.0	0.0		512.0 	50.0 	0.3 	0.5 	0.0 	0.0 	0 ]  1.0
#res2 [ $10005 -32.0	0.0 	150.0 	50.0	0.3 	0.5 	0.0 	0.0 	0 ]  1.0
#res3 [ $80005 1024.0	0.0 	512.0 	50.0	-0.3 	-0.5 	0.0 	0.0 	0 ]  1.0
#res4 [ $80005 1024.0	0.0 	150.0 	50.0	-0.3 	-0.5 	0.0 	0.0 	0 ]  1.0
#res5 [ $10005 380.0	40.0 	0.0 	0.0		0.0 	0.0 	0.3 	0.8 	0 ]  1.0
#res6 [ $10005 580.0	40.0 	0.0 	0.0		0.0 	0.0 	0.3 	0.8 	0 ]  1.0
#res7 [ $10005 380.0	40.0 	664.0 	0.0		0.0 	0.0 	-0.3 	-0.8 	0 ]  1.0
#res8 [ $10005 580.0	40.0 	664.0 	0.0		0.0 	0.0 	-0.3 	-0.8 	0 ]  1.0
	

:+robotr
	8 randmax 6 3 << * 'res1 + 
	'robot +obj
	
	'obj p.cnt 1 - 
	'obj p.nro
	16 +
	dup @ 
	$30000 + 
	3 randmax 22 * 16 << +
	swap !
	;

|-------------------------------------------
	
| msec addani|cntani x y vx vy lim|xy dest
:bici | a --
	>a
	a@ dup dtime + a!+ 
	a@+ dup 16 >> swap $ffff and rot |  add cnt msec
	animcntm + sprplayer | frame 'sprites
	a@+ 16 >> 32 -	-64 <? ( 3drop 0 ; ) 1064 >? ( 3drop 0 ; )
	a@+ 16 >> 64 -	-64 <? ( 4drop 0 ; ) 664 >? ( 4drop 0 ; ) 
	
	testchoque 1? ( 4drop drop 0 ; ) drop
	
	over 32 + over 32 + cursor!! 
	1? ( quietoycamina ) drop
	
	tsdraw 
	a> 16 + @	
	a@+ over *. a> 24 - +!	| vx
	a@+ *. a> 24 - +!	| vy
	;


		| anim 	| xp	|dxp 	| yp	|dyp	| vx	|dvx	| vy	|dvy 	| limit | dlimit | test
#veh1 [ $120004  -32.0 	0.0 	408.0 	90.0	0.7 	1.0 	0.0 	0.0 	0 ]  1.0
#veh2 [ $e0004	1080.0 	0.0 	210.0 	100.0	-0.7 	-1.0 	0.0 	0.0 	0 ]  1.0

:+bicir
	2 randmax 6 3 << * 'veh1 + 
	'bici +obj

	'obj p.cnt 1 - 
	'obj p.nro
	16 +
	dup @ 
	$30000 + 
	3 randmax 22 * 16 << +
	swap !	
	;


|----------------- autos
#aut1 [ $00001	1080.0 	0.0 	210.0 	70.0	-0.9 	-1.2 	0.0 	0.0 	0 ]  1.0
#aut2 [ $10001  -32.0 	0.0 	380.0 	70.0	0.9 	1.2 	0.0 	0.0 	0 ]  1.0
#aut3 [ $20001	470.0	72.0 	664.0 	0.0		0.0 	0.0 	-0.9 	-1.2 	0 ]  1.0

#sensorhit
	
:testsensor | dx dy --
	swap pick3 + swap pick2 + 
	mapa@ 'sensorhit ! ;

:sensor | x y
	0 'sensorhit !
	a@ |vx
	0 <? ( drop -16 72 testsensor over 24 + over 40 + 6 4 mapa.car ; )
	0 >? ( drop 128 72 testsensor over 24 + over 40 + 6 4 mapa.car ; )
	drop
	64 16 testsensor 
	over 40 + over 40 + 4 4 mapa.car
	;
	
:auto
	>a
	a@ dup dtime + a!+ 
	a@+ dup 16 >> swap $ffff and rot |  add cnt msec
	animcntm + sprauto | frame 'sprites
	a@+ 16 >> 64 -	-128 <? ( 3drop 0 ; ) 1152 >? ( 3drop 0 ; )
	a@+ 16 >> 64 -	-128 <? ( 4drop 0 ; ) 728 >? ( 4drop 0 ; ) 
	sensor
	tsdraw 
	sensorhit 1? ( drop ; ) drop
	a@+ a> 24 - +!	| vx
	a@+ a> 24 - +!	| vy
	;
	
:+autor	
	3 randmax 6 3 << * 'aut1 + 'auto  +obj
	a> 5 3 << - dup @
	6 randmax 2 << 16 << + | dibujo de auto
	swap !
	;

|---------------------
#secant

:creador
	msec 10 >>
	secant =? ( drop ; )
	'secant !
	3 randmax 0? ( +autor ) drop | 1/3
	5 randmax 0? ( +robotr ) drop
	5 randmax 0? ( +bicir ) drop
	;
	
|-------------------------------- semaforo
#sematime

:mapa.sema
	semaforoestado
	0? ( drop 440 530 8 4 mapa.rect ; ) drop
	620 210 4 7 mapa.rect
	330 390 4 7 mapa.rect
	;

:sema
	>a a@+ semaforoestado + sprsemaforo 
	8 a+
	a@+ 16 >> 48 - a@+ 16 >> 96 - tsdraw 
	
	dtime 'sematime +!
	sematime 9 >>
	0 =? ( 0 'semaforoestado ! 1 9 << 'sematime ! )
	30 =? ( 1 'semaforoestado ! 31 9 << 'sematime ! )
	33 =? ( 2 'semaforoestado ! 34 9 << 'sematime ! )
	55 =? ( 1 'semaforoestado ! 56 9 << 'sematime ! )	
	58 =? ( 0 'semaforoestado ! 0 'sematime ! )	
	drop
	;

:+sema | r x y --
	'sema 'obj p!+ >a 
	rot a!+ 0 a!+  
	swap 16 << a!+ 16 << a! ;
	
|-------------------------------- adornos
:quieto
	>a
	a@+ sprsemaforo 8 a+ 
	a@+ 16 >> 48 - a@+ 16 >> 96 - tsdraw 
	;

:+quieto | nro x y --
	'quieto 'obj p!+ >a 
	rot a!+ 0 a!+  
	swap 16 << a!+ 16 << a! ;
	
|------------------------------	 estado
:vidanro | nro -- nro spr
	vidas >=? ( 1 ; ) 0 ;
	
:barraestado
	40 500 base1 sdlimage
	
	5 ( 1? 1 -
		vidanro sprvida pick2 54 * 70 + 524 tsdraw
		) drop
		
	740 500 base2 sdlimage
	
	0 sdlcolor
	780 530 bat 
	reloj 1000 / 
	"%d" sprint bprint
	;
	
|------------------------------	
:usuario
	SDLkey 
	>esc< =? ( exit )
	
	<f1> =? ( +robotr )
	<f2> =? ( +bicir )
	<f3> =? ( +autor )
	
	<f4> =? ( sdlx sdly +fantasma )
	drop 
	;

:debug	
	1 4 sdlx sdly mapa.test "%d" sprint bprint
	.cls "list:" .println
	[ dup 8 + >a a@+ a@+ a@+ "%d %d %d" .println ; ] 'obj p.mapv ;
	
:jugando
	0 0 mapajuego SDLimage

	creador
	4 'obj p.sort
	time.delta
	
	mapa.ini
	mapa.sema
	'obj p.drawo
	'fx p.draw
	
|	mapa.show
|	debug	
	
	barraestado
	SDLredraw
	usuario
	;
	
:reset
	'obj p.clear
	'fx p.clear
	
	0 354 48 + 100 96 + +sema
	3 546 48 + 426 96 + +sema
	
	| adornos
	6 0 350 +quieto
	6 254 350 +quieto
	6 792 350 +quieto
	6 990 350 +quieto
	
	5 'vidas !
	time.start
	;

|---------------------------------
:findejuego
	;
	
:menuprincipal

|	[ reset 'jugando SDLShow 'findejuego SDLShow ; ]
|	'exit
	;

|---------------------------------
:main
	"r3sdl" 1024 600 SDLinit
	bfont2 
	|SDLfull
	
	"r3\j2022\vial\mapa.png" loadimg 'mapajuego !
	
	128 128 "r3\j2022\vial\autos.png" loadts 'sprauto !
	64 64 "r3\j2022\vial\robot.png" loadts 'sprplayer !
	96 96 "r3\j2022\vial\semaforo.png" loadts 'sprsemaforo !
	51 42 "r3\j2022\vial\vida.png" loadts 'sprvida !
	"r3\j2022\vial\base1.png" loadimg 'base1 !
	"r3\j2022\vial\base2.png" loadimg 'base2 !
	1000 'obj p.ini
	1000 'fx p.ini
	reset
	
	'jugando SDLshow

	SDLquit ;	
	
: main ;