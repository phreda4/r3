
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

#cntjug 1
#njug 0 0 0 0 0 0 0 0
#pjug 0 0 0 0 0 0 0 0

#posiciones [ 
580 890
570 720
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
	1 over 'njug + +!
	dup 'pjug + >a
	'njug + @
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
	100 10 $ff0000 font
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

	
:teclado
	SDLkey 
	>esc< =? ( exit )
|	<f1> =? ( 1 'nropreg +! cpypreg )
	<f1> =? ( 0 avjug )
	<f2> =? ( 1 avjug )
	<f3> =? ( 2 avjug )
	<f4> =? ( 3 avjug )
	drop 
	;

|-------------------------------------------
#resusr

:resp | r1 -- color
	resusr <>? ( drop $ffffff ; )
	'res1 =? ( drop $ff00 ; )  
	drop $ff0000 ;

:botonr | -- size
	resp SDLColor
	2over 2over SDLFRect	
	xywh64 ;
	
:respuesta
	gui
	$0 SDLcls
	0 0 
	1280 720
	stablero sdlimages
	
	mapascreen
	
	reloj


	$11 'pregunta 370 22 870 136 xywh64 $00 fontt textbox | $vh str box color font	
	
	25 312 288 65 r1 botonr
	$11 r1 rot $0 font textbox
	
	25 403 288 65 r2 botonr
	$11 r2 rot $0 font textbox
	
	25 497 288 65 r3 botonr
	$11 r3 rot $0 font textbox
	
	25 590 288 65 r4 botonr
	$11 r4 rot $0 font textbox

	0 scursor sdlx sdly tsdraw
	SDLredraw
	teclado
	;
	
|-------------------------------------------

:boton | -- size
	2over 2over guibox
	SDLb SDLx SDLy guiIn	
	$ffffff  [ $00ff00 nip ; ] guiI
	SDLColor
	2over 2over SDLFRect	
	xywh64 ;

:resok
	1 'nropreg +! cpypreg
	;
:reserror
	1 'nropreg +! cpypreg
	;
	
:tocoboton	| adr
	dup 'resusr !
	'res1 =? ( resok ; ) 
	reserror ;
	
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
	
	25 312 288 65 boton
	$11 r1 rot $0 font textbox
	r1 'tocoboton onClick drop
	
	25 403 288 65 boton
	$11 r2 rot $0 font textbox
	r2 'tocoboton onClick drop
	
	25 497 288 65 boton
	$11 r3 rot $0 font textbox
	r3 'tocoboton onClick drop
	
	25 590 288 65 boton
	$11 r4 rot $0 font textbox
	r4 'tocoboton onClick drop

	0 scursor sdlx sdly tsdraw
	SDLredraw
	teclado
	;


	
:jugar
	4 resetjug
	'jugando SDLshow
	|'respuesta SDLshow
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
	jugar
	SDLquit ;	
	
: main ;


