^r3/win/sdl2gfx.r3
^r3/win/sdl2mixer.r3
^r3/lib/rand.r3
^r3/util/bfont.r3
^r3/util/arr16.r3
^r3/util/varanim.r3
^r3/util/boxtext.r3
^r3/lib/color.r3
^r3/util/sdlgui.r3

#font

#nubes		| hoja de sprites
#explo		| hoja de sprites
#spredif	| hoja de sprites
#spravion
#sprbomba

#sndbomba
#sndgente
#sndexplo
#sndvictoria

#x 500.0 #y 100.0
#vx #vy	| viewport
#puntos
#bombas

#listbom 0 0	| lista de disparos
#listedi 0 0	| lista de edificios
#listfx 0 0 	| fx

|-------- sprite list
:.x 1 ncell+ ;
:.y 2 ncell+ ;
:.r 3 ncell+ ; 
:.a 4 ncell+ ; 
:.ss 5 ncell+ ;
:.vx 6 ncell+ ;
:.vy 7 ncell+ ;

:objsprite | adr -- adr
	dup 8 + >a
	a@+ int. a@+ int.	| x y
	a@+ dup 32 >> swap $ffffffff and 	| rota zoom
	a@ timer+ dup a!+ 	| anima
	nanim a@+ sspriterz
	dup .vx @ over .x +!	| vx
	dup .vy @ over .y +!	| vy
	;

|--------------- fx	
:nube
	objsprite
	dup .x @ -400.0 <? ( 1400.0 pick2 .x ! ) drop
	dup .y @ 200.0 - abs 200.0 >? ( over .vy dup @ neg swap ! ) drop | 200..500
	drop
	;

:+nube	| vx vy n z x y --
	'nube 'listfx p!+ >a 
	swap a!+ a!+	| x y 
	a!+ 
	52 << a!+ nubes a!+
	swap a!+ a!+ ;

:cielo
	30 ( 1? 1 -
		0.5 randmax 0.6 -
		0.1 randmax 0.05 -
		2 randmax 
		1.0 randmax 0.4 + 
		1800.0 randmax 400.0 -
		400.0 randmax 
		+nube
		) drop ;		
		
|----------------------
:edi | a -- a
	objsprite
	dup .x @ -100.0 <? ( 2drop 0 ; ) drop
	drop ;
	
:+edificio | vx vy n z x y --
	'edi 'listedi p!+ >a 
	swap a!+ a!+	| x y 
	a!+ 52 << a!+ 	| w h
	spredif a!+
	swap a!+ a!+ ;	| vx vy

:edificios
	50 randmax 1? ( drop ; ) drop
	-1.0 0 
	0 
	0.8 randmax 0.6 + | zoom
	1100.0 
	50.0 randmax 560.0 +
	+edificio
	;
	
|-------------- Explosion		
:nuke
	objsprite
	dup .a @ canim 25 =? ( 2drop 0 ; )
	2drop
	;
	
:+explo | x y --
	'nuke 'listfx p!+ >a 
	swap a!+ a!+	| x y 
	1.0 a!+ 
	6 26 0 vci>anim a!+ explo a!+
	-1.0 a!+ -0.1 a!+
	|sndexplo SNDPlay
	;
		

|-------------- Disparo	
#hit?
:hit | x y i n p -- x y p
	dup 8 + >a 
	pick4 a@+ -	pick4 a@+ -
	distfast 
	20.0 >? ( drop ; )	drop	| lejos
	dup .a dup
	@ 52 >> $1 and? ( 2drop ; )  | ya roto
	1 + 52 << swap !			| cambia dibujo
	1 'puntos +!
	1 'hit? !
|	10 randmax 1? ( drop ; ) drop
|	sndgente SNDplay | grito de gente
	;
	
:bomba | v -- 
	objsprite
	0.02 over .vy +!		| gravedad
	0.001 32 << over .r +!		| rotacion
	20 randmax 0? ( over .a dup @ $10000000000000 xor swap ! ) drop
	dup .x @ over .y @ 700.0 >? ( 100.0 - +explo drop 0 ; ) 
	0 'hit? !
	'hit 'listedi p.mapv		| choco con edificio
	hit? 1? ( drop 20.0 - +explo drop 0 ; ) drop
	2drop
	drop
	;

#disparodelay

