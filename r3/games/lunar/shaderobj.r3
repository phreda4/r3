| OpenGl full shader mtl
| PHREDA 2023

^r3/lib/mem.r3
^r3/win/sdl2.r3
^r3/win/sdl2gl.r3
^r3/win/sdl2image.r3

#GL_COMPILE_STATUS $8B81
#GL_LINK_STATUS $8B82
#GL_FRAGMENT_SHADER $8B30
#GL_VERTEX_SHADER $8B31
 	
#frag
#vert

#t		| aux var

:shCheckErr | ss --
	dup GL_COMPILE_STATUS 't glGetShaderiv
	t 1? ( 2drop ; ) drop
	512 0 here glGetShaderInfoLog
	here .println ;
	
:prCheckErr | ss --
	dup GL_LINK_STATUS 't glGetProgramiv
	t 1? ( 2drop ; ) drop
	512 't here glGetProgramInfoLog
	here .println ;

| load shader/vertex shader and return id
| free memory used - return 0 if fail
::loadShaders | "fragment" "vertex" -- idprogram
	here 16 + 	| room for 'vert and 'frag
	dup 'vert !
	swap LOAD vert =? ( 2drop 0 ; ) 
	0 swap c!+ 
	dup 'frag !
	swap LOAD frag =? ( drop 0 ; )  
	0 swap c!
	frag vert here !+ !
	|"vertex shader." .println
	GL_VERTEX_SHADER glCreateShader dup 
	dup 1 here 0 glShaderSource
	dup glCompileShader 
	dup GL_COMPILE_STATUS 't glGetShaderiv 
	t 0? ( drop shCheckErr 0 ; ) drop
	'vert !
	|"fragment shader." .println
	GL_FRAGMENT_SHADER glCreateShader dup
	dup 1 here 8 + 0 glShaderSource
	dup glCompileShader
	dup GL_COMPILE_STATUS 't glGetShaderiv 
	t 0? ( drop shCheckErr 0 ; ) drop
	'frag ! 
	
	glCreateProgram |'programID !
	dup vert glAttachShader
	dup frag glAttachShader
	dup glLinkProgram 
	dup glValidateProgram
	dup GL_LINK_STATUS 't glGetProgramiv 
	t 0? ( drop prCheckErr 0 ; ) drop
	
	vert glDeleteShader
	frag glDeleteShader
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

#GL_ARRAY_BUFFER $8892
#GL_ELEMENT_ARRAY_BUFFER $8893

#GL_STATIC_DRAW $88E4
#GL_FLOAT $1406
#GL_UNSIGNED_SHORT $1403
#GL_FALSE 0

#GL_UNSIGNED_BYTE $1401

#GL_TEXTURE $1702
#GL_TEXTURE0 $84C0
#GL_TEXTURE_2D $0DE1
#GL_TEXTURE_2D_ARRAY $8C1A
#GL_TEXTURE_3D $806F

#GL_TEXTURE_MAG_FILTER $2800
#GL_TEXTURE_MIN_FILTER $2801
#GL_LINEAR $2601

#GL_RED $1903
#GL_RGB $1907
#GL_RGBA $1908

#GL_TRIANGLES $0004

|--- sdl2 surface
|struct SDL_Surface
|	flags           dd ? 0 dd ? 4
|	?format        	dq ? 8 8
|	w               dd ? 16 4
|	h               dd ? 20 4
|	pitch           dd ? 24 4 dd ? 28 4
|	pixels          dq ? 32 8
#surface
:Surface->w surface 16 + d@ ;
:Surface->h surface 20 + d@ ;
:Surface->pixels surface 32 + @ ;
:Surface->format->bpp surface 8 + @ 16 + c@ ;
:GLBPP 
	Surface->format->bpp 
	32 =? ( drop GL_RGBA ; ) 
	24 =? ( drop GL_RGB ; )
	drop GL_RED ;
	
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
	t ;	
	
	
#cc * 256
#cc> 'cc

::glColorTex | col -- texid
	cc> d!+ 'cc> ! | store color (here)
	1 't glGenTextures
    GL_TEXTURE_2D t glBindTexture
	GL_TEXTURE_2D 0 GL_RGBA 1 1 0 pick3 GL_UNSIGNED_BYTE cc> 4 - glTexImage2D
	t ;
	
|--------------------- shaders
#IDpos
#IDnor
#IDtex

#IDlpos | vec3 Light.position;
#IDlamb | vec3 Light.ambient;
#IDldif | vec3 Light.diffuse;
#IDlspe | vec3 Light.specular;

#IDmamb | vec3 Material.ambient;
#IDmdif | vec3 Material.diffuse;
#IDmspe | vec3 Material.specular;    
#IDmdifM | sampler2D Material.diffuseMap;
#IDmspeM | sampler2D Material.specularMap;    	
#IDmshi | float Material.shininess;

#IDprojection	|uniform mat4 u_projection;
#IDview			|uniform mat4 u_view;
#IDmodel		|uniform mat4 u_world;

#shaderid

::loadshader | --
	"r3/games/lunar/shader/mat1.fs" 
	"r3/games/lunar/shader/mat1.vs" 	
	loadShaders | "fragment" "vertex" -- idprogram
	0? ( drop .input ; )
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

	dup "projection" glGetUniformLocation 'IDprojection !
	dup "view" glGetUniformLocation 'IDview !
	dup "model" glGetUniformLocation 'IDmodel !

	'shaderid ! 
	;
	
