| OpenGL example
| PHREDA 2023
|MEM 64
^r3/lib/3d.r3
^r3/lib/rand.r3
^r3/lib/gui.r3
^r3/util/arr16.r3
|^r3/lib/trace.r3

^r3/win/sdl2.r3
^r3/win/sdl2gl.r3
^r3/win/sdl2ttf.r3

^r3/opengl/shaderobj.r3
^r3/opengl/gltext.r3

| opengl Constant
#GL_DEPTH_TEST $0B71
#GL_LESS $0201
#GL_CULL_FACE $0B44


|-------------------------

|-------------------------------------
#flpos * 12
#flamb * 12
#fldif * 12
#flspe * 12
	
#fprojection * 64
#fview * 64
#fmodel * 64
	
#pEye 0.0 40.0 40.0
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
	
	'flpos >a
	1.2 f2fp da!+ 20.0 f2fp da!+ 2.0 f2fp da!+ | light position
	
	1.0 f2fp da!+ 1.0  f2fp da!+ 1.0 f2fp da!+ | ambi
	0.9 f2fp da!+ 0.9 f2fp da!+ 0.9 f2fp da!+ | diffuse
	1.0 f2fp da!+ 1.0 f2fp da!+ 1.0 f2fp da!+ | spec
	;


|----------
#chsum
#model
#frames
#frametime
#animation
#model

#framenow
	
:bvhrload | "" --
	here dup rot load 'here !
	4 + d@+ 'animation !
	d@+ 'chsum !
	d@+ 'frames !
	d@+ 'frametime ! 
	dup 'animation +!
	'model !
	;

#bones 

:loadbones | "" --
	here dup rot load 'here !
	'bones !
	;

|-------------------------------------
:remname/ | adr --  ; get path only
	( dup c@ $2f <>? drop 1 - ) drop 0 swap c! ;
	
#fnamefull * 1024
#fpath * 1024
#cmat

| version 2 obj
| "objr" ,	| 
| vert		| largo|vertex cant	
| ind		| tipo|inde cant	
| string>	| A
| buffer>	| B adr buffer
| index>	| I adr index
| format 	00000000 
| colors|sizecolor
| cver|col1,cver|col2..cver|coln

| >>bufer	| cvert*largo
| >>index	| cindex*1|2|4
| >>string names

|format
| 0 fin 
| 1 pos 3
| 2 norm 3 
| 3 uv 2
| 4 bones 4i
| 5 wbones 4
| 6 tan 3
| 7 bit 3
#testobj 

:mtestobj
	here dup 'testobj !
	"objr" d@ ,
	16 24 << 24 or ,	| size vertex | cnt vertex
	1 24 << 36 or ,		| size index | cnt index
	0 , | string
	0 ,	| vertex
	0 ,	| index
	$54321 , | format
	1 24 << 10 or ,	| 1 color, 10 bytes /colors
	36 ,		
	0 , 0 , 0 ,
	0 , 0 , 0 ,
	0 , 0 , 0 ,
	

:initobj | "" -- obj
    1 'VAO glGenVertexArrays
    1 'VBO glGenBuffers
	1 'VIO glGenBuffers

    VAO glBindVertexArray
    GL_ARRAY_BUFFER VBO glBindBuffer
    GL_ARRAY_BUFFER cbuffer buffer>> GL_STATIC_DRAW glBufferData
	GL_ELEMENT_ARRAY_BUFFER VIO glBindBuffer
	GL_ELEMENT_ARRAY_BUFFER cindex index>> GL_STATIC_DRAW glBufferData		
	
    0 glEnableVertexAttribArray |POS
    0 3 GL_FLOAT GL_FALSE 8 2 << 0 glVertexAttribPointer
	
    1 glEnableVertexAttribArray | NOR
    1 3 GL_FLOAT GL_FALSE 8 2 << 3 2 << glVertexAttribPointer
	
    2 glEnableVertexAttribArray | UV
    2 2 GL_FLOAT GL_FALSE 8 2 << 6 2 << glVertexAttribPointer

    3 glEnableVertexAttribArray | IBONE
    3 4 GL_INT 4 2 << 3 2 << glVertexAttribIPointer

    4 glEnableVertexAttribArray | IBONE
    4 4 GL_FLOAT GL_FALSE 8 2 << 3 2 << glVertexAttribPointer

    0 glBindVertexArray	
	;

