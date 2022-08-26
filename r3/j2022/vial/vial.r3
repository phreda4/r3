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
#sprsemaforo

#fx 0 0
#obj 0 0

#semaforoestado 0


#botrs $000000001
#botrr $100000005 |1 2 3 4 5
#botrt $600000001

#botrb $1200000004 | 18 19 20 21

#botls $700000001
#botlr $800000005 |8 9 10 11 12
#botlt $d00000001 |13

#botlb $e00000004 |14 15 16 17

|-------------- tiempo
#prevt
#dtime

:time.start
	msec 'prevt ! 0 'dtime ! ;

:time.delta
	msec dup prevt - 'dtime ! 'prevt ! ;

:animcntm | cnt msec -- 0..cnt-1
	55 << 1 >>> 63 *>> ; | 55 speed
	
|------------- cursor
	
::cursor!!	| x y -- hit?
	SDLx pick2 - SDLy pick2 - distfast
	16 >? ( 3drop 0 ; ) drop
	32 dup 2swap SDLfEllipse
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
	over 32 + over 32 + cursor!! | hit?
	>r
	tsdraw 
	a@+ a> 24 - +!	| vx
	a@+ a> 24 - +!	| vy
	r> 0? ( drop ; ) drop | hit
	| falta click
	SDLb 0? ( drop ; ) drop
	mode.com a> 7 3 << - !
	;

:robot.2 | a --
	>a
	a@ dup dtime + a!+ 
	a@+ dup 16 >> swap $ffff and rot |  add cnt msec
	animcntm + 0 nip
	sprplayer | frame 'sprites
	a@+ 16 >> 32 -
	a@+ 16 >> 64 -
	over 32 + over 32 + cursor!! >r | hit?	
	tsdraw 
	r> 0? ( drop ; ) drop | hit
	
	SDLb 0? ( drop ; ) drop	
	mode.run a> 7 3 << - !
	;

|================================
:getcoor
	$10000 and? ( a> 4 3 << - @ ; )
	a> 3 3 << - @ ;
	
:getval | v val -- v v2
	$100000 and? ( $ffff and ; )
	$ffff and swap ;
	
:robot.0 | a --
	>a
	a@ dup dtime + a!+ 
	a@+ dup 16 >> swap $ffff and rot |  add cnt msec
	animcntm + sprplayer | frame 'sprites
	a@+ 16 >> 32 -	-64 <? ( 3drop 0 ; ) 1064 >? ( 3drop 0 ; )
	a@+ 16 >> 64 -	-64 <? ( 4drop 0 ; ) 664 >? ( 4drop 0 ; ) 
	
	over 32 + over 32 + cursor!!
	
	tsdraw 
	a@+ a> 24 - +!	| vx
	a@+ a> 24 - +!	| vy
	
	a@ getcoor 16 >> 
	swap getval 
	<? ( drop ; ) drop
|	a@ 32 >> $f and  | cambia a estado 0..15
	| |-------------cambiaestado
|	$80005 a> 5 3 << - !
|	a> 2 3 << - dup @ neg swap !
|	a> 1 3 << - dup @ neg swap !	
	;
|================================	

		| anim 	| xp	|dxp 	| yp	|dyp	| vx	|dvx	| vy	|dvy 	| limit | dlimit | test
#res1 [ $10005 -32.0	0.0		512.0 	50.0 	0.5 	0.8 	0.0 	0.0 	350 60 $110000 ]
#res2 [ $10005 -32.0	0.0 	150.0 	50.0	0.5 	0.8 	0.0 	0.0 	350 60 $110000 ]
#res3 [ $80005 1024.0	0.0 	512.0 	50.0	-0.5 	-0.8 	0.0 	0.0 	600 60 $010000 ]
#res4 [ $80005 1024.0	0.0 	150.0 	50.0	-0.5 	-0.8 	0.0 	0.0 	600 60 $010000 ]
#res5 [ $10005 380.0	40.0 	0.0 	0.0		0.0 	0.0 	0.5 	0.8 	150 60 $100000 ]
#res6 [ $10005 580.0	40.0 	0.0 	0.0		0.0 	0.0 	0.5 	0.8 	150 60 $100000 ]
#res7 [ $10005 380.0	40.0 	664.0 	0.0		0.0 	0.0 	-0.5 	-0.8 	500 60 $000000 ]
#res8 [ $10005 580.0	40.0 	664.0 	0.0		0.0 	0.0 	-0.5 	-0.8 	500 60 $000000 ]
	
#modes 'robot.1 'robot.2

