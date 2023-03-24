| OpenGl utilities
| PHREDA 2023

^r3/lib/mem.r3
^r3/win/sdl2.r3
^r3/win/sdl2gl.r3
^r3/win/sdl2image.r3

| print info from GPU
::glInfo
	$1f00 glGetString .println | vendor
	$1f01 glGetString .println | render
	$1f02 glGetString .println | version
	$8B8C glGetString .println | shader
	;

#GL_COMPILE_STATUS $8B81
#GL_LINK_STATUS $8B82

#GL_FRAGMENT_SHADER $8B30
#GL_VERTEX_SHADER $8B31
#GL_GEOMETRY_SHADER $8dd9 	
	
#t | aux for error
#f #g #v	
	
:prCheckErr | ss --
	dup GL_LINK_STATUS 't glGetProgramiv
	t 1? ( 2drop ; ) drop
	512 't here glGetProgramInfoLog
	here .println ;

:shCheckErr | ss --
	dup GL_COMPILE_STATUS 't glGetShaderiv
	t 1? ( 2drop ; ) drop
	512 0 here glGetShaderInfoLog
	here .println ;

:createsh | type mem -- nh
	>r glCreateShader dup 
	dup 1 r> 0 glShaderSource
	dup glCompileShader 
	dup GL_COMPILE_STATUS 't glGetShaderiv 
	t 0? ( drop shCheckErr 0 ; ) drop
	;

