| OpenGL console example
| PHREDA 2025 - rev2

^r3/lib/3dgl.r3
^r3/lib/rand.r3
^r3/lib/sdl2gl.r3

^r3/lib/glutil.r3

|-------------------------------------
| Constantes de grilla (fuente de verdad unica)
#CON_W 100		| columnas  (800 / 8)
#CON_H 37		| filas     (600 / 16)

:CON_CELLS CON_W CON_H * ; | 3700 celdas totales

#fontTexture |
#VAO #VBO #instanceVBO |;
#shaderProgram |;
#conDirty 1	| flag: consola modificada

#shader "
@vertex-----------------
#version 330 core
const float uStep = 1.0 / 16.0;
const float vStep = 1.0 / 16.0;
layout (location = 0) in vec2 aPos;
layout (location = 1) in vec2 aTexCoord;
layout (location = 2) in int instanceData;	// FIX: int nativo
out vec2 TexCoord;
flat out vec3 fgColor;
flat out int  fInvert;						// FIX: flag separado
uniform mat4  projection;
uniform int   uCW;							// FIX: columnas como uniform
void main() {
	int ind       = instanceData;
	int charIndex = ind & 0xff;
	fgColor = vec3(
		((ind>>16)&0xff) * (1.0/255.0),	// FIX: 8 bits por canal
		((ind>> 8)&0xff) * (1.0/255.0),
		((ind    )&0xff) * (1.0/255.0)
		);
	fInvert = (ind >> 24) & 1;				// FIX: bit 24, canal propio
	float u = (charIndex % 16) / 16.0;
	float v = (charIndex / 16) / 16.0;
	TexCoord = vec2(aTexCoord.x*uStep+u, aTexCoord.y*vStep+v);
	float xOff = float(gl_InstanceID % uCW) * 8.0;
	float yOff = float(gl_InstanceID / uCW) * 16.0;
	gl_Position = projection * vec4(aPos.x+xOff, aPos.y+yOff, 0.0, 1.0);
}
@fragment---------------
#version 330 core
out vec4 FragColor;
in  vec2 TexCoord;
flat in vec3 fgColor;
flat in int  fInvert;
uniform sampler2D fontTexture;
void main() {
	float alpha = texture(fontTexture, TexCoord).a;
	if (fInvert == 1) { alpha = 1.0 - alpha; }	// FIX: usa flag separado
	FragColor = vec4(fgColor, alpha);
}
@-----------------------
"

|----------- data
#vert [
0.0  0.0  0.0 0.0
8.0  0.0  1.0 0.0
8.0 16.0  1.0 1.0
0.0 16.0  0.0 1.0
]

#fwintext * 64

:initshaders
	16 'vert memfloat

	'shader loadShaderv 'shaderProgram !
	"media/img/VGA8x16.png" glImgFnt 'fontTexture !

	1 'VAO glGenVertexArrays
	1 'VBO glGenBuffers

	VAO glBindVertexArray

	GL_ARRAY_BUFFER VBO glBindBuffer
	GL_ARRAY_BUFFER 4 4 * 4 * 'vert GL_STATIC_DRAW glBufferData

	| Posiciones
	0 2 GL_FLOAT GL_FALSE 4 4 * 0 glVertexAttribPointer
	0 glEnableVertexAttribArray

	| Coordenadas UV
	1 2 GL_FLOAT GL_FALSE 4 4 * 2 4 * glVertexAttribPointer
	1 glEnableVertexAttribArray

	| Instancias
	1 'instanceVBO glGenBuffers
	GL_ARRAY_BUFFER instanceVBO glBindBuffer

	| FIX: glVertexAttribIPointer para datos enteros nativos
	2 1 GL_INT 4 0 glVertexAttribIPointer
	2 glEnableVertexAttribArray
	2 1 glVertexAttribDivisor
	0 glBindVertexArray

	| FIX: GL_DEPTH_TEST innecesario para 2D — no se habilita

	matini
	800.0 0 0 600.0 1.0 0 mortho
	'fwintext mcpyf
	;

|---------------------------------------
| Formato de celda (32 bits):
|   bits  7.. 0  = indice de caracter ASCII (0-255)
|   bits 15.. 8  = azul  (0-255)
|   bits 23..16  = verde (0-255)
|   bits 31..24  = rojo  (0-255)  bit31 = flag inverso
|
| atr: $RRGGBBxx  (los 8 bits bajos se OR con el char al escribir)

#console * $ffff	| FIX: exactamente CON_W*CON_H celdas
#atr $ffffff			| blanco por defecto
#con> 'console

:gat | x y -- ptr
	CON_W * + 2 << 'console + 'con> ! ;	| FIX: usa CON_W

:gwrite | str --
	con>
	( swap c@+ 1?
		atr 8 << or rot d!+
		) 2drop
	'con> ! ;

:gprint | ... str --
	sprint gwrite ;

:gcls | --
	'console 0 CON_CELLS dfill ;		| FIX: usa constante

|---------------
:drawconsole
	0 0 800 600 glViewport
	GL_BLEND glEnable
	GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA glBlendFunc
	shaderProgram glUseProgram

	| FIX: solo sube buffer si fue modificado
	conDirty 1? (
		GL_ARRAY_BUFFER instanceVBO glBindBuffer
		GL_ARRAY_BUFFER CON_CELLS 4 * 'console GL_DYNAMIC_DRAW glBufferData
		0 'conDirty !
		) drop

	'fwintext shaderProgram "projection" shader!m4

	| FIX: pasar CON_W como uniform
	CON_W shaderProgram "uCW" shader!i

	GL_TEXTURE_2D fontTexture glBindTexture
	VAO glBindVertexArray
	| FIX: instancias = CON_CELLS exacto; TRIANGLE_STRIP en lugar de FAN
	GL_TRIANGLE_FAN 0 4 CON_CELLS glDrawArraysInstanced
	0 glBindVertexArray
	0 glUseProgram
	;

|--------------
:main
	$4100 glClear | color+depth

	1 'conDirty !					| marcar dirty antes de escribir
	$1f0f 'atr ! 2 2 gat msec "%h" gprint

	drawconsole

	SDLGLupdate
	SDLkey
	>esc< =? ( exit )
	drop ;

: |<<<<<<<< BOOT

	"test opengl" 800 600 SDLinitGL

|	GL_DEPTH_TEST glEnable 			| FIX: removido — innecesario en 2D
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
	$ffffff 'atr !
	0 0 gat "Hola Forth/r3 - OpenGL" gwrite

	$ffff00 'atr !
	0 4 gat "Bitmap FONT" gwrite
|.................
	'main SDLshow
	SDL_Quit
	;
