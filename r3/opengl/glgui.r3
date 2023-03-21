| OpenGL example
| PHREDA 2023
|MEM 64
^r3/lib/gui.r3
^r3/lib/3dgl.r3
^r3/win/sdl2gl.r3
^r3/opengl/glutil.r3

| opengl Constant
#GL_DEPTH_TEST $0B71
#GL_LESS $0201
#GL_CULL_FACE $0B44

#GL_ARRAY_BUFFER $8892

#GL_STATIC_DRAW $88E4
#GL_FLOAT $1406
#GL_UNSIGNED_SHORT $1403

#GL_TEXTURE $1702
#GL_TEXTURE0 $84C0
#GL_TEXTURE_2D $0DE1

#GL_BLEND $0BE2
#GL_SRC_ALPHA $0302
#GL_ONE_MINUS_SRC_ALPHA $0303

|-------------------------------------
#fontshader	
#fontTexture 
#fcolor [ 0 0 0 0 ]
#fwintext * 64

#scrshader

|-------------
#vt
#bt

#xt 0 #yt 0 
#xs 0 #ys 0
#ws 8.0 #hs 16.0 
|#ws 16.0 #hs 24.0 

::glimmgui
	sw 16 << 0 0 sh 16 << 1.0 0 mortho
	'fwintext mcpyf
	
	"r3/opengl/shader/font2.sha" loadShader 'fontshader !
	"r3/opengl/shader/basscr.sha" loadShader 'scrshader !
	
|	"media/img/font16x24.png" glImgFnt 'fontTexture !
	"media/img/VGA8x16.png" glImgFnt 'fontTexture !
	;

|--------------	FONT

:fp, f2fp , ;

::glcolor | fc --
	'fcolor >a  
	dup $ff0000 and 255 / f2fp da!+ 
	dup 8 << $ff0000 and 255 / f2fp da!+ 
	16 << $ff0000 and 255 / f2fp da!+
	1.0 f2fp da!+
	;
	
:gchar | char --
	dup $f and 12 << |$1000 * 
	'xt ! | x1
	4 >> $f and 12 << |$1000 * 
	'yt ! | y1

	xs fp, ys fp, 			xt fp, yt fp,
	xs ws + fp, ys fp, 		xt $1000 + fp, yt fp,
	xs ws + fp, ys hs + fp, xt $1000 + fp, yt $1000 + fp,
	
	xs fp, ys fp, 			xt fp, yt fp,
	xs ws + fp, ys hs + fp, xt $1000 + fp, yt $1000 + fp,
	xs fp, ys hs + fp, 		xt fp, yt $1000 + fp,
	
	8.0 'xs +! |16.0 'xs +!
	;
	
::glat | x y --
	16 << 'ys ! 16 << 'xs ! ;
	
::glxat | n --
	16 << 'xs ! ;
	
::glcr | --
	0 'xs ! 16.0 'ys +! ;
	
::gltext | "" --
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
	
	GL_ARRAY_BUFFER over here GL_STATIC_DRAW glBufferData
	0 glEnableVertexAttribArray 0 3 GL_FLOAT 0 4 2 << 0 glVertexAttribPointer
	1 glEnableVertexAttribArray 1 2 GL_FLOAT 0 4 2 << 2 2 << glVertexAttribPointer
	4 0 rot 4 >> glDrawArrays | 4 = triangle 
	0 glBindVertexArray
	1 'vt glDeleteVertexArrays
	1 'bt glDeleteBuffers	
	;
	
:gltextsize | "" -- "" sizew sizeh
	count 8 * 16 ;

:gltextsizecnt | "" cnt -- "" 	
	8 * 16 ;

|-------- RECT	
#wscr
#hscr	

:inishaderg
	scrshader glUseProgram
	'fcolor scrshader "fgColor" shader!v4
	'fwintext scrshader "projection" shader!m4
	1 'vt glGenVertexArrays
	1 'bt glGenBuffers
	vt glBindVertexArray
	GL_ARRAY_BUFFER bt glBindBuffer
	;
	
:endshadergf
	GL_ARRAY_BUFFER over here GL_STATIC_DRAW glBufferData
	0 glEnableVertexAttribArray 0 3 GL_FLOAT 0 2 2 << 0 glVertexAttribPointer
	6 0 rot 3 >> glDrawArrays | TRIANGLE_FAN
	0 glBindVertexArray
	1 'vt glDeleteVertexArrays
	1 'bt glDeleteBuffers	
	;

:endshadergl
	GL_ARRAY_BUFFER over here GL_STATIC_DRAW glBufferData
	0 glEnableVertexAttribArray 0 3 GL_FLOAT 0 2 2 << 0 glVertexAttribPointer
	2 0 rot 3 >> glDrawArrays | LINE LOOP
	0 glBindVertexArray
	1 'vt glDeleteVertexArrays
	1 'bt glDeleteBuffers	
	;
	
