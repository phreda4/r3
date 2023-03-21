| Obj Model Loader to Robj
| PHREDA 2023
|-----------------------------------
|MEM 512
^r3/win/console.r3
^r3/win/sdl2gl.r3
^r3/lib/3dgl.r3

^r3/util/loadobj.r3
^r3/opengl/glgui.r3

#GL_DEPTH_TEST $0B71
#GL_LESS $0201
#GL_CULL_FACE $0B44

#filename * 1024
#cutpath ( $2f )
#fpath * 1024
#fname 

:getpath | 'filename 'path --
	strcpyl 2 -
	( dup c@ $2f <>? drop 1 - ) drop
	0 swap c!+ 'fname !
	;
	
|-------- file bones and weigth
#bones 

:loadbones | "" --
	here dup 'bones !
	swap load 'here !
	;
	
| 4(w) 1(bone) - x4
:,4xw | vertex -- ;
	20 * bones +
	d@+ f2fp , 1+ d@+ f2fp , 1+ d@+ f2fp , 1+ d@+ f2fp , drop ;
	
:,4xi | vertex
	20 * bones +
	4 + c@+ , 4 + c@+ , 4 + c@+ , 4 + c@+ , drop ;

|---------- file animation bvh
#chsum
#model
#frames
#frametime
#animation
#cbones

#framenow
	
:bvhrload | "" --
	here dup rot load 'here !
	4 + d@+ 'animation !
	d@+ 'chsum !
	d@+ 'frames !
	d@+ 'frametime ! 
	dup 'animation +!
	animation over - 4 >> 'cbones !
	'model !
	;

|-------------------------------
#bonesmat>

#anip
:val anip d@+ swap 'anip ! ;

#lani 'mtranx 'mtrany 'mtranz 'mrotx 'mroty 'mrotz 

:anibones | flags --
	8 >> $ffffff and
	( 1? 
		val
		over $f and 1 - 3 << 'lani + @ ex 
		4 >> ) drop ;

:matbones | bones --
	here 'bonesmat> !
	>b
	framenow chsum * 2 << animation + 'anip !
	matini
	0 ( db@+ 1? dup $ff and
		rot over - 1 + clamp0 | anterior-actual+1
		nmpop
		mpush
		db@+ db@+ db@+ mtran
		swap anibones
		b>
		bonesmat> mcpyf
		64 'bonesmat> +!
		>b ) drop
	nmpop
	;

:matbonesid
	here 'bonesmat> !
	31 ( 1? 1 -
		bonesmat> midf
		64 'bonesmat> +!	
		) drop
	;
	
|-------------------------	
#fprojection * 64
#fview * 64
#fmodel * 64
	
#pEye 0.0 40.0 80.0
#pTo 0 20.0 0.0
#pUp 0 1.0 0

:eyecam
	'pEye 'pTo 'pUp mlookat 'fview mcpyf ;

:initvec
	matini
	0.1 1000.0 0.9 3.0 4.0 /. mperspective 'fprojection mcpyf	| perspective matrix
	eyecam		| eyemat
	'fmodel midf
	;

| DRAW
|-------------
#GL_ARRAY_BUFFER $8892
#GL_ELEMENT_ARRAY_BUFFER $8893

#GL_STATIC_DRAW $88E4

#GL_UNSIGNED_SHORT $1403
#GL_INT $1404
#GL_FLOAT $1406

#GL_FALSE 0
#GL_TRIANGLE $0004

#shaderd
:initshaders
	"r3/opengl/shader/anim_model.sha" loadShader 'shaderd !

	0 shaderd "texture_diffuse1" shader!i
	;
	
#vao 0
#vbo

#buffer>>
#cbuffer
#cfaces
#idt

:,posnor |
	dup $fffff and 1 - ]vert @+ f2fp , @+ f2fp , @ f2fp , 		| pos
	dup 40 >> $fffff and 1 - ]norm @+ f2fp , @+ f2fp , @ f2fp , | nor
	dup 20 >> $fffff and 1 - ]uv @+ f2fp , @ neg f2fp , 		| uv
	dup $fffff and 1 - ,4xi										| 4 index 
	dup $fffff and 1 - ,4xw										| 4 weight
	drop
	;
	

