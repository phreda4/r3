^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3
^r3/util/boxtext.r3
^r3/util/tilesheet.r3

#simaneges
#stablero
#fontt
#font
#preguntas

#nropreg 0
#pregunta * 1024
#res1 * 1024
#res2 * 1024
#res3 * 1024
#res4 * 1024

:cpypreg |
	preguntas
	nropreg dup 2 << + | * 5
	( 1? swap >>cr trim swap ) drop
	dup 'pregunta strcpyln
	>>cr trim dup 'res1 strcpyln
	>>cr trim dup 'res2 strcpyln
	>>cr trim dup 'res3 strcpyln
	>>cr trim dup 'res4 strcpyln
	drop ;
	
:teclado
	SDLkey 
	>esc< =? ( exit )
	<f1> =? ( 1 'nropreg +! cpypreg )
	drop 
	;
	
:jugando
	$0 SDLcls
	0 0 stablero sdlimage
| $vh str box color font	

	$0 'pregunta 200 100 800 400 xywh64 $00 fontt textbox
	
	$0 'res1 40 300 300 100 xywh64 $0 font textbox
	$0 'res2 40 360 300 100 xywh64 $0 font textbox
	$0 'res3 40 420 300 100 xywh64 $0 font textbox
	$0 'res4 40 480 300 100 xywh64 $0 font textbox

	SDLredraw
	teclado
	;

:inicio
	ttf_init
	"media\ttf\roboto-bold.ttf" 32 TTF_OpenFont 'fontt !	
	"media\ttf\roboto-bold.ttf" 28 TTF_OpenFont 'font !	
	
	64 dup "r3\j2022\pregunta\preguntas.png" loadts 'simaneges !
	"r3\j2022\pregunta\tablero juego.png" loadimg 'stablero !
	
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


