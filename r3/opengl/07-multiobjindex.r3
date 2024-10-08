| OpenGL example
| PHREDA 2023
|MEM 64
^r3/lib/3dgl.r3
^r3/lib/rand.r3
^r3/lib/gui.r3
^r3/util/arr16.r3

^r3/lib/sdl2.r3
^r3/lib/sdl2gl.r3

^r3/opengl/ogl2util.r3

| opengl Constant
#GL_ARRAY_BUFFER $8892
#GL_ELEMENT_ARRAY_BUFFER $8893

#GL_STATIC_DRAW $88E4
#GL_FLOAT $1406
#GL_UNSIGNED_SHORT $1403
#GL_FALSE 0

#GL_DEPTH_TEST $0B71
#GL_LESS $0201
#GL_CULL_FACE $0B44

#GL_TRIANGLES $0004

|--------------------- shader
#programID 

#MatrixID
#ViewMatrixID 
#ModelMatrixID 
#lightID
#textureID

:Shader1 | 'vars "vert" "frag" -- nro
	"r3/opengl/shader/StandardShading.frag" 
	"r3/opengl/shader/StandardShading.vert" 
	loadShaders | "fragment" "vertex" -- idprogram
	dup "MVP" glGetUniformLocation 'MatrixID !
	dup "V" glGetUniformLocation 'ViewMatrixID !
	dup "M" glGetUniformLocation 'ModelMatrixID !		
	dup "myTextureSampler" glGetUniformLocation 'TextureID !	
	dup "LightPosition_worldspace" glGetUniformLocation 'LightID !
	'programID !
	;


#fmvp * 64
#fviewmat * 64
#fmodelmat * 64
#flightpos [ 4.0 4.0 4.0 ]
	
:Shader1! | --
	programID glUseProgram
	MatrixID 1 GL_FALSE 'fmvp glUniformMatrix4fv 	
	ModelMatrixID 1 GL_FALSE 'fmodelmat glUniformMatrix4fv 		
	ViewMatrixID 1 GL_FALSE 'fviewmat glUniformMatrix4fv 		
	LightID 1 'flightpos glUniform3fv
	TextureID 0 glUniform1i
	;

|-------------------------------------
:remname/ | adr --  ; get path only
	( dup c@ $2f <>? drop 1 - ) drop 0 swap c! ;
	
#fnamefull * 1024
#fpath * 1024
#mobj
|	ncolor $ff and 8 << $02 or ,q			| tipo 2 - indices
|	0 ,			| filenames +8
|	0 ,			| VA		+12
|	0 , 		| vertex>	+16
|	0 , 		| normal>	+20
|	0 , 		| uv>		+24
|	0 ,			| index> 	+28
|	auxvert> auxvert - ,		| cntvert +32
|	indexa> indexa - ,			| cntindex +36

:cntvert mobj 32 + d@ ;
:cntind mobj 36 + d@ ;

| v 2.0 - index
:loadobjm | file -- mem
	dup 'fnamefull strcpy
	dup 'fpath strcpyl remname/
	here dup 'mobj !
	swap load here =? ( drop 0 ; ) 'here !
	mobj @+ drop | cnt | tipo
	dup d@ mobj + 	| adr names
	1 pick2 glGenTextures	| d@ string
    GL_TEXTURE_2D pick2 d@ glBindTexture
	'fpath "%s/%s" sprint glLoadImg 		| load tex
	4 + | adr
	1 over glGenVertexArrays
	dup d@ glBindVertexArray
	4 +
	dup d@ mobj + | adr vertex
	1 pick2 glGenBuffers
	GL_ARRAY_BUFFER pick2 d@ glBindBuffer
	GL_ARRAY_BUFFER cntvert 12 * rot GL_STATIC_DRAW glBufferData
	4 +	
	dup d@ mobj +	| adr normal
	1 pick2 glGenBuffers
	GL_ARRAY_BUFFER pick2 d@ glBindBuffer
	GL_ARRAY_BUFFER cntvert 12 * rot GL_STATIC_DRAW glBufferData
	4 +	
	dup d@ mobj +	| adr uv
	1 pick2 glGenBuffers
	GL_ARRAY_BUFFER pick2 d@ glBindBuffer
	GL_ARRAY_BUFFER cntvert 3 << rot GL_STATIC_DRAW glBufferData	
	4 +	
	dup d@ mobj +	| adr index
	1 pick2 glGenBuffers
	GL_ELEMENT_ARRAY_BUFFER pick2 d@ glBindBuffer
	GL_ELEMENT_ARRAY_BUFFER cntind 1 << rot GL_STATIC_DRAW glBufferData	
	drop
	
	mobj
	;
	
