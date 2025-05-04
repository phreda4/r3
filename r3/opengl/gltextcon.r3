| OpenGL console example
| PHREDA 2025

^r3/lib/3dgl.r3
^r3/lib/rand.r3
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
#fontTexture |  // ID de la textura de la fuente
#VAO #VBO #instanceVBO |; // Buffers para instancias
#shaderProgram |;  // Programa de shaders

#shader "
@vertex-----------------
#version 330 core

const int CW = 100; // 800/8
const int CH = 37;	// 600/16

const float uStep = 1.0 / 16.0;           // Ancho de un carácter en UV
const float vStep = 1.0 / 16.0;           // Alto de un carácter en UV

layout (location = 0) in vec2 aPos;
layout (location = 1) in vec2 aTexCoord;
layout (location = 2) in float instanceData;

out vec2 TexCoord;
flat out vec4 fgColor;

uniform mat4 projection;

void main() {
    int ind=int(instanceData);
	int charIndex=(ind&0xff);

	fgColor = vec4(
		((ind>>16)&0xf)*1.0/15, // r
		((ind>>12)&0xf)*1.0/15,	// g
		((ind>>8)&0xf)*1.0/15,	// b
		((ind>>20)&1)*1.0 		// bit 20 inverso
		);
	
    float u = (charIndex % 16) / 16.0;  // Columna del carácter
    float v = (charIndex / 16) / 16.0;  // Fila del carácter
	TexCoord = vec2(aTexCoord.x*uStep+u,aTexCoord.y*vStep+v);
	
    float xOff = (gl_InstanceID%CW)*8.0 ;     // X de la posición
    float yOff = ((gl_InstanceID/CW)%CH)*16.0;     // Y de la posición
	
	gl_Position = projection * vec4(aPos.x+xOff, aPos.y+yOff, 0.0, 1.0);
}
@fragment---------------
#version 330 core
out vec4 FragColor;
in vec2 TexCoord;
flat in vec4 fgColor;
uniform sampler2D fontTexture;

void main() {
	vec4 colt=texture(fontTexture, TexCoord); 
	if (fgColor.a==1.0) { colt.a=1.0-colt.a; } // inverso
	FragColor =vec4(fgColor.r,fgColor.g,fgColor.b,colt.a);
}
@-----------------------
"

|----------- data	
|// Posiciones     // Coordenadas UV
#vert [
0.0 0.0 0.0 0.0
8.0 0.0 1.0 0.0
8.0 16.0 1.0 1.0
0.0 16.0 0.0 1.0
]

#fwintext * 64

:initshaders
	16 'vert memfloat

	'shader	loadShaderv 'shaderProgram !
	"media/img/VGA8x16.png" glImgFnt 'fontTexture !

    1 'VAO glGenVertexArrays
    1 'VBO glGenBuffers

    VAO glBindVertexArray

    GL_ARRAY_BUFFER VBO glBindBuffer
	GL_ARRAY_BUFFER 4 4 * 4 * 'vert	GL_STATIC_DRAW glBufferData

    | Posiciones
    0 2 GL_FLOAT GL_FALSE 4 4 *  0 glVertexAttribPointer
    0 glEnableVertexAttribArray

    | Coordenadas UV
    1 2 GL_FLOAT GL_FALSE 4 4 * 2 4 * glVertexAttribPointer
    1 glEnableVertexAttribArray

    | instancias
    1 'instanceVBO glGenBuffers
    GL_ARRAY_BUFFER instanceVBO glBindBuffer

    | Atributo instancia
    2 1 GL_INT GL_FALSE 4 0 glVertexAttribPointer
    2 glEnableVertexAttribArray
    2 1 glVertexAttribDivisor
    0 glBindVertexArray

	matini
	800.0 0 0 600.0 1.0 0 mortho
	'fwintext mcpyf
	;

|---------------------------------------
| ...(i)f ffcc

#console * $3fff
#atr $fff
#con> 'console	

:gat | x y --
	100 * + 2 << 'console + 'con> ! ;
	
:gwrite | str --
	con>
	( swap c@+ 1? 
		atr 8 << or rot d!+ 
		) 2drop 
	'con> ! ;
	
:gprint | ... str --
	sprint gwrite ;
	
:gcls | --
	'console 0 100 37 * dfill ;

|---------------
:drawconsole
	0 0 800 600 glViewport
	GL_BLEND glEnable
	GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA glBlendFunc
    shaderProgram glUseProgram
    GL_ARRAY_BUFFER instanceVBO glBindBuffer
    GL_ARRAY_BUFFER $3fff 'console GL_DYNAMIC_DRAW glBufferData
	'fwintext shaderProgram "projection" shader!m4
    GL_TEXTURE_2D fontTexture glBindTexture
	VAO glBindVertexArray
    GL_TRIANGLE_FAN 0 4 $fff glDrawArraysInstanced
    0 glBindVertexArray
    0 glUseProgram
	;

|--------------	
:main
	$4100 glClear | color+depth

	$1f0f 'atr ! 2 2 gat msec "%h" gprint
	
	drawconsole
	
	SDLGLupdate
	SDLkey
	>esc< =? ( exit ) 	
	drop ;	

: |<<<<<<<< BOOT

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
|.................
	gcls
	$fff 'atr !
	0 0 gat "Hola Forth/r3 - OpenGL" gwrite
	
	$ff0 'atr !
	0 4 gat	"Bitmap FONT" gwrite
|.................
	'main SDLshow
	SDL_Quit 
	;	