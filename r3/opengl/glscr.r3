| OpenGL example
| PHREDA 2023
|MEM 64
^r3/lib/3dgl.r3
^r3/lib/gui.r3
^r3/win/sdl2.r3
^r3/win/sdl2gl.r3
^r3/opengl/shaderobj.r3

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

#GL_DEPTH_COMPONENT $1902
#GL_TEXTURE_MAG_FILTER $2800
#GL_TEXTURE_MAX_ANISOTROPY_EXT $84FE
#GL_TEXTURE_MAX_LEVEL $813D
#GL_TEXTURE_MAX_LOD $813B
#GL_TEXTURE_MIN_FILTER $2801
#GL_TEXTURE_MIN_LOD $813A
#GL_TEXTURE_WRAP_R $8072
#GL_TEXTURE_WRAP_S $2802
#GL_TEXTURE_WRAP_T $2803
#GL_NEAREST $2600
#GL_NEAREST_MIPMAP_LINEAR $2702
#GL_NEAREST_MIPMAP_NEAREST $2700
#GL_CLAMP_TO_BORDER $812D
#GL_TEXTURE_BORDER_COLOR $1004
#GL_FRAMEBUFFER $8D40
#GL_DEPTH_ATTACHMENT $8D00
#GL_TEXTURE1 $84C1
	
#GL_DEPTH_BUFFER_BIT $100	
#GL_UNPACK_ALIGNMENT $0CF5

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

#scrshader

|---------- load img
#surface

#GL_RED $1903
#GL_RGB $1907
#GL_RGBA $1908
#GL_UNSIGNED_BYTE $1401
#GL_CLAMP_TO_EDGE $812F

:Surface->w surface 16 + d@ ;
:Surface->h surface 20 + d@ ;
:Surface->p surface 24 + d@ ;
:Surface->pixels surface 32 + @ ;
:GLBPP 
	surface 8 + @ 16 + c@
	32 =? ( drop GL_RGBA ; ) 
	24 =? ( drop GL_RGB ; )
	drop GL_RED ;

::glImgFnt | "" -- 
	|GL_UNPACK_ALIGNMENT 1 glPixelStorei
	1 'fontTexture glGenTextures
    GL_TEXTURE_2D fontTexture glBindTexture IMG_Load 'Surface !
	GL_TEXTURE_2D 0 GLBPP Surface->w Surface->h 0 pick3 GL_UNSIGNED_BYTE Surface->pixels glTexImage2D
	GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_NEAREST glTexParameteri
	GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_NEAREST glTexParameteri
	GL_TEXTURE_2D GL_TEXTURE_WRAP_S GL_CLAMP_TO_EDGE  glTexParameteri
	GL_TEXTURE_2D GL_TEXTURE_WRAP_T GL_CLAMP_TO_EDGE  glTexParameteri	
	;	
|-------------
#vt
#bt

#xt 0 #yt 0 
#xs 0 #ys 0
#ws 8.0 #hs 16.0 
|#ws 16.0 #hs 24.0 

:glscr
	4 'fcolor memfloat	
	sw 16 << 0 0 sh 16 << 1.0 0 mortho
	'fwintext mcpyf
	
	"r3/opengl/shader/font2.fs"
	"r3/opengl/shader/font2.vs" 
	loadShaders 'fontshader !
	"r3/opengl/shader/basscr.fs"
	"r3/opengl/shader/basscr.vs" 
	loadShaders 'scrshader !
	
|	"media/img/font16x24.png" glImgFnt
	"media/img/VGA8x16.png" glImgFnt
	
	| 1.0 4 >> dup 'wt ! 'ht ! | = $1000
	;

|--------------	FONT

:fp, f2fp , ;

:textcolor | fc --
	'fcolor >a  
	dup $ff0000 and 255 / f2fp da!+ 
	dup 8 << $ff0000 and 255 / f2fp da!+ 
	16 << $ff0000 and 255 / f2fp da! 
	;
	
:gchar | char --
	dup $f and $1000 * 'xt ! | x1
	4 >> $f and $1000 * 'yt ! | y1

	xs fp, ys fp, 			xt fp, yt fp,
	xs ws + fp, ys fp, 		xt $1000 + fp, yt fp,
	xs ws + fp, ys hs + fp, xt $1000 + fp, yt $1000 + fp,
	
	xs fp, ys fp, 			xt fp, yt fp,
	xs ws + fp, ys hs + fp, xt $1000 + fp, yt $1000 + fp,
	xs fp, ys hs + fp, 		xt fp, yt $1000 + fp,
	
	8.0 'xs +!
	|16.0 'xs +!
	;
	
:glat
	16 << 'ys ! 16 << 'xs ! ;
	
:glcr
	0 'xs ! 16.0 'ys +! ;
	
:gltext | "" --
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
	
	GL_ARRAY_BUFFER over here GL_STATIC_DRAW glBufferData
	0 glEnableVertexAttribArray 0 3 GL_FLOAT GL_FALSE 4 2 << 0 glVertexAttribPointer
	1 glEnableVertexAttribArray 1 2 GL_FLOAT GL_FALSE 4 2 << 2 2 << glVertexAttribPointer
	GL_TRIANGLES 0 rot 4 >> glDrawArrays | 16 bytes per vertex
	0 glBindVertexArray
	1 'vt glDeleteVertexArrays
	1 'bt glDeleteBuffers	
	;
	
