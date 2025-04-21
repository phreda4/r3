| OpenGL example
| PHREDA 2023
|MEM 64
^r3/lib/3dgl.r3
^r3/lib/rand.r3
^r3/lib/gui.r3
^r3/util/arr16.r3
|^r3/lib/trace.r3

^r3/lib/sdl2.r3
^r3/lib/sdl2gl.r3
^r3/lib/sdl2gfx.r3

^r3/opengl/shaderobjins.r3

| opengl Constant
#GL_DEPTH_TEST $0B71
#GL_LESS $0201
#GL_CULL_FACE $0B44

#shaderd
:initshaders
	|"r3/opengl/shader/anim_model.sha" loadShader 'shaderd !
	|0 shaderd "texture_diffuse1" shader!i
	;
	
|-------------------------------------
:glinit
	"test opengl" 800 600 SDLinitGL
	
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
#flpos * 48
|#flamb * 12
|#fldif * 12
|#flspe * 12
	
#fprojection * 64
#fview * 64
#fmodel * 64
	
#eyed 12.0
	
#pEye 0.0 0.0 12.0
#pTo 0 0 0
#pUp 0 1.0 0

#xm #ym
#rx #ry

:eyecam
	rx 'pEye 8 + !
	ry sincos eyed *. swap eyed *. 'pEye !+ 8 + !
	'pEye 'pTo 'pUp mlookat 'fview mcpyf ;

|------ vista
:dnlook
	SDLx SDLy 'ym ! 'xm ! ;

:movelook
	SDLx SDLy
	ym over 'ym ! - neg 10 << 'rx +!
	xm over 'xm ! - 7 << neg 'ry +!  
	eyecam
	;
	

:initvec
	matini
	0.1 1000.0 0.9 3.0 4.0 /. mperspective	| perspective matrix
|	-20.0 20.0 -20.0 20.0 -20.0 20.0 mortho
	'fprojection mcpyf eyecam				| eyemat
	
	'flpos >a
	1.2 f2fp da!+ 6.0 f2fp da!+ 2.0 f2fp da!+ | light position
	
	0.9 f2fp da!+ 0.9  f2fp da!+ 0.9 f2fp da!+ | ambi
	0.9 f2fp da!+ 0.9 f2fp da!+ 0.9 f2fp da!+ | diffuse
	1.0 f2fp da!+ 1.0 f2fp da!+ 1.0 f2fp da!+ | spec
	;

|----------------------------------
#arrayobj 0 0
#matmem>

:fillmat | adr -- 
	8 + >b
	|------- rot+pos obj
	matini 
	b@+ b@+ b@+ b@+ mrpos
	matmem> mcpyf | model matrix
	64 'matmem> +!
	;	

:xyz2tran | n - x y z
	dup $f and 15 << 3.25 -
	over 4 >> $f and 15 << 3.25 -
	rot 8 >> $f and 15 << 3.25 -
	;
	
:+objv | v --
	dup xyz2tran 0
	'fillmat 'arrayobj p!+ >a 
	a!+ a!+ a!+ a!+
	;
	
|--------------	
#obj-rock
#obj-lool
#xm #ym
#rx #ry

:renderobj
	|--- fill matrixs
      
	obj-rock matmemset 'matmem> !	| where ?
	'arrayobj p.draw	| fill
	
	matmemun
	
	|------- draw
	startshaderi
|	shaderd glUseProgram

|	'fprojection shaderd "projection" shader!m4
|	'fview shaderd "view" shader!m4
|	'fmodel shaderd "model" shader!m4	

	'fprojection shadercami
	'flpos shaderlight
	obj-rock drawobjmi	| draw
	;



|--------------	
:main
	gui
	'dnlook 'movelook onDnMove

	$4100 glClear | color+depth
	renderobj
	SDL_windows SDL_GL_SwapWindow
	SDLkey
	>esc< =? ( exit ) 	
	
	<up> =? ( -0.1 'eyed +! eyecam )
	<dn> =? ( 0.1 'eyed +! eyecam )

	drop ;	

|---------------------------		
:ini	
	loadshaderi			| load shader
	
	"media/obj/cubo1.objm" 
	$1000 loadobjmi 'obj-rock !
	
	initvec
	$1000 'arrayobj p.ini 
	0 ( $1000 <?
		+objv
		1+ ) drop
	;
	
|----------- BOOT
:
	glinit
 	ini
	'main SDLshow
	glend 
	;	