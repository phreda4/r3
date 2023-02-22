| Obj Model Loader to Robj
| PHREDA 2023
|-----------------------------------
|MEM 512
^r3/win/console.r3
^r3/win/sdl2gl.r3

^r3/lib/3d.r3
^r3/lib/gui.r3

^r3/util/loadobj.r3
^r3/opengl/gltext.r3


#filename * 1024
#cutpath ( $2f )
#fpath * 1024
#fname 

:getpath | 'filename 'path --
	strcpyl 2 -
	( dup c@ $2f <>? drop 1 - ) drop
	0 swap c!+ 'fname !
	;
	
|-------- file bones and weigth
#bones 

:loadbones | "" --
	here dup 'bones !
	swap load 'here !
	;
	
| 4(w) 1(bone) - x4
:,4xw | vertex -- ;
	20 * bones +
	d@+ f2fp , 1+ d@+ f2fp , 1+ d@+ f2fp , 1+ d@+ f2fp , drop ;
	
:,4xi | vertex
	20 * bones +
	4 + c@+ 
	dup "%d " .print
	, 4 + c@+ , 4 + c@+ , 4 + c@+ , drop ;

|---------- file animation bvh
#chsum
#model
#frames
#frametime
#animation
#cbones

#framenow
	
:bvhrload | "" --
	here dup rot load 'here !
	4 + d@+ 'animation !
	d@+ 'chsum !
	d@+ 'frames !
	d@+ 'frametime ! 
	dup 'animation +!
	animation over - 4 >> 'cbones !
	'model !
	;
	
| GENERATE file
|-------------
#vertex_buffer_data 
#normal_buffer_data
#uv_buffer_data 
#filenames

:vert+uv | nro --
	dup $fffff and 1 - ]vert | vertex
	@+ f2fp da!+ @+ f2fp da!+ @ f2fp da!+ | x y z
	
	dup 20 >> $fffff and 1 - ]uv | texture
	@+ f2fp db!+ @ neg f2fp db!+
	
	nface 3 * 3 * 2 << 12 - a+
	40 >> $fffff and 1 - ]norm | normal
	@+ f2fp da!+ @+ f2fp da!+ @ f2fp da!+ | x y z
	nface 3 * 3 * 2 << neg a+
	;

#inimem
#sizemem

|--- how many vertes repeat?
#facerep

:eqvert | 'v1 a2 'v2 -- 'v1 a2
	pick2 =? ( 1 'facerep +! ) drop ;

:equalsvert | face2 face1 --
	@+ pick2 @+ eqvert @+ eqvert @ eqvert drop
	@+ pick2 @+ eqvert @+ eqvert @ eqvert drop
	@ over @+ eqvert @+ eqvert @ eqvert drop
	drop
	;

:vertexrep?
	0 'facerep !
	facel 
	0 ( nface <? 1 + swap
		over ( nface <?  | nro face n2
			dup ]face	| nro face1 n2 face2
			pick2 equalsvert
			1 + ) drop
		32 + swap ) 2drop ;
|---------------------------------		

| tipo 2 -- +index	
#auxvert | vertices
#auxvert>

#indexa | index
#indexa> 

#colornow -1
#indcolor * 128

:searchvert | vert -- vert nvert/-1 
	auxvert ( auxvert> <? 
		@+ pick2 
		=? ( drop auxvert - 3 >> 1 - ; )
		drop ) drop 
	-1 ;
	
:newvert | vert -- vert nvert
	dup auxvert> !+ 'auxvert> !
	auxvert> auxvert - 3 >> 1 - 
	;
	
:addvert, | vert --
	searchvert -? ( drop newvert ) 
	indexa> w!+ 'indexa> !
	drop 
	1 colornow 3 << 'indcolor + +! | add index to col
	;

:savever
	$fffff and 1 - ]vert
	@+ f2fp , @+ f2fp , @ f2fp , ;

:savenor
	40 >> $fffff and 1 - ]norm 
	@+ f2fp , @+ f2fp , @ f2fp , ;
	
