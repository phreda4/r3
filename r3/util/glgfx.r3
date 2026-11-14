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
flat out vec4 vColor;
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
flat in vec4 vColor;
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
#fontlist * 320		| 8 fonts
#fontn 0
#fcur 0			| current font
#ftex 0			| texture of the current font
#fatlas 0		| atlas w h (two int32)
#nfd

|-------------------------------------
| batcher: VMAX = 16384 vertices x 12 bytes
#vbuf * 196608
#vp 0			| address of the next vertex
#vcol $ffffffff		| color of the vertices that are written
#btex 0			| texture of the batch
#bsz 0			| atlas w h of the batch (two int32)
#btu 0			| 1 if the batch has textured vertices

:p16 | lo hi -- int32 ; pack two int16
	16 << swap $ffff and or ;

:vend 'vbuf 196608 + ;

::gflush | -- ; send the batch to the GPU (call it before your own GL calls)
	vp 'vbuf - 0? ( drop ; ) drop
	glshader glUseProgram
	unipro 1 0 'fwintext glUniformMatrix4fv
	unitex 0 glUniform1i
	uniatlas 1 'bsz glUniform2iv
	GL_TEXTURE0 glActiveTexture
	GL_TEXTURE_2D btex glBindTexture
	fvt glBindVertexArray
	GL_ARRAY_BUFFER fbt glBindBuffer
	GL_ARRAY_BUFFER 196608 0 GL_STREAM_DRAW glBufferData	| orphan
	GL_ARRAY_BUFFER 0 vp 'vbuf - 'vbuf glBufferSubData
	GL_TRIANGLES 0 vp 'vbuf - 12 / glDrawArrays
	0 glBindVertexArray
	'vbuf 'vp !
	0 'btu ! ;

:vroom | nverts -- ; flush if they do not fit
	12 * vp + vend >? ( gflush ) drop ;

:vt | pos uv -- ; one vertex with the color vcol
	vcol vp 8 + d!
	vp 4 + d! vp d!
	12 'vp +! ;

