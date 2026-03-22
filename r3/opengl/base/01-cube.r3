| opengl cube
| PHREDA 2026

^r3/lib/sdl2.r3
^r3/lib/sdl2gl.r3
^r3/lib/glutil.r3
^r3/lib/3dgl.r3

#prog
#loc_mvp 
#loc_model 

#shader "
@vertex-----------------
#version 440 core
layout(location=0) in vec3 aPos;
layout(location=1) in vec3 aNrm;
uniform mat4 uMVP;
uniform mat4 uModel;
out vec3 vNrm;
out vec3 vWPos;
void main(){
    vNrm  = mat3(uModel) * aNrm;
    vWPos = vec3(uModel * vec4(aPos,1.0));
    gl_Position = uMVP * vec4(aPos,1.0);
}
@fragment---------------
#version 440 core
in vec3 vNrm;
in vec3 vWPos;
out vec4 fc;
void main(){
    vec3 n    = normalize(vNrm);
    vec3 L    = normalize(vec3(0.6, 1.0, 0.5));
    float diff = max(dot(n, L), 0.0);
    vec3 col  = vec3(0.25, 0.55, 1.0);
    vec3 lit  = col * (0.18 + diff * 0.82);
    fc = vec4(pow(lit, vec3(1.0/2.2)), 1.0);
}
@-----------------------"

#verts [
-1.0 -1.0  1.0   0  0  1.0    1.0 -1.0  1.0   0  0  1.0    1.0  1.0  1.0   0  0  1.0   -1.0  1.0  1.0   0  0  1.0 
 1.0 -1.0 -1.0   0  0 -1.0   -1.0 -1.0 -1.0   0  0 -1.0   -1.0  1.0 -1.0   0  0 -1.0    1.0  1.0 -1.0   0  0 -1.0 
 1.0 -1.0  1.0   1.0  0  0    1.0 -1.0 -1.0   1.0  0  0    1.0  1.0 -1.0   1.0  0  0    1.0  1.0  1.0   1.0  0  0 
-1.0 -1.0 -1.0  -1.0  0  0   -1.0 -1.0  1.0  -1.0  0  0   -1.0  1.0  1.0  -1.0  0  0   -1.0  1.0 -1.0  -1.0  0  0 
-1.0  1.0  1.0   0  1.0  0    1.0  1.0  1.0   0  1.0  0    1.0  1.0 -1.0   0  1.0  0   -1.0  1.0 -1.0   0  1.0  0 
-1.0 -1.0 -1.0   0 -1.0  0    1.0 -1.0 -1.0   0 -1.0  0    1.0 -1.0  1.0   0 -1.0  0   -1.0 -1.0  1.0   0 -1.0  0 
]
#idx [
 0  1  2   0  2  3    4  5  6   4  6  7 
 8  9 10   8 10 11   12 13 14  12 14 15 
16 17 18  16 18 19   20 21 22  20 22 23 
]

#g_vao #g_vbo #g_ebo

:build_cube
1 'g_vao glGenVertexArrays
g_vao glBindVertexArray

24 6 * 'verts memfloat
1 'g_vbo glGenBuffers
GL_ARRAY_BUFFER g_vbo glBindBuffer
GL_ARRAY_BUFFER 24 6 * 4 * 'verts GL_STATIC_DRAW glBufferData

1 'g_ebo glGenBuffers
GL_ELEMENT_ARRAY_BUFFER g_ebo glBindBuffer
GL_ELEMENT_ARRAY_BUFFER 36 4 * 'idx GL_STATIC_DRAW glBufferData

0 glEnableVertexAttribArray
0 3 GL_FLOAT GL_FALSE 6 4 * 0 glVertexAttribPointer | pos
1 glEnableVertexAttribArray
1 3 GL_FLOAT GL_FALSE 6 4 * 3 4 * glVertexAttribPointer | normal
0 glBindVertexArray
;


#cam_yaw  0.25
#cam_pit  0.45
#cam_dist 4.5
#cam_drag 0

#cube_rot 0.0
#spinning 1

#flamb * 12
#fldif * 12
#flspe * 12

#pEye 0.0 0.0 4.5
#pTo 0 0 0.0
#pUp 0 1.0 0
	
#fmodel * 64
#fmvp * 64
	
:viewresize
|float asp = (vp_h > 0) ? (float)vp_w / (float)vp_h : 1.f;
|	0 0 800 600 glViewport
	;
	
	
:update
	spinning 1? ( 0.01 'cube_rot +! ) drop
	
	|0.005 'cam_yaw +!
	|0.0025 'cam_pit +!
	
	matini
	
	|cube_rot 0.4 *. mrotx 
	|cube_rot mroty 
	|m* | rotx*roty
	cube_rot 0 over 0.2 *. mrot
	
	'fmodel mcpyf | >>MODEL

	matini
	'pEye >a
	cam_yaw cos cam_pit cos *. cam_dist *. a!+ | ex
	cam_pit sin cam_dist *. a!+
	cam_yaw sin cam_pit cos *. cam_dist *. a!
	
	'pEye 'pTo 'pUp mlookat | VIEW
	m* |( view*model)

	0.05 100.0 | near far
	0.8 |FOV
	3.0 4.0 /. | aspect
	mperspective  | PROJ
	m*			| proj*(view*model)
	
	'fmvp mcpyf	 | >>MVP
|        Mat4 view  = mat4_lookat((Vec3){ex,ey,ez}, (Vec3){0,0,0}, (Vec3){0,1,0});
|        Mat4 proj  = mat4_persp(60.f * (PI/180.f), asp, 0.05f, 100.f);
|        Mat4 model = mat4_mul(mat4_rotate_x(cube_rot * 0.4f), mat4_rotate_y(cube_rot));
|        Mat4 mvp   = mat4_mul(proj, mat4_mul(view, model));
	;
	
:main
	update
	GLcls
	prog glUseProgram
	loc_mvp   1 GL_FALSE 'fmvp glUniformMatrix4fv
	loc_model 1 GL_FALSE 'fmodel glUniformMatrix4fv
	g_vao glBindVertexArray
	GL_TRIANGLES 36 GL_UNSIGNED_INT 0 glDrawElements
	
	GLUpdate
	sdlkey
	>esc< =? ( exit )
	drop
	;

	
|----------- BOOT
:
	"test opengl" 800 600 GLini
	GLInfo
	GL_DEPTH_TEST glEnable 
	GL_LESS glDepthFunc 
	$1c1c1c GLpaper
	'shader loadShaderv 'prog !
	build_cube
	prog "uMVP" glGetUniformLocation 'loc_mvp !
	prog "uModel" glGetUniformLocation 'loc_model !
	0 0 800 600 glViewport
	
	'main SDLshow
	
    1 'g_vao glDeleteVertexArrays
    1 'g_vbo glDeleteBuffers
    1 'g_ebo glDeleteBuffers
    prog glDeleteProgram
	GLend
	;