:saveuv
	20 >> $fffff and 1 - ]uv 
	@+ f2fp , @ neg f2fp , ;
	
:fillvertex&index
	here 
	dup dup 'auxvert ! 'auxvert> ! | cada vertice usado
	nface 3 * 3 << + | 3 vertices por cara | nro/vert/norm | max
	dup dup 'indexa ! 'indexa> !
	'here !
|	"vertex add" .println
	facel 
	nface ( 1? 1 - swap
		dup 24 + @ 
		'colornow ! 
		@+ addvert, @+ addvert,	@+ addvert,
		8 + swap 
		) 2drop
	indexa> 'here ! ;
	
|--------------------------
:,vf3
	dup $fffff and f2fp ,
	dup 20 >> $fffff and f2fp ,
	40 >> $fffff and f2fp , ;
	
:,vf
	f2fp , ;
	
:,material | n -- n
	'indcolor over 3 << + @ ,		| cntindex +0
	dup ]Kd@ ,vf3	| diffuse color +4
	dup ]Ka@ ,vf3	| ambient color +16
	dup ]Ke@ ,vf3	| emissive +28
	dup ]Ks@ ,vf3	| specular	+40
	dup ]Ns@ ,vf	| shininess +52
	dup ]d@ ,vf		| opacity	+56
	dup ]Ni@ drop	
	dup ]i@ drop
	dup ]Mkd@ ,		| diffuse Map { 255 255 255 255} +60
	dup ]MNs@ , 	| especular Map { 255 255 255 255} +64
	dup ]Mbp@ ,		| normal Map { 127 127 255 0 } +68
	; | +72

:namenmap | n --
	72 * 40 + inimem + ;

:,filen | "" -- adri
	0? ( ; ) 
	here strcpylnl 
	here swap 'here ! 
	inimem - ;
	
:,filesimg | n -- n
	dup ]Mkd@ ,filen over namenmap 60 + d!
	dup ]MNs@ ,filen over namenmap 64 + d!
	dup ]Mbp@ ,filen over namenmap 68 + d!
	;

:convertobj2 | --
	0 ( ncolor <? 
		0 over 3 << 'indcolor + !
		1 + ) drop

	mark
	|*** find and reeplace repetitions in vertex,normal and uv!!
	fillvertex&index
	|---- generate file
	mark
	here 'inimem !
	| cnt partes
	ncolor $ff and 8 << | cnt colores
	$02 or ,q			| tipo 2 - indices
	0 ,			| filenames +8 | not used <<<
	0 ,			| VA		+12
	0 , 		| vertex>	+16
	0 , 		| normal>	+20
	0 , 		| uv>		+24
	0 ,			| index> 	+28
	
	auxvert> auxvert - 3 >> ,		| cnt vert +32
	indexa> indexa - 1 >> ,			| cntindex +36
	| +40
	0 ( ncolor <? ,material 1 + ) drop	| Materiales
	
	here inimem - inimem 16 + d!
	auxvert ( auxvert> <? @+ savever ) drop
	here inimem - inimem 20 + d!
	auxvert ( auxvert> <? @+ savenor ) drop
	here inimem - inimem 24 + d!
	auxvert ( auxvert> <? @+ saveuv ) drop
	here inimem - inimem 28 + d!
	indexa ( indexa> <? w@+ ,w ) drop
	
	|--- old format
	here inimem - inimem 8 + d! | start string
	
	0 ( ncolor <? ,filesimg 1 + ) drop | texture names

	fname 'fpath "%s/%sm" sprint savemem
	empty
	
	empty	
	;



|-------------------------------
#bonesmat>

#anip
:val anip d@+ swap 'anip ! ;

:xpos val 0 0 mtransi ;
:ypos val 0 swap 0 mtransi ;
:zpos val 0 0 rot mtransi ;
:xrot val mrotxi ;
:yrot val mrotyi ;
:zrot val mrotzi ;
#lani xpos ypos zpos xrot yrot zrot

