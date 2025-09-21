| Resize windows, change sw and sh
| PHREDA 2024
^r3/lib/sdl2gfx.r3
^r3/util/vscreen.r3
^r3/util/bfont.r3
^r3/util/txfont.r3
	
#font

:demo
	vini
	$7f7f7f SDLcls
	$ffffff bcolor 
	10 10 bat 
	"Resize Windows" bprint2
	bcr bcr
	sh sw "w:%d h:%d" bprint2

	$ff00 sdlcolor
	0 0 sdlx sdly SDLline
	
	$ff0000 txrgb
	0 0 txat "hola" txemits	
	8 8 sdlx sdly sdlellipse
	vredraw
	SDLkey
	>esc< =? ( exit )
	drop 
	;
	
:main
	"r3sdl" 800 600 SDLinitR
	320 240 vscreen 
	
	"media/ttf/Roboto-Medium.ttf" 30 txload 'font !
	font txfont
	bfont1 | pc font 8x16
	
	'demo SDLshow
	SDLquit ;	
	
: main ;
