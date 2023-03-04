| Parse iqm7 file format and show in opengl
| PHREDA 2023

|MEM 64

^r3/win/console.r3
^r3/lib/str.r3

^r3/win/sdl2gl.r3
^r3/lib/3dgl.r3
^r3/lib/gui.r3
^r3/opengl/gltext.r3

#EX_IQM_MAGIC "INTERQUAKEMODEL"
#EX_IQM_VERSION 2

#filename * 1024

#iqm.
#iqm.str

:]iqm.str 0? ( "" nip ; ) iqm.str + ;

|.................
#iqm.mesh #iqm.mesho 
#iqm.verta #iqm.vert #iqm.vertao 
#iqm.tri #iqm.trio #iqm.tria
#iqm.join #iqm.joino	
#iqm.pose #iqm.poseo
#iqm.anim #iqm.animo
#iqm.nroframes #iqm.fracha #iqm.frameo #iqm.bouo

#IQM_POSITION
#IQM_TEXCOORD     
#IQM_NORMAL       
#IQM_TANGENT      
#IQM_BLENDINDEXES 
#IQM_BLENDWEIGHTS 
#IQM_COLOR        
  
:]offvpos 3 2 << * IQM_POSITION + ;
:]offvtex 2 2 << * IQM_TEXCOORD + ;
:]offvnor 3 2 << * IQM_NORMAL + ;
:]offvtan 3 2 << * IQM_TANGENT + ;
:]offvbin 2 << IQM_BLENDINDEXES + ;
:]offvbwe 2 << IQM_BLENDWEIGHTS + ;
:]offvcol 2 << IQM_COLOR + ;
	
:vertexoff |
	'IQM_POSITION 0 7 fill
	iqm.vertao 
	iqm.verta ( 1? 1- swap
		d@+ $7 and
		over 12 + d@ iqm. +
		swap 3 << 'IQM_POSITION + !
		16 + swap ) 2drop ;	

|.................

:meshes |
	iqm.mesho
	iqm.mesh ( 1? 1- swap
		d@+ ]iqm.str .print | name
		d@+ ]iqm.str " %s" .print | material
		d@+ " %d-" .print
		d@+ "%d " .print
		d@+ " %d-" .print
		d@+ "%d " .println
		swap ) 2drop ;
		
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
#GL_UNSIGNED_INT $1405
#GL_FLOAT $1406

#GL_FALSE 0
#GL_TRIANGLE $0004

#shaderd

:initshaders
	"r3/opengl/shader/anim_model.fs" "r3/opengl/shader/anim_model.vs" 
|	"r3/opengl/shader/forward.fs" "r3/opengl/shader/forward.vs" 	
	loadShaders 'shaderd !
	;
	
#fprojection * 64
#fview * 64
#fiview * 64
#fmodel * 64
	
#pEye 0.0 0.0 20.0
#pTo 0 0.0 0.0
#pUp 0 1.0 0

:eyecam
	'pEye 'pTo 'pUp mlookat 
	'fview mcpyf 
	matinv
	'fiview mcpyf 
	;

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
#VIO

#idt

|.................
:iqmload | "" -- obj
	dup 'filename strcpy
	here dup rot load 0 swap c!+ 'here !
	'iqm. !
	
	iqm. @ 'EX_IQM_MAGIC @ <>? ( drop ; ) drop
	
	'filename "load: %s" .println
	
	iqm. 28 +
	d@+ drop d@+ iqm. + 'iqm.str ! 
	d@+ 'iqm.mesh ! d@+ iqm. + 'iqm.mesho ! 
	d@+ 'iqm.verta ! d@+ 'iqm.vert ! d@+ iqm. + 'iqm.vertao !
	d@+ 'iqm.tri ! d@+ iqm. + 'iqm.trio ! d@+ iqm. + 'iqm.tria !
	d@+ 'iqm.join ! d@+ iqm. + 'iqm.joino !
	d@+ 'iqm.pose ! d@+ iqm. + 'iqm.poseo !
	d@+ 'iqm.anim ! d@+ iqm. + 'iqm.animo !
	d@+ 'iqm.nroframes ! d@+ 'iqm.fracha ! d@+  iqm. + 'iqm.frameo ! d@+ iqm. + 'iqm.bouo !
|	d@+ "comm %d " .print d@+ "off:%h " .println | comments
|	d@+ "ext %d " .print d@+ "off:%h " .println	 | extend
	drop

	vertexoff
	
	|......................
	| generate geometry (without index)
	here >a
	0 ( iqm.vert <?
		dup ]offvpos d@+ da!+ d@+ da!+ d@ da!+
		dup ]offvtex d@+ da!+ d@ da!+
		dup ]offvnor d@+ da!+ d@+ da!+ d@ da!+
		0 da!+ 0 da!+ 0 da!+ 0 da!+
		1.0 f2fp da!+ 0 da!+ 0 da!+ 0 da!+
		1+ ) drop 
		
	|......................
    1 'VAO glGenVertexArrays
    1 'VBO glGenBuffers
	1 'VIO glGenBuffers

    VAO glBindVertexArray
    GL_ARRAY_BUFFER VBO glBindBuffer
    GL_ARRAY_BUFFER iqm.vert 16 * 2 << here GL_STATIC_DRAW glBufferData
	
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
	
	|..... rotate triangles
	iqm.trio >a
	iqm.tri ( 1? 1-
		da@ 8 a+ da@ -8 a+ | 0..2
		da!+ 4 a+ da!+
		) drop 
		
	GL_ELEMENT_ARRAY_BUFFER VIO glBindBuffer
	GL_ELEMENT_ARRAY_BUFFER iqm.tri 3 * 2 << iqm.trio GL_STATIC_DRAW glBufferData	
	
    0 glBindVertexArray	


	
	
	"media/dae/walking/textures/Ch46_1001_Diffuse.png" glImgTex 'idt !
	;

	
:rendermesh
	;
	
:renderobj | obj --

	shaderd glUseProgram
	
	'fprojection shaderd "projection" shader!m4
	'fview shaderd "view" shader!m4
|	'fiview shaderd "u_inverse_view" shader!m4
	'fmodel shaderd "model" shader!m4
	
|	0 shaderd "u_has_skeleton" shader!i
	
	
	GL_TEXTURE0 glActiveTexture
	GL_TEXTURE_2D idt glBindTexture
	
	|................
	| animation
|	model matbones
	matbonesid

	shaderd "finalBonesMatrices" glGetUniformLocation 
	cbones 0 here glUniformMatrix4fv
	
|	framenow 1 + frames >=? ( 0 nip ) 'framenow !
	|................
	
    VAO glBindVertexArray

	GL_ELEMENT_ARRAY_BUFFER VIO glBindBuffer
	GL_TRIANGLE iqm.tri 3 * GL_UNSIGNED_INT 0 glDrawElements	

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
	|.................
	"test opengl" 800 600 SDLinitGL
	GL_DEPTH_TEST glEnable 
	GL_CULL_FACE glEnable
	GL_LESS glDepthFunc 	

	|.................
	

	"media/dae/iqm/mrfixit.iqm" iqmload	
|	"media/dae/raph/raph.iqm" iqmload	
|	"media/dae/cube.iqm" iqmload	

	| debug
	initglfont
	initvec
	initshaders
	
	'main SDLshow 
	SDLquit	
	;	