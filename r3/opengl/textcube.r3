| OpenGL example
| PHREDA 2023
^r3/win/sdl2.r3
^r3/win/sdl2gl.r3
^r3/win/sdl2image.r3
^r3/lib/3d.r3
^r3/lib/gui.r3

#xcam 0 #ycam 0 #zcam -3.0

| opengl Constant
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

#GL_TEXTURE $1702
#GL_TEXTURE0 $84C0
#GL_TEXTURE_2D $0DE1
#GL_TEXTURE_2D_ARRAY $8C1A
#GL_TEXTURE_3D $806F

#GL_RGB $1907
#GL_RGBA $1908

#GL_UNSIGNED_BYTE $1401
#GL_TEXTURE_MAG_FILTER $2800
#GL_TEXTURE_MIN_FILTER $2801
#GL_LINEAR $2601

#matrix [
0.5  0.0 0.0  0.0
0.0  0.5 0.0  0.0
0.0  0.0 0.5  0.0
0.25 0.5 0.75 1.0 ]
#fmatrix * 64

#vertex_shader_text "#version 330 core
// Input vertex data, different for all executions of this shader.
layout(location = 0) in vec3 vertexPosition_modelspace;
layout(location = 1) in vec2 vertexUV;
out vec2 UV; // Output data ; will be interpolated for each fragment.
uniform mat4 MVP; // Values that stay constant for the whole mesh.
void main(){
	gl_Position =  MVP * vec4(vertexPosition_modelspace,1); // Output position of the vertex, in clip space : MVP * position
	UV = vertexUV; // UV of the vertex. No special space for this one.
}"
#vht 'vertex_shader_text
 
#fragment_shader_text "#version 330 core
// Interpolated values from the vertex shaders
in vec2 UV;
out vec3 color; // Ouput data
uniform sampler2D myTextureSampler; // Values that stay constant for the whole mesh.
void main(){
	color = texture( myTextureSampler, UV ).rgb; 	// Output color = color of the texture at the specified UV
}"
#fst 'fragment_shader_text 

#g_vertex_buffer_data [
-1.0 -1.0 -1.0 
-1.0 -1.0  1.0 
-1.0  1.0  1.0 
 1.0  1.0 -1.0 
-1.0 -1.0 -1.0 
-1.0  1.0 -1.0 
 1.0 -1.0  1.0 
-1.0 -1.0 -1.0 
 1.0 -1.0 -1.0 
 1.0  1.0 -1.0 
 1.0 -1.0 -1.0 
-1.0 -1.0 -1.0 
-1.0 -1.0 -1.0 
-1.0  1.0  1.0 
-1.0  1.0 -1.0 
 1.0 -1.0  1.0 
-1.0 -1.0  1.0 
-1.0 -1.0 -1.0 
-1.0  1.0  1.0 
-1.0 -1.0  1.0 
 1.0 -1.0  1.0 
 1.0  1.0  1.0 
 1.0 -1.0 -1.0 
 1.0  1.0 -1.0 
 1.0 -1.0 -1.0 
 1.0  1.0  1.0 
 1.0 -1.0  1.0 
 1.0  1.0  1.0 
 1.0  1.0 -1.0 
-1.0  1.0 -1.0 
 1.0  1.0  1.0 
-1.0  1.0 -1.0 
-1.0  1.0  1.0 
 1.0  1.0  1.0 
-1.0  1.0  1.0 
 1.0 -1.0  1.0
]

#g_uv_buffer_data [
0.0000	1.0000
0.0001	0.6640
0.3359	0.6641
1.0000	1.0000
0.6679	0.6641
0.9999	0.6639
0.6679	0.6641
0.3360	0.3281
0.6679	0.3281
1.0000	1.0000
0.6681	1.0000
0.6679	0.6641
0.0000	1.0000
0.3359	0.6641
0.3360	0.9999
0.6679	0.6641
0.3359	0.6641
0.3360	0.3281
1.0000	0.3282
0.9999	0.6639
0.6679	0.6641
0.6681	1.0000
0.3359	0.6641
0.6679	0.6641
0.3359	0.6641
0.6681	1.0000
0.3360	0.9999
0.0001	0.6640
0.0000	0.3281
0.3360	0.3281
0.0001	0.6640
0.3360	0.3281
0.3359	0.6641
0.6679	0.3281
1.0000	0.3282
0.6679	0.6641
]

:mem2float | cnt to from --
	>a >b ( 1? 1 - da@+ f2fp db!+ ) drop ;

:glInfo
	$1f00 glGetString .println | vendor
	$1f01 glGetString .println | render
	$1f02 glGetString .println | version
	$8B8C glGetString .println | shader
	;
	