:setex | tex w h -- ; texture of the batch, flush only if the batch has other texture
	pick2 btex =? ( 4drop 1 'btu ! ; ) drop
	btu 1? ( gflush ) drop
	'bsz 4 + d! 'bsz d! 'btex !
	1 'btu ! ;

|-------------------------------------
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
	@ 'fatlas 4 + d! ;

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

	'vbuf 'vp ! 0 'btu ! 0 'btex !
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
	'vbuf 'vp ! 0 'btu !
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
#rx0 #ry0 #rx1 #ry1
#q0 #q1 #q2 #q3
#u0 #u1 #u2 #u3

:setrect | x y w h -- ; rx0 ry0 rx1 ry1
	pick2 + 'ry1 !
	pick2 + 'rx1 !
	'ry0 ! 'rx0 ! ;

:setq | -- ; q0..q3 from the rect
	rx0 ry0 p16 'q0 !  rx1 ry0 p16 'q1 !
	rx1 ry1 p16 'q2 !  rx0 ry1 p16 'q3 ! ;

:qs | -- ; solid quad (uv = -1)
	q0 -1 vt q1 -1 vt q2 -1 vt
	q0 -1 vt q2 -1 vt q3 -1 vt ;

:qt | -- ; textured quad
	q0 u0 vt q1 u1 vt q2 u2 vt
	q0 u0 vt q2 u2 vt q3 u3 vt ;

|---------------------------------------
| text
#xt 0 #yt 0

:gchar | char --
	6 vroom
	dup $f and ws * 'xt ! 4 >> $f and hs * 'yt !
	xs 'rx0 ! ys 'ry0 !
	xs ws fscale * + 'rx1 ! ys hs fscale * + 'ry1 !
	setq
	xt yt p16 'u0 !           xt ws + yt p16 'u1 !
	xt ws + yt hs + p16 'u2 !  xt yt hs + p16 'u3 !
	qt
	ws fscale * 'xs +! ;

::fat
	'ys ! 'xs ! ;

::ftextn | "" n -- ; draw n chars of the string with fcolor at fat
	ftex $ffff and 'fatlas d@+ swap d@ setex
	fcolor 'vcol !
	( 1? 1- swap c@+ gchar swap ) 2drop ;

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

|---------------------------------------
| solid shapes
::color | rgb -- ; draw color $RRGGBB (alpha 255)
	$ff000000 or 'fcolor ! ;

::colorA | argb -- ; draw color $AARRGGBB
	'fcolor ! ;

::frect | x y w h -- ; filled rectangle (covers x..x+w-1, y..y+h-1)
	6 vroom fcolor 'vcol !
	setrect setq qs ;

#ox #oy #ow #oh

::rect | x y w h -- ; rectangle outline (same area as frect)
	'oh ! 'ow ! 'oy ! 'ox !
	ow oh min 3 <? ( drop ox oy ow oh frect ; ) drop
	ox oy ow 1 frect
	ox oy oh + 1- ow 1 frect
	ox oy 1+ 1 oh 2 - frect
	ox ow + 1- oy 1+ 1 oh 2 - frect ;

::lineH | x1 y x2 -- ; horizontal line, both ends included
	pick2 - 1+ 1 frect ;

::lineV | x y1 y2 -- ; vertical line, both ends included
	over - 1+ 1 swap frect ;

::point | x y -- ; one pixel
	1 1 frect ;

::cls | rgb -- ; clear with the color $RRGGBB
	color 0 0 sw sh frect ;

#lx1 #ly1 #lx2 #ly2

:lsw | -- ; swap the ends
	lx1 lx2 'lx1 ! 'lx2 !
	ly1 ly2 'ly1 ! 'ly2 ! ;

:linex | -- ; mostly horizontal, 1 pixel high
	lx1 lx2 >? ( lsw ) drop
	6 vroom
	lx1 ly1 p16 'q0 !      lx2 1+ ly2 p16 'q1 !
	lx2 1+ ly2 1+ p16 'q2 !  lx1 ly1 1+ p16 'q3 !
	qs ;

:liney | -- ; mostly vertical, 1 pixel wide
	ly1 ly2 >? ( lsw ) drop
	6 vroom
	lx1 ly1 p16 'q0 !      lx2 ly2 1+ p16 'q1 !
	lx2 1+ ly2 1+ p16 'q2 !  lx1 1+ ly1 p16 'q3 !
	qs ;

::line | x1 y1 x2 y2 -- ; line, both ends included
	'ly2 ! 'lx2 ! 'ly1 ! 'lx1 !
	fcolor 'vcol !
	lx2 lx1 - abs ly2 ly1 - abs <? ( drop liney ; ) drop
	linex ;

::triangle | x1 y1 x2 y2 x3 y3 -- ; filled triangle
	fcolor 'vcol ! 3 vroom
	p16 >r p16 >r p16 -1 vt r> -1 vt r> -1 vt ;

#pp0 #pp1 #ppn

::polyop | x y -- ; start a filled polygon with its first point
	p16 'pp0 ! 1 'ppn ! ;

::polyline | x y -- ; from the third point each new point draws a triangle with the first and the previous one
	p16 1 'ppn +!
	ppn 2 =? ( drop 'pp1 ! ; ) drop
	fcolor 'vcol ! 3 vroom
	pp0 -1 vt pp1 -1 vt dup -1 vt 'pp1 ! ;

|--- ellipses: rows at pixel centers, half width of the row j (j rows from the center)
#ecx #ecy #erx #ery #eh #ewd

:ellset | rx ry x y --
	'ecy ! 'ecx ! 'ery ! 'erx ! ;

:ehw | j -- hw
	2* 1+ dup * ery dup * 2 << swap -
	0 <=? ( drop 0 ; )
	16 << sqrt. erx * ery 2* / $8000 + 16 >> ;

::fellipse | rx ry x y -- ; filled ellipse with radii rx ry centered at x y
	ellset
	0 ( ery <?
		dup ehw 'eh !
		ecx eh - ecy pick2 + eh 2* 1 frect
		ecx eh - ecy pick2 - 1- eh 2* 1 frect
		1+ ) drop ;

::ellipse | rx ry x y -- ; ellipse outline
	ellset
	0 ( ery <?
		dup ehw 'eh !
		dup 1+ ehw eh swap - 1 max 'ewd !
		dup ery 1- =? ( eh 'ewd ! ) drop
		ecx eh - ecy pick2 + ewd 1 frect
		ecx eh + ewd - ecy pick2 + ewd 1 frect
		ecx eh - ecy pick2 - 1- ewd 1 frect
		ecx eh + ewd - ecy pick2 - 1- ewd 1 frect
		1+ ) drop ;

::fcircle | r x y -- ; filled circle
	>r >r dup r> r> fellipse ;

::circle | r x y -- ; circle outline
	>r >r dup r> r> ellipse ;

|--- rounded rectangles
#rx #ry #rw #rh #rr #rii #ri #rwd

:rins | i -- inset ; inset of the row i (0 = border row)
	rr 1- swap - ehw rr swap - ;

:rinit | r x y w h --
	'rh ! 'rw ! 'ry ! 'rx !
	rw rh min 2/ min 'rr !
	rr 'erx ! rr 'ery ! ;

::fround | r x y w h -- ; filled rectangle with rounded corners of radius r
	rinit
	rr 0? ( drop rx ry rw rh frect ; ) drop
	0 'rii !
	( rii rr <? drop
		rii rins 'ri !
		rx ri + ry rii + rw ri 2* - 1 frect
		rx ri + ry rh + 1- rii - rw ri 2* - 1 frect
		1 'rii +! )
	drop
	rx ry rr + rw rh rr 2* - frect ;

:rwdt | i -- wd ; width of the span of the row i
	0? ( drop rw ri 2* - ; )
	1- rins ri - 1 max ;

::round | r x y w h -- ; outline of the rounded rectangle
	rinit
	rr 0? ( drop rx ry rw rh rect ; ) drop
	0 'rii !
	( rii rr <? drop
		rii rins 'ri !
		rii rwdt 'rwd !
		rx ri + ry rii + rwd 1 frect
		rx ri + ry rh + 1- rii - rwd 1 frect
		rii 1? ( rx rw + ri - rwd - ry rii + rwd 1 frect
			rx rw + ri - rwd - ry rh + 1- rii - rwd 1 frect ) drop
		1 'rii +! )
	drop
	rx ry rr + 1 rh rr 2* - frect
	rx rw + 1- ry rr + 1 rh rr 2* - frect ;

|---------------------------------------
| images (index of fimgload) with source rect isx isy isw ish
#idx_img #isx #isy #isw #ish

:imgq | -- ; draw q0..q3 with the source rect and the color icol
	idx_img 4 * 'imgtextures + d@
	idx_img 8 * 'imgsizes + d@+ swap d@ setex
	6 vroom
	isx isy p16 'u0 !           isx isw + isy p16 'u1 !
	isx isw + isy ish + p16 'u2 !  isx isy ish + p16 'u3 !
	icol 'vcol !
	qt ;

:imgsrc | idx -- ; the whole image as source
	dup 'idx_img ! fimgwh 'ish ! 'isw !
	0 'isx ! 0 'isy !
	imgtint 'icol ! ;

::imgdrawuv | idx dx dy dw dh sx sy sw sh -- ; source region in pixels, dest rect on screen
	'ish ! 'isw ! 'isy ! 'isx !
	setrect 'idx_img !
	imgtint 'icol !
	setq imgq ;

::imgdraw | idx dx dy dw dh -- ; full image scaled to dest rect
	pick4 fimgwh 0 0 2swap imgdrawuv ;

::image | x y img -- ; image at x y with its own size
	imgsrc isw ish setrect setq imgq ;

::images | x y w h img -- ; image scaled to the rectangle x y w h
	imgsrc setrect setq imgq ;

::imageb | 'box img -- ; image into the box x y w h (four int32)
	swap d@+ swap d@+ swap d@+ swap d@ imgdraw ;

::imagebb | 'src 'dst img -- ; box src of the image into the box dst (x y w h, four int32 each)
	imgsrc
	d@+ swap d@+ swap d@+ swap d@ setrect
	d@+ swap d@+ swap d@+ swap d@ 'ish ! 'isw ! 'isy ! 'isx !
	setq imgq ;

|---------------------------------------
| tilesets: w h "file" tsload -- ts ; the table is kept at here
| ts: img(qword) tw th(int32) tint(int32) then x y (int32) per tile
::tsload | w h "file" -- ts
	fimgload 'idx_img !
	'ish ! 'isw !
	ab[
	here >a
	idx_img a!+
	isw da!+ ish da!+ $ffffffff da!+ 0 da!+
	idx_img fimgwh 'isy ! 'isx !
	0 ( isy ish - <=?
		0 ( isx isw - <=?
			dup da!+ over da!+
			isw + ) drop
		ish + ) drop
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
	>r >r tilesel r> r> isw ish setrect setq imgq ;

::tsdraws | n ts x y w h -- ; tile n scaled to the rectangle x y w h
	>r >r >r >r tilesel r> r> r> r> setrect setq imgq ;

::tsbox | 'box n ts -- ; fill the box (x y w h, four int32) with the source rectangle of tile n
	tilesel
	ab[ >a isx da!+ isy da!+ isw da!+ ish da! ]ba ;

::tsfree | ts -- ; (the textures of glgfx are not freed)
	drop ;

|---------------------------------------
| sprites: image centered at x y, ang (1.0 = full turn), zoom (fixed point)
#cx #cy #hw #hh #cs #sn

:rpt | rx ry -- pos ; corner rotated and moved to the center
	over cs * over sn * - 16 >> cx + >r
	swap sn * swap cs * + 16 >> cy + r> swap p16 ;

:sprgo | x y ang zoom -- ; draw the source rect (idx_img isx..ish) centered
	>r sincos 'cs ! 'sn !
	'cy ! 'cx !
	r> dup isw * 17 >> 'hw ! ish * 17 >> 'hh !
	hw neg hh neg rpt 'q0 !
	hw hh neg rpt 'q1 !
	hw hh rpt 'q2 !
	hw neg hh rpt 'q3 !
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
