| glew32.dll
|
^r3/win/console.r3

#sys-glewInit
##glewExperimental
#sys-glCreateProgram
#sys-glCreateShader
#sys-glShaderSource
#sys-glCompileShader
#sys-glGetShaderiv
#sys-glAttachShader
#sys-glGetProgramiv
#sys-glGetAttribLocation
#sys-glClearColor
#sys-glGenBuffers
#sys-glBindBuffer
#sys-glBufferData
#sys-glUseProgram
#sys-glEnableVertexAttribArray
#sys-glVertexAttribPointer
#sys-glDisableVertexAttribArray
#sys-glDeleteProgram
#sys-glIsProgram
#sys-glIsShader
#sys-glGenVertexArrays
#sys-glBindVertexArray
#sys-glGetShaderInfoLog
#sys-glBindFragDataLocation
#sys-glLinkProgram
#sys-glActiveTexture
#sys-glBindTexture
#sys-glTexImage2D
#sys-glUniform1i
#sys-glTexParameteri
#sys-glTexSubImage2D
#sys-glEnable
#sys-glBlendFunc
#sys-glDetachShader
#sys-glDeleteShader
#sys-glDeleteTextures
#sys-glDeleteBuffers
#sys-glDeleteVertexArrays

#sys-glClear
#sys-glDrawElements
#sys-glDrawArrays
#sys-glGenTextures

#sys-glewGetString
#sys-glGetString
#sys-wglGetProcAddress

::glCreateProgram sys-glCreateProgram sys0 ;
::glCreateShader sys-glCreateShader sys1 ;
::glShaderSource sys-glShaderSource sys4 drop ;
::glCompileShader sys-glCompileShader sys1 drop ;
::glGetShaderiv sys-glGetShaderiv sys3 drop ;
::glAttachShader sys-glAttachShader sys2 drop ;
::glGetProgramiv sys-glGetProgramiv sys3 drop ;
::glGetAttribLocation sys-glGetAttribLocation sys2 ;
::glClearColor sys-glClearColor sys4 drop ;
::glGenBuffers sys-glGenBuffers sys2 drop ;
::glBindBuffer sys-glBindBuffer sys2 drop ;
::glBufferData sys-glBufferData sys4 drop ;
::glClear sys-glClear sys1 drop ;
::glUseProgram sys-glUseProgram sys1 drop ;
::glEnableVertexAttribArray sys-glEnableVertexAttribArray sys1 drop ;
::glVertexAttribPointer sys-glVertexAttribPointer sys6 drop ;
::glDrawElements sys-glDrawElements sys4 drop ;
::glDisableVertexAttribArray sys-glDisableVertexAttribArray sys1 drop ;
::glDeleteProgram sys-glDeleteProgram sys1 drop ;
::glIsProgram sys-glIsProgram sys1 ;
::glIsShader sys-glIsShader sys1 ;
::glGenVertexArrays sys-glGenVertexArrays sys2 drop ;
::glBindVertexArray sys-glBindVertexArray sys1 drop ;
::glGetShaderInfoLog sys-glGetShaderInfoLog sys4 drop ;
::glBindFragDataLocation sys-glBindFragDataLocation sys3 drop ;
::glLinkProgram sys-glLinkProgram sys1 drop ;
::glGenTextures sys-glGenTextures sys2 drop ;
::glActiveTexture sys-glActiveTexture sys1 drop ;
::glBindTexture sys-glBindTexture sys2 drop ;
::glTexImage2D sys-glTexImage2D sys9 drop ;
::glUniform1i sys-glUniform1i sys2 drop ;
::glTexParameteri sys-glTexParameteri sys3 drop ;
::glTexSubImage2D sys-glTexSubImage2D sys9 drop ;
::glEnable sys-glEnable sys1 drop ;
::glBlendFunc sys-glBlendFunc sys2 drop ;
::glDetachShader sys-glDetachShader sys2 drop ;
::glDeleteShader sys-glDeleteShader sys1 drop ;
::glDeleteTextures sys-glDeleteTextures sys2 drop ;
::glDeleteBuffers sys-glDeleteBuffers sys2 drop ;
::glDeleteVertexArrays sys-glDeleteVertexArrays sys2 drop ;

::glDrawArrays sys-glDrawArrays sys3 drop ;
::glewGetString sys-glewGetString sys1 ;
::glGetString sys-glGetString sys1 ;
::wglGetProcAddress sys-wglGetProcAddress sys1 ;

::InitGLAPI
	"glCreateProgram" wglGetProcAddress 'sys-glCreateProgram !
	"glDeleteProgram" wglGetProcAddress 'sys-glDeleteProgram !
	"glUseProgram" wglGetProcAddress 'sys-glUseProgram !
	"glAttachShader" wglGetProcAddress 'sys-glAttachShader !
	"glDetachShader" wglGetProcAddress 'sys-glDetachShader !
	"glLinkProgram" wglGetProcAddress 'sys-glLinkProgram !
	"glGetProgramiv" wglGetProcAddress 'sys-glGetProgramiv !
	"glGetShaderInfoLog" wglGetProcAddress 'sys-glGetShaderInfoLog !
