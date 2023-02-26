| OpenGL example
| PHREDA 2023
|MEM 64

^r3/win/console.r3
^r3/lib/str.r3

^r3/win/sdl2gl.r3
^r3/lib/3dgl.r3
^r3/lib/gui.r3
^r3/opengl/gltext.r3

:>>sp0 | adr -- adr'/0	; proxima linea/0
	>>sp dup c@ 0? ( nip ; ) drop ;

#filename * 1024
#cnt 
#images 

#position
#normal
#map1

:]pos | n -- p1
	3 << 3 * position + ;
:]nor | n -- n1
	3 << 3 * normal + ;
:]uv | n -- u1
	3 << 2 * map1 + ;
	
#datavc
#datap
#datap$

|-----------------------------
:<float_array> | adr -- adr
	"<float_array" =pre 0? ( drop ; ) drop
	"count=" findstr
	7 + str>nro 'cnt !
|	cnt "float array:%d" .println
	">" findstr 1 +
	here >a
	( trim 
		"</float_array" =pre 1? ( drop a> 'here ! ; ) drop
		getfenro a!+
		1? ) drop ;
		

:<vcount> | adr -- adr
	"<vcount>" =pre 0? ( drop ; ) drop
	>>sp0
	here dup 'datavc ! >a
	( trim 
		"</vcount>" =pre 1? ( drop a> 'here ! ; ) drop
		getnro a!+
		1? ) drop ;		

:<p> | adr -- adr
	"<p>" =pre 0? ( drop ; ) drop
	>>sp0
	here dup 'datap ! >a
	( trim 
		"</p>" =pre 1? ( drop a> dup 'here ! 'datap$ ! ; ) drop
		getnro a!+
		1? ) drop ;		

|-----------------------------
:toklvl1a
	;
:parseAnimation | adr - adr
	"<library_animations" =pre 0? ( drop ; ) drop
	>>sp0
	( trim 
		"</library_animations" =pre 1? ( drop ; ) drop
		toklvl1a >>sp0 1? ) drop ;

		
:toklvl1ac		
	;
:parseAnimationClip | library node --
	"<library_animation_clips" =pre 0? ( drop ; ) drop
	>>sp0
	( trim
		"</library_animation_clips" =pre 1? ( drop ; ) drop
		toklvl1ac 
		>>sp0 1? ) drop ;

:toklvl1c
|	"<source" =pre 1? (
	<float_array>
	;
	
:parseController | library node --
	"<library_controllers" =pre 0? ( drop ; ) drop
	>>sp0
	( trim 
		"</library_controllers" =pre 1? ( drop ; ) drop
		toklvl1c 
		>>sp0 1? ) drop ;

|-------------------------
:loadimage | adr pre -- adr pre
	swap
	"id=" findstr 4 + | store id "
	dup a!+
	"<init_from>" findstr 11 + | filename "<"
	dup a!+
	swap
	;
	
:parseImage | library node --
	"<library_images" =pre 0? ( drop ; ) drop
	here dup 'images ! >a
	>>sp0
	( trim 
		"</library_images" =pre 1? ( drop a> 'here ! ; ) drop
		"<image" =pre 1? ( loadimage ) drop
		>>sp0 1? ) drop ;

		
:parseEffect  | library node --
	"<library_effects" =pre 0? ( drop ; ) drop
	>>sp0
	( trim 
		"</library_effects" =pre 1? ( drop ; ) drop
		toklvl1c >>sp0 1? ) drop ;
		
:parseMaterial | library node --
	"<library_materials" =pre 0? ( drop ; ) drop
	>>sp0
	( trim 
		"</library_materials" =pre 1? ( drop ; ) drop
		toklvl1c >>sp0 1? ) drop ;
		
:parseCamera | library node --
	"<library_cameras" =pre 0? ( drop ; ) drop
	>>sp0
	( trim 
		"</library_cameras" =pre 1? ( drop ; ) drop
		toklvl1c >>sp0 1? ) drop ;
		
:parseLight | library node --
	"<library_lights" =pre 0? ( drop ; ) drop
	>>sp0
	( trim 
		"</library_lights" =pre 1? ( drop ; ) drop
		toklvl1c >>sp0 1? ) drop ;


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
		
|<polylist material="Ch46_bodySG" count="24564">		
:tok<poly
	"<polylist" =pre 0? ( drop ; ) drop
	"count=" findstr
	7 + str>nro 'cnt !
	">" findstr 1 +
	( trim 
		"</polylist" =pre 1? ( drop ; ) drop
		<vcount>
		<p>
		>>sp0 1? ) drop ;


:parseGeometry | library node --
	"<library_geometries" =pre 0? ( drop ; ) drop
	>>sp0
	( trim 
		"</library_geometries" =pre 1? ( drop ; ) drop
		tok<source
		tok<poly
		>>sp0 1? ) drop ;
	
:parseNode | library node --
	"<library_nodes" =pre 0? ( drop ; ) drop
	>>sp0
	( trim 
		"</library_nodes" =pre 1? ( drop ; ) drop
		toklvl1c >>sp0 1? ) drop ;
		
:parseVisualScene | library node --
	"<library_visual_scenes" =pre 0? ( drop ; ) drop
	>>sp0
	( trim 
		"</library_visual_scenes" =pre 1? ( drop ; ) drop
		toklvl1c >>sp0 1? ) drop ;
		
:parseKinematicsModel | library node --
	"<library_kinematics_models" =pre 0? ( drop ; ) drop
	>>sp0
	( trim 
		"</library_kinematics_models" =pre 1? ( drop ; ) drop
		toklvl1c >>sp0 1? ) drop ;
		
:parseKinematicsScene | adr -- adr
	"<library_physics_models" =pre 0? ( drop ; ) drop
	>>sp0
	( trim 
		"</library_physics_models" =pre 1? ( drop ; ) drop
		toklvl1c >>sp0 1? ) drop ;
		
:parsePhysicsModel | library node --
	"<scene" =pre 0? ( drop ; ) drop
	>>sp0
	( trim 
		"</scene" =pre 1? ( drop ; ) drop
		toklvl1c >>sp0 1? ) drop ;
		

|------------------------------
:daeload | "" --
	dup 'filename strcpy
	here dup rot load 0 swap c!+ 'here !
	( trim 
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
	"r3/opengl/shader/anim_model.fs"
	"r3/opengl/shader/anim_model.vs" 
	loadShaders 'shaderd !

	0 shaderd "texture_diffuse1" shader!i
	;
	
#fprojection * 64
#fview * 64
#fmodel * 64
	
#pEye 0.0 100.0 -100.0
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

:matbonesid
	here 'bonesmat> !
	31 ( 1? 1 -
		bonesmat> midf
		64 'bonesmat> +!	
		) drop
	;
	
#VAO
#VBO
#bufferv
#cfaces
#nface 10
#idt

:initobj | "" -- obj
	here 'bufferv !
	|......................
	0 'nface !
	datap ( datap$ <?
		@+ ]pos @+ f2fp , @+ f2fp , @ f2fp ,
		@+ ]nor @+ f2fp , @+ f2fp , @ f2fp ,
		@+ ]uv @+ f2fp , @ neg f2fp ,
		0 , 0 , 0 , 0 ,
		1.0 f2fp , 0 , 0 , 0 ,
		1 'nface +!
		) drop
	nface "%d" .println

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
	nface 3 * 'cfaces !
	"media/dae/walking/textures/Ch46_1001_Diffuse.png" glImgTex 'idt !
	
	;

		
:renderobj | obj --
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
	
|	framenow 1 + frames >=? ( 0 nip ) 'framenow !
	
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
	
|------------------------------
|----------- BOOT
|------------------------------
:
	cr
	"dae loader" .println
	"media/dae/walking/Walking.dae" daeload	

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