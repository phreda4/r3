| glgfx: 2D drawing over OpenGL (rects, bitmap font, images), batched
| PHREDA 2026
|
| All the drawing words accumulate triangles in a CPU buffer (12 bytes per
| vertex: pos, uv, color). The buffer goes to the GPU with one draw call when
| it is full, when the texture changes, at fend, gclip/gclip0 or gflush.
| Same names as sdl2gfx: color colorA cls point line lineH lineV frect rect
| fround round fellipse ellipse fcircle circle triangle polyop polyline
| image images imageb imagebb ts* sprite* ss*  (images are fimgload indexes)

^r3/lib/sdl2gl.r3
^r3/lib/math.r3
^r3/util/gllib.r3
^r3/lib/str.r3

#gl_shader "
@vertex--------------------------
#version 330 core
layout (location = 0) in int aPos;
layout (location = 1) in int uvIn;
layout (location = 2) in int aCol;
uniform mat4 projection;
uniform ivec2 uAtlas;
out vec2 uv;
out vec4 vColor;
flat out int vSolid;
void main() {
    vec2 pos = vec2(float(aPos<<16>>16), float(aPos>>16));
    vec2 uvp = vec2(float(uvIn<<16>>16), float(uvIn>>16));
    gl_Position = projection * vec4(pos, 0.0, 1.0);
    uv = uvp / vec2(uAtlas);
    vSolid = (uvIn == -1) ? 1 : 0;
    float a = float((aCol >> 24) & 0xff) / 255.0;
    float r = float((aCol >> 16) & 0xff) / 255.0;
    float g = float((aCol >>  8) & 0xff) / 255.0;
    float b = float( aCol        & 0xff) / 255.0;
    vColor = vec4(r, g, b, a);
}
@fragment-----------------------
#version 330 core
in vec2 uv;
in vec4 vColor;
flat in int vSolid;
uniform sampler2D u_FontTexture;
out vec4 FragColor;
void main() {
    vec4 t = texture(u_FontTexture, uv);
    FragColor = (vSolid == 1) ? vColor : vColor * t;
}
@-"

##fcolor $ffffffff
##fscale 1

|-------------------------------------
#glshader
#fwintext * 64

#xs 0 #ys 0
#ws 8 #hs 16

::fixFontResize | --
	| ortho ZERO_TO_ONE: z=0 -> ndc.z=0.5 (dentro del volumen de clip)
	sw 16 << 0 0 sh 16 << 1.0 -1.0 mortho
	'fwintext 'mat cpymatif
	;

#fvt #fbt

#unitex
#unipro
#uniatlas

|-------------------------------------
| images: GL texture id and size per index
| IMG_MAX = 16
#imgtextures * 64   | 16 x 4 bytes  (GL texture IDs, int32)
#imgsizes    * 128  | 16 x 8 bytes  (w, h as int32 pairs)
##imgcount 0

|-------------------------------------
| fonts: png atlas of 16x16 chars (code = row*16+col), each cell cw x ch pixels
| a font is a record of qwords: texture(packed with size) cw ch atlasw atlash
#fontlist * 16704	| 8 fonts x 2088 bytes: tex ws hs atlas(w h int32) pad, 256 entries at +40
#fontn 0
#fcur 0			| current font
#ftex 0			| texture of the current font
#fatlas 0		| atlas w h (two int32)
#ftab 0			| entries of the current font

|-------------------------------------
#vbuf 			| start free memory for buffer
#vp 0			| address of the next vertex
#vcol $ffffffff		| color of the vertices that are written
#btex 0			| texture of the batch
#bsz 0			| atlas w h of the batch (two int32)
#btu 0			| 1 if the batch has textured vertices

:p16 | lo hi -- int32 ; pack two int16
	16 << swap $ffff and or ;

::gflush | -- ; send the batch to the GPU (call it before your own GL calls)
	vp vbuf <=? ( drop ; ) drop
	glshader glUseProgram
	unipro 1 0 'fwintext glUniformMatrix4fv
	unitex 0 glUniform1i
	uniatlas 1 'bsz glUniform2iv
	GL_TEXTURE0 glActiveTexture
	GL_TEXTURE_2D btex glBindTexture
	fvt glBindVertexArray
	GL_ARRAY_BUFFER fbt glBindBuffer
	GL_ARRAY_BUFFER 196608 0 GL_STREAM_DRAW glBufferData	| orphan
	GL_ARRAY_BUFFER 0 vp vbuf - vbuf glBufferSubData
	GL_TRIANGLES 0 vp vbuf - 12 / glDrawArrays
	0 glBindVertexArray
	vbuf 'vp !
	0 'btu ! ;

