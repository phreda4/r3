^r3/lib/rand.r3
^r3/win/sdl2gfx.r3
^r3/util/arr16.r3
^r3/util/sdlgui.r3
^r3/win/sdl2mixer.r3

#sprnave	| dibujo
#aninave
#xp 100.0 #yp 400.0		| posicion
#xv #yv		| velocidad

#sprene
#sprdis
#sprislas

#puntos 0

#musicamenu
#musicaj
#sonidodis
#explosionx

#disparos 0 0 
#enemigos 0 0
#fondos 0 0
#fx 0 0
	
| x y ang anim ss vx vy ar
| 0 8 16  24   32 40 48 56

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

|------- explosion
:explosion
	objsprite	
	24 + @ nanim 20 =? ( drop 0 ; )
	drop
	;

:+fx	| y x --
	'explosion 'fx p!+ >a 
	swap a!+ a!+	| x y 
	2.0 a!+	| ang zoom
	6 19 2 vci>anim | vel cnt ini 
	a!+	sprene a!+			| anim sheet
	0 a!+ 0 a!+ 	| vx vy
	0.01 randmax 0.005 - 32 << 
	-0.01 $ffffffff and or
	a!			| vrz
	;
	
|--------------------
|disparo
	
#hit
:choque  | x y i n p -- x y p
	dup 8 + >a 
	pick4 a@+ -	pick4 a@+ -
	distfast 20.0 >? ( drop ; )	drop
	dup 8 + @+ swap @ +fx
	dup 'enemigos p.del
	1 'puntos +!
|	1 playsnd
	0 'hit !
	;
	
:bala | v -- 
	objsprite
	
	1 'hit !
	dup @+ dup -17.0 817.0 between -? ( 4drop 0 ; ) drop
	swap @ dup -200.0 616.0 between -? ( 4drop 0 ; ) drop
	'choque 'enemigos p.mapv | 'vector list --	
	2drop
	hit 0? ( nip ; ) drop
	drop
	;

:+disparo
	'bala 'disparos p!+ >a 
	xp 40.0 + a!+ yp 3.0 + a!+	| x y 
	2.0 a!+	| ang zoom
	9 4 0 vci>anim | vel cnt ini 
	a!+	sprdis a!+			| anim sheet
	3.0 a!+ 0 a!+ 	| vx vy
	0 a!			| vrz
	sonidodis sndplay
	;

|--------------------- ALIEN
:alien | v -- 
	objsprite
	|..... remove when outside screen
	dup @+ dup -17.0 827.0 between -? ( 4drop 0 ; ) drop
	swap @ dup -200.0 616.0 between -? ( 4drop 0 ; ) drop
	yp - swap xp - distfast
	30.0 <? ( exit ) drop
	drop
	;

:+marciano
	'alien 'enemigos p!+ >a 
	820.0 a!+
	400.0 randmax 100.0 + a!+  |alien  x y 
	2.0 a!+	| ang zoom
	7 2 0 vci>anim | vel cnt ini 
	a!+	sprene a!+			| anim sheet
	0.5 randmax 2.0 - a!+ 
	0.2 randmax 0.1 - a!+ 	| vx vy
	0 a!		
	;

:horda
	50 randmax 1? ( drop ; ) drop
	+marciano
	;

|---------- ISLA y SOMBRAS
:isla
	objsprite	
	|..... remove when outside screen
	dup @ -192.0 <? ( 2drop 0 ; ) drop
	drop
	;

:+isla
	'isla 'fondos p!+ >a 
	800.0 192.0 + a!+	| x
	600.0 randmax a!+  	| y 
	4 randmax 0.25 * 32 <<	| rotacion
	3.0 or a!+			| zoom
	0 0 4 randmax		| animacion nro sprite
	vci>anim | vel cnt ini 
	a!+ sprislas a!+	| anim sheet
	-0.6 a!+ 			| vx
	0 a!+ 0 a!			| vy vr
	;
	
#xisla 0
:fondo
	$0000FF SDLcls
	'fondos p.draw
	xisla 1? ( -1 'xisla +! drop ; ) drop
	40 randmax 1? ( drop ; ) drop
	+isla
	400 'xisla !
	;
	
:jugador
	xv 'xp +!
	yv 'yp +!
	
	xp int. yp int. 
	2.0
	aninave timer+ dup 'aninave ! nanim
	sprnave
	sspritez 
	
	SDLkey
	<a> =? ( -1.0 'xv ! )	>a< =? ( 0 'xv ! )
	<d> =? ( 1.0 'xv ! )	>d< =? ( 0 'xv ! )	
	<w> =? ( -1.0 'yv ! )	>w< =? ( 0 'yv ! )
	<s> =? ( 1.0 'yv ! )	>s< =? ( 0 'yv ! )
	<esp> =? ( +disparo )
	>esc< =? ( exit )
	drop ;

	
:juego
	timer.
	horda
	
	fondo
	'disparos p.draw
	jugador
	'enemigos p.draw
	'fx p.draw
	$0 ttcolor
	14 14 ttat
	puntos "%d" ttprint
	$ffffff ttcolor
	10 10 ttat
	puntos "%d" ttprint
	
	SDLredraw
	;
	
:jugar
	'juego sdlshow
;
:menu
	0 sdlcls
	immgui | ini INMGUI
	
	fondo
	800 immwidth
	$ffffff 'immcolortex !	
	
	120 50 immat
	"WAR FOR FREEDOM" immlabel
	
	200 300 immat
	400 immwidth
	
	'jugar "jugar" immbtn
	immdn
	'exit "salir" immbtn
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	drop
;

:main
	"r3sdl" 800 600 SDLinit
	32 32 "r3/itinerario/viggo/sana.png" ssload 'sprnave !
	32 32 "r3/itinerario/viggo/nave enemigo.png" ssload 'sprene !
	32 32 "r3/itinerario/viggo/disparo.png" ssload 'sprdis !
	128 128 "r3/itinerario/viggo/islas.png" ssload 'sprislas !
	"r3/itinerario/viggo/musica menu.mp3" mix_loadmus 'musicaj !
	"r3/itinerario/viggo/musica.mp3" mix_loadmus 'musicamenu !
	"r3/itinerario/viggo/disparo.mp3" mix_loadwav 'sonidodis !
	"r3/itinerario/viggo/explosion.mp3" mix_loadwav 'explosionx !
	"r3/itinerario/viggo/Revamped.otf" 50 TTF_OpenFont immSDL
	8 3 0 vci>anim 'aninave !
	timer<
	100 'enemigos p.ini
	100 'disparos p.ini
	100 'fondos p.ini
	100 'fx p.ini	
	musicamenu -1 mix_playmusic
	'menu SDLshow
	SDLquit ;	
	
: main ;