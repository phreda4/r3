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
#GL_UNPACK_ALIGNMENT $0CF5

|-------------------------------------

:memfloat | cnt place --
	>a ( 1? 1 - da@ f2fp da!+ ) drop ;
	
#fontshader	
#fontTexture 
#fcolor [ 1.0 1.0 1.0 1.0 ]

|---------- load img
#surface

#GL_RED $1903
#GL_RGB $1907
#GL_RGBA $1908
#GL_UNSIGNED_BYTE $1401

:Surface->w surface 16 + d@ ;
:Surface->h surface 20 + d@ ;
:Surface->p surface 24 + d@ ;
:Surface->pixels surface 32 + @ ;
:GLBPP 
	surface 8 + @ 16 + c@
	32 =? ( drop GL_RGBA ; ) 
	24 =? ( drop GL_RGB ; )
	drop GL_RED ;

::glImgFnt | "" -- 
	GL_UNPACK_ALIGNMENT 1 glPixelStorei
	1 'fontTexture glGenTextures
    GL_TEXTURE_2D fontTexture glBindTexture IMG_Load 'Surface !
	GL_TEXTURE_2D 0 GLBPP Surface->w Surface->h 0 pick3 GL_UNSIGNED_BYTE Surface->pixels glTexImage2D
	GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_NEAREST glTexParameteri
	GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_NEAREST glTexParameteri
	;	
|-------------

#xt 0 #yt 0 
#wt 0 #ht 0 #wts 0 #hts 0

#xs 0 #ys 0
#ws 0.05 #hs 0.1

:initshaders
	4 'fcolor memfloat	
	
	"r3/opengl/shader/font1.fs"
	"r3/opengl/shader/font1.vs" 
	loadShaders 'fontshader !
	
	fontshader glUseProgram
	0 over "u_FontTexture" shader!i
	'fcolor over "fgColor" shader!v4

|	"media/img/font16x24.png" glImgFnt
	"media/img/VGA8x16.png" glImgFnt

	0.5 8 / 'wt ! 
	wt 'wts ! 
	1.0 16 / 'ht ! 
	ht 'hts !
	;

|---------------------------------------
#vt
#bt

:fp, f2fp , ;

:gchar | char --
	dup $f and wt * 'xt ! | x1
	4 >> $f and ht * 'yt ! | y1

	xs fp, ys fp, 			xt fp, yt ht + fp,
	xs ws + fp, ys fp, 		xt wt + fp, yt ht + fp,
	xs ws + fp, ys hs + fp, xt wt + fp, yt fp,
	
	xs fp, ys fp, 			xt fp, yt ht + fp,
	xs ws + fp, ys hs + fp, xt wt + fp, yt fp,
	xs fp, ys hs + fp, 		xt fp, yt fp,
	
	0.05 'xs +!
	;
	
:rendergen | "" --
	fontshader glUseProgram
	GL_TEXTURE0 glActiveTexture
	GL_TEXTURE_2D fontTexture glBindTexture
	
	1 'vt glGenVertexArrays
	1 'bt glGenBuffers
	vt glBindVertexArray
	GL_ARRAY_BUFFER bt glBindBuffer
	
	here mark
	swap ( c@+ 1? gchar ) 2drop
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

	-0.8 'xs ! 0.8 'ys !
	"Hola Forth/r3 - OpenGL" rendergen
	-0.8 'xs ! 0.7 'ys !
	"Bitmap FONT" rendergen
	-0.8 'xs ! 0.6 'ys !
	msec "%h" sprint rendergen
	
	SDL_windows SDL_GL_SwapWindow
	SDLkey
	>esc< =? ( exit ) 	
	drop ;	
	
|----------- BOOT
:
	"test opengl" 800 600 SDLinitGL
	
	GL_DEPTH_TEST glEnable 
|	GL_CULL_FACE glEnable	
|	GL_LESS glDepthFunc 

	initshaders

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