| OpenGL example
| PHREDA 2023
|MEM 64
^r3/lib/3d.r3
^r3/lib/rand.r3
^r3/lib/gui.r3
^r3/util/arr16.r3
^r3/lib/trace.r3

^r3/win/sdl2.r3
^r3/win/sdl2gl.r3

^r3/opengl/shaderobj.r3

| opengl Constant
#GL_DEPTH_TEST $0B71
#GL_LESS $0201
#GL_CULL_FACE $0B44

#GL_ARRAY_BUFFER $8892
#GL_ELEMENT_ARRAY_BUFFER $8893

#GL_STATIC_DRAW $88E4
#GL_FLOAT $1406
#GL_UNSIGNED_SHORT $1403

#GL_TRIANGLE_FAN $0006
#GL_TRIANGLE_STRIP $0005
#GL_TRIANGLES $0004
#GL_FALSE 0

#GL_TEXTURE $1702
#GL_TEXTURE0 $84C0
#GL_TEXTURE_2D $0DE1

#GL_DEPTH_COMPONENT $1902
#GL_TEXTURE_MAG_FILTER $2800
#GL_TEXTURE_MAX_ANISOTROPY_EXT $84FE
#GL_TEXTURE_MAX_LEVEL $813D
#GL_TEXTURE_MAX_LOD $813B
#GL_TEXTURE_MIN_FILTER $2801
#GL_TEXTURE_MIN_LOD $813A
#GL_TEXTURE_WRAP_R $8072
#GL_TEXTURE_WRAP_S $2802
#GL_TEXTURE_WRAP_T $2803
#GL_NEAREST $2600
#GL_NEAREST_MIPMAP_LINEAR $2702
#GL_NEAREST_MIPMAP_NEAREST $2700
#GL_CLAMP_TO_BORDER $812D
#GL_TEXTURE_BORDER_COLOR $1004
#GL_FRAMEBUFFER $8D40
#GL_DEPTH_ATTACHMENT $8D00
#GL_TEXTURE1 $84C1
	
#GL_DEPTH_BUFFER_BIT $100	

|-------------------------------------

:memfloat | cnt place --
	>a ( 1? 1 - da@ f2fp da!+ ) drop ;
	
#fontshader	
#fontTexture 
#fmscreen * 64	
#fcolor [ 1.0 1.0 1.0 1.0 ]

|---------- load img
#surface

#GL_RED $1903
#GL_RGB $1907
#GL_RGBA $1908
#GL_UNSIGNED_BYTE $1401

:Surface->w surface 16 + d@ ;
:Surface->h surface 20 + d@ ;
:Surface->pixels surface 32 + @ ;
:GLBPP 
	surface 8 + @ 16 + c@
	32 =? ( drop GL_RGBA ; ) 
	24 =? ( drop GL_RGB ; )
	drop GL_RED ;

::glImgFnt | "" -- 
	1 'fontTexture glGenTextures
    GL_TEXTURE_2D fontTexture glBindTexture IMG_Load 'Surface !
	GL_TEXTURE_2D 0 GLBPP Surface->w Surface->h 0 pick3 GL_UNSIGNED_BYTE Surface->pixels glTexImage2D
	GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_NEAREST glTexParameteri
	GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_NEAREST glTexParameteri
	;	
|-------------

:initshaders
	4 'fcolor memfloat	
	
	"r3/opengl/shader/font1.fs"
	"r3/opengl/shader/font1.vs" 
	loadShaders 'fontshader !
	
	fontshader glUseProgram
	0 over "u_FontTexture" shader!i
	'fcolor over "fgColor" shader!v4

	"media/img/font16x24.png" glImgFnt
	;


|----------------------------------------------	
#quadVAO
#quadVBO

#quadVertices [
	-1.0  1.0 0.0 1.0
	-1.0 -1.0 0.0 0.0
	 1.0  1.0 1.0 1.0
	 1.0 -1.0 1.0 0.0
	]

:initquad
	20 'quadVertices memfloat

	1 'quadVAO glGenVertexArrays
	1 'quadVBO glGenBuffers
	quadVAO glBindVertexArray
	GL_ARRAY_BUFFER quadVBO glBindBuffer
	GL_ARRAY_BUFFER 20 2 << 'quadVertices GL_STATIC_DRAW glBufferData
	0 glEnableVertexAttribArray
	0 3 GL_FLOAT GL_FALSE 4 2 << 0 glVertexAttribPointer
	1 glEnableVertexAttribArray
	1 2 GL_FLOAT GL_FALSE 4 2 << 2 2 << glVertexAttribPointer
	;
	
