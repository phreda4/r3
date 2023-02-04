| OpenGL example
| PHREDA 2023
|MEM 64
^r3/lib/3d.r3
^r3/lib/rand.r3
^r3/lib/gui.r3
^r3/util/arr16.r3

^r3/win/sdl2.r3
^r3/win/sdl2gl.r3

^r3/util/loadobj.r3

^r3/opengl/ogl2util.r3


| opengl Constant
#GL_ARRAY_BUFFER $8892
#GL_STATIC_DRAW $88E4
#GL_FLOAT $1406
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

#texture	
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
	
	GL_TEXTURE0 glActiveTexture
	GL_TEXTURE_2D Texture glBindTexture
	TextureID 0 glUniform1i
	;

|--------------------- model
#vertex_buffer_data 
#normal_buffer_data
#uv_buffer_data 
	
:vert+uv | nro --
	dup $fffff and 1 - | vertex
	5 << verl +
	@+ f2fp da!+ @+ f2fp da!+ @ f2fp da!+ | x y z
	dup 20 >> $fffff and 1 - | texture
	24 * texl +
	@+ f2fp db!+ @ f2fp db!+
	nface 3 * 3 * 2 << 12 - a+
	40 >> $fffff and 1 - | normal
	24 * norml +
	@+ f2fp da!+ @+ f2fp da!+ @ f2fp da!+ | x y z
	nface 3 * 3 * 2 << neg a+
	;

:convertobj | "" --
	loadobj drop |'model !
	here 
	dup 'vertex_buffer_data ! 
	nface 3 * 3 * 2 << + | 3 vertices por vertice 3 coor por vertices 4 bytes por nro
	dup 'normal_buffer_data !
	nface 3 * 3 * 2 << + | 3 vertices por vertice 3 coor por vertices 4 bytes por nro
	'uv_buffer_data  !
	vertex_buffer_data >a
	| normal_buffer_data = vertex + nface 3 * 3 * 2 << +
	uv_buffer_data >b
	facel 
	nface ( 1? 1 - swap
		@+ vert+uv
		@+ vert+uv
		@+ vert+uv
		8 + swap ) 2drop
	b> 'here !
	;

#VertexArrayID
#vertexbuffer	
#normalbuffer	
#uvbuffer

	
:objModel | "" --
	convertobj

	1 'VertexArrayID glGenVertexArrays
	VertexArrayID glBindVertexArray

	1 'vertexbuffer glGenBuffers
	GL_ARRAY_BUFFER vertexbuffer glBindBuffer
	GL_ARRAY_BUFFER nface 3 * 3 * 2 << vertex_buffer_data GL_STATIC_DRAW glBufferData

	1 'normalbuffer glGenBuffers
	GL_ARRAY_BUFFER normalbuffer glBindBuffer
	GL_ARRAY_BUFFER nface 3 * 3 * 2 << normal_buffer_data GL_STATIC_DRAW glBufferData

	1 'uvbuffer glGenBuffers
	GL_ARRAY_BUFFER uvbuffer glBindBuffer
	GL_ARRAY_BUFFER nface 3 * 2 * 2 << uv_buffer_data GL_STATIC_DRAW glBufferData
	;
	
		
:objDraw! | nro --
	0 glEnableVertexAttribArray
	GL_ARRAY_BUFFER vertexbuffer glBindBuffer
	0 3 GL_FLOAT GL_FALSE 0 0 glVertexAttribPointer
	1 glEnableVertexAttribArray
	GL_ARRAY_BUFFER uvbuffer glBindBuffer
	1 2 GL_FLOAT GL_FALSE 0 0 glVertexAttribPointer
	2 glEnableVertexAttribArray
	GL_ARRAY_BUFFER normalbuffer glBindBuffer
	2 3 GL_FLOAT GL_FALSE 0 0 glVertexAttribPointer

	GL_TRIANGLES 0 nface 3 * glDrawArrays

	0 glDisableVertexAttribArray
	1 glDisableVertexAttribArray
	2 glDisableVertexAttribArray
	;
	

|-------------------------------------
:glinit
	5 1 SDL_GL_SetAttribute		|SDL_GL_DOUBLEBUFFER, 1);
|	13 1 SDL_GL_SetAttribute	|SDL_GL_MULTISAMPLEBUFFERS, 1);
|	14 8 SDL_GL_SetAttribute	|SDL_GL_MULTISAMPLESAMPLES, 8);
    17 4 SDL_GL_SetAttribute |SDL_GL_CONTEXT_MAJOR_VERSION
    18 6 SDL_GL_SetAttribute |SDL_GL_CONTEXT_MINOR_VERSION
	20 2 SDL_GL_SetAttribute |SDL_GL_CONTEXT_FLAGS, SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG);	
	21 2 SDL_GL_SetAttribute |SDL_GL_CONTEXT_PROFILE_MASK,  SDL_GL_CONTEXT_PROFILE_COMPATIBILITY
