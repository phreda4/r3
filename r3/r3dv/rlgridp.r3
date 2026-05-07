^./renderlib.r3

| ============================================================
| GRID SHADER - infinite grid on any axis plane, deferred-compatible
| Renders into the GBuffer (gNormal + gAlbedo + depth).
| Reverse-Z: depthFunc = GL_GREATER, clear = 0.
|
| uAxis  : 0 = YZ plane (normal X)
|           1 = XZ plane (normal Y)  <- default, was the old Y=0 floor
|           2 = XY plane (normal Z)
|
| uLevel : world-space coordinate along the plane's normal axis
|           e.g. uAxis=1 uLevel=0.0  ->  Y=0  (original behaviour)
|
| uGridScaleX/Y/Z : world units per cell on each world axis.
|   The two axes that form the plane surface each use their own scale,
|   so cells can be rectangular (e.g. X=1.0 Z=3.0 on the XZ plane).
|
| A fullscreen quad is ray-cast to find the plane intersection.
| Depth is written explicitly so geometry drawn before rl_frame_end
| occludes the grid correctly.
| ============================================================

#rl_shader_grid "
@vertex-----------------
#version 440 core
layout(location=0) in vec2 aPos;
out vec2 vScreen;
void main()
{
    vScreen = aPos;
    gl_Position = vec4(aPos, 0.0, 1.0);
}
@fragment---------------
#version 440 core
in vec2 vScreen;
layout(std140, binding=0) uniform Matrices
{
    mat4 view;
    mat4 proj;
    mat4 invView;
    mat4 invProj;
    mat4 ProjView;
    vec4 viewPos;
};

layout(location=0) out vec3 gNormal;
layout(location=1) out vec4 gAlbedo;

uniform int uAxis;

uniform float uLevel;

uniform float uGridScaleX;
uniform float uGridScaleY;
uniform float uGridScaleZ;

uniform float uFadeNear;
uniform float uFadeFar;

uniform vec3 uLineColor;

float worldToDepth(vec3 wp)
{
    vec4 cp = ProjView * vec4(wp, 1.0);
    return (cp.z / cp.w) * 0.5 + 0.5;
}

void main()
{
    vec4 vDir = invProj * vec4(vScreen, 1.0, 1.0);
    vec3 rd = normalize((invView * vec4(vDir.xyz / vDir.w, 0.0)).xyz);
    vec3 ro = viewPos.xyz;
    vec3 planeNormal;
    float rd_n;
    float ro_n;
    vec3 tangent;
    vec3 bitangent;
    vec2 gridScale;
    if (uAxis == 0) { // YZ plane
        planeNormal = vec3(1.0, 0.0, 0.0);
        rd_n = rd.x;
        ro_n = ro.x;
        tangent   = vec3(0.0, 1.0, 0.0);
        bitangent = vec3(0.0, 0.0, 1.0);
        gridScale = vec2(uGridScaleY,uGridScaleZ);
    } else if (uAxis == 2) { // XY plane
        planeNormal = vec3(0.0, 0.0, 1.0);
        rd_n = rd.z;
        ro_n = ro.z;
        tangent   = vec3(1.0, 0.0, 0.0);
        bitangent = vec3(0.0, 1.0, 0.0);
        gridScale = vec2(uGridScaleX,uGridScaleY);
    } else { // XZ plane
        planeNormal = vec3(0.0, 1.0, 0.0);
        rd_n = rd.y;
        ro_n = ro.y;
        tangent   = vec3(1.0, 0.0, 0.0);
        bitangent = vec3(0.0, 0.0, 1.0);
        gridScale = vec2(uGridScaleX,uGridScaleZ);
    }

    if (abs(rd_n) < 1e-6)
        discard;

    float t = (uLevel - ro_n) / rd_n;
    if (t < 0.05) discard;
    vec3 hit = ro + rd * t;

    float fade = 1.0 - clamp((t - uFadeNear) / (uFadeFar - uFadeNear),0.0,1.0);

    if (fade <= 0.0)
        discard;

    vec2 gp = vec2(dot(hit, tangent),dot(hit, bitangent)) / gridScale;

    vec2 fw = max(fwidth(gp),vec2(1e-6));

	vec2 g = abs(fract(gp - 0.5) - 0.5);
	vec2 grid = g / fw;

	float lineX = 1.0 - clamp(grid.x, 0.0, 1.0);
	float lineY = 1.0 - clamp(grid.y, 0.0, 1.0);
	float line = max(lineX, lineY);

    if (line * fade < 0.02) discard;

    vec3 planePoint = planeNormal * uLevel;
    float normalSign = sign(dot(planeNormal,ro - planePoint));
    gNormal = planeNormal * normalSign;

	vec3 lc=vec3(0.2);
	vec3 col = lc //uLineColor ?*** porque no pasa el color??
		* line * fade;
	
    gAlbedo = vec4(col,1.0/255.0);
	//gAlbedo = vec4(0.2,0.2,0.2,1.0 / 255.0);
    gl_FragDepth = worldToDepth(hit);
}
@-"
| ============================================================
| Grid state
#rl_sh_grid        0
#rl_u_grid_sx     -1
#rl_u_grid_sy     -1
#rl_u_grid_sz     -1
#rl_u_grid_fnear  -1
#rl_u_grid_ffar   -1
#rl_u_grid_axis   -1
#rl_u_grid_level  -1
#rl_u_grid_color  -1

