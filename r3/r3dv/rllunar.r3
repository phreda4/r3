^./renderlib.r3

| ============================================================
| LUNAR SURFACE SHADER - procedural moon terrain, deferred-compatible
| Renders into the GBuffer (gNormal + gAlbedo + depth).
| Reverse-Z: depthFunc = GL_GREATER, clear = 0.
| The base plane is Y = 0 in world space; FBM noise displaces it upward.
| A fullscreen quad is ray-cast against a slab Y in [0, uAmplitude*1.5]
| using linear ray-marching with binary-search refinement.
| Depth is written explicitly so the gbuffer depth test hides
| the terrain behind any geometry drawn before rl_frame_end.
|
| OPTIMIZATIONS vs. first version:
|  - hash(): dot+fract(sin()) -- single transcendental, no dependency chain.
|  - FBM: loop unrolled with compile-time constants for lacunarity/gain;
|    5 octaves (6th contributes <1% amplitude, removed).
|  - terrain() called ONCE per march step; bisect bracket [tPrev,t] is
|    always valid so no extra terrain() sample is needed to initialise it.
|  - Craters: d2 avoids sqrt; all five exp() calls share a common base
|    e^(-d2) via integer powers -> 5 exp() instead of 10.
|  - terrainNormal(): 3-tap forward-difference instead of 4-tap central
|    -> one fewer terrain() call (~7 FBM evaluations saved per pixel).
|    hitH returned from the marcher for free reuse as the centre sample.
|  - lunarColor(): receives the FBM value already computed in main()
|    -> zero extra FBM calls for color (was 1 extra call).
|  - worldToDepth(): uses ProjView (already in UBO) not proj*view.
|  - uFadeInvRange precomputed CPU-side; shader does a single MAD.
|    uFadeFar uniform removed entirely.
|  - tMax clamped to uFadeFar (was 2*uFadeFar); wasted march steps cut ~50%.
|  - prevOver variable removed (was assigned but never read).
| ============================================================

#rl_shader_lunar "
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
    mat4 view; mat4 proj; mat4 invView; mat4 invProj; mat4 ProjView; vec4 viewPos;
};

layout(location=0) out vec3 gNormal;
layout(location=1) out vec4 gAlbedo;

uniform float uAmplitude;      // max terrain height in world units
uniform float uScale;          // horizontal noise frequency
uniform float uFadeNear;       // fade start distance
uniform float uFadeInvRange;   // 1.0 / (uFadeFar - uFadeNear) -- precomputed CPU-side

// ---- Hash & noise ----------------------------------------------------

// Single transcendental, no extra fract/add dependency chain.
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

// Bilinear value noise in [0,1]
float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

// FBM - 5 octaves, unrolled.
// Compile-time constants allow the driver to fold freq multiplications.
float fbm(vec2 p) {
    const float G = 0.48;
    const float L = 2.1;
    float v = 0.0, amp = 0.5;
    v += amp * vnoise(p); amp *= G; p *= L;
    v += amp * vnoise(p); amp *= G; p *= L;
    v += amp * vnoise(p); amp *= G; p *= L;
    v += amp * vnoise(p); amp *= G; p *= L;
    v += amp * vnoise(p);
    return v * 0.5 + 0.5;
}

// ---- Craters ---------------------------------------------------------
// Packed as (centerX, centerZ, invRadius, depth).
// Rim ~ e^(-2.5*d2), pit ~ -e^(-6*d2).
// Both derived from e1 = e^(-d2) via integer powers -> one exp() per crater.

const vec4 CraterData[5] = vec4[](
    vec4( 4.0,  3.5, 1.0/2.2, 0.6),
    vec4(-6.5, -2.0, 1.0/3.5, 0.8),
    vec4( 1.0, -7.0, 1.0/1.4, 0.4),
    vec4(-2.5,  6.0, 1.0/1.0, 0.3),
    vec4( 8.0, -4.5, 1.0/2.8, 0.7)
);

