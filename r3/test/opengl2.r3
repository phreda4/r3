^r3/win/core.r3
^r3/win/glfw3.r3

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

#ws #hs
|----------------------------
:
vert!
glfwInit drop
640 480 "Simple example" 0 0 glfwCreateWindow 'window !
window glfwMakeContextCurrent
1 glfwSwapInterval


	1 'vertex_buffer glGenBuffers
	GL_ARRAY_BUFFER vertex_buffer glBindBuffer
	
    GL_ARRAY_BUFFER 15 4 << 'vertices GL_STATIC_DRAW glBufferData 
 
    GL_VERTEX_SHADER glCreateShader 'vertex_shader !
    vertex_shader 1 'vertex_shader_text 0 glShaderSource
    vertex_shader glCompileShader
 
    GL_FRAGMENT_SHADER glCreateShader 'fragment_shader !
    fragment_shader 1 'fragment_shader_text 0 glShaderSource
    fragment_shader glCompileShader
 
    glCreateProgram 'program !
    program vertex_shader glAttachShader
    program fragment_shader glAttachShader
    program glLinkProgram
 
    program "MVP" glGetUniformLocation 'mvp_location !
    program "vPos" glGetAttribLocation 'vpos_location !
    program "vCol" glGetAttribLocation 'vcol_location !
 
    vpos_location glEnableVertexAttribArray
	
	vpos_location 2 GL_FLOAT GL_FALSE 4 0 glVertexAttribPointer
    vcol_location glEnableVertexAttribArray
	vcol_location 3 GL_FLOAT GL_FALSE 4 8 glVertexAttribPointer
	
    window 'ws 'hs glfwGetFramebufferSize
	
	0 0 ws hs glViewport
	GL_COLOR_BUFFER_BIT glClear
	
	window glfwSwapBuffers
	glfwPollEvents

1000 ms

window glfwDestroyWindow
glfwTerminate
;