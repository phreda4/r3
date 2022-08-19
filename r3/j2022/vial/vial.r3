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

#fx 0 0

#semaforoestado 0


|--------------------------------
:perro | a --
	>a a@ dup 0.1 + a!+ 
	16 >> $3 and 26 + sprplayer 
	a@+ 
	dup 3 - -128 <? ( 4drop 0 ; ) a> 8 - !
	a@+ 
	tsdraw
	;
	
:+perro | x y --
	'perro 'fx p!+ >a 0 a!+ swap a!+ a!
	3 'fx p.sort ;
	

|--------------------------------
:robot1 | a --
	>a a@ dup 0.1 + a!+ 
	16 >> $3 and 26 + sprplayer 
	a@+ 
	dup 3 - -128 <? ( 4drop 0 ; ) a> 8 - !
	a@+ 
	tsdraw
	;
	
:+robot1 | x y --
	'robot1 'fx p!+ >a 0 a!+ swap a!+ a!
	3 'fx p.sort ;

|--------------------------------
:robot2 | a --
	>a a@ dup 0.1 + a!+ 
	16 >> $3 and 26 + sprplayer 
	a@+ 
	dup 3 - -128 <? ( 4drop 0 ; ) a> 8 - !
	a@+ 
	tsdraw
	;
	
:+robot2 | x y --
	'robot1 'fx p!+ >a 0 a!+ swap a!+ a!
	3 'fx p.sort ;
	

|--------------------------------
:autoh | a --
	>a a@ dup 0.1 + a!+ 
	16 >> $3 and 26 + sprplayer 
	a@+ 
	dup 3 - -128 <? ( 4drop 0 ; ) a> 8 - !
	a@+ 
	tsdraw
	;
	
:+autoh | x y --
	'autoh 'fx p!+ >a 0 a!+ swap a!+ a!
	3 'fx p.sort ;

|--------------------------------
:autov | a --
	>a a@ dup 0.1 + a!+ 
	16 >> $3 and 26 + sprplayer 
	a@+ 
	dup 3 - -128 <? ( 4drop 0 ; ) a> 8 - !
	a@+ 
	tsdraw
	;
	
:+autov | x y --
	'autov 'fx p!+ >a 0 a!+ swap a!+ a!
	3 'fx p.sort ;


|--------------------------------
:semaforos
	|semaforoestado
	;
	
|--------------------------------

:teclado
	SDLkey 
	>esc< =? ( exit )
	
	<f1> =? ( 1024 400 randmax 180 + +perro ) 
	<f1> =? ( 1024 400 randmax 180 + +robot1 ) 
	<f1> =? ( 1024 400 randmax 180 + +robot2 ) 
	
	<f1> =? ( 1024 400 randmax 180 + +autov ) 
	<f1> =? ( 1024 400 randmax 180 + +autoh ) 


	
	drop 
	;

:dibujomapa
	0 0 mapajuego SDLimage
	;
	
:demo
	0 SDLcls
	
	$039be5 SDLcls

	dibujomapa
	'fx p.drawo
	semaforos
	
	2 2 bat 
|	hitene "%h" sprint bprint
	
	SDLredraw
	teclado 
	;

:main
	1000 'fx p.ini
	"r3sdl" 1024 600 SDLinit
	bfont1 
	|SDLfull
	
	"r3\j2022\vial\mapa.png" loadimg 'mapajuego !
	
	124 124 "r3\j2022\vial\robot.png" loadts 'sprplayer !
	
	'demo SDLshow

	SDLquit ;	
	
: main ;