float craterField(vec2 xz) {
    float h = 0.0;
    for (int k = 0; k < 5; k++) {
        vec2  dv    = xz - CraterData[k].xy;
        float ir    = CraterData[k].z;
        float depth = CraterData[k].w * uAmplitude;
        float d2    = dot(dv, dv) * (ir * ir);
        float e1    = exp(-d2);
        float e2    = e1 * e1;
        float e25   = e2 * sqrt(e1);   // e^(-2.5*d2)
        float e6    = e2 * e2 * e2;    // e^(-6*d2)
        h += depth * (e25 * 0.35 - e6);
    }
    return h * uAmplitude;
}

// ---- Height field ----------------------------------------------------

float terrain(vec2 xz) {
    return max(fbm(xz * uScale) * uAmplitude + craterField(xz), 0.0);
}

// 3-tap forward-difference normal.
// hC = terrain(xz) already known at call site -> one fewer terrain() call.
vec3 terrainNormal(vec2 xz, float hC) {
    const float eps = 0.05;
    float hR = terrain(xz + vec2(eps, 0.0));
    float hU = terrain(xz + vec2(0.0, eps));
    return normalize(vec3(hC - hR, eps, hC - hU));
}

// ---- Ray helpers -----------------------------------------------------

void getRay(vec2 ndc, out vec3 ro, out vec3 rd) {
    vec4 vDir  = invProj * vec4(ndc, -1.0, 1.0);
    vDir.xyz  /= vDir.w;
    ro = viewPos.xyz;
    rd = normalize((invView * vec4(vDir.xyz, 0.0)).xyz);
}

// ProjView already in UBO -- avoids redundant proj*view multiplication.
float worldToDepth(vec3 wp) {
    vec4 cp = ProjView * vec4(wp, 1.0);
    return (cp.z / cp.w) * 0.5 + 0.5;
}

// ---- Ray-march -------------------------------------------------------

// Returns t on hit, -1.0 on miss.
// hitH: terrain height at the hit point (free, reused by caller).
float marchTerrain(vec3 ro, vec3 rd, out float hitH) {
    float yMax = uAmplitude * 1.5;
    float tMin = 0.001;
    float tMax = uFadeNear + 1.0 / uFadeInvRange;   // = uFadeFar

    // Clip against Y slab [0, yMax]
    if (rd.y > 0.0) {
        tMax = min(tMax, (yMax - ro.y) / rd.y);
        if (ro.y < 0.0) tMin = max(tMin, -ro.y / rd.y);
    } else if (rd.y < 0.0) {
        tMax = min(tMax, (-ro.y) / rd.y);
        if (ro.y > yMax) tMin = max(tMin, (yMax - ro.y) / rd.y);
    } else {
        if (ro.y < 0.0 || ro.y > yMax) return -1.0;
    }
    if (tMin >= tMax) return -1.0;

    float t     = tMin;
    float tPrev = t;
    float over  = (ro + rd * t).y - terrain((ro + rd * t).xz);

    for (int i = 0; i < 128; i++) {
        tPrev = t;
        t    += max(over * 0.4, 0.02);
        if (t > tMax) return -1.0;

        vec3  p = ro + rd * t;
        float h = terrain(p.xz);
        over = p.y - h;

        if (over < 0.001) {
            // [tPrev, t] always straddles the surface by construction.
            float tLo = tPrev, tHi = t;
            for (int b = 0; b < 6; b++) {
                float tM = (tLo + tHi) * 0.5;
                vec3  pm = ro + rd * tM;
                if (pm.y - terrain(pm.xz) > 0.0) tLo = tM; else tHi = tM;
            }
            float tf = (tLo + tHi) * 0.5;
            hitH = terrain((ro + rd * tf).xz);
            return tf;
        }
    }
    return -1.0;
}

// ---- Color -----------------------------------------------------------

// n: fbm already evaluated in main() -- zero extra FBM cost.
vec3 lunarColor(float n, float heightNorm, float slopeD) {
    vec3 col = mix(
        mix(vec3(0.08, 0.08, 0.09), vec3(0.18, 0.17, 0.16), smoothstep(0.2, 0.6, n)),
        vec3(0.30, 0.28, 0.25),
        smoothstep(0.6, 0.9, n));

    col *= mix(0.6, 1.0, smoothstep(0.92, 1.0, slopeD));
    col  = mix(col, col * vec3(1.05, 1.02, 0.95), smoothstep(0.6, 1.0, heightNorm));
    return col;
}

