^r3/win/sdl2gfx.r3
^r3/lib/rand.r3
^r3/util/bfont.r3
^r3/util/arr16.r3

				
#sprites

#puntos 0
#vidas 3

#x 320.0 #y 380.0
#xv 0 #yv 0

#listalien 0 0 | lista de aliens
#listshoot 0 0 | lista de disparos

:objsprite | adr -- adr
	dup >a
	a@+ int. a@+ int.	| x y
	a@+ 				| zoom
	a@ timer+ dup a!+ 	| anima
	nanim a@+ sspritez
	dup 40 + @ over +!		| vx
	dup 48 + @ over 8 + +!	| vy
	;
	
|--------------- Jugador
:jugador
	x int. y int. 2.0 	
	msec 7 >> $1 and 
	sprites sspritez 
	xv 'x +! yv 'y +! ;
	
|	xa xd - abs 16.0 >? ( drop ; ) drop
|	ya yd - abs 8.0 >? ( drop ; ) drop
|	+punto 
	;

:perdio?
|	xa x - abs 16.0 >? ( drop ; ) drop
|	ya y - abs 16.0 >? ( drop ; ) drop
	-1 'vidas +!
	vidas 0? ( exit ) drop
	320.0 'x ! 
	380.0 'y !
	;
	
|-------------- Disparo	
:bala | v -- 
	objsprite

	dup @ |-20.0 <? ( 2drop 0 ; ) 660.0 >? ( 2drop 0 ; ) 
	over 8 + @ -20.0 <? ( 3drop 0 ; ) |500.0 >? ( 3drop 0 ; )
	2drop	
|	1 'hit !
|	dup @+ dup -17.0 817.0 between -? ( 4drop 0 ; ) drop
|	swap @ dup -200.0 616.0 between -? ( 4drop 0 ; ) drop
|	'choque 'enemis p.mapv | 'vector list --	
|	2drop
|	hit 0? ( nip ; ) drop
	drop
	;

:+disparo
	'bala 'listshoot p!+ >a 
	x a!+ y 16.0 - a!+	| x y 
	1.0 a!+	| zoom
	8 2 10 vci>anim | vel cnt ini 
	a!+ sprites a!+	| anim sheet
	0 a!+ -3.0 a!+ 	| vx vy
	;
	
|-------------- Alien	
:alien | v -- 
	objsprite	
	
	dup @ x - 
	over 8 + @ 500.0 >? ( 3drop 0 ; ) 
	y - distfast
|	30.0 <? ( +explon ) 
	drop
	drop
	;

:+alien
	'alien 'listalien p!+ >a 
	500.0 randmax 70.0 + a!+ 
	-16.0 a!+
	2.0 a!+	| zoom
	7 4 2 vci>anim | vel cnt ini 
	a!+	sprites a!+			| anim sheet
	2.0 randmax 1.0 - 
	a!+ 2.0 a!+ 	| vx vy
	;

|------------- fondo de estrellas
#buffer * 1024			| lugar para guardar las coordenadas
#buffer> 'buffer

:+estrella | x y –
	buffer> w!+ w!+ 'buffer> ! ;

:.estrellas
	$ffffff sdlColor
	'buffer ( buffer> <?
		w@+ swap
		over 1 + sh >? ( 0 nip ) 
		over 2 - w!
		w@+ rot
		SDLPoint ) drop ;

:llenaestrellas
	256 ( 1? 1 -
		sw randmax sh randmax +estrella
		) drop ;

|-------------- Juego
:juego
	0 SDLcls
	timer.
	.estrellas 
	'listalien p.draw
	'listshoot p.draw
	jugador	

	10 8 bat puntos "puntos:%d" sprint bprint
	10 24 bat vidas "vidas:%d" sprint bprint
	SDLredraw

	SDLkey 
	>esc< =? ( exit )
	<le> =? ( -1.0 'xv ! ) >le< =? ( 0 'xv ! )
	<ri> =? ( 1.0 'xv ! ) >ri< =? ( 0 'xv ! )
	<esp> =? ( +disparo )
	<f1> =? ( +alien )
	drop ;

:main
	"r3sdl" 640 480 SDLinit
	bfont1 
	16 16 "media/img/manual.png" ssload 'sprites !			
	llenaestrellas
	200 'listalien p.ini
	200 'listshoot p.ini
	timer<
	'juego SDLshow
	SDLquit ;	
	
: main ;