:renderobj | obj --

    VAO glBindVertexArray
	GL_TRIANGLE 0 cntindex glDrawArrays 
    0 glBindVertexArray
	;
	
:deleteobj | obj --
	VIO glDeleteBuffers
	VBO glDeleteBuffers	
	VAO glDeleteVertexArrays
	;
	
	| glUseProgram(_shader._id);
	| glUniformMatrix4fv(_projection_ptr, 1, GL_FALSE, glm::value_ptr(projection));
	| glUniformMatrix4fv(_view_ptr, 1, GL_FALSE, glm::value_ptr(view));
	| glUniformMatrix4fv(_model_ptr, 1, GL_FALSE, glm::value_ptr(model));
	| glUniformMatrix4fv(_transforms_ptr, GLsizei(transforms.size()), GL_FALSE, glm::value_ptr(transforms[0]));
	| glUniform3fv(_light_position_ptr, 1, glm::value_ptr(light_position));
	| glUniform3fv(_view_position_ptr, 1, glm::value_ptr(view_position));	
	
| unsigned VAO = 0;
| unsigned VBO = 0;
| unsigned EBO = 0;
| glGenVertexArrays(1, &VAO);
| glGenBuffers(1, &VBO);
| glGenBuffers(1, &EBO);

| glBindVertexArray(VAO);
| glBindBuffer(GL_ARRAY_BUFFER, VBO);
| glBufferData(GL_ARRAY_BUFFER , vertices.size() * sizeof(AnimVertex) , vertices.data(), GL_STATIC_DRAW);
| glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
| glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.size() * sizeof(unsigned), indices.data(), GL_STATIC_DRAW);
| glEnableVertexAttribArray(0);
| glVertexAttribPointer(0, 3/*vec3*/, GL_FLOAT, GL_FALSE, sizeof(AnimVertex), (void*)offsetof(AnimVertex, position));
| glEnableVertexAttribArray(1);
| glVertexAttribPointer(1, 3/*vec3*/, GL_FLOAT, GL_FALSE, sizeof(AnimVertex), (void*)offsetof(AnimVertex, normal));
| glEnableVertexAttribArray(2);
| glVertexAttribPointer(2, 2/*vec2*/, GL_FLOAT, GL_FALSE, sizeof(AnimVertex), (void*)offsetof(AnimVertex, texture_uv));
| glEnableVertexAttribArray(3);
| glVertexAttribIPointer(3, 4/*int[4]*/, GL_INT, sizeof(AnimVertex), (void*)offsetof(AnimVertex, bone_ids));
| glEnableVertexAttribArray(4);
| glVertexAttribPointer(4, 4/*float[4]*/, GL_FLOAT, GL_FALSE, sizeof(AnimVertex), (void*)offsetof(AnimVertex, weights));
| glEnableVertexAttribArray(5);
| glVertexAttribPointer(5, 3/*vec3*/, GL_FLOAT, GL_FALSE, sizeof(AnimVertex), (void*)offsetof(AnimVertex, tangent));
| glEnableVertexAttribArray(6);
| glVertexAttribPointer(6, 3/*vec3*/, GL_FLOAT, GL_FALSE, sizeof(AnimVertex), (void*)offsetof(AnimVertex, bitangent));
| glBindVertexArray(0);

| return RenderMesh(VAO, VBO, EBO, indices.size(), GetTexture(textures, TextureType::Diffuse), GetTexture(textures, TextureType::Normal));	
|------------------------------	
:cntvert b> 32 + d@ ;
:cntind b> 36 + d@ ;

