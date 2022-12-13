|#include <GL/gl3w.h>
|#include <SDL.h>
^r3/win/sdl2.r3
^r3/win/glew.r3

#width 640
#height 480

#window
#context

| data for a fullscreen quad
#vertexData
[ 0 0 0 0 0 0 ]
[ 0 0 0 0 0 0 ]
[ 0 0 0 0 0 0 ]
[ 0 0 0 0 0 0 ]
[ 0 0 0 0 0 0 ]
[ 0 0 0 0 0 0 ]

|  X     Y     Z           R     G     B
:fillvertex
	-1.0 f2fp 0.0 f2fp 1.0 f2fp
	'vertexData >a
	dup da!+ dup da!+ over da!+ dup da!+ over da!+ over da!+
	pick2 da!+ dup da!+ over da!+ over da!+ dup da!+ over da!+
	dup da!+ pick2 da!+ over da!+ over da!+ over da!+ dup da!+ 
	dup da!+ pick2 da!+ over da!+ over da!+ over da!+ dup da!+ 
	pick2 da!+ dup da!+ over da!+ over da!+ dup da!+ over da!+	
	dup da!+ pick2 da!+ over da!+ dup da!+ over da!+ over da!+	
	3drop ;
	
|       1.0f, 1.0f, 0.0f,       1.0f, 0.0f, 0.0f, // vertex 0
|      -1.0f, 1.0f, 0.0f,       0.0f, 1.0f, 0.0f, // vertex 1
|       1.0f,-1.0f, 0.0f,       0.0f, 0.0f, 1.0f, // vertex 2
|       1.0f,-1.0f, 0.0f,       0.0f, 0.0f, 1.0f, // vertex 3
|      -1.0f, 1.0f, 0.0f,       0.0f, 1.0f, 0.0f, // vertex 4
|      -1.0f,-1.0f, 0.0f,       1.0f, 0.0f, 0.0f, // vertex 5

| shader source code
#vertex_source "#version 330
layout(location = 0) in vec4 vposition;
layout(location = 1) in vec4 vcolor;
out vec4 fcolor;
void main() {
   fcolor = vcolor;
   gl_Position = vposition;
}"

#fragment_source "#version 330
in vec4 fcolor;
layout(location = 0) out vec4 FragColor;
void main() {
   FragColor = fcolor;
}"

| program and shader handles
#shader_program
#vertex_shader
#fragment_shader

| vao and vbo handle
#vao #vbo

#GL_COLOR_BUFFER_BIT $00004000
#GL_FRAGMENT_SHADER $8B30
#GL_VERTEX_SHADER $8B31
#GL_ARRAY_BUFFER $8892
#GL_STATIC_DRAW $88E4
#GL_FLOAT $1406
#GL_FALSE 0

#GL_TRIANGLES $0004

#varr
#carr

:initgl
	"SDL2" width height SDLinitGL 
	
|	$3231 SDL_init  

    | select opengl version
|    21 1 SDL_GL_SetAttribute |(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
|    17 3 SDL_GL_SetAttribute |(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
|    18 3 SDL_GL_SetAttribute |(SDL_GL_CONTEXT_MINOR_VERSION, 3);

    | create a window
|	"SDL2" 0 0 width height $6 SDL_CreateWindow 'window ! | 2 or 4
|	window SDL_GL_CreateContext 'context !


	glewInit

"a" .println

    | create and compiler vertex shader
    GL_VERTEX_SHADER glCreateShader 'vertex_shader !
"d" .println
	'vertex_source 1 'carr d! 'varr !

	
    vertex_shader 1 'varr 'carr |vertex_source count 
	glShaderSource
"e" .println
	
    vertex_shader glCompileShader

"b" .println
    | create and compiler fragment shader
    GL_FRAGMENT_SHADER glCreateShader 'fragment_shader !
    fragment_shader 1 'fragment_source count glShaderSource
    fragment_shader glCompileShader

    | create program
    glCreateProgram 'shader_program !

"c" .println
    | attach shaders
    shader_program vertex_shader glAttachShader
    shader_program fragment_shader glAttachShader

    | link the program and check for errors
    shader_program glLinkProgram

    | generate and bind the vao
    1 'vao glGenVertexArrays
    vao glBindVertexArray

    | generate and bind the buffer object
    1 'vbo glGenBuffers
    GL_ARRAY_BUFFER vbo glBindBuffer

    | fill with data
    GL_ARRAY_BUFFER 4 6 * 6 * vertexData GL_STATIC_DRAW glBufferData

    | set up generic attrib pointers
    0 glEnableVertexAttribArray
    0 3 GL_FLOAT GL_FALSE 6 4 * 0 glVertexAttribPointer

    1 glEnableVertexAttribArray
    1 3 GL_FLOAT GL_FALSE 6 4 * 4 3 * glVertexAttribPointer
	
	fillvertex
	;
	
:glend
    1 'vao glDeleteVertexArrays
    1 'vbo glDeleteBuffers

    shader_program vertex_shader glDetachShader
	
    shader_program fragment_shader glDetachShader
    vertex_shader glDeleteShader
    fragment_shader glDeleteShader
    shader_program glDeleteProgram

    context SDL_GL_DeleteContext
    window SDL_DestroyWindow
    SDL_Quit
	;

:main
	GL_COLOR_BUFFER_BIT glClear
	shader_program glUseProgram
	vao glBindVertexArray
	GL_TRIANGLES 0 6 glDrawArrays

	window SDL_GL_SwapWindow
	SDLkey
	>esc< =? ( exit ) 
	drop ;
		

: 	initgl 
	'main SDLshow
	glend 
	;