:rectangle | -- size
	here mark
	xs fp, ys fp,
	wscr fp, ys fp,
	wscr fp, hscr fp,
	xs fp, hscr fp,
	here swap - empty ;
	
:circle | -- size
	here mark
	wscr hscr min 1 >>
	xs wscr 1 >> +
	ys hscr 1 >> +
	0 ( 1.0 <? >r
		r@ pick3 ar>xy | xc yc bangle r -- xc yc x y
		swap fp, fp,
		r> 0.1 + ) 4drop 
	here swap - empty ;
	
| 0 = up
| 0.166 =dn
| 0.25 	=le
| 0.082 =ri	
:tri | ang -- size
	>r here mark
	wscr hscr min 1 >>
	xs wscr 1 >> +
	ys hscr 1 >> +
	r> ( 1.0 <? >r
		r@ pick3 ar>xy | xc yc bangle r -- xc yc x y
		swap fp, fp,
		r> 0.334 + ) 4drop 
	here swap - empty ;

::rect | x y w h --
	pick2 + 16 << 'hscr ! pick2 + 16 << 'wscr ! 16 << 'ys ! 16 << 'xs !
	inishaderg rectangle endshadergl ;
	
::frect | x y w h --
	pick2 + 16 << 'hscr ! pick2 + 16 << 'wscr ! 16 << 'ys ! 16 << 'xs !
	inishaderg rectangle endshadergf ;

::circ | x y w h --
	16 << 'hscr ! 16 << 'wscr ! 16 << 'ys ! 16 << 'xs !
	inishaderg circle endshadergl ;

::fcirc | x y w h --
	16 << 'hscr ! 16 << 'wscr ! 16 << 'ys ! 16 << 'xs !
	inishaderg circle endshadergf ;

	
|--------------	GUI
#padx 2 #pady 2
#curx 10 #cury 10
#boxw 100 #boxh 20
#winx 10 #winy 10

::glgui |
	gui 
	10 'curx ! 10 'cury !
	
	GL_DEPTH_TEST glDisable 
	GL_CULL_FACE glDisable
	GL_BLEND glEnable
	GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA glBlendFunc
	;

::glwin | xini yini w h --
	'boxh ! 'boxw !
	'cury ! 'curx ! ;

|----------------------	
::gldn
	pady 1 << boxh + 'cury +! ;
::glri
	padx 1 << boxw + 'curx +! ;	
	
::gltextcen | "" --
	gltextsize swap
	boxw swap - 1 >> curx + padx + swap
	boxh swap - 1 >> cury + pady + 
	glat
	gltext ;

|----------------------	
::gltbtn | 'click "" --
	curx padx + cury pady + boxw boxh 
	2over 2over guiBox
	$0000ff [ $00007f nip ; ] guiI glcolor
	frect
	$ffffff glcolor
	gltextcen
	onClick ;
	
|----------------------
:slideh | 0.0 1.0 'value --
	sdlx curx padx + - boxw clamp0max 
	2over swap - | Fw
	boxw */ pick3 +
	over ! ;
	
:slideshow | 0.0 1.0 'value --
	$00007f glcolor
	curx padx + cury pady + boxw boxh frect
	$3f3fff [ $7f7fff nip ; ] guiI glcolor
	dup @ pick3 - 
	boxw 8 - pick4 pick4 swap - */ 
	curx padx + 1 + +
	cury pady + 2 + 
	6 
	boxh 4 - 
	frect ;
	
::glSliderf | 0.0 1.0 'value --
	curx padx + cury pady + boxw boxh guiBox
	'slideh dup onDnMoveA | 'dn 'move --	
	slideshow
	$ffffff glcolor @ .f2 gltextcen
	2drop ;

::glSlideri | 0 255 'value --
	curx padx + cury pady + boxw boxh guiBox
	'slideh dup onDnMoveA | 'dn 'move --	
	slideshow	
	$ffffff glcolor @ .d gltextcen
	2drop ;

|----------------------	
:check | 'var ""
	curx padx + cury pady + 14 boxh frect
	over @ 1 nand? ( drop ; ) drop 
	$7f7fff glcolor 
	curx padx + 4 + cury pady + 4 + 8 boxh 8 - frect
	;
	
::glCheck | 'val "op1" -- ; v op1  v op2  x op3
	curx padx + cury pady + boxw boxh guiBox
	$00007f [ $0000ff nip ; ] guiI glcolor 
	check
	$ffffff glcolor 
	curx padx + 20 + cury pady + glat
	gltext
	[ dup @ 1 xor over ! ; ] onClick
	drop ;

|----------------------
#cntlist
	
