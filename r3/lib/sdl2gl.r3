| OpenGL Interface for r3forth via SDL2
| PHREDA 2024-2026
^r3/lib/sdl2.r3
^r3/lib/sdl2gl-constv.r3

#SDL_context

| --- System Variable Declarations ---
#sys-glClearBufferfv
#sys-glCreateProgram #sys-glCreateShader #sys-glShaderSource #sys-glCompileShader
#sys-glGetShaderiv #sys-glAttachShader #sys-glGetProgramiv #sys-glGetAttribLocation
#sys-glClearColor #sys-glGenBuffers #sys-glBindBuffer #sys-glBindRenderbuffer
#sys-glBufferData #sys-glBufferSubData #sys-glGetTexImage #sys-glMapBuffer
#sys-glUnmapBuffer #sys-glGetUniformBlockIndex #sys-glUniformBlockBinding
#sys-glBindBufferBase #sys-glUseProgram #sys-glValidateProgram #sys-glEnableVertexAttribArray
#sys-glVertexAttribPointer #sys-glVertexAttribIPointer #sys-glDisableVertexAttribArray
#sys-glDeleteProgram #sys-glIsProgram #sys-glIsShader #sys-glGenVertexArrays
#sys-glBindVertexArray #sys-glGetShaderInfoLog #sys-glGetProgramInfoLog
#sys-glBindFragDataLocation #sys-glLinkProgram #sys-glActiveTexture #sys-glBindTexture
#sys-glTexImage2D #sys-glUniform1i #sys-glTexParameteri #sys-glTexSubImage2D
#sys-glEnable #sys-glDisable #sys-glDepthFunc #sys-glBlendFunc #sys-glDetachShader
#sys-glDeleteShader #sys-glDeleteTextures #sys-glDeleteBuffers #sys-glDeleteVertexArrays
#sys-glViewport #sys-glScissor #sys-glVertexPointer #sys-glClear #sys-glDrawElements
#sys-glDrawElementsInstanced #sys-glDrawArrays #sys-glDrawArraysInstanced
#sys-glGenTextures #sys-glGetError #sys-glGetString #sys-glBegin #sys-glEnd
#sys-glColor4ubv #sys-glVertex3fv #sys-glTexCoord2fv #sys-glVertex2fv
#sys-glGetUniformLocation #sys-glUniform1iv #sys-glUniform2iv #sys-glUniform3iv
#sys-glUniform4iv #sys-glUniform1fv #sys-glUniform2fv #sys-glUniform3fv
#sys-glUniform4fv #sys-glUniformMatrix4fv #sys-glUniformMatrix3fv
#sys-glVertexAttrib1fv #sys-glVertexAttrib2fv #sys-glVertexAttrib3fv #sys-glVertexAttrib4fv 
#sys-glVertexAttribDivisor #sys-glBindAttribLocation #sys-glGenFramebuffers 
#sys-glTexParameterfv #sys-glBindFramebuffer #sys-glFramebufferTexture2D 
#sys-glDrawBuffer #sys-glReadBuffer #sys-glPixelStorei #sys-glRenderbufferStorage
#sys-glFramebufferRenderbuffer #sys-glGenRenderbuffers #sys-glGenQueries 
#sys-glDeleteQueries #sys-glBeginQuery #sys-glEndQuery #sys-glGetQueryObjectuiv 
#sys-glFenceSync #sys-glClientWaitSync #sys-glDeleteSync #sys-glBufferStorage #sys-glMapBufferRange
#sys-glClearNamedFramebufferfv
#sys-glCreateFramebuffers
#sys-glCreateTextures
#sys-glTextureStorage2D
#sys-glTextureParameteri
#sys-glNamedFramebufferTexture
#sys-glCheckNamedFramebufferStatus
#sys-glNamedFramebufferDrawBuffers
#sys-glCreateVertexArrays
#sys-glCreateBuffers
#sys-glNamedBufferStorage
#sys-glVertexArrayVertexBuffer
#sys-glVertexArrayElementBuffer
#sys-glEnableVertexArrayAttrib
#sys-glVertexArrayAttribFormat
#sys-glVertexArrayAttribBinding
#sys-glBindTextures
#sys-glProgramUniform1i
#sys-glBindBufferRange
#sys-glVertexAttribFormat
#sys-glVertexAttribBinding
#sys-glVertexBindingDivisor
#sys-glColorMask
#sys-glDepthMask
#sys-glCullFace
#sys-glFrontFace
#sys-glBlitFramebuffer
#sys-glDrawBuffers
#sys-glCheckFramebufferStatus
#sys-glDeleteRenderbuffers

