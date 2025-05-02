| OpenGL example
| PHREDA 2023
|MEM 64
^r3/lib/3dgl.r3
^r3/lib/rand.r3
^r3/lib/gui.r3
^r3/util/arr16.r3
^r3/lib/trace.r3

^r3/lib/sdl2.r3
^r3/lib/sdl2gl.r3

^r3/opengl/glutil.r3

| opengl Constant
#GL_DEPTH_TEST $0B71
#GL_LESS $0201
#GL_CULL_FACE $0B44

#GL_ARRAY_BUFFER $8892
#GL_ELEMENT_ARRAY_BUFFER $8893

#GL_STATIC_DRAW $88E4
#GL_DYNAMIC_DRAW $88E8
#GL_FLOAT $1406
#GL_UNSIGNED_SHORT $1403

#GL_TRIANGLE_FAN $0006
#GL_TRIANGLE_STRIP $0005
#GL_TRIANGLES $0004
#GL_FALSE 0

#GL_TEXTURE $1702
#GL_TEXTURE0 $84C0
#GL_TEXTURE_2D $0DE1

#GL_BLEND $0BE2
#GL_SRC_ALPHA $0302
#GL_ONE_MINUS_SRC_ALPHA $0303

|-------------------------------------

:memfloat | cnt place --
	>a ( 1? 1 - da@ f2fp da!+ ) drop ;
	
#fontTexture |  // ID de la textura de la fuente
#VAO #VBO #instanceVBO |; // Buffers para instancias
#shaderProgram |;  // Programa de shaders

#shader "
@vertex--------------------------
#version 330 core
layout (location = 0) in vec2 aPos;       // Posiciones del quad (local)
layout (location = 1) in vec2 aTexCoord; // Coordenadas UV del quad
layout (location = 2) in vec3 instanceData; // Datos de la instancia: (nroCaracter, x, y)

out vec2 TexCoord;

uniform vec2 scale=vec2(1.0,1.0); // Escala global para caracteres

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
}
@fragment-----------------------
#version 330 core
out vec4 FragColor;
in vec2 TexCoord;
uniform sampler2D fontTexture;

void main() {
    FragColor = texture(fontTexture, TexCoord);
}
@-------------------------------
"

|----------- data	
|// Posiciones     // Coordenadas UV
#vertices [
0 			0 			0 			$3f800000	| Inf Izq
$3f800000 	0 			$3f800000 	$3f800000	| inf Der
$3f800000 	$3f800000 	$3f800000 	0			| Sup Der
0 			$3f800000 	0 			0			| sup Izq
]

:initshaders
|	4 'fcolor memfloat	
|	800.0 0 0 600.0 1.0 0 mortho
|	'fwintext mcpyf
	
	'shader	loadShaderv 'shaderProgram !
	"media/img/VGA8x16.png" glImgFnt 'fontTexture !

    1 'VAO glGenVertexArrays
    1 'VBO glGenBuffers

    VAO glBindVertexArray

    GL_ARRAY_BUFFER VBO glBindBuffer
	GL_ARRAY_BUFFER 4 4 * 4 * 'vertices GL_STATIC_DRAW glBufferData

    |// Posiciones
    0 2 GL_FLOAT GL_FALSE 4 4 *  0 glVertexAttribPointer
    0 glEnableVertexAttribArray

    |// Coordenadas UV
    1 2 GL_FLOAT GL_FALSE 4 4 * 2 4 * glVertexAttribPointer
    1 glEnableVertexAttribArray

    |// Configuramos un VBO para instancias
    1 'instanceVBO glGenBuffers
    GL_ARRAY_BUFFER instanceVBO glBindBuffer

    |// Atributo para datos de la instancia
    2 3 GL_FLOAT GL_FALSE 3 4 * 0 glVertexAttribPointer
    2 glEnableVertexAttribArray
    2 1 glVertexAttribDivisor
    0 glBindVertexArray

	;

|---------------------------------------
#mems

:drawstring | x y str --
	here dup 'mems ! >a
	( c@+ 1?
		i2fp da!+
		pick2 i2fp da!+
		over i2fp da!+
		rot 8 + -rot
		) 2drop
	a> mems - 'mems !

    |// Actualizamos el VBO de instancias
    GL_ARRAY_BUFFER instanceVBO glBindBuffer
    GL_ARRAY_BUFFER mems here GL_DYNAMIC_DRAW glBufferData

    |// Dibujamos las instancias
    shaderProgram glUseProgram
    GL_TEXTURE_2D fontTexture glBindTexture
	VAO glBindVertexArray

    |glUniform2f(glGetUniformLocation(shaderProgram, "scale"), scale * CHAR_WIDTH, scale * CHAR_HEIGHT);
    GL_TRIANGLE_FAN 0 4 12 glDrawArraysInstanced

    0 glBindVertexArray
    0 glUseProgram
	2drop
	;

|--------------	
:main
	$4100 glClear | color+depth
	
	10 10 "Hol a todos " drawstring
|	"Hola Forth/r3 - OpenGL" 0.0 0.0 text
	
|	$ff textcolor
|	msec "%h" sprint 0.0 16.0 text
|	$ff00 textcolor
|	"Bitmap FONT" 0.0 32.0 text
	
	SDLGLupdate
	SDLkey
	>esc< =? ( exit ) 	
	drop ;	
	
|----------- BOOT
:
	"test opengl" 800 600 SDLinitGL
	
	GL_DEPTH_TEST glEnable 
|	GL_CULL_FACE glEnable	
|	GL_LESS glDepthFunc 

	initshaders

	.cr 
	glInfo		
	.cr 
	"<esc> - Exit" .println
	.cr

	'main SDLshow
	SDL_Quit 
	;	