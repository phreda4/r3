| OpenGL example
| PHREDA 2023
|MEM 64
^r3/lib/3d.r3
^r3/lib/rand.r3
^r3/lib/gui.r3
^r3/util/arr16.r3
|^r3/lib/trace.r3

^r3/win/sdl2.r3
^r3/win/sdl2gl.r3
^r3/win/sdl2ttf.r3

^r3/opengl/shaderobj.r3

| opengl Constant
#GL_DEPTH_TEST $0B71
#GL_LESS $0201
#GL_CULL_FACE $0B44
#GL_RED $1903
#GL_RGB $1907
#GL_RGBA $1908
#GL_TEXTURE0 $84C0
#GL_TEXTURE_2D $0DE1
#GL_TRIANGLE_FAN $0006
#GL_UNSIGNED_BYTE $1401
#GL_TEXTURE_MAG_FILTER $2800
#GL_TEXTURE_MIN_FILTER $2801
#GL_LINEAR $2601
#GL_NEAREST $2600
#GL_ARRAY_BUFFER $8892
#GL_STATIC_DRAW $88E4
#GL_FLOAT $1406
#GL_FALSE 0
#GL_BLEND $0BE2
#GL_SRC_ALPHA $0302
#GL_ONE_MINUS_SRC_ALPHA $0303

#fontshader
	
:initshaders
	"r3/opengl/shader/font1.fs"
	"r3/opengl/shader/font1.vs" 
	loadShaders 'fontshader !
	;	
	
#font
#ink

#surface
:Surface->w surface 16 + d@ ;
:Surface->h surface 20 + d@ ;
:Surface->p surface 24 + d@ ;
:Surface->pixels surface 32 + @ ;

:GLBPP 
	surface 8 + @ 16 + c@
	32 =? ( drop GL_RGBA ; ) 
	24 =? ( drop GL_RGB ; )
	drop GL_RED ;	

:fp, f2fp , ;

#tt #vt #bt
#ws #hs

:glrendertext | "" x y --
	rot
	fontshader glUseProgram
	
	1 'tt glGenTextures
    GL_TEXTURE_2D tt glBindTexture
	font swap ink TTF_RenderUTF8_Blended 'Surface !
	GL_TEXTURE_2D 0 GLBPP Surface->p 2 >> Surface->h 0 pick3 GL_UNSIGNED_BYTE Surface->pixels glTexImage2D
	GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_NEAREST glTexParameteri
	GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_NEAREST glTexParameteri
	Surface->w 0.003 * 'ws !
	Surface->h 0.003 * 'hs !
	surface SDL_FreeSurface
	
	GL_TEXTURE0 glActiveTexture
	GL_TEXTURE_2D tt glBindTexture
	
	1 'vt glGenVertexArrays
	1 'bt glGenBuffers
	vt glBindVertexArray
	GL_ARRAY_BUFFER bt glBindBuffer
	
	mark
	over fp, dup fp, 			0.0 fp, 1.0 fp,
	over ws + fp, dup fp, 		1.0 fp, 1.0 fp,
	over ws + fp, dup hs + fp, 	1.0 fp, 0.0 fp,
	over fp, dup hs + fp, 		0.0 fp, 0.0 fp,
	empty | size
	2drop
	
	GL_ARRAY_BUFFER 16 2 << here GL_STATIC_DRAW glBufferData
	0 glEnableVertexAttribArray 0 3 GL_FLOAT GL_FALSE 4 2 << 0 glVertexAttribPointer
	1 glEnableVertexAttribArray 1 2 GL_FLOAT GL_FALSE 4 2 << 2 2 << glVertexAttribPointer
	
	GL_BLEND glEnable
	GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA glBlendFunc
	GL_TRIANGLE_FAN 0 4 glDrawArrays | 16 bytes per vertex
	
	0 glBindVertexArray
	1 'vt glDeleteVertexArrays
	1 'bt glDeleteBuffers	
	1 'tt glDeleteTextures
	
	;
