
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

|----------------------------------------	
#sndfile "correcta.mp3" "incorrecta.mp3" "boton.mp3" 0

#sndlist * 1024

:loadsndfile
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

#cntjug 2
#njug 0 0 0 0 0 0 0 0
#pjug 0 0 0 0 0 0 0 0

#njug1 * 32
#njug2 * 32
#njug3 * 32
#njug4 * 32

#jnow
#resusr
#maxjug

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
	d@+ 400 xresm */ 500 + 32 -
	swap 
	d@ 523 yresm */ 180 + 32 - ;
	
:mapascreen
	'pjug >a
	cntjug ( 1? 1-
		dup simagenes da@+ da@+ tsdraw
		) drop ;

:resetname
	"Jugador 1" 'njug1 strcpy 
	"Jugador 2" 'njug2 strcpy 
	"Jugador 3" 'njug3 strcpy 
	"Jugador 4" 'njug4 strcpy 
	;
	
:resetjug | n --
	dup 'cntjug !
	'njug >a
	'pjug >b
	( 1? 1 - 
		0 a!+
		0 nposjug
		swap 32 randmax 16 - +
		swap 32 randmax 16 - +
		swap db!+ db!+
		) drop ;

:avjug | n --
	3 <<
|	dup 'njug + dup @ 1 + 10 mod swap !
	1 over 'njug + +!
	dup 'pjug + >a
	'njug + @
	dup maxjug max 'maxjug !
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
	30 28 $ff0000 fontt
	textline | str x y color font --
	;

|-------------------------------------------
:robot
	|msec 8 >> 3 and 7 +
	7
	simagenes 
	-44 dup 400 dup tsdraws

	6
	simagenes 
	-10 dup 150 dup tsdraws
	
	reloj	
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

:jugando
	gui
	$0 SDLcls
	0 0 
	1280 720
	stablero sdlimages
	
	mapascreen


	robot
	
	$11 'pregunta 370 22 870 136 xywh64 $00 fontt textbox | $vh str box color font	
	
	$11 jnow 5 << 'njug1 + 1280 300 - 600 300 80 xywh64 $0000 fontt textbox
	
	[ 0 'resusr ! exit ; ] r1 25 312 288 65 boton
	[ 1 'resusr ! exit ; ] r2 25 403 288 65 boton
	[ 2 'resusr ! exit ; ] r3 25 497 288 65 boton
	[ 3 'resusr ! exit ; ] r4 25 590 288 65 boton

	sdlx sdly scursor SDLimage
	SDLredraw

	SDLkey 
	>esc< =? ( exit ) | terminar siempre
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
	( maxjug 10 <? drop
		'jugando SDLshow
	
		respuesta	
		1 'nropreg +! cpypreg
		jnow 1 + cntjug mod 'jnow ! 
	
		1 'maxjug +! | ****
		
		) drop ;

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
	
	[ 2 'cntjug ! 2 playsnd ; ] "2" 100 300 100 60 boton	
	[ 3 'cntjug ! 2 playsnd ; ] "3" 100 380 100 60 boton	
	[ 4 'cntjug ! 2 playsnd ; ] "4" 100 460 100 60 boton	

	
	$01 'njug1 220 220 800 60 xywh64 $ffffff fontt textbox
	$01 'njug2 220 300 800 60 xywh64 2 jcolor fontt textbox
	$01 'njug3 220 380 800 60 xywh64 3 jcolor fontt textbox
	$01 'njug4 220 460 800 60 xywh64 4 jcolor fontt textbox
	
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
	"r3/j2022/quepaso/font/RobotoCondensed-Regular.ttf" 28 TTF_OpenFont 'font !	
	
	"r3\j2022\quepaso\cursor.png" loadimg 'scursor !	
	64 dup "r3\j2022\quepaso\preguntas.png" loadts 'simagenes !
	"r3\j2022\quepaso\tablero.png" loadimg 'stablero !
	
	SNDInit
	loadsndfile
	
	here dup 'preguntas !
	"r3\j2022\quepaso\preguntas.txt" load 
	0 swap c!+ 'here !

	0 'nropreg !
	cpypreg
	
	resetname
	;
	
:main
	"r3sdl" 1280 720 SDLinit
	|"r3sdl" 1024 576 SDLinit
	|SDLfull
	inicio
	0 SDL_ShowCursor
	
	'menuprincipal SDLshow 
	
	SDLquit ;	
	
: main ;


