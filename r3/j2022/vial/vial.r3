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

#fx 0 0
#obj 0 0

#semaforoestado 0

|----------------- map 
| 1024*600 = 64*37 (16x16)
#mapa * 2368

:mapa.ini
	'mapa 0 2368 cfill ;

:mapa. | x y -- amapa
	600 clamp0max 
	4 >> 6 << swap | 16 / 64 *
	1024 clamp0max 
	4 >> + 'mapa + ;
	
:mapa.show
	'mapa >a
	0 ( 37 <? 
		0 ( 64 <?
			ca@+ 1? ( over 4 << pick3 4 <<  8 8 SDLFRect ) drop
			1 + ) drop
		1 + ) drop ;
	
|-------------- tiempo
#prevt
#dtime

:time.start
	msec 'prevt ! 0 'dtime ! ;

:time.delta
	msec dup prevt - 'dtime ! 'prevt ! ;

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
	db@+ db@+ randmax + db@ or a!
	;
	
|------------- cursor
#upclick	

::cursor!!	| x y -- hit?
	SDLx pick2 - SDLy pick2 - distfast
	32 >? ( 3drop 0 ; ) drop
	32 dup 2swap SDLfEllipse
	SDLB 1? ( 'upclick ! 0 ; ) drop
	upclick 0? ( ; ) drop
	0 'upclick !
	1 ;
	
|-------------- cambio de estado
#mode.run	0
#mode.com	1

|-------------- objeto animado	
| msec addani|cntani x y vx vy lim|xy dest
:robot.1 | v a -- v
	>a
	a@ dup dtime + a!+ 
	a@+ dup 16 >> swap $ffff and rot |  add cnt msec
	animcntm + sprplayer | frame 'sprites
	a@+ 16 >> 32 -	-64 <? ( 3drop 0 ; ) 1064 >? ( 3drop 0 ; )
	a@+ 16 >> 64 -	-64 <? ( 4drop 0 ; ) 664 >? ( 4drop 0 ; ) 
	
	over 32 + over 64 + mapa. 1 swap c!
	
	over 32 + over 32 + cursor!! | hit?
	
	1? ( mode.com a> 5 3 << - ! ) drop
	tsdraw 
	a@+ a> 24 - +!	| vx
	a@+ a> 24 - +!	| vy
	;

:robot.2 | a --
	>a
	a@ dup dtime + a!+ 
	a@+ dup 16 >> swap $ffff and rot |  add cnt msec
	animcntm + 0 nip
	sprplayer | frame 'sprites
	a@+ 16 >> 32 -
	a@+ 16 >> 64 -
	
	over 32 + over 64 + mapa. 1 swap c!
	
	over 32 + over 32 + cursor!! | hit?	
	
	1? ( mode.run a> 5 3 << - ! ) drop
	tsdraw 
	;

		| anim 	| xp	|dxp 	| yp	|dyp	| vx	|dvx	| vy	|dvy 	| limit | dlimit | test
#res1 [ $10005 -32.0	0.0		512.0 	50.0 	0.3 	0.8 	0.0 	0.0 	350 60 $110000 ]
#res2 [ $10005 -32.0	0.0 	150.0 	50.0	0.3 	0.8 	0.0 	0.0 	350 60 $110000 ]
#res3 [ $80005 1024.0	0.0 	512.0 	50.0	-0.3 	-0.8 	0.0 	0.0 	600 60 $010000 ]
#res4 [ $80005 1024.0	0.0 	150.0 	50.0	-0.3 	-0.8 	0.0 	0.0 	600 60 $010000 ]
#res5 [ $10005 380.0	40.0 	0.0 	0.0		0.0 	0.0 	0.3 	0.8 	150 60 $100000 ]
#res6 [ $10005 580.0	40.0 	0.0 	0.0		0.0 	0.0 	0.3 	0.8 	150 60 $100000 ]
#res7 [ $10005 380.0	40.0 	664.0 	0.0		0.0 	0.0 	-0.3 	-0.8 	500 60 $000000 ]
#res8 [ $10005 580.0	40.0 	664.0 	0.0		0.0 	0.0 	-0.3 	-0.8 	500 60 $000000 ]
	
#modes 'robot.1 'robot.2

:+objr
	8 randmax 6 3 << * 'res1 + 
	|1 randmax 3 << 'modes + @ 
	'robot.1 +obj
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
	
	over 32 + over 64 + mapa. 1 swap c!
	
	over 32 + over 32 + cursor!! 
	
	1? ( mode.com a> 5 3 << - ! ) drop
	tsdraw 
	a@+ a> 24 - +!	| vx
	a@+ a> 24 - +!	| vy
	;

		| anim 	| xp	|dxp 	| yp	|dyp	| vx	|dvx	| vy	|dvy 	| limit | dlimit | test
#veh1 [ $120004  -32.0 	0.0 	408.0 	90.0	0.7 	1.0 	0.0 	0.0 	1080 60 $110000 ]
#veh2 [ $e0004	1080.0 	0.0 	210.0 	100.0	-0.7 	-1.0 	0.0 	0.0 	-80 60 $100000 ]

:+bicir
	2 randmax 6 3 << * 'veh1 + 
	'bici +obj
	;

|----------------- autos
#aut1 [ $00001	1080.0 	0.0 	210.0 	80.0	-0.9 	-1.2 	0.0 	0.0 	-80 60 $100000 ]
#aut2 [ $10001  -32.0 	0.0 	390.0 	80.0	0.9 	1.2 	0.0 	0.0 	1080 60 $110000 ]
#aut3 [ $20001	430.0	70.0 	664.0 	0.0		0.0 	0.0 	-0.9 	-1.2 	500 60 $000000 ]

#factor
:sensor | x y
	over 64 + over 64 + mapa. c@ 'factor !
	over 64 + over 64 + mapa. 1 swap c!
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
	factor 1? ( drop ; ) drop
	a@+ a> 24 - +!	| vx
	a@+ a> 24 - +!	| vy
	;
	
:+autor	
	3 randmax 6 3 << * 'aut1 + 'auto  +obj
	a> 5 3 << - dup @
	6 randmax 2 << 16 << + | dibujo de auto
	swap !
	
	;
	
|-------------------------------- semaforo
#sematime

:sema
	16 + >a semaforoestado sprsemaforo a@+ 16 >> 48 - a@+ 16 >> 96 - tsdraw 
	
	dtime 'sematime +!
	sematime 9 >>
	0 =? ( 0 'semaforoestado ! 1 9 << 'sematime ! )
	20 =? ( 1 'semaforoestado ! 21 9 << 'sematime ! )
	23 =? ( 2 'semaforoestado ! 24 9 << 'sematime ! )
	35 =? ( 1 'semaforoestado ! 36 9 << 'sematime ! )	
	38 =? ( 0 'semaforoestado ! 0 'sematime ! )	
	drop
	;

:+sema | x y --
	'sema 'obj p!+ >a 0 a!+ 0 a!+  
	swap 16 << a!+ 16 << a! ;
	
|-------------------------------- adornos
:quieto
	a@+ sprsemaforo 8 a+ a@+ 16 >> 48 - a@+ 16 >> 96 - tsdraw 
	;

:+quieto | nro x y --
	'quieto 'obj p!+ >a 
	rot a!+ 0 a!+  
	swap 16 << a!+ 16 << a! ;
	
|------------------------------	
:usuario
	SDLkey 
	>esc< =? ( exit )
	
	<f1> =? ( +objr )
	<f2> =? ( +bicir )
	<f3> =? ( +autor )
	
	drop 
	;

:debug	
	.cls "list:" .println
	[ dup 8 + >a a@+ a@+ a@+ "%d %d %d" .println ; ] 'obj p.mapv ;
	
:jugando
	0 0 mapajuego SDLimage

	4 'obj p.sort
	time.delta
	mapa.ini
	'obj p.drawo
	'fx p.draw
	
mapa.show

	|debug	
|	2 2 bat cercano "%d" sprint bprint
	
	SDLredraw
	usuario
	;
	
:reset
	'obj p.clear
	'fx p.clear
	
	354 48 + 100 96 + +sema
	546 48 + 426 96 + +sema
	
	| adornos
|	3 400 300 +quieto
	
	time.start

	'robot.1 'mode.run !
	'robot.2 'mode.com !
	;

:main
	"r3sdl" 1024 600 SDLinit
	bfont1 
	|SDLfull
	
	"r3\j2022\vial\mapa.png" loadimg 'mapajuego !
	
	128 128 "r3\j2022\vial\autos.png" loadts 'sprauto !
	64 64 "r3\j2022\vial\robot.png" loadts 'sprplayer !
	96 96 "r3\j2022\vial\semaforo.png" loadts 'sprsemaforo !
	
	1000 'obj p.ini
	1000 'fx p.ini
	reset
	
	'jugando SDLshow

	SDLquit ;	
	
: main ;