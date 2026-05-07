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

// ---------------------------------------------------------------
// FLOOR_FILL to paint the whole floor with FLOOR_COLOR_BASE.

//efine FLOOR_FILL // <--- PATCH

#define FLOOR_COLOR_BASE  vec3(0.18, 0.20, 0.26)   // solid floor colour
#define FLOOR_COLOR_LINE  vec3(0.45, 0.55, 0.75)   // grid line colour
// ---------------------------------------------------------------

// gAlbedo.a packs roughness=7(0xE0), metallic=0, glow=0 -> 224/255
// Precomputed as a constant to avoid a per-fragment division.
#define GBUFFER_PACK  0.87843137  // 224.0/255.0

in vec2 vScreen;

layout(std140, binding=0) uniform Matrices {
    mat4 view; mat4 proj; mat4 invView; mat4 invProj; mat4 ProjView; vec4 viewPos;
};

layout(location=0) out vec3 gNormal;
layout(location=1) out vec4 gAlbedo;

uniform float uGridScale;   // world units per cell
uniform float uFadeNear;    // fade start distance
uniform float uFadeFar;     // fade end distance

// NDC depth from a view-space point (reverse-Z).
// hit is already in world space; we only need the projected z/w.
// Avoids a full mat4*vec4 by using ProjView directly.
float worldToDepth(vec3 wp) {
    vec4 cp = ProjView * vec4(wp, 1.0);
    return (cp.z / cp.w) * 0.5 + 0.5;
}

void main() {
    // --- Ray reconstruction ---
    // Unproject NDC -> view-space direction without an explicit getRay() call.
    // invProj * vec4(ndc, -1, 1) with w=1:  result.xyz / result.w
    // then rotate to world space via invView (rotation only, w=0).
    vec4 vDir = invProj * vec4(vScreen, -1.0, 1.0);
    vec3 rd   = normalize(mat3(invView) * (vDir.xyz / vDir.w));
    vec3 ro   = viewPos.xyz;

    // --- Intersect Y = 0 plane ---
    if (abs(rd.y) < 1e-5) discard;
    float t = -ro.y / rd.y;
    if (t < 0.0) discard;

    // t == distance along the normalised ray -> no need for length(hit-ro)
    float fade = 1.0 - clamp((t - uFadeNear) / (uFadeFar - uFadeNear), 0.0, 1.0);
    if (fade <= 0.0) discard;

    vec3 hit = ro + rd * t;

    // --- Grid lines (AA via fwidth) ---
    vec2 gp   = hit.xz / uGridScale;
    vec2 fw   = fwidth(gp);                         // compute once, reuse for gp5
    vec2 grid = abs(fract(gp - 0.5) - 0.5) / fw;
    float line = 1.0 - clamp(min(grid.x, grid.y) - 0.01, 0.0, 1.0);

    // gp5 = gp / 5  ->  fwidth(gp5) = fw / 5  (fwidth is linear)
    vec2 gp5   = gp * 0.2;
    vec2 grid5 = abs(fract(gp5 - 0.5) - 0.5) / (fw * 0.2);
    float line5 = 1.0 - clamp(min(grid5.x, grid5.y) - 0.01, 0.0, 1.0);

    float lineMask = max(line * 0.35, line5 * 0.8);

    // --- GBuffer write ---
    gNormal = vec3(0.0, 1.0, 0.0);

#ifdef FLOOR_FILL
    vec3 col = mix(FLOOR_COLOR_BASE, FLOOR_COLOR_LINE, lineMask) * fade;
#else
    if (lineMask * fade < 0.02) discard;
    vec3 col = FLOOR_COLOR_LINE * (lineMask * fade);
#endif
    gAlbedo = vec4(col, GBUFFER_PACK);

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

:modfill
	'rl_shader_grid "//efine FLOOR_FILL" findstr
	"#d" 2 cmove | patch shader
	;

::rl_grid_init | fillgrid --
	1? ( modfill ) drop
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
    ;
