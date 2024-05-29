| glew32.dll
|
^r3/win/sdl2.r3

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
#sys-glBindRenderbuffer
#sys-glBufferData

#sys-glMapBuffer
#sys-glUnmapBuffer

#sys-glUseProgram
#sys-glValidateProgram
#sys-glEnableVertexAttribArray
#sys-glVertexAttribPointer
#sys-glVertexAttribIPointer
#sys-glDisableVertexAttribArray
#sys-glDeleteProgram
#sys-glIsProgram
#sys-glIsShader
#sys-glGenVertexArrays
#sys-glBindVertexArray
#sys-glGetShaderInfoLog
#sys-glGetProgramInfoLog
#sys-glBindFragDataLocation
#sys-glLinkProgram
#sys-glActiveTexture
#sys-glBindTexture
#sys-glTexImage2D
#sys-glUniform1i
#sys-glTexParameteri
#sys-glTexSubImage2D
#sys-glEnable
#sys-glDisable
#sys-glDepthFunc
#sys-glBlendFunc
#sys-glDetachShader
#sys-glDeleteShader
#sys-glDeleteTextures
#sys-glDeleteBuffers
#sys-glDeleteVertexArrays

#sys-glViewport
#sys-glVertexPointer


#sys-glClear
#sys-glDrawElements
#sys-glDrawElementsInstanced
|#sys-glDrawRangeElements
#sys-glDrawArrays
#sys-glGenTextures

#sys-glGetError
#sys-glGetString

#sys-glBegin
#sys-glEnd
#sys-glColor4ubv
#sys-glVertex3fv
#sys-glTexCoord2fv
#sys-glVertex2fv

#sys-glGetUniformLocation 
#sys-glUniform1iv 
#sys-glUniform2iv 
#sys-glUniform3iv 
#sys-glUniform4iv 
#sys-glUniform1fv 
#sys-glUniform2fv 
#sys-glUniform3fv 
#sys-glUniform4fv 
#sys-glUniformMatrix4fv 
#sys-glVertexAttrib1fv 
#sys-glVertexAttrib2fv 
#sys-glVertexAttrib3fv 
#sys-glVertexAttrib4fv 
#sys-glVertexAttribDivisor
#sys-glBindAttribLocation 

#sys-glGenFramebuffers
#sys-glTexParameterfv
#sys-glBindFramebuffer
#sys-glFramebufferTexture2D
#sys-glDrawBuffer
#sys-glReadBuffer
#sys-glPixelStorei
#sys-glRenderbufferStorage
#sys-glFramebufferRenderbuffer
#sys-glGenRenderbuffers
#sys-glGenTextures

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
::glBindRenderbuffer sys-glBindRenderbuffer sys2 drop ;
::glBufferData sys-glBufferData sys4 drop ;

::glMapBuffer sys-glMapBuffer sys2 ;
::glUnmapBuffer sys-glUnmapBuffer sys1 drop ;

::glClear sys-glClear sys1 drop ;
::glUseProgram sys-glUseProgram sys1 drop ;
::glValidateProgram sys-glValidateProgram sys1 drop ;
::glEnableVertexAttribArray sys-glEnableVertexAttribArray sys1 drop ;
::glVertexAttribPointer sys-glVertexAttribPointer sys6 drop ;
::glVertexAttribIPointer sys-glVertexAttribIPointer sys5 drop ;
::glDrawElements sys-glDrawElements sys4 drop ;
::glDrawElementsInstanced sys-glDrawElementsInstanced sys5 drop ;
|::glDrawRangeElements sys-glDrawRangeElements sys6 drop ;
::glDisableVertexAttribArray sys-glDisableVertexAttribArray sys1 drop ;
::glDeleteProgram sys-glDeleteProgram sys1 drop ;
::glIsProgram sys-glIsProgram sys1 ;
::glIsShader sys-glIsShader sys1 ;
::glGenVertexArrays sys-glGenVertexArrays sys2 drop ;
::glBindVertexArray sys-glBindVertexArray sys1 drop ;
::glGetShaderInfoLog sys-glGetShaderInfoLog sys4 drop ;
::glGetProgramInfoLog sys-glGetProgramInfoLog sys4 drop ; 
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
::glDisable sys-glDisable sys1 drop ;
::glBlendFunc sys-glBlendFunc sys2 drop ;
::glDepthFunc sys-glDepthFunc sys1 drop ;
::glDetachShader sys-glDetachShader sys2 drop ;
::glDeleteShader sys-glDeleteShader sys1 drop ;
::glDeleteTextures sys-glDeleteTextures sys2 drop ;
::glDeleteBuffers sys-glDeleteBuffers sys2 drop ;
::glDeleteVertexArrays sys-glDeleteVertexArrays sys2 drop ;

