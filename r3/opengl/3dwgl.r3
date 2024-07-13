| 3dworld - opengl
| PHREDA 2024
|-----
^r3/lib/rand.r3
^r3/lib/3dgl.r3
^r3/lib/gui.r3

^r3/util/arr16.r3

^r3/win/sdl2.r3
^r3/win/sdl2gl.r3

^r3/opengl/shaderobj.r3

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

|---------------
#GL_ARRAY_BUFFER $8892
#GL_ELEMENT_ARRAY_BUFFER $8893

#GL_STATIC_DRAW $88E4
#GL_DYNAMIC_DRAW $88E8

#GL_FLOAT $1406
#GL_UNSIGNED_SHORT $1403

#GL_TRIANGLE_FAN $0006
#GL_TRIANGLE_STRIP $0005
#GL_FALSE 0

#GL_TEXTURE $1702
#GL_TEXTURE0 $84C0
#GL_TEXTURE_2D $0DE1

#shfloor
#vafl
#vbfl 
#vifl
#vnfl
#vtfl

#IDtp 
#IDtv
#IDtm 

#IDpos
#IDnor 
#IDtex 

#IDlpos 
#IDlamb 
#IDldif 
#IDlspe 

#IDmamb 
#IDmdif 
#IDmspe 
#IDmdifM 
#IDmspeM 
#IDmshi 

#texm

#dif [ 0.7 0.7 0.7 ]
#amb [ 0.5 0.5 0.5 ]
#spe [ 0.8 0.8 0.8 ]
#sho 1.0
	
	
:shaderlightf | adr --
	IDlpos 1 pick2 glUniform3fv 12 +
	IDlamb 1 pick2 glUniform3fv 12 +
	IDldif 1 pick2 glUniform3fv 12 +
	IDlspe 1 pick2 glUniform3fv |12 +
	drop ;

:mem2float | cnt to --
	>a ( 1? 1 - da@ f2fp da!+ ) drop ;
	
:genfloor
	10 'dif mem2float | 3+3+3+1
	"r3/opengl/shader/height.fs" 
	"r3/opengl/shader/height.vs" 
	loadShaders 
	
	dup "aPos" glGetAttribLocation 'IDpos !
	dup "aNormal" glGetAttribLocation 'IDnor !
	dup "aTexCoords" glGetAttribLocation 'IDtex !

	dup "light.position" glGetUniformLocation 'IDlpos !
	dup "light.ambient" glGetUniformLocation 'IDlamb !
	dup "light.diffuse" glGetUniformLocation 'IDldif !
	dup "light.specular" glGetUniformLocation 'IDlspe !

	dup "material.ambient" glGetUniformLocation 'IDmamb !
	dup "material.diffuse" glGetUniformLocation 'IDmdif !
	dup "material.specular" glGetUniformLocation 'IDmspe !
	dup "material.diffuseMap" glGetUniformLocation 'IDmdifM !
	dup "material.specularMap" glGetUniformLocation 'IDmspeM !
	dup "material.shininess" glGetUniformLocation 'IDmshi !
	
	dup "projection" glGetUniformLocation 'IDtp !
	dup "view" glGetUniformLocation 'IDtv !
	dup "model" glGetUniformLocation 'IDtm !	
	'shfloor !
	
	1 'vafl glGenVertexArrays	| VA
	vafl glBindVertexArray 
	
	1 'vbfl glGenBuffers
	mark
	-80.0 ( 80.0 <=?
		-80.0 ( 80.0 <=?
			over f2fp , dup f2fp , 
			|2.0 randmax 3.0 -
			-5.0 randmax
			f2fp , | x y z
			4.0 + ) drop
		4.0 + ) drop
	GL_ARRAY_BUFFER vbfl glBindBuffer	| vertex
	|GL_ARRAY_BUFFER memsize swap GL_STATIC_DRAW glBufferData
	GL_ARRAY_BUFFER memsize swap GL_DYNAMIC_DRAW glBufferData
	empty


    0 3 GL_FLOAT GL_FALSE 12 0 glVertexAttribPointer
    0 glEnableVertexAttribArray

	1 'vnfl glGenBuffers
	mark
	-20.0 ( 20.0 <=?
		-20.0 ( 20.0 <=?
			1.0 randmax 1.0 over -
			0.0 f2fp , f2fp , f2fp , | x y z
			1.0 + ) drop
		1.0 + ) drop
	GL_ARRAY_BUFFER vnfl glBindBuffer | normal
	GL_ARRAY_BUFFER memsize swap GL_STATIC_DRAW glBufferData
	empty


	1 'vtfl glGenBuffers	
	mark
	-20.0 ( 20.0 <=?
		-20.0 ( 20.0 <=?
			over $10000 and f2fp , 
			dup $10000 and f2fp , 
			1.0 + ) drop
		1.0 + ) drop
	GL_ARRAY_BUFFER vtfl  glBindBuffer | uv
	GL_ARRAY_BUFFER memsize swap GL_STATIC_DRAW glBufferData	
	empty
	
	| -20 ..20 = 40
	mark	
	0 ( 40 <? 
		0 ( 41 <? 
			over 41 * over + ,w
			over 1 + 41 * over + ,w
			1 + ) drop
		1 + ) drop
	1 'vifl glGenBuffers
	GL_ELEMENT_ARRAY_BUFFER vifl glBindBuffer
	GL_ELEMENT_ARRAY_BUFFER memsize swap GL_STATIC_DRAW glBufferData	
	empty
	
	"media/img/metal.jpg" glImgTex 'texm !
	;
	
