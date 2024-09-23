^r3/lib/sdl2gfx.r3
^r3/lib/sdl2mixer.r3
^r3/lib/rand.r3
^r3/util/bfont.r3
^r3/util/arr16.r3
^r3/util/sdlgui.r3
				
#sprites		| hoja de sprites
#snd_shoot		| sonido de disparo
#snd_explode	| sonido de explosion

#puntos 0
#vidas 3

#x 320.0 #y 380.0
#xv 0 #yv 0

#listalien 0 0 | lista de aliens
#listshoot 0 0 | lista de disparos
#listfx 0 0 | fx

|-- sprite list
| x y z a ss vx vy
:.x 1 ncell+ ;
:.y 2 ncell+ ;
:.z 3 ncell+ ;
:.a 4 ncell+ ;
:.ss 5 ncell+ ;
:.vx 6 ncell+ ;
:.vy 7 ncell+ ;

:objsprite | adr -- adr
	dup 8 + >a
	a@+ int. a@+ int.	| x y
	a@+ 				| zoom
	a@ timer+ dup a!+ 	| anima
	anim>N a@+ sspritez
	dup .vx @ over .x +!	| vx
	dup .vy @ over .y +!	| vy
	;

|--------------- fx	
:explosion
	objsprite	
	.a @ anim>N 10 =? ( drop 0 ; ) drop ;

:+explo	| y x --
	'explosion 'listfx p!+ >a 
	swap a!+ a!+	| x y 
	2.0 a!+			| zoom
	6 5 $7f ICS>anim | init cnt scale
	a!+	sprites a!+			| anim sheet
	0 a!+ 0 a!+ 	| vx vy
	snd_explode SNDplay	
	;

|--------------- Jugador
:jugador
	x int. y int. 2.0 	
	msec 7 >> $1 and 
	sprites sspritez 
	xv 'x +! yv 'y +! 
	;

:pierdevida
	-1 'vidas +!
	vidas 0? ( exit ) drop
	320.0 'x ! 380.0 'y !
	;
	
|-------------- Disparo	
#hit
:choque?  | x y i n p -- x y p
	dup 8 + >a 
	pick4 a@+ -	pick4 a@+ -
	distfast 20.0 >? ( drop ; )	drop
	dup 'listalien p.del
	1 'puntos +!
	0 'hit !
	pick4 pick4 +explo
	;
	
:bala | v -- 
	objsprite

	1 'hit !
	dup .x @ |-20.0 <? ( 2drop 0 ; ) 660.0 >? ( 2drop 0 ; ) ; fuera de pantalla
	over .y @ -20.0 <? ( 3drop 0 ; ) |500.0 >? ( 3drop 0 ; ) ; fuera de pantalla
	'choque? 'listalien p.mapv | 'vector list --	
	2drop
	hit 0? ( nip ; ) drop
	drop
	;

:+disparo
	'bala 'listshoot p!+ >a 
	x a!+ y 16.0 - a!+	| x y 
	1.0 a!+	| zoom
	10 2 $7f ICS>anim | init cnt scale	
	a!+ sprites a!+	| anim sheet
	0 a!+ -3.0 a!+ 	| vx vy
	snd_shoot SNDplay	
	;
	
|-------------- Alien	
:alien | v -- 
	objsprite	
	
	dup .x @ x - 
	over .y @ 500.0 >? ( 3drop 0 ; ) | llego abajo?
	y - distfast
	30.0 <? ( pierdevida ) 
	drop
	drop
	;

:+alien
	'alien 'listalien p!+ >a 
	500.0 randmax 70.0 + a!+ 
	-16.0 a!+
	2.0 a!+	| zoom
	2 4 $7f ICS>anim | init cnt scale
	a!+	sprites a!+			| anim sheet
	2.0 randmax 1.0 - 
	a!+ 2.0 a!+ 	| vx vy
	;

:horda
	50 randmax 1? ( drop ; ) drop
	+alien
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
	'listfx p.draw
	jugador	
	horda
	
	10 8 bat puntos "puntos:%d" sprint bprint
	10 24 bat vidas "vidas:%d" sprint bprint
	SDLredraw

	SDLkey 
	>esc< =? ( exit )
	<le> =? ( -1.0 'xv ! ) >le< =? ( 0 'xv ! )
	<ri> =? ( 1.0 'xv ! ) >ri< =? ( 0 'xv ! )
	<esp> =? ( +disparo )
	drop ;

:jugar 
	'listalien p.clear
	'listshoot p.clear
	'listfx p.clear
	0 'puntos ! 3 'vidas !
	320.0 'x ! 380.0 'y !
	'juego SDLShow ;
	
:menu
	0 SDLcls
	timer.
	.estrellas 
	immgui
	
	0 100 immat 
	640 immwidth
	$ffffff 'immcolortex !
	"Xenofobia Extraterrestre" immLabelC
	320 immwidth
	160 300 immat
	
	$7f00 'immcolorbtn !
	'jugar "Jugar" immbtn 
	immdn 
	$7f0000 'immcolorbtn !
	'exit "Salir" immbtn 
	
	SDLredraw

	SDLkey 
	>esc< =? ( exit )
	drop ;
	
:main
	"r3sdl" 640 480 SDLinit
	bfont1 
	16 16 "media/img/manual.png" ssload 'sprites !	
	"media/snd/shoot.mp3" Mix_LoadWAV 'snd_shoot !
	"media/snd/explode.mp3" Mix_LoadWAV 'snd_explode !	
	"media/ttf/Roboto-bold.ttf" 40 TTF_OpenFont immSDL	
	llenaestrellas
	200 'listalien p.ini
	200 'listshoot p.ini
	200 'listfx p.ini
	timer<
	'menu SDLshow
	SDLquit ;	
	
: main ;
