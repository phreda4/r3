^r3/win/sdl2gfx.r3


:	
	"r3sdl" 800 600 SDLinit

	$ffffff Color 
	30 10
	100 100
	Rect
		
	redraw 
	( SDLupdate SDLkey >esc< <>? drop ) drop
	SDLquit 
	;
fkds

dsf