:makelist | "" -- list
	1 'cntlist !
	here >a
	a> swap
	( c@+ 1?
		$7c =? ( 1 'cntlist +! 0 nip )
		ca!+ ) ca!+ 
	a> 'here !
	drop ;
	
:nlist | here n -- str
	( 1? 1 - swap >>0 swap ) drop ;

|----------------------
:radio | 'var nro "" -- 'var nro "" 
	curx padx + cury pady + 14 boxh fcirc
	pick2 @ pick2 <>? ( drop ; ) drop 
	$7f7fff glcolor 
	curx padx + 3 + cury pady + 3 + 9 boxh 7 - fcirc
	;
	
:iglRadio | val nro str -- val nro str
	curx padx + cury pady + boxw boxh guiBox
	$00007f [ $0000ff nip ; ] guiI glcolor 
	radio
	$ffffff glcolor 
	curx padx + 20 + cury pady + glat
	dup gltext
	[ over pick3 ! ; ] onClick
	;

::glRadio | 'val "op1|op2|op3" -- ; ( ) op1  (x) op2 ( ) op3
	mark
	makelist
	0 ( cntlist <? swap
		iglRadio gldn |glri
		>>0 swap 1 + ) 3drop 
	empty ;
	
|----------------------	
::glCombo | 'val "op1|op2|op3" -- ; [op1  v]
	mark
	makelist
	curx padx + cury pady + boxw boxh
	2over 2over guiBox rect	
	$00007f [ $0000ff nip ; ] guiI glcolor 
	$ffffff glcolor 
	curx padx + 1 + cury pady + boxh 16 - 1 >> + glat	
	over @ nlist gltext
	
	[ dup @ 1 + cntlist >=? ( 0 nip ) over ! ; ] onClick
	drop
	empty
	;

|----------------------
:glwindow
	;
:gltab
	;
:glTable
	;

|--- Edita linea
#cmax
#padi>	| inicio
#pad>	| cursor
#padf>	| fin

:lins  | c --
	padf> padi> - cmax >=? ( 2drop ; ) drop
	pad> dup 1 - padf> over - 1 + cmove> 1 'padf> +!
:lover | c --
	pad> c!+ dup 'pad> !
	padf> >? (
		dup padi> - cmax >=? ( swap 1 - swap -1 'pad> +! ) drop
		dup 'padf> ! ) drop
:0lin | --
	0 padf> c! ;
:kdel
	pad> padf> >=? ( drop ; ) drop
	1 'pad> +!
:kback
	pad> padi> <=? ( drop ; )
	dup 1 - swap padf> over - 1 + cmove -1 'padf> +! -1 'pad> +! ;
:kder
	pad> padf> <? ( 1 + ) 'pad> ! ;
:kizq
	pad> padi> >? ( 1 - ) 'pad> ! ;
:kup
	pad> ( padi> >?
		1 - dup c@ $ff and 32 <? ( drop 'pad> ! ; )
		drop ) 'pad> ! ;
:kdn
	pad> ( c@+ 1?
		$ff and 32 <? ( drop 'pad> ! ; )
		drop ) drop 1 - 'pad> ! ;

#modo 'lins

::glcursoro | pos --
	xs ys >r >r
	gltextsizecnt drop | w h
	xs 16 >> + ys 16 >> 8 16 frect
	r> r> 'ys ! 'xs !
	;
	
::glcursori | pos --
	xs ys >r >r
	gltextsizecnt drop | w h
	xs 16 >> + ys 16 >> 12 + 8 4 frect
	r> r> 'ys ! 'xs !
	;

:cursor
	msec $100 and? ( drop ; ) drop
	$ff00 glcolor
	modo 'lins =? ( drop pad> padi> - glcursori ; ) drop
	pad> padi> - glcursoro ;
	
|----- ALFANUMERICO
:iniinput | 'var max IDF -- 'var max IDF
	pick2 1 - 'cmax !
	pick3 dup 'padi> !
	( c@+ 1? drop ) drop 1 -
	dup 'pad> ! 'padf> !
	'lins 'modo !
	;

:chmode
	modo 'lins =? ( drop 'lover 'modo ! ; )
	drop 'lins 'modo ! ;

:proinputa | --
	cursor 
	SDLchar 1? ( modo ex ; ) drop
	SDLkey 0? ( drop ; )
	<ins> =? ( chmode )
	<le> =? ( kizq ) <ri> =? ( kder )
	<back> =? ( kback ) <del> =? ( kdel )
	<home> =? ( padi> 'pad> ! ) <end> =? ( padf> 'pad> ! )
	<tab> =? ( nextfoco )
	<ret> =? ( nextfoco )
|	<shift> =? ( 1 'mshift ! ) >shift< =? ( 0 'mshift ! )
|	<dn> =? ( nextfoco ) <up> =? ( prevfoco )
	drop
	;


|************************************
::glInput | 'buff max --
	$ff glcolor
	curx padx + cury pady + 2dup boxw boxh 
	2over 2over guiBox rect
	boxh 16 - 1 >> + glat
|	$7f7f7f [ $ffffff nip ; ] guiI glcolor
	'proinputa 'iniinput w/foco
	'clickfoco onClick
	$ffffff glcolor
	drop gltext ;

:glInputInt | 'buff  --
	;
:glInputFix | 'buff  --
	;

