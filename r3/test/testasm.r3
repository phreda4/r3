^r3/win/sdl2gfx.r3

:test
	3 "hola %d" .print
	;

:	
	test
	"r3sdl" 800 600 SDLinit

	$ffffff SDLColor 
	30 10
	100 100
	SDLRect
		
	SDLredraw 
	( SDLupdate SDLkey >esc< <>? drop ) drop
	SDLquit 
	;
