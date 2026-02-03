| draw text

^r3/lib/sdl2gfx.r3
^r3/util/txfont.r3

:demo
	0 SDLcls
	$ff4c4c txrgb
	10 10 txat
	"Tx Font lib" txprint
	$ffff4f txrgb
	10 40 txat 
	msec "ms: %d" txprint
	
	$4cff4c txrgb
	$11 txalign  | Center horizontally and vertically
	300 250 200 100 
"Welcome to the application
This is a multi-line message
[ESC] to exit" 
	txText

	SDLredraw
	SDLkey >esc< =? ( exit ) drop ;
	
:main
	"r3 text" 800 600 SDLinit
	"media/ttf/VictorMono-Bold.ttf" 32 txload txfont
	'demo SDLshow
	SDLquit ;	
	
: main ;