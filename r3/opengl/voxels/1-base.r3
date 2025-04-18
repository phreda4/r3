^r3/lib/gui.r3
^r3/lib/sdl2.r3
^r3/lib/sdl2gl.r3
^r3/lib/sdl2gfx.r3
^r3/lib/3dgl.r3


#cubeVertices [
    | Positions     
    -0.5 -0.5 -0.5  | Bottom-let
     0.5 -0.5 -0.5  | Bottom-right
     0.5  0.5 -0.5  | Top-right
    -0.5  0.5 -0.5  | Top-let

    -0.5 -0.5  0.5
     0.5 -0.5  0.5
     0.5  0.5  0.5
    -0.5  0.5  0.5
]

#cubeIndices [
    0 1 2 2 3 0 | Back ace
    4 5 6 6 7 4 | ront ace
    0 1 5 5 4 0 | Bottom ace
    3 2 6 6 7 3 | Top ace
    0 3 7 7 4 0 | Let ace
    1 2 6 6 5 1  | Right ace
]

#instanceColors [
    1.0 0.0 0.0 | Red
    0.0 1.0 0.0 | Green
    0.0 0.0 1.0 | Blue
    1.0 1.0 0.0  | Yellow
]

#instanceOffsets [
    -1.0  0.0 0.0 | Oset or the irst cube
     1.0  0.0 0.0 | Oset or the second cube
     0.0 -1.0 0.0 | Oset or the third cube
     0.0  1.0 0.0  | Oset or the ourth cube
]

#GL_ARRAY_BUFFER $8892
#GL_STATIC_DRAW $88E4
#GL_ELEMENT_ARRAY_BUFFER $8893

#GL_UNSIGNED_BYTE $1401
#GL_UNSIGNED_SHORT $1403
#GL_INT $1404
#GL_UNSIGNED_INT $1405
#GL_FLOAT $1406

#GL_TRIANGLES $4
#GL_FALSE 0

#shaderProgram
#VAO #VBO #EBO
#instanceColorVBO 
#instanceOffsetVBO

:2float | cnt mem --
	>a ( 1? 1- da@ f2fp da!+ ) drop ;
	
:prog
	8 3 * 'cubeVertices 2float
	4 3 * 'instanceColors 2float
	4 3 * 'instanceOffsets 2float

	1 'VAO glGenVertexArrays
	1 'VBO glGenBuffers
	1 'EBO glGenBuffers
	1 'instanceColorVBO glGenBuffers
	1 'instanceOffsetVBO glGenBuffers

	VAO glBindVertexArray

	GL_ARRAY_BUFFER VBO glBindBuffer
	GL_ARRAY_BUFFER 8 3 * 4 * 'cubeVertices GL_STATIC_DRAW glBufferData

	GL_ELEMENT_ARRAY_BUFFER EBO glBindBuffer
	GL_ELEMENT_ARRAY_BUFFER 6 6 * 4 * 'cubeIndices GL_STATIC_DRAW glBufferData

	0 3 GL_FLOAT GL_FALSE 12 0 glVertexAttribPointer
	0 glEnableVertexAttribArray

	GL_ARRAY_BUFFER instanceColorVBO glBindBuffer
	GL_ARRAY_BUFFER 4 3 * 4 * 'instanceColors GL_STATIC_DRAW glBufferData
	1 3 GL_FLOAT GL_FALSE 12 0 glVertexAttribPointer
	1 glEnableVertexAttribArray
    1 1 glVertexAttribDivisor

	GL_ARRAY_BUFFER instanceOffsetVBO glBindBuffer
	GL_ARRAY_BUFFER 4 3 * 4 * 'instanceOffsets GL_STATIC_DRAW glBufferData
	2 3 GL_FLOAT GL_FALSE 12 0 glVertexAttribPointer
	2 glEnableVertexAttribArray
	2 1 glVertexAttribDivisor

	GL_ARRAY_BUFFER 0 glBindBuffer
	0 glBindVertexArray
	;
	
:render
	shaderProgram glUseProgram
	VAO glBindVertexArray
	GL_TRIANGLES 36 GL_UNSIGNED_INT 0 4 glDrawElementsInstanced
	0 glBindVertexArray
	;
	
:main
	gui
	SDLGLcls
	render
	SDLGLupdate
	SDLkey
	>esc< =? ( exit ) 	
	drop ;	
	;
	
	
|---------------------------		
#vertexShader
#fragmentShader


#vertexShaderSource "#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aInstanceColor;
layout (location = 2) in vec3 aInstanceOffset;
out vec3 fragColor;
void main() {
    fragColor = aInstanceColor;
    gl_Position = vec4(aPos + aInstanceOffset, 1.0);
}"

#fragmentShaderSource "#version 330 core
in vec3 fragColor;
out vec4 color;
void main() {
    color = vec4(fragColor, 1.0);
}"

#vs 'vertexShaderSource
#fs 'fragmentShaderSource

#GL_COMPILE_STATUS $8B81
#GL_LINK_STATUS $8B82
#GL_FRAGMENT_SHADER $8B30
#GL_VERTEX_SHADER $8B31

#GL_DEPTH_TEST $0B71
#GL_LESS $0201
#GL_CULL_FACE $0B44

#t
:shCheckErr | ss --
	dup GL_COMPILE_STATUS 't glGetShaderiv
	t 1? ( 2drop ; ) drop
	512 0 here glGetShaderInfoLog
	here .println .input ;
	
:prCheckErr | ss --
	dup GL_LINK_STATUS 't glGetProgramiv
	t 1? ( 2drop ; ) drop
	512 't here glGetProgramInfoLog
	here .println .input ;
	
:ini	
	GL_VERTEX_SHADER glCreateShader dup 
	dup 1 'vs 0 glShaderSource
	dup glCompileShader 
	dup GL_COMPILE_STATUS 't glGetShaderiv 
	t 0? ( drop shCheckErr ; ) drop
	'vertexShader !

	GL_FRAGMENT_SHADER glCreateShader dup
	dup 1 'fs 0 glShaderSource
	dup glCompileShader
	dup GL_COMPILE_STATUS 't glGetShaderiv 
	t 0? ( drop shCheckErr ; ) drop
	'fragmentShader ! 

	glCreateProgram 
	dup vertexShader glAttachShader
	dup fragmentShader glAttachShader
	dup glLinkProgram 
	dup glValidateProgram
	dup GL_LINK_STATUS 't glGetProgramiv 
	t 0? ( drop prCheckErr ; ) drop
	
	vertexShader glDeleteShader
	fragmentShader glDeleteShader
	
	'shaderProgram !
	;
|-----------------
:glinit
	"voxel gl" 1024 600 SDLinitGL
	glInfo
	GL_DEPTH_TEST glEnable 
	GL_CULL_FACE glEnable	
	GL_LESS glDepthFunc 
	;	
	
:glend
	shaderProgram glDeleteProgram
    SDL_Quit ;
	
|----------- BOOT
:
	glinit
 	ini
	prog
	'main SDLshow
	glend 
	;	