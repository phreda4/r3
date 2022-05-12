^r3/win/sdl2gfx.r3


:	
	"r3sdl" 800 600 SDLinit

	$ffffff SDLcolor 
	30 10
	100 100
	SDLRect
		
	SDLRedraw 
	( SDLupdate SDLkey >esc< <>? drop ) drop
	SDLquit 
	;