|--------------------
|------------------------UI
#id	#idh #ida 	| now hot active
#idf #idfh #idfa | focus
#fx #fy #fw #fh

::immBox | x y w h --
	'fh ! 'fw ! 'fy ! 'fx ! ;	
	
::immFull | --
	0 0 sw sh immBox ;

::immIni
	immFull
	idfh -? ( id nip ) id >? ( 0 nip ) dup 'idf ! 'idfh !
	idh 'ida ! -1 'id ! ;
	
:immIn? | -- 0/-1
	sdlx fx - $ffff and fw >? ( drop 0 ; ) drop
	sdly fy - $ffff and fh >? ( drop 0 ; ) drop 
	-1 ;
	
::immMouse | -- state
	1 'id +! 
	ida -? ( drop 			| no active
		immIn? 0? ( ; ) drop		| out->0
		sdlb 0? ( drop 1 ; ) drop	| over->1
		id dup 'idh ! 'idfh ! 2 ; )	| in->2(prev)
	id <>? ( drop 0 ; ) 	|	 active no this->0
	drop
	immIn? 0? ( drop
		sdlb 1? ( drop 4 ; ) drop	| active out->4
		-1 'idh ! 5 ; ) drop		| out up->5
	sdlb 1? ( drop 3 ; ) drop 		| active->3
	-1 'idh ! 6 ; 					| click->6		


| --- API Wrappers ---
::glClearBufferfv sys-glClearBufferfv sys3 drop ;

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
::glBufferSubData sys-glBufferSubData sys4 drop ;
::glGetTexImage sys-glGetTexImage sys5 drop ;

::glMapBuffer sys-glMapBuffer sys2 ;
::glUnmapBuffer sys-glUnmapBuffer sys1 drop ;
::glGetUniformBlockIndex sys-glGetUniformBlockIndex sys2 ;
::glUniformBlockBinding sys-glUniformBlockBinding sys3 drop ;
::glBindBufferBase sys-glBindBufferBase sys3 drop ;

::glClear sys-glClear sys1 drop ;
::glUseProgram sys-glUseProgram sys1 drop ;
::glValidateProgram sys-glValidateProgram sys1 drop ;
::glEnableVertexAttribArray sys-glEnableVertexAttribArray sys1 drop ;
::glVertexAttribPointer sys-glVertexAttribPointer sys6 drop ;
::glVertexAttribIPointer sys-glVertexAttribIPointer sys5 drop ;
::glDrawElements sys-glDrawElements sys4 drop ;
::glDrawElementsInstanced sys-glDrawElementsInstanced sys5 drop ;
::glDrawArrays sys-glDrawArrays sys3 drop ;
::glDrawArraysInstanced sys-glDrawArraysInstanced sys4 drop ;

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

::glGetError sys-glGetError sys0 ;
::glGetString sys-glGetString sys1 ;
::glViewport sys-glViewport sys4 drop ;
::glScissor sys-glScissor sys4 drop ;
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
::glUniformMatrix3fv sys-glUniformMatrix3fv sys4 drop ;
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

::glGenQueries sys-glGenQueries sys2 drop ;
::glDeleteQueries sys-glDeleteQueries sys2 drop ;
::glBeginQuery sys-glBeginQuery sys2 drop ;
::glEndQuery sys-glEndQuery sys1 drop ;
::glGetQueryObjectuiv sys-glGetQueryObjectuiv sys3 drop ;
::glFenceSync sys-glFenceSync sys2 ;
::glClientWaitSync sys-glClientWaitSync sys4 ;
::glDeleteSync sys-glDeleteSync sys1 drop ;
::glBufferStorage sys-glBufferStorage sys4 drop ;
::glMapBufferRange sys-glMapBufferRange sys4 ;

::glClearNamedFramebufferfv sys-glClearNamedFramebufferfv sys4 drop ;
::glCreateFramebuffers sys-glCreateFramebuffers sys2 drop ;
::glCreateTextures sys-glCreateTextures sys3 drop ;
::glTextureStorage2D sys-glTextureStorage2D sys5 drop ;
::glTextureParameteri sys-glTextureParameteri sys4 drop ;
::glNamedFramebufferTexture sys-glNamedFramebufferTexture sys4 drop ;
::glCheckNamedFramebufferStatus sys-glCheckNamedFramebufferStatus sys2 ;
::glNamedFramebufferDrawBuffers sys-glNamedFramebufferDrawBuffers sys3 drop ;
::glCreateVertexArrays sys-glCreateVertexArrays sys2 drop ;
::glCreateBuffers sys-glCreateBuffers sys2 drop ;
::glNamedBufferStorage sys-glNamedBufferStorage sys5 drop ;
::glVertexArrayVertexBuffer sys-glVertexArrayVertexBuffer sys5 drop ;
::glVertexArrayElementBuffer sys-glVertexArrayElementBuffer sys2 drop ;
::glEnableVertexArrayAttrib sys-glEnableVertexArrayAttrib sys2 drop ;
::glVertexArrayAttribFormat sys-glVertexArrayAttribFormat sys6 drop ;
::glVertexArrayAttribBinding sys-glVertexArrayAttribBinding sys3 drop ;
::glBindTextures sys-glBindTextures sys3 drop ;

::glProgramUniform1i sys-glProgramUniform1i sys3 drop ;
::glBindBufferRange sys-glBindBufferRange sys5 drop ;
::glVertexAttribFormat sys-glVertexAttribFormat sys5 drop ;
::glVertexAttribBinding sys-glVertexAttribBinding sys2 drop ;
::glVertexBindingDivisor sys-glVertexBindingDivisor sys2 drop ;
::glColorMask sys-glColorMask sys4 drop ;
::glDepthMask sys-glDepthMask sys1 drop ;
::glCullFace sys-glCullFace sys1 drop ;
::glFrontFace sys-glFrontFace sys1 drop ;
::glBlitFramebuffer sys-glBlitFramebuffer sys10 drop ;
::glDrawBuffers sys-glDrawBuffers sys2 drop ;
::glCheckFramebufferStatus sys-glCheckFramebufferStatus sys1 ;
::glDeleteRenderbuffers sys-glDeleteRenderbuffers sys2 drop ;
| --- API Initialization ---

::InitGLAPI
    0 SDL_GL_LoadLibrary
	"glClearBufferfv" SDL_GL_GetProcAddress 'sys-glClearBufferfv !
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
    "glUniformMatrix3fv" SDL_GL_GetProcAddress 'sys-glUniformMatrix3fv !
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
    "glClear" SDL_GL_GetProcAddress 'sys-glClear !
    "glDrawElements" SDL_GL_GetProcAddress 'sys-glDrawElements !
    "glDrawElementsInstanced" SDL_GL_GetProcAddress 'sys-glDrawElementsInstanced !
    "glDrawArrays" SDL_GL_GetProcAddress 'sys-glDrawArrays !
    "glDrawArraysInstanced" SDL_GL_GetProcAddress 'sys-glDrawArraysInstanced !
    "glGenTextures" SDL_GL_GetProcAddress 'sys-glGenTextures !
    "glBindTexture" SDL_GL_GetProcAddress 'sys-glBindTexture !
    "glTexImage2D" SDL_GL_GetProcAddress 'sys-glTexImage2D !
    "glTexParameteri" SDL_GL_GetProcAddress 'sys-glTexParameteri !
    "glTexSubImage2D" SDL_GL_GetProcAddress 'sys-glTexSubImage2D !
    "glEnable" SDL_GL_GetProcAddress 'sys-glEnable !
    "glDisable" SDL_GL_GetProcAddress 'sys-glDisable !
    "glBlendFunc" SDL_GL_GetProcAddress 'sys-glBlendFunc !
    "glViewport" SDL_GL_GetProcAddress 'sys-glViewport !
    "glScissor" SDL_GL_GetProcAddress 'sys-glScissor !
    "glDepthFunc" SDL_GL_GetProcAddress 'sys-glDepthFunc !
    "glCreateShader" SDL_GL_GetProcAddress 'sys-glCreateShader !
    "glDeleteShader" SDL_GL_GetProcAddress 'sys-glDeleteShader !
    "glShaderSource" SDL_GL_GetProcAddress 'sys-glShaderSource !
    "glCompileShader" SDL_GL_GetProcAddress 'sys-glCompileShader !
    "glGetShaderiv" SDL_GL_GetProcAddress 'sys-glGetShaderiv !
    "glGenBuffers" SDL_GL_GetProcAddress 'sys-glGenBuffers !
    "glBindBuffer" SDL_GL_GetProcAddress 'sys-glBindBuffer !
    "glBindRenderbuffer" SDL_GL_GetProcAddress 'sys-glBindRenderbuffer !
    "glBufferData" SDL_GL_GetProcAddress 'sys-glBufferData !
    "glGetTexImage" SDL_GL_GetProcAddress 'sys-glGetTexImage !
    "glBufferSubData" SDL_GL_GetProcAddress 'sys-glBufferSubData !
    "glVertexAttribPointer" SDL_GL_GetProcAddress 'sys-glVertexAttribPointer !
    "glVertexAttribIPointer" SDL_GL_GetProcAddress 'sys-glVertexAttribIPointer !
    "glMapBuffer" SDL_GL_GetProcAddress 'sys-glMapBuffer !
    "glUnmapBuffer" SDL_GL_GetProcAddress 'sys-glUnmapBuffer !
    "glGetUniformBlockIndex" SDL_GL_GetProcAddress 'sys-glGetUniformBlockIndex !
    "glUniformBlockBinding" SDL_GL_GetProcAddress 'sys-glUniformBlockBinding !
    "glBindBufferBase" SDL_GL_GetProcAddress 'sys-glBindBufferBase !
    "glGenVertexArrays" SDL_GL_GetProcAddress 'sys-glGenVertexArrays !
    "glBindVertexArray" SDL_GL_GetProcAddress 'sys-glBindVertexArray !
    "glDeleteBuffers" SDL_GL_GetProcAddress 'sys-glDeleteBuffers !
    "glDeleteVertexArrays" SDL_GL_GetProcAddress 'sys-glDeleteVertexArrays !
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
    "glGenQueries" SDL_GL_GetProcAddress 'sys-glGenQueries !
    "glDeleteQueries" SDL_GL_GetProcAddress 'sys-glDeleteQueries !
    "glBeginQuery" SDL_GL_GetProcAddress 'sys-glBeginQuery !
    "glEndQuery" SDL_GL_GetProcAddress 'sys-glEndQuery !
    "glGetQueryObjectuiv" SDL_GL_GetProcAddress 'sys-glGetQueryObjectuiv !
    "glFenceSync" SDL_GL_GetProcAddress 'sys-glFenceSync !
    "glClientWaitSync" SDL_GL_GetProcAddress 'sys-glClientWaitSync !
    "glDeleteSync" SDL_GL_GetProcAddress 'sys-glDeleteSync !
    "glBufferStorage" SDL_GL_GetProcAddress 'sys-glBufferStorage !
    "glMapBufferRange" SDL_GL_GetProcAddress 'sys-glMapBufferRange !
    "glClearNamedFramebufferfv" SDL_GL_GetProcAddress 'sys-glClearNamedFramebufferfv !
    "glCreateFramebuffers" SDL_GL_GetProcAddress 'sys-glCreateFramebuffers !
    "glCreateTextures" SDL_GL_GetProcAddress 'sys-glCreateTextures !
    "glTextureStorage2D" SDL_GL_GetProcAddress 'sys-glTextureStorage2D !
    "glTextureParameteri" SDL_GL_GetProcAddress 'sys-glTextureParameteri !
    "glNamedFramebufferTexture" SDL_GL_GetProcAddress 'sys-glNamedFramebufferTexture !
    "glCheckNamedFramebufferStatus" SDL_GL_GetProcAddress 'sys-glCheckNamedFramebufferStatus !
    "glNamedFramebufferDrawBuffers" SDL_GL_GetProcAddress 'sys-glNamedFramebufferDrawBuffers !
    "glCreateVertexArrays" SDL_GL_GetProcAddress 'sys-glCreateVertexArrays !
    "glCreateBuffers" SDL_GL_GetProcAddress 'sys-glCreateBuffers !
    "glNamedBufferStorage" SDL_GL_GetProcAddress 'sys-glNamedBufferStorage !
    "glVertexArrayVertexBuffer" SDL_GL_GetProcAddress 'sys-glVertexArrayVertexBuffer !
    "glVertexArrayElementBuffer" SDL_GL_GetProcAddress 'sys-glVertexArrayElementBuffer !
    "glEnableVertexArrayAttrib" SDL_GL_GetProcAddress 'sys-glEnableVertexArrayAttrib !
    "glVertexArrayAttribFormat" SDL_GL_GetProcAddress 'sys-glVertexArrayAttribFormat !
    "glVertexArrayAttribBinding" SDL_GL_GetProcAddress 'sys-glVertexArrayAttribBinding !
    "glBindTextures" SDL_GL_GetProcAddress 'sys-glBindTextures !
	
    "glProgramUniform1i" SDL_GL_GetProcAddress 'sys-glProgramUniform1i !
    "glBindBufferRange" SDL_GL_GetProcAddress 'sys-glBindBufferRange !
    "glVertexAttribFormat" SDL_GL_GetProcAddress 'sys-glVertexAttribFormat !
    "glVertexAttribBinding" SDL_GL_GetProcAddress 'sys-glVertexAttribBinding !
    "glVertexBindingDivisor" SDL_GL_GetProcAddress 'sys-glVertexBindingDivisor !
    "glColorMask" SDL_GL_GetProcAddress 'sys-glColorMask !
    "glDepthMask" SDL_GL_GetProcAddress 'sys-glDepthMask !
    "glCullFace" SDL_GL_GetProcAddress 'sys-glCullFace !
    "glFrontFace" SDL_GL_GetProcAddress 'sys-glFrontFace !
    "glBlitFramebuffer" SDL_GL_GetProcAddress 'sys-glBlitFramebuffer !
    "glDrawBuffers" SDL_GL_GetProcAddress 'sys-glDrawBuffers !
    "glCheckFramebufferStatus" SDL_GL_GetProcAddress 'sys-glCheckFramebufferStatus !
    "glDeleteRenderbuffers" SDL_GL_GetProcAddress 'sys-glDeleteRenderbuffers !
    ;

| --- SDL2 Context and Initialization ---

::SDLinitGL | "title" w h --
    5 1 SDL_GL_SetAttribute
    13 1 SDL_GL_SetAttribute
    14 8 SDL_GL_SetAttribute
    17 4 SDL_GL_SetAttribute
    18 6 SDL_GL_SetAttribute
    20 2 SDL_GL_SetAttribute
    21 2 SDL_GL_SetAttribute
    'sh ! 'sw !
    $3231 SDL_init
    $1FFF0000 dup sw sh $6 SDL_CreateWindow 'SDL_windows !
    SDL_windows SDL_GL_CreateContext 'SDL_context !
    1 SDL_GL_SetSwapInterval
    InitGLAPI
    ;

::SDLinitSGL | "title" w h --
    5 1 SDL_GL_SetAttribute
    13 1 SDL_GL_SetAttribute
    14 8 SDL_GL_SetAttribute
    17 4 SDL_GL_SetAttribute
    18 6 SDL_GL_SetAttribute
    20 2 SDL_GL_SetAttribute
    21 2 SDL_GL_SetAttribute
    'sh ! 'sw !
    $3231 SDL_init
    $1FFF0000 dup sw sh $6 SDL_CreateWindow dup 'SDL_windows !
    dup SDL_GL_CreateContext 'SDL_context !
    1 SDL_GL_SetSwapInterval
    dup -1 0 SDL_CreateRenderer 'SDLrenderer !
    SDL_RaiseWindow
    InitGLAPI
    ;

::SDLGLcls
    $4100 glClear
    ;

::SDLGLupdate
    SDL_windows SDL_GL_SwapWindow ;

::glInfo
    $1f00 glGetString .println
    $1f01 glGetString .println
    $1f02 glGetString .println
    $8B8C glGetString .println
    ;
	
:SDL_GL_CONTEXT_MAJOR_VERSION	17 ;
:SDL_GL_CONTEXT_MINOR_VERSION	18 ;
:SDL_GL_CONTEXT_PROFILE_MASK	21 ;
:SDL_GL_CONTEXT_PROFILE_CORE	1 ;
:SDL_GL_DOUBLEBUFFER	5 ;
:SDL_GL_DEPTH_SIZE	6 ;
	
#colorgl [ 0 0 0 1.0 ]
#basegl [ 1.0 ]


::memfloat | cnt adr --
	>a ( 1? 1- da@ f2fp da!+ ) drop ;
	
::mem2float | cnt src dst --
	>b >a ( 1? 1- a@ f2fp db!+ ) drop ;

::memd2float | cnt src dst --
	>b >a ( 1? 1- da@ f2fp db!+ ) drop ;
	
::GLpaper | $ffffff --
	'colorgl >a
	dup 16 >> $ff and 1.0 8 *>> da!+
	dup 8 >> $ff and 1.0 8 *>> da!+
	$ff and 1.0 8 *>> da!
	4 'colorgl memfloat ;
	
::GLcls
	$1800 0 'colorgl glClearBufferfv | GL_COLOR
	$1801 0 'basegl glClearBufferfv | GL_DEPTH
	;
	
::GLIni | w h --
	'sh ! 'sw !
    $3231 SDL_init
    SDL_GL_CONTEXT_MAJOR_VERSION 4 SDL_GL_SetAttribute
    SDL_GL_CONTEXT_MINOR_VERSION 4 SDL_GL_SetAttribute
    SDL_GL_CONTEXT_PROFILE_MASK SDL_GL_CONTEXT_PROFILE_CORE SDL_GL_SetAttribute
    SDL_GL_DOUBLEBUFFER 1 SDL_GL_SetAttribute
    SDL_GL_DEPTH_SIZE 24 SDL_GL_SetAttribute
    $1FFF0000 dup sw sh $22 SDL_CreateWindow 'SDL_windows !
    SDL_windows SDL_GL_CreateContext 'SDL_context !
    1 SDL_GL_SetSwapInterval
    InitGLAPI
	5 'colorgl memfloat
	;
	
::GLend
    SDL_context SDL_Gl_DeleteContext
    SDL_windows SDL_DestroyWindow
    SDL_Quit ;
	
::GLUpdate
   SDL_windows SDL_GL_SwapWindow ;
