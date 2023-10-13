| Animation example
^r3/lib/rand.r3
^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3
^r3/util/arr16.r3
^r3/win/sdl2mixer.r3
^r3/util/sdlgui.r3

#arcoiris 0 0 
#frutas 0 0
#estrellas 0 0

#sndcomiento
#musmenu
#musjuego

#tsguy	| dibujo
#xp 200.0 #yp 400.0		| posicion
|#xv #yv		| velocidad
#animacion
#comiendo

#puntos 0

:objsprite | adr -- adr
	dup >a
	a@+ int. a@+ int.	| x y
	a@+ dup 32 >> swap $ffffffff and | rot zoom
	a@ timer+ dup a!+ nanim 			| n
	a@+ sspriterz
	dup 40 + @ over +!
	dup 48 + @ over 8 + +!
	dup 56 + @ over 16 + +!
	;

:gatovuela
	7 6 1 vci>anim 'animacion !	;
	
:gatocome
	comiendo 1? ( drop ; ) drop
	60 'comiendo !
	7 7 7 vci>anim 'animacion !	;

	
|--------------- ARCOIRIS	
|disparo
| x y ang anim ss vx vy ar
| 0 8 16  24   32 40 48 56
	
:estela | v -- 
	objsprite
	|..... remove when outside screen
	dup @+ dup -17.0 827.0 between -? ( 4drop 0 ; ) drop
	swap @ dup -200.0 616.0 between -? ( 4drop 0 ; ) drop
	2drop
	drop
	;

#alterna 
:+estela
	'estela 'arcoiris p!+ >a 
	160.0 a!+ yp 10.0 + alterna + a!+	| x y 
	1.0 a!+	| ang zoom
	0 0 0 vci>anim | vel cnt ini 
	a!+	tsguy a!+			| anim sheet
	-2.0 a!+ 0.0 a!+ 	| vx vy
	0 a!			| vrz
	alterna 0? ( drop 4.0 'alterna ! ; ) drop
	0 'alterna !
	;
	
#ce
:+est
	1 'ce +!
	ce 7 <? ( drop ; ) drop
	0 'ce !
	+estela ;

:comefruta
	0 gatocome 1 'puntos +!
	sndcomiento sndplay
	;
	
|--------------- FRUTAS
:fruta | v -- 
	objsprite
	|..... remove when outside screen
	dup @+ dup -17.0 827.0 between -? ( 4drop 0 ; ) drop
	swap @ dup -200.0 616.0 between -? ( 4drop 0 ; ) drop
	yp - swap xp - distfast
	50.0 <? ( 2drop comefruta ; ) drop
	drop
	;

:+fruta | fruta y --
	'fruta 'frutas p!+ >a 
	810.0 a!+
	|500.0 randmax 100.0 +
	| YYY
	a!+	| x y 
	1.0 a!+	| ang zoom
	0 0 
	|8 randmax 
	rot 16 + | fruta
	vci>anim | vel cnt ini 
	a!+	tsguy a!+			| anim sheet
	1.0 randmax neg 1.5 - a!+
	|2.0 randmax 1.0 - 
	0
	a!+ 	| vx vy
	0.01 randmax 0.005 - 32 << a!			| vrz
	;

	
:+frutarand
	'fruta 'frutas p!+ >a 
	810.0 a!+
	500.0 randmax 100.0 +
	a!+	| x y 
	1.0 a!+	| ang zoom
	0 0 
	8 randmax 16 +
	vci>anim | vel cnt ini 
	a!+	tsguy a!+			| anim sheet
	1.0 randmax neg 1.5 - a!+
	2.0 randmax 1.0 - a!+ 	| vx vy
	0.01 randmax 0.005 - 32 << a!			| vrz
	;
	
:+fru
	100 randmax 
	0? ( +frutarand )
	drop
	;
	
|-------------------------- estrellas
:estrella | v -- 
	objsprite
	dup @ -30.0 >? ( 2drop ; ) drop 
	830.0 swap !
	; 
	
:+estrella 
	'estrella 'estrellas p!+ >a
	860.0 randmax 30.0 - a!+
	600.0 randmax a!+
	1.0 a!+
	6 3 24 vci>anim 
	rand $fffffffff and or
	a!+
	tsguy a!+
	0.5 randmax 1.0 - a!+
	0 a!+ 
	0 a!+ ;
	
|--------------- JUEGO	
:jugador

	xp int. yp int. 2.0 
	animacion timer+ dup 'animacion ! nanim 
	tsguy sspritez	
|	xv 'xp +! yv 'yp +!
	msec 3 << sin 250 * 300.0 + 'yp !

	comiendo 0? ( drop ; ) 
	1 -
	0? ( gatovuela )
	'comiendo !
	;

:puntaje
	$0 ttcolor
	314 14 ttat
	puntos "%d" ttprint
	$FFFFFF ttcolor
	310 10 ttat
	puntos "%d" ttprint
	;
	
:juego
	$252850 SDLcls
	timer.
	'estrellas p.draw
	'arcoiris p.draw	
	jugador
	'frutas p.draw
	
	puntaje
	SDLredraw

	+est
|	+fru
		
	SDLkey
	>esc< =? ( exit )
	<a> =? ( 1 100.0 +fruta ) 
	<s> =? ( 2 300.0 +fruta ) 
	<d>  =? ( 3 500.0 +fruta ) 
|	<w> =? ( -2.0 'yv ! )
|	>w< =? ( 0 'yv ! )
|	<s> =? ( 2.0 'yv ! )
|	>s< =? ( 0 'yv ! )	
	drop 
	;
	

:juegoreset
	'arcoiris p.clear
	'frutas p.clear
	timer<
	7 3 1 vci>anim 'animacion !
	;

:jugar
	juegoreset
|	32 Mix_VolumeMusic 	
|	musjuego -1 mix_playmusic
	'juego SDLshow
|	128 Mix_VolumeMusic 
|	musmenu -1 mix_playmusic 
	;

:menu
	$252850 SDLcls
	Immgui
	timer.
	'estrellas p.draw

	0 100 immat
	800 immwidth
	"Nyan Fruit" immlabelc

	200 300 immat
	400 immwidth
	'jugar "jugar" immbtn
	immdn
	'exit "salir" immbtn

	SDLredraw
	SDLkey
	>esc< =? ( exit )
	<f1> =? ( jugar )
	drop
	;

	
:main
	"r3sdl" 800 600 SDLinit
	64 64 "r3/itinerario/gio/gato.png" ssload 'tsguy !
	"r3/itinerario/gio/Starborn.ttf" 38 ttf_OpenFont immsdL
	"r3/itinerario/gio/comiendo.mp3" mix_loadwav 'sndcomiento !
	"r3/itinerario/gio/Gatito kawaii.mp3" mix_loadmus 'musmenu !
	"r3/itinerario/gio/Nyan Cat.mp3" mix_loadmus 'musjuego !
	50 'arcoiris p.ini
	200 'frutas p.ini
	
	100 'estrellas p.ini
	100 ( 1? +estrella 1 - ) drop
	
|	musmenu -1 mix_playmusic
	'menu SDLshow
	SDLquit ;	
	
: main ;