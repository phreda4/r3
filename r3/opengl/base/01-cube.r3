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
#pTo 0 0 0
#pUp 0 1.0 0
	
#fmodel * 64
#fmvp * 64
	
:update
|        float asp = (vp_h > 0) ? (float)vp_w / (float)vp_h : 1.f;
|        float ex = cosf(cam_yaw) * cosf(cam_pit) * cam_dist;
|        float ey = sinf(cam_pit) * cam_dist;
|        float ez = sinf(cam_yaw) * cosf(cam_pit) * cam_dist;


	matini
	cube_rot 0.4 *. mrotx 
	cube_rot mroty 
	m* | rotx*roty
	'fmodel mcpyf | >>MODEL
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
	rendercube
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
	GL_CULL_FACE glEnable	
	GL_LESS glDepthFunc 
	
	$1c1c1c GLpaper
	
	'shader loadShaderv 'prog ! | "fragment" "vertex" -- idprogram
	initcube
	prog "uMVP" glGetUniformLocation 'loc_mvp !
	prog "uModel" glGetUniformLocation 'loc_model !

	
	'main SDLshow
	GLend
	;