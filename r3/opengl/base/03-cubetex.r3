| opengl cube with per-face SDF raymarching
| PHREDA 2026

^r3/lib/sdl2.r3
^r3/lib/sdl2gl.r3
^r3/lib/glutil.r3
^r3/lib/3dgl.r3

#shader "
@vertex-----------------
#version 440 core
layout(location=0) in vec3 aPos;
layout(location=1) in vec3 aNrm;
layout(location=2) in vec2 aTexCoord;
uniform mat4 uMVP;
uniform mat4 uModel;
out vec3 vNrm;
out vec3 vWPos;
out vec2 vTexCoord;
void main(){
	vNrm  = mat3(uModel) * aNrm;
	vWPos = vec3(uModel * vec4(aPos,1.0));
	vTexCoord = aTexCoord;
	gl_Position = uMVP * vec4(aPos,1.0);
}
@fragment---------------
#version 440 core
in vec3 vNrm;
in vec3 vWPos;
in vec2 vTexCoord;
uniform sampler2D uTex;
out vec4 fc;
void main(){
	vec3 n    = normalize(vNrm);
	vec3 L    = normalize(vec3(0.6, 1.0, 0.5));
	float diff = max(dot(n, L), 0.0);
	vec3 col  = texture(uTex, vTexCoord).rgb;
	vec3 lit  = col * (0.18 + diff * 0.82);
	fc = vec4(pow(lit, vec3(1.0/2.2)), 1.0);
}
@-----------------------"

| 24 vertices (4 por cara x 6 caras) con pos, normal, UV */
#verts [
-1.0 -1.0  1.0   0 0 1.0   0 0    1.0 -1.0  1.0   0 0 1.0   1.0 0    1.0  1.0  1.0   0 0 1.0   1.0 1.0   -1.0  1.0  1.0   0 0 1.0   0 1.0 
1.0 -1.0 -1.0   0 0 -1.0  1.0 0   -1.0 -1.0 -1.0   0 0 -1.0  0 0   -1.0  1.0 -1.0   0 0 -1.0  0 1.0    1.0  1.0 -1.0   0 0 -1.0  1.0 1.0 
1.0 -1.0  1.0   1.0 0 0   0 0    1.0 -1.0 -1.0   1.0 0 0   1.0 0    1.0  1.0 -1.0   1.0 0 0   1.0 1.0    1.0  1.0  1.0   1.0 0 0   0 1.0 
-1.0 -1.0 -1.0  -1.0 0 0   0 0   -1.0 -1.0  1.0  -1.0 0 0   1.0 0   -1.0  1.0  1.0  -1.0 0 0   1.0 1.0   -1.0  1.0 -1.0  -1.0 0 0   0 1.0 
-1.0  1.0  1.0   0 1.0 0   0 0    1.0  1.0  1.0   0 1.0 0   1.0 0    1.0  1.0 -1.0   0 1.0 0   1.0 1.0   -1.0  1.0 -1.0   0 1.0 0   0 1.0 
-1.0 -1.0 -1.0   0 -1.0 0  0 0    1.0 -1.0 -1.0   0 -1.0 0  1.0 0    1.0 -1.0  1.0   0 -1.0 0  1.0 1.0   -1.0 -1.0  1.0   0 -1.0 0  0 1.0 
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
    24 8 * 'verts memfloat
    1 'g_vbo glGenBuffers
    GL_ARRAY_BUFFER g_vbo glBindBuffer
    GL_ARRAY_BUFFER 24 8 * 4 * 'verts GL_STATIC_DRAW glBufferData
    1 'g_ebo glGenBuffers
    GL_ELEMENT_ARRAY_BUFFER g_ebo glBindBuffer
    GL_ELEMENT_ARRAY_BUFFER 36 4 * 'idx GL_STATIC_DRAW glBufferData
    0 glEnableVertexAttribArray
    0 3 GL_FLOAT GL_FALSE 8 4 * 0 glVertexAttribPointer
    1 glEnableVertexAttribArray
    1 3 GL_FLOAT GL_FALSE 8 4 * 3 4 * glVertexAttribPointer
    2 glEnableVertexAttribArray
    2 2 GL_FLOAT GL_FALSE 8 4 * 6 4 * glVertexAttribPointer
    0 glBindVertexArray
	;

	
