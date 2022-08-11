
^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3
^r3/util/boxtext.r3
^r3/util/tilesheet.r3
^r3/lib/rand.r3

#simaneges
#stablero
#smapa

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
	;

	
:teclado
	SDLkey 
	>esc< =? ( exit )
	<f1> =? ( 1 'nropreg +! cpypreg )
	drop 
	;
	
	
:jugando
	$0 SDLcls
	0 0 
	1280 720
	stablero sdlimages
	
	500 180 
	400 523
	smapa sdlimages
	
	reloj

	msec 8 >> 3 and 
	simaneges 
	20 20 
	256 dup tsdraws
	$11 'pregunta 370 22 870 136 xywh64 $00 fontt textbox | $vh str box color font	
	$11 r1 25 312 288 65 xywh64 $0 font textbox
	$11 r2 25 404 288 65 xywh64 $0 font textbox
	$11 r3 25 498 288 65 xywh64 $0 font textbox
	$11 r4 25 590 288 65 xywh64 $0 font textbox

	SDLredraw
	teclado
	;

:inicio
	ttf_init
	"r3/j2022/pregunta/font/RobotoCondensed-Bold.ttf" 50 TTF_OpenFont 'fontt !	
	"r3/j2022/pregunta/font/RobotoCondensed-Regular.ttf" 28 TTF_OpenFont 'font !	
	
	64 dup "r3\j2022\pregunta\preguntas.png" loadts 'simaneges !
	"r3\j2022\pregunta\tablero juego.png" loadimg 'stablero !
	"r3\j2022\pregunta\mapa.png" loadimg 'smapa !
	
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
	'jugando SDLshow
	SDLquit ;	
	
: main ;


