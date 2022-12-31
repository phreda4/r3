^r3/win/sdl2gfx.r3
^r3/util/bfont.r3
^r3/lib/gui.r3
^r3/util/dlgcol.r3

:main
	gui
	$0 SDLcls

	30 30 dlgColor

	SDLkey
	>esc< =? ( exit )
	drop

	SDLredraw 
	;	

:   
	"r3color" 800 600 SDLinit
	bfont1
	dlgColorIni
	'main SDLShow
	SDLquit
	;