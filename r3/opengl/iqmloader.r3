| Parse iqm file format and show in opengl
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
#filepath * 1024
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
#IQM_CUS	| $10 -> $7

#nil 0 0		
  
:]offvpos IQM_POSITION 0? ( 2drop 'nil ; ) swap 3 2 << * + ;
:]offvtex IQM_TEXCOORD 0? ( 2drop 'nil ; ) swap 2 2 << * + ;
:]offvnor IQM_NORMAL 0? ( 2drop 'nil ; ) swap 3 2 << * + ;
:]offvtan IQM_TANGENT 0? ( 2drop 'nil ; ) swap 4 2 << * + ;
:]offvbin IQM_BLENDINDEXES 0? ( 2drop 'nil ; ) swap 2 << + ;
:]offvbwe IQM_BLENDWEIGHTS 0? ( 2drop 'nil ; ) swap 2 << + ;
:]offvcol IQM_COLOR 0? ( 2drop 'nil ; ) swap 2 << + ;
	
:vertexoff |
	'IQM_POSITION 0 8 fill
	iqm.vertao 
	iqm.verta ( 1? 1- swap
		d@+ $10 and? ( $7 nip ) $7 and
		over 12 + d@ 1? ( iqm. + )
		swap 3 << 'IQM_POSITION + !
		16 + swap ) 2drop ;	

	
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

#GL_UNSIGNED_BYTE $1401
#GL_UNSIGNED_SHORT $1403
#GL_INT $1404
#GL_UNSIGNED_INT $1405
#GL_FLOAT $1406

#GL_FALSE 0
#GL_TRUE 1
#GL_TRIANGLE $0004

#shaderd

:initshaders
|	"r3/opengl/shader/anim_model.fs" "r3/opengl/shader/anim_model.vs"
|	"r3/opengl/shader/forward.fs" "r3/opengl/shader/forward.vs"
	"r3/opengl/shader/f2.fs" "r3/opengl/shader/f2.vs"
	loadShaders 'shaderd !
	;
	
#fprojection * 64
#fview * 64
|#fiview * 64
#fmodel * 64
	
#pEye 0.0 0.0 10.0
#pTo 0 0.0 0.0
#pUp 0 1.0 0.0

:eyecam
	'pEye 'pTo 'pUp mlookat 
	'fview mcpyf 
|	matinv 'fiview mcpyf 
	;

#tex_dif
#tex_nor
#tex_spe

:initvec
	matini
	0.1 1000.0 0.9 3.0 4.0 /. mperspective 
|	-2.0 2.0 -2.0 2.0 -2.0 2.0 mortho
	'fprojection mcpyf	| perspective matrix
	eyecam		| eyemat
	'fmodel midf
	$ffffffff glColorTex 'tex_dif !
	$7f7fffff glColorTex 'tex_nor !
	$000000ff glColorTex 'tex_spe !
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
#cbones 75

:matbonesid | fill animation with id
	here 'bonesmat> !
	cbones ( 1? 1 -
		bonesmat> midf
		64 'bonesmat> +!	
		) drop 	;


|---------------------------------	
#VAO
#VBO
#VIO

#listmesh
#listbones
#listanim

#listframes

:loadt | default string pre -- fl
	'filepath "%s/%s%s" sprint 
		
	dup .println
	dup filexist 0? ( 2drop ; ) drop
	nip glImgTex ;
		
	
:strpath | src dst --
	strcpyl 
	( dup c@ $2f <>? 
		drop 1 - ) drop 0 swap c! ;
	
:,fvec | adr cnt -- adr'
	( 1? 1- swap
		d@+ fp2f , 
		swap ) drop ;

|typedef struct {
|  int parent;
|  uint channelmask;
|  float channeloffset[10];
|  float channelscale[10];

#offfra>
:offval | -- val
	offfra> d@+ swap 'offfra> ! fp2f ;

#trans 0 0 0
#rotat 0 0 0 0
#scale 0 0 0 

:]iqm.pose | nro - ooff
	88 * iqm.poseo + ;

:getpose | frame pose -- frame pose
	dup ]iqm.pose
	'trans >a
	dup 8 + >b | off/+40->scale
	dup 4 + d@ | mask
	$01 ( $400 <?  | mask cnt 
		db@ fp2f swap | mask off cnt
		pick2 and? ( swap offval b> 40 + d@ fp2f *. + swap  )
		swap a!+ 4 b+
		1 << ) 3drop ;