#programID #vs #fs
#VertexArrayID
#MatrixID
#vertexbuffer	
#uvbuffer
#texture
#textureID

|--- sdl2 surface
|struct SDL_Surface
|	flags           dd ? 0 dd ? 4
|	?format        	dq ? 8 8
|	w               dd ? 16 4
|	h               dd ? 20 4
|	pitch           dd ? 24 4 dd ? 28 4
|	pixels          dq ? 32 8
|	userdata        dq ?
|	locked          dd ? dd ?
|	lock_data       dq ?
|	clip_rect       SDL_Rect
|	map             dq ?
|	refcount        dd ? dd ?
#surface
:Surface->w surface 16 + d@ ;
:Surface->h surface 20 + d@ ;
:Surface->pixels surface 32 + @ ;
:Surface->format->bpp surface 8 + @ 16 + c@ ;
:GLBPP Surface->format->bpp 4 =? ( drop GL_RGB ; ) drop GL_RGBA ;
	
|-----------------------------------------------	
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
	glGetError 0? ( drop ; ) "Error %d:" .println ;
	

:loadshaders
|	"Vertex" .println
	GL_VERTEX_SHADER glCreateShader 'vs !
	vs 1 'vht 0 glShaderSource
	vs glCompileShader 
	vs shCheckErr glError
	
|	"Fragment" .println
	GL_FRAGMENT_SHADER glCreateShader 'fs !
	fs 1 'fst 0 glShaderSource
	fs glCompileShader
	fs shCheckErr glError

|	"Program:" .println
	glCreateProgram 'programID !
	programID vs glAttachShader
	programID fs glAttachShader
	programID glLinkProgram 
	programID glValidateProgram
	programID prCheckErr glError
	
	vs glDeleteShader
	fs glDeleteShader
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
	
	"test opengl" 800 600 SDLinitGL
	
	glInfo	

	GL_DEPTH_TEST glEnable 
	GL_LESS glDepthFunc 
	
	1 'VertexArrayID glGenVertexArrays
	VertexArrayID glBindVertexArray
	
	loadshaders

	|GLuint Texture = loadDDS("uvtemplate.DDS");
|---------------------------	
	"media/img/lolomario.png" IMG_Load 'Surface !
 
	1 'Texture glGenTextures
	GL_TEXTURE_2D Texture glBindTexture
 
	GL_TEXTURE_2D 0 GLBPP Surface->w Surface->h 0 pick3 GL_UNSIGNED_BYTE Surface->pixels glTexImage2D
	GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_LINEAR glTexParameteri
	GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_LINEAR glTexParameteri

|---------------------------	
	programID "MVP" glGetUniformLocation 'MatrixID !
	programID "myTextureSampler" glGetUniformLocation 'TextureID !
	
	1 'vertexbuffer glGenBuffers
	GL_ARRAY_BUFFER vertexbuffer glBindBuffer
	GL_ARRAY_BUFFER 36 3 * 2 << 'g_vertex_buffer_data GL_STATIC_DRAW glBufferData

	1 'uvbuffer glGenBuffers
	GL_ARRAY_BUFFER uvbuffer glBindBuffer
	GL_ARRAY_BUFFER 36 2 * 2 << 'g_uv_buffer_data GL_STATIC_DRAW glBufferData

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

|--------------	
:main
	gui
	'dnlook 'movelook onDnMove
	
	|1.0 3dmode
	| Projection matrix : 45° Field of View, 4:3 ratio, display range : 0.1 unit <-> 100 units
	|perspective(tan(45.0f/2), 4.0f / 3.0f, 0.1f, 100.0f);	
	0.9 4.0 3.0 /. 0.1 1000.0 matper
	rx mrotxi ry mrotyi
	xcam ycam zcam mtransi
	
|	mper
|mprint	
|	m*
|mprint	
	$4100 glClear

|......
	programID glUseProgram
	
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

	GL_TRIANGLES 0 12 3 * glDrawArrays

	0 glDisableVertexAttribArray
	1 glDisableVertexAttribArray

|......		
	SDL_windows SDL_GL_SwapWindow
	SDLkey
	>esc< =? ( exit ) 	
	drop ;	
	
|----------- BOOT
: 	
	36 3 * 'g_vertex_buffer_data 'g_vertex_buffer_data mem2float
	36 2 * 'g_uv_buffer_data 'g_uv_buffer_data mem2float
	
	16 'fmatrix 'matrix mem2float	
	
	initgl 
	'main SDLshow
	glend 
	;	