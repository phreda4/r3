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

#framenow
#frames

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

#GL_RGB10_A2 $8059
#GL_DEPTH24_STENCIL8 $88F0

#GL_UNSIGNED_BYTE $1401
#GL_UNSIGNED_SHORT $1403
#GL_INT $1404
#GL_UNSIGNED_INT $1405
#GL_FLOAT $1406

#GL_FALSE 0
#GL_TRUE 1
#GL_TRIANGLE $0004

#GL_FRAMEBUFFER $8D40
#GL_RGBA $1908

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
#GL_TEXTURE_CUBE_MAP $8513

#shaderd
#shaderfb

:initshaders
|	"r3/opengl/shader/anim_model.fs" "r3/opengl/shader/anim_model.vs"
	"r3/opengl/shader/forward.fs" "r3/opengl/shader/forward.vs" loadShaders 'shaderd !
	"r3/opengl/shader/fboshader.fs" "r3/opengl/shader/fboshader.vs" loadShaders 'shaderfb !
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
	matini
	msec 0 0 0 mrpos
	matinv
	7 ( 1? 1 -
|		bonesmat> midf
		bonesmat> mcpyf
		64 'bonesmat> +!	
		) drop 	
	70 ( 1? 1 -
		bonesmat> midf
|		bonesmat> mcpyf
		64 'bonesmat> +!	
		) drop 	;
;

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
|	framenow chsum * 2 << animation + 'anip !
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

:calcbones | frame  --
	here 'bonesmat> !
	framenow 
	iqm.pose 40 * +
	matini
	0 ( iqm.pose <? swap 
		
		10 ( 1? 1 - a@+ , ) drop | dwors (16.16)

		bonesmat> mcpyf
		64 'bonesmat> +!
		swap 1+ ) drop 
	;
	
:updatemat
	;
	
|---------------------------------	
#VAO
#VBO
#VIO

#listmesh
#listbones
#listanim

#listframes

:makeinvert
	listbones
	d@+ ( 1? 1- swap
		d@+ | parent
		
		swap ) 2drop ;

|		10 ,fvec | fvec3 ,fvec4 ,fvec3

|------------------------
:loadt | default string pre -- fl
	'filepath "%s/%s%s" sprint 
|	dup .println
	dup filexist 0? ( 2drop ; ) drop
	nip glImgTex ;
		


#trans 0 0 0
#rotat 0 0 0 0
#scale 0 0 0 

:,fvec | adr cnt -- adr'
	'trans >a
	( 1? 1- swap
		d@+ fp2f a!+ 
		swap ) drop 
	matini
	'scale @+ swap @+ swap @ mscale
	'rotat matqua m*
	'trans @+ swap @+ swap @ mtran
	matinv
	here mcpy
	128 'here +!
	;


|typedef struct {
|  int parent;
|  uint channelmask;
|  float channeloffset[10];
|  float channelscale[10];

#offfra>

:offval | -- val
	offfra> d@+ swap 'offfra> ! fp2f ;

:]iqm.pose | nro - ooff
	88 * iqm.poseo + ;

:getpose | frame pose -- frame pose
	dup ]iqm.pose
	'trans >a
|	dup d@ , parent
|	dup d@ $ff and "%h " .print 
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
	
|	'filename "load: %s" .println
	
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
	| parent | mat4x4 inv
	here 'listbones !
	iqm.joino
	iqm.join dup , 
	( 1? 1- swap
		d@+ drop |]iqm.str "%s " .print | name
		d@+ |dup $ff and "%h " .print | parent
		,
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
				10 ( 1? 1 - a@+ , ) drop | dwors (16.16)
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
	
	framenow 1 + frames >=? ( 0 nip ) 'framenow !
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
|  /* -- SCREEN QUAD -- */
#vertices [
    -1.0  1.0 0.0 1.0
    -1.0 -1.0 0.0 0.0
     1.0 -1.0 1.0 0.0
    -1.0  1.0 0.0 1.0
     1.0 -1.0 1.0 0.0
     1.0  1.0 1.0 1.0 
	]
#border [ 1.0 1.0 1.0 1.0 ]

#vaosq
#vbosq

#display.width 800
#display.height 600

#framebuffer.fbo
#framebuffer.rbo
#framebuffer.cbo
#framebuffer.vao 
#framebuffer.vbo
#framebuffer.width
#framebuffer.height
 
#GL_COLOR_ATTACHMENT0 $8CE0
#GL_RENDERBUFFER $8D41
#GL_DEPTH_STENCIL_ATTACHMENT $821A

:render_resize | 
	GL_FRAMEBUFFER framebuffer.fbo glBindFramebuffer

	display.width 'framebuffer.width !
	display.height 'framebuffer.height !

	GL_TEXTURE_2D framebuffer.cbo glBindTexture
	GL_TEXTURE_2D 0 GL_RGB10_A2 framebuffer.width framebuffer.height 0 GL_RGBA GL_UNSIGNED_BYTE 0 glTexImage2D

	GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_NEAREST glTexParameteri
	GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_NEAREST glTexParameteri
	GL_TEXTURE_2D GL_TEXTURE_WRAP_R GL_CLAMP_TO_BORDER glTexParameteri
	GL_TEXTURE_2D GL_TEXTURE_WRAP_S GL_CLAMP_TO_BORDER glTexParameteri
	GL_TEXTURE_2D GL_TEXTURE_WRAP_T GL_CLAMP_TO_BORDER glTexParameteri
  
	GL_TEXTURE_CUBE_MAP GL_TEXTURE_BORDER_COLOR 'border glTexParameterfv
	GL_TEXTURE_2D 0 glBindTexture
	GL_FRAMEBUFFER GL_COLOR_ATTACHMENT0 GL_TEXTURE_2D framebuffer.cbo 0 glFramebufferTexture2D

	GL_RENDERBUFFER framebuffer.rbo glBindRenderbuffer
	GL_RENDERBUFFER GL_DEPTH24_STENCIL8 framebuffer.width framebuffer.height glRenderbufferStorage
	GL_RENDERBUFFER 0 glBindRenderbuffer
	GL_FRAMEBUFFER GL_DEPTH_STENCIL_ATTACHMENT GL_RENDERBUFFER framebuffer.rbo glFramebufferRenderbuffer

|  // test framebuffer
|  if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
|    printf("Error! Framebuffer is not complete\n");

	GL_FRAMEBUFFER 0 glBindFramebuffer
	;
	
:iniscrquad
	'vertices >a 24 ( 1? 1 - da@ f2fp da!+ ) drop
	'border >a 4 ( 1? 1 - da@ f2fp da!+ ) drop
	
	1 'vaosq glGenVertexArrays
	1 'vbosq glGenBuffers
	vaosq glBindVertexArray

	GL_ARRAY_BUFFER vbosq glBindBuffer
	GL_ARRAY_BUFFER 24 2 << 'vertices GL_STATIC_DRAW glBufferData

	0 2 GL_FLOAT GL_FALSE 4 2 << 0 glVertexAttribPointer
	0 glEnableVertexAttribArray

	1 2 GL_FLOAT GL_FALSE 4 2 << 2 2 << glVertexAttribPointer
	1 glEnableVertexAttribArray
	0 glBindVertexArray
	
	1 'framebuffer.fbo glGenFramebuffers
	1 'framebuffer.rbo glGenRenderbuffers
	1 'framebuffer.cbo glGenTextures
	vaosq 'framebuffer.vao !
	vbosq 'framebuffer.vbo !
 
	display.width display.height render_resize
  
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
	iniscrquad
	
	'main SDLshow 
	SDLquit	
	;	