:vt | pos uv -- ; one vertex with the color vcol
	swap vp d!+ d!+ vcol swap d!+ 'vp ! ;

:vtc | pos uv col -- ; one vertex with its own color
	swap rot vp d!+ d!+ d!+ 'vp ! ;

:setex | tex w h -- ; texture of the batch, flush only if the batch has other texture
	pick2 btex =? ( 4drop 1 'btu ! ; ) drop
	btu 1? ( gflush ) drop
	'bsz 4 + d! 'bsz d! 'btex !
	1 'btu ! ;

|-------------------------------------
| entry of a char: x | w<<16 | y<<32 | h<<48 (pixels of the atlas)
:fntex | tex font -- font ; texture and atlas size of the record
	2dup !
	over 32 >> $ffff and over 24 + d!
	swap 48 >> $ffff and over 28 + d!
	1 'fontn +! ;


:ftabfill | font -- ; 16x16 grid of cells ws x hs
	dup 8 + @ over 16 + @ rot 40 +		| cw ch adr
	ab[ >a
	0 ( 256 <?				| cw ch i
		dup $f and pick3 *
		over 4 >> $f and pick3 * 32 << or
		pick2 48 << or pick3 16 << or a!+
		1+ ) 3drop
	]ba ;

::fnew | tex -- font ; record for a font with its own table (0 if full): set ws hs at +8 +16 and the 256 entries at +40
	fontn 8 >=? ( 2drop 0 ; ) drop
	fontn 2088 * 'fontlist +		| tex font
	0 over 8 + ! 0 over 16 + !
	fntex ;

::fload | "file" cw ch -- font ; load the atlas (max 8 fonts, 0 if full)
	fontn 8 >=? ( 4drop 0 ; ) drop
	fontn 2088 * 'fontlist +		| file cw ch font
	swap over 16 + !			| file cw font
	swap over 8 + !				| file font
	swap glLoadImg				| font tex
	over fntex				| font font
	ftabfill ;

::txfont | font -- ; select the font (from fload or txload) for ftext and the tx words
	0? ( drop ; )
	dup 'fcur !
	@+ 'ftex ! @+ 'ws ! @+ 'hs ! @ 'fatlas !
	fcur 40 + 'ftab ! ;

::txfont@ | -- font ; the font selected now
	fcur ;

|-------------------------------------
::glgfx
	fixFontResize

	'gl_shader loadShaderv
	dup "u_FontTexture" glGetUniformLocation 'unitex !
	dup "projection"    glGetUniformLocation 'unipro !
	dup "uAtlas"        glGetUniformLocation 'uniatlas !
	'glshader !

	0 'fontn !
	"media/img/VGA8x16.png" 8 16 fload txfont

	1 'fvt glGenVertexArrays
	1 'fbt glGenBuffers
	fvt glBindVertexArray
	GL_ARRAY_BUFFER fbt glBindBuffer
	GL_ARRAY_BUFFER 196608 0 GL_STREAM_DRAW glBufferData
	0 glEnableVertexAttribArray
	0 1 GL_INT 12 0 glVertexAttribIPointer
	1 glEnableVertexAttribArray
	1 1 GL_INT 12 4 glVertexAttribIPointer
	2 glEnableVertexAttribArray
	2 1 GL_INT 12 8 glVertexAttribIPointer
	0 glBindVertexArray
	vbuf 'vp !
	0 'btu ! 0 'btex !
	1 'bsz d! 1 'bsz 4 + d!
	;

|---------------------------------------
| images: fimgload | "" -- idx
##icol $ffffffff	| color (tint) of the next image quad
##imgtint $ffffffff	| tint of image, images, imageb, imagebb ($AARRGGBB)

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

|------- state
::fini
	GL_DEPTH_TEST glDisable
	GL_CULL_FACE glDisable
	GL_BLEND glEnable
	GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA glBlendFunc
	0 0 sw sh glViewport
	here $ffff + | 64k ahead (can inside gui modify here)
	dup 'vbuf ! 'vp ! 
	0 'btu !
	$ffffffff 'imgtint !
	;

::fend
	gflush
	GL_DEPTH_TEST glEnable
	GL_BLEND glDisable
	0 glUseProgram
	;

|---------------------------------------
| quads: positions q0..q3 (int16 pairs), uv u0..u3
#q0 #q1 #q2 #q3
#u0 #u1 #u2 #u3

:rc | x y w h -- x x1 y y1 ; corners of the rect
	swap pick3 + -rot over + ;

:setq | x y w h -- ; q0..q3 from the rect
	rc pick3 pick2 p16 'q0 !
	pick2 pick2 p16 'q1 !
	pick2 over p16 'q2 !
	nip nip p16 'q3 ! ;

:setuv | x y w h -- ; u0..u3 from the source rect
	rc pick3 pick2 p16 'u0 !
	pick2 pick2 p16 'u1 !
	pick2 over p16 'u2 !
	nip nip p16 'u3 ! ;

:vs | x y -- ; solid vertex (uv = -1)
	p16 -1 vt ;

:qt | -- ; textured quad
	q0 u0 vt q1 u1 vt q2 u2 vt
	q0 u0 vt q2 u2 vt q3 u3 vt ;

|---------------------------------------
| text
:tfont | -- ; texture of the current font in the batch
	ftex $ffff and 'fatlas d@+ swap d@ setex ;

:gchar | char --
|	6 vroom
	$ff and 3 << ftab + @				| e
	xs ys pick2 16 >> $ffff and fscale *		| e xs ys w
	pick3 48 >> fscale * setq			| e
	dup 16 >> $ffff and fscale * 'xs +!
	dup 48 >> >r
	dup $ffff and swap dup 32 >> $ffff and swap
	16 >> $ffff and r>				| xt yt cw ch
	setuv qt ;

:gtext | "" n -- ; n chars at xs ys, xs advances
	( 1? 1- swap c@+ gchar swap ) 2drop ;

::fat
	'ys ! 'xs ! ;

::ftextn | "" n -- ; draw n chars of the string with fcolor at fat
	tfont fcolor 'vcol !
	gtext ;

::ftext | "" --
	count ftextn ;

|---------------------------------------
| solid shapes
::color | rgb -- ; draw color $RRGGBB (alpha 255)
	$ff000000 or 'fcolor ! ;

::colorA | argb -- ; draw color $AARRGGBB
	'fcolor ! ;

::frect | x y w h -- ; filled rectangle (covers x..x+w-1, y..y+h-1)
	|6 vroom 
	fcolor 'vcol !
	rc					| x x1 y y1
	pick3 pick2 vs  pick2 pick2 vs  pick2 over vs
	pick3 pick2 vs  pick2 over vs  nip nip vs ;

::rect | x y w h -- ; rectangle outline (same area as frect)
	2dup min 3 <? ( drop frect ; ) drop
	pick3 pick3 pick3 1 frect			| top
	pick3 pick3 pick2 + 1- pick3 1 frect		| bottom
	pick3 pick3 1+ 1 pick3 2 - frect		| left
	2 - 2swap				| w h-2 x y
	1+ rot 2swap + 1- -rot			| x+w-1 y+1 h-2
	1 swap frect ;				| right

::lineH | x1 y x2 -- ; horizontal line, both ends included
	pick2 - 1+ 1 frect ;

::lineV | x y1 y2 -- ; vertical line, both ends included
	over - 1+ 1 swap frect ;

:vg | x y rgb -- ; solid vertex with its own color $RRGGBB
	>r p16 -1 r> $ff000000 or vtc ;

::lineHg | x1 y x2 c1 c2 -- ; horizontal line, both ends included, gradient from the color c1 to c2 ($RRGGBB)
	|6 vroom
	rot 1+ -rot				| x1 y x2+1 c1 c2
	pick4 pick4 pick3 vg
	pick2 pick4 pick2 vg
	pick2 pick4 1+ pick2 vg
	pick4 pick4 pick3 vg
	pick2 pick4 1+ pick2 vg
	drop nip swap 1+ swap vg ;

::lineVg | x y1 y2 c1 c2 -- ; vertical line, both ends included, gradient from the color c1 to c2 ($RRGGBB)
	|6 vroom
	rot 1+ -rot				| x y1 y2+1 c1 c2
	pick4 pick4 pick3 vg
	pick4 1+ pick4 pick3 vg
	pick4 1+ pick3 pick2 vg
	pick4 pick4 pick3 vg
	pick4 1+ pick3 pick2 vg
	nip rot drop vg ;

::point | x y -- ; one pixel
	1 1 frect ;

::cls | rgb -- ; clear with the color $RRGGBB
	color 0 0 sw sh frect ;


:xord | x1 y1 x2 y2 -- x1 y1 x2 y2 ; ends ordered by x
	pick3 pick2 <=? ( drop ; ) drop 2swap ;

:yord | x1 y1 x2 y2 -- x1 y1 x2 y2 ; ends ordered by y
	pick2 over <=? ( drop ; ) drop 2swap ;

:linex | x1 y1 x2 y2 -- ; mostly horizontal, 1 pixel high
	xord |6 vroom
	swap 1+ swap				| x1 y1 x2+1 y2
	pick3 pick3 vs  2dup vs  2dup 1+ vs
	pick3 pick3 vs  2dup 1+ vs
	2drop 1+ vs ;

:liney | x1 y1 x2 y2 -- ; mostly vertical, 1 pixel wide
	yord |6 vroom
	1+					| x1 y1 x2 y2+1
	pick3 pick3 vs  2dup vs  over 1+ over vs
	pick3 pick3 vs  over 1+ over vs
	2drop swap 1+ swap vs ;

::line | x1 y1 x2 y2 -- ; line, both ends included
	fcolor 'vcol !
	pick3 pick2 - abs pick3 pick2 - abs <? ( drop liney ; ) drop
	linex ;

::triangle | x1 y1 x2 y2 x3 y3 -- ; filled triangle
	fcolor 'vcol ! |3 vroom
	p16 >r p16 >r p16 -1 vt r> -1 vt r> -1 vt ;

#pp0 #pp1 #ppn

::polyop | x y -- ; start a filled polygon with its first point
	p16 'pp0 ! 1 'ppn ! ;

::polyline | x y -- ; from the third point each new point draws a triangle with the first and the previous one
	p16 1 'ppn +!
	ppn 2 =? ( drop 'pp1 ! ; ) drop
	fcolor 'vcol ! |3 vroom
	pp0 -1 vt pp1 -1 vt dup -1 vt 'pp1 ! ;

|--- ellipses: rows at pixel centers, half width of the row j (j rows from the center)

:ehw | rx ry j -- hw ; half width of the row j (j rows from the center)
	2* 1+ dup *				| rx ry n
	over dup * 2 << swap -			| rx ry d
	0 <=? ( 3drop 0 ; )
	16 << sqrt. rot * swap 2* / $8000 + 16 >> ;

:hrow | x y hw -- ; row of 2*hw pixels centered at x
	rot over - -rot 2* 1 frect ;

::fellipse | rx ry x y -- ; filled ellipse with radii rx ry centered at x y
	0 ( pick3 <?				| rx ry x y j
		pick4 pick4 pick2 ehw		| rx ry x y j hw
		pick3 pick3 pick3 + pick2 hrow
		pick3 pick3 pick3 - 1- rot hrow
		1+ ) 4drop drop ;

:ewdt | rx ry j -- eh ewd ; half width of the row j and thickness of its edge
	pick2 pick2 pick2 ehw >r
	1+ over =? ( 3drop r> dup ; )		| last row: ewd = eh
	ehw r@ swap - 1 max r> swap ;

:erow | x y eh ewd -- ; the two segments of the row y
	pick3 pick2 - pick3 pick2 1 frect
	pick3 pick2 + over - pick3 pick2 1 frect
	4drop ;

::ellipse | rx ry x y -- ; ellipse outline
	0 ( pick3 <?				| rx ry x y j
		pick4 pick4 pick2 ewdt		| rx ry x y j eh ewd
		pick4 pick4 pick4 + pick3 pick3 erow
		pick4 pick4 pick4 - 1- 2swap erow
		1+ ) 4drop drop ;

::fcircle | r x y -- ; filled circle
	pick2 -rot fellipse ;

::circle | r x y -- ; circle outline
	pick2 -rot ellipse ;

|--- rounded rectangles
#rx #ry #rw #rh #rr			| the rect and the radius, shared by the row words

:rins | i -- inset ; inset of the row i (0 = border row)
	rr 1- swap - rr rr rot ehw rr swap - ;

:rinit | r x y w h --
	'rh ! 'rw ! 'ry ! 'rx !
	rw rh min 2/ min 'rr ! ;

::fround | r x y w h -- ; filled rectangle with rounded corners of radius r
	rinit
	rr 0? ( drop rx ry rw rh frect ; ) drop
	0 ( rr <?				| i
		dup rins			| i ri
		rx over + ry pick3 + rw pick3 2* - 1 frect
		rx over + ry rh + 1- pick3 - rw pick3 2* - 1 frect
		drop 1+ ) drop
	rx ry rr + rw rh rr 2* - frect ;

:rwdt | ri i -- wd ; width of the span of the row i
	0? ( drop rw swap 2* - ; )
	1- rins swap - 1 max ;

:rside | i ri wd -- i ; right side of the row i (the first row has none)
	pick2 0? ( 3drop ; ) drop
	rx rw + pick2 - over -			| i ri wd x
	rot drop				| i wd x
	dup ry pick4 + pick3 1 frect
	ry rh + 1- pick3 - rot 1 frect ;

::round | r x y w h -- ; outline of the rounded rectangle
	rinit
	rr 0? ( drop rx ry rw rh rect ; ) drop
	0 ( rr <?				| i
		dup rins 2dup swap rwdt		| i ri wd
		rx pick2 + ry pick4 + pick2 1 frect
		rx pick2 + ry rh + 1- pick4 - pick2 1 frect
		rside
		1+ ) drop
	rx ry rr + 1 rh rr 2* - frect
	rx rw + 1- ry rr + 1 rh rr 2* - frect ;

|---------------------------------------
| images (index of fimgload) with source rect isx isy isw ish
#idx_img #isx #isy #isw #ish

:imgq | -- ; draw q0..q3 with the source rect and the color icol
	idx_img 4 * 'imgtextures + d@
	idx_img 8 * 'imgsizes + d@+ swap d@ setex
	|6 vroom
	isx isy isw ish setuv
	icol 'vcol !
	qt ;

:imgsrc | idx -- ; the whole image as source
	dup 'idx_img ! fimgwh 'ish ! 'isw !
	0 'isx ! 0 'isy !
	imgtint 'icol ! ;

::imgdrawuv | idx dx dy dw dh sx sy sw sh -- ; source region in pixels, dest rect on screen
	'ish ! 'isw ! 'isy ! 'isx !
	setq 'idx_img !
	imgtint 'icol !
	imgq ;

::imgdraw | idx dx dy dw dh -- ; full image scaled to dest rect
	pick4 fimgwh 0 0 2swap imgdrawuv ;

::image | x y img -- ; image at x y with its own size
	imgsrc isw ish setq imgq ;

::images | x y w h img -- ; image scaled to the rectangle x y w h
	imgsrc setq imgq ;

::imagebb | 'src 'dst img -- ; box src of the image into the box dst (x y w h, four int32 each)
	imgsrc
	d@+ swap d@+ swap d@+ swap d@ setq
	d@+ swap d@+ swap d@+ swap d@ 'ish ! 'isw ! 'isy ! 'isx !
	imgq ;

|---------------------------------------
| tilesets: w h "file" tsload -- ts ; the table is kept at here
| ts: img(qword) tw th(int32) tint(int32) then x y (int32) per tile
:tsrow | w iw y -- ; the tiles x y of the row y
	0 ( pick2 pick4 - <=?			| w iw y x
		dup da!+ over da!+
		pick3 + ) 4drop ;

::tsload | w h "file" -- ts
	fimgload				| w h idx
	ab[
	here >a
	dup a!+ pick2 da!+ over da!+ $ffffffff da!+ 0 da!+
	fimgwh					| w h iw ih
	0 ( over pick4 - <=?			| w h iw ih y
		pick4 pick3 pick2 tsrow
		pick3 + ) 4drop drop
	here a> 'here !
	]ba ;

:tilesel | n ts -- ; source rect and texture of the tile n
	dup @ 'idx_img !
	dup 8 + d@ 'isw !
	dup 12 + d@ 'ish !
	dup 16 + d@ 'icol !
	swap 3 << 24 + +
	d@+ 'isx ! d@ 'isy ! ;

::tscolor | rgb ts -- ; color modulation $RRGGBB of the tileset
	16 + dup d@ $ff000000 and rot $ffffff and or swap d! ;

::tsalpha | alpha ts -- ; alpha modulation (0..255) of the tileset
	16 + dup d@ $ffffff and rot $ff and 24 << or swap d! ;

::tsdraw | n ts x y -- ; tile n at x y (its own size)
	>r >r tilesel r> r> isw ish setq imgq ;

::tsdraws | n ts x y w h -- ; tile n scaled to the rectangle x y w h
	>r >r >r >r tilesel r> r> r> r> setq imgq ;

::tsbox | 'box n ts -- ; fill the box (x y w h, four int32) with the source rectangle of tile n
	tilesel
	ab[ >a isx da!+ isy da!+ isw da!+ ish da! ]ba ;

::tsfree | ts -- ; (the textures of glgfx are not freed)
	drop ;

|---------------------------------------
| sprites: image centered at x y, ang (1.0 = full turn), zoom (fixed point)
#cx #cy #cs #sn

:rpt | rx ry -- pos ; corner rotated and moved to the center
	over cs * over sn * - 16 >> cx + >r
	swap sn * swap cs * + 16 >> cy + r> swap p16 ;

:sprgo | x y ang zoom -- ; draw the source rect (idx_img isx..ish) centered
	>r sincos 'cs ! 'sn !
	'cy ! 'cx !
	r> dup isw * 17 >> swap ish * 17 >>	| hw hh
	over neg over neg rpt 'q0 !
	over over neg rpt 'q1 !
	2dup rpt 'q2 !
	swap neg swap rpt 'q3 !
	imgq ;

::sprite | x y img -- ; centered at x y
	imgsrc 0 1.0 sprgo ;

::spriteZ | x y zoom img -- ; centered at x y with zoom
	imgsrc 0 swap sprgo ;

::spriteR | x y ang img -- ; centered at x y rotated
	imgsrc 1.0 sprgo ;

::spriteRZ | x y ang zoom img -- ; centered at x y rotated and with zoom
	imgsrc sprgo ;

|--- spritesheets (same table as tsload)
##sscol $ffffffff

::ssload | w h "file" -- ssprite ; frames w x h of the image
	tsload ;

::sscnt | ssprite -- ssprite n ; number of frames (only right after ssload)
	here over - 24 - 3 >> ;

::sstint | argb -- ; tint color $AARRGGBB of the ssprite words
	'sscol ! ;

::ssnotint | --
	$ffffffff 'sscol ! ;

::sspritewh | ssprite -- w h ; size of a frame
	8 + d@+ swap d@ ;

:sstile | n ss --
	tilesel sscol 'icol ! ;

::ssprite | x y n ssprite -- ; frame n centered at x y
	sstile 0 1.0 sprgo ;

::sspriter | x y ang n ssprite -- ; frame n rotated
	sstile 1.0 sprgo ;

::sspritez | x y zoom n ssprite -- ; frame n with zoom
	sstile 0 swap sprgo ;

::sspriterz | x y ang zoom n ssprite -- ; frame n rotated and with zoom
	sstile sprgo ;

|---------------------------------------
| 2D layer: color, text (fonts from fload or txload), clip, image box
| same words as the SDL side (sdl2gfx + txfont), a gui can sit on any of both
|---------------------------------------
#txcol $ffffff

::txrgb | rgb -- ; text color $RRGGBB, apart from the draw color
	$ffffff and 'txcol ! ;

::fsizeh | -- cnh
	fscale hs * ;

::fsizew | -- cnw
	fscale ws * ;

::fsizecnt | "" cnt -- "" sizew sizeh ; size of cnt cells of a monospace font
	fsizew * fsizeh ;

|--- metrics (with fscale)
::txcw | adr car -- adr' width ; width in pixels of a character
	$ff and 3 << ftab + 2 + w@ fscale * ;

::txch | adr car -- adr' h ; height of a character
	$ff and 3 << ftab + 6 + w@ fscale * ;

::txh | -- h ; height of the font (line height)
	ftab 262 + w@ fscale * ;

::txw | "" -- "" width ; width of the string in pixels
	0 over ( c@+ 1? txcw rot + swap ) 2drop ;

::txfit | w "" -- ncar ; number of bytes of the string that fit in w pixels
	0 over
	( c@+ 1? txcw
		rot +
		pick3 >? ( drop swap - nip ; )
		swap
		) drop nip
	swap - nip ;

::fsize | "" -- "" sizew sizeh
	txw txh ;

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

:tcolor | -- ; vertex color of the text
	txcol $ff000000 or 'vcol ! ;

::txemit | adr car -- adr' ; one char at the cursor with the text color, the cursor moves
	tfont tcolor
	tcx tcy fat gchar xs 'tcx ! ;

::txwriten | "" n -- ; n chars at the cursor with the text color, the cursor moves
	tfont tcolor
	tcx tcy fat gtext xs 'tcx ! ;

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

:curw | str cur -- w ; the cursor x goes to the char cur, w is the width of that char
	swap ( over <? c@+ txcw 'tcx +! ) drop
	c@ $ff and 3 << ftab + 2 + w@ fscale * ;

::txcur | str cur -- ; block cursor on the char cur of str
	curw tcx tcy rot txh frect ;

::txcuri | str cur -- ; insert cursor (bar at the bottom)
	curw tcx tcy txh + txh 2 >> - rot txh 2 >> frect ;

|--- text in a box, wrapped by words (CR LF and ; start a new line)
#strsplit
#strsplit>
#lines
#cntlines

:emit0
	13 =? ( drop dup c@ 10 =? ( swap 1+ swap ) drop 0 ; )
	10 =? ( drop dup c@ 13 =? ( swap 1+ swap ) drop 0 ; )
	$3b =? ( 0 nip ) ;

:<<sp | stro str -- str'
	swap over
	( over <? ( 2drop ; )
		dup c@ $ff and 32 >?
		drop 1- ) drop nip nip ;

:testw | w h x y str -- str
	pick4 over txfit
	over count nip >=? ( drop ; )
	over a!+
	over + <<sp
	0 swap c!+
	testw ;

:splitlines | str --
	here dup >a 'strsplit !
	( c@+ 1? emit0 ca!+ ) nip
	a> 'strsplit> !
	ca!+
	a> 'lines !
	strsplit ( strsplit> <?
		testw dup a!+ >>0
		) drop
	0 a!+
	a> dup 'here !
	lines - 3 >> 'cntlines !
	;

::lwrite | w "str" -- ; left aligned text for txText (ignores w)
	nip txwrite ;
::cwrite | w "str" -- ; centered text in w pixels for txText
	txw rot swap - 2/ 0 tx+at
	txwrite ;
::rwrite | w "str" -- ; right aligned text in w pixels for txText
	txw rot swap - 0 tx+at
	txwrite ;

:vtop	drop ;
:vcen	cntlines txh * - 2/ + txh 2/ + ;
:vbot	cntlines 1- txh * - +  ;

#halign 'cwrite
#valign 'vcen

::txalign | $VH -- ; bits 0-1 horizontal (0 left 1 center 2 right), bits 4-5 vertical (0 top 1 center 2 bottom)
	dup $3 and
	0 =? ( 'lwrite 'halign !  )
	1 =? ( 'cwrite 'halign ! )
	2 =? ( 'rwrite 'halign ! )
	drop
	4 >> $3 and
	0 =? ( 'vtop 'valign ! )
	1 =? ( 'vcen 'valign ! )
	2 =? ( 'vbot 'valign ! )
	drop ;

::txText | w h x y "" -- ; text in the box, aligned with txalign
	mark ab[
	splitlines
	rot
	valign ex
	lines >a (
		2dup txat
		a@+ 1?
		pick3 swap halign ex
		txh + ) drop
	3drop
	]ba empty ;

::imageb | 'box img -- ; image (index of fimgload) into the box x y w h (four int32)
	swap d@+ swap d@+ swap d@+ swap d@ imgdraw ;

|--- clip
#gcx #gcy #gcw #gch

::gclip | x y w h -- ; clip the drawing to the rectangle
	gflush
	'gch ! 'gcw ! 'gcy ! 'gcx !
	3089 glEnable
	gcx sh gcy - gch - gcw gch glScissor ;

::gclip0 | -- ; no clip
	gflush
	3089 glDisable ;