:+disparo
	disparodelay -? ( drop ; ) drop
	-200 'disparodelay ! |200 ms delay
	bombas 0? ( drop ; ) drop
	'bomba 'listbom p!+ >a 
	x 30.0 + a!+ y 40.0 + a!+	| x y 
	1.0 a!+ 0 a!+
	sprbomba a!+			|
	0 a!+ 0.02 a!+ 	| vx vy
	|sndbomba SNDplay
	-1 'bombas +!
	;

:randwind
	vareset
	'x 400.0 randmax 300.0 + x 9 2.0 0.0 +vanim
	'y 200.0 randmax 50.0 + y 9 2.0 0.0 +vanim
	'randwind 2.0 +vexe ;
	
:startwind
	vareset
	'x 550.0 -500.0 3 3.0 0.0 +vanim 
	'y 220.0 -100.0 3 3.0 0.0 +vanim 
	'randwind 3.0 +vexe ;

:endwind
	vareset
	'x 1250.0 x 3 3.0 1.0 +vanim 
	'y -100.0 y 3 3.0 1.0 +vanim 
	'exit 5.0 +vexe ;

|-------------- Jugador
#findejuego
#xant
#xprom

:angulo
	x xant =? ( drop ; ) 
	xant - xprom + 1 >> 'xprom ! x 'xant ! ;

:jugador
	x int. y int. 
	xprom 8 >> 
	spravion SDLspriteR
	angulo
	findejuego 1? ( drop ; ) drop
	bombas 0? ( 1 'findejuego ! endwind ) drop 
	;
	
:hud
	$ffffff ttcolor 
	20 10 ttat bombas "%d" ttprint
	920 10 ttat puntos "%d" ttprint
	;
	
|-------------- Juego
:juego
	immgui 
	timer. vupdate
	deltatime 'disparodelay +!
	$78ADE8 SDLcls
	'listedi p.draw
	'listfx p.draw
	'listbom p.draw	
	jugador	
	edificios
	hud
	SDLredraw
	SDLkey 
	>esc< =? ( exit )
	<esp> =? ( +disparo )
	drop ;

:jugar 
	'listbom p.clear
	'listfx p.clear
	500.0 'x ! 100.0 'y !
	cielo
	0 'puntos ! 
	10 'bombas !
	0 'findejuego !
	startwind |	randwind

	'juego SDLShow ;

|-------------------------------------
#texto>
#texto 
"The world need" 
"more democracy"
" "
"don't worry"
"we have democracy for all"
" "
"Oppenheimer Democracy"
0

:nextt texto> >>0 'texto> ! ;

#colm
#t	
:lines | texto --
	dup 'texto> !
	$ff 'colm !
	vareset
	1.0 't !
	l0count 
	0 ( over <? 
		'colm 0 $ff 5 1.0 t +vanim
		'colm $ff 0 5 1.0 t 2.0 + +vanim
		'nextt t 3.0 + +vexe
		3.0 't +!
		1 + ) 2drop 
	'exit t 1.0 + +vexe 		
	;

:titlestart
	vupdate
	$0 SDLcls
	
	$11 texto>
	300 100 424 400 xywh64 
	$ffffff $0 colm colmix
	font 
	textbox | $vh str box color font --

	SDLredraw	
	SDLkey
	>esc< =? ( exit )
	drop ;

|-------------------------------------
:main
	"od" 1024 600 SDLinit
	
	128 128 "r3/gamejamd/od/explosion.png" ssload 'explo !
	50 20 "r3/gamejamd/od/bomba.png" ssload 'sprbomba !
	"r3/gamejamd/od/b52.png" loadimg 'spravion !
	143 88 "r3/gamejamd/od/nubes.png" ssload 'nubes !
	50 100 "r3/gamejamd/od/edificios.png" ssload 'spredif !
	"media/ttf/roboto-medium.ttf" 48 TTF_OpenFont 'font ! 
	font immSDL
	"r3/gamejamd/od/bomba.mp3" mix_loadWAV 'sndbomba !
	"r3/gamejamd/od/gente.mp3" mix_loadWAV 'sndgente !
	"r3/gamejamd/od/explosion.mp3" mix_loadWAV 'sndexplo !
	"r3/gamejamd/od/victoria.mp3" mix_loadWAV 'sndvictoria !
	$7f vaini
	200 'listbom p.ini
	100 'listedi p.ini
	200 'listfx p.ini
	timer<
	
	'texto lines
|	'titlestart SDLshow
	
	jugar
	SDLquit ;	
	
: main ;
