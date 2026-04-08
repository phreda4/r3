| OpenGL fixfont
| PHREDA 2023
^./renderlib.r3
^./gllib.r3

#font_shader "
@vertex--------------------------
#version 330 core
layout (location = 0) in ivec2 aPos;
layout (location = 1) in ivec2 uvIn;
uniform mat4 projection;
uniform int fgColor;
out vec2 uv;
flat out vec4 vColor;
void main() {
    gl_Position = projection * vec4(vec2(aPos), 0.0, 1.0);
    uv = vec2(uvIn) / vec2(128.0, 256.0);
    float a = float((fgColor >> 24) & 0xff) / 255.0;
    float r = float((fgColor >> 16) & 0xff) / 255.0;
    float g = float((fgColor >>  8) & 0xff) / 255.0;
    float b = float( fgColor        & 0xff) / 255.0;
    vColor = vec4(r, g, b, a);
}
@fragment-----------------------
#version 330 core
in vec2 uv;
flat in vec4 vColor;          // Color recibido del vertex shader
uniform sampler2D u_FontTexture;
uniform int fgmode;           // 0 = multiplicar por textura, 1 = solo color
out vec4 FragColor;
void main() {
    if (fgmode == 0) {
        FragColor = vColor * texture(u_FontTexture, uv);
    } else {
        FragColor = vColor;
    }
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

#fvt #fbt

#unifont
#unipro
#unicolor
#unimode

::glFixFont
	fixFontResize
	
	'font_shader loadShaderv 
	dup "u_FontTexture" glGetUniformLocation 'unifont !
	dup "projection"    glGetUniformLocation 'unipro !
	dup "fgColor" glGetUniformLocation 'unicolor !
	dup "fgmode" glGetUniformLocation 'unimode !
	'fontshader !
	
	"media/img/VGA8x16.png" glImgFnt 'fontTexture !

	1 'fvt glGenVertexArrays
	1 'fbt glGenBuffers
	fvt glBindVertexArray
	GL_ARRAY_BUFFER fbt glBindBuffer
	0 glEnableVertexAttribArray
	0 2 GL_INT 4 2 << 0 glVertexAttribIPointer
	1 glEnableVertexAttribArray
	1 2 GL_INT 4 2 << 2 2 << glVertexAttribIPointer
	0 glBindVertexArray
	;

|---------------------------------------
#xt 0 #yt 0 

:gchar | char --
    dup $f and ws * 'xt ! 4 >> $f and hs * 'yt !
    xs da!+ ys da!+                              xt da!+ yt da!+
    xs ws fscale * + da!+ ys da!+                xt ws + da!+ yt da!+
    xs ws fscale * + da!+ ys hs fscale * + da!+  xt ws + da!+ yt hs + da!+
    xs da!+ ys da!+                              xt da!+ yt da!+
    xs ws fscale * + da!+ ys hs fscale * + da!+  xt ws + da!+ yt hs + da!+
    xs da!+ ys hs fscale * + da!+                xt da!+ yt hs + da!+
    ws fscale * 'xs +!
    ;	

::fini
    GL_DEPTH_TEST glDisable
	GL_CULL_FACE glDisable 
	GL_BLEND glEnable
    GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA glBlendFunc	
    0 0 sw sh glViewport

    fontshader glUseProgram
    unifont 0 glUniform1i
    unipro 1 0 'fwintext glUniformMatrix4fv

    GL_TEXTURE0 glActiveTexture
    GL_TEXTURE_2D fontTexture glBindTexture
	;
	
::fend
    GL_DEPTH_TEST glEnable
	GL_BLEND glDisable   
    0 glUseProgram
	;
	
::fat
	'ys ! 'xs ! ;
	
::ftext | "" --	
	ab[
	unicolor fcolor glUniform1i
	unimode 0 glUniform1i
	here >a ( c@+ 1? gchar ) 2drop
	a> here -

	fvt glBindVertexArray
	GL_ARRAY_BUFFER fbt glBindBuffer
	GL_ARRAY_BUFFER over here GL_STREAM_DRAW  glBufferData
	GL_TRIANGLES 0 rot 4 >> glDrawArrays
	0 glBindVertexArray
	]ba
	;

::fsizeh | -- cnh
	16 fscale * ;
	
::fsize | "" -- "" sizew sizeh
	count 8 * fscale * 16 fscale * ;

::fsizecnt | "" cnt -- "" 	
	8 * fscale * 16 fscale * ;
	
:sdraw | mode nverts --
	unicolor fcolor glUniform1i
	unimode 1 glUniform1i
    fvt glBindVertexArray
    GL_ARRAY_BUFFER fbt glBindBuffer
    GL_ARRAY_BUFFER over 4 << here GL_STATIC_DRAW glBufferData
    0 swap glDrawArrays
    0 glBindVertexArray
    ;

:fillrect | x y w h --
	swap pick3 + swap pick2 +
    here >a
    pick3 da!+ pick2 da!+ 0 a!+
    over  da!+ pick2 da!+ 0 a!+
    over  da!+ dup   da!+ 0 a!+
    pick3 da!+ dup   da!+ 0 a!+
    4drop ;

::frect | x y w h --
    fillrect GL_TRIANGLE_FAN 4 sdraw ;	

::rect | x y w h --
	fillrect GL_LINE_LOOP 4 sdraw ;
	
:fillrecb | x y w h b --
	>b 
	swap pick3 + swap pick2 +
	here >a
    pick3 b> + da!+ pick2      da!+ 0 a!+
    over b> -  da!+ pick2      da!+ 0 a!+
	over       da!+ pick2 b> + da!+ 0 a!+
	over       da!+ dup b> -   da!+ 0 a!+
	over b> -  da!+ dup        da!+ 0 a!+	
	pick3 b> + da!+ dup        da!+ 0 a!+	
	pick3      da!+ dup b> -   da!+ 0 a!+	
	pick3      da!+ pick2 b> + da!+ 0 a!+
    4drop ;
	
::frectb | x y w h b --
    fillrecb GL_TRIANGLE_FAN 8 sdraw ;	

::rectb | x y w h b --
	fillrecb GL_LINE_LOOP 8 sdraw ;