|	SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);
	
	"test opengl" 800 600 SDLinitGL
	glInfo	
	GL_DEPTH_TEST glEnable 
	GL_CULL_FACE glEnable	
	GL_LESS glDepthFunc 
	;	
	
:glend
	programID glDeleteProgram
	1 'VertexArrayID glDeleteVertexArrays
	1 'uvbuffer glDeleteBuffers
	1 'vertexbuffer glDeleteBuffers
	1 'normalbuffer glDeleteBuffers
	1 'Texture glDeleteTextures

    SDL_Quit
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

#pEye 4.0 0.0 0.0
#pTo 0 0 0
#pUp 0 1.0 0

#matcam * 128

:initvec
	matini
	0.1 1000.0 0.9 3.0 4.0 /. mperspective 
	'matcam mmcpy	| perspective matrix

|	matini
	'fviewmat midf	| view matrix >>
	
	'flightpos >a	| light position
	da@ f2fp da!+ da@ f2fp da!+ da@ f2fp da!+ 
	;

|--------------	
#arrayobj 0 0

#fhit

:hit | mask pos -- pos
	-20.0 <? ( over 'fhit +! )
	20.0 >? ( over 'fhit +! )
	nip ;
	
:rhit	
	fhit 
	%1 and? ( b> 24 + dup @ neg swap ! )
	%10 and? ( b> 32 + dup @ neg swap ! )
	%100 and? ( b> 40 + dup @ neg swap !  )
	drop ;
	
:objexec | adr -- 
	dup >b
	matini 
	|------- mov obj
	b@+ b@+ b@+ mrot
	0 'fhit ! 
	%1 b@+ hit %10 b@+ hit %100 b@+ hit mpos
	'fmodelmat mcpyf | model matrix	>>
	
	|------- mov camara
	|mpush 'pEye 'pTo 'pUp mlookat m* | eye to up -- : **** BAD MATRIX

	|------- perspective
	'matcam mm* 	| cam matrix
	'fmvp mcpyf		| mvp matrix >>
	
	Shader1!
	objDraw!
	6 3 << + >b
	rhit
	b@+ b> 7 3 << - +!
	b@+ b> 7 3 << - +!
	b@+ b> 7 3 << - +!
	b@+ b> 7 3 << - +!
	b@+ b> 7 3 << - +!
	b@+ b> 7 3 << - +!
	;
	
:+obj | vz vy vx vrz vry vrx z y x rz ry rx --
	'objexec 'arrayobj p!+ >a 
	a!+ a!+ a!+ 
	a!+ a!+ a!+ 
	a!+ a!+ a!+ 
	a!+ a!+ a!+ ;

:velrot 0.01 randmax 0.005 - ;
:velpos 0.5 randmax 0.25 - ;
	
:+objr	
	velpos velpos velpos |vz |vy |vx
	velrot velrot velrot |vrz |vry |vrx
	0 0 0
	1.0 randmax 
	1.0 randmax 
	1.0 randmax  
	+obj ;

:+objr2
	0 0 0 
	0 0 0
	20.0 randmax 10.0 -	| pos z
	20.0 randmax 10.0 - | pos y
	20.0 randmax 10.0 - | pos x	
	1.0 randmax 
	1.0 randmax 
	1.0 randmax  
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
	<f1> =? ( 50 ( 1? 1 - +objr ) drop ) 
	<f2> =? ( 50 ( 1? 1 - +objr2 ) drop ) 
	
	<up> =? ( 1.0 'pEye +! )
	<dn> =? ( -1.0 'pEye +! )
	<le> =? ( 1.0 'pEye 8 + +! )
	<ri> =? ( -1.0 'pEye 8 + +! )
	<a> =? ( 1.0 'pEye 16 + +! )
	<d> =? ( -1.0 'pEye 16 + +! )

	<esp> =? ( +objr )
	drop ;	

|---------------------------		
:ini	
	Shader1			| load shader
	"media/obj/cube.png" 
	glLoadImg 		| load tex
	
	"media/obj/suzanne.obj" 
	|"media/obj/cube.obj" 
	objModel		| load model
	initvec
	
	1000 'arrayobj p.ini 
	.cls	
	glinfo
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