| Grid geometry reuses the fullscreen quad (rl_quad_vao) — no extra VAO needed.

#rl_grid_scale_x  [ 1.0  ]   | 1 world unit per cell on X
#rl_grid_scale_y  [ 1.0  ]   | 1 world unit per cell on Y
#rl_grid_scale_z  [ 1.0  ]   | 1 world unit per cell on Z
#rl_grid_fnear    [ 10.0 ]   | fade starts at 10 units
#rl_grid_ffar     [ 60.0 ]   | fully faded at 80 units
#rl_grid_level    [ 0.0  ]   | plane position along normal axis
#rl_grid_color    [ 1.0 1.0 1.0 ]  | line colour RGB
#rl_grid_axis     [ 1    ]   | 0=YZ  1=XZ(floor)  2=XY

:gridp_param
    rl_sh_grid glUseProgram
    rl_u_grid_sx    1 'rl_grid_scale_x glUniform1fv
    rl_u_grid_sy    1 'rl_grid_scale_y glUniform1fv
    rl_u_grid_sz    1 'rl_grid_scale_z glUniform1fv
    rl_u_grid_fnear 1 'rl_grid_fnear   glUniform1fv
    rl_u_grid_ffar  1 'rl_grid_ffar    glUniform1fv
    rl_u_grid_level 1 'rl_grid_level   glUniform1fv
    rl_u_grid_color 3 'rl_grid_color   glUniform3fv
	rl_u_grid_axis  1 'rl_grid_axis    glUniform1iv
	;

| ============================================================
| rl_grid_init  --
| Compiles the shader and caches all uniform locations.
::rl_gridp_init
    'rl_shader_grid loadShaderv 'rl_sh_grid !
    rl_sh_grid "uGridScaleX" glGetUniformLocation 'rl_u_grid_sx    !
    rl_sh_grid "uGridScaleY" glGetUniformLocation 'rl_u_grid_sy    !
    rl_sh_grid "uGridScaleZ" glGetUniformLocation 'rl_u_grid_sz    !
    rl_sh_grid "uFadeNear"   glGetUniformLocation 'rl_u_grid_fnear !
    rl_sh_grid "uFadeFar"    glGetUniformLocation 'rl_u_grid_ffar  !
    rl_sh_grid "uAxis"       glGetUniformLocation 'rl_u_grid_axis  !
    rl_sh_grid "uLevel"      glGetUniformLocation 'rl_u_grid_level !
    rl_sh_grid "uLineColor"  glGetUniformLocation 'rl_u_grid_color !
    0 rl_sh_grid "Matrices" rl_bind_ubo
	9 'rl_grid_scale_x memfloat | solo convierte 1 vez
	gridp_param
    ;

| ============================================================
| rl_grid_free  --
::rl_gridp_free
    rl_sh_grid 1? ( rl_sh_grid glDeleteProgram ) drop ;

| ============================================================
| draw_grid  --
| Call INSIDE rl_frame_begin / rl_frame_end, after drawscene.
::draw_gridp
    rl_sh_grid glUseProgram
    rl_quad_vao glBindVertexArray
    GL_TRIANGLE_STRIP 0 4 glDrawArrays
    0 glBindVertexArray ;
	
::gridplevel! | f --
	f2fp 'rl_grid_level d! 
	gridp_param ;
	
::gridpAxis! | a --
	'rl_grid_axis d!
	gridp_param ;

::gridpsx! | f --
	f2fp 'rl_grid_scale_x d! 
	gridp_param ;

::gridpsy! | f --
	f2fp 'rl_grid_scale_y d! 
	gridp_param ;

::gridpsz! | f --
	f2fp 'rl_grid_scale_z d! 
	gridp_param ;
	