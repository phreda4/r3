| OpenGL example
| PHREDA 2023
|MEM 64
^r3/lib/3d.r3
^r3/lib/rand.r3
^r3/lib/gui.r3
^r3/util/arr16.r3

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
|	programID glDeleteProgram
|	1 'VertexArrayID glDeleteVertexArrays
|	1 'uvbuffer glDeleteBuffers
|	1 'vertexbuffer glDeleteBuffers
|	1 'normalbuffer glDeleteBuffers
|	1 'TextureID glDeleteTextures
    SDL_Quit ;

|-------------------------------------
#flpos * 12
#flamb * 12
#fldif * 12
#flspe * 12
	
#fprojection * 64
#fview * 64
#fmodel * 64
	
#pEye 1.0 1.0 1.0
#pTo 0 0 0
#pUp 0 1.0 0

:eyecam
	 'pEye 'pTo 'pUp mlookat  | eye to up -- 
	'fview mcpyf ;

:initvec
	matini
	0.1 1000.0 0.9 3.0 4.0 /. mperspective 
|	-2.0 2.0 -2.0 2.0 -2.0 2.0 mortho
	'fprojection mcpyf	| perspective matrix
	'fmodel midf	| view matrix >>
	eyecam		| eyemat
	
	'flpos >a	
	da@ f2fp da!+ da@ f2fp da!+ da@ f2fp da!+ | light position
	da@ f2fp da!+ da@ f2fp da!+ da@ f2fp da!+ | ambi
	da@ f2fp da!+ da@ f2fp da!+ da@ f2fp da!+ | diffuse
	da@ f2fp da!+ da@ f2fp da!+ da@ f2fp da!+ | spec
	;


|--------------	
#o1 * 80
#arrayobj 0 0
#fhit

:hit | mask pos -- pos
	-2.0 <? ( over 'fhit +! )
	2.0 >? ( over 'fhit +! )
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
	'fmodel mcpyf | model matrix	>>
	
|	'mateye mm* 	|------- mov eye
|	'matcam mm* 	| cam matrix
|	'fmvp mcpyf		| mvp matrix >>
	
	|------- refresh & hit
	4 3 << + >b rhit
	b@+ b> 5 3 << - dup @ rot +rota swap !
	b@+ b> 5 3 << - +! | +x
	b@+ b> 5 3 << - +! | +y
	b@+ b> 5 3 << - +! | +z
	
	|------- draw
	'fprojection shadercam
	'flpos shaderlight
	startshader
	b@+ drawobjm
	;
	
:+obj | obj vz vy vx vrzyx z y x rzyx --
	'objexec 'arrayobj p!+ >a 
	a!+ a!+ a!+ a!+ 
	a!+ a!+ a!+ a!+ 
	a! ;

#cntobj 
:objrand
	cntobj  randmax 3 << 'o1 + @ ;
	
:velrot 0.01 randmax 0.005 - ;
:velpos 0.05 randmax 0.025 - ;
	
:+objr	
	velpos velpos velpos |vz |vy |vx
	velrot velrot velrot packrota |vrz |vry |vrx
	0 0 0 
	0 | 0 0 0 packrota
	+obj ;

:+objr2
	0 0 0 
	velrot velrot velrot packrota
	2.0 randmax 1.0 -	| pos z
	2.0 randmax 1.0 - | pos y
	2.0 randmax 1.0 - | pos x	
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

	SDL_windows SDL_GL_SwapWindow
	SDLkey
	>esc< =? ( exit ) 	
	<f1> =? ( 50 ( 1? 1 - objrand +objr ) drop ) 
	<f2> =? ( 50 ( 1? 1 - objrand +objr2 ) drop ) 
	<f3> =? ( 'arrayobj dup @ swap p.del )
	
	<up> =? ( 1.0 'pEye +! eyecam )
	<dn> =? ( -1.0 'pEye +! eyecam )
	<le> =? ( 1.0 'pEye 8 + +! eyecam )
	<ri> =? ( -1.0 'pEye 8 + +! eyecam )
	<a> =? ( 1.0 'pEye 16 + +! eyecam )
	<d> =? ( -1.0 'pEye 16 + +! eyecam )

	<esp> =? ( objrand 0 0 0 $001000f0000e -0.5 0.0 0.0 0 +obj )
	drop ;	


#objs 	
"media/obj/food/Lollipop.objm" ( 0 )

|---------------------------		
:ini	
"a" .println
	loadshader			| load shader

"b" .println	
	0 'cntobj !
	'o1 >a			| load objs
	'objs ( dup c@ 1? drop
		dup loadobjm a!+
		1 'cntobj +!
		>>0 ) drop
"c" .println	
	initvec
"d" .println
	1000 'arrayobj p.ini 
|	.cls	
	cr cr cr cr glinfo
	"<esc> - Exit" .println
	"<f1> - 50 obj moving" .println
	"<f2> - 50 obj static" .println
	"<esp> - 1 obj moving" .println	
	;
	
|----------- BOOT
:
	glinit
 	ini
	'main SDLshow
	glend 
	;	