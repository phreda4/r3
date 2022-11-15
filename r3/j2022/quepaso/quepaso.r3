
^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3
^r3/win/sdl2mixer.r3

^r3/util/boxtext.r3
^r3/util/tilesheet.r3
^r3/lib/rand.r3
^r3/lib/gui.r3

#simagenes
#stablero
#scursor
#sfin
#spodio
#sf1 #sf2 #sf3
#tu1 #tu2 #tu3
#sbtn1 #sbtn2

#musicini
#musicrun

|----------------------------------------	
#sndfile "correcta.mp3" "incorrecta.mp3" "boton.mp3" 0

#sndlist * 1024

:loadsndfile
	"r3/j2022/quepaso/audio/musinicio.mp3" Mix_LoadMUS 'musicini !
	"r3/j2022/quepaso/audio/musjuego.mp3" Mix_LoadMUS 'musicrun !

	'sndlist >a
	'sndfile ( dup c@ 1? drop
		dup "r3/j2022/quepaso/audio/%s" sprint
		Mix_LoadWAV a!+
		>>0 ) drop ;

:playsnd | n --
	3 << 'sndlist + @ SNDplay ;
	
|----------------------------------------	
	
#fontt
#font
#preguntas

#tiempo
#nropreg 0
#pregunta * 1024

#res1 * 1024
#res2 * 1024
#res3 * 1024
#res4 * 1024

#r1 #r2 #r3 #r4

#cntjug 3
#njug 0 0 0 0
#pjug 0 0 0 0

#jnow
#resusr
#maxjug
#nrojug

#posiciones [ 
580 890
570 700
610 520
640 340
590 180
370 120
170 400
210 560
360 730
430 920 ]

#xresm 800 #yresm 1047

:nposjug | n -- x y
	10 mod 
	3 << 'posiciones +
	d@+ 400 xresm */ 500 + 40 -
	swap 
	d@ 523 yresm */ 180 + 120 - ;
	
:mapascreen
	'pjug >a
	'sf1 >b
	0 ( cntjug <? 
		da@+ da@+ 
		pick2 3 << 'sf1 + @ sdlimage
		1 + ) drop ;

	
:resetjug | n --
	dup 'cntjug !
	'pjug >b
	( 1? 1 - 
		0 nposjug
		swap 32 randmax 16 - +
		swap 32 randmax 16 - +
		swap db!+ db!+
		) drop ;

:avjug | n --
	3 <<
	1 over 'njug + +!
	dup 'pjug + >a
	'njug + @
	dup maxjug max 'maxjug !
	njug 'nrojug !
	nposjug		
	swap 32 randmax 16 - +
	swap 32 randmax 16 - +
	swap da!+ da!+
	;
	

|-------------------------------------------
#mseca

:inireloj
	0 'tiempo !
	msec 'mseca !
	;
	
:reloj
	msec dup mseca - 'tiempo +! 'mseca ! 
	
	tiempo 1000 /
	"%d" sprint
	36 36 $ff0000 fontt
	textline | str x y color font --
	;


|-------------------------------------------
:rswap |
	3 randmax 3 << 'r1 +
	3 randmax 3 << 'r1 +
	dup @ pick2 @ rot ! swap ! ;
	
:mixres
	'res1 'r1 ! 'res2 'r2 ! 'res3 'r3 ! 'res4 'r4 !
	21 ( 1? rswap 1 - ) drop ;
	
:cpypreg |
	preguntas
	nropreg dup 2 << + | * 5
	( 1? 1 - swap >>cr trim swap ) drop
	dup 'pregunta strcpyln
	>>cr trim dup 'res1 strcpyln
	>>cr trim dup 'res2 strcpyln
	>>cr trim dup 'res3 strcpyln
	>>cr trim dup 'res4 strcpyln
	drop 
	mixres 
	inireloj
|	3 playsnd
	;

	
|-------------------------------------------

:boton | 'vecor "text" -- size
	2over 2over guibox
	SDLb SDLx SDLy guiIn	
	$ffffff  [  $00ff00 nip ; ] guiI
	SDLColor
	2over 2over SDLRect	
	xywh64 
	$11 rot rot $0 font textbox 
	onCLick ;

| 483,143
:btnn | 'vec "text" -- 
	2dup 288 65 guibox 
	sdlb sdlx sdly guiIn
	'sbtn1 [ 8 + rot 4 + rot 4 + rot ; ] guiI
	@ pick2 pick2 rot SDLimage
	280 74 xywh64
	$11 rot rot $0 font textbox 
	onCLick ;
	
