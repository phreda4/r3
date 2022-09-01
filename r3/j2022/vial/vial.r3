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
#mapao * 2368
#mapaw 64

:mapa.ini
	'mapao 'mapa 2368 cmove
	'mapa 0 2368 cfill ;

:mapa. | x y -- amapa
	4 >> 6 << swap 4 >> + 'mapa + ;

:mapa@ | x y -- n
	0 <? ( 2drop 0 ; ) 600 >? ( 2drop 0 ; )
	4 >> 6 << swap | 16 / 64 *
	0 <? ( 2drop 0 ; ) 1024 >? ( 2drop 0 ; )
	4 >> + 'mapao + c@ ;

:mapa! | x y --
	0 <? ( 2drop ; ) 600 >? ( 2drop ; )
	4 >> 6 << swap | 16 / 64 *
	0 <? ( 2drop ; ) 1024 >? ( 2drop ; )
	4 >> + 'mapa +
	1 swap c! ;
	
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
	1.0 a!
	;
	
|------------- cursor
#hotnow

::cursor!!	| x y -- hit?
	SDLx pick2 - SDLy pick2 - distfast
	32 >? ( 3drop 0 ; ) drop
	0 SDLColor
	32 dup 2swap SDLfEllipse
	sdlb 1? ( a@ hotnow =? ( 2drop 0 ; ) 'hotnow ! ; ) drop
	a@ hotnow =? ( 0 'hotnow ! ) drop
	0
	;
	
|-------------- objeto animado	
| msec addani|cntani x y vx vy lim|xy dest

:estado
	0? ( 1.0 + ; )
	drop 0
	;
	
:quietoycamina
	a> 16 + @
	estado
	a> 16 + !
	;
	
:robot | v a -- v
	>a
	a@ dup dtime + a!+ 
	a@+ dup 16 >> swap $ffff and rot |  add cnt msec
	animcntm + 
	
	sprplayer | frame 'sprites
	a@+ 16 >> 32 -	-64 <? ( 3drop 0 ; ) 1064 >? ( 3drop 0 ; )
	a@+ 16 >> 64 -	-64 <? ( 4drop 0 ; ) 664 >? ( 4drop 0 ; ) 
	
	over 32 + over 50 + mapa!
	
	over 32 + over 32 + cursor!! | hit?
	1? ( quietoycamina ) drop
	tsdraw 
	a> 16 + @
	a@+ over *. a> 24 - +!	| vx
	a@+ *. a> 24 - +!	| vy
	;


		| anim 	| xp	|dxp 	| yp	|dyp	| vx	|dvx	| vy	|dvy 	| limit | dlimit | test
#res1 [ $10005 -32.0	0.0		512.0 	50.0 	0.3 	0.8 	0.0 	0.0 	0 ]  1.0
#res2 [ $10005 -32.0	0.0 	150.0 	50.0	0.3 	0.8 	0.0 	0.0 	0 ]  1.0
#res3 [ $80005 1024.0	0.0 	512.0 	50.0	-0.3 	-0.8 	0.0 	0.0 	0 ]  1.0
#res4 [ $80005 1024.0	0.0 	150.0 	50.0	-0.3 	-0.8 	0.0 	0.0 	0 ]  1.0
#res5 [ $10005 380.0	40.0 	0.0 	0.0		0.0 	0.0 	0.3 	0.8 	0 ]  1.0
#res6 [ $10005 580.0	40.0 	0.0 	0.0		0.0 	0.0 	0.3 	0.8 	0 ]  1.0
#res7 [ $10005 380.0	40.0 	664.0 	0.0		0.0 	0.0 	-0.3 	-0.8 	0 ]  1.0
#res8 [ $10005 580.0	40.0 	664.0 	0.0		0.0 	0.0 	-0.3 	-0.8 	0 ]  1.0
	

:+robotr
	8 randmax 6 3 << * 'res1 + 
	'robot +obj
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
	
	over 32 + over 50 + mapa!
	
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
	;

|----------------- autos
#aut1 [ $00001	1080.0 	0.0 	210.0 	70.0	-0.9 	-1.2 	0.0 	0.0 	0 ]  1.0
#aut2 [ $10001  -32.0 	0.0 	380.0 	70.0	0.9 	1.2 	0.0 	0.0 	0 ]  1.0
#aut3 [ $20001	470.0	72.0 	664.0 	0.0		0.0 	0.0 	-0.9 	-1.2 	0 ]  1.0

#sensorhit

:sensor | x y
	0 'sensorhit !
	a@ |vx
	0 <? ( pick2 32 - pick2 72 + mapa@ 'sensorhit ! )
	0 >? ( pick2 128 + pick2 72 + mapa@ 'sensorhit ! )
	drop
	a> 8 + @
	0 <? ( pick2 64 + pick2 16 + mapa@ 'sensorhit ! )
|	0 >? ( pick2 64 + pick2 64 + mapa@ 'sensorhit ! )
	drop
	over 24 + over 40 + 6 4 mapa.rect
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
	4 randmax 0? ( +robotr ) drop
	4 randmax 0? ( +bicir ) drop
	;
	
|-------------------------------- semaforo
#sematime

:mapa.sema
	semaforoestado
	1? ( drop 440 530 8 4 mapa.rect ; ) drop
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
	
	<f1> =? ( +robotr )
	<f2> =? ( +bicir )
	<f3> =? ( +autor )
	
	drop 
	;

:debug	
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
	
|mapa.show

	|debug	
	2 2 bat 
	 
|	1 4 sdlx sdly mapa.test "%d" sprint bprint
	
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
	
	time.start
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