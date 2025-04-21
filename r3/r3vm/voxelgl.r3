^r3/lib/sdl2.r3
^r3/lib/sdl2gl.r3
^r3/lib/3dgl.r3

|-------------------------------------
#IDprojection
#fprojection * 64

#IDview
#fview * 64
	
|-------------------------------------
#IDpaleta	
#fpaleta * 192 | 16*3*4

#paleta [ | uchu
$080a0d $0949ac $b56227 $2e943a
$542690 $a30d30 $fdfdfd $b59944
$878a8b $3984f2 $ff9f5b $64d970
$915ad3 $ea3c65 $cbcdcd $fedf7b ]

:fillpaleta
	mark
	'paleta >a
	'fpaleta >b
	16 ( 1? 1-
		da@+ 
		dup 16 >> $ff and 1.0 $ff */ dup "vec3(%f," ,print f2fp db!+
		dup 8 >> $ff and 1.0 $ff */ dup "%f," ,print f2fp db!+
		$ff and 1.0 $ff */ dup "%f)" ,print f2fp db!+
		,cr
		) drop 
		"colpal.txt" savemem
	empty
	;
|-------------------------------------
::2float | cnt mem --
	>a ( 1? 1- da@ f2fp da!+ ) drop ;


#GL_COMPILE_STATUS $8B81
#GL_LINK_STATUS $8B82
#GL_FRAGMENT_SHADER $8B30
#GL_VERTEX_SHADER $8B31

#vertexShader
#fragmentShader
#t

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
	
::inishader | fragment vertex -- idshader
	't !
	GL_VERTEX_SHADER glCreateShader dup 
	dup 1 't 0 glShaderSource
	dup glCompileShader 
	dup GL_COMPILE_STATUS 't glGetShaderiv 
	t 0? ( 2drop shCheckErr 0 ; ) drop
	'vertexShader !

	swap 't !
	GL_FRAGMENT_SHADER glCreateShader dup
	dup 1 't 0 glShaderSource
	dup glCompileShader
	dup GL_COMPILE_STATUS 't glGetShaderiv 
	t 0? ( drop shCheckErr 0 ; ) drop
	'fragmentShader ! 

	glCreateProgram 
	dup vertexShader glAttachShader
	dup fragmentShader glAttachShader
	dup glLinkProgram 
	dup glValidateProgram
	dup GL_LINK_STATUS 't glGetProgramiv 
	t 0? ( drop prCheckErr 0 ; ) drop
	
	vertexShader glDeleteShader
	fragmentShader glDeleteShader
	;

