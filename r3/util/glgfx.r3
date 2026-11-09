| glgfx: 2D drawing over OpenGL (rects, bitmap font, images)
| PHREDA 2026

^r3/lib/sdl2gl.r3
^r3/util/gllib.r3
^r3/lib/str.r3

#font_shader "
@vertex--------------------------
#version 330 core
layout (location = 0) in int aPos;
layout (location = 1) in int uvIn;
uniform mat4 projection;
uniform int fgColor;
uniform ivec2 uAtlas;
out vec2 uv;
flat out vec4 vColor;
void main() {
    vec2 pos = vec2(float(aPos<<16>>16), float(aPos>>16));
    vec2 uvp = vec2(float(uvIn<<16>>16), float(uvIn>>16));
    gl_Position = projection * vec4(pos, 0.0, 1.0);
    uv = uvp / vec2(uAtlas);
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
#fwintext * 64

#xs 0 #ys 0
#ws 8 #hs 16

::fixFontResize | --
	| ortho ZERO_TO_ONE: z=0 -> ndc.z=0.5 (dentro del volumen de clip)
	sw 16 << 0 0 sh 16 << 1.0 -1.0 mortho
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

|-------------------------------------
| fonts: png atlas of 16x16 chars (code = row*16+col), each cell cw x ch pixels
| a font is a record of qwords: texture(packed with size) cw ch atlasw atlash
#sf 0			| state: 1 text shader, 2 image shader, 0 none
#fontlist * 320		| 8 fonts
#fontn 0
#fcur 0			| current font
#ftex 0			| texture of the current font
#fatlas 0		| atlas w h (two int32 for the shader)
#unia
#nfd

::fload | "file" cw ch -- font ; load the atlas (max 8 fonts, 0 if full)
	fontn 8 >=? ( 4drop 0 ; ) drop
	fontn 40 * 'fontlist + 'nfd !
	nfd 16 + ! nfd 8 + !
	glLoadImg
	dup nfd !
	dup 32 >> $ffff and nfd 24 + !
	48 >> $ffff and nfd 32 + !
	1 'fontn +!
	nfd ;

::txfont | font -- ; select the font (from fload) for ftext and the tx words
	0? ( drop ; )
	dup 'fcur !
	@+ 'ftex ! @+ 'ws ! @+ 'hs !
	@+ 'fatlas d!
	@ 'fatlas 4 + d!
	0 'sf ! ;

::txfont@ | -- font ; the font selected now
	fcur ;

::glgfx
	fixFontResize

	'font_shader loadShaderv
	dup "u_FontTexture" glGetUniformLocation 'unifont !
	dup "projection"    glGetUniformLocation 'unipro !
	dup "fgColor"       glGetUniformLocation 'unicolor !
	dup "fgmode"        glGetUniformLocation 'unimode !
	dup "uAtlas"        glGetUniformLocation 'unia !
	'fontshader !

	0 'fontn !
	"media/img/VGA8x16.png" 8 16 fload txfont

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

:statefont
	sf 1 =? ( drop ; ) drop 
	1 'sf !
	fontshader glUseProgram
	unifont 0 glUniform1i
	unipro 1 0 'fwintext glUniformMatrix4fv
	GL_TEXTURE0 glActiveTexture
	GL_TEXTURE_2D ftex $ffff and glBindTexture
	unia 1 'fatlas glUniform2iv
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

::ftextn | "" n -- ; draw n chars of the string with fcolor at fat
	statefont
	ab[
	unicolor fcolor glUniform1i
	unimode 0 glUniform1i
	here >a ( 1? 1- swap c@+ gchar swap ) 2drop
	a> here -

	fvt glBindVertexArray
	GL_ARRAY_BUFFER fbt glBindBuffer
	GL_ARRAY_BUFFER over here GL_STREAM_DRAW glBufferData
	GL_TRIANGLES 0 rot 3 >> glDrawArrays
	0 glBindVertexArray
	]ba
	;

::ftext | "" --
	count ftextn ;

::fsizeh | -- cnh
	fscale hs * ;

::fsizew | -- cnw
	fscale ws * ;

::fsize | "" -- "" sizew sizeh
	count fsizew * fsizeh ;

::fsizecnt | "" cnt -- "" sizew sizeh
	fsizew * fsizeh ;

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

|---------------------------------------
| 2D layer: color, text (monospace atlas font), shapes, clip, image box
| same words as the SDL side (sdl2gfx + txfont), a gui can sit on any of both
|---------------------------------------
#txcol $ffffff

::color | rgb -- ; draw color $RRGGBB (alpha 255)
	$ff000000 or 'fcolor ! ;

::txrgb | rgb -- ; text color $RRGGBB, apart from the draw color
	$ffffff and 'txcol ! ;

|--- metrics (monospace font, with fscale)
::txh | -- h ; line height
	fsizeh ;

::txw | "" -- "" w ; width of the string in pixels
	count fsizew * ;

::txfit | w "" -- ncar ; chars of the string that fit in w pixels
	count rot fsizew / min nip ;

|--- text cursor
#tcx #tcy

::txat | x y -- ; cursor in pixels
	'tcy ! 'tcx ! ;

::txpos | -- x y
	tcx tcy ;

::tx+at | x y -- ; move the cursor
	'tcy +! 'tcx +! ;

::txcr | -- ; new line
	0 'tcx ! txh 'tcy +! ;

::txwriten | "" n -- ; n chars at the cursor with the text color, the cursor moves
	dup fsizew * >r
	tcx tcy fat
	fcolor >r
	txcol $ff000000 or 'fcolor !
	ftextn
	r> 'fcolor !
	r> 'tcx +! ;

::txwrite | "" -- ; string at the cursor, the cursor moves
	count txwriten ;

::txemitr | "" -- ; right aligned, ends at the cursor x
	txw neg 'tcx +!
	txwrite ;

::txemitc | w "" -- ; centered in w pixels from the cursor x
	txw rot swap - 2/ 'tcx +!
	txwrite ;

::txprint | .. "" -- ; sprint at the cursor
	sprint txwrite ;

::txprintr | .. "" -- ; sprint right aligned
	sprint txemitr ;

::txcur | str cur -- ; block cursor on the char cur of str
	swap - fsizew * 'tcx +!
	tcx tcy fsizew fsizeh frect ;

::txcuri | str cur -- ; insert cursor (bar at the bottom)
	swap - fsizew * 'tcx +!
	tcx tcy fsizeh + fsizeh 2 >> - fsizew fsizeh 2 >> frect ;

|--- text in a box, wrapped by words (CR LF and ; start a new line)
#txal 0
#tw #th #tx0 #ty0 #tht #ly
#lmax 1
#lnb #lne #lnn #lcnt

::txalign | $VH -- ; bits 0-1 horizontal (0 left 1 center 2 right), bits 4-5 vertical (0 top 1 center 2 bottom)
	'txal ! ;

:eol | str -- e0 ; end of the text of the line (0 CR LF or ;)
	( c@+ 1?
		13 =? ( drop 1- ; )
		10 =? ( drop 1- ; )
		59 =? ( drop 1- ; )
		drop ) drop 1- ;

:lterm | e -- next ; start of the next line after the terminator at e, 0 if the text ends
	c@+ 0? ( 2drop 0 ; )
	13 =? ( drop dup c@ 10 =? ( drop 1+ ; ) drop ; )
	10 =? ( drop dup c@ 13 =? ( drop 1+ ; ) drop ; )
	drop ;

:wcut | q -- ; cut the line at the space in q
	dup 'lne ! 1+ 'lnn ! ;

:lwrap | -- ; line longer than lmax: cut at the last space or hard cut
	lnb lmax +
	( lnb >?
		dup c@ 32 =? ( drop wcut ; ) drop
		1- )
	drop
	lnb lmax + dup 'lne ! 'lnn ! ;

:lline | str -- ; text of the line lnb..lne, next line lnn (0 = last)
	dup 'lnb !
	eol dup 'lne !
	lnb - lmax >? ( drop lwrap ; ) drop
	lne lterm 'lnn ! ;

:nlines | str -- n
	0 'lcnt !
	( lline 1 'lcnt +! lnn 1? ) drop
	lcnt ;

:valy | -- dy
	th tht -
	txal 4 >> $3 and
	1 =? ( drop 2/ ; )
	2 =? ( drop ; )
	2drop 0 ;

:halx | lw -- dx
	txal $3 and
	1 =? ( drop tw swap - 2/ ; )
	2 =? ( drop tw swap - ; )
	2drop 0 ;

:tdraw | str --
	( lline
		lne lnb - dup fsizew * halx tx0 + ly txat
		lnb swap txwriten
		fsizeh 'ly +!
		lnn 1? ) drop ;

::txText | w h x y "" -- ; text in the box, aligned with txalign
	>r 'ty0 ! 'tx0 ! 'th ! 'tw ! r>
	tw fsizew / 1 max 'lmax !
	dup nlines fsizeh * 'tht !
	ty0 valy + 'ly !
	tdraw ;

|--- shapes
#rbv

:rbev | r x y w h -- x y w h b ; bevel that imitates the radius r
	>r >r >r >r 3 5 */ 'rbv !
	r> r> r> r>
	2dup min 2/ rbv min ;

::fround | r x y w h -- ; filled rectangle with cut corners (radius r)
	rbev frectb ;

::round | r x y w h -- ; outline of the same
	rbev rectb ;

::lineH | x1 y x2 -- ; horizontal line, both ends included
	pick2 - 1+ 1 frect ;

::lineV | x y1 y2 -- ; vertical line, both ends included
	over - 1+ 1 swap frect ;

::imageb | 'box img -- ; image (index of fimgload) into the box x y w h (four int32)
	swap d@+ swap d@+ swap d@+ swap d@ imgdraw ;

|--- clip
#gcx #gcy #gcw #gch

::gclip | x y w h -- ; clip the drawing to the rectangle
	'gch ! 'gcw ! 'gcy ! 'gcx !
	3089 glEnable
	gcx sh gcy - gch - gcw gch glScissor ;

::gclip0 | -- ; no clip
	3089 glDisable ;