::glDrawArrays sys-glDrawArrays sys3 drop ;
::glGetError sys-glGetError sys0 ; 
::glGetString sys-glGetString sys1 ;
::glViewport sys-glViewport sys4 drop ;
::glVertexPointer sys-glVertexPointer sys4 drop ;

::glBegin sys-glBegin sys1 drop ;
::glEnd sys-glEnd sys0 drop ;
::glColor4ubv sys-glColor4ubv sys1 drop ;
::glVertex3fv sys-glVertex3fv sys1 drop ;
::glTexCoord2fv sys-glTexCoord2fv sys1 drop ;
::glVertex2fv sys-glVertex2fv sys1 drop ;

::glGetUniformLocation sys-glGetUniformLocation sys2 ;
::glUniform1iv sys-glUniform1iv sys3 drop ;
::glUniform2iv sys-glUniform2iv sys3 drop ;
::glUniform3iv sys-glUniform3iv sys3 drop ;
::glUniform4iv sys-glUniform4iv sys3 drop ;
::glUniform1fv sys-glUniform1fv sys3 drop ;
::glUniform2fv sys-glUniform2fv sys3 drop ;
::glUniform3fv sys-glUniform3fv sys3 drop ;
::glUniform4fv sys-glUniform4fv sys3 drop ;
::glVertexAttribDivisor sys-glVertexAttribDivisor sys2 drop ;
::glUniformMatrix4fv sys-glUniformMatrix4fv sys4 drop ;
::glVertexAttrib1fv sys-glVertexAttrib1fv sys2 drop ;
::glVertexAttrib2fv sys-glVertexAttrib2fv sys2 drop ;
::glVertexAttrib3fv sys-glVertexAttrib3fv sys2 drop ;
::glVertexAttrib4fv sys-glVertexAttrib4fv sys2 drop ;
::glBindAttribLocation sys-glBindAttribLocation sys3 drop ;

::glGenFramebuffers sys-glGenFramebuffers sys2 drop ;
::glTexParameterfv sys-glTexParameterfv sys3 drop ;
::glBindFramebuffer sys-glBindFramebuffer sys2 drop ;
::glFramebufferTexture2D sys-glFramebufferTexture2D sys5 drop ;
::glDrawBuffer sys-glDrawBuffer sys1 drop ;
::glReadBuffer sys-glReadBuffer sys1 drop ;
::glPixelStorei sys-glPixelStorei sys2 drop ;
::glRenderbufferStorage sys-glRenderbufferStorage sys4 drop ;
::glFramebufferRenderbuffer sys-glFramebufferRenderbuffer sys4 drop ;
::glGenRenderbuffers sys-glGenRenderbuffers sys2 drop ;
::glGenTextures sys-glGenTextures sys2 drop ;

