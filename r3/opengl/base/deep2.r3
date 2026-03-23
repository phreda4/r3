| opengl cube with per-face SDF raymarching
| PHREDA 2026

^r3/lib/sdl2.r3
^r3/lib/sdl2gl.r3
^r3/lib/glutil.r3
^r3/lib/3dgl.r3
^r3/lib/math.r3

#shader "
@vertex-----------------
#version 440 core
layout(location=0) in vec3 aPos;
layout(location=1) in vec3 aNrm;
layout(location=2) in vec3 aTan;
uniform mat4 uMVP;
uniform mat4 uModel;
uniform vec3 uCamPos;
out vec3 vWPos;
out vec3 vWNrm;
out vec3 vWTan;
out vec3 vWBit;
out vec3 vRayDir;
void main(){
    vec3 wp = vec3(uModel * vec4(aPos,1.0));
    mat3 M3 = mat3(uModel);
    vWPos   = wp;
    vWNrm   = normalize(M3 * aNrm);
    vWTan   = normalize(M3 * aTan);
    vWBit   = cross(vWNrm, vWTan);
    vRayDir = wp - uCamPos;
    gl_Position = uMVP * vec4(aPos,1.0);
}
@fragment---------------
#version 440 core
in vec3 vWPos;
in vec3 vWNrm;
in vec3 vWTan;
in vec3 vWBit;
in vec3 vRayDir;
uniform vec3  uCamPos;
uniform float uTime;
out vec4 fc;

float sdf(vec3 p){
    float sphere = length(p - vec3(0.0, 0.0, 0.45)) - 0.55;
    vec3  q = abs(p) - vec3(0.95, 0.95, 0.50);
    float box = length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
    return max(sphere, box);
}

vec3 sdf_normal(vec3 p){
    const float e = 0.001;
    return normalize(vec3(
        sdf(p+vec3(e,0,0))-sdf(p-vec3(e,0,0)),
        sdf(p+vec3(0,e,0))-sdf(p-vec3(0,e,0)),
        sdf(p+vec3(0,0,e))-sdf(p-vec3(0,0,e))));
}

void main(){
    vec3 N = normalize(vWNrm);
    vec3 T = normalize(vWTan);
    vec3 B = normalize(vWBit);

    vec3 ro = vec3(dot(vWPos,T), dot(vWPos,B), 1.0);
    vec3 rw = normalize(vRayDir);
    vec3 rd = vec3(dot(rw,T), dot(rw,B), dot(rw,N));

    float t   = 0.0;
    bool  hit = false;
    for(int i=0;i<64;i++){
        vec3  p = ro + rd*t;
        float d = sdf(p);
        if(d < 0.001){ hit=true; break; }
        if(p.z < 0.0 || t > 2.5) break;
        t += max(d, 0.005);
    }

    if(!hit){
        fc = vec4(0.06, 0.07, 0.12, 1.0);
        return;
    }

    vec3 p_hit = ro + rd*t;
    vec3 sn_ts = sdf_normal(p_hit);
    vec3 sn_w  = normalize(sn_ts.x*T + sn_ts.y*B + sn_ts.z*N);

    vec3 face_col;
    vec3 an = abs(N);
    if     (an.z > 0.9) face_col = (N.z>0.0) ? vec3(0.9,0.3,0.2) : vec3(0.2,0.5,0.9);
    else if(an.x > 0.9) face_col = (N.x>0.0) ? vec3(0.2,0.8,0.3) : vec3(0.8,0.6,0.1);
    else                face_col = (N.y>0.0) ? vec3(0.7,0.2,0.8) : vec3(0.2,0.7,0.7);

    vec3  L    = normalize(vec3(0.6, 1.0, 0.5));
    float diff = max(dot(sn_w, L), 0.0);
    vec3  V    = normalize(uCamPos - vWPos);
    vec3  H    = normalize(L + V);
    float spec = pow(max(dot(sn_w,H),0.0), 32.0) * 0.4;
    float ao   = clamp(1.0 - t*0.5, 0.2, 1.0);
    vec3  lit  = face_col*(0.15 + diff*0.85)*ao + vec3(spec);
    fc = vec4(pow(max(lit,vec3(0.0)), vec3(1.0/2.2)), 1.0);
}
@-----------------------"

| Vertex data: pos(3) + normal(3) + tangent(3) = 9 floats per vertex
#verts [
| +Z face
-1.0 -1.0  1.0   0.0 0.0 1.0   1.0 0.0 0.0
 1.0 -1.0  1.0   0.0 0.0 1.0   1.0 0.0 0.0
 1.0  1.0  1.0   0.0 0.0 1.0   1.0 0.0 0.0
-1.0  1.0  1.0   0.0 0.0 1.0   1.0 0.0 0.0
| -Z face
 1.0 -1.0 -1.0   0.0 0.0 -1.0  -1.0 0.0 0.0
-1.0 -1.0 -1.0   0.0 0.0 -1.0  -1.0 0.0 0.0
-1.0  1.0 -1.0   0.0 0.0 -1.0  -1.0 0.0 0.0
 1.0  1.0 -1.0   0.0 0.0 -1.0  -1.0 0.0 0.0
| +X face
 1.0 -1.0  1.0   1.0 0.0 0.0   0.0 0.0 -1.0
 1.0 -1.0 -1.0   1.0 0.0 0.0   0.0 0.0 -1.0
 1.0  1.0 -1.0   1.0 0.0 0.0   0.0 0.0 -1.0
 1.0  1.0  1.0   1.0 0.0 0.0   0.0 0.0 -1.0
