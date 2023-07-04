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

|--------------- Jugador
:jugador
	x int. y int. 2.0 	
	msec 7 >> $1 and 
	sprites sspritez 
	xv 'x +! yv 'y +! ;
	;

|-------------- Disparo	
:alien | adr –
	>a
	a@+ int. a@+ int. | x y , convertidos a enteros
	a@+ | zoom
	a@+ | nro de sprite
	a@+ | hoja de sprite
	sspritez ;


:+alien
	'alien 'listalien p!+ >a
	640.0 randmax a!+ | x
	480.0 randmax a!+ | y
	2.0 randmax 1.0 + a!+
	12 randmax a!+
	sprites a!+ 
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
	jugador	

	10 8 bat puntos "puntos:%d" sprint bprint
	10 24 bat vidas "vidas:%d" sprint bprint
	SDLredraw

	SDLkey 
	>esc< =? ( exit )
	<le> =? ( -1.0 'xv ! ) >le< =? ( 0 'xv ! )
	<ri> =? ( 1.0 'xv ! ) >ri< =? ( 0 'xv ! )
	<f1> =? ( +alien )
	drop ;

:main
	"r3sdl" 640 480 SDLinit
	bfont1 
	16 16 "media/img/manual.png" ssload 'sprites !			
	llenaestrellas
	200 'listalien p.ini
	timer<
	'juego SDLshow
	SDLquit ;	
	
: main ;