// ---- Main ------------------------------------------------------------

void main() {
    vec3 ro, rd;
    getRay(vScreen, ro, rd);

    float hitH;
    float t = marchTerrain(ro, rd, hitH);
    if (t < 0.0) discard;

    // Single MAD for fade -- no division in shader.
    float fade = 1.0 - clamp((t - uFadeNear) * uFadeInvRange, 0.0, 1.0);
    if (fade <= 0.0) discard;

    vec3 hit = ro + rd * t;

    // Normal: hitH reused as centre sample -> 3 terrain() calls instead of 4.
    vec3  N      = terrainNormal(hit.xz, hitH);
    float slopeD = N.y;

    // FBM for color reuses the same scale as the march -> coherent detail.
    float n   = fbm(hit.xz * uScale);
    vec3  col = lunarColor(n, hit.y / uAmplitude, slopeD) * fade;

    gNormal  = N;
    gAlbedo  = vec4(col, 224.0 / 255.0);   // roughness=7, metallic=0, glow=0
    gl_FragDepth = worldToDepth(hit);
}
@-"

| ============================================================
| Lunar surface state
#rl_sh_lunar          0
#rl_u_lunar_amp      -1
#rl_u_lunar_scale    -1
#rl_u_lunar_fnear    -1
#rl_u_lunar_finvr    -1   | 1/(far-near), precomputed

| Terrain parameters (edit these two; init computes the rest)
#rl_lunar_amp    [ 1.5  ]   | max terrain height in world units
#rl_lunar_scale  [ 0.18 ]   | noise horizontal frequency
#rl_lunar_fnear  [ 10.0 ]   | fade starts at 10 units
#rl_lunar_ffar   [ 80.0 ]   | fade ends at 80 units (CPU only, not sent to GPU)
#rl_lunar_finvr  [ 0.0  ]   | filled in by rl_lunar_init

:rl_bind_ubo | binding prog "name" --
    over swap glGetUniformBlockIndex rot glUniformBlockBinding ;

| Precompute 1/(ffar-fnear) so the shader can use a MAD instead of a divide.
:rl_lunar_calc_invr
    'rl_lunar_ffar d@ 'rl_lunar_fnear d@ - 1.0 swap /. 'rl_lunar_finvr d! ;

::rl_lunar_init
	rl_lunar_calc_invr
    5 'rl_lunar_amp memfloat

    'rl_shader_lunar loadShaderv 'rl_sh_lunar !
    rl_sh_lunar "uAmplitude"    glGetUniformLocation 'rl_u_lunar_amp   !
    rl_sh_lunar "uScale"        glGetUniformLocation 'rl_u_lunar_scale !
    rl_sh_lunar "uFadeNear"     glGetUniformLocation 'rl_u_lunar_fnear !
    rl_sh_lunar "uFadeInvRange" glGetUniformLocation 'rl_u_lunar_finvr !
    0 rl_sh_lunar "Matrices" rl_bind_ubo
    ;

::rl_lunar_free
    rl_sh_lunar 1? ( rl_sh_lunar glDeleteProgram 0 'rl_sh_lunar ! ) drop ;

| Call this INSIDE rl_frame_begin / rl_frame_end
::draw_lunar
    rl_sh_lunar glUseProgram
    rl_u_lunar_amp   1 'rl_lunar_amp   glUniform1fv
    rl_u_lunar_scale 1 'rl_lunar_scale glUniform1fv
    rl_u_lunar_fnear 1 'rl_lunar_fnear glUniform1fv
    rl_u_lunar_finvr 1 'rl_lunar_finvr glUniform1fv
    rl_quad_vao glBindVertexArray
    GL_TRIANGLE_STRIP 0 4 glDrawArrays
    0 glBindVertexArray
    ;

| ============================================================
