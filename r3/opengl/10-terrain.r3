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

|-------------------------------------
:glinit
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
	
#pEye 0.0 -10.0 10.0
#pTo 0 0 0
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
	-10.0 <? ( over 'fhit +! )
	10.0 >? ( over 'fhit +! )
	nip ;

:hitz | mask pos -- pos
	0.0 <? ( over 'fhit +! )
	10.0 >? ( over 'fhit +! )
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

:+objr2
	0 0 0 
	velrot velrot velrot packrota
	2.0 randmax 	| pos z
	2.0 randmax 1.0 - | pos y
	2.0 randmax 1.0 - | pos x	
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

#shfloor
#vafl
#vbfl 
#vifl
#vnfl
#vtfl

#IDtp 
#IDtv
#IDtm 

#fver
#find
#fnor 
#ftex

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
		

:genfloor
	
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
	here 'fver !
	-40.0 ( 40.0 <=?
		-40.0 ( 40.0 <=?
			over f2fp , dup f2fp , 
			2.0 randmax 3.0 -
			f2fp , | x y z
			2.0 + ) drop
		2.0 + ) drop
	GL_ARRAY_BUFFER vbfl glBindBuffer	| vertex
	GL_ARRAY_BUFFER here fver - fver GL_STATIC_DRAW glBufferData

    0 3 GL_FLOAT GL_FALSE 12 0 glVertexAttribPointer
    0 glEnableVertexAttribArray

here 'fnor !
1 'vnfl glGenBuffers
	-20.0 ( 20.0 <=?
		-20.0 ( 20.0 <=?
			1.0 randmax 1.0 over -
			0.0 f2fp , f2fp , f2fp , | x y z
			1.0 + ) drop
		1.0 + ) drop
	GL_ARRAY_BUFFER vnfl glBindBuffer | normal
	GL_ARRAY_BUFFER here fnor - fnor GL_STATIC_DRAW glBufferData

here 'ftex !
1 'vtfl glGenBuffers	
	-20.0 ( 20.0 <=?
		-20.0 ( 20.0 <=?
			over $10000 and f2fp , 
			dup $10000 and f2fp , 
			1.0 + ) drop
		1.0 + ) drop
	GL_ARRAY_BUFFER vtfl  glBindBuffer | uv
	GL_ARRAY_BUFFER here ftex - ftex GL_STATIC_DRAW glBufferData	
	
	here 'find !
	| -20 ..20 = 40
	0 ( 40 <? 
		0 ( 41 <? 
			over 41 * over + ,w
			over 1 + 41 * over + ,w
			1 + ) drop
		1 + ) drop
	1 'vifl glGenBuffers
	GL_ELEMENT_ARRAY_BUFFER vifl glBindBuffer
	GL_ELEMENT_ARRAY_BUFFER here find - find GL_STATIC_DRAW glBufferData	
	empty
	
	"media/obj/cube.png" glImgTex 'texm !
	|dup "-->%h" .println
	;
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
	
	
|//        glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
	0 ( 40 <?
		GL_TRIANGLE_STRIP 
		40 1 <<
		GL_UNSIGNED_SHORT
		41 1 << pick4 * 1 <<
		glDrawElements
		1 + ) drop
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

	$4100 glClear | color+depth
	
	drawfloor
	
	startshader

	'flpos shaderlight
	'arrayobj p.draw

	SDL_windows SDL_GL_SwapWindow
	SDLkey
	>esc< =? ( exit ) 	
	<f1> =? ( 50 ( 1? 1 - objrand +objr ) drop ) 
	<f2> =? ( 50 ( 1? 1 - objrand +objr2 ) drop ) 
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
"media/obj/rock.objm"
|"media/obj/food/Lollipop.objm"
 ( 0 )


:mem2float | cnt to from --
	>a >b ( 1? 1 - da@+ f2fp db!+ ) drop ;
|---------------------------		
:ini	
	loadshader			| load shader
	0 'cntobj !
	'o1 >a			| load objs
	'objs ( dup c@ 1? drop
		dup loadobjm a!+
		1 'cntobj +!
		>>0 ) drop
	initvec
	1000 'arrayobj p.ini 
	
	10 'dif 'dif mem2float
	genfloor
	
|	.cls	
	.cr .cr glinfo
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