:loadtex | adr -- adr val
	dup d@ 0? ( ; ) | need texcolor!
	b> + 
	'fpath "%s/%s" sprint |dup .print
	glImgTex 	| load tex
	|dup "-->%h" .println
	;
	
:loadmat | adr -- adr' 
	dup 60 + loadtex swap d!
	dup 64 + loadtex swap d!
	dup 68 + loadtex swap d!
	72 + ;
	
::loadobjmb | file -- mem
	dup 'fnamefull strcpy
	dup 'fpath strcpyl remname/
	here dup >b
	swap load here =? ( drop 0 ; ) 'here !
	b> @+ 
	dup 8 >> $ff and 'cmat ! | cant materials
	drop | cnt | tipo
	4 + | not used..
	1 over glGenVertexArrays	| VA
	dup d@ glBindVertexArray 
	4 + | vertex>
	dup d@ b> + | adr vertex	
	1 pick2 glGenBuffers
	GL_ARRAY_BUFFER pick2 d@ glBindBuffer
	GL_ARRAY_BUFFER cntvert 12 * rot GL_STATIC_DRAW glBufferData
	4 +	| normal>
	dup d@ b> +	| adr normal
	1 pick2 glGenBuffers
	GL_ARRAY_BUFFER pick2 d@ glBindBuffer
	GL_ARRAY_BUFFER cntvert 12 * rot GL_STATIC_DRAW glBufferData
	4 +	| uv>
	dup d@ b> +	| adr uv
	1 pick2 glGenBuffers
	GL_ARRAY_BUFFER pick2 d@ glBindBuffer
	GL_ARRAY_BUFFER cntvert 3 << rot GL_STATIC_DRAW glBufferData	
	4 +	| index>
	dup d@ b> +	| adr index
	1 pick2 glGenBuffers
	GL_ELEMENT_ARRAY_BUFFER pick2 d@ glBindBuffer
	GL_ELEMENT_ARRAY_BUFFER cntind 1 << rot GL_STATIC_DRAW glBufferData	
	12 + | first material
	cmat ( 1? 1 - swap
		loadmat
		swap ) 2drop
	b>
	;

	
#ashaderid


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

	'pEye @+ swap @+ swap @
	"CAM z:%f y:%f x:%f" sprint
	-0.8 0.8 gltext
	
	SDL_windows SDL_GL_SwapWindow
	SDLkey
	>esc< =? ( exit ) 	
	
	<up> =? ( 0.5 'pEye +! eyecam )
	<dn> =? ( -0.5 'pEye +! eyecam )
	<le> =? ( 0.5 'pEye 8 + +! eyecam )
	<ri> =? ( -0.5 'pEye 8 + +! eyecam )
	<a> =? ( 0.5 'pEye 16 + +! eyecam )
	<d> =? ( -0.5 'pEye 16 + +! eyecam )

	drop ;	

|---------------------------		
:ini	
	loadshader			| load shader
	"r3/opengl/shader/anim_model.fs" 
	"r3/opengl/shader/anim_model.vs" 	
	loadShaders | "fragment" "vertex" -- idprogram
	0? ( drop .input ; )
	'ashaderid ! 	

	"media/bvh/ChaCha001.bvhr" bvhrload
	"media/bvh/bones2mario" loadbones
	"media/obj/mario/mario.objm" loadobjmb 'o1 !
	
	initvec

|	.cls	
	cr cr glinfo
	"<esc> - Exit" .println
	
	;
	
|----------- BOOT
:
	"test opengl" 800 600 SDLinitGL
	
	initglfont
	
	GL_DEPTH_TEST glEnable 
	GL_CULL_FACE glEnable	
	GL_LESS glDepthFunc 

 	ini
	'main SDLshow
	SDL_Quit
	;	