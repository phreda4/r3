| Head Up Display
| PHREDA 2026

^./renderlib.r3
^./gllib.r3

#font_shader "
@vertex--------------------------
#version 330 core
layout (location = 0) in int aPos;
layout (location = 1) in int uvIn;
uniform mat4 projection;
uniform int fgColor;
out vec2 uv;
flat out vec4 vColor;
void main() {
    vec2 pos = vec2(float(aPos<<16>>16), float(aPos>>16));
    vec2 uvp = vec2(float(uvIn<<16>>16), float(uvIn>>16));
    gl_Position = projection * vec4(pos, 0.0, 1.0);
    uv = uvp / vec2(128.0, 256.0);
    float a = float((fgColor >> 24) & 0xff) / 255.0;
    float r = float((fgColor >> 16) & 0xff) / 255.0;
    float g = float((fgColor >>  8) & 0xff) / 255.0;
    float b = float( fgColor        & 0xff) / 255.0;
    vColor = vec4(r, g, b, a);
}
@fragment-----------------------
#version 330 core
in vec2 uv;
flat in vec4 vColor;
uniform sampler2D u_FontTexture;
uniform int fgmode;
out vec4 FragColor;
void main() {
    if (fgmode == 0) {
        FragColor = vColor * texture(u_FontTexture, uv);
    } else {
        FragColor = vColor;
    }
}
@-"

