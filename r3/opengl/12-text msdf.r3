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

:savech | adr char --
	32 <? ( 2drop ; ) 255 >? ( 2drop ; )
	32 - 9 * 2 << arrf + >a
	1 + str>fnro da!+
	1 + str>fnro da!+
	1 + str>fnro da!+
	1 + str>fnro da!+
	1 + str>fnro da!+
	1 + str>fnro glimgw /. f2fp da!+
	1 + str>fnro glimgh swap - glimgh /. f2fp da!+
	1 + str>fnro glimgw /. f2fp da!+
	1 + str>fnro glimgh swap - glimgh /. f2fp da!+
	drop ;
	
:glLoadMsdf | str --
	dup "%s.png" sprint glImgTex 'fontTexture !
	glimgh 16 << 'glimgh !
	glimgw 16 << 'glimgw !
	here dup 'arrt !
	swap "%s.csv" sprint load 
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
	"r3/opengl/shader/msdf.sha" loadShader 'fontshader !

	"media/msdf/roboto-bold" glLoadMsdf
	;

|---------------------------------------
#vt
#bt

:fgcolor | fc --
	'fcolor >a  
	dup 16 >> $ff and $101 * f2fp da!+ | 255.0 255 / --> 255 $101 *
	dup 8 >> $ff and $101 * f2fp da!+ 
	dup $ff and $101 * f2fp da!+ 
	24 >> $ff and $101 * f2fp da! 
	;
	
#size 30.0
#xs 0 #ys 0
	
#sl #sb #sr #st		

:gchar | ch --
	32 <? ( drop ; ) 32 - 
	2 << dup 3 << + arrf + >a |	9 * 2 << 
	da@+ | size
	da@+ size *. xs + f2fp 'sl ! ys size + da@+ size *. - f2fp 'sb !
	da@+ size *. xs + f2fp 'sr ! ys size + da@+ size *. - f2fp 'st !
	da@+ da@+ da@+ da@ | l b r t 
	sl , st ,	pick3 , dup ,
	sr , st ,	over , dup ,
	sr , sb ,	over , pick2 ,

	sl , st ,	pick3 , ,
	sr , sb ,	, dup ,
	sl , sb ,	swap , ,
	
	size *. 'xs +!
	;

:gltext | "" --
	GL_DEPTH_TEST glDisable 
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
	
	GL_ARRAY_BUFFER over here GL_STATIC_DRAW glBufferData
	0 glEnableVertexAttribArray 0 3 GL_FLOAT 0 16 0 glVertexAttribPointer
	1 glEnableVertexAttribArray 1 2 GL_FLOAT 0 16 8 glVertexAttribPointer
	4 0 rot 4 >> glDrawArrays | 16 bytes per vertex
	0 glBindVertexArray
	1 'vt glDeleteVertexArrays
	1 'bt glDeleteBuffers	
	;

	
:gsize | char -- size
	32 <? ( drop 0 ; ) 32 - 2 << dup 3 << + arrf + d@ ;

:gltextw | "" -- "" wsize
	0 over ( c@+ 1? gsize rot + swap ) 2drop ;

:glat
	16 << 'ys ! 16 << 'xs ! ;
	
:glcr
	0 'xs ! size 'ys +! ;
	


|--------------
#fsize 115.0
	
:main
	$4100 glClear | color+depth

	fsize 'size !
	
	$ffffffff fgcolor
	0 0 glat
	"Hola Forth/r3 - OpenGL" gltext glcr
	$ff0000ff fgcolor 
	msec "%h" sprint gltext glcr
	$ff00ff00 fgcolor
	"Bitmap FONT" gltext glcr
	fsize "%f" sprint gltext

	SDL_windows SDL_GL_SwapWindow
	SDLkey
	>esc< =? ( exit ) 	
	<up> =? ( 1.0 'fsize +! )
	<dn> =? ( -1.0 'fsize +! )

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