| OpenGL example
| PHREDA 2023
|MEM 64
^r3/lib/3dgl.r3
^r3/lib/gui.r3

^r3/win/sdl2.r3
^r3/win/sdl2gl.r3

^r3/util/loadobj.r3

^r3/opengl/ogl2util.r3

#xcam 0 #ycam 0 #zcam -30.0

| opengl Constant
#GL_COLOR_BUFFER_BIT $4000
#GL_DEPTH_BUFFER_BIT $100

#GL_ARRAY_BUFFER $8892
#GL_STATIC_DRAW $88E4
#GL_FLOAT $1406
#GL_FALSE 0

#GL_DEPTH_TEST $0B71
#GL_LESS $0201
#GL_CULL_FACE $0B44

#GL_TRIANGLES $0004

#vertex_buffer_data 
#uv_buffer_data 

:mem2float | cnt to from --
	>a >b ( 1? 1 - da@+ f2fp db!+ ) drop ;
	
	
:vert+uv | nro --
	dup | norm|text|vertex
	$fffff and 1 - | vertex
	5 << verl +
	@+ f2fp da!+ @+ f2fp da!+ @ f2fp da!+ | x y z
	20 >> $fffff and 1 - | texture
	24 * texl +
	@+ f2fp db!+ @ neg f2fp db!+
	;

:convertobj | "" --
	loadobj drop |'model !
|	objcentra

	here dup 'vertex_buffer_data ! 
	nface 3 * 3 * 2 << + | 3 vertices por vertice 3 coor por vertices 4 bytes por nro
	'uv_buffer_data  !

	vertex_buffer_data >a
	uv_buffer_data >b
	facel 
	nface ( 1? 1 - swap
		@+ vert+uv
		@+ vert+uv
		@+ vert+uv
		8 + swap ) 2drop
	b> 'here !
	;
	
#programID 
#VertexArrayID
#MatrixID

#vertexbuffer	
#uvbuffer
#texture	
#textureID

:initgl
	5 1 SDL_GL_SetAttribute		|SDL_GL_DOUBLEBUFFER, 1);
|	13 1 SDL_GL_SetAttribute	|SDL_GL_MULTISAMPLEBUFFERS, 1);
|	14 8 SDL_GL_SetAttribute	|SDL_GL_MULTISAMPLESAMPLES, 8);

    17 4 SDL_GL_SetAttribute |SDL_GL_CONTEXT_MAJOR_VERSION
    18 6 SDL_GL_SetAttribute |SDL_GL_CONTEXT_MINOR_VERSION
	20 2 SDL_GL_SetAttribute |SDL_GL_CONTEXT_FLAGS, SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG);	
	21 2 SDL_GL_SetAttribute |SDL_GL_CONTEXT_PROFILE_MASK,  SDL_GL_CONTEXT_PROFILE_COMPATIBILITY
|SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);
	
	"test opengl" 800 600 SDLinitGL

|	glInfo	

	GL_DEPTH_TEST glEnable 
	GL_LESS glDepthFunc 
	GL_CULL_FACE glEnable
	
|---------------------------		
	"r3/opengl/shader/basic.frag" 
	"r3/opengl/shader/basic.vert" 
	loadShaders | "fragment" "vertex" -- idprogram
	'programID !

	programID "MVP" glGetUniformLocation 'MatrixID !
	programID "myTextureSampler" glGetUniformLocation 'TextureID !	
|---------------------------		
	|GLuint Texture = loadDDS("uvtemplate.DDS");

	1 'Texture glGenTextures
	GL_TEXTURE_2D Texture glBindTexture
	
||	"r3/opengl/tex/uvtemplate.png" 
	"media/obj/mario/Mario_body.png"
	glLoadImg 

|---------------------------		
	1 'VertexArrayID glGenVertexArrays
	VertexArrayID glBindVertexArray

	1 'vertexbuffer glGenBuffers
	GL_ARRAY_BUFFER vertexbuffer glBindBuffer
	GL_ARRAY_BUFFER |nver 3 * 
	nface 3 * 3 *
	2 << vertex_buffer_data GL_STATIC_DRAW glBufferData

	1 'uvbuffer glGenBuffers
	GL_ARRAY_BUFFER uvbuffer glBindBuffer
	GL_ARRAY_BUFFER |ntex 2 * 
	nface 3 * 2 *
	2 << uv_buffer_data GL_STATIC_DRAW glBufferData
	;	
	
:glend
	programID glDeleteProgram
	1 'VertexArrayID glDeleteVertexArrays
	1 'uvbuffer glDeleteBuffers
	1 'vertexbuffer glDeleteBuffers
	1 'Texture glDeleteTextures

    SDL_Quit
	;
	
|------ vista
#xm #ym
#rx #ry

:dnlook
	SDLx SDLy 'ym ! 'xm ! ;

:movelook
	SDLx SDLy
	ym over 'ym ! - neg 7 << 'rx +!
	xm over 'xm ! - 7 << neg 'ry +!  ;

#pEye 4.0 3.0 3.0
#pTo 0 0 0
#pUp 0 1.0 0

#matcam * 128
#t

:mvp
	matini 
	|rx mrotx ry mroty 
|	0.5 0.0 0.0 mtrans
	rx ry t 3 <<  mrot
	mpush xcam ycam zcam mtra m*
	|'pEye 'pTo 'pUp mlookat | eye to up --
	'matcam mm* | perspective
	;
	
|--------------	
:main
	gui
	'dnlook 'movelook onDnMove

	0.0001 't +!
	$4100 glClear

	programID glUseProgram
	
	mvp
	MatrixID 1 GL_FALSE getfmat glUniformMatrix4fv 	
	
	GL_TEXTURE0 glActiveTexture
	GL_TEXTURE_2D Texture glBindTexture
	TextureID 0 glUniform1i

	0 glEnableVertexAttribArray
	GL_ARRAY_BUFFER vertexbuffer glBindBuffer
	0 3 GL_FLOAT GL_FALSE 0 0 glVertexAttribPointer

	1 glEnableVertexAttribArray
	GL_ARRAY_BUFFER uvbuffer glBindBuffer
	1 2 GL_FLOAT GL_FALSE 0 0 glVertexAttribPointer

	GL_TRIANGLES 0 nface 3 * glDrawArrays

	0 glDisableVertexAttribArray
	1 glDisableVertexAttribArray

|......		
	SDL_windows SDL_GL_SwapWindow
	SDLkey
	>esc< =? ( exit ) 	
	<up> =? ( 1.0 'zcam +! )
	<dn> =? ( -1.0 'zcam +! )
	drop ;	
	
|----------- BOOT
: 	
	|"media/obj/cube.obj" 
	|"media/obj/suzanne.obj" 
	"media/obj/mario/mario.obj" 
	convertobj

	matini 
	0.1 1000.0 0.9 3.0 4.0 /. mperspective 
	'matcam mcpy
	
	initgl 
	'main SDLshow
	glend 
	;	