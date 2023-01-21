| OpenGL example
| PHREDA 2023
^r3/win/sdl2.r3
^r3/win/sdl2gl.r3

|^r3/lib/trace.r3

#window
#context

#vao 
#vbo 
#vs 
#fs
#sp | shader program

#vboData [
 -1.0 -1.0 0.0
  1.0 -1.0 0.0
  1.0  1.0 0.0
]

:mem2float | cnt to from --
	>a >b ( 1? 1 - da@+ f2fp db!+ ) drop ;

#vertex_shader_text "#version 330 core
layout(location = 0) in vec3 vertexPosition_modelspace;

void main()
{
//We're not modifying positions of vertices
gl_Position.xyz = vertexPosition_modelspace;
gl_Position.w = 1.0;
}"
#vht 'vertex_shader_text
 
#fragment_shader_text "#version 330 core
out vec3 color;
void main()
{
color = vec3(1,0,1);
}"
#fst 'fragment_shader_text 

#GL_COLOR_BUFFER_BIT $4000
#GL_DEPTH_BUFFER_BIT $100
#GL_FRAGMENT_SHADER $8B30
#GL_VERTEX_SHADER $8B31
#GL_ARRAY_BUFFER $8892
#GL_STATIC_DRAW $88E4
#GL_FLOAT $1406
#GL_FALSE 0

#GL_COMPILE_STATUS $8B81
#GL_LINK_STATUS $8B82

#GL_DEPTH_TEST $0B71
#GL_LESS $0201

#GL_TRIANGLES $0004

#ss | error compile
#log * 512
:shCheckErr | ss --
	dup GL_COMPILE_STATUS 'ss glGetShaderiv
	ss 1? ( 2drop ; ) drop
	512 0 'log glGetShaderInfoLog
	'log .println ;

:prCheckErr | ss --
	dup GL_LINK_STATUS 'ss glGetProgramiv
	ss 1? ( 2drop ; ) drop
	512 'ss 'log glGetProgramInfoLog
	'log .println ;
	
:glError
	glGetError 0? ( drop ; ) 
	"Error %d:" .println
	;
	
:glInfo
	$1f00 glGetString .println | vendor
	$1f01 glGetString .println | render
	$1f02 glGetString .println | version
	$8B8C glGetString .println | shader
	;
	
:initgl
	5 1 SDL_GL_SetAttribute		|SDL_GL_DOUBLEBUFFER, 1);
|	13 1 SDL_GL_SetAttribute	|SDL_GL_MULTISAMPLEBUFFERS, 1);
|	14 4 SDL_GL_SetAttribute	|SDL_GL_MULTISAMPLESAMPLES, 8);

    17 4 SDL_GL_SetAttribute |SDL_GL_CONTEXT_MAJOR_VERSION
    18 6 SDL_GL_SetAttribute |SDL_GL_CONTEXT_MINOR_VERSION
	20 2 SDL_GL_SetAttribute |SDL_GL_CONTEXT_FLAGS, SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG);	
	21 2 SDL_GL_SetAttribute |SDL_GL_CONTEXT_PROFILE_MASK,  SDL_GL_CONTEXT_PROFILE_COMPATIBILITY
|SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);
	
	$3231 SDL_init 	
	$1FFF0000 dup 800 600 $2 SDL_CreateWindow 'window !
	window SDL_GL_CreateContext 'context !
|	window context SDL_GL_MakeCurrent
	1 SDL_GL_SetSwapInterval

	InitGLAPI	
	
	glInfo	

	"Vertex" .println
	GL_VERTEX_SHADER glCreateShader 'vs !
	vs 1 'vht 0 glShaderSource
	vs glCompileShader 
	vs shCheckErr 
	glError
	
	"Fragment" .println
	GL_FRAGMENT_SHADER glCreateShader 'fs !
	fs 1 'fst 0 glShaderSource
	fs glCompileShader
	fs shCheckErr
	glError

	"Program" .println
	glCreateProgram 'sp !
	sp vs glAttachShader
	sp fs glAttachShader
	sp glLinkProgram 
	sp glValidateProgram
	sp prCheckErr glError
	
	vs glDeleteShader
	fs glDeleteShader


	1 'vao glGenVertexArrays
	vao glBindVertexArray

	1 'vbo glGenBuffers
	GL_ARRAY_BUFFER vbo glBindBuffer
	GL_ARRAY_BUFFER 9 4 * 'vboData GL_STATIC_DRAW glBufferData

	sp glUseProgram
	0 glEnableVertexAttribArray
	0 3 GL_FLOAT GL_FALSE 0 0 glVertexAttribPointer

	;
		
:glend
	sp glDeleteProgram
	1 'vao glDeleteVertexArrays
	1 'vbo glDeleteBuffers

	context SDL_Gl_DeleteContext
    SDL_Quit
	;

	
:main

|	0 233 0 0 glClearColor | how reeplace this? without floating point?

	$4100 glClear
	
    vao glBindVertexArray

    GL_TRIANGLES 0 3 glDrawArrays

	window SDL_GL_SwapWindow
	SDLkey
	>esc< =? ( exit ) 
	|	16 'fmatrix 'matrix mem2float	
	drop ;	
	
|----------- BOOT
: 	
	9 'vboData 'vboData mem2float
	
	initgl 
	'main SDLshow
	glend 
	;