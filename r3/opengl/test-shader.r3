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
	
	GL_VERTEX_SHADER glCreateShader dup 
	dup 1 here 0 glShaderSource
	dup glCompileShader 
	dup GL_COMPILE_STATUS 't glGetShaderiv 
	t 0? ( drop shCheckErr 0 ; ) drop
	'vert !
	
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
	
|--------------------------------

##GL_UNSIGNED_BYTE $1401

##GL_TEXTURE $1702
##GL_TEXTURE0 $84C0
##GL_TEXTURE_2D $0DE1
##GL_TEXTURE_2D_ARRAY $8C1A
##GL_TEXTURE_3D $806F

#GL_TEXTURE_MAG_FILTER $2800
#GL_TEXTURE_MIN_FILTER $2801
#GL_LINEAR $2601

#GL_RED $1903
#GL_RGB $1907
#GL_RGBA $1908

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
	
	
#cc * 80
#cc> 'cc

::glColorTex | col -- texid
	cc> d!+ 'cc> ! | store color (here)
	1 't glGenTextures
    GL_TEXTURE_2D t glBindTexture
	GL_TEXTURE_2D 0 GL_RGBA 1 1 0 pick3 GL_UNSIGNED_BYTE cc> 4 - glTexImage2D
	t ;
	
|*** need code	
::glddsTex | "" -- 
	here swap LOAD here =? ( drop ; ) drop
	here "DDS " =pre 0? ( drop ; ) drop
	
	;

|--------------------- shaders
#shiddiffuse		|uniform vec3 diffuse;
#shidambient		|uniform vec3 ambient;
#shidemissive		|uniform vec3 emissive;
#shidspecular		|uniform vec3 specular;
#shidshininess		|uniform float shininess;
#shidopacity		|uniform float opacity;

#shiddiffuseMap  	|uniform sampler2D diffuseMap;
#shidspecularMap	|uniform sampler2D specularMap;
#shidnormalMap		| uniform sampler2D normalMap;

#shidu_lightDirection	|uniform vec3 u_lightDirection;
#shidu_ambientLight		|uniform vec3 u_ambientLight;

#shidu_projection	|uniform mat4 u_projection;
#shidu_view		|uniform mat4 u_view;
#shidu_world	|uniform mat4 u_world;
#shidu_viewWorldPosition |uniform vec3 u_viewWorldPosition;

##shaderid

##IDpos
##IDnor
##IDuv
##IDtan
##IDcol

::loadshader | --
	"r3/opengl/shader/mtl-test.frag" 
	"r3/opengl/shader/mtl-test.vert" 	
	loadShaders | "fragment" "vertex" -- idprogram
	dup "u_projection" glGetUniformLocation 'shidu_projection !
	dup "u_view" glGetUniformLocation 'shidu_view !
	dup "u_world" glGetUniformLocation 'shidu_world !
	dup "u_viewWorldPosition" glGetUniformLocation 'shidu_viewWorldPosition !

	dup "diffuse" glGetUniformLocation 'shiddiffuse !
	dup "ambient" glGetUniformLocation 'shidambient !
	dup "emissive" glGetUniformLocation 'shidemissive !
	dup "specular" glGetUniformLocation 'shidspecular !
	dup "shininess" glGetUniformLocation 'shidshininess !
	dup "opacity" glGetUniformLocation 'shidopacity !
	
	dup "diffuseMap" glGetUniformLocation 'shiddiffuseMap !	
	dup "specularMap" glGetUniformLocation 'shidspecularMap !	
	dup "normalMap" glGetUniformLocation 'shidnormalMap !	
	
	dup "u_lightDirection" glGetUniformLocation 'shidu_lightDirection !
	dup "u_ambientLight" glGetUniformLocation 'shidu_ambientLight !
	
	dup "a_position" glGetAttribLocation 'IDpos !
	dup "a_normal" glGetAttribLocation 'IDnor !
	dup "a_texcoord" glGetAttribLocation 'IDuv !
	dup "a_tangent" glGetAttribLocation 'IDtan !
	dup "a_color" glGetAttribLocation 'IDcol !
	'shaderid ! 
	;
	
#fdiffuse * 12		|uniform vec3 diffuse;
#fambient * 12		|uniform vec3 ambient;
#femissive * 12		|uniform vec3 emissive;
#fspecular * 12		|uniform vec3 specular;
#fshininess [ 0	]	|uniform float shininess;
#fopacity [ 0 ]		|uniform float opacity;

#fdiffuseMap [ 0 ]  |uniform sampler2D diffuseMap;
#fspecularMap [ 0 ]	|uniform sampler2D specularMap;
#fnormalMap [ 0 ]	| uniform sampler2D normalMap;

##fu_lightDirection * 12	|uniform vec3 u_lightDirection;
##fu_ambientLight * 12		|uniform vec3 u_ambientLight;

##fu_projection * 64		|uniform mat4 u_projection;
##fu_view * 64				|uniform mat4 u_view;
##fu_world * 64				|uniform mat4 u_world;
##fu_viewWorldPosition * 12	|uniform vec3 u_viewWorldPosition;
	
::setshader | src --
	|dup >a 'fdiffuse swap 17 dmove |
	>a

	shiddiffuse 1 a> glUniform3fv 12 a+
	shidambient 1 a> glUniform3fv 12 a+
	shidemissive 1 a> glUniform3fv 12 a+
	shidspecular 1 a> glUniform3fv 12 a+
	shidshininess 1 a> glUniform1fv 4 a+
	shidopacity 1 a> glUniform1fv 4 a+

	shiddiffuseMap 0 glUniform1i
	GL_TEXTURE0 glActiveTexture
	GL_TEXTURE_2D da@+ glBindTexture 
	
	shidspecularMap 1 glUniform1i
	GL_TEXTURE0 1 + glActiveTexture
	GL_TEXTURE_2D da@+ glBindTexture
	
	shidnormalMap 2 glUniform1i
	GL_TEXTURE0 2 + glActiveTexture
	GL_TEXTURE_2D da@+ glBindTexture 
	
	shidu_lightDirection 1 'fu_lightDirection glUniform3fv
	shidu_ambientLight 1 'fu_ambientLight glUniform3fv

	shidu_projection 1 0 'fu_projection glUniformMatrix4fv 	
	shidu_view 1 0 'fu_view glUniformMatrix4fv
	shidu_world 1 0 'fu_world glUniformMatrix4fv 	
	shidu_viewWorldPosition 1 'fu_viewWorldPosition glUniform3fv

	;

#texWhite 
#texNorm
#vec30 [ 0 0 0 ]
#vec31 [ 1 1 1 ]

:vec32fp | 'adr 
	>a da@ f2fp da!+ da@ f2fp da!+ da@ f2fp da! ;
	
::resetshader
	'fdiffuse 'vec31 3 dmove
	'fambient 'vec30 3 dmove
	'femissive 'vec30 3 dmove
	'fspecular 'vec31 3 dmove
	400.0 f2fp 'fshininess d!
	1.0 f2fp 'fopacity d!
	
	texWhite 'fdiffuseMap d!
	texNorm 'fnormalMap d!
	texWhite 'fspecularMap d!
	;
	
|-----------------------------------------
: 
|	$ffffffff glColorTex 'texWhite !
|	$ff7f7f glColorTex 'texNorm !
	'vec30 vec32fp
	'vec31 vec32fp
	;