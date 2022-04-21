^r3/win/sdl2gfx.r3
^r3/util/bfont.r3

:teclado
	SDLkey
	>esc< =? ( exit )
	drop ;

:demo
	0 SDLClear
	
	$ffffff bcolor 
	10 10 bat 
	"Texto fuente fija" bprint
	
	$ffff00 bcolor 
	10 30 bat 
	msec "milisegundos del sistema:%d" sprint bprint
	
	SDLredraw
	teclado
	;
	
:main
	"r3sdl" 800 600 SDLinit
|	bfont1
	bfont2
	'demo SDLshow
	SDLquit ;	
	
: main ;