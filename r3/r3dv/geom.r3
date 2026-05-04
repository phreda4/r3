| PHREDA 2026
^./renderlib.r3

#rl_sh_geom       0

#rl_u_model         -1
#rl_u_uPackColor	-1
#rl_u_normal_matrix -1

#rl_shader_geom "
@vertex-----------------
#version 440 core
layout(location=0) in vec3 aPos;
layout(location=1) in vec3 aNormal;
layout(std140, binding=0) uniform Matrices {
    mat4 view; mat4 proj; mat4 invView; mat4 invProj; mat4 ProjView; vec4 viewPos;  };
uniform mat4 model;
uniform mat3 normalMatrix;
out vec3 vPos; out vec3 vNormal;
void main(){
    vec4 wp = model*vec4(aPos,1.0);
    vPos = wp.xyz;
    vNormal = normalMatrix*aNormal;
    gl_Position = ProjView*wp;
}
@fragment---------------
#version 440 core
in vec3 vPos; in vec3 vNormal;
uniform uint uPackColor;
layout(location=0) out vec3 gNormal;
layout(location=1) out vec4 gAlbedo;
void main(){
	gNormal = normalize(vNormal);
	gAlbedo = vec4(float((uPackColor>>24)&0xFFu),
		float((uPackColor>>16)&0xFFu),
		float((uPackColor>> 8)&0xFFu),
		float( uPackColor     &0xFFu))/ 255.0;
}
@-----------------------"


| 24 vertices (4 por cara x 6 caras) con pos, normal
#verts [
-0.5  -0.5  -0.5  0 0 -1.0  0.5  -0.5  -0.5  0 0 -1.0 
 0.5   0.5  -0.5  0 0 -1.0 -0.5   0.5  -0.5  0 0 -1.0 
-0.5  -0.5   0.5  0 0  1.0  0.5  -0.5   0.5  0 0  1.0 
 0.5   0.5   0.5  0 0  1.0 -0.5   0.5   0.5  0 0  1.0 
-0.5   0.5   0.5  -1.0 0 0 -0.5   0.5  -0.5  -1.0 0 0 
-0.5  -0.5  -0.5  -1.0 0 0 -0.5  -0.5   0.5  -1.0 0 0 
 0.5   0.5   0.5   1.0 0 0  0.5   0.5  -0.5   1.0 0 0 
 0.5  -0.5  -0.5   1.0 0 0  0.5  -0.5   0.5   1.0 0 0 
-0.5  -0.5  -0.5  0 -1.0 0  0.5  -0.5  -0.5  0 -1.0 0 
 0.5  -0.5   0.5  0 -1.0 0 -0.5  -0.5   0.5  0 -1.0 0 
-0.5   0.5  -0.5  0  1.0 0  0.5   0.5  -0.5  0  1.0 0 
 0.5   0.5   0.5  0  1.0 0 -0.5   0.5   0.5  0  1.0 0 
]

#idx [
 0  2  1  0  3  2   4  5  6  4  6  7   8  9 10  8 10 11 
12 14 13 12 15 14  16 17 18 16 18 19  20 22 21 20 23 22
]

#g_cube_vao #g_cube_vbo #g_cube_ebo

::IniGeom
	'rl_shader_geom       loadShaderv 'rl_sh_geom       !
	
    rl_sh_geom "model"        glGetUniformLocation 'rl_u_model         !
	rl_sh_geom "uPackColor"   glGetUniformLocation 'rl_u_uPackColor !
    rl_sh_geom "normalMatrix" glGetUniformLocation 'rl_u_normal_matrix !
	
    0 rl_sh_geom  "Matrices"     rl_bind_ubo
	
	24 6 * 'verts memfloat

    1 'g_cube_vao glGenVertexArrays
    1 'g_cube_vbo glGenBuffers
    1 'g_cube_ebo glGenBuffers
    g_cube_vao glBindVertexArray
    GL_ARRAY_BUFFER g_cube_vbo glBindBuffer
    GL_ARRAY_BUFFER 24 6 * 4 * 'verts GL_STATIC_DRAW glBufferData
    GL_ELEMENT_ARRAY_BUFFER g_cube_ebo glBindBuffer
    GL_ELEMENT_ARRAY_BUFFER 36 4 * 'idx GL_STATIC_DRAW glBufferData
    0 glEnableVertexAttribArray
    0 3 GL_FLOAT GL_FALSE 6 4 * 0 glVertexAttribPointer
    1 glEnableVertexAttribArray
    1 3 GL_FLOAT GL_FALSE 6 4 * 3 4 * glVertexAttribPointer
    0 glBindVertexArray
	;
	
::endGeom
    rl_sh_geom       glDeleteProgram
	
	1 'g_cube_vao glDeleteVertexArrays
	1 'g_cube_vbo glDeleteBuffers
	1 'g_cube_ebo glDeleteBuffers
	;
	
::rl_ProgGeom
	rl_sh_geom glUseProgram ;

::rl_setcolor | rgbmm --
	rl_u_uPackColor swap glUniform1ui ;

::rl_geomat	| normal model --
	>r rl_u_model 1 GL_FALSE r> glUniformMatrix4fv
	>r rl_u_normal_matrix 1 GL_FALSE r> glUniformMatrix3fv 
	;
	
#fmodel * 64 | mat4x4
#fnormal * 36 | mat3x3	

::draw_cube 
	'fmodel 'mat cpymatif
	matinv
	'fnormal 'mati cpymatif3
	'fnormal 'fmodel rl_geomat	
	g_cube_vao glBindVertexArray
    GL_TRIANGLES 36 GL_UNSIGNED_INT 0 glDrawElements
	;
