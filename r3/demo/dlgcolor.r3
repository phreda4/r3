^r3/lib/sdl2gfx.r3
^r3/util/bfont.r3
^r3/lib/gui.r3
^r3/util/dlgcol.r3

:main
	gui
	$0 SDLcls

	dlgColor

	SDLkey
	>esc< =? ( exit )
	drop

	SDLredraw 
	;	

:   
	"r3color" 800 600 SDLinit
	bfont1
	30 30 xydlgColor!
	dlgColorIni
	'main SDLShow
	SDLquit
	;