:typeshader | adr -- adr
	0 swap c!+ | adr
	dup c@ toupp
	$46 =? ( drop >>cr trim dup 'f ! ; ) | F
	$47 =? ( drop >>cr trim dup 'g ! ; ) | G
	$56 =? ( drop >>cr trim dup 'v ! ; ) | V
	drop ;

| load shader/geom/vertex shader and return id
| free memory used - return 0 if fail
| @S..@
| @g..@
| @v..@
::loadShader | "shader" -- idprogram
	here dup rot
	LOAD over =? ( 2drop "Not shader found" .println 0 ; ) 0 swap c!
	0 'f ! 0 'g ! 0 'v !
	( 64 findchar 1? |"@" findstr 
		typeshader ) drop

	f 1? ( GL_FRAGMENT_SHADER 'f createsh 'f ! ) drop
	g 1? ( GL_GEOMETRY_SHADER 'g createsh 'g ! ) drop
	v 1? ( GL_VERTEX_SHADER 'v createsh 'v ! ) drop
	
	glCreateProgram |'programID !
	dup v glAttachShader
	dup f glAttachShader
	dup g glAttachShader
	dup glLinkProgram 
	dup glValidateProgram
	dup GL_LINK_STATUS 't glGetProgramiv 
	t 0? ( drop prCheckErr 0 ; ) drop
	
	v glDeleteShader
	f glDeleteShader
	g glDeleteShader
	;

::shadera!i | int shader "name"  --
	glGetAttribLocation swap glUniform1i ;
::shader!i | int shader "name"  --
	glGetUniformLocation swap glUniform1i ;
::shader!v3 | 'v3 shader "name" --
	glGetUniformLocation 1 rot glUniform3fv ;
::shader!v4 | 'v4 shader "name" --
	glGetUniformLocation 1 rot glUniform4fv ;	
::shader!m4 | 'm4 shader "name" --	
	glGetUniformLocation 1 rot 0 swap glUniformMatrix4fv ;	
::shader!f1
	glGetUniformLocation 1 rot glUniform1fv ;
	
|--------------------------------
#surface
##glimgw
##glimgh

##GL_TEXTURE $1702
##GL_TEXTURE0 $84C0
##GL_TEXTURE_2D $0DE1
##GL_TEXTURE_2D_ARRAY $8C1A
##GL_TEXTURE_3D $806F

#GL_TEXTURE_MAG_FILTER $2800
#GL_TEXTURE_MIN_FILTER $2801
#GL_LINEAR $2601
#GL_NEAREST $2600
#GL_NEAREST_MIPMAP_LINEAR $2702
#GL_NEAREST_MIPMAP_NEAREST $2700
#GL_TEXTURE_WRAP_R $8072
#GL_TEXTURE_WRAP_S $2802
#GL_TEXTURE_WRAP_T $2803

#GL_RED $1903
#GL_RGB $1907
#GL_RGBA $1908
#GL_UNSIGNED_BYTE $1401
#GL_CLAMP_TO_EDGE $812F

:Surface->w surface 16 + d@ ;
:Surface->h surface 20 + d@ ;
:Surface->p surface 24 + d@ ;
:Surface->pixels surface 32 + @ ;
:GLBPP 
	surface 8 + @ 16 + c@
	32 =? ( drop GL_RGBA ; ) 
	24 =? ( drop GL_RGB ; )
	drop GL_RED ;

::glImgFnt | "" -- t
	1 't glGenTextures
    GL_TEXTURE_2D t glBindTexture IMG_Load 'Surface !
	GL_TEXTURE_2D 0 GLBPP Surface->w Surface->h 0 pick3 GL_UNSIGNED_BYTE Surface->pixels glTexImage2D
	GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_NEAREST glTexParameteri
	GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_NEAREST glTexParameteri
	GL_TEXTURE_2D GL_TEXTURE_WRAP_S GL_CLAMP_TO_EDGE  glTexParameteri
	GL_TEXTURE_2D GL_TEXTURE_WRAP_T GL_CLAMP_TO_EDGE  glTexParameteri	
	Surface SDL_FreeSurface
	t ;		


:isPowerOf2 | dim -- 0=is^2
	dup 1 - and ;
	
::glImgTex | "" -- texid
	1 't glGenTextures
    GL_TEXTURE_2D t glBindTexture
	IMG_Load 'Surface !
	GL_TEXTURE_2D 0 GLBPP Surface->w Surface->h 0 pick3 GL_UNSIGNED_BYTE Surface->pixels glTexImage2D
	GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_LINEAR glTexParameteri
	GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_LINEAR glTexParameteri
|	Surface->w isPowerOf2
|	Surface->h isPowerOf2 or 
|	0? ( drop  
|		gl.generateMipmap(gl.TEXTURE_2D);
|		; ) drop 
|	gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
|	gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
|	gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
	Surface->w 'glimgw !
	Surface->h 'glimgh !
	Surface SDL_FreeSurface
	t ;	
	
	
#cc

::glColorTex | col -- texid
	'cc d!
	1 't glGenTextures
    GL_TEXTURE_2D t glBindTexture
	GL_TEXTURE_2D 0 GL_RGBA 1 1 0 pick3 GL_UNSIGNED_BYTE 'cc glTexImage2D
	t ;

|-----------
#GL_ARRAY_BUFFER $8892
#GL_STATIC_DRAW $88E4
#GL_FLOAT $1406

#cubevao
#cubevbo

| x y z nx ny nz tu tv
#vertcube [ | back face
	-1.0 -1.0 -1.0  0.0  0.0 -1.0 0.0 0.0 | bottom-left
	 1.0  1.0 -1.0  0.0  0.0 -1.0 1.0 1.0 | top-right
	 1.0 -1.0 -1.0  0.0  0.0 -1.0 1.0 0.0 | bottom-right         
	 1.0  1.0 -1.0  0.0  0.0 -1.0 1.0 1.0 | top-right
	-1.0 -1.0 -1.0  0.0  0.0 -1.0 0.0 0.0 | bottom-left
	-1.0  1.0 -1.0  0.0  0.0 -1.0 0.0 1.0 | top-left
	| front face
	-1.0 -1.0  1.0  0.0  0.0  1.0 0.0 0.0 | bottom-left
	 1.0 -1.0  1.0  0.0  0.0  1.0 1.0 0.0 | bottom-right
	 1.0  1.0  1.0  0.0  0.0  1.0 1.0 1.0 | top-right
	 1.0  1.0  1.0  0.0  0.0  1.0 1.0 1.0 | top-right
	-1.0  1.0  1.0  0.0  0.0  1.0 0.0 1.0 | top-left
	-1.0 -1.0  1.0  0.0  0.0  1.0 0.0 0.0 | bottom-left
	| left face
	-1.0  1.0  1.0 -1.0  0.0  0.0 1.0 0.0 | top-right
	-1.0  1.0 -1.0 -1.0  0.0  0.0 1.0 1.0 | top-left
	-1.0 -1.0 -1.0 -1.0  0.0  0.0 0.0 1.0 | bottom-left
	-1.0 -1.0 -1.0 -1.0  0.0  0.0 0.0 1.0 | bottom-left
	-1.0 -1.0  1.0 -1.0  0.0  0.0 0.0 0.0 | bottom-right
	-1.0  1.0  1.0 -1.0  0.0  0.0 1.0 0.0 | top-right
	| right face
	 1.0  1.0  1.0  1.0  0.0  0.0 1.0 0.0 | top-left
	 1.0 -1.0 -1.0  1.0  0.0  0.0 0.0 1.0 | bottom-right
	 1.0  1.0 -1.0  1.0  0.0  0.0 1.0 1.0 | top-right         
	 1.0 -1.0 -1.0  1.0  0.0  0.0 0.0 1.0 | bottom-right
	 1.0  1.0  1.0  1.0  0.0  0.0 1.0 0.0 | top-left
	 1.0 -1.0  1.0  1.0  0.0  0.0 0.0 0.0 | bottom-left     
	| bottom face
	-1.0 -1.0 -1.0  0.0 -1.0  0.0 0.0 1.0 | top-right
	 1.0 -1.0 -1.0  0.0 -1.0  0.0 1.0 1.0 | top-left
	 1.0 -1.0  1.0  0.0 -1.0  0.0 1.0 0.0 | bottom-left
	 1.0 -1.0  1.0  0.0 -1.0  0.0 1.0 0.0 | bottom-left
	-1.0 -1.0  1.0  0.0 -1.0  0.0 0.0 0.0 | bottom-right
	-1.0 -1.0 -1.0  0.0 -1.0  0.0 0.0 1.0 | top-right
	| top face
	-1.0  1.0 -1.0  0.0  1.0  0.0 0.0 1.0 | top-left
	 1.0  1.0  1.0  0.0  1.0  0.0 1.0 0.0 | bottom-right
	 1.0  1.0 -1.0  0.0  1.0  0.0 1.0 1.0 | top-right     
	 1.0  1.0  1.0  0.0  1.0  0.0 1.0 0.0 | bottom-right
	-1.0  1.0 -1.0  0.0  1.0  0.0 0.0 1.0 | top-left
	-1.0  1.0  1.0  0.0  1.0  0.0 0.0 0.0  | bottom-left        
	]
	
:memfloat | cnt place --
	>a ( 1? 1 - da@ f2fp da!+ ) drop ;
	
::initcube
	1 'cubeVAO glGenVertexArrays
	1 'cubeVBO glGenBuffers
	| fill buffer
	36 8 * 'vertcube memfloat
	GL_ARRAY_BUFFER cubeVBO glBindBuffer
	GL_ARRAY_BUFFER 36 8 * 2 << 'vertcube GL_STATIC_DRAW glBufferData
	| link vertex attributes
	cubeVAO glBindVertexArray
	0 glEnableVertexAttribArray
	0 3 GL_FLOAT 0 8 2 << 0 glVertexAttribPointer
	1 glEnableVertexAttribArray
	1 3 GL_FLOAT 0 8 2 << 3 2 << glVertexAttribPointer
	2 glEnableVertexAttribArray
	2 2 GL_FLOAT 0 8 2 << 6 2 << glVertexAttribPointer
	GL_ARRAY_BUFFER 0 glBindBuffer
	0 glBindVertexArray
	;

::rendercube
    cubevao glBindVertexArray
    4 0 36 glDrawArrays 
    0 glBindVertexArray
	;