#img_shader "
@vertex--------------------------
#version 330 core
layout (location = 0) in int aPos;
layout (location = 1) in int uvIn;
uniform mat4 projection;
uniform ivec2 uImgSize;
out vec2 uv;
void main() {
    vec2 pos = vec2(float(aPos<<16>>16), float(aPos>>16));
    vec2 uvp = vec2(float(uvIn<<16>>16), float(uvIn>>16));
    gl_Position = projection * vec4(pos, 0.0, 1.0);
    uv = uvp / vec2(uImgSize);
}
@fragment-----------------------
#version 330 core
in vec2 uv;
uniform sampler2D u_ImgTexture;
out vec4 FragColor;
void main() {
    FragColor = texture(u_ImgTexture, uv);
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

|-------------------------------------
| image shader globals
#imgshader
#img_unipro
#img_unisize
#img_unitex

| IMG_MAX = 16
#imgtextures * 64   | 16 x 4 bytes  (GL texture IDs, int32)
#imgsizes    * 128  | 16 x 8 bytes  (w, h as int32 pairs)
##imgcount 0

::rlhud
	fixFontResize

	'font_shader loadShaderv
	dup "u_FontTexture" glGetUniformLocation 'unifont !
	dup "projection"    glGetUniformLocation 'unipro !
	dup "fgColor"       glGetUniformLocation 'unicolor !
	dup "fgmode"        glGetUniformLocation 'unimode !
	'fontshader !

	"media/img/VGA8x16.png" glLoadImg 'fontTexture !

	'img_shader loadShaderv
	dup "u_ImgTexture" glGetUniformLocation 'img_unitex !
	dup "projection"   glGetUniformLocation 'img_unipro !
	dup "uImgSize"     glGetUniformLocation 'img_unisize !
	'imgshader !

	1 'fvt glGenVertexArrays
	1 'fbt glGenBuffers
	fvt glBindVertexArray
	GL_ARRAY_BUFFER fbt glBindBuffer
	0 glEnableVertexAttribArray
	0 1 GL_INT 8 0 glVertexAttribIPointer
	1 glEnableVertexAttribArray
	1 1 GL_INT 8 4 glVertexAttribIPointer
	0 glBindVertexArray
	;

|---------------------------------------
| imgload | "" -- idx
#idx_img

::fimgload | "" -- idx
	glLoadImg
	dup $ffff and 'imgtextures imgcount 4 * + d!
	32 >> 
	dup 16 >> swap $ffff and 
	'imgsizes imgcount 8 * + d!+ d!
	imgcount
	1 'imgcount +!
	;
	
::fimgtex | tex -- idx
	dup $ffff and 'imgtextures imgcount 4 * + d!
	32 >> 
	dup 16 >> swap $ffff and 
	'imgsizes imgcount 8 * + d!+ d!
	imgcount
	1 'imgcount +!
	;
	
::fimgwh | idx -- w h
	8 * 'imgsizes + d@+ swap d@ ;

|---------------------------------------
| pack two int16 into one int32: lo hi -- int32
:p16 16 << swap $ffff and or ;
:px+ $ffff and + ;
:py+ $ffff0000 and + ;

#xt 0 #yt 0

:gchar | char --
	dup $f and ws * 'xt ! 4 >> $f and hs * 'yt !
	xs ys p16 da!+                              xt yt p16 da!+
	xs ws fscale * + ys p16 da!+                xt ws + yt p16 da!+
	xs ws fscale * + ys hs fscale * + p16 da!+  xt ws + yt hs + p16 da!+
	xs ys p16 da!+                              xt yt p16 da!+
	xs ws fscale * + ys hs fscale * + p16 da!+  xt ws + yt hs + p16 da!+
	xs ys hs fscale * + p16 da!+                xt yt hs + p16 da!+
	ws fscale * 'xs +!
	;

|------- state 
#sf 0

:statefont
	sf 1 =? ( drop ; ) drop 
	1 'sf !
	fontshader glUseProgram
	unifont 0 glUniform1i
	unipro 1 0 'fwintext glUniformMatrix4fv
	GL_TEXTURE0 glActiveTexture
	GL_TEXTURE_2D fontTexture $ffff and glBindTexture
	;

:stateimg | --
	sf 2 =? ( drop ; ) drop 
	2 'sf !
	imgshader glUseProgram
	img_unipro 1 0 'fwintext glUniformMatrix4fv
	img_unitex 0 glUniform1i
	GL_TEXTURE0 glActiveTexture
	;
	
::fini
	GL_DEPTH_TEST glDisable
	GL_CULL_FACE glDisable
	GL_BLEND glEnable
	GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA glBlendFunc
	0 0 sw sh glViewport
	0 'sf !
	;

::fend
	GL_DEPTH_TEST glEnable
	GL_BLEND glDisable
	0 glUseProgram
	;

::fat
	'ys ! 'xs ! ;

::ftext | "" --
	statefont
	ab[
	unicolor fcolor glUniform1i
	unimode 0 glUniform1i
	here >a ( c@+ 1? gchar ) 2drop
	a> here -

	fvt glBindVertexArray
	GL_ARRAY_BUFFER fbt glBindBuffer
	GL_ARRAY_BUFFER over here GL_STREAM_DRAW glBufferData
	GL_TRIANGLES 0 rot 3 >> glDrawArrays
	0 glBindVertexArray
	]ba
	;

::fsizeh | -- cnh
	fscale 16 * ;

::fsizew | -- cnw
	fscale 8 * ;

::fsize | "" -- "" sizew sizeh
	count 8 * fscale * fscale 16 * ;

::fsizecnt | "" cnt -- ""
	8 * fscale * fscale 16 * ;

:sdraw | mode nverts --
	statefont
	unicolor fcolor glUniform1i
	unimode 1 glUniform1i
	fvt glBindVertexArray
	GL_ARRAY_BUFFER fbt glBindBuffer
	GL_ARRAY_BUFFER over 3 << here GL_STATIC_DRAW glBufferData
	0 swap glDrawArrays
	0 glBindVertexArray
	;

:fillrect | x y w h --
	p16 -rot p16 swap
	here >a
	over da!+     0 da!+
	2dup px+ da!+ 0 da!+
	2dup + da!+   0 da!+
	py+ da!+      0 da!+
	;
	
::frect | x y w h --
	fillrect GL_TRIANGLE_FAN 4 sdraw ;

::rect | x y w h --
	fillrect GL_LINE_LOOP 4 sdraw ;

:fillrecb | x y w h b --
	>b
	swap pick3 + swap pick2 +
	here >a
	pick3 b> + pick3      p16 da!+  0 da!+
	over b> -  pick3      p16 da!+  0 da!+
	over       pick3 b> + p16 da!+  0 da!+
	over       over b> -  p16 da!+  0 da!+
	over b> -  over       p16 da!+  0 da!+
	pick3 b> + over       p16 da!+  0 da!+
	pick3      over b> -  p16 da!+  0 da!+
	pick3      pick3 b> + p16 da!+  0 da!+
	4drop ;

::frectb | x y w h b --
	fillrecb GL_TRIANGLE_FAN 8 sdraw ;

::rectb | x y w h b --
	fillrecb GL_LINE_LOOP 8 sdraw ;

|---------------------------------------
| image drawing
#dxy_img #dwh_img #sxy_img #swh_img

:gimgquad | -- builds 6 verts into buffer using img vars
	dxy_img da!+              sxy_img da!+
	dxy_img dwh_img px+ da!+  sxy_img swh_img px+ da!+
	dxy_img dwh_img + da!+    sxy_img swh_img + da!+
	dxy_img da!+              sxy_img da!+
	dxy_img dwh_img + da!+    sxy_img swh_img + da!+
	dxy_img dwh_img py+ da!+  sxy_img swh_img py+ da!+
	;

:imgdoraw | --
	stateimg
	GL_TEXTURE_2D idx_img 4 * 'imgtextures + d@ glBindTexture
	img_unisize 1 idx_img 8 * 'imgsizes + glUniform2iv
	ab[
	here >a gimgquad a> here -
	fvt glBindVertexArray
	GL_ARRAY_BUFFER fbt glBindBuffer
	GL_ARRAY_BUFFER over here GL_STREAM_DRAW glBufferData
	GL_TRIANGLES 0 rot 3 >> glDrawArrays
	0 glBindVertexArray
	]ba
	;

| imgdrawuv | idx dx dy dw dh sx sy sw sh --
| Draw partial image: src region in pixels, dest rect on screen
::imgdrawuv | idx dx dy dw dh sx sy sw sh --
	p16 'swh_img ! p16 'sxy_img ! 
	p16 'dwh_img ! p16 'dxy_img ! 
	'idx_img !
	imgdoraw
	;

| imgdraw | idx dx dy dw dh --
| Draw full image scaled to dest rect
::imgdraw | idx dx dy dw dh --
	p16 'dwh_img ! p16 'dxy_img ! 
	'idx_img !
	0 'sxy_img !
	idx_img 8 * 'imgsizes + d@+ swap d@ p16 'swh_img !
	imgdoraw
	;
