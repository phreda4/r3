
^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3
^r3/util/boxtext.r3
^r3/util/tilesheet.r3
^r3/lib/rand.r3

#sfondo
#scursor

#simaneges
#stablero
#smapa

#fontt
#font
#preguntas

#tiempo
#nropreg 0

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


:teclado
	SDLkey 
	>esc< =? ( exit )
	<f1> =? ( 1 'nropreg +! )
	drop 
	;
	
	
:jugando
	$0 SDLcls
	0 0 
	1280 720
	sfondo sdlimages
	
	sdlb scursor sdlx sdly tsdraw
	
	SDLredraw
	teclado
	;

:inicio
	ttf_init
|	"r3/j2022/pregunta/font/RobotoCondensed-Bold.ttf" 50 TTF_OpenFont 'fontt !	
|	"r3/j2022/pregunta/font/RobotoCondensed-Regular.ttf" 28 TTF_OpenFont 'font !	
	
	128 dup "r3\j2022\pregunta\cursor.png" loadts 'scursor !	
	
|	64 dup "r3\j2022\pregunta\preguntas.png" loadts 'simaneges !
|	"r3\j2022\pregunta\tablero juego.png" loadimg 'stablero !
	"r3\j2022\braian\fondo.png" loadimg 'sfondo !
	
|	here dup 'preguntas !
|	"r3\j2022\pregunta\preguntas.txt" load 
|	0 swap c!+ 'here !

	0 'nropreg !
	;
	
:main
	"r3sdl" 1280 720 SDLinit
	|"r3sdl" 1024 576 SDLinit
	|SDLfull
	inicio
	0 SDL_ShowCursor
	'jugando SDLshow
	SDLquit ;	
	
: main ;


