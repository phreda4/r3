| OpenGL fixfont
| PHREDA 2023
^./renderlib.r3
^./gllib.r3

#font_shader "
@fragment-----------------------
#version 330 core
in vec2 uv;
uniform sampler2D u_FontTexture;
uniform int fgColor;
out vec4 FragColor;
void main()
{
    float a = float((fgColor >> 24) & 0xff) / 255.0;
    float r = float((fgColor >> 16) & 0xff) / 255.0;
    float g = float((fgColor >>  8) & 0xff) / 255.0;
    float b = float( fgColor        & 0xff) / 255.0;
    FragColor = vec4(r, g, b, a) * texture(u_FontTexture, uv);
}
@vertex--------------------------
#version 330 core
layout (location = 0) in ivec2 aPos;
layout (location = 1) in ivec2 uvIn;
out vec2 uv;
uniform mat4 projection;
void main()
{
    gl_Position = projection * vec4(vec2(aPos), 0.0, 1.0);
    uv = vec2(uvIn) / vec2(128.0, 256.0);
}
@-"


##fcolor $ffffffff
##fscale 1

|-------------------------------------
#fontshader	
#fontTexture 
#fwintext * 64

#xs 0 #ys 0
#ws 8 #hs 16

::fixFontResize | --
	sw 16 << 0 0 sh 16 << 1.0 0 mortho
	'fwintext 'mat cpymatif
	;
	
::glFixFont
	fixFontResize
	'font_shader loadShaderv 'fontshader !
	"media/img/VGA8x16.png" glImgFnt 'fontTexture !
	;

|---------------------------------------
#xt 0 #yt 0 

:gchar | char --
    dup $f and ws * 'xt ! 4 >> $f and hs * 'yt !
    xs da!+ ys da!+                           xt da!+ yt da!+
    xs ws fscale * + da!+ ys da!+             xt ws + da!+ yt da!+
    xs ws fscale * + da!+ ys hs fscale * + da!+ xt ws + da!+ yt hs + da!+
    xs da!+ ys da!+                           xt da!+ yt da!+
    xs ws fscale * + da!+ ys hs fscale * + da!+ xt ws + da!+ yt hs + da!+
    xs da!+ ys hs fscale * + da!+             xt da!+ yt hs + da!+
    ws fscale * 'xs +!
    ;	
	
#vt #bt

::fini
    GL_DEPTH_TEST glDisable
	GL_CULL_FACE glDisable 
	GL_BLEND glEnable
    GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA glBlendFunc	
    0 0 sw sh glViewport

    fontshader glUseProgram
    fontshader "u_FontTexture" glGetUniformLocation 0 glUniform1i
    fontshader "projection"    glGetUniformLocation 1 0 'fwintext glUniformMatrix4fv

    GL_TEXTURE0 glActiveTexture
    GL_TEXTURE_2D fontTexture glBindTexture
	;
	
::fend
    GL_DEPTH_TEST glEnable
	GL_BLEND glDisable   
    0 glUseProgram
	;
	
::ftext | "" x y --
	'ys ! 'xs !
	fontshader "fgColor" glGetUniformLocation fcolor glUniform1i
	
	1 'vt glGenVertexArrays
	1 'bt glGenBuffers
	vt glBindVertexArray
	GL_ARRAY_BUFFER bt glBindBuffer
	
	here >a ( c@+ 1? gchar ) 2drop
	a> here -
	 
	GL_ARRAY_BUFFER over here GL_STATIC_DRAW glBufferData
	0 glEnableVertexAttribArray 
	0 2 GL_INT 4 2 << 0 glVertexAttribIPointer
	1 glEnableVertexAttribArray 
	1 2 GL_INT 4 2 << 2 2 << glVertexAttribIPointer
	GL_TRIANGLES 0 rot 4 >> glDrawArrays | 16 bytes per vertex
	0 glBindVertexArray
	1 'vt glDeleteVertexArrays
	1 'bt glDeleteBuffers	
	;

:fsize | "" -- "" sizew sizeh
	count 8 * fscale * 16 fscale * ;

:gltextsizecnt | "" cnt -- "" 	
	8 * fscale * 16 fscale * ;

