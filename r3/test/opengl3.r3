^r3/win/sdl2.r3
^r3/win/glew.r3

#window
#context

#vao 0 
#vbo 0 
#vs #fs

#vertex_shader_text 
"#version 400
in vec3 vp;
void main() {
	gl_Position = vec4(vp,1.0);
}"
#vht 'vertex_shader_text
 
#fragment_shader_text 
"#version 400
out vec4 frag_color;
void main() {
	frag_color = vec4(0.5,0.0,0.5,1.0); 	
}"
#fst 'fragment_shader_text 

#sp

#GL_COLOR_BUFFER_BIT $4000
#GL_DEPTH_BUFFER_BIT $100
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
	window context SDL_GL_MakeCurrent


	fillvertex
	1 glewExperimental d!
	glewInit 	
	
	0 0 800 600 glViewport
	
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
	
	1 'vbo glGenBuffers
	GL_ARRAY_BUFFER vbo glBindBuffer
	GL_ARRAY_BUFFER 9 4 * 'vertexData GL_STATIC_DRAW  glBufferData
	
	1 'vao glGenVertexArrays
	vao glBindVertexArray
	0 glEnableVertexAttribArray
	GL_ARRAY_BUFFER vbo glBindBuffer
	0 3 GL_FLOAT GL_FALSE 0 0 glVertexAttribPointer
	
	GL_VERTEX_SHADER glCreateShader 'vs !
	vs 1 'vht 0 glShaderSource
	vs glCompileShader
	
	GL_FRAGMENT_SHADER glCreateShader 'fs !
	fs 1 'fst 0 glShaderSource
	fs glCompileShader
	
	glCreateProgram 'sp !
	fs sp glAttachShader
	vs sp glAttachShader
	sp glLinkProgram 
	;
		
:glend
	1 'vao glDeleteVertexArrays
	1 'vbo glDeleteBuffers

	context SDL_Gl_DeleteContext
    SDL_Quit
	;

:main
	GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT or glClear
	sp glUseProgram
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