:gltextsize | "" -- "" sizew sizeh
	count 8 * 16 ;

|-------- RECT	
#wscr
#hscr	
:fillrect | x y w h --
	pick2 + 16 << 'hscr ! pick2 + 16 << 'wscr ! 16 << 'ys ! 16 << 'xs !
	scrshader glUseProgram
	'fcolor scrshader "fgColor" shader!v4
	'fwintext scrshader "projection" shader!m4
	1 'vt glGenVertexArrays
	1 'bt glGenBuffers
	vt glBindVertexArray
	GL_ARRAY_BUFFER bt glBindBuffer
	
	here mark
	xs fp, ys fp,
	wscr fp, ys fp,
	wscr fp, hscr fp,
	xs fp, hscr fp,
	here swap - empty | size

	GL_BLEND glEnable
	GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA glBlendFunc

	GL_ARRAY_BUFFER over here GL_STATIC_DRAW glBufferData
	0 glEnableVertexAttribArray 0 3 GL_FLOAT GL_FALSE 2 2 << 0 glVertexAttribPointer
	6 0 rot 3 >> glDrawArrays | TRIANGLE_FAN
	0 glBindVertexArray
	1 'vt glDeleteVertexArrays
	1 'bt glDeleteBuffers	
	;

:rect | x y w h --
	pick2 + 16 << 'hscr ! pick2 + 16 << 'wscr ! 16 << 'ys ! 16 << 'xs !
	scrshader glUseProgram
	'fcolor scrshader "fgColor" shader!v4
	'fwintext scrshader "projection" shader!m4
	1 'vt glGenVertexArrays
	1 'bt glGenBuffers
	vt glBindVertexArray
	GL_ARRAY_BUFFER bt glBindBuffer
	
	here mark
	xs fp, ys fp,
	wscr fp, ys fp,
	wscr fp, hscr fp,
	xs fp, hscr fp,
	here swap - empty | size

	GL_BLEND glEnable
	GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA glBlendFunc

	GL_ARRAY_BUFFER over here GL_STATIC_DRAW glBufferData
	0 glEnableVertexAttribArray 0 3 GL_FLOAT GL_FALSE 2 2 << 0 glVertexAttribPointer
	2 0 rot 3 >> glDrawArrays | LINE_LOOP
	0 glBindVertexArray
	1 'vt glDeleteVertexArrays
	1 'bt glDeleteBuffers	
	;
	
	
|--------------	GUI
#padx 4 #pady 4
#curx 10 #cury 10
#boxw 80 #boxh 20
#winx 10 #winy 10

:glgui |
	gui 
	10 'curx ! 10 'cury !
	;

:glwin |
	'cury ! 'curx ! ;
	
:gltextcen | "" --
	gltextsize swap
	boxw swap - 1 >> curx + padx + swap
	boxh swap - 1 >> cury + pady + 
	glat
	gltext ;
	
	
:gltbtn | 'click "" --
	curx padx + cury pady + boxw boxh 
	2over 2over guiBox
	$0000ff textcolor
	[ $00007f textcolor ; ] guiI 
	fillrect
	$ffffff textcolor
	gltextcen
	onClick
	;
	
:glSliderf | 0.0 1.0 'value --
	;
:glSlideri | 0 255 'value --
	;
:glCheck | 'val "op1|op2|op3" -- ; v op1  v op2  x op3
	;
:glRadio | 'val "op1|op2|op3" -- ; ( ) op1  (x) op2 ( ) op3
	;
:glCombo | 'val "op1|op2|op3" -- ; [op1  v]
	;
	
:glInputText | 'buff 255 --
	;
:glInputInt | 'buff  --
	;
:glInputFix | 'buff  --
	;
	
:glwindow
	;
:gltab
	;
:glTable
	;
	
:gldn
	pady 1 << boxh + 'cury +! ;
:glri
	padx 1 << boxw + 'curx +! ;
	
|--------------	
:main
	$4100 glClear | color+depth

	glgui

	300 10 glwin
	'exit "hola" gltbtn	gldn
	'exit "salir" gltbtn glri
	'exit "otro" gltbtn glri

	
	0 0 glat
	$ffffff textcolor
	"Hola Forth/r3 - OpenGL" gltext glcr
	$ff textcolor
	msec "%h" sprint gltext glcr
	$ff00 textcolor
	"Bitmap FONT" gltext

	
	
	SDL_windows SDL_GL_SwapWindow
	SDLkey
	>esc< =? ( exit ) 	
	drop ;	
	
|----------- BOOT
:
	"test glscr" 800 600 SDLinitGL
	
|	GL_DEPTH_TEST glEnable 
|	GL_CULL_FACE glEnable	
|	GL_LESS glDepthFunc 

	glscr

	'main SDLshow
	SDL_Quit 
	;	