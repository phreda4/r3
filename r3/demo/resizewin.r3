| Resize windows, change sw and sh
| PHREDA 2024

^r3/win/sdl2gfx.r3
^r3/util/bfont.r3

:demo
	0 SDLcls
	$ffffff bcolor 
	10 10 bat 
	"Resize Windows" bprint2
	bcr bcr
	sh sw "w:%d h:%d" bprint2
	$ff00 sdlcolor
	0 0 sw sh SDLline
	SDLredraw	
	SDLkey
	>esc< =? ( exit )
	drop ;
	;
	
:main
	"r3sdl" 800 600 SDLinitR
	bfont1 | pc font 8x16
	'demo SDLshow
	SDLquit ;	
	
: main ;
