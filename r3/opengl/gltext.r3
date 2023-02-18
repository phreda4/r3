^r3/win/sdl2.r3
^r3/win/sdl2gl.r3
^r3/win/sdl2ttf.r3

^r3/opengl/shaderobj.r3

#GL_RED $1903
#GL_RGB $1907
#GL_RGBA $1908
#GL_TEXTURE0 $84C0
#GL_TEXTURE_2D $0DE1
#GL_TRIANGLE_FAN $0006
#GL_UNSIGNED_BYTE $1401
#GL_TEXTURE_MAG_FILTER $2800
#GL_TEXTURE_MIN_FILTER $2801
#GL_LINEAR $2601
#GL_NEAREST $2600
#GL_ARRAY_BUFFER $8892
#GL_STATIC_DRAW $88E4
#GL_FLOAT $1406
#GL_FALSE 0
#GL_BLEND $0BE2
#GL_SRC_ALPHA $0302
#GL_ONE_MINUS_SRC_ALPHA $0303

#fontshader
#font
#ink
	
::initglfont
	ttf_init
	"media/ttf/roboto-bold.ttf" 32 TTF_OpenFont 'font !
	$ffffffff 'ink !
	"r3/opengl/shader/font1.fs"
	"r3/opengl/shader/font1.vs" 
	loadShaders 'fontshader !
	;	

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

::gltext | "" x y --
	rot
	fontshader glUseProgram
	
	1 'tt glGenTextures
    GL_TEXTURE_2D tt glBindTexture
	font swap ink TTF_RenderUTF8_Blended 'Surface !
	GL_TEXTURE_2D 0 GLBPP Surface->p 2 >> Surface->h 0 pick3 GL_UNSIGNED_BYTE Surface->pixels glTexImage2D
	GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_LINEAR glTexParameteri
	GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_LINEAR glTexParameteri
	Surface->w 0.003 * 'ws !
	Surface->h 0.003 * 'hs !
	surface SDL_FreeSurface
	
	GL_TEXTURE0 glActiveTexture
	GL_TEXTURE_2D tt glBindTexture
	
	1 'vt glGenVertexArrays
	1 'bt glGenBuffers
	vt glBindVertexArray
	GL_ARRAY_BUFFER bt glBindBuffer
	
	mark
	over fp, dup fp, 			0.0 fp, 1.0 fp,
	over ws + fp, dup fp, 		1.0 fp, 1.0 fp,
	over ws + fp, dup hs + fp, 	1.0 fp, 0.0 fp,
	over fp, dup hs + fp, 		0.0 fp, 0.0 fp,
	empty | size
	2drop
	
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