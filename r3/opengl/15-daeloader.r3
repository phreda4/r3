| Parse collada file format and show in opengl
| PHREDA 2023

|MEM 64

^r3/win/console.r3
^r3/lib/str.r3
^r3/win/sdl2gl.r3
^r3/lib/3dgl.r3
^r3/lib/gui.r3
^r3/opengl/glfgui.r3

|-------------- UTILS

| next space or <, but if start with < skip (nodes not always space separator)
:>>sp0 | adr -- adr'	; next space
	dup c@ $3c =? ( swap 1 + swap ) drop
	( c@+ $ff and 32 >? 
		$3c <>?
		drop ) drop 1 - 
	dup c@ 0? ( nip ; ) drop ;

| string in id (end with ") convert to hash in 64bits
:strhash | adr -- hash
	0 swap
	( c@+ $22 <>? 
		$7f and
		rot dup 57 >>> swap 7 << or
		xor swap ) 2drop ;
	
| copy filename, end with <	
:cpyfile | dst adr  --
	( c@+ $3c <>? rot c!+ swap ) 2drop 0 swap c! ;


#filename * 1024
#cnt 

#images 	| hash-filename
#images$

#position
#normal
#map1

:]pos | n -- p1
	3 << 3 * position + ;
:]nor | n -- n1
	3 << 3 * normal + ;
:]uv | n -- u1
	3 << 2 * map1 + ;
	
| triangle vertex
#trib * 2048
#trib>

#datavc		| count poli
#datavc$
#datap		| data vertex
#datap$

#bwc #bwc$	| cnt bones w cnt
#bwp #bwp$	| bones w 

