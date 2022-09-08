
^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3
^r3/win/sdl2mixer.r3

^r3/util/boxtext.r3
^r3/util/tilesheet.r3
^r3/lib/rand.r3
^r3/lib/gui.r3

#simagenes
#stablero
#smapa
#scursor

#snd_boton 
#snd_correcta 
#snd_incorrecta
#snd_pregunta

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
	500 180 
	400 523
	smapa sdlimages 

	'pjug >a
	cntjug ( 1? 1-
		dup simagenes da@+ da@+ tsdraw
		) drop ;
	
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
:robot
	msec 8 >> 3 and 7 +
	simagenes 
	-44 dup
	400 dup tsdraws
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
	100 10 $ff0000 fontt
	textline | str x y color font --
	;

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
|	snd_pregunta SNDplay
	;

	
|-------------------------------------------

:boton | 'vecor "text" -- size
	2over 2over guibox
	SDLb SDLx SDLy guiIn	
	$ffffff  [ $00ff00 nip ; ] guiI
	SDLColor
	2over 2over SDLFRect	
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

	reloj
	robot
	
	$11 'pregunta 370 22 870 136 xywh64 $00 fontt textbox | $vh str box color font	
	
	[ 0 'resusr ! exit ; ] r1 25 312 288 65 boton
	[ 1 'resusr ! exit ; ] r2 25 403 288 65 boton
	[ 2 'resusr ! exit ; ] r3 25 497 288 65 boton
	[ 3 'resusr ! exit ; ] r4 25 590 288 65 boton

	0 scursor sdlx sdly tsdraw
	SDLredraw

	SDLkey 
	>esc< =? ( exit ) | terminar siempre
	drop 
	;


|----------------------------------
:respuestaOK
	jnow avjug 
	;

:respuestaNO
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
	
		) drop ;

:menuprincipal
	gui
	$0 SDLcls

	$11 "Preguntas de San Cayetano"
	0 10 1280 100 xywh64 
	$ffffff fontt textbox

	$11 cntjug "%d jugadores" sprint
	0 140 1280 80 xywh64 
	$ffffff fontt textbox

|	$11 "Cuantos Jugadores ?"
|	0 140 1280 80 xywh64 
|	$ffffff fontt textbox
	
	[ 2 'cntjug ! ; ] "2" 200 300 100 80 boton	
	[ 3 'cntjug ! ; ] "3" 400 300 100 80 boton	
	[ 4 'cntjug ! ; ] "4" 600 300 100 80 boton	
	[ 5 'cntjug ! ; ] "5" 860 300 100 80 boton	
	
	[ jugar ; ] "Jugar" 400 500 120 80 boton
	[ exit ; ] "Salir" 600 500 120 80 boton
	
	0 scursor sdlx sdly tsdraw
	
	SDLredraw

	SDLkey 
	>esc< =? ( exit )
	drop 
	;
	
:inicio
	ttf_init
	"r3/j2022/pregunta/font/RobotoCondensed-Bold.ttf" 50 TTF_OpenFont 'fontt !	
	"r3/j2022/pregunta/font/RobotoCondensed-Regular.ttf" 28 TTF_OpenFont 'font !	
	
	128 dup "r3\j2022\pregunta\cursor.png" loadts 'scursor !	
	64 dup "r3\j2022\pregunta\preguntas.png" loadts 'simagenes !
	"r3\j2022\pregunta\tablero juego.png" loadimg 'stablero !
	"r3\j2022\pregunta\mapa.png" loadimg 'smapa !
	
	"r3\j2022\pregunta\boton.mp3" Mix_LoadWAV 'snd_boton !
	"r3\j2022\pregunta\correcta.mp3" Mix_LoadWAV 'snd_correcta !
	"r3\j2022\pregunta\incorrecta.mp3" Mix_LoadWAV 'snd_incorrecta !
	"r3\j2022\pregunta\pregunta.mp3" Mix_LoadWAV 'snd_pregunta !
	
	here dup 'preguntas !
	"r3\j2022\pregunta\preguntas.txt" load 
	0 swap c!+ 'here !

	0 'nropreg !
	cpypreg
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


