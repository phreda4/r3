^r3/lib/mem.r3
^r3/win/sdl2.r3
^r3/win/sdl2gl.r3
^r3/win/sdl2image.r3


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
 	
| mem---
| 'vertsh -> vertsh + 16
| 'fragsh -> fragsh + len(vertsh)
| vertsh 
| fragsh

#frag
#vert
#err
::loadShaders | "fragment" "vertex" -- idprogram
	here 16 + 
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
	dup GL_COMPILE_STATUS 'err glGetShaderiv
	err 0? ( 2drop 0 ; ) drop
	'vert !
	
	GL_FRAGMENT_SHADER glCreateShader dup
	dup 1 here 8 + 0 glShaderSource
	dup glCompileShader
	dup GL_COMPILE_STATUS 'err glGetShaderiv
	err 0? ( 2drop 0 ; ) drop
	'frag ! 
	
	glCreateProgram |'programID !
	dup vert glAttachShader
	dup frag glAttachShader
	dup glLinkProgram 
	dup glValidateProgram
	dup GL_LINK_STATUS 'err glGetProgramiv
	err 0? ( 2drop 0 ; ) drop
	
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
|	userdata        dq ?
|	locked          dd ? dd ?
|	lock_data       dq ?
|	clip_rect       SDL_Rect
|	map             dq ?
|	refcount        dd ? dd ?
#surface
:Surface->w surface 16 + d@ ;
:Surface->h surface 20 + d@ ;
:Surface->pixels surface 32 + @ ;
:Surface->format->bpp surface 8 + @ 16 + c@ ;
:GLBPP Surface->format->bpp 32 =? ( drop GL_RGBA ; ) drop GL_RGB ;
	
::glLoadImg | "" -- 
	IMG_Load 'Surface !
 
	GL_TEXTURE_2D 0 GLBPP Surface->w Surface->h 0 pick3 GL_UNSIGNED_BYTE Surface->pixels glTexImage2D
	GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_LINEAR glTexParameteri
	GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_LINEAR glTexParameteri
	;	
	
|*** need code	
::glLoadDDS | "" -- 
	here swap LOAD here =? ( drop ; ) drop
	here "DDS " =pre 0? ( drop ; ) drop
	
	;