|	"glGetUniformLocation" wglGetProcAddress 'glGetUniformLocation !
	"glUniform1i" wglGetProcAddress 'sys-glUniform1i !
|	"glUniform1iv" wglGetProcAddress 'glUniform1iv !
|	"glUniform2iv" wglGetProcAddress 'glUniform2iv !
|	"glUniform3iv" wglGetProcAddress 'glUniform3iv !
|	"glUniform4iv" wglGetProcAddress 'glUniform4iv !
|	"glUniform1fv" wglGetProcAddress 'glUniform1fv !
|	"glUniform2fv" wglGetProcAddress 'glUniform2fv !
|	"glUniform3fv" wglGetProcAddress 'glUniform3fv !
|	"glUniform4fv" wglGetProcAddress 'glUniform4fv !
|	"glUniformMatrix4fv" wglGetProcAddress 'glUniformMatrix4fv !
	"glGetAttribLocation" wglGetProcAddress 'sys-glGetAttribLocation !
|	"glVertexAttrib1fv" wglGetProcAddress 'glVertexAttrib1fv !
|	"glVertexAttrib2fv" wglGetProcAddress 'glVertexAttrib2fv !
|	"glVertexAttrib3fv" wglGetProcAddress 'glVertexAttrib3fv !
|	"glVertexAttrib4fv" wglGetProcAddress 'glVertexAttrib4fv !
	"glEnableVertexAttribArray" wglGetProcAddress 'sys-glEnableVertexAttribArray !
|	"glBindAttribLocation" wglGetProcAddress 'glBindAttribLocation !

| Shader
	"glCreateShader" wglGetProcAddress 'sys-glCreateShader !
	"glDeleteShader" wglGetProcAddress 'sys-glDeleteShader !
	"glShaderSource" wglGetProcAddress 'sys-glShaderSource !
	"glCompileShader" wglGetProcAddress 'sys-glCompileShader !
	"glGetShaderiv" wglGetProcAddress 'sys-glGetShaderiv !

| VBO
	"glGenBuffers" wglGetProcAddress 'sys-glGenBuffers !
	"glBindBuffer" wglGetProcAddress 'sys-glBindBuffer !
	"glBufferData" wglGetProcAddress 'sys-glBufferData !
	"glVertexAttribPointer" wglGetProcAddress 'sys-glVertexAttribPointer !
	
	"glGenVertexArrays" wglGetProcAddress 'sys-glGenVertexArrays !
	"glBindVertexArray" wglGetProcAddress 'sys-glBindVertexArray !
	"glDeleteBuffers" wglGetProcAddress 'sys-glDeleteBuffers !
	"glDeleteVertexArrays" wglGetProcAddress 'sys-glDeleteVertexArrays !	
	;
	
::glewInit sys-glewInit sys0 drop 
	InitGLAPI
	;
|----- BOOT
:
	"GLEW32.DLL" loadlib
	dup "glewInit" getproc 'sys-glewInit ! 
	dup "glewExperimental" getproc 'glewExperimental !
	dup "__glewClearColorx" getproc 'sys-glClearColor !

	dup "__glewDisableVertexAttribArray" getproc 'sys-glDisableVertexAttribArray !
	dup "__glewIsProgram" getproc 'sys-glIsProgram !
	dup "__glewIsShader" getproc 'sys-glIsShader !
	dup "__glewBindFragDataLocation" getproc 'sys-glBindFragDataLocation !
	dup "__glewActiveTexture" getproc 'sys-glActiveTexture !

	dup "__glewDeleteTexturesEXT" getproc 'sys-glDeleteTextures !

	
	dup "glewGetString" getproc 'sys-glewGetString ! 
	drop
	
	"opengl32.dll" loadlib
	dup "glClear" getproc 'sys-glClear !
	dup "glDrawElements" getproc 'sys-glDrawElements !	
	dup "glGenTextures" getproc 'sys-glGenTextures !
	dup "glBindTexture" getproc 'sys-glBindTexture !
	dup "glTexImage2D" getproc 'sys-glTexImage2D !	
	
	dup "glTexParameteri" getproc 'sys-glTexParameteri !
	dup "glTexSubImage2D" getproc 'sys-glTexSubImage2D !
	dup "glEnable" getproc 'sys-glEnable !	
	dup "glBlendFunc" getproc 'sys-glBlendFunc !	
	dup "glDrawArrays" getproc 'sys-glDrawArrays !
	dup "glGetString" getproc 'sys-glGetString !
	dup "wglGetProcAddress" getproc 'sys-wglGetProcAddress !
	drop

|	0 'sys-glewInit ( 'sys-glGenTextures <=? @+ pick2 "%d %h " .print swap 1 + swap ) 2drop
	;