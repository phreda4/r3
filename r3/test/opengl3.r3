^r3/win/sdl2.r3
^r3/win/glew.r3

#window
#context

#vao 0 
#vbo 0 

#GL_COLOR_BUFFER_BIT $00004000
#GL_FRAGMENT_SHADER $8B30
#GL_VERTEX_SHADER $8B31
#GL_ARRAY_BUFFER $8892
#GL_STATIC_DRAW $88E4
#GL_FLOAT $1406
#GL_FALSE 0

#GL_TRIANGLES $0004

| data for a fullscreen quad
#vertexData
[ 0 0 0 ]
[ 0 0 0 ]
[ 0 0 0 ]

:fillvertex
	-1.0 f2fp 0.0 f2fp 1.0 f2fp
	'vertexData >a
	pick2 da!+ pick2 da!+ over da!+
	dup da!+ pick2 da!+ over da!+
	over da!+ dup da!+ over da!+
	3drop ;

:initgl
    | select opengl version

	20 2 SDL_GL_SetAttribute |(SDL_GL_CONTEXT_FLAGS, SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG);
    17 3 SDL_GL_SetAttribute |(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    18 3 SDL_GL_SetAttribute |(SDL_GL_CONTEXT_MINOR_VERSION, 3);
	21 2 SDL_GL_SetAttribute |(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);	
|SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);

	13 1 SDL_GL_SetAttribute |  SDL_GL_SetAttribute(SDL_GL_MULTISAMPLEBUFFERS, 1);
	14 4 SDL_GL_SetAttribute   |SDL_GL_SetAttribute(SDL_GL_MULTISAMPLESAMPLES, 8);
	
	$3231 SDL_init 	
	
	$1FFF0000 dup 800 600 $2 SDL_CreateWindow 'window !
	
	window SDL_GL_CreateContext 'context !
|	window context SDL_GL_MakeCurrent


	fillvertex
	1 glewExperimental d!
	glewInit 	
	
	|--- info
	"glew " .print
	1 glewGetString .println 
|	2 glewGetString .println 
|	3 glewGetString .println 
|	4 glewGetString .println 
	"OpenGl " .print
	$1f00 glGetString .println | vendor
	$1f01 glGetString .println | render
	$1f02 glGetString .println | version
	$8B8C glGetString .println | shader
	
    | ---generate and bind the vao
	1 'vao glGenVertexArrays
	vao glBindVertexArray

	1 'vbo glGenBuffers
	GL_ARRAY_BUFFER vbo glBindBuffer
	GL_ARRAY_BUFFER 9 4 * 'vertexData GL_STATIC_DRAW  glBufferData
	;
	
:glend
	1 'vao glDeleteVertexArrays
	1 'vbo glDeleteBuffers

	context SDL_Gl_DeleteContext
    SDL_Quit
	;

:main
	GL_COLOR_BUFFER_BIT glClear
	vao glBindVertexArray
	GL_TRIANGLES 0 3 glDrawArrays

	window SDL_GL_SwapWindow
	SDLkey
	>esc< =? ( exit ) 
	drop ;
		

: 	initgl 
	'main SDLshow
	glend 
	;