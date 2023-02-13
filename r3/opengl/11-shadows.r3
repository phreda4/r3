| OpenGL example
| PHREDA 2023
|MEM 64
^r3/lib/3d.r3
^r3/lib/rand.r3
^r3/lib/gui.r3
^r3/util/arr16.r3
^r3/lib/trace.r3

^r3/win/sdl2.r3
^r3/win/sdl2gl.r3

^r3/opengl/shaderobj.r3

| opengl Constant
#GL_DEPTH_TEST $0B71
#GL_LESS $0201
#GL_CULL_FACE $0B44

|-------------------------------------
:glinit
	5 1 SDL_GL_SetAttribute		|SDL_GL_DOUBLEBUFFER, 1);
	13 1 SDL_GL_SetAttribute	|SDL_GL_MULTISAMPLEBUFFERS, 1);
	14 8 SDL_GL_SetAttribute	|SDL_GL_MULTISAMPLESAMPLES, 8);
    17 4 SDL_GL_SetAttribute |SDL_GL_CONTEXT_MAJOR_VERSION
    18 6 SDL_GL_SetAttribute |SDL_GL_CONTEXT_MINOR_VERSION
	20 2 SDL_GL_SetAttribute |SDL_GL_CONTEXT_FLAGS, SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG);	
	21 2 SDL_GL_SetAttribute |SDL_GL_CONTEXT_PROFILE_MASK,  SDL_GL_CONTEXT_PROFILE_COMPATIBILITY
|	SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);
|	"SDL_RENDER_SCALE_QUALITY" "1" SDL_SetHint	
	
	"test opengl" 800 600 SDLinitGL
	
	glInfo	
	GL_DEPTH_TEST glEnable 
	GL_CULL_FACE glEnable	
	GL_LESS glDepthFunc 
	;	
	
:glend
    SDL_Quit ;

|-------------------------------------
#flpos * 12
#flamb * 12
#fldif * 12
#flspe * 12
	
#fprojection * 64
#fview * 64
#fmodel * 64
	
#pEye 0.0 10.0 10.0
#pTo 0 0 0
#pUp 0 1.0 0

#lightPos [ -2.0 4.0 -1.0 ]

#lightSpaceMatrix * 64

:eyecam
	'pEye 'pTo 'pUp mlookat 'fview mcpyf ;


|--------------	
#o1 * 80
#arrayobj 0 0
#fhit

