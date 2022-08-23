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
	
|-------------- cambio de estado
:espera! 

	-6 3 << a> + !
	;
	
:sigue! | nro --
	;


:getcoor
	$10000 and? ( a> 4 3 << - @ ; )
	a> 3 3 << - @ ;
	
:getval | v val -- v v2
	$100000 and? ( $ffff and ; )
	$ffff and swap ;
	
|-------------- objeto animado	
| msec addani|cntani x y vx vy lim|xy dest
:robot | a --
	>a
	a@ dup dtime + a!+ 
	a@+ dup 16 >> swap $ffff and rot |  add cnt msec
	animcntm + sprplayer | frame 'sprites
	a@+ 16 >> 32 -	-64 <? ( 3drop 0 ; ) 1064 >? ( 3drop 0 ; )
	a@+ 16 >> 64 -	-64 <? ( 4drop 0 ; ) 664 >? ( 4drop 0 ; ) 
	tsdraw 
	a@+ a> 24 - +!	| vx
	a@+ a> 24 - +!	| vy
	
	a@ getcoor 16 >> 
	swap getval 
	<? ( drop ; ) drop
|	a@ 32 >> $f and  | cambia a estado 0..15
	
	$80005 a> 5 3 << - !
	a> 2 3 << - dup @ neg swap !
	a> 1 3 << - dup @ neg swap !	
	;
	
#res1 [ $10005 | anim
-32.0 0.0 	| xp
512.0 50.0	| yp
0.5 0.8 	| vx
0.0 0.0 	| vy
350 60 $110000 ]
#res2 [ $10005 | anim
-32.0 0.0 	| xp
150.0 50.0	| yp
0.5 0.8 	| vx
0.0 0.0 	| vy
350 60 $110000 ]
#res3 [ $80005 | anim
1024.0 0.0 	| xp
512.0 50.0	| yp
-0.5 -0.8 	| vx
0.0 0.0 	| vy
600 60 $010000 ]
#res4 [ $80005 | anim
1024.0 0.0 	| xp
150.0 50.0	| yp
-0.5 -0.8 	| vx
0.0 0.0 	| vy
600 60 $010000 ]
#res5 [ $10005 | anim
380.0 40.0 	| xp
0.0 0.0		| yp
0.0 0.0 	| vx
0.5 0.8 	| vy
150 60 $100000 ]
#res6 [ $10005 | anim
580.0 40.0 	| xp
0.0 0.0	| yp
0.0 0.0 	| vx
0.5 0.8 	| vy
150 60 $100000 ]
#res7 [ $10005 | anim
380.0 40.0 	| xp
664.0 0.0		| yp
0.0 0.0 	| vx
-0.5 -0.8 	| vy
500 60 $000000 ]
#res8 [ $10005 | anim
580.0 40.0 	| xp
664.0 0.0	| yp
0.0 0.0 	| vx
-0.5 -0.8 	| vy
500 60 $000000 ]
	
:+objg	| adr --
	'robot 'obj p!+ >a >b
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
	
| x yrand 	
#lugarpea [
-32 512
-32 150
380 0
580 0
1056 150
1056 512
580 664
380 664
]	
#waitpea [
340 512
350 150
380 150
580 150
600 150
600 512
570 530
380 530
]

#lugarbic [
-32 400
-32 220
450 0
1056 220
1056 400
450 664
]	

#waitbic [
330 400
330 220
450 140
670 220
670 400
450 590
]

|-------------------------------- semaforo
:sema
	8 + >a semaforoestado sprsemaforo a@+ 48 - a@+ 96 - tsdraw ;

:+sema | x y --
	'sema 'obj p!+ >a 0 a!+ swap a!+ a! ;
	
|--------------------------------

:teclado
	SDLkey 
	>esc< =? ( exit )
	
	<f1> =? ( +objr )
	<f2> =? ( 'res5 +objg )

	<up> =? ( semaforoestado 1 + 3 =? ( 0 nip ) 'semaforoestado ! ) 
	
	drop 
	;


:debug	
	.cls "list:" .println
	[ dup 8 + >a a@+ a@+ a@+ "%d %d %d" .println ; ] 'obj p.mapv ;
	
:jugando
	0 0 mapajuego SDLimage

	|3 'obj p.sort
	time.delta
	'obj p.drawo
	'fx p.draw
	
|	debug	
|	2 2 bat hitene "%h" sprint bprint
	
	SDLredraw
	teclado 
	;
	
:reset
	'obj p.clear
	'fx p.clear
	
	354 48 + 100 96 + +sema
	546 48 + 426 96 + +sema
	| lamparas de luz
	time.start
	
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