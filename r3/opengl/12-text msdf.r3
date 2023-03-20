| OpenGL example
| PHREDA 2023
|MEM 64
^r3/lib/3dgl.r3
^r3/lib/rand.r3
^r3/lib/gui.r3
^r3/util/arr16.r3
^r3/lib/trace.r3

^r3/win/sdl2.r3
^r3/win/sdl2gl.r3

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

#GL_DEPTH_BUFFER_BIT $100	
#GL_UNPACK_ALIGNMENT $0CF5
#GL_LINEAR $2601

#GL_BLEND $0BE2
#GL_SRC_ALPHA $0302
#GL_ONE_MINUS_SRC_ALPHA $0303

|-------------------------------------
#fontshader	
#fontTexture 
#fcolor [ 0 0 0 0 ]

#fwintext * 64

#arrt
#arrf
#fw 304.0 #fh 304.0 

:savech | adr char --
	32 <? ( 2drop ; ) 32 -
	9 * 2 << arrf + >a
	1 + str>fnro da!+
	1 + str>fnro da!+
	1 + str>fnro da!+
	1 + str>fnro da!+
	1 + str>fnro da!+
	1 + str>fnro fw /. da!+
	1 + str>fnro fh swap - fh /. da!+
	1 + str>fnro fw /. da!+
	1 + str>fnro fh swap - fh /. da!+
	drop ;
	
:genarr | str --
	here dup 'arrt !
	"media/msdf/Roboto.csv" load 
	0 swap c!+ 
	dup 'here ! 'arrf !
	arrf 0 9 255 32 - * dfill 
	arrt
	( dup c@ 1? drop
		dup str>nro 
		savech		
		>>cr trim
		) 2drop
	9 255 32 - * 2 << 'here +!
	;


:initshaders
	800.0 0 0 600.0 1.0 -1.0 mortho 'fwintext mcpyf
	"r3/opengl/shader/msdf1.sha" loadShader 'fontshader !
	
	"media/msdf/roboto.png" glImgFnt 'fontTexture !
	
	genarr	
	;

|---------------------------------------
#vt
#bt

:fp, f2fp , ;

:fgcolor | fc --
	'fcolor >a  
	dup $ff0000 and 255 / f2fp da!+ 
	dup 8 << $ff0000 and 255 / f2fp da!+ 
	dup 16 << $ff0000 and 255 / f2fp da!+ 
	8 >> $ff0000 and 255 / f2fp da! 
	;

	
#size 30.0
#xs 0 #ys 0
	
#sl #sb #sr #st		
#l #b #r #t	

:gchar |ch
	32 <? ( drop ; ) 32 - 9 * 2 << arrf + >a
	da@+
	
	da@+ size *. xs + 'sl ! ys size + da@+ size *. - 'sb !
	da@+ size *. xs + 'sr !	ys size + da@+ size *. - 'st !
	
	da@+ 'l ! da@+ 'b ! da@+ 'r ! da@+ 't !
	
	sl fp, st fp,	l fp, t fp,
	sr fp, st fp,	r fp, t fp,
	sr fp, sb fp,	r fp, b fp,
	
	sl fp, st fp,	l fp, t fp,
	sr fp, sb fp,	r fp, b fp,
	sl fp, sb fp,	l fp, b fp,
	
	size *. 'xs +!
	;

:glat
	16 << 'ys ! 16 << 'xs ! ;
	
:glcr
	0 'xs ! size 'ys +! ;
	
:gltext | "" --
	GL_DEPTH_TEST glDisable 
	GL_CULL_FACE glDisable
	GL_BLEND glEnable
	GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA glBlendFunc
	
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

	GL_CULL_FACE glDisable
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


|--------------	
:main
	$4100 glClear | color+depth

	msec 5 << $3fffff and 5.0 + 'size !
	
	$ffffffff fgcolor
	0 0 glat
	"Hola Forth/r3 - OpenGL" gltext glcr
	$ff0000ff fgcolor 
	msec "%h" sprint gltext glcr
	$ff00ff00 fgcolor
	"Bitmap FONT" gltext glcr
	
	SDL_windows SDL_GL_SwapWindow
	SDLkey
	>esc< =? ( exit ) 	
	drop ;	
	
|----------- BOOT
:
	"test opengl" 800 600 SDLinitGL
|	0 0 800 600 glViewport
|	GL_DEPTH_TEST glEnable 
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