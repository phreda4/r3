| Parse iqm7 file format and show in opengl
| PHREDA 2023

|MEM 64

^r3/win/console.r3
^r3/lib/str.r3

^r3/win/sdl2gl.r3
^r3/lib/3dgl.r3
^r3/lib/gui.r3
^r3/opengl/gltext.r3

#filename * 1024

#iqm.
#iqm.str

:]iqm.str 0? ( "" nip ; ) iqm.str + ;

|.................
#iqm.mesh #iqm.mesho 
#iqm.verta #iqm.vertao 
#iqm.tri #iqm.trio
#iqm.join #iqm.joino	
#iqm.pose #iqm.poseo
#iqm.anim #iqm.animo
#iqm.nroframes #iqm.fracha #iqm.frameo #iqm.bouo

:iqmgeometry |
	iqm.vertao 
	iqm.verta ( 1? 1- swap
		d@+ "%d " .print
		d@+ "%d " .print
		d@+ "%d " .print
		d@+ "%d " .print
		d@+ "%h " .println
		swap ) 2drop ;

|.................
:iqmmesh |
	iqm.mesho
	iqm.mesh ( 1? 1- swap
		d@+ ]iqm.str .print | name
		d@+ ]iqm.str " %s" .print | material
		d@+ " %d-" .print
		d@+ "%d " .print
		d@+ " %d-" .print
		d@+ "%d " .println
		swap ) 2drop ;

|.................
:fvec4 
	d@+ fp2f "%f " .print
:fvec3	
	d@+ fp2f "%f " .print
	d@+ fp2f "%f " .print
	d@+ fp2f "%f :" .print ;
	
:iqmjoin
	iqm.joino
	iqm.join ( 1? 1- swap
		d@+ ]iqm.str "%s " .print | name
		d@+ "%d " .print | parent
		fvec3 fvec4 fvec3
		.cr
		swap ) 2drop ;

|.................	
:iqmanim	
	iqm.animo
	iqm.anim ( 1? 1 - swap
		d@+ ]iqm.str "%s " .print | name
		d@+ "%d-" .print d@+ "%d " .print
		d@+ fp2f "fps:%f " .print
		d@+ "%h" .println
		swap ) 2drop ;
|   anims[i].loop   = a->flags || (1<<0);

|.................
#v * 80 | 10 	
:iqmpose
	0 ( iqm.nroframes <? 
		0 ( iqm.pose <? 
|			iqm.poseo 
			0 ( 10 <?
				1+ ) drop
			1+ ) drop
		1+ ) drop ;
	
:iqmtri
|  for (i=0; i<header.num_triangles*3; i+=3) { a = indices[i+0];indices[i+0] = indices[i+2];indices[i+2] = a;  }
	;

|.................
:iqmload | "" --
	dup 'filename strcpy
	here dup rot load 0 swap c!+ 'here !
	'iqm. !
	
	iqm. 28 +
	d@+ drop d@+ iqm. + 'iqm.str ! 
	d@+ 'iqm.mesh ! d@+ iqm. + 'iqm.mesho ! 
	d@+ 'iqm.verta ! d@+ "vert %d " .print d@+ iqm. + 'iqm.vertao !
	d@+ 'iqm.tri ! d@+ iqm. + 'iqm.trio ! d@+ "offa:%h " .println
	d@+ 'iqm.join ! d@+ iqm. + 'iqm.joino !
	d@+ 'iqm.pose ! d@+ iqm. + 'iqm.poseo !
	d@+ 'iqm.anim ! d@+ iqm. + 'iqm.animo !
	d@+ 'iqm.nroframes ! d@+ 'iqm.fracha ! d@+  iqm. + 'iqm.frameo ! d@+ iqm. + 'iqm.bouo !
	d@+ "comm %d " .print d@+ "off:%h " .println
	d@+ "ext %d " .print d@+ "off:%h " .println	
	drop
	
	iqmgeometry	
	iqmmesh
	iqmjoin
	iqmanim
	iqmpose
	;

	
|------------------------------
|------------------------------

#GL_DEPTH_TEST $0B71
#GL_LESS $0201
#GL_CULL_FACE $0B44

#GL_TEXTURE_2D $0DE1
#GL_TEXTURE0 $84C0

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
	"r3/opengl/shader/anim1.fs"
	"r3/opengl/shader/anim1.vs" 
	loadShaders 'shaderd !
	;
	
#fprojection * 64
#fview * 64
#fmodel * 64
	