#bufferv
:initobj | "" -- obj
	here 'bufferv !
	facel >b
	nface ( 1? 1 -
		b@+ ,posnor
		b@+ ,posnor
		b@+ ,posnor
		8 b+
		) drop
	
    1 'VAO glGenVertexArrays
    1 'VBO glGenBuffers

    VAO glBindVertexArray
    GL_ARRAY_BUFFER VBO glBindBuffer
    GL_ARRAY_BUFFER nface 3 * 16 * 2 << bufferv GL_STATIC_DRAW glBufferData
	
    0 glEnableVertexAttribArray |POS
    0 3 GL_FLOAT GL_FALSE 16 2 << 0 glVertexAttribPointer
	
    1 glEnableVertexAttribArray | NOR
    1 3 GL_FLOAT GL_FALSE 16 2 << 3 2 << glVertexAttribPointer

    2 glEnableVertexAttribArray | UV
    2 2 GL_FLOAT GL_FALSE 16 2 << 6 2 << glVertexAttribPointer

    3 glEnableVertexAttribArray | bones
    3 4 GL_INT 16 2 << 8 2 << glVertexAttribIPointer

    4 glEnableVertexAttribArray | weight
    4 4 GL_FLOAT GL_FALSE 16 2 << 12 2 << glVertexAttribPointer
	
    0 glBindVertexArray	
	|empty
	nface 3 * 'cfaces !
	"media/obj/Mario/Mario_body.png" glImgTex 'idt !
	
	;

#GL_TEXTURE_2D $0DE1
#GL_TEXTURE0 $84C0

:renderobj | obj --
	GL_DEPTH_TEST glEnable 
	GL_CULL_FACE glEnable
	GL_LESS glDepthFunc 	
	
	shaderd glUseProgram
	'fprojection shaderd "projection" shader!m4
	'fview shaderd "view" shader!m4
	'fmodel shaderd "model" shader!m4
	
	GL_TEXTURE0 glActiveTexture
	GL_TEXTURE_2D idt glBindTexture

|	model matbones
	matbonesid

	shaderd "finalBonesMatrices" glGetUniformLocation 
	cbones 0 here glUniformMatrix4fv
	
	framenow 1 + frames >=? ( 0 nip ) 'framenow !
	
    VAO glBindVertexArray
	GL_TRIANGLE 0 cfaces glDrawArrays 
    0 glBindVertexArray
	;

:deleteobj | obj --
	VBO glDeleteBuffers	
	VAO glDeleteVertexArrays
	;
	
| MAIN
|-----------------------------------
#xm #ym
#rx #ry

:dnlook
	SDLx SDLy 'ym ! 'xm ! ;

:movelook
	SDLx SDLy
	ym over 'ym ! - neg 7 << 'rx +!
	xm over 'xm ! - 7 << neg 'ry +!  
	rx $ffff and 32 << ry $ffff and 16 << or 0 0 0 mrpos
	'fmodel mcpyf	
	;

#modelo

:useobj | "" --
	dup 'fpath getpath
	dup 'filename strcpy
	loadobj 'modelo !

	initobj
	;
	

|---------------------------------------------------	
:objinfo
	$ffffff glcolor
	0 0 glat 'filename gltext
	0 16 glat "Obj view" gltext
	0 32 glat frames framenow "%d %d" sprint gltext
	
	
	;
	
:main

	$4100 glClear | color+depth

	glgui
	'dnlook 'movelook onDnMove	
	objinfo
	
	renderobj
	
	SDL_windows SDL_GL_SwapWindow
	
	SDLkey
	>esc< =? ( exit )
	drop ;

|------------------------------------	


: 
	"test opengl" 800 600 SDLinitGL
	
	glimmgui
		
	initvec
	initshaders
	
	matbonesid
	

	
	mark
	"media/bvh/ChaCha001.bvhr" bvhrload
	"media/bvh/bones2mario" loadbones

	"media/obj/mario/mario.obj"	useobj
	
	'main SDLshow 
	SDLquit
	;