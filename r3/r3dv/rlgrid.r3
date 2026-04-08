^./renderlib.r3

| ============================================================
| GRID SHADER - infinite floor grid, deferred-compatible
| Renders into the GBuffer (gNormal + gAlbedo + depth).
| Reverse-Z: depthFunc = GL_GREATER, clear = 0.
| The grid plane is Y = 0 in world space.
| A fullscreen quad is ray-cast to find the intersection;
| fragments above the plane (or behind the camera) are discarded.
| Depth is written explicitly so the gbuffer depth test hides
| the grid behind any geometry drawn before rl_frame_end.
| ============================================================

#rl_shader_grid "
@vertex-----------------
#version 440 core
layout(location=0) in vec2 aPos;
out vec2 vScreen;
void main(){
    vScreen = aPos;
    gl_Position = vec4(aPos, 0.0, 1.0);
}
@fragment---------------
#version 440 core

in vec2 vScreen;

layout(std140, binding=0) uniform Matrices {
    mat4 view; mat4 proj; mat4 invView; mat4 invProj;
    vec4 viewPos;
};

layout(location=0) out vec3 gNormal;
layout(location=1) out vec4 gAlbedo;

// Reverse-Z: near maps to 1, far maps to 0
// We write depth manually so objects occlude the grid.

uniform float uGridScale;   // world units per cell
uniform float uFadeNear;    // fade start distance
uniform float uFadeFar;     // fade end distance

// Reconstruct a world-space ray from NDC position
void getRay(vec2 ndc, out vec3 ro, out vec3 rd) {
    vec4 ndc4   = vec4(ndc, -1.0, 1.0);
    vec4 vDir   = invProj * ndc4;
    vDir.xyz   /= vDir.w;
    vDir.w      = 0.0;
    ro = viewPos.xyz;
    rd = normalize((invView * vec4(vDir.xyz, 0.0)).xyz);
}

// NDC depth from world position (reverse-Z, no infinite far)
float worldToDepth(vec3 wp) {
    vec4 cp = proj * view * vec4(wp, 1.0);
    return (cp.z / cp.w) * 0.5 + 0.5;
}

void main() {
    vec3 ro, rd;
    getRay(vScreen, ro, rd);

    // Intersect with Y = 0 plane
    // rd.y == 0 means ray is parallel to floor -> no hit
    if (abs(rd.y) < 1e-5) discard;

    float t = -ro.y / rd.y;
    if (t < 0.0) discard;           // intersection is behind camera

    vec3 hit = ro + rd * t;

    // Distance fade
    float dist = length(hit - ro);
    float fade = 1.0 - clamp((dist - uFadeNear) / (uFadeFar - uFadeNear), 0.0, 1.0);
    if (fade <= 0.0) discard;

    // Grid pattern using fwidth for AA
    vec2 gp    = hit.xz / uGridScale;
    vec2 grid  = abs(fract(gp - 0.5) - 0.5) / fwidth(gp);
    float line = 1.0 - clamp(min(grid.x, grid.y) - 0.01, 0.0, 1.0);

    // Sub-grid (thin lines every unit, thick every 5)
    vec2 gp5   = hit.xz / (uGridScale * 5.0);
    vec2 grid5 = abs(fract(gp5 - 0.5) - 0.5) / fwidth(gp5);
    float line5 = 1.0 - clamp(min(grid5.x, grid5.y) - 0.01, 0.0, 1.0);

    float lineMask = max(line * 0.35, line5 * 0.8);
    if (lineMask * fade < 0.02) discard;

    // Write into GBuffer
    gNormal = vec3(0.0, 1.0, 0.0);

    // Color pre-multiplied by fade so distant lines are truly dark.
    // Thick lines are brighter than thin ones.
    vec3 baseCol = mix(vec3(0.18, 0.20, 0.26), vec3(0.45, 0.55, 0.75), line5);
    vec3 col = baseCol * lineMask * fade;

    // gAlbedo.a encodes roughness/metallic/glow as:
    //   bits[7:5] = roughness (0-7)
    //   bits[4:2] = metallic  (0-7)
    //   bits[1:0] = glow      (0-3)
    // We want roughness=7 (0xE0), metallic=0, glow=0  -> pack = 0xE0 = 224
    // float(224)/255.0 ~ 0.878
    // This gives a matte surface with NO glow, so bloom never fires on it.
    gAlbedo = vec4(col, 224.0 / 255.0);

    // Write correct reverse-Z depth so geometry occludes grid
    gl_FragDepth = worldToDepth(hit);
}
@-"
| ============================================================
| Grid state
#rl_sh_grid       0
#rl_u_grid_scale -1
#rl_u_grid_fnear -1
#rl_u_grid_ffar  -1

| Grid geometry reuses the fullscreen quad (rl_quad_vao)
| from renderlib — no extra VAO needed.

#rl_grid_scale  [ 1.0  ]   | 1 world unit per cell
#rl_grid_fnear  [ 10.0 ]   | fade starts at 10 units
#rl_grid_ffar   [ 80.0 ]   | fully faded at 80 units

:rl_bind_ubo | binding prog "name" --
	over swap glGetUniformBlockIndex  | binding prog index
	|(idx!=GL_INVALID_INDEX)
	rot glUniformBlockBinding ;

::rl_grid_init
	3 'rl_grid_scale memfloat
    'rl_shader_grid loadShaderv 'rl_sh_grid !
    rl_sh_grid "uGridScale" glGetUniformLocation 'rl_u_grid_scale !
    rl_sh_grid "uFadeNear"  glGetUniformLocation 'rl_u_grid_fnear !
    rl_sh_grid "uFadeFar"   glGetUniformLocation 'rl_u_grid_ffar  !
    0 rl_sh_grid "Matrices" rl_bind_ubo
    ;

::rl_grid_free
    rl_sh_grid 1? ( rl_sh_grid glDeleteProgram 0 'rl_sh_grid ! ) drop ;

| Call this INSIDE rl_frame_begin / rl_frame_end
| (after drawscene, before rl_frame_end)
::draw_grid
    rl_sh_grid glUseProgram
    rl_u_grid_scale 1 'rl_grid_scale glUniform1fv
    rl_u_grid_fnear 1 'rl_grid_fnear glUniform1fv
    rl_u_grid_ffar  1 'rl_grid_ffar  glUniform1fv
    rl_quad_vao glBindVertexArray
    GL_TRIANGLE_STRIP 0 4 glDrawArrays
    0 glBindVertexArray
    | Restore geometry shader for next drawscene calls
    rl_ProgGeom
    ;

| ============================================================