:genfloordyn
	1 'vbfl glGenBuffers
	mark
	-80.0 ( 80.0 <=?
		-80.0 ( 80.0 <=?
			over px + f2fp , dup py + f2fp , 
			|2.0 randmax 3.0 -
			-3.0 randmax
			f2fp , | x y z
			4.0 + ) drop
		4.0 + ) drop
	GL_ARRAY_BUFFER vbfl glBindBuffer	| vertex
	|GL_ARRAY_BUFFER memsize swap GL_STATIC_DRAW glBufferData
	GL_ARRAY_BUFFER memsize swap GL_DYNAMIC_DRAW glBufferData
	empty
	;
	
:floorcam | adr --
	IDtp 1 0 pick3 glUniformMatrix4fv 64 +
	IDtv 1 0 pick3 glUniformMatrix4fv 64 +
|	IDtm 1 0 pick3 glUniformMatrix4fv |64 +
	drop

	'fmodel midf
	IDtm 1 0 'fmodel glUniformMatrix4fv |64 +
	;
	
:drawfloor
	shfloor glUseProgram	

	'flpos shaderlightf	
	'fprojection floorcam

	IDmdif 1 'dif glUniform3fv  | vec3 Material.diffuse;
	IDmamb 1 'amb glUniform3fv  | vec3 Material.ambient;
	IDmspe 1 'spe glUniform3fv  | vec3 Material.specular;    
	IDmshi 1 'sho glUniform1fv  | float Material.shininess;
	
	vafl glBindVertexArray
	0 glEnableVertexAttribArray	
	GL_ARRAY_BUFFER vbfl glBindBuffer | vertex>
	0 3 GL_FLOAT GL_FALSE 0 0 glVertexAttribPointer
	
	1 glEnableVertexAttribArray	
	GL_ARRAY_BUFFER vnfl glBindBuffer | normal>
	1 3 GL_FLOAT GL_FALSE 0 0 glVertexAttribPointer
	
	2 glEnableVertexAttribArray
	GL_ARRAY_BUFFER vtfl glBindBuffer | uv>
	2 2 GL_FLOAT GL_FALSE 0 0 glVertexAttribPointer
	
	GL_ELEMENT_ARRAY_BUFFER vifl glBindBuffer | index>	
	
	IDmdifM 0 glUniform1i
	GL_TEXTURE0 glActiveTexture | sampler2D Material.diffuseMap;
	GL_TEXTURE_2D texm glBindTexture 
	
	0 ( 40 <?
		GL_TRIANGLE_STRIP 
		40 1 <<
		GL_UNSIGNED_SHORT
		41 1 << pick4 * 1 <<
		glDrawElements
		1 + ) drop
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
	<a> =? ( genfloordyn )
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
	
:player
	see3r
	|see1r

	matini 
	prot px py pz mrpos
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
	-0.02 'vpz +!	
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
	
	drawfloor
	
	'listobj p.draw

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
	20 ( 1? 1-
		objrand +objr2
		) drop

	'juego SDLShow 
	;
	
|-------------------------------------
#objs 	
"media/obj/cube.objm"
"media/obj/rock.objm"
"media/obj/rock2.objm"
"media/obj/tree.objm"
"media/obj/tree2.objm" 
"media/obj/tree3.objm"
"media/obj/raceCarRed.objm" 
|"media/obj/basicCharacter.objm" 

|"media/obj/tinker.objm" 
|"media/obj/food/Lollipop.objm"
|"media/obj/mario/mario.objm"
|"media/obj/rock.objm"
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
	genfloor		
	initvec
	.cr .cr 
	"<esc> - Exit" .println
	"<esp> - jmp" .println	
	

	100 'listfx p.ini
	200 'listobj p.ini
	jugar
	glend
	;	
	
