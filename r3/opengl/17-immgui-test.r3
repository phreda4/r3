| OpenGL IMMGUI example
| PHREDA 2023
|MEM 64

^r3/win/sdl2.r3
^r3/win/sdl2gl.r3

^r3/opengl/glfgui.r3

|--------------	
#val1 0 
#val2 0
#val3 4.0
#val4 0

#texto1 * 64
#texto2 * 64

#vchek
#vradio
#vcombo

:main
	$4100 glClear | color+depth

	glgui

	10 10 200 20 glwin
	
	'exit "salir" gltbtn gldn
	
	-1.0 1.0 'val1 glSliderf gldn
	1.0 4.0 'val3 glSliderf gldn
	0.0 4.0 'val4 glSliderf gldn
	gldn
	-100 200 'val2 glSlideri gldn
	
	'vchek "Check" glCheck gldn
	'vradio "Radio 1|Radio 2|Radio 3" glRadio  
	'vcombo "Combo 1|Combo 2|Combo 3|Combo 4" glCombo gldn
	
	'texto1 20 glInput gldn
	'texto2 20 glInput
	
	300 0 glat
	$ffffff glcolor
	"Hola Forth/r3 - OpenGL" gltext
	
	300 16 glat
	$ff glcolor
	val1 "%f" sprint gltext 
	
	300 32 glat
	$ff00 glcolor
	"Bitmap FONT" gltext

	
	SDL_windows SDL_GL_SwapWindow
	SDLkey
	>esc< =? ( exit ) 	
	drop ;	
	
|----------- BOOT
:
	"test glscr" 800 600 SDLinitGL
	
|	GL_DEPTH_TEST glEnable 
|	GL_CULL_FACE glEnable	
|	GL_LESS glDepthFunc 

	glimmgui

	'main SDLshow
	SDL_Quit 
	;	