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

^r3/opengl/shaderobj.r3

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
#GL_TEXTURE1 $84C1
	
#GL_DEPTH_BUFFER_BIT $100	

|-------------------------------------
#fprojection * 64
#fview * 64
	
#pEye 1.0 7.0 7.0
#fpEye [ 0 0 0 ]
#pTo 0 0 0
#pUp 0 1.0 0

#lightPos -4.0 4.0 -1.0 
#flightPos [ 0 0 0  ]

#lightSpaceMatrix * 64

#borderColor [ 1.0 1.0 1.0 1.0 ]

#near_plane [ 1.0 ]
#far_plane [ 7.5 ]


:memfloat | cnt place --
	>a ( 1? 1 - da@ f2fp da!+ ) drop ;

:mem2float | cnt to from --
	>a >b ( 1? 1 - a@+ f2fp db!+ ) drop ;
	
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
	 25.0 -0.5 -25.0  0.0 1.0 0.0  25.0 25.0 	 
	-25.0 -0.5 -25.0  0.0 1.0 0.0   0.0 25.0	 
	-25.0 -0.5  25.0  0.0 1.0 0.0   0.0  0.0
	 ]
	
#planeVAO
#planeVBO

:initplane		 
    1 'planeVAO glGenVertexArrays
    1 'planeVBO glGenBuffers
    planeVAO glBindVertexArray
    GL_ARRAY_BUFFER planeVBO glBindBuffer
	4 8 * 'vertplane memfloat
    GL_ARRAY_BUFFER 48 2 << 'vertplane GL_STATIC_DRAW glBufferData
    0 glEnableVertexAttribArray
    0 3 GL_FLOAT GL_FALSE 8 2 << 0 glVertexAttribPointer
    1 glEnableVertexAttribArray
    1 3 GL_FLOAT GL_FALSE 8 2 << 3 2 << glVertexAttribPointer
    2 glEnableVertexAttribArray
    2 2 GL_FLOAT GL_FALSE 8 2 << 6 2 << glVertexAttribPointer
    0 glBindVertexArray
	;

#GL_TRIANGLE_FAN $0006

:renderplane
    planeVAO glBindVertexArray
	GL_TRIANGLE_FAN 0 4 glDrawArrays 
    0 glBindVertexArray
	;
	
|----------------------------------------------	
#quadVAO
#quadVBO

#quadVertices [
	-0.98 0.98 0.0 0.0 1.0
	-0.98 0.2 0.0 0.0 0.0
	-0.2 0.98 0.0 1.0 1.0
	-0.2 0.2 0.0 1.0 0.0
	]

:initquad
	20 'quadVertices memfloat
	1 'quadVAO glGenVertexArrays
	1 'quadVBO glGenBuffers
	quadVAO glBindVertexArray
	GL_ARRAY_BUFFER quadVBO glBindBuffer
	GL_ARRAY_BUFFER 20 2 << 'quadVertices GL_STATIC_DRAW glBufferData
	0 glEnableVertexAttribArray
	0 3 GL_FLOAT GL_FALSE 5 2 << 0 glVertexAttribPointer
	1 glEnableVertexAttribArray
	1 2 GL_FLOAT GL_FALSE 5 2 << 3 2 << glVertexAttribPointer
	;
	
:renderquad
	quadVAO glBindVertexArray
	GL_TRIANGLE_STRIP 0 4 glDrawArrays
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

	shader glUseProgram	
	0 shader "diffuseTexture" shader!i
	1 shader "shadowMap" shader!i

	debugDepthQuad glUseProgram	
	0 debugDepthQuad "depthMap" shader!i
	'near_plane debugDepthQuad "near_plane" shader!f1
	'far_plane debugDepthQuad "far_plane" shader!f1
	
	"media/img/wood.png" glImgTex 'woodTexture !
	"media/img/marble.jpg" glImgTex 'marbleTexture !
	;
	

|--------------	 configure depth map FBO
#depthMapFBO
#depthMap
|const unsigned int SHADOW_WIDTH = 1024, SHADOW_HEIGHT = 1024;


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
	;
	

