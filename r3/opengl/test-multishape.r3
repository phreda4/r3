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

^r3/opengl/test-shader.r3

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

|-------------------------------------
:remname/ | adr --  ; get path only
	( dup c@ $2f <>? drop 1 - ) drop 0 swap c! ;
	
#fnamefull * 1024
#fpath * 1024
#mobj
#mstr
|	ncolor $ff and 8 << $02 or ,q			| tipo 2 - indices
|	0 ,			| filenames +8
|	0 ,			| VA		+12
|	0 , 		| vertex>	+16
|	0 , 		| normal>	+20
|	0 , 		| uv>		+24
|	0 ,			| index> 	+28
|	auxvert> auxvert - ,	| cntvert +32
|	cntindex ,			| cntindex +36

|	colors * 76 bytes	| colors +40
|		cntindex ,			
|		

:cntvert mobj 32 + d@ ;
:cntind mobj 36 + d@ ;

#texaux

:debugte | adr -- adr
	d@+ "(cnt:%d)" .println
	d@+ "%h," .print d@+ "%h," .print d@+ "%h - " .print
	d@+ "%h," .print d@+ "%h," .print d@+ "%h" .println
	d@+ "%h," .print d@+ "%h," .print d@+ "%h - " .print
	d@+ "%h," .print d@+ "%h," .print d@+ "%h" .println
	d@+ "%h : " .print d@+ "%h" .println
	
	texaux swap d!+
	texaux swap d!+
	texaux swap d!+

|	d@+ "%h / " .print
|	d@+ "%h / " .print
|	d@+ "%h" .println
	
	;
	
#cntcol 
| v 2.0 - index
:loadobjm | file -- mem
	dup 'fnamefull strcpy
	dup 'fpath strcpyl remname/
	here dup 'mobj !
	swap load here =? ( drop 0 ; ) 'here !
	mobj @+ 
	dup 8 >> $ff and 'cntcol !
	drop | cnt | tipo
	d@+ mobj + 'mstr !
	

	"media/obj/mario/Mario_body.png"  glImgTex dup "%d<<" .println 'texaux !
|	dup d@ mobj + 	| adr names
	
|	1 pick2 glGenTextures	| d@ string
|    GL_TEXTURE_2D pick2 d@ glBindTexture
|	'fpath "%s/%s" sprint glLoadImg 		| load tex
|	drop
	
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
	
	12 +
	
	cntvert "ver:%d" .println
	cntind "ind:%d" .println
	mstr
	0 ( cntcol <? 
		rot debugte rot rot
		swap
|		dup .println >>0
|		dup .println >>0
|		dup .println >>0
		swap 1 + ) 2drop

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
|colors

:drawobjm | adr --
	8 + 4 + >a 
	
		shaderid glUseProgram
		
|	GL_TEXTURE0 glActiveTexture
|	GL_TEXTURE_2D da@+ glBindTexture 
	IDpos glEnableVertexAttribArray
	4 a+ |VA
	GL_ARRAY_BUFFER da@+ glBindBuffer
	IDpos 3 GL_FLOAT GL_FALSE 0 0 glVertexAttribPointer
	
	IDnor glEnableVertexAttribArray	
	GL_ARRAY_BUFFER da@+ glBindBuffer
	IDnor 3 GL_FLOAT GL_FALSE 0 0 glVertexAttribPointer
	
	IDtan glEnableVertexAttribArray	
	GL_ARRAY_BUFFER a> 4 - d@ glBindBuffer
	IDtan 3 GL_FLOAT GL_FALSE 0 0 glVertexAttribPointer
	
	IDuv glEnableVertexAttribArray
	GL_ARRAY_BUFFER da@+ glBindBuffer
	IDuv 2 GL_FLOAT GL_FALSE 0 0 glVertexAttribPointer

	IDcol glEnableVertexAttribArray	
	GL_ARRAY_BUFFER a> 4 - d@ glBindBuffer
	IDcol 4 GL_FLOAT GL_FALSE 0 0 glVertexAttribPointer
	
	GL_ELEMENT_ARRAY_BUFFER da@+ glBindBuffer
	4 a+

	a> 8 + setshader	
	
	GL_TRIANGLES da@+ GL_UNSIGNED_SHORT 0 glDrawElements
	
	
	| 0 
	| da@+ 
	|GL_TRIANGLES pick2 pick2 over + pick3 GL_UNSIGNED_SHORT 0 glDrawRangeElements
	| +
	
	|glDrawRangeElements(mode, start, end, end-start, type, data)
	
	0 glDisableVertexAttribArray
	1 glDisableVertexAttribArray
	2 glDisableVertexAttribArray
	;

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
		
