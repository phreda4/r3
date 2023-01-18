| OpenGL example
| PHREDA 2023
^r3/win/sdl2.r3
^r3/win/sdl2gl.r3

|^r3/lib/trace.r3

#window
#context

#matrix [
0.5 0.0 0.0 0.0
0.0 0.5 0.0 0.0
0.0 0.0 0.5 0.0
0.25 0.5 0.75 1.0
]

:mat2float
	'matrix >a 16 ( 1? 1 - da@ f2fp da!+  ) drop ;
	
#vao 
#vbo 
#vs 
#fs

#vertex_shader_text "#version 400
layout(location = 0) in vec3 vertex_position;
layout(location = 1) in vec3 vertex_colour;
out vec3 color;
uniform mat4 matrix;
void main () {
  color = vertex_colour;
	gl_Position=matrix * vec4(vertex_position, 1.0);
}"
#vht 'vertex_shader_text
 
#fragment_shader_text "#version 400
in vec3 color;
out vec4 frag_colour;
void main () {
	frag_colour = vec4 (color, 1.0);
	}"
#fst 'fragment_shader_text 

#sp | shader program

#ss | error compile

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

| data for a fullscreen quad
#vertexData
[ 0 0 0 ]
[ 0 0 0 ]
[ 0 0 0 ]

:fillvertex
	-0.5 f2fp 0.0 f2fp 0.5 f2fp
	'vertexData >a
	pick2 da!+ pick2 da!+ over da!+
	dup da!+ pick2 da!+ over da!+
	over da!+ dup da!+ over da!+
	3drop ;

	
#matrix_location
	
#log * 512

:glcompst | ss --
	dup GL_COMPILE_STATUS 'ss glGetShaderiv
	ss 1? ( 2drop ; ) drop
	512 0 'log glGetShaderInfoLog
	'log .println ;
	
:gllinkst | ss --
	dup GL_LINK_STATUS 'ss glGetProgramiv
	ss 1? ( 2drop ; ) drop
	512 0 'log glGetShaderInfoLog
	'log .println ;
	

:glInfo
	$1f00 glGetString .println | vendor
	$1f01 glGetString .println | render
	$1f02 glGetString .println | version
	$8B8C glGetString .println | shader
	;
	
:initgl
    | select opengl version
	20 2 SDL_GL_SetAttribute |(SDL_GL_CONTEXT_FLAGS, SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG);
    17 4 SDL_GL_SetAttribute |(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    18 0 SDL_GL_SetAttribute |(SDL_GL_CONTEXT_MINOR_VERSION, 3);
	21 2 SDL_GL_SetAttribute |(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);	
|SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);

|	13 1 SDL_GL_SetAttribute |  SDL_GL_SetAttribute(SDL_GL_MULTISAMPLEBUFFERS, 1);
|	14 4 SDL_GL_SetAttribute   |SDL_GL_SetAttribute(SDL_GL_MULTISAMPLESAMPLES, 8);
5 1 SDL_GL_SetAttribute |  SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
	
	$3231 SDL_init 	
	$1FFF0000 dup 800 600 $2 SDL_CreateWindow 'window !
	window SDL_GL_CreateContext 'context !
|	window context SDL_GL_MakeCurrent
	1 SDL_GL_SetSwapInterval

	InitGLAPI	
	glInfo	
	
	GL_DEPTH_TEST glEnable 
	GL_LESS glDepthFunc 

	1 'vao glGenVertexArrays
	vao glBindVertexArray
|	vao "vao:%d" .println

	1 'vbo glGenBuffers
	GL_ARRAY_BUFFER vbo glBindBuffer
|	vbo "vbo:%d" .println
	
	GL_ARRAY_BUFFER 9 2 << 'vertexData GL_STATIC_DRAW  glBufferData
	0 3 GL_FLOAT GL_FALSE 3 2 << 0 glVertexAttribPointer
	0 glEnableVertexAttribArray

	GL_VERTEX_SHADER glCreateShader 'vs !
	vs 1 'vht 0 glShaderSource
	vs glCompileShader
	
	vs glcompst 
	
	GL_FRAGMENT_SHADER glCreateShader 'fs !
	fs 1 'fst 0 glShaderSource
	fs glCompileShader

	fs glcompst
	
	glCreateProgram 'sp !
	sp fs glAttachShader
	sp vs glAttachShader
	sp glLinkProgram 
	
	sp gllinkst
	
	sp "matrix" glGetUniformLocation 'matrix_location !
	
	vs glDeleteShader
	fs glDeleteShader
	;
		
:glend
	sp glDeleteProgram
	1 'vao glDeleteVertexArrays
	1 'vbo glDeleteBuffers

	context SDL_Gl_DeleteContext
    SDL_Quit
	;

:main

	matrix_location 1 GL_FALSE 'matrix glUniformMatrix4fv 
|	0 233 0 0 glClearColor
	$4100 glClear
	sp glUseProgram
	vao glBindVertexArray
	GL_TRIANGLES 0 3 glDrawArrays

	window SDL_GL_SwapWindow
	
	SDLkey
	>esc< =? ( exit ) 
	drop ;	
	
|----------- BOOT
: 	
	fillvertex
	mat2float	

	initgl 
	'main SDLshow
	glend 
	;