:renderquad
	fontshader glUseProgram
	GL_TEXTURE0 glActiveTexture
	GL_TEXTURE_2D fontTexture glBindTexture
	quadVAO glBindVertexArray
	GL_TRIANGLE_STRIP 0 4 glDrawArrays
	0 glBindVertexArray
	;

#vt
#bt

#wp 16 #hp 24

#xt 0 #yt 0
#wt 0 #ht 0

#xs 0 #ys 0
#ws 0.1 #hs 0.2

:gchar | char --
	1.0 wp / 'wt !
	1.0 hp / 'ht !
	
	dup $f and wt * 'xt ! | x1
	4 >> $f and ht * 'yt ! | y1

	xs f2fp , ys f2fp , 			xt f2fp , yt f2fp ,
	xs ws + f2fp , ys f2fp , 		xt wt + f2fp , yt f2fp ,
	xs ws + f2fp , ys hs + f2fp , 	xt wt + f2fp , yt ht + f2fp ,
	
	xs f2fp , ys f2fp , 			xt f2fp , yt f2fp ,
	xs ws + f2fp , ys hs + f2fp , 	xt wt + f2fp , yt ht + f2fp ,
	xs f2fp , ys hs + f2fp , 		xt f2fp , yt ht + f2fp ,
	
	0.1 'xs +!
	;
	
:rendergen | "" --
	fontshader glUseProgram
	GL_TEXTURE0 glActiveTexture
	GL_TEXTURE_2D fontTexture glBindTexture
	
	1 'vt glGenVertexArrays
	1 'bt glGenBuffers
	quadVAO glBindVertexArray
	GL_ARRAY_BUFFER bt glBindBuffer
	
	here mark
	swap
	( c@+ 1? gchar ) 2drop
	
	here swap - empty | size
	GL_ARRAY_BUFFER over here GL_STATIC_DRAW glBufferData
	0 glEnableVertexAttribArray 0 3 GL_FLOAT GL_FALSE 4 2 << 0 glVertexAttribPointer
	1 glEnableVertexAttribArray 1 2 GL_FLOAT GL_FALSE 4 2 << 2 2 << glVertexAttribPointer
	GL_TRIANGLES 0 rot 4 >> glDrawArrays | 16 bytes per vertex
	0 glBindVertexArray
	1 'vt glDeleteVertexArrays
	1 'bt glDeleteBuffers	
	;

|--------------	
:main
	$4100 glClear | color+depth

|	renderQuad
	-0.8 'xs ! 0 'ys !
	"hola mun" rendergen
	
	SDL_windows SDL_GL_SwapWindow
	SDLkey
	>esc< =? ( exit ) 	
	
	drop ;	
	
|----------- BOOT
:
 	5 1 SDL_GL_SetAttribute		|SDL_GL_DOUBLEBUFFER, 1);
	13 1 SDL_GL_SetAttribute	|SDL_GL_MULTISAMPLEBUFFERS, 1);
	14 8 SDL_GL_SetAttribute	|SDL_GL_MULTISAMPLESAMPLES, 8);
    17 4 SDL_GL_SetAttribute |SDL_GL_CONTEXT_MAJOR_VERSION
    18 6 SDL_GL_SetAttribute |SDL_GL_CONTEXT_MINOR_VERSION
	20 2 SDL_GL_SetAttribute |SDL_GL_CONTEXT_FLAGS, SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG);	
	21 2 SDL_GL_SetAttribute |SDL_GL_CONTEXT_PROFILE_MASK,  SDL_GL_CONTEXT_PROFILE_COMPATIBILITY
|	SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);
|	"SDL_RENDER_SCALE_QUALITY" "1" SDL_SetHint	
	
	"test opengl" 800 600 SDLinitGL
	
	
	GL_DEPTH_TEST glEnable 
|	GL_CULL_FACE glEnable	
|	GL_LESS glDepthFunc 

	800.0 0.0 600.0 0.0 100.0 0.0 mortho 
	'fmscreen mcpyf

	initshaders
	initQuad

	cr 
	glInfo		
	cr 
	"<esc> - Exit" .println
	"<f1> - 1 obj moving" .println
	"<esp> - 1 obj fix" .println	
	cr

	'main SDLshow
	SDL_Quit 
	;	