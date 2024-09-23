^r3/lib/rand.r3
^r3/lib/sdl2.r3
^r3/lib/sdl2gl.r3
^r3/lib/sdl2gfx.r3
^r3/lib/sdl2ttf.r3
^r3/opengl/shaderobj.r3

| opengl Constant
#GL_DEPTH_TEST $0B71
#GL_LESS $0201
#GL_CULL_FACE $0B44

#GL_RED $1903
#GL_RGB $1907
#GL_RGBA $1908
#GL_BGRA_EXT $80e1

#GL_UNSIGNED_BYTE $1401
#GL_TEXTURE_MAG_FILTER $2800
#GL_TEXTURE_MIN_FILTER $2801
#GL_LINEAR $2601
#GL_NEAREST $2600

#GL_TEXTURE0 $84C0
#GL_TEXTURE_2D $0DE1
#GL_TRIANGLE_STRIP $0005
#GL_TRIANGLE_FAN $0006
#GL_ARRAY_BUFFER $8892
#GL_STATIC_DRAW $88E4
#GL_FLOAT $1406
#GL_FALSE 0
#GL_BLEND $0BE2
#GL_SRC_ALPHA $0302
#GL_ONE_MINUS_SRC_ALPHA $0303

|-------------------------------------
:glinit
	"test opengl" 800 600 SDLinitGL
	
|	GL_DEPTH_TEST glEnable 
|	GL_CULL_FACE glEnable	
|	GL_LESS glDepthFunc 
	
	0 0 800 600 glViewport
	;	

:mem2float | cnt to from --
	>a >b ( 1? 1 - da@+ f2fp db!+ ) drop ;
	
#fontshader
	
:initshaders
	"r3/opengl/shader/font1.fs"
	"r3/opengl/shader/font1.vs" 
	loadShaders 'fontshader !
	;	
	
#font
#ink
#x #y
#t

#surface
:Surface->w surface 16 + d@ ;
:Surface->h surface 20 + d@ ;
:Surface->p surface 24 + d@ ;
:Surface->pixels surface 32 + @ ;
:GLBPP 
	surface 8 + @ 16 + c@
	32 =? ( drop GL_RGBA ; ) 
	24 =? ( drop GL_RGB ; )
	drop GL_RED ;	

:fp, f2fp , ;

#tt #vt #bt
#ws #hs

:glrendertext | "" x y --
	'y ! 'x ! 
	
	fontshader glUseProgram
	
	1 'tt glGenTextures
    GL_TEXTURE_2D tt glBindTexture
	font swap ink TTF_RenderUTF8_Blended 'Surface !
	GL_TEXTURE_2D 0 GLBPP Surface->p 2 >> Surface->h 0 pick3  GL_UNSIGNED_BYTE Surface->pixels glTexImage2D
	GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_NEAREST glTexParameteri
	GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_NEAREST glTexParameteri
	Surface->w 0.005 * 'ws !
	Surface->h 0.005 * 'hs !
	surface SDL_FreeSurface
	
	GL_TEXTURE0 glActiveTexture
	GL_TEXTURE_2D tt glBindTexture
	
	1 'vt glGenVertexArrays
	1 'bt glGenBuffers
	vt glBindVertexArray
	GL_ARRAY_BUFFER bt glBindBuffer
	
	mark
	x fp, y fp, 			0.0 fp, 1.0 fp,
	x ws + fp, y fp, 		1.0 fp, 1.0 fp,
	x ws + fp, y hs + fp, 	1.0 fp, 0.0 fp,
	x fp, y hs + fp, 		0.0 fp, 0.0 fp,
	empty | size
	
	GL_ARRAY_BUFFER 16 2 << here GL_STATIC_DRAW glBufferData
	0 glEnableVertexAttribArray 0 3 GL_FLOAT GL_FALSE 4 2 << 0 glVertexAttribPointer
	1 glEnableVertexAttribArray 1 2 GL_FLOAT GL_FALSE 4 2 << 2 2 << glVertexAttribPointer
	
	GL_BLEND glEnable
	GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA glBlendFunc

	GL_TRIANGLE_FAN 0 4 glDrawArrays | 16 bytes per vertex
	0 glBindVertexArray
	1 'vt glDeleteVertexArrays
	1 'bt glDeleteBuffers	
	1 'tt glDeleteTextures
	;
	
:main
	|gui
	|'dnlook 'movelook onDnMove

	$4100 glClear | color+depth

	"Hola Mundo" -0.8 -0.8 glrendertext
	rand 'ink !
	SDL_windows SDL_GL_SwapWindow
	SDLkey
	>esc< =? ( exit ) 	
	
	drop ;		
|----------- BOOT
:
	glinit
	initshaders

	"media/ttf/roboto-bold.ttf" 24 TTF_OpenFont 'font !
|	font 1 TTF_SetFontSDF
	$ffff0000 'ink !
	
	'main SDLshow
	SDL_Quit
	;	