::startshader	
	shaderid glUseProgram	
	;

|----------------------------------------------------------
::shadercam | adr --
	IDprojection 1 0 pick3 glUniformMatrix4fv 64 +
	IDview 1 0 pick3 glUniformMatrix4fv 64 +
	IDmodel 1 0 pick3 glUniformMatrix4fv |64 +
	drop
	;

::shaderlight | adr --
	IDlpos 1 pick2 glUniform3fv 12 +
	IDlamb 1 pick2 glUniform3fv 12 +
	IDldif 1 pick2 glUniform3fv 12 +
	IDlspe 1 pick2 glUniform3fv |12 +
	drop ;
		
|---in mem!		
|	dup ]Kd@ ,vf3	| diffuse color +4
|	dup ]Ka@ ,vf3	| ambient color +16
|	dup ]Ke@ ,vf3	| emissive +28
|	dup ]Ks@ ,vf3	| specular	+40
|	dup ]Ns@ ,vf	| shininess +52
|	dup ]d@ ,vf		| opacity	+56
|	dup ]Mkd@ ,		| diffuse Map { 255 255 255 255} +60
|	dup ]MNs@ , 	| especular Map { 255 255 255 255} +64
|	dup ]Mbp@ ,		| normal Map { 127 127 255 0 } +68
::shadermat | adr --
	IDmdif 1 pick2 glUniform3fv 12 + | vec3 Material.diffuse;
	IDmamb 1 pick2 glUniform3fv 12 + | vec3 Material.ambient;
	12 + | emissive
	IDmspe 1 pick2 glUniform3fv 12 + | vec3 Material.specular;    
	IDmshi 1 pick2 glUniform1fv 4 + | float Material.shininess;
	4 + | opacity

	IDmdifM 0 glUniform1i
	GL_TEXTURE0 glActiveTexture | sampler2D Material.diffuseMap;
	GL_TEXTURE_2D over d@ glBindTexture 4 +

	IDmspeM 1 glUniform1i
	GL_TEXTURE0 1 + glActiveTexture | sampler2D Material.specularMap;
	GL_TEXTURE_2D over d@ glBindTexture |4 +

|	GL_TEXTURE0 2 + glActiveTexture | sampler2D Material.normalMap;
|	GL_TEXTURE_2D over d@ glBindTexture 4 +
	
	drop
	;
	
|-------------------------------------
:remname/ | adr --  ; get path only
	( dup c@ $2f <>? drop 1 - ) drop 0 swap c! ;
	
#fnamefull * 1024
#fpath * 1024
#cmat

|	ncolor $ff and 8 << $02 or ,q			| tipo 2 - indices
|	0 ,			| filenames +8 | not used<<
|	0 ,			| VA		+12
|	0 , 		| vertex>	+16
|	0 , 		| normal>	+20
|	0 , 		| uv>		+24
|	0 ,			| index> 	+28
|	auxvert> auxvert - ,		| cntvert +32
|	indexa> indexa - ,			| cntindex +36

:cntvert b> 32 + d@ ;
:cntind b> 36 + d@ ;

:loadtex | adr -- adr val
	dup d@ 0? ( drop $ffffffff glColorTex ; ) | need texcolor!
	b> + 'fpath "%s/%s" sprint 
	|dup .write .cr
	glImgTex 	| load tex
	;
	
:loadmat | adr -- adr' 
	dup 60 + loadtex swap d!
	dup 64 + loadtex swap d!
	dup 68 + loadtex swap d!
	72 + ;
	
::loadobjm | file -- mem
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

	
|	ncolor $ff and 8 << $02 or ,q			| tipo 2 - indices
|	0 ,			| filenames +8
|	0 ,			| VA		+12
|	0 , 		| vertex>	+16
|	0 , 		| normal>	+20
|	0 , 		| uv>		+24
|	0 ,			| index> 	+28
|	auxvert> auxvert - ,		| cntvert +32
|	indexa> indexa - ,			| cntindex +36

::drawobjm | adr --
	@+ 8 >> $ff and 'cmat ! | cant materials
	>a 
	4 a+ | no used
	da@+ glBindVertexArray | VA
	IDpos glEnableVertexAttribArray	
	GL_ARRAY_BUFFER da@+ glBindBuffer | vertex>
	IDpos 3 GL_FLOAT GL_FALSE 0 0 glVertexAttribPointer
	
	IDnor glEnableVertexAttribArray	
	GL_ARRAY_BUFFER da@+ glBindBuffer | normal>
	IDnor 3 GL_FLOAT GL_FALSE 0 0 glVertexAttribPointer
	
	IDtex glEnableVertexAttribArray
	GL_ARRAY_BUFFER da@+ glBindBuffer | uv>
	IDtex 2 GL_FLOAT GL_FALSE 0 0 glVertexAttribPointer
	
	GL_ELEMENT_ARRAY_BUFFER da@+ glBindBuffer | index>
	8 a+	| cntvert total
	0 cmat ( 1? 1 - swap
		da@+ | start cnt
		a> shadermat 
		GL_TRIANGLES over GL_UNSIGNED_SHORT pick4 1 << glDrawElements		
		+ 68 a+ swap ) 2drop
	IDtex glDisableVertexAttribArray
	IDnor glDisableVertexAttribArray
	IDpos glDisableVertexAttribArray
	;

