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
#fontTexture
#consoleVBO

|---------------------------		
#vertexShader
#fragmentShader

#vertexShaderSource "#version 330 core
layout (location = 0) in vec2 aPos;       // Posiciones del quad (local)
layout (location = 1) in float cell; // Datos de la instancia: (nroCaracter, x, y)

out vec3 fragPos;
out vec3 fragColor;

out vec2 TexCoord;

uniform vec2 scale=vec2(1.0,1.0); // Escala global para caracteres

void main() {
	int bchar=int(cell);
    
	int xpos=gl_InstanceID % 80;
	int ypos=(gl_InstanceID / 80) % 50;

    float uStep = 1.0 / 8.0;           // Ancho de un carácter en UV
    float vStep = 1.0 / 16.0;           // Alto de un carácter en UV

    int charIndex = bchar&0xff; // Índice del carácter
	
	float u = (charIndex&0xf)*uStep;
    float v = ((charIndex>>4)&0xf)*vStep;

    TexCoord = vec2(u,v);
	fragColor = vec3(1.0,1.0,1.0);
    gl_Position = vec4(aPos+vec2(xpos, ypos), 0.0, 1.0);
}"

#fragmentShaderSource "#version 330 core
in vec2 TexCoord;
out vec4 FragColor;
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
	dup "fontTexture" glGetUniformLocation 'fontTextureID ! 
	'shaderProgram !
	;
	
|--------------------------------
#surface
##glimgw
##glimgh

##GL_TEXTURE $1702
##GL_TEXTURE0 $84C0
##GL_TEXTURE_2D $0DE1
##GL_TEXTURE_2D_ARRAY $8C1A
##GL_TEXTURE_3D $806F

#GL_TEXTURE_MAG_FILTER $2800
#GL_TEXTURE_MIN_FILTER $2801
#GL_LINEAR $2601
#GL_NEAREST $2600
#GL_NEAREST_MIPMAP_LINEAR $2702
#GL_NEAREST_MIPMAP_NEAREST $2700
#GL_TEXTURE_WRAP_R $8072
#GL_TEXTURE_WRAP_S $2802
#GL_TEXTURE_WRAP_T $2803

#GL_RED $1903
#GL_RGB $1907
#GL_RGBA $1908
#GL_UNSIGNED_BYTE $1401
#GL_CLAMP_TO_EDGE $812F	

:Surface->w surface 16 + d@ ;
:Surface->h surface 20 + d@ ;
:Surface->p surface 24 + d@ ;
:Surface->pixels surface 32 + @ ;
:GLBPP 
	surface 8 + @ 16 + c@
	32 =? ( drop GL_RGBA ; ) 
	24 =? ( drop GL_RGB ; )
	drop GL_RED ;

::glImgFnt | "" -- t
	1 't glGenTextures
    GL_TEXTURE_2D t glBindTexture IMG_Load 'Surface !
	GL_TEXTURE_2D 0 GLBPP Surface->w Surface->h 0 pick3 GL_UNSIGNED_BYTE Surface->pixels glTexImage2D
	GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_NEAREST glTexParameteri
	GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_NEAREST glTexParameteri
	GL_TEXTURE_2D GL_TEXTURE_WRAP_S GL_CLAMP_TO_EDGE  glTexParameteri
	GL_TEXTURE_2D GL_TEXTURE_WRAP_T GL_CLAMP_TO_EDGE  glTexParameteri	
	Surface SDL_FreeSurface
	t ;	
	
:progshader
    1 'VAO glGenVertexArrays
    1 'VBO glGenBuffers
	
    VAO glBindVertexArray

	GL_ARRAY_BUFFER VBO glBindBuffer			| vertices
	GL_ARRAY_BUFFER 4 4 * 4 * 'Vertices GL_STATIC_DRAW glBufferData

|// Posiciones
    0 2 GL_FLOAT GL_FALSE 4 4 * 0 glVertexAttribPointer
    0 glEnableVertexAttribArray
	
	1 'consoleVBO glGenBuffers
	GL_ARRAY_BUFFER consoleVBO glBindBuffer		| typos
	
	GL_ARRAY_BUFFER $3fff 'console GL_STATIC_DRAW glBufferData
	
	1 4 GL_INT GL_FALSE 4 0 glVertexAttribPointer | ??? pasa como float!!!
	1 glEnableVertexAttribArray
    1 1 glVertexAttribDivisor

	GL_ARRAY_BUFFER 0 glBindBuffer
	0 glBindVertexArray
	
	
	"media/img/VGA8x16.png" glImgFnt 'fontTexture !	
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