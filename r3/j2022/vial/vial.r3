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

#botrs 0
#botrr 1 2 3 4 5
#botrt 6

#botrb 18 19 20 21

#botls 7
#botlr 8 9 10 11 12
#botlt 13

#botlb 14 15 16 17

:animcnt | cnt -- 0..cnt-1
	msec 55 << 1 >>> 63 *>> ;
	
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
|-------------------------------- estado
| 0 - run
| 1 - wait in
| 2 - cruce ok
| 3 - cruce no ok
|
| recorrido-
|--------------------------------
:robot1 | a --
	>a a@ 0.1 + a!+ 
	5 animcnt 8 +
	sprplayer 
	a@ 32 -
	dup 1 - 
	-64 <? ( 4drop 0 ; ) a!+
	a@+ 64 -
	tsdraw
	;
	
:+robot1 | x y --
	'robot1 'obj p!+ >a 0 a!+ swap a!+ a! ;

|--------------------------------
:robot2 | a --
	>a a@ 0.1 + a!+ 
	5 animcnt 0 +
	sprplayer 
	a@ 
	dup 1 + 1024 >? ( 4drop 0 ; ) a!+
	a@+ 64 -
	tsdraw
	;
	
:+robot2 | x y --
	'robot2 'obj p!+ >a 0 a!+ swap a!+ a! ;

|--------------------------------
:robot3 | a --
	>a a@ 0.1 + a!+ 
	4 animcnt 14 +
	sprplayer 
	a@ 
	dup 1 - -64 <? ( 4drop 0 ; ) a!+
	a@+ 64 -
	tsdraw
	;
	
:+robot3 | x y --
	'robot3 'obj p!+ >a 0 a!+ swap a!+ a! ;
|--------------------------------
:robot4 | a --
	>a a@ 0.1 + a!+ 
	4 animcnt 18 +
	sprplayer 
	a@ 
	dup 1 + 1024 >? ( 4drop 0 ; ) a!+
	a@+ 64 -
	tsdraw
	;
	
:+robot4 | x y --
	'robot4 'obj p!+ >a 0 a!+ swap a!+ a! ;
	

|-------------------------------- semaforo
:sema
	8 + >a semaforoestado sprsemaforo a@+ 48 - a@+ 96 - tsdraw ;

:+sema | x y --
	'sema 'obj p!+ >a 0 a!+ swap a!+ a! ;
	
|--------------------------------

:teclado
	SDLkey 
	>esc< =? ( exit )
	
	<f1> =? ( 1024 30 randmax 164 + +robot1 ) 
	<f2> =? ( -64 30 randmax 164 + +robot2 ) 

	<f3> =? ( 1024 120 randmax 208 + +robot3 ) 
	<f4> =? ( -64 120 randmax 208 + +robot4 ) 

	<up> =? ( semaforoestado 1 + 3 =? ( 0 nip ) 'semaforoestado ! ) 
	
	drop 
	;


:jugando
	0 0 mapajuego SDLimage

	3 'obj p.sort
	'obj p.drawo
	'fx p.draw
	
	2 2 bat 
|	hitene "%h" sprint bprint
	
	SDLredraw
	teclado 
	;
	
:reset
	'obj p.clear
	'fx p.clear
	
	354 48 + 100 96 + +sema
	546 48 + 426 96 + +sema
	| lamparas de luz
	
	
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