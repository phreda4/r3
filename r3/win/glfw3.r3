| glfw3.dll
|
^r3/win/console.r3

#sys-glfwInit
#sys-glfwWindowHint
#sys-glfwCreateWindow
#sys-glfwTerminate
#sys-glfwMakeContextCurrent
#sys-gladLoadGL
#sys-glfwSwapInterval
#sys-glGenBuffers
#sys-glBindBuffer
#sys-glBufferData
#sys-glCreateShader
#sys-glShaderSource
#sys-glCompileShader
#sys-glCreateProgram
#sys-glAttachShader
#sys-glLinkProgram
#sys-glGetUniformLocation
#sys-glGetAttribLocation
#sys-glEnableVertexAttribArray
#sys-glVertexAttribPointer
#sys-glfwWindowShouldClose
#sys-glfwGetFramebufferSize
#sys-glViewport
#sys-glClear
#sys-glUseProgram
#sys-glUniformMatrix4fv
#sys-glDrawArrays
#sys-glfwSwapBuffers
#sys-glfwPollEvents
#sys-glfwDestroyWindow

#sys-glfwSetErrorCallback
#sys-glfwSetKeyCallback


::glfwInit sys-glfwInit sys0 ;
::glfwWindowHint sys-glfwWindowHint sys2 drop ;
::glfwCreateWindow sys-glfwCreateWindow sys5 ;
::glfwTerminate sys-glfwTerminate sys0 drop ;
::glfwMakeContextCurrent sys-glfwMakeContextCurrent sys1 drop ;
::gladLoadGL sys-gladLoadGL sys1 drop ;
::glfwSwapInterval sys-glfwSwapInterval sys1 drop ;
::glGenBuffers sys-glGenBuffers sys2 drop ;
::glBindBuffer sys-glBindBuffer sys2 drop ;
::glBufferData sys-glBufferData sys4 drop ;
::glCreateShader sys-glCreateShader sys1 ;
::glShaderSource sys-glShaderSource sys4 drop ;
::glCompileShader sys-glCompileShader sys1 drop ;
::glCreateProgram sys-glCreateProgram sys0 ;
::glAttachShader sys-glAttachShader sys2 drop ;
::glLinkProgram sys-glLinkProgram sys1 drop ;
::glGetUniformLocation sys-glGetUniformLocation sys2 ;
::glGetAttribLocation sys-glGetAttribLocation sys2 ;
::glEnableVertexAttribArray sys-glEnableVertexAttribArray sys1 drop ;
::glVertexAttribPointer sys-glVertexAttribPointer sys6 drop ;
::glfwWindowShouldClose sys-glfwWindowShouldClose sys1 ;
::glfwGetFramebufferSize sys-glfwGetFramebufferSize sys3 drop ;
::glViewport sys-glViewport sys4 drop ;
::glClear sys-glClear sys1 drop ;
::glUseProgram sys-glUseProgram sys1 drop ;
::glUniformMatrix4fv sys-glUniformMatrix4fv  sys4 drop ;
::glDrawArrays sys-glDrawArrays sys3 drop ;
::glfwSwapBuffers sys-glfwSwapBuffers sys1 drop ;
::glfwPollEvents sys-glfwPollEvents sys0 drop ;
::glfwDestroyWindow sys-glfwDestroyWindow sys1 drop ;

::glfwSetErrorCallback sys-glfwSetErrorCallback sys1 drop ;
::glfwSetKeyCallback sys-glfwSetKeyCallback sys2 drop ;

|----- BOOT
:
	"glfw3.DLL" loadlib
	dup "glfwInit" getproc 'sys-glfwInit ! 
	dup "glfwWindowHint" getproc 'sys-glfwWindowHint !
	dup "glfwCreateWindow" getproc 'sys-glfwCreateWindow !
	dup "glfwTerminate" getproc 'sys-glfwTerminate !
	dup "glfwMakeContextCurrent" getproc 'sys-glfwMakeContextCurrent !

	dup "glfwSwapInterval" getproc 'sys-glfwSwapInterval !

	dup "glBufferData" getproc 'sys-glBufferData !
	dup "glCreateShader" getproc 'sys-glCreateShader !
	dup "glShaderSource" getproc 'sys-glShaderSource !
	dup "glCompileShader" getproc 'sys-glCompileShader !
	dup "glCreateProgram" getproc 'sys-glCreateProgram !
	dup "glAttachShader" getproc 'sys-glAttachShader !
	dup "glLinkProgram" getproc 'sys-glLinkProgram !
	dup "glGetUniformLocation" getproc 'sys-glGetUniformLocation !
	dup "glGetAttribLocation" getproc 'sys-glGetAttribLocation !
	dup "glEnableVertexAttribArray" getproc 'sys-glEnableVertexAttribArray !
	dup "glVertexAttribPointer" getproc 'sys-glVertexAttribPointer !
	dup "glfwWindowShouldClose" getproc 'sys-glfwWindowShouldClose !
	dup "glfwGetFramebufferSize" getproc 'sys-glfwGetFramebufferSize !
	dup "glViewport" getproc 'sys-glViewport !
	dup "glUseProgram" getproc 'sys-glUseProgram !
	dup "glUniformMatrix4fv" getproc 'sys-glUniformMatrix4fv !
	dup "glDrawArrays" getproc 'sys-glDrawArrays !
	dup "glfwSwapBuffers" getproc 'sys-glfwSwapBuffers !
	dup "glfwPollEvents" getproc 'sys-glfwPollEvents !
	dup "glfwDestroyWindow" getproc 'sys-glfwDestroyWindow !

	dup "glfwSetErrorCallback" getproc 'sys-glfwSetErrorCallback !
	dup "glfwSetKeyCallback" getproc 'sys-glfwSetKeyCallback !
	
	drop

	;