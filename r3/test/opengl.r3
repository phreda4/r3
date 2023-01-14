^r3/win/core.r3

^r3/win/glfw3.r3
^r3/win/glew.r3

#window

#vertex_buffer
#vertex_shader
#fragment_shader
#program
#mvp_location
#vpos_location
#vcol_location
	
#vertex_shader_text 
"#version 110
uniform mat4 MVP;
attribute vec3 vCol;
attribute vec2 vPos;
varying vec3 color;
void main()
{
    gl_Position = MVP * vec4(vPos, 0.0, 1.0);
    color = vCol;
}"
 
#fragment_shader_text 
"#version 110
varying vec3 color;
void main()
{
    gl_FragColor = vec4(color, 1.0);
}"

#vertices
[ 0 0 0 0 0 ]
[ 0 0 0 0 0 ]
[ 0 0 0 0 0 ]

:vert!
	'vertices >a
	-0.6 f2fp da!+ -0.4 f2fp da!+ 1.0 f2fp da!+ 0.0 f2fp da!+ 0.0 f2fp da!+ 
    0.6 f2fp da!+ -0.4 f2fp da!+ 0.0 f2fp da!+ 1.0 f2fp da!+ 0.0 f2fp da!+ 
    0.0 f2fp da!+  0.6 f2fp da!+ 0.0 f2fp da!+ 0.0 f2fp da!+ 1.0 f2fp da!+ 
	;
	
|----------------------------

#GL_COLOR_BUFFER_BIT $00004000
#GL_FRAGMENT_SHADER $8B30
#GL_VERTEX_SHADER $8B31
#GL_ARRAY_BUFFER $8892
#GL_STATIC_DRAW $88E4
#GL_FLOAT $1406
#GL_FALSE 0

#VertexArrayID

|----------------------------
:
vert!

glfwInit drop

$2100D 4 glfwWindowHint |(GLFW_SAMPLES, 4);
$22002 3 glfwWindowHint |(GLFW_CONTEXT_VERSION_MAJOR, 3);
$22003 3 glfwWindowHint |(GLFW_CONTEXT_VERSION_MINOR, 3);
	
640 480 "Simple example" 0 0 glfwCreateWindow 'window !
window glfwMakeContextCurrent
1 glewExperimental d!
glewInit

|1 'VertexArrayID glGenVertexArrays
|VertexArrayID glBindVertexArray

( window glfwWindowShouldClose 0? drop

	GL_COLOR_BUFFER_BIT glClear
	
	window glfwSwapBuffers
	glfwPollEvents
	) drop

window glfwDestroyWindow
glfwTerminate
;