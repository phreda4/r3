| OpenGL example
| PHREDA 2023
|MEM 64
^r3/lib/3dgl.r3
^r3/win/sdl2.r3
^r3/win/sdl2gl.r3
^r3/opengl/shaderobj.r3
^r3/opengl/glgui.r3

|--------------	
#val1 0 
#val2 0
#val3 4.0
#val4 0

#vchek
#vradio
:main
	$4100 glClear | color+depth

	glgui

	300 10 100 20 glwin
	
	'exit "salir" gltbtn gldn
	
	-1.0 1.0 'val1 glSliderf gldn
	1.0 4.0 'val3 glSliderf gldn
	0.0 4.0 'val4 glSliderf gldn
	gldn
	-100 200 'val2 glSlideri gldn
	
	'vchek "Check" glCheck gldn
	'vradio "Radio" glRadio gldn
	
	0 0 glat
	$ffffff textcolor
	"Hola Forth/r3 - OpenGL" gltext glcr
	$ff textcolor
	val1 "%f" sprint gltext glcr
	$ff00 textcolor
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