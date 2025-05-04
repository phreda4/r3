^r3/lib/gui.r3
^r3/lib/sdl2.r3
^r3/lib/sdl2gl.r3
^r3/lib/sdl2gfx.r3
^r3/lib/3dgl.r3
^r3/lib/rand.r3

#voxels 

:genrandcolor
	voxels >a $3ffff ( 1? 1- 
		$3ff randmax
		$ff >? ( 0 nip )
		ca!+ ) drop ;

|----------- data	
#cubeVertices [
-0.5 -0.5 -0.5	 0.5 -0.5 -0.5
 0.5  0.5 -0.5	-0.5  0.5 -0.5
-0.5 -0.5  0.5	 0.5 -0.5  0.5
 0.5  0.5  0.5	-0.5  0.5  0.5
]

#cubeIndices [
0 3 1 3 2 1		1 2 5 2 6 5 
5 6 4 6 7 4		4 7 0 7 3 0
3 7 2 7 6 2		4 0 5 0 1 5
]

|--------------------
#GL_ARRAY_BUFFER $8892
#GL_UNIFORM_BUFFER $8A11
#GL_STATIC_DRAW $88E4
#GL_DYNAMIC_COPY $88EA
#GL_DYNAMIC_DRAW $88E8
#GL_DYNAMIC_READ $88E9

#GL_ELEMENT_ARRAY_BUFFER $8893

#GL_UNSIGNED_BYTE $1401
#GL_UNSIGNED_SHORT $1403
#GL_INT $1404
#GL_UNSIGNED_INT $1405
#GL_FLOAT $1406

#GL_TRIANGLES $4
#GL_FALSE 0

|-------------------------------------
#IDprojection
#fprojection * 64

#IDview
#fview * 64
	
|-------------------------------------
#shaderProgram

#eyed 80.0
	
#pEye 0.0 0.0 82.0
#pTo 0 0 0
#pUp 0 1.0 0

#xm #ym
#rx #ry

:eyecam
	rx 'pEye 8 + !
	ry sincos eyed *. swap eyed *. 'pEye !+ 8 + !
	'pEye 'pTo 'pUp mlookat 'fview mcpyf 
	
	;
	
:2float | cnt mem --
	>a ( 1? 1- da@ f2fp da!+ ) drop ;

#VAO #VBO #EBO
#TypeVBO

|---------------------------		
#vertexShader
#fragmentShader

#vertexShaderSource "#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in float aType; // int no funciona !!

out vec3 fragPos;
flat out vec3 normal;
out vec3 fragColor;

uniform mat4 view;
uniform mat4 projection;

void main() {
	int at=int(aType);
	if (at==0) { // no draw
		gl_Position = vec4(0.0, 0.0, 0.0, 0.0);
		return;
		}

    // Cálculo de posición en un cubo de cubos 4x4x4
    int x = gl_InstanceID&0x3f;
    int y = (gl_InstanceID>>6)&0x3f;
    int z = (gl_InstanceID>>12)&0x3f;

	fragColor = vec3(((at>>5)&7)*1.0/7,((at>>2)&7)*1.0/7,(at&3)*1.0/3);
	
    vec3 instanceOffset = vec3(-32.0,-32.0,-32.0)+vec3(x, y, z); // (16*1.1)/2

    fragPos = aPos + instanceOffset;
    normal = normalize(aPos); // Normales para sombreado
    gl_Position = projection * view * vec4(fragPos, 1.0);
	}"

#fragmentShaderSource "#version 330 core
in vec3 fragPos;
flat in vec3 normal;
in vec3 fragColor;

out vec4 color;

uniform vec3 lightDir = normalize(vec3(1.0, 0.2, 1.3));

void main() {
    float diff = max(dot(normal, lightDir), 0.0);
    vec3 litColor = fragColor*diff + fragColor*0.6;

    color = vec4(litColor, 1.0);
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
	
:inishader
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
	
|--------- VARS
	dup "projection" glGetUniformLocation 'IDprojection !
	dup "view" glGetUniformLocation 'IDview !
	'shaderProgram !

	vertexShader glDeleteShader
	fragmentShader glDeleteShader
	;

:progshader
	|genrandcolor
	|fillpaleta
	8 3 * 'cubeVertices 2float

    1 'VAO glGenVertexArrays
    1 'VBO glGenBuffers
    1 'EBO glGenBuffers
	1 'typeVBO glGenBuffers
	
    VAO glBindVertexArray

	GL_ARRAY_BUFFER VBO glBindBuffer			| vertices
	GL_ARRAY_BUFFER 8 3 * 4 * 'cubeVertices GL_STATIC_DRAW glBufferData

	GL_ELEMENT_ARRAY_BUFFER EBO glBindBuffer	| indices
	GL_ELEMENT_ARRAY_BUFFER 6 6 * 4 * 'cubeIndices GL_STATIC_DRAW glBufferData

	0 3 GL_FLOAT GL_FALSE 12 0 glVertexAttribPointer
	0 glEnableVertexAttribArray
	
	GL_ARRAY_BUFFER typeVBO glBindBuffer		| typos
	GL_ARRAY_BUFFER $fffff voxels GL_STATIC_DRAW glBufferData
	1 1 GL_UNSIGNED_BYTE GL_FALSE 1 0 glVertexAttribPointer | ??? pasa como float!!!
	1 glEnableVertexAttribArray
    1 1 glVertexAttribDivisor

	GL_ARRAY_BUFFER 0 glBindBuffer
	0 glBindVertexArray
	
	matini
	0.9 500.0 0.9 3.0 4.0 /. mperspective	| perspective matrix
|	-40.0 40.0 -40.0 40.0 -40.0 40.0 mortho
	'fprojection mcpyf 
	eyecam				| eyemat	
	;

:renderviews
	GL_ARRAY_BUFFER typeVBO glBindBuffer		| typos
	GL_ARRAY_BUFFER 0 $fffff voxels glBufferSubData
	
	shaderProgram glUseProgram
	IDprojection 1 0 'fprojection glUniformMatrix4fv 
	IDview 1 0 'fview glUniformMatrix4fv 
	VAO glBindVertexArray
	GL_TRIANGLES 36 GL_UNSIGNED_INT 0 $3ffff glDrawElementsInstanced
	0 glBindVertexArray
	
	;

|------ vista
:dnlook
	SDLx SDLy 'ym ! 'xm ! ;

:movelook
	SDLx SDLy
	ym over 'ym ! - neg 14 << 'rx +!
	xm over 'xm ! - 7 << neg 'ry +!  
	eyecam
	;

:main
	gui
	'dnlook 'movelook onDnMove	
	SDLGLcls
	renderviews
	SDLGLupdate
	SDLkey
	>esc< =? ( exit ) 
	<up> =? ( -1.0 'eyed +! eyecam )
	<dn> =? ( 1.0 'eyed +! eyecam )	
	<f1> =? ( genrandcolor )
	drop ;	
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
	here 'voxels !
	$3ffff 'here +!
	glinit
 	inishader
	progshader
	'main SDLshow
	glend 
	;	