:anibones | flags --
	8 >> $ffffff and
	( 1? dup $f and 1 - 3 << 'lani + @ ex 4 >> )
	drop ;

:drawbones | bones --
	>b
	framenow chsum * 2 << animation + 'anip !
	0 ( db@+ 1? dup $ff and
		rot over - 1 + clamp0 | anterior-actual+1
		nmpop
		mpush
		db@+ db@+ db@+ mtransi
		swap anibones
		b>
		bonesmat> mcpyf
		|bonesmat> midf
		64 'bonesmat> +!
		>b ) drop
	nmpop
	;
	
|-------------------------	
#fprojection * 64
#fview * 64
#fmodel * 64
	
#pEye 0.0 40.0 -80.0
#pTo 0 20.0 0.0
#pUp 0 1.0 0

:eyecam
	'pEye 'pTo 'pUp mlookat 'fview mcpyf ;

:initvec
	matini
	0.1 1000.0 0.9 3.0 4.0 /. mperspective 
|	-2.0 2.0 -2.0 2.0 -2.0 2.0 mortho
	'fprojection mcpyf	| perspective matrix
	eyecam		| eyemat
	'fmodel midf
	;


| DRAW
|-------------
#GL_ARRAY_BUFFER $8892
#GL_ELEMENT_ARRAY_BUFFER $8893

#GL_STATIC_DRAW $88E4
#GL_FLOAT $1406
#GL_UNSIGNED_SHORT $1403
#GL_INT $1404
#GL_FALSE 0
#GL_TRIANGLE $0004

#shaderd
:initshaders
	"r3/opengl/shader/anim_model.fs"
	"r3/opengl/shader/anim_model.vs" 
	loadShaders 'shaderd !

	0 shaderd "texture_diffuse1" shader!i
|	shaderd glUseProgram	
|	0 shaderd "diffuseTexture" shader!i
|	1 shaderd "shadowMap" shader!i
	;
	
#vao 0
#vbo

#buffer>>
#cbuffer
#cfaces
#idt

:,posnor |
	dup $fffff and 1 - ]vert
	@+ f2fp , @+ f2fp , @ f2fp , 
	dup 40 >> $fffff and 1 - ]norm 
	@+ f2fp , @+ f2fp , @ f2fp , 
	dup 20 >> $fffff and 1 - ]uv 
	@+ f2fp , @ neg f2fp , 
	dup $fffff and 1 - ,4xi	| 4 index 
	dup $fffff and 1 - ,4xw	| 4 float
	drop
	;
	
#bufferv
:initobj | "" -- obj
	mark
	
	here 'bufferv !
	facel >b
	nface ( 1? 1 -
		b@+ ,posnor
		b@+ ,posnor
		b@+ ,posnor
		8 b+
		) drop
	
|	here bufferv - "%d bytes" .println
	
    1 'VAO glGenVertexArrays
    1 'VBO glGenBuffers

    VAO glBindVertexArray
    GL_ARRAY_BUFFER VBO glBindBuffer
    GL_ARRAY_BUFFER nface 3 * 16 * 2 << bufferv GL_STATIC_DRAW glBufferData
	
    0 glEnableVertexAttribArray |POS
    0 3 GL_FLOAT GL_FALSE 16 2 << 0 glVertexAttribPointer
	
    1 glEnableVertexAttribArray | NOR
    1 3 GL_FLOAT GL_FALSE 16 2 << 3 2 << glVertexAttribPointer

    2 glEnableVertexAttribArray | UV
    2 2 GL_FLOAT GL_FALSE 16 2 << 6 2 << glVertexAttribPointer

    3 glEnableVertexAttribArray | bones
    3 4 GL_INT 16 2 << 8 2 << glVertexAttribIPointer

    4 glEnableVertexAttribArray | weight
    4 4 GL_FLOAT GL_FALSE 16 2 << 12 2 << glVertexAttribPointer
	
    0 glBindVertexArray	
	empty
	nface 3 * 'cfaces !
	"media/obj/Mario/Mario_body.png" glImgTex 'idt !
	
	;

