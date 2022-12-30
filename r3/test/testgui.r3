^r3/lib/gui.r3
^r3/win/sdl2gfx.r3
^r3/util/bfont.r3
^r3/lib/input.r3

#cv 0

:tbtn | exe "" x1 y1 w h --
	guibox
	
	$7f 
	[ $ff nip ; ] guiI
	SDLColor
	xr1 yr1 xr2 pick2 - yr2 pick2 -
	SDLFRect	
	
	$ffffff SDLColor
	bsize | w h
	xr2 xr1 + 1 >> rot 1 >> - 
	yr2 yr1 + 1 >> rot 1 >> -
	bat
	bprint
	onClick
	;
	
#buffer * 100
#otrob * 50
	
:main
	gui
	0 SDLcls
	$ff00 SDLColor
	
	10 10 bat
	cv "%d" sprint bprint
	
	10 30 bat
	"buffer: " bprint
	'buffer 100 input
	
	10 50 bat
	"otro: " bprint
	'otrob 100 input
	
	[ 1 'cv +! ; ] "suma 1" 200 300 100 30 tbtn
	[ -1 'cv +! ; ] "resta 1" 200 340 100 30 tbtn

	SDLredraw 
	SDLkey
	>esc< =? ( exit )
	drop ;	

: 
	"r3sdl" 800 600 SDLinit
	bfont1
	
	'main SDLShow 
	SDLquit
	;