:jugando
	gui
	$0 SDLcls
	0 0 stablero sdlimage
	
	mapascreen
	'pjug jnow 3 << + >a
	da@+ da@+ jnow 3 << 'sf1 + @ sdlimage

	$11 'pregunta 370 22 870 136 xywh64 $00 fontt textbox | $vh str box color font	
	
	970 550 jnow 3 << 'tu1 + @ sdlimage

	[ 0 'resusr ! exit ; ] r1 25 305 btnn
	[ 1 'resusr ! exit ; ] r2 25 400 btnn
	[ 2 'resusr ! exit ; ] r3 25 495 btnn
	[ 3 'resusr ! exit ; ] r4 25 590 btnn

	reloj

	sdlx sdly scursor SDLimage
	SDLredraw

	SDLkey 
	>esc< =? ( exit ) | terminar siempre
	drop 
	;

|---------------------------------
#col0 "Verde"
#col1 "Naranja"
#col2 "Celeste"
#lcol col0 col1 col2
#ccol $42A30A $F68E1F $13BFC1

| 109X139
:ganador
	gui
	$0 SDLcls
	0 0 spodio sdlimage
	
	170 300 
	msec 4 >> $3f and +
	218 288 nrojug 3 << 'sf1 + @ sdlimages

	$11
	nrojug 3 << 'lcol + @
	400 490 500 140 xywh64
	nrojug 3 << 'ccol + @ 8 <<
	fontt textbox 

	900 300 
	msec 4 >> $3f and +
	218 288 nrojug 3 << 'sf1 + @ sdlimages

	sdlx sdly scursor SDLimage

	SDLredraw

	SDLkey 
	>esc< =? ( exit ) | terminar siempre
	<f1> =? ( nrojug 1 + 3 mod 'nrojug ! )
	drop 
	;
	
|----------------------------------
:respuestaOK
	jnow avjug
	0 playsnd 
	;

:respuestaNO
	1 playsnd
	;
	
:respuesta	
	resusr 3 << 'r1 + @ 'res1 =? ( drop respuestaOK ; ) drop
	respuestaNO
	;
	
:jugar
	cntjug resetjug
	0 'jnow !
	0 'maxjug !

	musicrun -1 Mix_PlayMusic

	( maxjug 10 <? drop
		'jugando SDLshow
	
		respuesta	
		1 'nropreg +! cpypreg
		jnow 1 + cntjug mod 'jnow ! 
	
		) drop 
		
	'ganador SDLshow	
	;

:jcolor | n -- color
	cntjug >? ( drop $333333 ; ) drop $ffffff ;
	
:menuprincipal
	gui
	$0 SDLcls

	$11 "Preguntas de San Cayetano"
	0 10 1280 100 xywh64 
	$ffffff fontt textbox

	$11 cntjug "%d jugadores" sprint
	0 80 1280 80 xywh64 
	$ffffff fontt textbox
	

	[ jugar 2 playsnd ; ] "Jugar" 400 640 160 60 boton
	[ exit 2 playsnd ; ] "Salir" 600 640 160 60 boton
	
	sdlx sdly scursor SDLimage
	
	SDLredraw

	SDLkey 
	>esc< =? ( exit )
	drop 
	;
	
:inicio
	ttf_init
	"r3/j2022/quepaso/font/RobotoCondensed-Bold.ttf" 50 TTF_OpenFont 'fontt !	
	"r3/j2022/quepaso/font/RobotoCondensed-Regular.ttf" 26 TTF_OpenFont 'font !	
	
	"r3/j2022/quepaso/img/cursor.png" loadimg 'scursor !	
	"r3/j2022/quepaso/img/tablero.png" loadimg 'stablero !
	"r3/j2022/quepaso/img/fin.png" loadimg 'sfin !
	"r3/j2022/quepaso/img/podio.png" loadimg 'spodio !
	
	"r3/j2022/quepaso/img/ficha1.png" loadimg 'sf1 !
	"r3/j2022/quepaso/img/ficha2.png" loadimg 'sf2 !
	"r3/j2022/quepaso/img/ficha3.png" loadimg 'sf3 !
	
	"r3/j2022/quepaso/img/turno1.png" loadimg 'tu1 !
	"r3/j2022/quepaso/img/turno2.png" loadimg 'tu2 !
	"r3/j2022/quepaso/img/turno3.png" loadimg 'tu3 !

	"r3/j2022/quepaso/img/btn1.png" loadimg 'sbtn1 !
	"r3/j2022/quepaso/img/btn2.png" loadimg 'sbtn2 !
	
	SNDInit
	loadsndfile
	
	here dup 'preguntas !
	"r3/j2022/quepaso/preguntas.txt" load 
	0 swap c!+ 'here !

	0 'nropreg !
	cpypreg
	
	;
	
:main
	"r3sdl" 1280 720 SDLinit
	|SDLfull
	inicio
	0 SDL_ShowCursor

	musicini -1 Mix_PlayMusic
	
	'menuprincipal SDLshow 
|	jugar
|0 'nrojug ! 'ganador SDLshow
	
	SDLquit ;	
	
: main ;