#GL_TEXTURE_2D $0DE1
#GL_TEXTURE0 $84C0

:renderobj | obj --
	shaderd glUseProgram
	'fprojection shaderd "projection" shader!m4
	'fview shaderd "view" shader!m4
	'fmodel shaderd "model" shader!m4
	
	GL_TEXTURE0 glActiveTexture
	GL_TEXTURE_2D idt glBindTexture

	here 'bonesmat> !
	model drawbones
	
	shaderd "finalBonesMatrices" glGetUniformLocation 
	cbones 0 here glUniformMatrix4fv
	
|	shaderd "finalBonesMatrices[1]" glGetUniformLocation 
|	1 0 here 64 + glUniformMatrix4fv
	
|	glUniformMatrix4fv(jointMatrixLoc, 2, GL_FALSE, glm::value_ptr(jointM[0]));
|	for (int i = 0; i < transforms.size(); ++i)
|		ourShader.setMat4("finalBonesMatrices[" + std::to_string(i) + "]", transforms[i]);
	
	framenow 1 + frames >=? ( 0 nip ) 'framenow !
	
    VAO glBindVertexArray
	GL_TRIANGLE 0 cfaces glDrawArrays 
    0 glBindVertexArray
	;

:deleteobj | obj --
	VBO glDeleteBuffers	
	VAO glDeleteVertexArrays
	;
	
	
| MAIN
|-----------------------------------
#xcam 0 #ycam 0 #zcam -20.0
#xm #ym
#rx #ry

:dnlook
	SDLx SDLy 'ym ! 'xm ! ;

:movelook
	SDLx SDLy
	ym over 'ym ! - neg 7 << 'rx +!
	xm over 'xm ! - 7 << neg 'ry +!  ;

#modelo

:useobj | "" --
	dup 'fpath getpath
	dup 'filename strcpy
	loadobj 'modelo !

	initobj
	;
	

|---------------------------------------------------	
:objinfo
	0.002 'gltextsize !
	'filename -0.98 -0.9 gltext
	"F1:LOAD F2:OBJ1 F3:OBJ2 F10:CENTER" -0.98 0.9 gltext
	frames framenow "%d %d" sprint -0.98 -0.8 gltext
	
	;
	
:main
	gui
	'dnlook 'movelook onDnMove
	$4100 glClear | color+depth
	
	objinfo
	
	|renderobj
	
	SDL_windows SDL_GL_SwapWindow
	
	SDLkey
	<up> =? ( 1.0 'zcam +! )
	<dn> =? ( -1.0 'zcam +! )

	<f1> =? ( loadobj ) 
	<f3> =? ( convertobj2 )
	<f10> =? ( objminmax objcentra )
	>esc< =? ( exit )
	drop ;

|------------------------------------	
#GL_DEPTH_TEST $0B71
#GL_LESS $0201
#GL_CULL_FACE $0B44

: 
	"test opengl" 800 600 SDLinitGL
	initglfont
	
	initvec
	initshaders
	
	GL_DEPTH_TEST glEnable 
	GL_CULL_FACE glEnable
	GL_LESS glDepthFunc 
	
|	"media/obj/" dlgSetPath
	mark
	"media/bvh/bones2mario" loadbones
	"media/bvh/ChaCha001.bvhr" bvhrload
	
|	"media/obj/food/Brocolli.obj" 	
|	"media/obj/food/Bellpepper.obj" 
|	"media/obj/food/Banana.obj" 
|	"media/obj/food/Crabcake.obj" 
|	"media/obj/food/Apple.obj" 
|	"media/obj/food/Cake.obj" 
|	"media/obj/food/Carrot.obj" 
|	"media/obj/food/Cherries.obj" 
|	"media/obj/food/Chicken.obj" 

|	"media/obj/cube.obj"
|	"media/obj/food/Lollipop.obj"
	"media/obj/mario/mario.obj"
|	"media/obj/rock.obj"	
|	"media/obj/lolo/tinker.obj"
|	"media/obj/tinker.obj"
	useobj
	
	'main SDLshow 
	SDLquit
	;