| 3dworld - opengl
| PHREDA 2024
|-----
^r3/lib/rand.r3
^r3/lib/3dgl.r3
^r3/lib/gui.r3

^r3/util/arr16.r3

^r3/win/sdl2.r3
^r3/win/sdl2gl.r3

^r3/games/lunar/shaderobj.r3
^r3/games/lunar/heightmap.r3

#listobj 0 0
#listfx 0 0

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
	
#pEye 0.0 8.0 4.0
#pTo 0 0 0
#pUp 0 0 1.0

:initvec
	matini
	0.1 1000.0 0.9 3.0 4.0 /. mperspective 
|	-2.0 2.0 -2.0 2.0 -2.0 2.0 mortho
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
#fhit
#cntobj 

:hit | mask pos -- pos
	-50.0 <? ( over 'fhit +! )
	50.0 >? ( over 'fhit +! )
	nip ;

:hitz | mask pos -- pos
	0.0 <? ( over 'fhit +! )
	90.0 >? ( over 'fhit +! )
	nip ;
	
:rhit	
	fhit 
	%1 and? ( b> 8 + dup @ neg swap ! )
	%10 and? ( b> 16 + dup @ neg swap ! )
	%100 and? ( b> 24 + dup @ neg swap !  )
	drop ;
	
:objexec | adr -- 
	dup 8 + >b
	|------- rot+pos obj
	0 'fhit ! 
	matini 
	b@+ %1 b@+ hit %10 b@+ hit %100 b@+ hitz mrpos
	'fmodel mcpyf | model matrix
	
	|------- refresh & hit
	5 3 << + >b rhit
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
	'objexec 'listobj p!+ >a 
	a!+ a!+ a!+ a!+ 
	a!+ a!+ a!+ a!+ 
	a! ;
	
:objrand
	cntobj randmax 3 << 'o1 + @ ;
	
:velrot 0.01 randmax 0.005 - ;
:velpos 0.5 randmax 0.25 - ;
	
:+objr	
	velpos velpos velpos |vz |vy |vx
	velrot velrot velrot packrota |vrz |vry |vrx
	0 0 0 
	0 | 0 0 0 packrota
	+obj ;

:+objr2
	0 0 0 
	0

	0	| pos z
	20 randmax 10 - 2.0 * | pos y
	20 randmax 10 - 2.0 * | pos x	
	$ffff randmax $ffff randmax $ffff randmax
	packrota
	+obj ;

|----- player


#zz
:playerkey
	sdlkey
	<up> =? ( 0.1 'vd ! ) >up< =? ( 0 'vd ! )
	<dn> =? ( -0.1 'vd ! ) >dn< =? ( 0 'vd ! )
	<le> =? ( 0.005 'vr ! ) >le< =? ( 0 'vr ! )
	<ri> =? ( -0.005 'vr ! ) >ri< =? ( 0 'vr ! )
	<esp> =? ( vpz 0? ( 0.4 'vpz ! ) drop )
	<w> =? ( 0.1 'zz +! )
	<s> =? ( -0.1 'zz +! )
	drop 
	;
	
|-- camera	

:see3r
	prot sincos -5.0 *. px + 'pEye  ! -5.0 *. py + 'pEye 8 + !
	|zz 'pEye 16 + !
|	pz 7.0 + 'pEye 16 + ! | allways on top
	0 py px 'pTo !+ !+ ! | remove z coord
	'pEye 'pTo 'pUp mlookat 'fview mcpyf ;
	
:see1r
	prot sincos px + 'pTo ! py + 'pTo 8 + !
	'px 'pTo 'pUp mlookat 'fview mcpyf 
	;

:see3r	
	prot sincos -5.0 *. px + 'pEye  ! -5.0 *. py + 'pEye 8 + !
	zz 'pEye 16 + !
	pz 4.0 + 'pEye 16 + ! | allways on top
	pz py px 'pTo !+ !+ ! | remove z coord
	'pEye 'pTo 'pUp mlookat 'fview mcpyf ;
	
:player
	see3r
	|see1r

	matini 
	|prot 0.25 +  | camara siempre atras
	0
	px py pz mrpos
	4.0 muscalei
	'fmodel mcpyf | model matrix
	startshader
	'fprojection shadercam
	'flpos shaderlight
	o1 drawobjm 

	playerkey
	prot sincos vd *. 'px +! vd *. 'py +!
	vr 'prot +!

	pz vpz +
	0 <=? ( drop 0 'pz ! 0 'vpz ! ; )
	'pz !
	-0.005 'vpz +!	
	;
	

:superficie
	prot px py genfloordyn
		
	'fmodel 'fprojection 'flpos drawfloor
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
	
|-------------------------------	
:juego
	gui
	'dnlook 'movelook onDnMove

	$4100 glClear | color+depth
	'listobj p.draw
	
	superficie
	player
	
	SDL_windows SDL_GL_SwapWindow
	SDLkey
	>esc< =? ( exit ) 	
	<f1> =? ( 50 ( 1? 1 - objrand +objr ) drop ) 
	<f2> =? ( 50 ( 1? 1 - objrand +objr2 ) drop ) 

	drop ;		
	

	
:jugar 
	'listfx p.clear
	'listobj p.clear
|	20 ( 1? 1-
|		objrand +objr2
|		) drop

	'juego SDLShow 
	;
	
|-------------------------------------
#objs 	
|"r3/games/lunar/obj/yyht.objm"  |*
"r3/games/lunar/obj/astro1.objm" 
"r3/games/lunar/obj/piedra.objm" 
"r3/games/lunar/obj/extraterrestrenave.objm" 
"r3/games/lunar/obj/pablo.objm"
"r3/games/lunar/obj/navelau.objm"
"r3/games/lunar/obj/nave.objm"
( 0 )

|---------------------------		
| opengl Constant
#GL_DEPTH_TEST $0B71
#GL_LESS $0201
#GL_CULL_FACE $0B44
	
|-------------------------------------
:glinit
	.cls
	"3d world" 1024 600 SDLinitGL
	glInfo	
	GL_DEPTH_TEST glEnable 
	GL_CULL_FACE glEnable	
	GL_LESS glDepthFunc 
	;	
	
:glend
    SDL_Quit ;
	
:
	glinit
	
	loadshader			| load shader
	0 'cntobj !
	'o1 >a			| load objs
	'objs ( dup c@ 1? drop
		dup loadobjm a!+
		1 'cntobj +!
		>>0 ) drop
	loadhm	
	genfloor		
	initvec
	100 'listfx p.ini
	200 'listobj p.ini
	jugar
	glend
	;	
	