|-------------------------------
:<float_array> | adr -- adr
	"<float_array" =pre 0? ( drop ; ) drop
	"count=" findstr
	7 + str>nro 'cnt !
	">" findstr 1 +
	here >a
	( trim 
		"</float_array" =pre 1? ( drop a> 'here ! ; ) drop
		getfenro a!+
		1? ) drop ;

:<vcount> | var str -- str
	swap
	"<vcount>" =pre 0? ( drop nip ; ) drop
	8 +
	here dup pick3 ! >a
	( trim 
		"</vcount>" =pre 1? ( drop a> dup 'here ! rot 8 + ! ; ) drop
		getnro ca!+ | save bytes!!
		1? ) drop ;		
		
:<p> | var str -- str
	swap
	"<p>" =pre 0? ( drop nip ; ) drop
	3 +
	here dup pick3 ! >a
	( trim 
		"</p>" =pre 1? ( drop a> dup 'here ! rot 8 + ! ; ) drop
		getnro da!+ | save dwords
		1? ) drop ;		

:<v> | var str -- str
	swap
	"<v>" =pre 0? ( drop nip ; ) drop
	3 +
	here dup pick3 ! >a
	( trim 
		"</v>" =pre 1? ( drop a> dup 'here ! rot 8 + ! ; ) drop
		getnro da!+ | save dwords
		1? ) drop ;	
|-------------------------------
#anisou * 1024
#anisou$

:tok<source
	"<source" =pre 0? ( drop ; ) drop
	"id=" findstr 4 + | store id "
	here over strhash anisou$ !+ !+ 'anisou$ !
	">" findstr 1 +	
	( trim 
		"</source" =pre 1? ( drop ; ) drop
		<float_array>
		>>sp0 1? ) drop ;	


:parseAnimation | adr - adr
	"<library_animations" =pre 0? ( drop ; ) drop
	'anisou 'anisou$ !
	>>sp0
	( trim 
		"</library_animations" =pre 1? ( drop ; ) drop
		tok<source 
		>>sp0 1? ) drop ;

|-------------------------------		
:toklvl1ac		
	;
:parseAnimationClip | --
	"<library_animation_clips" =pre 0? ( drop ; ) drop
	>>sp0
	( trim
		"</library_animation_clips" =pre 1? ( drop ; ) drop
		toklvl1ac 
		>>sp0 1? ) drop ;

|-------------------------------		
#consou * 1024
#consou$

:searchso | hash -- mem
	consou ( consou$ <?
		@+ pick2 =? ( nip ; ) drop
		8 + ) drop
	0
	;
	
#vertexw

|<input semantic="WEIGHT" source="#pCylinderShape1-skin-weights" offset="1"></input>
:tok<input
	"<input semantic=""WEIGHT""" =pre 0? ( drop ; ) drop
	"source=" findstr
	8 + strhash 
	searchso 'vertexw !
	;
	
:tok<source
	"<source" =pre 0? ( drop ; ) drop
	"id=" findstr 4 + | store id "
	here over strhash consou$ !+ !+ 'consou$ !
	">" findstr 1 +	
	( trim 
		"</source" =pre 1? ( drop ; ) drop
		tok<input
		<float_array>
		>>sp0 1? ) drop ;	
	
:tok<wei	
	"<vertex_weights" =pre 0? ( drop ; ) drop
	"count=" findstr
	7 + str>nro 'cnt !
	">" findstr 1 +
	( trim 
		"</vertex_weights" =pre 1? ( drop  ; ) drop
		'bwc <vcount>
		'bwp <v>
		>>sp0 1? ) drop ;
	
:tok<joi	
	"<joints>" =pre 0? ( drop ; ) drop
	( trim 
		"</joints>" =pre 1? ( drop  ; ) drop
		>>sp0 1? ) drop ;	
		
:parseController | --
	"<library_controllers" =pre 0? ( drop ; ) drop
	'consou 'consou$ !
	>>sp0
	( trim 
		"</library_controllers" =pre 1? ( drop ; ) drop
		tok<source
		tok<wei
		>>sp0 1? ) drop ;

|-------------------------------
:loadimage | adr pre -- adr pre
	swap
	"id=" findstr 4 + | store id "
	dup strhash ,q
	"<init_from>" findstr 11 + | filename "<"
	dup ,q
	swap ;
	
:parseImage | library node --
	"<library_images" =pre 0? ( drop ; ) drop
	here 'images !
	>>sp0
	( trim 
		"</library_images" =pre 1? ( drop here 'images$ ! ; ) drop
		"<image " =pre 1? ( loadimage ) drop
		>>sp0 1? ) drop ;

|-------------------------------		
:parseEffect  | library node --
	"<library_effects" =pre 0? ( drop ; ) drop
	>>sp0
	( trim 
		"</library_effects" =pre 1? ( drop ; ) drop
		>>sp0 1? ) drop ;
		
:parseMaterial | library node --
	"<library_materials" =pre 0? ( drop ; ) drop
	>>sp0
	( trim 
		"</library_materials" =pre 1? ( drop ; ) drop
		>>sp0 1? ) drop ;
		
:parseCamera | library node --
	"<library_cameras" =pre 0? ( drop ; ) drop
	>>sp0
	( trim 
		"</library_cameras" =pre 1? ( drop ; ) drop
		>>sp0 1? ) drop ;
		
:parseLight | library node --
	"<library_lights" =pre 0? ( drop ; ) drop
	>>sp0
	( trim 
		"</library_lights" =pre 1? ( drop ; ) drop
		>>sp0 1? ) drop ;

|-------------------------------

:tok<source
	"<source" =pre 0? ( drop ; ) drop
	"name=" findstr 6 + 
	
	"position" =pre 1? ( here 'position ! ) drop
	"normal" =pre 1? ( here 'normal ! ) drop
	"map1" =pre 1? ( here 'map1 ! ) drop
	
	">" findstr 1 +	
	>>sp0
	( trim 
		"</source" =pre 1? ( drop ; ) drop
		<float_array>
		>>sp0 1? ) drop ;

:getv | -- nv
	da@+ $fffff and 
	da@+ $fffff and 20 << or
	da@+ $fffff and 40 << or ;

:genvertexp
	here trib> !+ 'trib> !
	datap >a
	datavc ( datavc$ <? 
		c@+ 3 - >b
		getv getv getv			| 1 2 3
		( 	pick2 ,q over ,q dup ,q
			b> 1? 1 - >b
				nip getv )		| 1 3 4 ..etc
		4drop
		) drop
	here trib> !+ 'trib> ! ;
	
|<polylist material="Ch46_bodySG" count="24564">		
:tok<poly
	"<polylist" =pre 0? ( drop ; ) drop
	"count=" findstr
	7 + str>nro 'cnt !
	">" findstr 1 +
	( trim 
		"</polylist" =pre 1? ( drop genvertexp ; ) drop
		'datavc <vcount>
		'datap <p>
		>>sp0 1? ) drop ;

:genvertext
	here trib> !+ 'trib> !
	datap ( datap$ <?
		d@+ $fffff and swap
		d@+ $fffff and 20 << swap
		d@+ $fffff and 40 << 
		rot or rot or ,q
		) drop 
	here trib> !+ 'trib> ! ;

:tok<tri
	"<triangles" =pre 0? ( drop ; ) drop
	"count=" findstr
	7 + str>nro 'cnt !
	">" findstr 1 +
	( trim 
		"</triangles" =pre 1? ( drop genvertext ; ) drop
		'datap <p>
		>>sp0 1? ) drop ;

:parseGeometry | library node --
	"<library_geometries" =pre 0? ( drop ; ) drop
	>>sp0
	( trim 
		"</library_geometries" =pre 1? ( drop ; ) drop
		tok<source
		tok<poly
		tok<tri
		>>sp0 1? ) drop ;
		
|-------------------------------		
	
:parseNode | --
	"<library_nodes" =pre 0? ( drop ; ) drop
	>>sp0
	( trim 
		"</library_nodes" =pre 1? ( drop ; ) drop
		>>sp0 1? ) drop ;
		
|-----------------------------------	
#bone * 2048	
#bone>			| now
#level
	
:tok>mat	
	"<matrix" =pre 0? ( drop ; ) drop
	">" findstr 1 +
	16 ( 1? 1 - swap 
		getfenro 
		, swap ) drop 
	"/matrix>" findstr 8 + ;
	
:lvlup
	here level bone> !+ !+ 'bone> ! 
	1 'level +! ;
	
:lvldn
	-1 'level +! ;
	
:parseVisualScene | library node --
	"<library_visual_scenes" =pre 0? ( drop ; ) drop
	>>sp0
	0 'level !
	'bone 'bone> !
	( trim 
|		dup "%w" .println
		"</library_visual_scenes" =pre 1? ( drop ; ) drop
		"<node" =pre 1? ( lvlup ) drop
		"</node" =pre 1? ( lvldn ) drop
		tok>mat	
|		"<instance_camera" =pre 1? ( ) drop
|		"<instance_controller" =pre 1? ( ) drop
|		"<instance_light" =pre 1? ( ) drop
|		"<instance_geometry" =pre 1? ( ) drop
|		"<instance_node" =pre 1? ( ) drop
|		"<translate" =pre 1? ( ) drop
|		"<rotate" =pre 1? ( ) drop
		>>sp0 1? ) drop ;

|-----------------------------------		
:parseKinematicsModel | library node --
	"<library_kinematics_models" =pre 0? ( drop ; ) drop
	>>sp0
	( trim 
		"</library_kinematics_models" =pre 1? ( drop ; ) drop
		>>sp0 1? ) drop ;
		
:parseKinematicsScene | adr -- adr
	"<library_physics_models" =pre 0? ( drop ; ) drop
	>>sp0
	( trim 
		"</library_physics_models" =pre 1? ( drop ; ) drop
		>>sp0 1? ) drop ;
		
:parsePhysicsModel | library node --
	"<scene" =pre 0? ( drop ; ) drop
	>>sp0
	( trim 
		"</scene" =pre 1? ( drop ; ) drop
		>>sp0 1? ) drop ;
		

|------------------------------
:daeload | "" --
	dup 'filename strcpy
	'trib 'trib> !
	here dup rot load 0 swap c!+ 'here !
	( trim 
|	dup "%w" .println
		parseAnimation
		parseAnimationClip 
		parseController
		parseImage
		parseEffect
		parseMaterial
		parseCamera
		parseLight 
		parseGeometry
		parseNode 
		parseVisualScene 
		parseKinematicsModel
		parseKinematicsScene
		parsePhysicsModel
		>>sp0 1? ) drop ;

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
	"r3/opengl/shader/anim_model.sha" loadShader 'shaderd !

	0 shaderd "texture_diffuse1" shader!i
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
	0.1 1000.0 0.9 3.0 4.0 /. mperspective 'fprojection mcpyf	| perspective matrix
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
	$ffffff glcolor
	0 0 glat
	'filename "Model: %s " sprint gltext
|	frames framenow "%d %d" sprint gltext
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

#vertexb 
#vertexw

:genbonewe	
	here 'vertexb !
	bwp >a
	bwc ( bwc$ <? 
		c@+ 1 -
		dup 3 - 0 max 
		swap 3 max
		( 1? 1 - da@+ ,c 4 a+ ) drop 
		( 1? 1 - 8 a+ ) drop
		) drop	
		
	here 'vertexw !
	bwp >a
	bwc ( bwc$ <? 
		c@+ 1 - 
		dup 3 - 0 max 
		swap 3 max
		( 1? 1 - 4 a+ da@+ , ) drop 
		( 1? 1 - 8 a+ ) drop
		) drop	
	;
		
:weightvertex | nro --
	dup 2 << vertexb + 
|	c@+ , c@+ , c@+ , c@ ,
	drop 0 , 0 , 0 , 0 ,
	4 << vertexw +
|	d@+ f2fp , d@+ f2fp , d@+ f2fp , d@ f2fp ,
	drop 1.0 f2fp , 0 , 0 , 0 ,	
	;
	
|---------------------------------	
#VAO
#VBO
#bufferv
#cfaces
#nface 10
#idt

:initobj | "" -- obj
	genbonewe	
	here 'bufferv !
	|......................
	| generate geometry (without index)
	
	0 'nface !
	'trib ( trib> <?
		@+ swap @+ rot | hasta desde
		( over <? @+
			dup $fffff and ]pos @+ f2fp , @+ f2fp , @ f2fp ,
			dup 20 >> $fffff and ]nor @+ f2fp , @+ f2fp , @ f2fp ,
			dup 40 >> $fffff and ]uv @+ f2fp , @ neg f2fp , | y neg
			
			$fffff and weightvertex
|			0 , 0 , 0 , 0 ,
|			1.0 f2fp , 0 , 0 , 0 ,
			
			1 'nface +!
			) 2drop		
		) drop
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

	"media/dae/walking/textures/Ch46_1001_Diffuse.png" glImgTex 'idt !
	;

		
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
	glgui	
	objinfo
	renderobj
	SDL_windows SDL_GL_SwapWindow
	SDLkey
	>esc< =? ( exit )
	drop ;

:debug
	"image" .println
	images ( images$ <? @+ "%h >> " .print @+ "%w >> " .println ) drop
	"source con" .println		
	'consou ( consou$ <? @+ "%h >> " .print @+ "%w >> " .println ) drop
	"source ani" .println		
	'anisou  ( anisou$ <? @+ "%h >> " .print @+ "%w >> " .println ) drop
	
	|	bwc ( bwc$ <? c@+ "%d " .print ) drop
|		bwp ( bwp$ <? d@+ "%d " .print ) drop

	;
	
|------------------------------
|----------- BOOT
|------------------------------
:
	.cr
	"dae loader" .println
	|.................
	"media/dae/walking/Walking.dae" daeload	
|	"media/dae/demo.dae" daeload	
|	"media/dae/AstroBoy_walk/astroBoy_walk_Maya.dae" daeload	

	| debug
	
	|.................
	"test opengl" 800 600 SDLinitGL

	
	glimmgui
	
	initvec
	initshaders
	initobj
	
	'main SDLshow 
	SDLquit	
	;	