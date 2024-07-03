| sdl2 text in box 
| PHREDA 2021
^r3/win/sdl2gfx.r3	
^r3/util/pcfont.r3

:draw
	0 SDLcls

	10 2 gotoxy
	$ffffff pccolor
	"Hola r3 pcfont" pcprint
	pccr
	$ff00 pccolor
	"Ahora doble" pcprintd
	pccr
	$ff0000 pccolor
	"Doble size" pcprint2
	pccr pccr
	"Text with size 4.3" 4.3 pcprintz	
	
	SDLredraw
	sdlkey
	>esc< =? ( exit )
	drop
	;
	
:main
	"test pcfont" 1024 600 SDLinit
	pcfont
	'draw sdlshow
	SDLquit
	;

: main ;