#prog
#texture

#loc_mvp
#loc_model
#loc_tex

#vp_w 900
#vp_h 600
#vp_asp 

| Camera controls
#cam_yaw  -0.785398   | -PI/4
#cam_pit   0.45
#cam_dist  4.5
#cam_drag  0

| Cube rotation
#cube_rot  0.0
#spinning  -1

#pEye 0.0 0.0 4.5
#fpEye [ 0 0 0 ]

#pTo 0 0 0.0
#pUp 0 1.0 0

	
| Float matrices
#fmodel * 64
#fmvp   * 64

| Mouse state
#mouse_x   0
#mouse_y   0
#mouse_btn 0

:viewresize
    0 0 vp_w vp_h glViewport
	vp_h vp_w /. 'vp_asp !
	;

#xp #yp 
:movecam
	sdlx dup xp - 0.002 * 'cam_yaw +! 'xp !
	sdly dup yp - neg 0.002 * 
	cam_pit + 0.2 min -0.2 max 'cam_pit ! 
	'yp !
:calcam
	'pEye >a
	cam_yaw cos cam_pit cos *. cam_dist *. a!+ | ex
	cam_pit sin cam_dist *. a!+
	cam_yaw sin cam_pit cos *. cam_dist *. a!
	3 'pEye 'fpEye mem2float
	;
:wheelcam
	SDLw 0? ( drop ; ) neg
	0.2 * 'cam_dist +!
	calcam
	;
	
	
:update
    spinning 1? ( 0.004 'cube_rot +! ) drop
	matini
	cube_rot dup 0.2 *. 0 mrot
	'fmodel mcpyf | >>MODEL
	'pEye 'pTo 'pUp mview
	0.05 100.0 | near far
	0.8 |FOV
	vp_asp | aspect
	mproj
	'fmvp mcpyf	 | >>MVP

	;

:draw
	prog glUseProgram
	loc_mvp   1 GL_FALSE 'fmvp glUniformMatrix4fv
	loc_model 1 GL_FALSE 'fmodel glUniformMatrix4fv
	loc_tex 0 glUniform1i
	GL_TEXTURE0 glActiveTexture
	GL_TEXTURE_2D texture glBindTexture
    g_vao glBindVertexArray
    GL_TRIANGLES 36 GL_UNSIGNED_INT 0 glDrawElements
	;

:main
	GLcls
    update
    draw
    GLUpdate
	
	immIni
	immMouse
	1 =? ( wheelcam ) | over
	3 =? ( movecam ) | active
	drop	
	
    sdlkey
	>esc< =? ( exit )
	<esp> =? ( spinning not 'spinning ! )
    drop
	;

| Boot
:
    "cube texture" 900 600 GLini
    GLInfo
	
    build_cube
	'shader loadShaderv 'prog !
    prog "uMVP"    glGetUniformLocation 'loc_mvp   !
    prog "uModel"  glGetUniformLocation 'loc_model !
    prog "uTex" glGetUniformLocation 'loc_tex !
	
	"media/img/wood.jpg" glImgTex 'texture !
	viewresize | Viewport dimensions
	calcam
	
    | Clear and draw
    GL_DEPTH_TEST glEnable
    GL_LESS glDepthFunc
    $1e1f23 GLpaper

    'main SDLshow

    1 'g_vao glDeleteVertexArrays
    1 'g_vbo glDeleteBuffers
    1 'g_ebo glDeleteBuffers
    prog glDeleteProgram
    GLend
;