|------------------------------------------------------
::InitGLAPI
	0 SDL_GL_LoadLibrary
	"glGetError" SDL_GL_GetProcAddress 'sys-glGetError !
	"glGetString" SDL_GL_GetProcAddress 'sys-glGetString !
	"glCreateProgram" SDL_GL_GetProcAddress 'sys-glCreateProgram !
	"glDeleteProgram" SDL_GL_GetProcAddress 'sys-glDeleteProgram !
	"glUseProgram" SDL_GL_GetProcAddress 'sys-glUseProgram !
	"glValidateProgram" SDL_GL_GetProcAddress 'sys-glValidateProgram !
	"glAttachShader" SDL_GL_GetProcAddress 'sys-glAttachShader !
	"glDetachShader" SDL_GL_GetProcAddress 'sys-glDetachShader !
	"glLinkProgram" SDL_GL_GetProcAddress 'sys-glLinkProgram !
	"glGetProgramiv" SDL_GL_GetProcAddress 'sys-glGetProgramiv !
	"glGetShaderInfoLog" SDL_GL_GetProcAddress 'sys-glGetShaderInfoLog !
	"glGetProgramInfoLog" SDL_GL_GetProcAddress 'sys-glGetProgramInfoLog !
	"glGetAttribLocation" SDL_GL_GetProcAddress 'sys-glGetAttribLocation !
	"glEnableVertexAttribArray" SDL_GL_GetProcAddress 'sys-glEnableVertexAttribArray !
	"glUniform1i" SDL_GL_GetProcAddress 'sys-glUniform1i !
	"glGetUniformLocation" SDL_GL_GetProcAddress 'sys-glGetUniformLocation !
	"glUniform1iv" SDL_GL_GetProcAddress 'sys-glUniform1iv !
	"glUniform2iv" SDL_GL_GetProcAddress 'sys-glUniform2iv !
	"glUniform3iv" SDL_GL_GetProcAddress 'sys-glUniform3iv !
	"glUniform4iv" SDL_GL_GetProcAddress 'sys-glUniform4iv !
	"glUniform1fv" SDL_GL_GetProcAddress 'sys-glUniform1fv !
	"glUniform2fv" SDL_GL_GetProcAddress 'sys-glUniform2fv !
	"glUniform3fv" SDL_GL_GetProcAddress 'sys-glUniform3fv !
	"glUniform4fv" SDL_GL_GetProcAddress 'sys-glUniform4fv !
	"glUniformMatrix4fv" SDL_GL_GetProcAddress 'sys-glUniformMatrix4fv !
	"glVertexAttrib1fv" SDL_GL_GetProcAddress 'sys-glVertexAttrib1fv !
	"glVertexAttrib2fv" SDL_GL_GetProcAddress 'sys-glVertexAttrib2fv !
	"glVertexAttrib3fv" SDL_GL_GetProcAddress 'sys-glVertexAttrib3fv !
	"glVertexAttrib4fv" SDL_GL_GetProcAddress 'sys-glVertexAttrib4fv !
	"glVertexAttribDivisor" SDL_GL_GetProcAddress 'sys-glVertexAttribDivisor !
	"glBindAttribLocation" SDL_GL_GetProcAddress 'sys-glBindAttribLocation !
	"glClearColor" SDL_GL_GetProcAddress 'sys-glClearColor !
	"glDisableVertexAttribArray" SDL_GL_GetProcAddress 'sys-glDisableVertexAttribArray !
	"glIsProgram" SDL_GL_GetProcAddress 'sys-glIsProgram !
	"glIsShader" SDL_GL_GetProcAddress 'sys-glIsShader !
	"glBindFragDataLocation" SDL_GL_GetProcAddress 'sys-glBindFragDataLocation !
	"glActiveTexture" SDL_GL_GetProcAddress 'sys-glActiveTexture !

	"glDeleteTexturesEXT" SDL_GL_GetProcAddress 'sys-glDeleteTextures !

	"glVertexPointer" SDL_GL_GetProcAddress 'sys-glVertexPointer !

	"glDrawArrays" SDL_GL_GetProcAddress 'sys-glDrawArrays !
	"glClear" SDL_GL_GetProcAddress 'sys-glClear !
	"glDrawElements" SDL_GL_GetProcAddress 'sys-glDrawElements !	
	"glDrawElementsInstanced" SDL_GL_GetProcAddress 'sys-glDrawElementsInstanced !
|	"glDrawRangeElements" SDL_GL_GetProcAddress 'sys-glDrawRangeElements !
	"glGenTextures" SDL_GL_GetProcAddress 'sys-glGenTextures !
	"glBindTexture" SDL_GL_GetProcAddress 'sys-glBindTexture !
	"glTexImage2D" SDL_GL_GetProcAddress 'sys-glTexImage2D !	
	
	"glTexParameteri" SDL_GL_GetProcAddress 'sys-glTexParameteri !
	"glTexSubImage2D" SDL_GL_GetProcAddress 'sys-glTexSubImage2D !
	"glEnable" SDL_GL_GetProcAddress 'sys-glEnable !	
	"glDisable" SDL_GL_GetProcAddress 'sys-glDisable !	
	"glBlendFunc" SDL_GL_GetProcAddress 'sys-glBlendFunc !	
	"glViewport" SDL_GL_GetProcAddress 'sys-glViewport !
	"glDepthFunc" SDL_GL_GetProcAddress 'sys-glDepthFunc !
	
| Shader
	"glCreateShader" SDL_GL_GetProcAddress 'sys-glCreateShader !
	"glDeleteShader" SDL_GL_GetProcAddress 'sys-glDeleteShader !
	"glShaderSource" SDL_GL_GetProcAddress 'sys-glShaderSource !
	"glCompileShader" SDL_GL_GetProcAddress 'sys-glCompileShader !
	"glGetShaderiv" SDL_GL_GetProcAddress 'sys-glGetShaderiv !