:hit | mask pos -- pos
	-20.0 <? ( over 'fhit +! )
	20.0 >? ( over 'fhit +! )
	nip ;

:hitz | mask pos -- pos
	0.0 <? ( over 'fhit +! )
	40.0 >? ( over 'fhit +! )
	nip ;
	
:rhit	
	fhit 
	%1 and? ( b> 8 + dup @ neg swap ! )
	%10 and? ( b> 16 + dup @ neg swap ! )
	%100 and? ( b> 24 + dup @ neg swap !  )
	drop ;
	
:objexec | adr -- 
	dup >b
	|------- rot+pos obj
	0 'fhit ! 
	matini 
	b@+ %1 b@+ hit %10 b@+ hit %100 b@+ hit mrpos
	'fmodel mcpyf | model matrix
	
	|------- refresh & hit
	4 3 << + >b rhit
	b@+ b> 5 3 << - dup @ rot +rota swap !
	b@+ b> 5 3 << - +! | +x
	b@+ b> 5 3 << - +! | +y
	b@+ b> 5 3 << - +! | +z
	
	|------- draw
	'fprojection shadercam | only model mat change
	b@+ drawobjm
	;
	
:+obj | obj vz vy vx vrzyx z y x rzyx --
	'objexec 'arrayobj p!+ >a 
	a!+ a!+ a!+ a!+ 
	a!+ a!+ a!+ a!+ 
	a! ;

#cntobj 
:objrand
	cntobj randmax 3 << 'o1 + @ ;
	
:velrot 0.01 randmax 0.005 - ;
:velpos 0.5 randmax 0.25 - ;
	
:+objr	
	velpos velpos velpos |vz |vy |vx
	velrot velrot velrot packrota |vrz |vry |vrx
	2.0 randmax 	| pos z
	0 0 
	0 | 0 0 0 packrota
	+obj ;


|---------------
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

	
:memfloat | cnt place --
	>a ( 1? 1 - da@ f2fp da!+ ) drop ;
	
|-----------
#cubevao
#cubevbo

#vertcube [ | back face
	-1.0 -1.0 -1.0  0.0  0.0 -1.0 0.0 0.0 | bottom-left
	 1.0  1.0 -1.0  0.0  0.0 -1.0 1.0 1.0 | top-right
	 1.0 -1.0 -1.0  0.0  0.0 -1.0 1.0 0.0 | bottom-right         
	 1.0  1.0 -1.0  0.0  0.0 -1.0 1.0 1.0 | top-right
	-1.0 -1.0 -1.0  0.0  0.0 -1.0 0.0 0.0 | bottom-left
	-1.0  1.0 -1.0  0.0  0.0 -1.0 0.0 1.0 | top-left
	| front face
	-1.0 -1.0  1.0  0.0  0.0  1.0 0.0 0.0 | bottom-left
	 1.0 -1.0  1.0  0.0  0.0  1.0 1.0 0.0 | bottom-right
	 1.0  1.0  1.0  0.0  0.0  1.0 1.0 1.0 | top-right
	 1.0  1.0  1.0  0.0  0.0  1.0 1.0 1.0 | top-right
	-1.0  1.0  1.0  0.0  0.0  1.0 0.0 1.0 | top-left
	-1.0 -1.0  1.0  0.0  0.0  1.0 0.0 0.0 | bottom-left
	| left face
	-1.0  1.0  1.0 -1.0  0.0  0.0 1.0 0.0 | top-right
	-1.0  1.0 -1.0 -1.0  0.0  0.0 1.0 1.0 | top-left
	-1.0 -1.0 -1.0 -1.0  0.0  0.0 0.0 1.0 | bottom-left
	-1.0 -1.0 -1.0 -1.0  0.0  0.0 0.0 1.0 | bottom-left
	-1.0 -1.0  1.0 -1.0  0.0  0.0 0.0 0.0 | bottom-right
	-1.0  1.0  1.0 -1.0  0.0  0.0 1.0 0.0 | top-right
	| right face
	 1.0  1.0  1.0  1.0  0.0  0.0 1.0 0.0 | top-left
	 1.0 -1.0 -1.0  1.0  0.0  0.0 0.0 1.0 | bottom-right
	 1.0  1.0 -1.0  1.0  0.0  0.0 1.0 1.0 | top-right         
	 1.0 -1.0 -1.0  1.0  0.0  0.0 0.0 1.0 | bottom-right
	 1.0  1.0  1.0  1.0  0.0  0.0 1.0 0.0 | top-left
	 1.0 -1.0  1.0  1.0  0.0  0.0 0.0 0.0 | bottom-left     
	| bottom face
	-1.0 -1.0 -1.0  0.0 -1.0  0.0 0.0 1.0 | top-right
	 1.0 -1.0 -1.0  0.0 -1.0  0.0 1.0 1.0 | top-left
	 1.0 -1.0  1.0  0.0 -1.0  0.0 1.0 0.0 | bottom-left
	 1.0 -1.0  1.0  0.0 -1.0  0.0 1.0 0.0 | bottom-left
	-1.0 -1.0  1.0  0.0 -1.0  0.0 0.0 0.0 | bottom-right
	-1.0 -1.0 -1.0  0.0 -1.0  0.0 0.0 1.0 | top-right
	| top face
	-1.0  1.0 -1.0  0.0  1.0  0.0 0.0 1.0 | top-left
	 1.0  1.0  1.0  0.0  1.0  0.0 1.0 0.0 | bottom-right
	 1.0  1.0 -1.0  0.0  1.0  0.0 1.0 1.0 | top-right     
	 1.0  1.0  1.0  0.0  1.0  0.0 1.0 0.0 | bottom-right
	-1.0  1.0 -1.0  0.0  1.0  0.0 0.0 1.0 | top-left
	-1.0  1.0  1.0  0.0  1.0  0.0 0.0 0.0  | bottom-left        
	]
	
:initcube
	1 'cubeVAO glGenVertexArrays
	1 'cubeVBO glGenBuffers
	| fill buffer
	36 8 * 'vertcube memfloat
	GL_ARRAY_BUFFER cubeVBO glBindBuffer
	GL_ARRAY_BUFFER 36 8 * 2 << 'vertcube GL_STATIC_DRAW glBufferData
	| link vertex attributes
	cubeVAO glBindVertexArray
	0 glEnableVertexAttribArray
	0 3 GL_FLOAT GL_FALSE 8 2 << 0 glVertexAttribPointer
	1 glEnableVertexAttribArray
	1 3 GL_FLOAT GL_FALSE 8 2 << 3 2 << glVertexAttribPointer
	2 glEnableVertexAttribArray
	2 2 GL_FLOAT GL_FALSE 8 2 << 6 2 << glVertexAttribPointer
	GL_ARRAY_BUFFER 0 glBindBuffer
	0 glBindVertexArray
	;

:rendercube
    cubevao glBindVertexArray
    GL_TRIANGLES 0 36 glDrawArrays 
    0 glBindVertexArray
	;
	
#vertplane [ | positions   | normals    | texcoords 8 *
	 25.0 -0.5  25.0  0.0 1.0 0.0  25.0  0.0
	-25.0 -0.5  25.0  0.0 1.0 0.0   0.0  0.0
	-25.0 -0.5 -25.0  0.0 1.0 0.0   0.0 25.0

	 25.0 -0.5  25.0  0.0 1.0 0.0  25.0  0.0
	-25.0 -0.5 -25.0  0.0 1.0 0.0   0.0 25.0
	 25.0 -0.5 -25.0  0.0 1.0 0.0  25.0 25.0 ]
	
#planeVAO
#planeVBO

:initplane		 
    1 'planeVAO glGenVertexArrays
    1 'planeVBO glGenBuffers
    planeVAO glBindVertexArray
    GL_ARRAY_BUFFER planeVBO glBindBuffer
	6 8 * 'vertplane memfloat
    GL_ARRAY_BUFFER 48 2 << 'vertplane GL_STATIC_DRAW glBufferData
    0 glEnableVertexAttribArray
    0 3 GL_FLOAT GL_FALSE 8 2 << 0 glVertexAttribPointer
    1 glEnableVertexAttribArray
    1 3 GL_FLOAT GL_FALSE 8 2 << 3 2 << glVertexAttribPointer
    2 glEnableVertexAttribArray
    2 2 GL_FLOAT GL_FALSE 8 2 << 6 2 << glVertexAttribPointer
    0 glBindVertexArray
	;

:renderplane
    planeVAO glBindVertexArray
    GL_TRIANGLES 0 6 glDrawArrays 
    0 glBindVertexArray
	;
	
|----------------------------------------------	
#shader	
#simpleDepthShader
#debugDepthQuad

#woodTexture 
#marbleTexture 

:initshaders
	"r3/opengl/shader/shadow_mapping.fs"
	"r3/opengl/shader/shadow_mapping.vs" 
	loadShaders 'shader !
	"r3/opengl/shader/shadow_mapping_depth.fs"
	"r3/opengl/shader/shadow_mapping_depth.vs" 
	loadShaders 'simpleDepthShader !
	"r3/opengl/shader/debug_quad_depth.fs"	
	"r3/opengl/shader/debug_quad.vs"
	loadShaders 'debugDepthQuad !

	"media/img/wood.png" glImgTex 'woodTexture !
	"media/img/marble.jpg" glImgTex 'marbleTexture !
	;
	

|--------------	 configure depth map FBO
#depthMapFBO
#depthMap
|const unsigned int SHADOW_WIDTH = 1024, SHADOW_HEIGHT = 1024;
#borderColor [ 1.0 1.0 1.0 1.0 ]

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

:initDepthMap
    1 'depthMapFBO glGenFramebuffers
    1 'depthMap glGenTextures
    GL_TEXTURE_2D depthMap glBindTexture
    GL_TEXTURE_2D 0 GL_DEPTH_COMPONENT 1024 dup 0 GL_DEPTH_COMPONENT GL_FLOAT 0 glTexImage2D
    GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_NEAREST glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_NEAREST glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_WRAP_S GL_CLAMP_TO_BORDER glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_WRAP_T GL_CLAMP_TO_BORDER glTexParameteri
  
    GL_TEXTURE_2D GL_TEXTURE_BORDER_COLOR 'borderColor glTexParameterfv
    
    GL_FRAMEBUFFER depthMapFBO glBindFramebuffer
    GL_FRAMEBUFFER GL_DEPTH_ATTACHMENT GL_TEXTURE_2D depthMap 0 glFramebufferTexture2D
    0 glDrawBuffer | none
    0 glReadBuffer | none
    GL_FRAMEBUFFER 0 glBindFramebuffer
	
	shader glUseProgram	
	0 shader "diffuseTexture" shader!i
	1 shader "shadowMap" shader!i

	debugDepthQuad glUseProgram	
	0 debugDepthQuad "depthMap" shader!i
	;
	

:initvec
	matini
	0.1 1000.0 0.9 3.0 4.0 /. mperspective 
|	-2.0 2.0 -2.0 2.0 -2.0 2.0 mortho
	'fprojection mcpyf	| perspective matrix
|	'fmodel midf	| view matrix >>
	eyecam		| eyemat


	matini
	'lightPos 'pTo 'pUp mlookat
	mpush
	-10.0 10.0 -10.0 10.0 1.0 7.5 mortho m*
	'lightSpaceMatrix mcpyf
|        lightView = glm::lookAt(lightPos, glm::vec3(0.0f), glm::vec3(0.0, 1.0, 0.0));
|        lightSpaceMatrix = lightProjection * lightView;	
	3 'lightPos memfloat	
	
	'flpos >a
	1.2 f2fp da!+ 20.0 f2fp da!+ 2.0 f2fp da!+ | light position
	
	1.0 f2fp da!+ 1.0  f2fp da!+ 1.0 f2fp da!+ | ambi
	0.9 f2fp da!+ 0.9 f2fp da!+ 0.9 f2fp da!+ | diffuse
	1.0 f2fp da!+ 1.0 f2fp da!+ 1.0 f2fp da!+ | spec
	;

#mmodel	* 64

:renderScene | shader --
	GL_TEXTURE0 glActiveTexture
	GL_TEXTURE_2D woodTexture glBindTexture

	matini 
	$7fff 0.0 -2.0 0.0 mrpos
	'mmodel mcpyf 
	'mmodel over "model" shader!m4
	renderplane

	GL_TEXTURE0 glActiveTexture
	GL_TEXTURE_2D marbleTexture  glBindTexture

	matini 
	$0 0.0 1.5 0.0 mrpos
	0.8 dup dup mscale	
	'mmodel mcpyf 
	'mmodel over "model" shader!m4
	rendercube

	matini 
	$0 2.0 0.0 1.0 mrpos
	0.8 dup dup mscale
	'mmodel mcpyf 
	'mmodel over "model" shader!m4
	rendercube
	
	matini 
	$3fff -1.0 0.0 2.0 mrpos
	1.2 dup dup mscale
	'mmodel mcpyf 
	'mmodel over "model" shader!m4
	rendercube
	drop
	;

:setrender
	shader glUseProgram
	
	'fprojection shader "projection" shader!m4
	'fview shader "view" shader!m4

	'fview 12 2 << + shader "viewPos" shader!v3  |'camera.Position = 'fview +12
	'lightPos shader "lightPos" shader!v3
	'lightSpaceMatrix shader "lightSpaceMatrix" shader!m4
	
	GL_TEXTURE0 1 + glActiveTexture
	GL_TEXTURE_2D depthMap glBindTexture
	;
	
#GL_DEPTH_BUFFER_BIT $100	

:rendershadow
	simpleDepthShader glUseProgram
	'lightSpaceMatrix simpleDepthShader "lightSpaceMatrix" shader!m4
	
	0 0 1024 dup glViewport
	GL_FRAMEBUFFER depthMapFBO glBindFramebuffer
	GL_DEPTH_BUFFER_BIT glClear
	GL_TEXTURE0 glActiveTexture
	GL_TEXTURE_2D woodTexture glBindTexture
	simpleDepthShader renderScene
	GL_FRAMEBUFFER 0 glBindFramebuffer
	0 0 800 600 glViewport
	;
		
|-------- debug
#near_plane 1.0
#far_plane 7.5
:renderdebug
	| debugDepthQuad glUseProgram
	| 'near_plane debugDepthQuad "near_plane" shader!f1
	| 'far_plane debugDepthQuad "far_plane" shader!f1
	| GL_TEXTURE0 glActiveTexture
	| GL_TEXTURE_2D depthMap glBindTexture
	| renderQuad
	;
|------ vista
#xm #ym
#rx #ry

:dnlook
	SDLx SDLy 'ym ! 'xm ! ;

:movelook
	SDLx SDLy
	ym over 'ym ! - neg 7 << 'rx +!
	xm over 'xm ! - 7 << neg 'ry +!  ;

|--------------	
:main
	gui
	'dnlook 'movelook onDnMove

	rendershadow

	$4100 glClear | color+depth
	
	startshader
	'flpos shaderlight
	'arrayobj p.draw
	
	setrender
	shader renderScene	
	
	renderdebug
	
	SDL_windows SDL_GL_SwapWindow
	SDLkey
	>esc< =? ( exit ) 	
	<f1> =? ( objrand +objr ) 
	<f3> =? ( 'arrayobj dup @ swap p.del )
	
	<up> =? ( 0.5 'pEye +! eyecam )
	<dn> =? ( -0.5 'pEye +! eyecam )
	<le> =? ( 0.5 'pEye 8 + +! eyecam )
	<ri> =? ( -0.5 'pEye 8 + +! eyecam )
	<a> =? ( 0.5 'pEye 16 + +! eyecam )
	<d> =? ( -0.5 'pEye 16 + +! eyecam )

	<esp> =? ( objrand 0 0 0 0 0 0.0 0.0 0 +obj )
	drop ;	


#objs 	
|"media/obj/mario/mario.objm"
|"media/obj/rock.objm"
"media/obj/food/Lollipop.objm"
 ( 0 )


	
|---------------------------		
:ini	
	loadshader			| load shader
	initshaders
	
	0 'cntobj !
	'o1 >a			| load objs
	'objs ( dup c@ 1? drop
		dup loadobjm a!+
		1 'cntobj +!
		>>0 ) drop
	initvec
	
	1000 'arrayobj p.ini 
	
	initCube
	initPlane
	initDepthMap
	
|	.cls	
	cr cr glinfo
	"<esc> - Exit" .println
	"<f1> - 1 obj moving" .println
	"<esp> - 1 obj fix" .println	

	;
	
|----------- BOOT
:
	glinit
 	ini
	'main SDLshow
	glend 
	;	