| -X face
-1.0 -1.0 -1.0  -1.0 0.0 0.0   0.0 0.0 1.0
-1.0 -1.0  1.0  -1.0 0.0 0.0   0.0 0.0 1.0
-1.0  1.0  1.0  -1.0 0.0 0.0   0.0 0.0 1.0
-1.0  1.0 -1.0  -1.0 0.0 0.0   0.0 0.0 1.0
| +Y face
-1.0  1.0  1.0   0.0 1.0 0.0   1.0 0.0 0.0
 1.0  1.0  1.0   0.0 1.0 0.0   1.0 0.0 0.0
 1.0  1.0 -1.0   0.0 1.0 0.0   1.0 0.0 0.0
-1.0  1.0 -1.0   0.0 1.0 0.0   1.0 0.0 0.0
| -Y face
-1.0 -1.0 -1.0   0.0 -1.0 0.0   1.0 0.0 0.0
 1.0 -1.0 -1.0   0.0 -1.0 0.0   1.0 0.0 0.0
 1.0 -1.0  1.0   0.0 -1.0 0.0   1.0 0.0 0.0
-1.0 -1.0  1.0   0.0 -1.0 0.0   1.0 0.0 0.0
]

#idx [
 0  1  2   0  2  3
 4  5  6   4  6  7
 8  9 10   8 10 11
12 13 14  12 14 15
16 17 18  16 18 19
20 21 22  20 22 23
]

#g_vao #g_vbo #g_ebo

:build_cube
    1 'g_vao glGenVertexArrays
    g_vao glBindVertexArray

    24 9 * 'verts memfloat
    1 'g_vbo glGenBuffers
    GL_ARRAY_BUFFER g_vbo glBindBuffer
    GL_ARRAY_BUFFER 24 9 * 4 * 'verts GL_STATIC_DRAW glBufferData

    1 'g_ebo glGenBuffers
    GL_ELEMENT_ARRAY_BUFFER g_ebo glBindBuffer
    GL_ELEMENT_ARRAY_BUFFER 36 4 * 'idx GL_STATIC_DRAW glBufferData

    0 glEnableVertexAttribArray
    0 3 GL_FLOAT GL_FALSE 9 4 * 0 glVertexAttribPointer

    1 glEnableVertexAttribArray
    1 3 GL_FLOAT GL_FALSE 9 4 * 3 4 * glVertexAttribPointer

    2 glEnableVertexAttribArray
    2 3 GL_FLOAT GL_FALSE 9 4 * 6 4 * glVertexAttribPointer

    0 glBindVertexArray
;

#prog

#loc_mvp
#loc_model
#loc_cam
#loc_time

#vp_w 900
#vp_h 600

| Camera controls
#cam_yaw  -0.785398   | -PI/4
#cam_pit   0.45
#cam_dist  4.5
#cam_drag  0

| Cube rotation
#cube_rot  0.0
#spinning  1

#pEye 0.0 0.0 4.5
#fpEye [ 0 0 0 ]

#pTo 0 0 0.0
#pUp 0 1.0 0

#last_time
#time
#ftime [ 0 ]
	
| Float matrices
#fmodel * 64
#fmvp   * 64

| Mouse state
#mouse_x   0
#mouse_y   0
#mouse_btn 0

:viewresize
    0 0 vp_w vp_h glViewport
	;

:update
    spinning 1? ( 0.008 'cube_rot +! ) drop

    | Build model matrix
    matini
    cube_rot 0.4 *. mrotx
    cube_rot mroty
    m*
    'fmodel mcpyf

    | Build view matrix
    matini
	
	'pEye >a
    cam_yaw cos cam_pit cos *. cam_dist *. a!+ | ex
    cam_pit sin cam_dist *. a!+              | ey
    cam_yaw sin cam_pit cos *. cam_dist *. a! | ez

    'pEye 'pTo 'pUp mlookat
    m* | view * model

    | Build projection matrix
    0.05 100.0 | near far
    0.8 | FOV
    vp_w vp_h /. | aspect
    mperspective
    m* | proj * view * model

    'fmvp mcpyf
	
|::mem2float | cnt src dst --	
	3 'pEye 'fpEye mem2float
	time 0.1 *. f2fp 'ftime !
	;


:draw
    prog glUseProgram
    loc_mvp   1 GL_FALSE 'fmvp glUniformMatrix4fv
    loc_model 1 GL_FALSE 'fmodel glUniformMatrix4fv
    loc_cam 1 'fpEye glUniform3fv
    loc_time  1 'ftime glUniform1fv

    g_vao glBindVertexArray
    GL_TRIANGLES 36 GL_UNSIGNED_INT 0 glDrawElements
	;

#now #dt
:main
    SDL_GetTicks 'now !
    now last_time - 'dt !
    now 'last_time !
    dt 'time +!

	GLcls
    update
    draw

    GLUpdate
    sdlkey
	>esc< =? ( exit )
	<esp> =? ( spinning not 'spinning ! )
    drop
	;

| Boot
:
    "cube sdf raymarching" 900 600 GLini
    GLInfo
	
    build_cube

	'shader loadShaderv 'prog !
    prog "uMVP"    glGetUniformLocation 'loc_mvp   !
    prog "uModel"  glGetUniformLocation 'loc_model !
    prog "uCamPos" glGetUniformLocation 'loc_cam   !
    prog "uTime"   glGetUniformLocation 'loc_time  !
	
    SDL_GetTicks 'last_time !

    | Viewport dimensions
    viewresize

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