|.................
:iqmload | "" -- obj
	dup 'filename strcpy
	dup 'filepath strpath
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
		dup ]offvtan d@+ da!+ d@+ da!+ d@+ da!+ d@ da!+
		dup ]offvcol d@ da!+
		dup ]offvbin d@ da!+
		dup ]offvbwe d@ da!+
		1+ ) drop 
		
	|......................
    1 'VAO glGenVertexArrays
    1 'VBO glGenBuffers
	1 'VIO glGenBuffers

    VAO glBindVertexArray
    GL_ARRAY_BUFFER VBO glBindBuffer
    GL_ARRAY_BUFFER iqm.vert 15 * 2 << here GL_STATIC_DRAW glBufferData
	
    0 glEnableVertexAttribArray |POS
    0 3 GL_FLOAT GL_FALSE 15 2 << 0 glVertexAttribPointer
    1 glEnableVertexAttribArray | UV
    1 2 GL_FLOAT GL_FALSE 15 2 << 3 2 << glVertexAttribPointer
    2 glEnableVertexAttribArray | NOR
    2 3 GL_FLOAT GL_FALSE 15 2 << 5 2 << glVertexAttribPointer
	3 glEnableVertexAttribArray | TAN
    3 4 GL_FLOAT GL_FALSE 15 2 << 8 2 << glVertexAttribPointer
    4 glEnableVertexAttribArray | COL
    4 4 GL_UNSIGNED_BYTE GL_TRUE 15 2 << 12 2 << glVertexAttribPointer
    5 glEnableVertexAttribArray | B IND
    5 4 GL_UNSIGNED_BYTE GL_TRUE 15 2 << 13 2 << glVertexAttribPointer
    6 glEnableVertexAttribArray | B WEI
    6 4 GL_UNSIGNED_BYTE GL_TRUE 15 2 << 14 2 << glVertexAttribPointer

	|..... rotate triangles
	iqm.trio >a
	iqm.tri ( 1? 1-
		da@ 8 a+ da@ -8 a+ | 0..2
		da!+ 4 a+ da!+
		) drop 
		
	GL_ELEMENT_ARRAY_BUFFER VIO glBindBuffer
	GL_ELEMENT_ARRAY_BUFFER iqm.tri 3 * 2 << iqm.trio GL_STATIC_DRAW glBufferData	
	
    0 glBindVertexArray	

	here 'listmesh !
	|... load texture and meshes
	iqm.mesho
	iqm.mesh dup , 
	( 1? 1- swap
		d@+ drop 			|]iqm.str .print | name
		d@+ ]iqm.str 		|" %s" .print | material
		tex_dif over "" loadt ,
		tex_spe over "spec_" loadt ,
		tex_nor swap "norm_" loadt ,
		d@+ drop d@+ drop | vertex ini-end
		d@+ 3 * 2 << swap | tri-ini (bytes)
		d@+ 3 *  | tri-cnt (vertex)
		, swap ,
		swap ) 2drop 
	
	|............... bones
	| cnt
	| parent | 3pos 4rot 3scale
	here 'listbones !
	iqm.joino
	iqm.join dup , 
	( 1? 1- swap
		d@+ drop |]iqm.str "%s " .print | name
		d@+ , |"%d " .print | parent
		10 ,fvec | fvec3 ,fvec4 ,fvec3
		swap ) 2drop 
	
	|............... anims
	| cnt
	| ini cnt fps flag
	here 'listanim !
	iqm.animo
	iqm.anim dup ,
	( 1? 1 - swap
		d@+ drop |]iqm.str "%s " .print | name
		d@+ , |"%d-" .print | inicio
		d@+ , |"%d " .print | cant
		d@+ fp2f , |"fps:%f " .print
		d@+ , |"%h" .println flag
		swap ) 2drop 
		
	|............... poses
	| frames * poses
	| frame, (40 bytes)/pose
	iqm.frameo 'offfra> !
	iqm.nroframes ,
	iqm.pose ,
	0 ( iqm.nroframes <? 
		0 ( iqm.pose <? 
				getpose
				'trans >a 
				10 ( 1? 1 - a@+ dup "%f " .print , ) drop | dwors (16.16)
				.cr
			1+ ) drop

		1+ ) drop 

	;

:renderobj | obj --

	shaderd glUseProgram
	
	'fprojection shaderd "u_projection" shader!m4
	'fview shaderd "u_view" shader!m4
|	'fiview shaderd "u_inverse_view" shader!m4
	'fmodel shaderd "u_model" shader!m4
	
	0 shaderd "u_point_count" shader!i
  
	0 shaderd "u_ambient_pass" shader!i

	4 shaderd "u_texture" shader!i
	5 shaderd "u_spec" shader!i
	6 shaderd "u_norm" shader!i
	
	|................
	| animation
|	model matbones
	matbonesid

	
	1 shaderd "u_has_skeleton" shader!i
	
	shaderd "u_bone_matrix" glGetUniformLocation 
	cbones 0 here glUniformMatrix4fv
	
|	framenow 1 + frames >=? ( 0 nip ) 'framenow !
	|................
	
    VAO glBindVertexArray
	GL_ELEMENT_ARRAY_BUFFER VIO glBindBuffer
	
	listmesh >a
	da@+ ( 1? 1- 
		GL_TEXTURE0 4 + glActiveTexture GL_TEXTURE_2D da@+ glBindTexture
		GL_TEXTURE0 5 + glActiveTexture GL_TEXTURE_2D da@+ glBindTexture
		GL_TEXTURE0 6 + glActiveTexture GL_TEXTURE_2D da@+ glBindTexture
		GL_TRIANGLE da@+ GL_UNSIGNED_INT da@+ glDrawElements	
		) drop 

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