| VBO
	"glGenBuffers" SDL_GL_GetProcAddress 'sys-glGenBuffers !
	"glBindBuffer" SDL_GL_GetProcAddress 'sys-glBindBuffer !
	"glBindRenderbuffer" SDL_GL_GetProcAddress 'sys-glBindRenderbuffer !
	"glBufferData" SDL_GL_GetProcAddress 'sys-glBufferData !
	"glVertexAttribPointer" SDL_GL_GetProcAddress 'sys-glVertexAttribPointer !
	"glVertexAttribIPointer" SDL_GL_GetProcAddress 'sys-glVertexAttribIPointer !	
	"glMapBuffer" SDL_GL_GetProcAddress 'sys-glMapBuffer !
	"glUnmapBuffer" SDL_GL_GetProcAddress 'sys-glUnmapBuffer !
	
	
	"glGenVertexArrays" SDL_GL_GetProcAddress 'sys-glGenVertexArrays !
	"glBindVertexArray" SDL_GL_GetProcAddress 'sys-glBindVertexArray !
	"glDeleteBuffers" SDL_GL_GetProcAddress 'sys-glDeleteBuffers !
	"glDeleteVertexArrays" SDL_GL_GetProcAddress 'sys-glDeleteVertexArrays !	
	
| old
	"glBegin" SDL_GL_GetProcAddress 'sys-glBegin !
	"glEnd" SDL_GL_GetProcAddress 'sys-glEnd !
	"glColor4ubv" SDL_GL_GetProcAddress 'sys-glColor4ubv !
	"glVertex3fv" SDL_GL_GetProcAddress 'sys-glVertex3fv !
	"glTexCoord2fv" SDL_GL_GetProcAddress 'sys-glTexCoord2fv !
	"glVertex2fv" SDL_GL_GetProcAddress 'sys-glVertex2fv !
	
	"glGenFramebuffers" SDL_GL_GetProcAddress 'sys-glGenFramebuffers !
	"glTexParameterfv" SDL_GL_GetProcAddress 'sys-glTexParameterfv !
	"glBindFramebuffer" SDL_GL_GetProcAddress 'sys-glBindFramebuffer !
	"glFramebufferTexture2D" SDL_GL_GetProcAddress 'sys-glFramebufferTexture2D !

	"glDrawBuffer" SDL_GL_GetProcAddress 'sys-glDrawBuffer !
	"glReadBuffer" SDL_GL_GetProcAddress 'sys-glReadBuffer !
	"glPixelStorei" SDL_GL_GetProcAddress 'sys-glPixelStorei !
	"glRenderbufferStorage" SDL_GL_GetProcAddress 'sys-glRenderbufferStorage !
	"glFramebufferRenderbuffer" SDL_GL_GetProcAddress 'sys-glFramebufferRenderbuffer !

	"glGenRenderbuffers" SDL_GL_GetProcAddress 'sys-glGenRenderbuffers !
	"glGenTextures" SDL_GL_GetProcAddress 'sys-glGenTextures !
	
|	0 'sys-glCreateProgram  ( 'sys-glBindAttribLocation  <=? @+ pick2 "%d %h " .print swap 1 + swap ) 2drop
	;
	
#SDL_context

::SDLinitGL | "titulo" w h --
	5 1 SDL_GL_SetAttribute		|SDL_GL_DOUBLEBUFFER, 1);
	13 1 SDL_GL_SetAttribute	|SDL_GL_MULTISAMPLEBUFFERS, 1);
	14 8 SDL_GL_SetAttribute	|SDL_GL_MULTISAMPLESAMPLES, 8);
    17 4 SDL_GL_SetAttribute |SDL_GL_CONTEXT_MAJOR_VERSION
    18 6 SDL_GL_SetAttribute |SDL_GL_CONTEXT_MINOR_VERSION
	20 2 SDL_GL_SetAttribute |SDL_GL_CONTEXT_FLAGS, SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG);	
	21 2 SDL_GL_SetAttribute |SDL_GL_CONTEXT_PROFILE_MASK,  SDL_GL_CONTEXT_PROFILE_COMPATIBILITY
|	SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);
|	"SDL_RENDER_SCALE_QUALITY" "1" SDL_SetHint	
	'sh ! 'sw !
	$3231 SDL_init 
	$1FFF0000 dup sw sh $6 SDL_CreateWindow 'SDL_windows ! 
	SDL_windows SDL_GL_CreateContext 'SDL_context !
	1 SDL_GL_SetSwapInterval	

	InitGLAPI
	;

::SDLGLcls
	$4100 glClear | color+depth
	;

::SDLGLupdate
	SDL_windows SDL_GL_SwapWindow ;
	
::SDLquit
	SDL_context SDL_Gl_DeleteContext
	SDL_windows SDL_DestroyWindow 
	SDL_Quit ;		
	
|----------------------------------------
| print info from GPU
::glInfo
	$1f00 glGetString .println | vendor
	$1f01 glGetString .println | render
	$1f02 glGetString .println | version
	$8B8C glGetString .println | shader
	;	