#pEye 0.0 100.0 100.0
|#pEye 0.0 0.0 10.0
#pTo 0 90.0 0.0
#pUp 0 1.0 0

:eyecam
	'pEye 'pTo 'pUp mlookat 'fview mcpyf ;

:initvec
	matini
	0.1 1000.0 0.9 3.0 4.0 /. mperspective 
|	-2.0 2.0 -2.0 2.0 -2.0 2.0 mortho
	'fprojection mcpyf	| perspective matrix
	eyecam		| eyemat
	'fmodel midf
	;
	
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
	
:objinfo
	0.002 'gltextsize !
	'filename "Model: %s" sprint -0.98 0.9 gltext
|	frames framenow "%d %d" sprint -0.98 -0.8 gltext
	;

|------------------------------
#bonesmat>
#cbones 31

:matbonesid | fill animation with id
	here 'bonesmat> !
	31 ( 1? 1 -
		bonesmat> midf
		64 'bonesmat> +!	
		) drop 	;


	
|---------------------------------	
#VAO
#VBO
#bufferv
#cfaces
#nface 10

:initobj | "" -- obj
	here 'bufferv !
	|......................
	| generate geometry (without index)
	

	0 'nface !
|	'trib ( trib> <?
|		@+ swap @+ rot | hasta desde
|		( over <? @+
|			dup $fffff and ]pos @+ f2fp , @+ f2fp , @ f2fp ,
|			dup 20 >> $fffff and ]nor @+ f2fp , @+ f2fp , @ f2fp ,
|			dup 40 >> $fffff and ]uv @+ f2fp , @ neg f2fp , | y neg
			
|			0 , 0 , 0 , 0 ,
|			1.0 f2fp , 0 , 0 , 0 ,
			
|			1 'nface +!
|			) 2drop		
|		) drop
	nface 3 * 'cfaces !		
	
|	nface "%d" .println

	|......................
    1 'VAO glGenVertexArrays
    1 'VBO glGenBuffers

    VAO glBindVertexArray
    GL_ARRAY_BUFFER VBO glBindBuffer
    GL_ARRAY_BUFFER nface 3 * 16 * 2 << bufferv GL_STATIC_DRAW glBufferData
	
    0 glEnableVertexAttribArray |POS
    0 3 GL_FLOAT GL_FALSE 16 2 << 0 glVertexAttribPointer

    2 glEnableVertexAttribArray | UV
    2 2 GL_FLOAT GL_FALSE 16 2 << 3 2 << glVertexAttribPointer
	
    1 glEnableVertexAttribArray | NOR
    1 3 GL_FLOAT GL_FALSE 16 2 << 5 2 << glVertexAttribPointer

    3 glEnableVertexAttribArray | bones
    3 4 GL_INT 16 2 << 8 2 << glVertexAttribIPointer

    4 glEnableVertexAttribArray | weight
    4 4 GL_FLOAT GL_FALSE 16 2 << 12 2 << glVertexAttribPointer
	
    0 glBindVertexArray	
	;

		
:renderobj | obj --
	shaderd glUseProgram
	'fprojection shaderd "projection" shader!m4
	'fview shaderd "view" shader!m4
	'fmodel shaderd "model" shader!m4
	

	|................
	| animation
|	model matbones
	matbonesid

	shaderd "finalBonesMatrices" glGetUniformLocation 
	cbones 0 here glUniformMatrix4fv
	
|	framenow 1 + frames >=? ( 0 nip ) 'framenow !
	|................
	
    VAO glBindVertexArray
	GL_TRIANGLE 0 cfaces glDrawArrays 
    0 glBindVertexArray
	;
	
|------------------------------
:main
	gui
	'dnlook 'movelook onDnMove
	$4100 glClear | color+depth
	objinfo
	renderobj
	SDL_windows SDL_GL_SwapWindow
	SDLkey
	>esc< =? ( exit )
	drop ;

:debug

	;
	
|------------------------------
|----------- BOOT
|------------------------------
:
	.cr
	"iqm loader" .println
	|.................
	"media/dae/iqm/mrfixit.iqm" iqmload	
|	"media/dae/raph/raph.iqm" iqmload	

	| debug
	
	|.................
	"test opengl" 800 600 SDLinitGL
	GL_DEPTH_TEST glEnable 
	GL_CULL_FACE glEnable
	GL_LESS glDepthFunc 	
	
	initglfont
	initvec
	initshaders
	initobj
	
	'main SDLshow 
	SDLquit	
	;	