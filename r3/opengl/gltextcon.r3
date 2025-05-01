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
	
#fontshader	
#fontTexture 
#fcolor [ 1.0 0.0 0.0 1.0 ]
#fwintext * 64

#xt 0 #yt 0 
#wt 0 #ht 0 
#xs 0 #ys 0
#ws 8.0 #hs 16.0 

#shader "
@vertex--------------------------
#version 330 core
layout (location = 0) in vec2 aPos;
layout (location = 1) in vec2 uvIn;
layout (location = 2) in float acon; 

out vec2 uv;

uniform mat4 projection;

void main()
{
	gl_Position = projection * vec4(aPos.x, aPos.y, 0.0, 1.0);
	uv = uvIn;
}
@fragment-----------------------
#version 330 core
in vec2 uv;
uniform sampler2D u_FontTexture;
uniform vec4 fgColor;
out vec4 FragColor;

void main()
{
	FragColor =  fgColor * texture(u_FontTexture, uv);
}
@-------------------------------
"

:initshaders
	4 'fcolor memfloat	
	800.0 0 0 600.0 1.0 0 mortho
	'fwintext mcpyf
	
	'shader	loadShaderv 'fontshader !
	"media/img/VGA8x16.png" glImgFnt 'fontTexture !
	
	1.0 4 >> dup 'wt ! 'ht ! 
	;

|---------------------------------------
#vt
#bt

:fp, f2fp , ;

:textcolor | fc --
	'fcolor >a  
	dup $ff0000 and 255 / f2fp da!+ 
	dup 8 << $ff0000 and 255 / f2fp da!+ 
	16 << $ff0000 and 255 / f2fp da! 
	;
	
:gchar | char --
	dup $f and wt * 'xt ! | x1
	4 >> $f and ht * 'yt ! | y1

	xs fp, ys fp, 			xt fp, yt fp,
	xs ws + fp, ys fp, 		xt wt + fp, yt fp,
	xs ws + fp, ys hs + fp, xt wt + fp, yt ht + fp,
	
	xs fp, ys fp, 			xt fp, yt fp,
	xs ws + fp, ys hs + fp, xt wt + fp, yt ht + fp,
	xs fp, ys hs + fp, 		xt fp, yt ht + fp,
	
	8.0 'xs +!
	;
	
:text | "" x y --
	'ys ! 'xs !
	fontshader glUseProgram
	0 fontshader "u_FontTexture" shader!i
	'fcolor fontshader "fgColor" shader!v4
	'fwintext fontshader "projection" shader!m4
	
	GL_TEXTURE0 glActiveTexture
	GL_TEXTURE_2D fontTexture glBindTexture
	
	1 'vt glGenVertexArrays
	1 'bt glGenBuffers
	vt glBindVertexArray
	GL_ARRAY_BUFFER bt glBindBuffer
	
	here mark
	swap ( c@+ 1? gchar ) 2drop
	here swap - empty | size
	
	GL_BLEND glEnable
	GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA glBlendFunc
	0 0 800 600 glViewport
	 
	GL_ARRAY_BUFFER over here GL_STATIC_DRAW glBufferData
	0 glEnableVertexAttribArray 0 3 GL_FLOAT GL_FALSE 4 2 << 0 glVertexAttribPointer
	1 glEnableVertexAttribArray 1 2 GL_FLOAT GL_FALSE 4 2 << 2 2 << glVertexAttribPointer
	GL_TRIANGLES 0 rot 4 >> glDrawArrays | 16 bytes per vertex
	0 glBindVertexArray
	1 'vt glDeleteVertexArrays
	1 'bt glDeleteBuffers	
	;
	
:text2
	;

|--------------	
:main
	$4100 glClear | color+depth

	$ffffff textcolor
	"Hola Forth/r3 - OpenGL" 0.0 0.0 text
	
	$ff textcolor
	msec "%h" sprint 0.0 16.0 text
	$ff00 textcolor
	"Bitmap FONT" 0.0 32.0 text
	
	SDL_windows SDL_GL_SwapWindow
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