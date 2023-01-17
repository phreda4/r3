^r3/win/core.r3

^r3/win/glfw3.r3
^r3/win/glew.r3

#window
#vao 
#vbo 
#vs 
#fs

#vertex_shader_text "in vec3 vp;void main() { gl_Position = vec4(vp,1.0); }"
#vht 'vertex_shader_text
 
#fragment_shader_text " void main() { gl_FragColor = vec4(0.5,0.0,0.5,1.0); }"
#fst 'fragment_shader_text 

#sp | shader program

#ss | error compile

#GL_COLOR_BUFFER_BIT $4000
#GL_DEPTH_BUFFER_BIT $100
#GL_FRAGMENT_SHADER $8B30
#GL_VERTEX_SHADER $8B31
#GL_ARRAY_BUFFER $8892
#GL_STATIC_DRAW $88E4
#GL_FLOAT $1406
#GL_FALSE 0
#GL_COMPILE_STATUS $8B81

#GL_TRIANGLES $0004

| data for a fullscreen quad
#vertexData
[ 0 0 0 ]
[ 0 0 0 ]
[ 0 0 0 ]

:fillvertex
	-0.5 f2fp 0.0 f2fp 0.5 f2fp
	'vertexData >a
	pick2 da!+ pick2 da!+ over da!+
	dup da!+ pick2 da!+ over da!+
	over da!+ dup da!+ over da!+
	3drop ;

#log * 512

:glcompst | ss --
	dup GL_COMPILE_STATUS 'ss glGetShaderiv
	ss 1? ( 2drop ; ) drop
	512 0 'log glGetShaderInfoLog
	'log .println ;
	

|----------------------------
:glinit
	fillvertex

glfwInit drop

$2100D 4 glfwWindowHint |(GLFW_SAMPLES, 4);
$22002 3 glfwWindowHint |(GLFW_CONTEXT_VERSION_MAJOR, 3);
$22003 3 glfwWindowHint |(GLFW_CONTEXT_VERSION_MINOR, 3);
	
640 480 "Simple example" 0 0 glfwCreateWindow 'window !
window glfwMakeContextCurrent

	1 glewExperimental d!
	glewInit 	
	
	0 0 800 600 glViewport
	
	|--- info
	"glew " .print
	1 glewGetString .println 
|	2 glewGetString .println 
|	3 glewGetString .println 
|	4 glewGetString .println 
	"OpenGl " .print
	$1f00 glGetString .println | vendor
	$1f01 glGetString .println | render
	$1f02 glGetString .println | version
	$8B8C glGetString .println | shader
	
	1 'vao glGenVertexArrays
	vao glBindVertexArray

	1 'vbo glGenBuffers
	GL_ARRAY_BUFFER vbo glBindBuffer
	
	GL_ARRAY_BUFFER 9 2 << 'vertexData GL_STATIC_DRAW  glBufferData
	0 3 GL_FLOAT GL_FALSE 3 2 << 0 glVertexAttribPointer
	0 glEnableVertexAttribArray

	GL_VERTEX_SHADER glCreateShader 'vs !
	vs 1 'vht 0 glShaderSource
	vs glCompileShader
	
	vs glcompst 
	
	GL_FRAGMENT_SHADER glCreateShader 'fs !
	fs 1 'fst 0 glShaderSource
	fs glCompileShader

	fs glcompst
	
	glCreateProgram 'sp !
	sp fs glAttachShader
	sp vs glAttachShader
	sp glLinkProgram 
	
	vs glDeleteShader
	fs glDeleteShader
	;
		
:glend
	sp glDeleteProgram
	1 'vao glDeleteVertexArrays
	1 'vbo glDeleteBuffers
	;
	
:
glinit
( window glfwWindowShouldClose 0? drop

	GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT or glClear
	sp glUseProgram
	vao glBindVertexArray
	GL_TRIANGLES 0 3 glDrawArrays
	
	window glfwSwapBuffers
	glfwPollEvents
	) drop

window glfwDestroyWindow
glfwTerminate
;