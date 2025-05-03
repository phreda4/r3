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
#GL_INT $1404

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
layout (location = 2) in float instanceData; // Datos de la instancia: (nroCaracter, x, y)

out vec2 TexCoord;
out vec4 fgColor;

uniform mat4 projection;
uniform vec2 scale=vec2(0.1,0.1); // Escala global para caracteres

void main() {
    int ind=int(instanceData); // Índice del carácter
	int charIndex=(ind&0xff);

	fgColor = vec4(((ind>>16)&0xf)*1.0/15,((ind>>12)&0xf)*1.0/15,((ind>>8)&0xf)*1.0/15,1.0);
	
    // Calculamos las coordenadas UV
    float u = (charIndex % 16) / 16.0;  // Columna del carácter
    float v = (charIndex / 16) / 16.0;  // Fila del carácter
    float uStep = 1.0 / 16.0;           // Ancho de un carácter en UV
    float vStep = 1.0 / 16.0;           // Alto de un carácter en UV
	TexCoord = vec2(aTexCoord.x*uStep+u,aTexCoord.y*vStep+v);
	
    float xOffset = (gl_InstanceID%80)*0.1 ;     // X de la posición
    float yOffset = ((gl_InstanceID/80)%50)*0.1;     // Y de la posición

    // Calculamos la posición del vértice en pantalla
    gl_Position = vec4(aPos * scale + vec2(xOffset, yOffset), 0.0, 1.0);
}
@fragment-----------------------
#version 330 core
out vec4 FragColor;
in vec2 TexCoord;
in vec4 fgColor;
uniform sampler2D fontTexture;

void main() {
    FragColor = fgColor*texture(fontTexture, TexCoord); 
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

#fwintext * 64

:initshaders
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
    2 1 GL_INT GL_FALSE 4 0 glVertexAttribPointer
    2 glEnableVertexAttribArray
    2 1 glVertexAttribDivisor
    0 glBindVertexArray

|	4 'fcolor memfloat	
	800.0 0 0 600.0 1.0 0 mortho
	'fwintext mcpyf

	'fwintext shaderProgram "projection" shader!m4
	;

|---------------------------------------
| ...f ffcc

#console * $3fff

:draws
	'console >a
	( c@+ 1? 
		$ff 8 << or 
		da!+ ) 2drop ;
		
:drawconsole
	0 0 800 600 glViewport
	GL_BLEND glEnable
	GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA glBlendFunc

    |// Actualizamos el VBO de instancias
    GL_ARRAY_BUFFER instanceVBO glBindBuffer
    GL_ARRAY_BUFFER $3fff 'console GL_DYNAMIC_DRAW glBufferData

    |// Dibujamos las instancias
    shaderProgram glUseProgram
    GL_TEXTURE_2D fontTexture glBindTexture
	VAO glBindVertexArray

    |glUniform2f(glGetUniformLocation(shaderProgram, "scale"), scale * CHAR_WIDTH, scale * CHAR_HEIGHT);
    GL_TRIANGLE_FAN 0 4 $fff glDrawArraysInstanced

    0 glBindVertexArray
    0 glUseProgram
	;

|--------------	
:main
	$4100 glClear | color+depth
	
	|"Hol a todos " drawstring
|	"Hola Forth/r3 - OpenGL" 0.0 0.0 text
	
|	$ff textcolor
|	msec "%h" sprint 0.0 16.0 text
|	$ff00 textcolor
|	"Bitmap FONT" 0.0 32.0 text
	drawconsole
	
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

	"Hola dsad  hgdsjfhgdjsh gfjdshg fjhdgs jfhgd sjfh gdjshg fjhdsg fjhdsgjshg fjdhgs jfh gdsjfg jdshgfjhdgs jhgfjdshg fjhdsgf jhdsg " draws
	'main SDLshow
	SDL_Quit 
	;	