| 3d view - opengl
| PHREDA 2024
|-----
^r3/lib/rand.r3
^r3/lib/3dgl.r3

^r3/lib/sdl2.r3
^r3/lib/sdl2gl.r3

^r3/opengl/glfgui.r3
^r3/opengl/shaderobj.r3

#pdir 0
#prot
#px 0 #py 0 #pz 0
#pvel 0 0 0 

#vr
#vd
#vpz

|-------------------------------		
#flpos * 12
#flamb * 12
#fldif * 12
#flspe * 12
	
#fprojection * 64
#fview * 64
#fmodel * 64
	
#pEye 0.0 4.0 2.0
#pTo 0 0 0
#pUp 0 0 1.0

:initvec
	matini
	0.1 1000.0 0.9 3.0 4.0 /. mperspective 
|	-20.0 20.0 -20.0 20.0 -20.0 20.0 mortho
	'fprojection mcpyf	| perspective matrix
	'pEye 'pTo 'pUp mlookat 'fview mcpyf	| eyemat
	
	'flpos >a
	1.2 f2fp da!+ 20.0 f2fp da!+ 2.0 f2fp da!+ | light position
	'flamb >a
	1.0 f2fp da!+ 1.0  f2fp da!+ 1.0 f2fp da!+ | ambi
	'fldif >a
	0.9 f2fp da!+ 0.9 f2fp da!+ 0.9 f2fp da!+ | diffuse
	'flspe >a
	1.0 f2fp da!+ 1.0 f2fp da!+ 1.0 f2fp da!+ | spec
	;

|---------------------------------
|disparo
| x y z rxyz sxyz vxyz vrxyz
| 1 2 3 4    5    6    7     
:.rxyz 	1 ncell+ ;
:.x		2 ncell+ ;
:.y		3 ncell+ ;
:.z		4 ncell+ ;

:.sxyz	5 ncell+ ;
:.vxyz	6 ncell+ ;
:.vrxyz	7 ncell+ ;
:.anim	8 ncell+ ;
:.va	9 ncell+ ;

#o1 * 80
#cntobj 
	
|------ vista
#xm #ym
#rx #ry #rz

:dnlook
	SDLx SDLy 'ym ! 'xm ! ;

:movelook
	SDLx SDLy
	ym over 'ym ! - neg 7 << 'rx +!
	xm over 'xm ! - 7 << neg 'ry +!  ;	
	
|-------------------------------	
:control
	glgui
	
	'dnlook 'movelook onDnMove
	
	$ffffff glcolor
	0 0 glat
|	'filename "Model: %s" sprint gltext glcr
|	iqm.nroframes framenow "%d %d" sprint gltext
	
	sw 70 - 10 60 20 glwin
	'exit "Exit" gltbtn gldn
	10 32 180 20 glwin
	-1.0 1.0 'rx glSliderf gldn	
	-1.0 1.0 'ry glSliderf gldn	
	-1.0 1.0 'rz glSliderf gldn	
	-10.0 10.0 'px glSliderf gldn	
	-10.0 10.0 'py glSliderf gldn	
	-500.0 500.0 'pz glSliderf gldn	
|	'anima "Model|Bones|Animation" glCombo
	;

|---------------------------		
| opengl Constant
#GL_DEPTH_TEST $0B71
#GL_LESS $0201
#GL_CULL_FACE $0B44
	
:juego
	$4100 glClear | color+depth

	GL_DEPTH_TEST glEnable 
	GL_CULL_FACE glEnable	
	GL_LESS glDepthFunc 
	
	matini 
	rx $ffff and 32 << 
	ry $ffff and 16 << or 
	rz $ffff and or 
	px py pz mrpos
	'fmodel mcpyf | model matrix
	startshader
	'fprojection shadercam
	'flpos shaderlight
	o1 drawobjm 

	control
		
	SDL_windows SDL_GL_SwapWindow
	SDLkey
	>esc< =? ( exit ) 	
	drop ;		
	
|-------------------------------------
#objs 	
|"media/obj/cube.objm"
|"media/obj/rock.objm"
|"media/obj/rock2.objm"
|"media/obj/tree.objm"
|"media/obj/tree2.objm" 
|"media/obj/tree3.objm"
"media/obj/raceCarRed.objm" 
|"media/obj/basicCharacter.objm" 

|"media/obj/tinker.objm" |*
|"media/obj/food/Lollipop.objm"
|"media/obj/mario/mario.objm"
|"media/obj/rock.objm"
 ( 0 )

|-------------------------------------
:
	"3d world" 1024 600 SDLinitGL
	.cls
	glInfo	
	glimmgui
	loadshader			| load shader
	0 'cntobj !
	'o1 >a			| load objs
	'objs ( dup c@ 1? drop
		dup loadobjm a!+
		1 'cntobj +!
		>>0 ) drop
	initvec
	'juego SDLShow 
	SDL_Quit 
	;	
	
