^r3/lib/gui.r3
^r3/lib/sdl2.r3
^r3/lib/sdl2gl.r3
^r3/lib/sdl2gfx.r3
^r3/lib/3dgl.r3


|-------------------------------------
#flpos * 48
#fprojection * 64
#fview * 64
	
#eyed 8.0
	
#pEye 0.0 0.0 12.0
#pTo 0 0 0
#pUp 0 1.0 0

#xm #ym
#rx #ry

:eyecam
	rx 'pEye 8 + !
	ry sincos eyed *. swap eyed *. 'pEye !+ 8 + !
	'pEye 'pTo 'pUp mlookat 'fview mcpyf ;
	
|----------- data	
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

#instancetype * 4096 | 16x16x16

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

#typeVBO
#instancepalVBO 
#instanceOffsetVBO

#IDprojection
#IDview
#IDpaleta

:2float | cnt mem --
	>a ( 1? 1- da@ f2fp da!+ ) drop ;
	
#paleta [ | uchu
$080a0d $0949ac $b56227 $2e943a
$542690 $a30d30 $fdfdfd $b59944
$878a8b $3984f2 $ff9f5b $64d970
$915ad3 $ea3c65 $cbcdcd $fedf7b ]

#colorPaleta * 192  | 16*3*4 
	
:fillpaleta
	'paleta >a
	'colorPaleta >b
	16 ( 1? 1-
		da@+ 
		dup 16 >> $ff and 1.0 $ff */ f2fp db!+
		dup 8 >> $ff and 1.0 $ff */ f2fp db!+
		$ff and 1.0 $ff */ f2fp db!+
		) drop ;
	
#instanceOffsets * 49152 | 16x16x16*3*4

:fillpos
	'instanceOffsets >a
	0 ( $fff <=? 
		dup $f and 16 << 7.5 - f2fp da!+
		dup 4 >> $f and 16 << 7.5 - f2fp da!+
		dup 8 >> $f and 16 << 7.5 - f2fp da!+
		1+ ) drop ;
	
#instancetype * 4096
	
:prog
	8 3 * 'cubeVertices 2float
	matini
	0.1 1000.0 0.9 3.0 4.0 /. mperspective	| perspective matrix
|	-20.0 20.0 -20.0 20.0 -20.0 20.0 mortho
	'fprojection mcpyf eyecam				| eyemat	


	1 'VAO glGenVertexArrays
	1 'VBO glGenBuffers
	1 'EBO glGenBuffers
	
	1 'instancepalVBO glGenBuffers
	1 'typeVBO glGenBuffers
	1 'instanceOffsetVBO glGenBuffers

	VAO glBindVertexArray

	GL_ARRAY_BUFFER VBO glBindBuffer
	GL_ARRAY_BUFFER 8 3 * 4 * 'cubeVertices GL_STATIC_DRAW glBufferData

	GL_ELEMENT_ARRAY_BUFFER EBO glBindBuffer
	GL_ELEMENT_ARRAY_BUFFER 6 6 * 4 * 'cubeIndices GL_STATIC_DRAW glBufferData

	0 3 GL_FLOAT GL_FALSE 12 0 glVertexAttribPointer
	0 glEnableVertexAttribArray

	GL_ARRAY_BUFFER instancePalVBO glBindBuffer
	GL_ARRAY_BUFFER 16 3 * 4 * 'colorPaleta GL_STATIC_DRAW glBufferData
	
	1 3 GL_FLOAT GL_FALSE 12 0 glVertexAttribPointer
	1 glEnableVertexAttribArray
    1 1 glVertexAttribDivisor

    GL_ARRAY_BUFFER typeVBO glBindBuffer
    GL_ARRAY_BUFFER 16 16 * 16 * 'instancetype GL_STATIC_DRAW glBufferData

    1 1 GL_UNSIGNED_BYTE GL_FALSE 1 0 glVertexAttribPointer
    1 glEnableVertexAttribArray
    1 1 glVertexAttribDivisor | One type per instance
	
	GL_ARRAY_BUFFER instanceOffsetVBO glBindBuffer
	GL_ARRAY_BUFFER 16 16 * 16 * 3 * 4 * 'instanceOffsets GL_STATIC_DRAW glBufferData
	2 3 GL_FLOAT GL_FALSE 12 0 glVertexAttribPointer
	2 glEnableVertexAttribArray
	2 1 glVertexAttribDivisor

	GL_ARRAY_BUFFER 0 glBindBuffer
	0 glBindVertexArray

	;
	
:render
	shaderProgram glUseProgram
	IDprojection 1 0 'fprojection glUniformMatrix4fv 
	IDview 1 0 'fview glUniformMatrix4fv 
	IDpaleta 16 'colorPaleta glUniform3fv 

	VAO glBindVertexArray
	GL_TRIANGLES 36 GL_UNSIGNED_INT 0 16 16 * 16 * glDrawElementsInstanced
	0 glBindVertexArray
	;

|------ vista
:dnlook
	SDLx SDLy 'ym ! 'xm ! ;

:movelook
	SDLx SDLy
	ym over 'ym ! - neg 10 << 'rx +!
	xm over 'xm ! - 7 << neg 'ry +!  
	eyecam
	;

:main
	gui
	'dnlook 'movelook onDnMove	
	SDLGLcls
	render
	SDLGLupdate
	SDLkey
	>esc< =? ( exit ) 
	<up> =? ( -0.1 'eyed +! eyecam )
	<dn> =? ( 0.1 'eyed +! eyecam )	
	drop ;	
	;
	
	
|---------------------------		
#vertexShader
#fragmentShader

|---------------------------------------
#vertexShaderSource "#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in int aType;
layout (location = 2) in vec3 aInstanceOffset;

//uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;
uniform vec3 palette[16];
out vec3 fragColor;

void main() {
	if (aType==0) {
		gl_Position = vec4(0.0, 0.0, 0.0, 0.0);
		gl_Position.w = 0.0; // Clip invisible cubes
		return;
		}
    fragColor = palette[aType];
    gl_Position = projection * view * vec4(aPos + aInstanceOffset, 1.0);
}"
|---------------------------------------
#fragmentShaderSource "#version 330 core
in vec3 fragColor;
out vec4 color;
void main() {
    color = vec4(fragColor, 1.0);
}"
|---------------------------------------
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
	
	dup "projection" glGetUniformLocation 'IDprojection !
	dup "view" glGetUniformLocation 'IDview !
	dup "palette" glGetUniformLocation 'IDpaleta !
	
	'shaderProgram !

	vertexShader glDeleteShader
	fragmentShader glDeleteShader
	;
|-----------------
:glinit
	"voxel gl" 1024 600 SDLinitGL
	glInfo
	GL_DEPTH_TEST glEnable 
	|GL_CULL_FACE glEnable	
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