:+objg	| adr --
	|1 randmax 3 << 'modes + @ 
	'robot.1
	'obj p!+ >a >b
	0 a!+
	db@+ a!+
	db@+ db@+ randmax + a!+
	db@+ db@+ randmax + a!+
	db@+ db@+ randmax + a!+
	db@+ db@+ randmax + a!+
	db@+ db@+ randmax + db@ or a!
	;

:+objr
	8 randmax 6 3 << * 'res1 + +objg ;

|-------------------------------------------
	
| msec addani|cntani x y vx vy lim|xy dest
:vehiculo | a --
	>a
	a@ dup dtime + a!+ 
	a@+ dup 16 >> swap $ffff and rot |  add cnt msec
	animcntm + sprplayer | frame 'sprites
	a@+ 16 >> 32 -	-64 <? ( 3drop 0 ; ) 1064 >? ( 3drop 0 ; )
	a@+ 16 >> 64 -	-64 <? ( 4drop 0 ; ) 664 >? ( 4drop 0 ; ) 
	over 32 + over 32 + cursor!! >r
	tsdraw 
	a@+ a> 24 - +!	| vx
	a@+ a> 24 - +!	| vy
	r> drop
	;

:+vehi	| adr --
	'vehiculo 'obj p!+ >a >b
	0 a!+
	db@+ a!+
	db@+ db@+ randmax + a!+
	db@+ db@+ randmax + a!+
	db@+ db@+ randmax + a!+
	db@+ db@+ randmax + a!+
	db@+ db@+ randmax + db@ or a!
	;

		| anim 	| xp	|dxp 	| yp	|dyp	| vx	|dvx	| vy	|dvy 	| limit | dlimit | test
#veh1 [ $120004  -32.0 	0.0 	408.0 	90.0	0.7 	1.0 	0.0 	0.0 	1080 60 $110000 ]
#veh2 [ $e0004	1080.0 	0.0 	210.0 	100.0	-0.7 	-1.0 	0.0 	0.0 	-80 60 $100000 ]

:+vehir
	2 randmax 6 3 << * 'veh1 + 
	+vehi ;
	
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
	
|============================== player
#btnpad

:player
	16 + >a semaforoestado sprsemaforo 
	a@+ 16 >> 48 - a@+ 16 >> 96 - tsdraw 
	-8 a+
	btnpad
	%1000 and? ( a@ 2.0 - a! )
	%100 and? ( a@ 2.0 + a! )
	-8 a+
	%10 and? ( a@ 2.0 - a! )
	%1 and? ( a@ 2.0 + a! )
	drop
	;

:+pla | x y --
	'player 'obj p!+ >a 0 a!+ 0 a!+  
	swap 16 << a!+ 16 << a! ;
	
:playerkeys
	<up> =? ( btnpad %1000 or 'btnpad ! )
	<dn> =? ( btnpad %100 or 'btnpad ! )
	<le> =? ( btnpad %10 or 'btnpad ! )
	<ri> =? ( btnpad %1 or 'btnpad ! )
	>up< =? ( btnpad %1000 not and 'btnpad ! )
	>dn< =? ( btnpad %100 not and 'btnpad ! )
	>le< =? ( btnpad %10 not and 'btnpad ! )
	>ri< =? ( btnpad %1 not and 'btnpad ! )
	;
	
|==============================
	
:usuario
	SDLkey 
	>esc< =? ( exit )
	
|	playerkeys

	<f1> =? ( +objr )
	<f2> =? ( +vehir )

|	<up> =? ( semaforoestado 1 + 3 =? ( 0 nip ) 'semaforoestado ! ) 
	
	drop 
	;


:debug	
	.cls "list:" .println
	[ dup 8 + >a a@+ a@+ a@+ "%d %d %d" .println ; ] 'obj p.mapv ;
	
:jugando
	0 0 mapajuego SDLimage

	4 'obj p.sort
	time.delta
	'obj p.drawo
	'fx p.draw
	

	|debug	
	2 2 bat cursor "%h" sprint bprint
	
	SDLredraw
	usuario
	;
	
:reset
	'obj p.clear
	'fx p.clear
	
	354 48 + 100 96 + +sema
	546 48 + 426 96 + +sema
|	400 300 +pla
	| lamparas de luz
	time.start

	'robot.1 'mode.run !
	'robot.2 'mode.com !
	;

:main
	"r3sdl" 1024 600 SDLinit
	bfont1 
	|SDLfull
	
	"r3\j2022\vial\mapa.png" loadimg 'mapajuego !
	
	64 64 "r3\j2022\vial\robot.png" loadts 'sprplayer !
	96 96 "r3\j2022\vial\semaforo.png" loadts 'sprsemaforo !
	
	1000 'obj p.ini
	1000 'fx p.ini
	reset
	
	'jugando SDLshow

	SDLquit ;	
	
: main ;