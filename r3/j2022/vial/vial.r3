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
	
|--------------------------------
:robot1 | a --
	>a a@ 0.1 + a!+ 
	5 animcnt 8 +
	sprplayer 
	a@ 
	dup 1 - 
	-64 <? ( 4drop 0 ; ) a!+
	a@+ 
	tsdraw
	;
	
:+robot1 | x y --
	'robot1 'fx p!+ >a 0 a!+ swap a!+ a!
	3 'fx p.sort 
	;

|--------------------------------
:robot2 | a --
	>a a@ 0.1 + a!+ 
	5 animcnt 0 +
	sprplayer 
	a@ 
	dup 1 + 1024 >? ( 4drop 0 ; ) a!+
	a@+ 
	tsdraw
	;
	
:+robot2 | x y --
	'robot2 'fx p!+ >a 0 a!+ swap a!+ a!
	3 'fx p.sort ;

|--------------------------------
:robot3 | a --
	>a a@ 0.1 + a!+ 
	4 animcnt 14 +
	sprplayer 
	a@ 
	dup 1 - -64 <? ( 4drop 0 ; ) a!+
	a@+ 
	tsdraw
	;
	
:+robot3 | x y --
	'robot3 'fx p!+ >a 0 a!+ swap a!+ a!
	3 'fx p.sort ;
|--------------------------------
:robot4 | a --
	>a a@ 0.1 + a!+ 
	4 animcnt 18 +
	sprplayer 
	a@ 
	dup 1 + 1024 >? ( 4drop 0 ; ) a!+
	a@+ 
	tsdraw
	;
	
:+robot4 | x y --
	'robot4 'fx p!+ >a 0 a!+ swap a!+ a!
	3 'fx p.sort ;
	
	
|--------------------------------

:teclado
	SDLkey 
	>esc< =? ( exit )
	
	<f1> =? ( 1024 30 randmax 100 + +robot1 ) 
	<f2> =? ( -64 30 randmax 100 + +robot2 ) 

	<f3> =? ( 1024 120 randmax 144 + +robot3 ) 
	<f4> =? ( -64 120 randmax 144 + +robot4 ) 


	<up> =? ( semaforoestado 1 + 3 =? ( 0 nip ) 'semaforoestado ! ) 
	
	drop 
	;

:pantalla
	0 0 mapajuego SDLimage

	semaforoestado sprsemaforo 354 100 tsdraw |
	semaforoestado sprsemaforo 546 426 tsdraw |
	'fx p.drawo

	;
	
:demo
	0 SDLcls
	
	$039be5 SDLcls

	pantalla
	
	2 2 bat 
|	hitene "%h" sprint bprint
	
	SDLredraw
	teclado 
	;

:main
	
	"r3sdl" 1024 600 SDLinit
	bfont1 
	|SDLfull
	
	"r3\j2022\vial\mapa.png" loadimg 'mapajuego !
	
	64 64 "r3\j2022\vial\robot.png" loadts 'sprplayer !
	96 96 "r3\j2022\vial\semaforo.png" loadts 'sprsemaforo !
	
	
	1000 'fx p.ini
	
	'demo SDLshow

	SDLquit ;	
	
: main ;