:eyecam
	'pEye 'pTo 'pUp mlookat 
	'fview mcpyf 
	3 'fpEye 'pEye mem2float | cnt to from --
	;

:initvec
	4 'borderColor memfloat
	2 'near_plane memfloat	
	
	matini
	0.1 1000.0 0.9 3.0 4.0 /. mperspective 
|	-2.0 2.0 -2.0 2.0 -2.0 2.0 mortho
	'fprojection mcpyf	| perspective matrix
	eyecam		| eyemat


	matini
	'lightPos 'pTo 'pUp mlookat
	mpush 
	10.0 -10.0 10.0 -10.0 17.5 -8.0 mortho 
	m*
	'lightSpaceMatrix mcpyf
	3 'flightPos 'lightPos mem2float | cnt to from --
	;

#mmodel	* 64

:model>shader | shader --
	'mmodel mcpyf 
	'mmodel over "model" shader!m4
	;

:renderScene | shader --
	GL_TEXTURE0 glActiveTexture
	GL_TEXTURE_2D marbleTexture glBindTexture

|	matini 
	0 0.0 -1.0 0.0 mrpos
	model>shader
	renderplane

	GL_TEXTURE0 glActiveTexture
	GL_TEXTURE_2D woodTexture 	glBindTexture

|	matini 
	msec $ffff and dup 16 << or
	0.0 1.5 0.0 mrpos
	model>shader
	rendercube

|	matini 
	$0 2.0 msec 7 << $1ffff and 1.0 mrpos
	0.8 dup dup mscale
	model>shader
	rendercube
	
|	matini 
	$3fff -1.0 0.0 2.0 mrpos
	msec 4 << $ffff and 0.5 + dup dup mscale
	model>shader
	rendercube
	
	drop
	;

:render
|	GL_BACK glCullFace
	shader glUseProgram
	
	'fprojection shader "projection" shader!m4

	'fview shader "view" shader!m4
	'fpEye shader "viewPos" shader!v3  

	'flightPos shader "lightPos" shader!v3
	'lightSpaceMatrix shader "lightSpaceMatrix" shader!m4

	GL_TEXTURE1 glActiveTexture
	GL_TEXTURE_2D depthMap glBindTexture
	
	shader renderScene
	;


:rendershadow
	|GL_FRONT glCullFace
	simpleDepthShader glUseProgram
	'lightSpaceMatrix simpleDepthShader "lightSpaceMatrix" shader!m4
	
	0 0 1024 dup glViewport
	GL_FRAMEBUFFER depthMapFBO glBindFramebuffer
	
	GL_DEPTH_BUFFER_BIT glClear

	simpleDepthShader renderScene
	GL_FRAMEBUFFER 0 glBindFramebuffer
	0 0 800 600 glViewport
	;
		
|-------- debug
:renderdebug
	debugDepthQuad glUseProgram
	GL_TEXTURE0 glActiveTexture
	GL_TEXTURE_2D depthMap glBindTexture
	renderQuad
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
	render
|	renderdebug
	
	SDL_windows SDL_GL_SwapWindow
	SDLkey
	>esc< =? ( exit ) 	
	
	<up> =? ( 0.5 'pEye +! eyecam )
	<dn> =? ( -0.5 'pEye +! eyecam )
	<le> =? ( 0.5 'pEye 8 + +! eyecam )
	<ri> =? ( -0.5 'pEye 8 + +! eyecam )
	<a> =? ( 0.5 'pEye 16 + +! eyecam )
	<d> =? ( -0.5 'pEye 16 + +! eyecam )

	drop ;	
	
|----------- BOOT
:
	"test opengl" 800 600 SDLinitGL

	
	GL_DEPTH_TEST glEnable 
	GL_CULL_FACE glEnable
	GL_LESS glDepthFunc 

	initvec

	initshaders
	
	initCube
	initPlane
|	initQuad
	initDepthMap

	cr 
	glInfo		
	cr 
	"<esc> - Exit" .println
	"<f1> - 1 obj moving" .println
	"<esp> - 1 obj fix" .println	
	cr

	'main SDLshow
	SDL_Quit 
	;	