^r3/lib/sdl2gfx.r3
^r3/util/bfont.r3

:teclado
	SDLkey
	>esc< =? ( exit )
	drop ;

:demo
	0 SDLcls
	$ffffff bcolor 
	10 10 bat 
	"Font Fix library" bprint
	$ffff00 bcolor 
	10 30 bat 
	msec "ms: %d" bprint2 bcr bcr
	$ffff bcolor 
	"text bold" bprintd bcr
	$ff00 bcolor 
	"text 2x" bprint2
	bcr bcr
	msec 5 << $7ffff and | 0 to 7.9 interval
	"Text Size %f" over bprintz
	SDLredraw
	teclado
	;
	
:main
	"r3sdl" 800 600 SDLinit
|	bfont1 | pc font 8x16
	bfont2 | big fix font 16x24
	'demo SDLshow
	SDLquit ;	
	
: main ;