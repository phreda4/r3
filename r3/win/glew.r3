| glew32.dll
|
^r3/win/console.r3

#sys-glewInit
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
#sys-glClear
#sys-glUseProgram
#sys-glEnableVertexAttribArray
#sys-glVertexAttribPointer
#sys-glDrawElements
#sys-glDisableVertexAttribArray
#sys-glDeleteProgram
#sys-glIsProgram
#sys-glIsShader
#sys-glGenVertexArrays
#sys-glBindVertexArray
#sys-glGetShaderInfoLog
#sys-glBindFragDataLocation
#sys-glLinkProgram
#sys-glGenTextures
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


::glewInit sys-glewInit sys0 drop ;
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

::glew
	"GLEW32.DLL" loadlib
	dup "glewInit" getproc 'sys-glewInit ! 
	dup "__glewCreateProgram" getproc 'sys-glCreateProgram !
	dup "__glewCreateShader" getproc 'sys-glCreateShader !
	dup "__glewShaderSource" getproc 'sys-glShaderSource !
	dup "__glewCompileShader" getproc 'sys-glCompileShader !
	dup "__glewGetShaderiv" getproc 'sys-glGetShaderiv !
	dup "__glewAttachShader" getproc 'sys-glAttachShader !
	dup "__glewGetProgramiv" getproc 'sys-glGetProgramiv !
	dup "__glewGetAttribLocation" getproc 'sys-glGetAttribLocation !
	dup "__glewClearColorx" getproc 'sys-glClearColor !
	dup "__glewGenBuffers" getproc 'sys-glGenBuffers !
	dup "__glewBindBuffer" getproc 'sys-glBindBuffer !
	dup "__glewBufferData" getproc 'sys-glBufferData !
	dup "__glewClear" getproc 'sys-glClear !
	dup "__glewUseProgram" getproc 'sys-glUseProgram !
	dup "__glewEnableVertexAttribArray" getproc 'sys-glEnableVertexAttribArray !
	dup "__glewVertexAttribPointer" getproc 'sys-glVertexAttribPointer !
	dup "__glewDrawElements" getproc 'sys-glDrawElements !
	dup "__glewDisableVertexAttribArray" getproc 'sys-glDisableVertexAttribArray !
	dup "__glewIsProgram" getproc 'sys-glIsProgram !
	dup "__glewIsShader" getproc 'sys-glIsShader !
	dup "__glewGenVertexArrays" getproc 'sys-glGenVertexArrays !
	dup "__glewBindVertexArray" getproc 'sys-glBindVertexArray !
	dup "__glewGetShaderInfoLog" getproc 'sys-glGetShaderInfoLog !
	dup "__glewBindFragDataLocation" getproc 'sys-glBindFragDataLocation !
	dup "__glewLinkProgram" getproc 'sys-glLinkProgram !
	dup "__glewGenTextures" getproc 'sys-glGenTextures !
	dup "__glewActiveTexture" getproc 'sys-glActiveTexture !
	dup "__glewBindTexture" getproc 'sys-glBindTexture !
	dup "__glewTexImage2D" getproc 'sys-glTexImage2D !
	dup "__glewUniform1i" getproc 'sys-glUniform1i !
	dup "__glewTexParameteri" getproc 'sys-glTexParameteri !
	dup "__glewTexSubImage2D" getproc 'sys-glTexSubImage2D !
	dup "__glewEnable" getproc 'sys-glEnable !
	dup "__glewBlendFunc" getproc 'sys-glBlendFunc !
	dup "__glewDetachShader" getproc 'sys-glDetachShader !
	dup "__glewDeleteShader" getproc 'sys-glDeleteShader !
	dup "__glewDeleteTextures" getproc 'sys-glDeleteTextures !
	dup "__glewDeleteBuffers" getproc 'sys-glDeleteBuffers !
	dup "__glewDeleteVertexArrays" getproc 'sys-glDeleteVertexArrays !
	drop
	
	|'sys-glewInit ( 'sys-glDeleteVertexArrays <? @+ " %h " .print ) drop
	;