|	ncolor $ff and 8 << $02 or ,q			| tipo 2 - indices
|	0 ,			| filenames +8
|	0 ,			| VA		+12
|	0 , 		| vertex>	+16
|	0 , 		| normal>	+20
|	0 , 		| uv>		+24
|	0 ,			| index> 	+28
|	auxvert> auxvert - ,		| cntvert +32
|	indexa> indexa - ,			| cntindex +36

:drawobjm | adr --
	8 + >a 
	GL_TEXTURE0 glActiveTexture
	
	GL_TEXTURE_2D da@+ glBindTexture 
	0 glEnableVertexAttribArray
	4 a+ |VA
	GL_ARRAY_BUFFER da@+ glBindBuffer
	0 3 GL_FLOAT GL_FALSE 0 0 glVertexAttribPointer
	2 glEnableVertexAttribArray	
	GL_ARRAY_BUFFER da@+ glBindBuffer
	2 3 GL_FLOAT GL_FALSE 0 0 glVertexAttribPointer
	1 glEnableVertexAttribArray
	GL_ARRAY_BUFFER da@+ glBindBuffer
	1 2 GL_FLOAT GL_FALSE 0 0 glVertexAttribPointer
	GL_ELEMENT_ARRAY_BUFFER da@+ glBindBuffer
	4 a+
	GL_TRIANGLES da@+ GL_UNSIGNED_SHORT 0 glDrawElements

	0 glDisableVertexAttribArray
	1 glDisableVertexAttribArray
	2 glDisableVertexAttribArray
	;

|-------------------------------------
:glinit
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
	
|------ vista
#xm #ym
#rx #ry

:dnlook
	SDLx SDLy 'ym ! 'xm ! ;

:movelook
	SDLx SDLy
	ym over 'ym ! - neg 7 << 'rx +!
	xm over 'xm ! - 7 << neg 'ry +!  ;


#mateye * 128
#matcam * 128

#pEye 1.0 1.0 1.0
#pTo 0 0 0
#pUp 0 1.0 0

:eyecam
	 'pEye 'pTo 'pUp mlookat  | eye to up -- 
	'mateye mcpy ;

:initvec
	matini
	0.1 1000.0 0.9 3.0 4.0 /. mperspective 
|	-2.0 2.0 -2.0 2.0 -2.0 2.0 mortho
	'matcam mcpy	| perspective matrix

	eyecam		| eyemat
	
	'fviewmat midf	| view matrix >>
	
	'flightpos >a	| light position
	da@ f2fp da!+ da@ f2fp da!+ da@ f2fp da!+ 
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
	dup 8 + >b
	|------- rot+pos obj
	0 'fhit ! 
	matini 
	b@+ %1 b@+ hit %10 b@+ hit %100 b@+ hit mrpos
	'fmodelmat mcpyf | model matrix	>>
	
	'mateye mm* 	|------- mov eye
	'matcam mm* 	| cam matrix
	'fmvp mcpyf		| mvp matrix >>
	
	|------- refresh & hit
	5 3 << + >b rhit
	b@+ b> 5 3 << - dup @ rot +rota swap !
	b@+ b> 5 3 << - +! | +x
	b@+ b> 5 3 << - +! | +y
	b@+ b> 5 3 << - +! | +z
	
	|------- draw
	Shader1!
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
"media/obj/food/Brocolli.objm" "media/obj/food/Bellpepper.objm" "media/obj/food/Banana.objm" "media/obj/food/Apple.objm"  "media/obj/food/Crabcake.objm" "media/obj/food/Cake.objm" "media/obj/food/Carrot.objm" "media/obj/food/Cherries.objm" "media/obj/food/Chicken.objm" "media/obj/food/Lollipop.objm" ( 0 )

|---------------------------		
:ini	
	Shader1			| load shader
	
	0 'cntobj !
	'o1 >a			| load objs
	'objs ( dup c@ 1? drop
		dup loadobjm a!+
		1 'cntobj +!
		>>0 ) drop
	
	initvec
	
	1000 'arrayobj p.ini 
|	.cls	
	.cr .cr .cr .cr glinfo
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