|-------------------------------------
#flpos * 12
#flamb * 12
#fldif * 12
#flspe * 12
	
#fprojection * 64
#fview * 64
#fmodel * 64
	
#pEye 0.0 40.0 40.0
#pTo 0 20.0 0.0
#pUp 0 1.0 0

:eyecam
	'pEye 'pTo 'pUp mlookat 'fview mcpyf ;

:initvec
	matini
	0.1 1000.0 0.9 3.0 4.0 /. mperspective 
|	-2.0 2.0 -2.0 2.0 -2.0 2.0 mortho
	'fprojection mcpyf	| perspective matrix
|	'fmodel midf	| view matrix >>
	eyecam		| eyemat
	
	'flpos >a
	1.2 f2fp da!+ 20.0 f2fp da!+ 2.0 f2fp da!+ | light position
	
	1.0 f2fp da!+ 1.0  f2fp da!+ 1.0 f2fp da!+ | ambi
	0.9 f2fp da!+ 0.9 f2fp da!+ 0.9 f2fp da!+ | diffuse
	1.0 f2fp da!+ 1.0 f2fp da!+ 1.0 f2fp da!+ | spec
	;


|--------------	
#o1 * 80
#arrayobj 0 0
#fhit

:hit | mask pos -- pos
	-80.0 <? ( over 'fhit +! )
	90.0 >? ( over 'fhit +! )
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
	startshader
	'fprojection shadercam
	'flpos shaderlight
	b@+ drawobjm
	;
	
:+obj | obj vz vy vx vrzyx z y x rzyx --
	'objexec 'arrayobj p!+ >a 
	a!+ a!+ a!+ a!+ 
	a!+ a!+ a!+ a!+ 
	a! ;

:velrot 0.01 randmax 0.005 - ;
:velpos 0.5 randmax 0.25 - ;
	
:+objr	
	velpos velpos velpos |vz |vy |vx
	velrot velrot velrot packrota |vrz |vry |vrx
	0 0 0 
	0 | 0 0 0 packrota
	+obj ;

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

	$4100 glClear | color+depth
	'arrayobj p.draw

	'pEye @+ swap @+ swap @
	"CAM z:%f y:%f x:%f" sprint
	-0.8 0.8 glrendertext
	
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

|---------------------------		
:ini	
	loadshader			| load shader

	"media/obj/mario/mario.objm" loadobjm 'o1 !
	
	initvec
	1000 'arrayobj p.ini 
|	.cls	
	cr cr glinfo
	"<esc> - Exit" .println
	"<esp> - 1 obj moving" .println	
	
|	 o1 0 0 0 $001000f0000e -0.5 0.0 0.0 0 +obj 
	;
	
|----------- BOOT
:
	5 1 SDL_GL_SetAttribute		|SDL_GL_DOUBLEBUFFER, 1);
	13 1 SDL_GL_SetAttribute	|SDL_GL_MULTISAMPLEBUFFERS, 1);
	14 8 SDL_GL_SetAttribute	|SDL_GL_MULTISAMPLESAMPLES, 8);
    17 4 SDL_GL_SetAttribute |SDL_GL_CONTEXT_MAJOR_VERSION
    18 6 SDL_GL_SetAttribute |SDL_GL_CONTEXT_MINOR_VERSION
	20 2 SDL_GL_SetAttribute |SDL_GL_CONTEXT_FLAGS, SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG);	
	21 2 SDL_GL_SetAttribute |SDL_GL_CONTEXT_PROFILE_MASK,  SDL_GL_CONTEXT_PROFILE_COMPATIBILITY

	"test opengl" 800 600 SDLinitGL
	
	ttf_init
	"media/ttf/roboto-bold.ttf" 24 TTF_OpenFont 'font !
	initshaders
	$ffffffff 'ink !
	
	GL_DEPTH_TEST glEnable 
	GL_CULL_FACE glEnable	
	GL_LESS glDepthFunc 

* 	ini
	o1 0 0 0 0 0 0.0 0.0 0 +obj
	'main SDLshow
	SDL_Quit
	;	