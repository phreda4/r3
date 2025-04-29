^r3/lib/gui.r3
^r3/lib/sdl2.r3
^r3/lib/sdl2gl.r3
^r3/lib/sdl2gfx.r3
^r3/lib/3dgl.r3
^r3/lib/rand.r3

#conw 80
#conh 50
#console * $3fff | 80 x 50 x 4

:genrandcon
	'console >a 
	$fff ( 1? 1- 
		$ff randmax 
		da!+ ) drop ;

|----------- data	
|// Posiciones     // Coordenadas UV
#vertices [
0 			0 			0 			$3f800000	| Inf Izq
$3f800000 	0 			$3f800000 	$3f800000	| inf Der
$3f800000 	$3f800000 	$3f800000 	0			| Sup Der
0 			$3f800000 	0 			0			| sup Izq
]

|--------------------
#GL_ARRAY_BUFFER $8892
#GL_UNIFORM_BUFFER $8A11
#GL_STATIC_DRAW $88E4
#GL_DYNAMIC_COPY $88EA
#GL_DYNAMIC_DRAW $88E8
#GL_DYNAMIC_READ $88E9

#GL_ELEMENT_ARRAY_BUFFER $8893

#GL_TEXTURE_2D $0DE1

#GL_UNSIGNED_BYTE $1401
#GL_UNSIGNED_SHORT $1403
#GL_INT $1404
#GL_UNSIGNED_INT $1405
#GL_FLOAT $1406

#GL_TRIANGLES $4
#GL_TRIANGLE_FAN $6
#GL_FALSE 0

|-------------------------------------
#shaderProgram


:2float | cnt mem --
	>a ( 1? 1- da@ f2fp da!+ ) drop ;

#VAO #VBO #EBO
#fontTextureID
#consoleVBO

|---------------------------		
#vertexShader
#fragmentShader

#vertexShaderSource "#version 330 core
layout (location = 0) in vec2 aPos;       // Posiciones del quad (local)
layout (location = 1) in vec2 aTexCoord; // Coordenadas UV del quad
layout (location = 2) in vec3 instanceData; // Datos de la instancia: (nroCaracter, x, y)

out vec2 TexCoord;

uniform vec2 scale; // Escala global para caracteres

void main() {
    int charIndex = int(instanceData.x); // Índice del carácter
    float xOffset = instanceData.y;     // X de la posición
    float yOffset = instanceData.z;     // Y de la posición

    // Calculamos las coordenadas UV
    float u = (charIndex % 16) / 16.0;  // Columna del carácter
    float v = (charIndex / 16) / 16.0;  // Fila del carácter
    float uStep = 1.0 / 16.0;           // Ancho de un carácter en UV
    float vStep = 1.0 / 16.0;           // Alto de un carácter en UV

    TexCoord = vec2(aTexCoord.x * uStep + u, aTexCoord.y * vStep + v);

    // Calculamos la posición del vértice en pantalla
    gl_Position = vec4(aPos * scale + vec2(xOffset, yOffset), 0.0, 1.0);
}"

#fragmentShaderSource "#version 330 core
out vec4 FragColor;

in vec2 TexCoord;

uniform sampler2D fontTexture;

void main() {
    FragColor = texture(fontTexture, TexCoord);
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

	vertexShader glDeleteShader
	fragmentShader glDeleteShader

|--------- VARS

|	dup "projection" glGetUniformLocation 'IDprojection !
|	dup "view" glGetUniformLocation 'IDview !
	'shaderProgram !
	;

:progshader
    1 'VAO glGenVertexArrays
    1 'VBO glGenBuffers
	
    VAO glBindVertexArray

	GL_ARRAY_BUFFER VBO glBindBuffer			| vertices
	GL_ARRAY_BUFFER 4 4 * 4 * 'Vertices GL_STATIC_DRAW glBufferData

|// Posiciones
    0 2 GL_FLOAT GL_FALSE 4 4 * 0 glVertexAttribPointer
    0 glEnableVertexAttribArray
	
|// Coordenadas UV
    1 2 GL_FLOAT GL_FALSE 4 4 * 4 2 * glVertexAttribPointer
    1 glEnableVertexAttribArray

	1 'consoleVBO glGenBuffers
	GL_ARRAY_BUFFER consoleVBO glBindBuffer		| typos
	
|	GL_ARRAY_BUFFER $1fff 'console GL_STATIC_DRAW glBufferData
	
	2 4 GL_INT GL_FALSE 4 0 glVertexAttribPointer | ??? pasa como float!!!
	2 glEnableVertexAttribArray
    2 1 glVertexAttribDivisor

	GL_ARRAY_BUFFER 0 glBindBuffer
	0 glBindVertexArray
	;

:renderviews
	GL_ARRAY_BUFFER consoleVBO glBindBuffer		| typos
	GL_ARRAY_BUFFER $3fff 'console GL_DYNAMIC_DRAW glBufferData
	
	shaderProgram glUseProgram
	GL_TEXTURE_2D fontTextureID glBindTexture
	VAO glBindVertexArray
	
	GL_TRIANGLE_FAN 0 4 10 glDrawElementsInstanced
	0 glBindVertexArray
	0 glUseProgram 
	;

|------ vista
:main
	gui
	SDLGLcls
	
	renderviews
	SDLGLupdate
	SDLkey
	>esc< =? ( exit ) 
	drop ;	
	;
	
	
|-----------------
:glinit
	"gl console" 1024 600 SDLinitGL
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
 	inishader
	progshader
	genrandcon
	'main SDLshow
	glend 
	;	