|	glInfo	
	GL_DEPTH_TEST glEnable 
|	GL_CULL_FACE glEnable	
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


|##fu_lightDirection * 12 |uniform vec3 u_lightDirection;
|##fu_ambientLight * 12	|uniform vec3 u_ambientLight;

|##fu_projection * 64			|uniform mat4 u_projection;
|##fu_view * 64					|uniform mat4 u_view;
|##fu_world * 64				|uniform mat4 u_world;
|##fu_viewWorldPosition * 12	|uniform vec3 u_viewWorldPosition;

#mateye * 128
#matcam * 128

#pEye 0.0 0.0 10.0
#pTo 0 0 0
#pUp 0 1.0 0

:eyecam
	'pEye 'pTo 'pUp mlookat  | eye to up -- 
	'mateye mcpy 
|	'fu_camera midf 
	'fu_view mcpyf | inverse camera???	
	;

:initvec
	matini
	0.1 1000.0 0.9 3.0 4.0 /. mperspective 
|	-2.0 2.0 -2.0 2.0 -2.0 2.0 mortho
	'fu_projection mcpyf
	'matcam mmcpy	| perspective matrix
	
	eyecam		| eyemat
	matini
	'fu_world midf	| view matrix >>
	
	'fu_lightDirection >a	| light position
	-1.0 f2fp da!+ 3.0 f2fp da!+ 5.0 f2fp da!+ 
	'fu_ambientLight >a
	1.0 f2fp da!+ 1.0 f2fp da!+ 1.0  f2fp da!+ 
	
	'fu_viewWorldPosition >a
	1.0 f2fp da!+ 2.0 f2fp da!+ 3.0  f2fp da!+ 
	;


|--------------	
#o1 * 80

#arrayobj 0 0

#fhit

:hit | mask pos -- pos
	-400.0 <? ( over 'fhit +! )
	400.0 >? ( over 'fhit +! )
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
	'fu_world mcpyf | model matrix	>>
	
|	'mateye mm* 	|------- mov eye
|	'matcam mm* 	| cam matrix
|	'fu_view mcpyf	

	
	|------- refresh & hit
	4 3 << + >b rhit
	b@+ b> 5 3 << - dup @ rot +rota swap !
	b@+ b> 5 3 << - +! | +x
	b@+ b> 5 3 << - +! | +y
	b@+ b> 5 3 << - +! | +z
	
	|------- draw
	b@+ drawobjm
	;
	
:+obj | obj vz vy vx vrzyx z y x rzyx --
	'objexec 'arrayobj p!+ >a 
	a!+ a!+ a!+ a!+ 
	a!+ a!+ a!+ a!+ 
	a! ;

:objrand
|	9 randmax 3 << 'o1 + @ 
	o1
	;
	
:velrot 0.01 randmax 0.005 - ;
:velpos 5.0 randmax 2.5 - ;
	
:+objr	
	velpos velpos velpos |vz |vy |vx
	velrot velrot velrot packrota |vrz |vry |vrx
	0 0 0 
	0 | 0 0 0 packrota
	+obj ;

:+objr2
	0 0 0 
	velrot velrot velrot packrota
	200.0 randmax 100.0 -	| pos z
	200.0 randmax 100.0 - | pos y
	200.0 randmax 100.0 - | pos x	
	0 | 0 0 0 packrota
	+obj ;

|--------------	
:main
	gui
	'dnlook 'movelook onDnMove

	$4100 glClear | color+depth
	'arrayobj p.draw

	SDL_windows SDL_GL_SwapWindow
	
|	exit
	
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

	<esp> =? ( o1 0 0 0 $001000f0000e -0.5 0.0 0.0 0 +obj )
	drop ;	

|---------------------------		
:ini	
	loadshader		| load shader
	
	"media/obj/mario/mario.objm" 
|	"media/obj/food/Lollipop.objm"
|	"media/obj/cube.objm"
	loadobjm 'o1 !
	
	initvec
	
	1000 'arrayobj p.ini 
|	.cls	
|	glinfo
	"<esc> - Exit" .println
	"<f1> - 50 obj moving" .println
	"<f2> - 50 obj static" .println
	"<esp> - 1 obj moving" .println	
	
	o1 0 0 0 $00f000f0000e -0.5 0.0 0.0 0 +obj
	;
	
|----------- BOOT
:
	glinit
 	ini
	'main SDLshow
	glend 
	|.input
	;	