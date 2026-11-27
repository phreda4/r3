| R3LIB 
| PHREDA 2026

^r3/lib/sdl2gl.r3
^r3/lib/3dgl.r3
^r3/lib/glutil.r3
^r3/lib/str.r3

| Vertex shader compartido: triangulo que cubre la pantalla (3 vertices, sin VBO), uv en [0,1]
| Cada shader de abajo solo tiene la seccion @fragment; rl_loadsh les antepone este.
#rl_shader_vs
"@vertex-----------------
#version 440 core
out vec2 uv;
void main(){
    vec2 p = vec2((gl_VertexID << 1) & 2, gl_VertexID & 2);   // (0,0) (2,0) (0,2)
    uv = p;
    gl_Position = vec4(p * 2.0 - 1.0, 0.0, 1.0);
}
"

#rl_shbuf * 24576		| armado de vertex compartido + fragment

:rl_loadsh | 'frag -- idprogram
	'rl_shader_vs 'rl_shbuf strcpy
	'rl_shbuf strcat
	'rl_shbuf loadShaderv ;

#rl_shader_light 
"@fragment---------------
#version 440 core
in vec2 uv;
out vec4 FragColor;

// ---- OPCIONES ---------------------------------------------------------------
// Activo: el albedo (paleta .vox / colores de shapes) esta en sRGB y se pasa a lineal aqui.
// Comentar si el albedo ya llega en lineal.
#define ALBEDO_SRGB

// Ambiente hemisferico: el AO solo se aplica a este termino (no a la luz directa)
const vec3  UP_AXIS       = vec3(0.0, 1.0, 0.0);      // eje arriba del mundo
const vec3  AMB_SKY       = vec3(0.20, 0.25, 0.35);
const vec3  AMB_GROUND    = vec3(0.06, 0.055, 0.05);
const float MIN_ROUGHNESS = 0.10;                     // evita hot-spots en luces puntuales
// En lineal el albedo es ~2.2x mas oscuro => el ambiente (unico termino con AO) pesa menos frente a la
// luz directa y el SSAO casi no se nota. AMB_GAIN lo compensa; DIRECT_AO aplica una parte del AO a la luz directa.
#ifdef ALBEDO_SRGB
const float AMB_GAIN      = 2.5;
#else
const float AMB_GAIN      = 1.0;
#endif
uniform float ambScale;                               // rl_ambient: escala del ambiente (1 = normal, ~0.04 = noche)
const float DIRECT_AO     = 0.4;                      // 0 = AO solo en ambiente, 1 = AO total tambien en directa
// -----------------------------------------------------------------------------
const float GLOW[4] = float[4](0.0, 0.35, 1.2, 5.0);

layout(binding = 0) uniform sampler2D gNormal;
layout(binding = 1) uniform sampler2D gAlbedo;
layout(binding = 2) uniform sampler2D gAO;
layout(binding = 3) uniform sampler2D gDepth;

layout(std140, binding = 0) uniform Matrices {
    mat4 view; mat4 proj; mat4 invView; mat4 invProj; mat4 ProjView; vec4 viewPos;
    mat4 invProjView;
};
layout(std140, binding = 1) uniform DirectLight { vec4 lightDir; vec4 lightColor; };

// sombra del sol (la llena ss3dshadow.r3): sp.x = activa, sp.y = normal offset, sp.z = bias de profundidad
layout(std140, binding = 3) uniform ShadowU { mat4 lightVP; vec4 ldir; vec4 sp; };
layout(binding = 4) uniform sampler2DShadow gShadow;

struct PointLight { vec4 pos; vec4 color; };
layout(std140, binding = 2) uniform PointLights {
    ivec4 header; PointLight lights[16];
} pl;

const float PI     = 3.14159265359;
const float INV_PI = 0.31830988618;
const float EPS    = 0.001;

float pow5(float x) { float x2 = x * x; return x2 * x2 * x; }

// normal octaedrica (RG16F) -> vec3 unitario en espacio mundo
vec3 octDecode(vec2 e) {
    vec3 n = vec3(e, 1.0 - abs(e.x) - abs(e.y));
    if (n.z < 0.0) n.xy = (1.0 - abs(n.yx)) * vec2(n.x >= 0.0 ? 1.0 : -1.0, n.y >= 0.0 ? 1.0 : -1.0);
    return normalize(n);
}

// sRGB -> lineal exacto (el composite usa la inversa exacta)
vec3 srgb2lin(vec3 c) { return mix(c / 12.92, pow((c + 0.055) / 1.055, vec3(2.4)), step(vec3(0.04045), c)); }

// z de vista a partir de la profundidad (ndc.z = depth; clip.w = -z)
float viewZ(float d) { return -proj[3][2] / (d + proj[2][2]); }

// AO de media resolucion -> resolucion completa: bilineal pesado por similitud de profundidad.
// La muestra h del AO representa al texel 2h del gbuffer (ver rl_shader_ao).
float aoUpsample(ivec2 px, float zc) {
    ivec2 asz = textureSize(gAO, 0);
    vec2  f   = vec2(px) * 0.5;
    ivec2 h0  = ivec2(f);
    vec2  fr  = f - vec2(h0);
    float tol = 0.05 * abs(zc) + 0.001;
    float sum = 0.0, wsum = 0.0;
    for (int j = 0; j < 2; ++j)
        for (int i = 0; i < 2; ++i) {
            ivec2 h  = min(h0 + ivec2(i, j), asz - 1);
            float bw = (i == 0 ? 1.0 - fr.x : fr.x) * (j == 0 ? 1.0 - fr.y : fr.y);
            float dd = texelFetch(gDepth, h * 2, 0).r;
            float w  = (dd > 0.0) ? exp(-abs(viewZ(dd) - zc) / tol) : 0.0;
            w = bw * (w + 1e-5);              // el piso evita 0/0 si ningun vecino coincide
            sum  += texelFetch(gAO, h, 0).r * w;
            wsum += w;
        }
    return sum / wsum;
}

// una sola multiplicacion: depth ya es ndc.z (clip ZERO_TO_ONE)
vec3 reconstructWorldPos(vec2 uv, float depth) {
    vec4 w = invProjView * vec4(uv * 2.0 - 1.0, depth, 1.0);
    return w.xyz / w.w;
}

// a2 = alpha^2, con alpha = roughness^2
float DistributionGGX(float NdotH, float a2) {
    float d = NdotH * NdotH * (a2 - 1.0) + 1.0;
    return a2 / (PI * d * d + EPS);
}
float GeometrySchlickGGX(float NdotX, float k) {
    return NdotX / (NdotX * (1.0 - k) + k);
}

vec3 BRDF(vec3 N, vec3 V, vec3 L,
          float NdotV, float NdotL,
          vec3 albedo, float metallic,
          float a2, float k, vec3 F0)
{
    vec3  H     = normalize(V + L);
    float NdotH = max(dot(N, H), 0.0);
    float HdotV = max(dot(H, V), 0.0);
    float NDF = DistributionGGX(NdotH, a2);
    float G   = GeometrySchlickGGX(NdotV, k) * GeometrySchlickGGX(NdotL, k);
    float f   = pow5(1.0 - HdotV);
    vec3  F   = F0 + (1.0 - F0) * f;
    vec3 kD   = (1.0 - F) * (1.0 - metallic);
    vec3 specular = (NDF * G * F) / (4.0 * NdotV * NdotL + EPS);
    return (kD * albedo * INV_PI + specular) * NdotL;
}

// fraccion de luz (1 = iluminado) con PCF 3x3 sobre el mapa de sombras ortografico
float sunShadow(vec3 worldPos, vec3 N) {
    if (sp.x < 0.5) return 1.0;
    vec4  c = lightVP * vec4(worldPos + N * sp.y, 1.0);
    vec3  s = vec3(c.xy * 0.5 + 0.5, c.z);
    if (s.x < 0.0 || s.x > 1.0 || s.y < 0.0 || s.y > 1.0 || s.z > 1.0) return 1.0;
    float ref = s.z - sp.z;
    vec2  ts  = 1.0 / vec2(textureSize(gShadow, 0));
    float sum = 0.0;
    for (int j = -1; j <= 1; ++j)
        for (int i = -1; i <= 1; ++i)
            sum += texture(gShadow, vec3(s.xy + vec2(i, j) * ts, ref));
    return sum * (1.0 / 9.0);
}

void main() {
    ivec2 px = ivec2(gl_FragCoord.xy);

    // fondo: negro (reverse-Z: depth 0 = plano lejano)
    float depth = texelFetch(gDepth, px, 0).r;
    if (depth <= 0.0) { FragColor = vec4(0.0, 0.0, 0.0, 1.0); return; }

    vec4 albedoPacked = texelFetch(gAlbedo, px, 0);
    vec3 albedo       = albedoPacked.rgb;
#ifdef ALBEDO_SRGB
    albedo = srgb2lin(albedo);
#endif
    vec3 N = octDecode(texelFetch(gNormal, px, 0).rg);

    int   pack      = int(albedoPacked.a * 255.0 + 0.5);
    float roughness = float((pack >> 5) & 0x07) * (1.0 / 7.0);
    float metallic  = float((pack >> 2) & 0x07) * (1.0 / 7.0);
    vec3  emissive  = albedo * GLOW[pack & 0x03];

    roughness = max(roughness, MIN_ROUGHNESS);
    float a   = roughness * roughness;              // alpha (Disney/Epic)
    float a2  = a * a;                              // alpha^2
    float k   = (roughness + 1.0) * (roughness + 1.0) * 0.125;
    vec3  F0  = mix(vec3(0.04), albedo, metallic);

    vec3  worldPos = reconstructWorldPos(uv, depth);
    vec3  V        = normalize(viewPos.xyz - worldPos);
    float NdotV    = max(dot(N, V), 0.0001);

    // ---- ambiente (difuso + especular) con AO ----
    float ao      = aoUpsample(px, viewZ(depth));
    vec3  hemi    = mix(AMB_GROUND, AMB_SKY, dot(N, UP_AXIS) * 0.5 + 0.5);
    vec3  Rv      = reflect(-V, N);
    vec3  env     = mix(AMB_GROUND, AMB_SKY, dot(Rv, UP_AXIS) * 0.5 + 0.5);
    vec3  Fr      = F0 + (max(vec3(1.0 - roughness), F0) - F0) * pow5(1.0 - NdotV);
    float specOcc = clamp(pow(NdotV + ao, exp2(-16.0 * roughness - 1.0)) - 1.0 + ao, 0.0, 1.0);

    vec3 color = (hemi * albedo * (1.0 - metallic) * ao
               + env * Fr * (1.0 - 0.5 * roughness) * specOcc) * (AMB_GAIN * ambScale)
               + emissive;
    float aoDir = mix(1.0, ao, DIRECT_AO);

    // ---- luz direccional (AO parcial: DIRECT_AO) ----
    vec3  L     = normalize(lightDir.xyz);
    float NdotL = dot(N, L);
    if (NdotL > 0.0) {
        color += BRDF(N, V, L, NdotV, NdotL, albedo, metallic, a2, k, F0)
               * lightColor.rgb * (lightColor.a * sunShadow(worldPos, N) * aoDir);
    }

    // ---- luces puntuales (AO parcial: DIRECT_AO): pos.w = radio de influencia ----
    int numLights = min(pl.header.x, 16);
    for (int i = 0; i < numLights; ++i) {
        vec3  toLight = pl.lights[i].pos.xyz - worldPos;
        float dist2   = dot(toLight, toLight);
        float rad     = pl.lights[i].pos.w;
        float r2      = rad * rad;
        if (dist2 > 1e-8 && dist2 < r2) {
            float invDist = inversesqrt(dist2);
            vec3  Lp      = toLight * invDist;
            float NdotLp  = dot(N, Lp);
            if (NdotLp > 0.0) {
                float dist = dist2 * invDist;
                float x    = dist2 / r2;
                float win  = clamp(1.0 - x * x, 0.0, 1.0);      // ventana suave hasta 0 en el radio
                float att  = win * win / (1.0 + dist * (0.09 + 0.032 * dist));
                color += BRDF(N, V, Lp, NdotV, NdotLp, albedo, metallic, a2, k, F0)
                       * pl.lights[i].color.rgb * (pl.lights[i].color.a * att * aoDir);
            }
        }
    }

    FragColor = vec4(color, 1.0);
}
@-"

#rl_shader_bright "
@fragment---------------
#version 440 core
in vec2 uv; out vec4 FragColor;
layout(binding=0) uniform sampler2D scene;
uniform float threshold;

// umbral con rodilla cuadratica + proteccion NaN/Inf + limite anti-fireflies
vec3 prefilter(vec3 c){
    if (any(isnan(c))) return vec3(0.0);
    if (any(isinf(c))) return vec3(0.0);
    c = min(c, vec3(64.0));
    float br   = max(c.r, max(c.g, c.b));
    float knee = max(threshold * 0.5, 0.0001);
    float soft = clamp(br - threshold + knee, 0.0, 2.0 * knee);
    soft = soft * soft / (4.0 * knee);
    float contrib = max(soft, br - threshold) / max(br, 0.0001);
    return c * contrib;
}
float karis(vec3 c){ return 1.0 / (1.0 + dot(c, vec3(0.2126, 0.7152, 0.0722))); }

void main(){
    // 4 taps bilineales = caja 4x4 sin solapes; promedio de Karis contra fireflies
    vec2 ts = 1.0 / vec2(textureSize(scene, 0));
    vec3 c0 = prefilter(texture(scene, uv + ts * vec2(-1.0, -1.0)).rgb);
    vec3 c1 = prefilter(texture(scene, uv + ts * vec2( 1.0, -1.0)).rgb);
    vec3 c2 = prefilter(texture(scene, uv + ts * vec2(-1.0,  1.0)).rgb);
    vec3 c3 = prefilter(texture(scene, uv + ts * vec2( 1.0,  1.0)).rgb);
    float w0 = karis(c0);
    float w1 = karis(c1);
    float w2 = karis(c2);
    float w3 = karis(c3);
    vec3 col = (c0 * w0 + c1 * w1 + c2 * w2 + c3 * w3) / (w0 + w1 + w2 + w3);
    FragColor = vec4(col, 1.0);
}
@-----------------------"

#rl_shader_bloom_down "
@fragment---------------
#version 440 core
in vec2 uv; out vec4 FragColor;
layout(binding=0) uniform sampler2D src;
uniform vec2 texelSize;
void main(){
    vec4 s=texture(src,uv)*4.0;
    s+=texture(src,uv-texelSize);
    s+=texture(src,uv+texelSize);
    s+=texture(src,uv+vec2(texelSize.x,-texelSize.y));
    s+=texture(src,uv+vec2(-texelSize.x,texelSize.y));
    FragColor=s/8.0;
}
@-----------------------"

#rl_shader_bloom_up "
@fragment---------------
#version 440 core
in vec2 uv; out vec4 FragColor;
layout(binding=0) uniform sampler2D src;   // nivel mas grueso (ya acumulado)
layout(binding=1) uniform sampler2D base;  // mip de bajada del mismo nivel
uniform vec2 texelSize;
void main(){
    vec2 h=texelSize*0.5;
    vec4 s =texture(src,uv+vec2(-h.x*2,0));
         s+=texture(src,uv+vec2(-h.x, h.y))*2;
         s+=texture(src,uv+vec2( 0,   h.y*2));
         s+=texture(src,uv+vec2( h.x, h.y))*2;
         s+=texture(src,uv+vec2( h.x*2,0));
         s+=texture(src,uv+vec2( h.x,-h.y))*2;
         s+=texture(src,uv+vec2( 0,  -h.y*2));
         s+=texture(src,uv+vec2(-h.x,-h.y))*2;
    vec3 up = (s/12.0).rgb;
    FragColor = vec4(mix(texture(base,uv).rgb, up, 0.5), 1.0);
}
@-----------------------"

#rl_shader_composite "
@fragment---------------
#version 440 core
in vec2 uv; out vec4 FragColor;
layout(binding=0) uniform sampler2D scene;
layout(binding=1) uniform sampler2D bloom;
uniform float bloomIntensity;
uniform float exposure;
vec3 ACES(vec3 x){
    const float a=2.51,b=0.03,c=2.43,d=0.59,e=0.14;
    return clamp((x*(a*x+b))/(x*(c*x+d)+e),0,1);}
void main(){
    vec3 col = texture(scene,uv).rgb + texture(bloom,uv).rgb * bloomIntensity;
    col = ACES(col * exposure);
    // sRGB exacto
    col = mix(col * 12.92, 1.055 * pow(col, vec3(1.0/2.4)) - 0.055, step(vec3(0.0031308), col));
    // dither (evita banding en degradados a 8 bits)
    float n = fract(52.9829189 * fract(dot(gl_FragCoord.xy, vec2(0.06711056, 0.00583715))));
    col += (n - 0.5) / 255.0;
    FragColor = vec4(col, 1.0);
}
@---"

#rl_shader_ao "
@fragment---------------
#version 440 core
in vec2 uv;
out float FragAO;

layout(binding = 0) uniform sampler2D gNormal;   // normal en espacio mundo (octaedrica, RG16F)
layout(binding = 3) uniform sampler2D gDepth;    // reverse-Z, clip ZERO_TO_ONE, far infinito

layout(std140, binding = 0) uniform Matrices {
    mat4 view; mat4 proj; mat4 invView; mat4 invProj; mat4 ProjView; vec4 viewPos;
    mat4 invProjView;
};

// ---- PARAMETROS (unidades de mundo) ----
const int   NS         = 12;
uniform float RADIUS;                // radio en unidades de mundo (rl_ao_radius)
const float POWER      = 1.5;
const float FADE_START_K = 66.667;   // el AO se desvanece con la distancia: start = RADIUS*K
const float FADE_END_K   = 133.333;  // (RADIUS=0.6 => 40 y 80 unidades)

// ruido de gradiente intercalado (por pixel, alineado con gl_FragCoord)
float ign(vec2 p) { return fract(52.9829189 * fract(dot(p, vec2(0.06711056, 0.00583715)))); }

// normal octaedrica (RG16F) -> vec3 unitario en espacio mundo
vec3 octDecode(vec2 e) {
    vec3 n = vec3(e, 1.0 - abs(e.x) - abs(e.y));
    if (n.z < 0.0) n.xy = (1.0 - abs(n.yx)) * vec2(n.x >= 0.0 ? 1.0 : -1.0, n.y >= 0.0 ? 1.0 : -1.0);
    return normalize(n);
}

// z de vista a partir de la profundidad (ndc.z = depth; clip.w = -z)
float viewZ(float d) { return -proj[3][2] / (d + proj[2][2]); }

void main() {
    // el target es de media resolucion: el pixel h usa el texel 2h del gbuffer
    ivec2 fp = ivec2(gl_FragCoord.xy) * 2;
    float d  = texelFetch(gDepth, fp, 0).r;
    if (d <= 0.0) { FragAO = 1.0; return; }

    float zc  = viewZ(d);
    vec2  ndc = (vec2(fp) + 0.5) / vec2(textureSize(gDepth, 0)) * 2.0 - 1.0;
    vec3  P   = vec3(ndc * (-zc) / vec2(proj[0][0], proj[1][1]), zc);
    vec3  N   = normalize(mat3(view) * octDecode(texelFetch(gNormal, fp, 0).rg));

    // base ortonormal rotada un angulo distinto en cada pixel
    vec3  up  = abs(N.z) < 0.999 ? vec3(0.0, 0.0, 1.0) : vec3(1.0, 0.0, 0.0);
    vec3  T0  = normalize(cross(up, N));
    vec3  B0  = cross(N, T0);
    float ang = ign(gl_FragCoord.xy) * 6.2831853;
    vec3  T   = T0 * cos(ang) + B0 * sin(ang);
    vec3  B   = cross(N, T);

    float jit  = ign(gl_FragCoord.xy + vec2(17.0, 31.0));
    float bias = RADIUS * 0.05 + 0.001 * (-zc);  // el bias crece con la distancia y con el radio
    float occ  = 0.0;

    for (int i = 0; i < NS; ++i) {
        // secuencia R2 -> hemisferio ponderado por coseno (Malley)
        float u   = fract(0.5 + float(i) * 0.7548776662);
        float v   = fract(0.5 + float(i) * 0.5698402910);
        float phi = v * 6.2831853;
        float r   = sqrt(u);
        vec3  h   = vec3(cos(phi) * r, sin(phi) * r, sqrt(1.0 - u));

        float s   = (float(i) + jit) / float(NS);
        float len = RADIUS * mix(0.1, 1.0, s * s);        // mas muestras cerca del punto
        vec3  S   = P + (T * h.x + B * h.y + N * h.z) * len;

        vec4 c = proj * vec4(S, 1.0);
        if (c.w <= 0.0) continue;
        vec2 suv = c.xy / c.w * 0.5 + 0.5;
        if (any(lessThan(suv, vec2(0.0)))) continue;
        if (any(greaterThan(suv, vec2(1.0)))) continue;

        float sd = texture(gDepth, suv).r;
        if (sd <= 0.0) continue;                           // cielo no ocluye
        float sceneZ = viewZ(sd);

        // range check: ignora oclusores mucho mas cerca de la camara que el radio
        float range = smoothstep(0.0, 1.0, RADIUS / max(abs(zc - sceneZ), 0.0001));
        if (sceneZ >= S.z + bias) occ += range;
    }
    // las muestras descartadas cuentan como no ocluidas (siempre se divide por NS)
    float ao = pow(clamp(1.0 - occ / float(NS), 0.0, 1.0), POWER);
    FragAO = mix(ao, 1.0, smoothstep(RADIUS * FADE_START_K, RADIUS * FADE_END_K, -zc));
}
@-"

#rl_shader_aoblur "
@fragment---------------
#version 440 core
in vec2 uv;
out float FragAO;

layout(binding = 0) uniform sampler2D aoTex;
layout(binding = 3) uniform sampler2D gDepth;

layout(std140, binding = 0) uniform Matrices {
    mat4 view; mat4 proj; mat4 invView; mat4 invProj; mat4 ProjView; vec4 viewPos;
    mat4 invProjView;
};

uniform ivec2 dir;   // (1,0) horizontal  -  (0,1) vertical, en texels de media resolucion

float viewZ(float d) { return -proj[3][2] / (d + proj[2][2]); }

const float GW[4] = float[4](1.0, 0.7788, 0.3679, 0.1054);   // exp(-i*i*0.25)

// blur bilateral separable (media resolucion): pesa por distancia y por diferencia de profundidad.
// El pixel h usa la profundidad del texel 2h del gbuffer (igual que rl_shader_ao).
void main() {
    ivec2 hp  = ivec2(gl_FragCoord.xy);
    ivec2 asz = textureSize(aoTex, 0);
    float dc  = texelFetch(gDepth, hp * 2, 0).r;
    if (dc <= 0.0) { FragAO = 1.0; return; }
    float zc   = viewZ(dc);
    float tol  = 0.05 * abs(zc) + 0.001;
    float sum  = 0.0;
    float wsum = 0.0;
    for (int i = -3; i <= 3; ++i) {
        ivec2 o  = clamp(hp + dir * i, ivec2(0), asz - 1);
        float dd = texelFetch(gDepth, o * 2, 0).r;
        float w  = 0.0;
        if (dd > 0.0) w = GW[abs(i)] * exp(-abs(viewZ(dd) - zc) / tol);
        sum  += texelFetch(aoTex, o, 0).r * w;
        wsum += w;
    }
    FragAO = sum / max(wsum, 0.0001);
}
@-"
#rl_shader_fxaa "
@fragment---------------
#version 440 core
in vec2 uv;
out vec4 FragColor;

layout(binding = 0) uniform sampler2D tex;   // LDR sRGB, filtro LINEAR + CLAMP_TO_EDGE

// ---- PARAMETROS FXAA 3.11 (calidad) ----
const float EDGE_THRESHOLD_MIN = 0.0312;   // contraste minimo absoluto
const float EDGE_THRESHOLD_MAX = 0.125;    // contraste minimo relativo al maximo local
const int   ITERATIONS         = 12;       // pasos maximos de busqueda del borde
const float SUBPIXEL_QUALITY   = 0.75;     // suavizado de detalle subpixel (0 = off)

float QUALITY(int q) {
    if (q < 5)   return 1.0;
    if (q == 5)  return 1.5;
    if (q < 10)  return 2.0;
    if (q == 10) return 4.0;
    return 8.0;
}

float rgb2luma(vec3 rgb) { return dot(rgb, vec3(0.299, 0.587, 0.114)); }

void main() {
    vec2 inv = 1.0 / vec2(textureSize(tex, 0));

    vec3  colorCenter = texture(tex, uv).rgb;
    float lumaCenter  = rgb2luma(colorCenter);
    float lumaDown    = rgb2luma(textureOffset(tex, uv, ivec2( 0, -1)).rgb);
    float lumaUp      = rgb2luma(textureOffset(tex, uv, ivec2( 0,  1)).rgb);
    float lumaLeft    = rgb2luma(textureOffset(tex, uv, ivec2(-1,  0)).rgb);
    float lumaRight   = rgb2luma(textureOffset(tex, uv, ivec2( 1,  0)).rgb);

    float lumaMin   = min(lumaCenter, min(min(lumaDown, lumaUp), min(lumaLeft, lumaRight)));
    float lumaMax   = max(lumaCenter, max(max(lumaDown, lumaUp), max(lumaLeft, lumaRight)));
    float lumaRange = lumaMax - lumaMin;

    // sin borde suficiente: no se toca el pixel
    if (lumaRange < max(EDGE_THRESHOLD_MIN, lumaMax * EDGE_THRESHOLD_MAX)) {
        FragColor = vec4(colorCenter, 1.0);
        return;
    }

    float lumaDownLeft  = rgb2luma(textureOffset(tex, uv, ivec2(-1, -1)).rgb);
    float lumaUpRight   = rgb2luma(textureOffset(tex, uv, ivec2( 1,  1)).rgb);
    float lumaUpLeft    = rgb2luma(textureOffset(tex, uv, ivec2(-1,  1)).rgb);
    float lumaDownRight = rgb2luma(textureOffset(tex, uv, ivec2( 1, -1)).rgb);

    float lumaDownUp       = lumaDown + lumaUp;
    float lumaLeftRight    = lumaLeft + lumaRight;
    float lumaLeftCorners  = lumaDownLeft + lumaUpLeft;
    float lumaDownCorners  = lumaDownLeft + lumaDownRight;
    float lumaRightCorners = lumaDownRight + lumaUpRight;
    float lumaUpCorners    = lumaUpRight + lumaUpLeft;

    // orientacion del borde (horizontal o vertical)
    float edgeHorizontal = abs(-2.0 * lumaLeft + lumaLeftCorners)
                         + abs(-2.0 * lumaCenter + lumaDownUp) * 2.0
                         + abs(-2.0 * lumaRight + lumaRightCorners);
    float edgeVertical   = abs(-2.0 * lumaUp + lumaUpCorners)
                         + abs(-2.0 * lumaCenter + lumaLeftRight) * 2.0
                         + abs(-2.0 * lumaDown + lumaDownCorners);
    bool isHorizontal = (edgeHorizontal >= edgeVertical);

    // lado del borde con mayor gradiente
    float luma1 = isHorizontal ? lumaDown : lumaLeft;
    float luma2 = isHorizontal ? lumaUp   : lumaRight;
    float gradient1 = luma1 - lumaCenter;
    float gradient2 = luma2 - lumaCenter;
    bool  is1Steepest    = abs(gradient1) >= abs(gradient2);
    float gradientScaled = 0.25 * max(abs(gradient1), abs(gradient2));

    float stepLength = isHorizontal ? inv.y : inv.x;
    float lumaLocalAverage = 0.0;
    if (is1Steepest) {
        stepLength = -stepLength;
        lumaLocalAverage = 0.5 * (luma1 + lumaCenter);
    } else {
        lumaLocalAverage = 0.5 * (luma2 + lumaCenter);
    }

    // medio pixel hacia el borde y busqueda en ambas direcciones
    vec2 currentUv = uv;
    if (isHorizontal) currentUv.y += stepLength * 0.5;
    else              currentUv.x += stepLength * 0.5;

    vec2 offset = isHorizontal ? vec2(inv.x, 0.0) : vec2(0.0, inv.y);
    vec2 uv1 = currentUv - offset;
    vec2 uv2 = currentUv + offset;

    float lumaEnd1 = rgb2luma(texture(tex, uv1).rgb) - lumaLocalAverage;
    float lumaEnd2 = rgb2luma(texture(tex, uv2).rgb) - lumaLocalAverage;

    bool reached1    = abs(lumaEnd1) >= gradientScaled;
    bool reached2    = abs(lumaEnd2) >= gradientScaled;
    bool reachedBoth = reached1 && reached2;

    if (!reached1) uv1 -= offset;
    if (!reached2) uv2 += offset;

    if (!reachedBoth) {
        for (int i = 2; i < ITERATIONS; i++) {
            if (!reached1) lumaEnd1 = rgb2luma(texture(tex, uv1).rgb) - lumaLocalAverage;
            if (!reached2) lumaEnd2 = rgb2luma(texture(tex, uv2).rgb) - lumaLocalAverage;
            reached1    = abs(lumaEnd1) >= gradientScaled;
            reached2    = abs(lumaEnd2) >= gradientScaled;
            reachedBoth = reached1 && reached2;
            if (!reached1) uv1 -= offset * QUALITY(i);
            if (!reached2) uv2 += offset * QUALITY(i);
            if (reachedBoth) break;
        }
    }

    // distancia a cada extremo -> desplazamiento del pixel
    float distance1 = isHorizontal ? (uv.x - uv1.x) : (uv.y - uv1.y);
    float distance2 = isHorizontal ? (uv2.x - uv.x) : (uv2.y - uv.y);
    bool  isDirection1  = distance1 < distance2;
    float distanceFinal = min(distance1, distance2);
    float edgeThickness = distance1 + distance2;
    float pixelOffset   = -distanceFinal / edgeThickness + 0.5;

    bool isLumaCenterSmaller = lumaCenter < lumaLocalAverage;
    bool correctVariation    = ((isDirection1 ? lumaEnd1 : lumaEnd2) < 0.0) != isLumaCenterSmaller;
    float finalOffset = correctVariation ? pixelOffset : 0.0;

    // suavizado subpixel
    float lumaAverage = (1.0 / 12.0) * (2.0 * (lumaDownUp + lumaLeftRight) + lumaLeftCorners + lumaRightCorners);
    float subPixelOffset1 = clamp(abs(lumaAverage - lumaCenter) / lumaRange, 0.0, 1.0);
    float subPixelOffset2 = (-2.0 * subPixelOffset1 + 3.0) * subPixelOffset1 * subPixelOffset1;
    float subPixelOffsetFinal = subPixelOffset2 * subPixelOffset2 * SUBPIXEL_QUALITY;
    finalOffset = max(finalOffset, subPixelOffsetFinal);

    vec2 finalUv = uv;
    if (isHorizontal) finalUv.y += finalOffset * stepLength;
    else              finalUv.x += finalOffset * stepLength;

    FragColor = vec4(texture(tex, finalUv).rgb, 1.0);
}
@-"

| <======= SHADERS

|-----------------------------------------------------------
##rl_w 1024 ##rl_h 768

| GBuffer
#rl_gbuf_fbo    0
#rl_gbuf_norm   0
#rl_gbuf_albedo 0
#rl_gbuf_depth  0

| Scene + Bloom
#rl_scene_fbo   0
#rl_scene_tex   0

| AO (SSAO en view-space a media resolucion + blur bilateral separable; el light pass hace el upsample)
#rl_ao_fbo   0
#rl_ao_tex   0
#rl_ao_fbo2  0
#rl_ao_tex2  0
##rl_ao_on   1       | 1=AO activo  0=desactivado (AO=1.0)
##rl_ao_radius 0.6   | radio del SSAO en unidades de mundo (ajustar a la escala de la escena)
#rl_ao_radf   0      | rl_ao_radius en float32 (se sube como uniform en cada aopass)
#rl_u_ao_radius -1
#rl_ao_dirh * 8      | ivec2 (1,0): paso del blur en texels de media resolucion
#rl_ao_dirv * 8      | ivec2 (0,1)
#rl_ao_w 0  #rl_ao_h 0   | tamano del AO: media resolucion (redondeo hacia arriba)
#rl_ao_clr 0         | 1 = ao_tex ya esta en blanco (AO apagado), no se vuelve a limpiar
#rl_ao_white * 16    | vec4 (1,1,1,1) en float32

| FXAA: composite -> ldr_tex (RGBA8) -> pase FXAA -> pantalla
#rl_ldr_fbo   0
#rl_ldr_tex   0
##rl_aa_on     1     | 1=FXAA activo  0=desactivado (el composite va directo a pantalla)

| VAO vacio: los pases de pantalla completa dibujan un triangulo con gl_VertexID (sin VBO),
| pero el core profile exige un VAO enlazado. Lo usan tambien rlforward/rlgrid/rlgridp.
##rl_empty_vao 0

| UBOs
##rl_ubo_matrices  0
##rl_ubo_dirlight  0
##rl_ubo_shadow    0		| ShadowU (binding 3): lightVP(64) ldir(16) sp(16) = 96 bytes
##rl_shadow_tex    0		| mapa de sombras (depth, compare LEQUAL) -> unidad 4
##rl_shadow_hook   0		| direccion de una palabra que se ejecuta al inicio de rl_frame_end (pase de sombras)
##rl_ubo_plights   0

| Shaders
#rl_sh_light      0
#rl_sh_bright     0
#rl_sh_bloom_down 0
#rl_sh_bloom_up   0
#rl_sh_composite  0
#rl_sh_ao         0
#rl_sh_aoblur     0
#rl_sh_fxaa       0

| Uniform locations
#rl_u_bright_threshold    -1
#rl_u_bloom_down_texel    -1
#rl_u_bloom_up_texel      -1
#rl_u_composite_intensity -1
#rl_u_composite_exposure  -1
#rl_u_aoblur_dir          -1

| Luces puntuales del frame
| PointLight: pos[4] + color[4] = 8 floats = 32 bytes
#rl_plight_count 0
| radio de influencia de las luces puntuales (va en pos.w); cambiarlo antes de rl_point_light
##rl_plight_radius 8.0

| Ambiente hemisferico (luz difusa + reflejo del cielo): 1.0 = normal, 0.0 = sin ambiente (solo luces y emisivos)
##rl_ambient 1.0
#rl_ambf 0		| rl_ambient en float32 (se sube como uniform en cada lightpass)
#rl_u_ambient -1

#tid

|----------------------------------
:rl_make_tex2d | ifmt w h filter -- texid	; 2D inmutable (1 nivel), CLAMP_TO_EDGE, sin tocar bindings (DSA)
	>r >r >r >r
	GL_TEXTURE_2D 1 'tid glCreateTextures
	tid 1 r> r> r> glTextureStorage2D		| texture levels ifmt w h
	tid GL_TEXTURE_MIN_FILTER r@ glTextureParameteri
	tid GL_TEXTURE_MAG_FILTER r> glTextureParameteri
	tid GL_TEXTURE_WRAP_S GL_CLAMP_TO_EDGE glTextureParameteri
	tid GL_TEXTURE_WRAP_T GL_CLAMP_TO_EDGE glTextureParameteri
	tid ;

:rl_make_fbo | color_tex -- fbo	; fbo con un solo color (draw buffer por defecto = COLOR_ATTACHMENT0)
	>r
	1 'tid glCreateFramebuffers
	tid GL_COLOR_ATTACHMENT0 r> 0 glNamedFramebufferTexture
	tid ;

:rl_make_rt | ifmt -- tex fbo	; textura rl_w x rl_h (lineal) + su fbo
	rl_w rl_h GL_LINEAR rl_make_tex2d
	dup rl_make_fbo ;

| formatos del gbuffer de normales
:RL_FMT_RG16F $822F ;	| GL_RG16F

| GLenum draws[2] = {GL_COLOR_ATTACHMENT0, GL_COLOR_ATTACHMENT1}
#_gdb_draws [ $8CE0 $8CE1 ]

:rl_init_gbuffer
    1 'rl_gbuf_fbo glGenFramebuffers
    GL_FRAMEBUFFER rl_gbuf_fbo glBindFramebuffer
	
    | gNormal: GL_RG16F (normal octaedrica en espacio mundo, 4 bytes por pixel)
    RL_FMT_RG16F rl_w rl_h GL_NEAREST
    rl_make_tex2d 'rl_gbuf_norm !
	
    | gAlbedo: GL_RGBA8
    GL_RGBA8 rl_w rl_h GL_NEAREST
    rl_make_tex2d 'rl_gbuf_albedo !
	
    | gDepth: GL_DEPTH_COMPONENT32F
    GL_DEPTH_COMPONENT32F rl_w rl_h GL_NEAREST
    rl_make_tex2d 'rl_gbuf_depth !
	
    GL_FRAMEBUFFER GL_COLOR_ATTACHMENT0 GL_TEXTURE_2D rl_gbuf_norm   0 glFramebufferTexture2D
    GL_FRAMEBUFFER GL_COLOR_ATTACHMENT1 GL_TEXTURE_2D rl_gbuf_albedo 0 glFramebufferTexture2D
    GL_FRAMEBUFFER GL_DEPTH_ATTACHMENT  GL_TEXTURE_2D rl_gbuf_depth  0 glFramebufferTexture2D
    2 '_gdb_draws glDrawBuffers

	GL_FRAMEBUFFER 0 glBindFramebuffer
	GL_TEXTURE_2D 0 glBindTexture
	;

| Bloom FBOs y texturas: 5 mips × 2 sides = 10 entradas (dwords)
:RL_BLOOM_MIPS 5 ; 

#listwh [ 0 0 0 0 0 ]
#lisafp 0 0 0 0 0 
#listex * 40		| 2 ids por mip (dwords)
#lisfbo * 40

:]wh | n -- w h
	2 << 'listwh + d@ dup $ffff and swap 16 >>> ;
:]wh! | wh n --
	2 << 'listwh + d! ;

:]afp | n -- afp
	3 << 'lisafp + ;
:]afp! | afp n -- 
	3 << 'lisafp + ! ;
	
:]tex | n -- tex
	2 << 'listex + d@ ;
:]fbo | n -- fbo
	2 << 'lisfbo + d@ ;

| ================================================================	
:rl_init_bloom
    | scene: RGBA16F
    GL_RGBA16F rl_make_rt 'rl_scene_fbo ! 'rl_scene_tex !
	
	
    | Bloom mips
	'listex >a
	'lisfbo >b
    rl_w rl_h 0 ( RL_BLOOM_MIPS <? >r
		swap 2/ 2 max 
		swap 2/ 2 max   | w h
		2dup 16 << or r@ ]wh!
		1.0 pick2 / f2fp $ffffffff and 
		1.0 pick2 / f2fp 32 << or r@ ]afp!
		GL_RGBA16F pick2 pick2 GL_LINEAR rl_make_tex2d 
		dup da!+ rl_make_fbo db!+
		GL_RGBA16F pick2 pick2 GL_LINEAR rl_make_tex2d 
		dup da!+ rl_make_fbo db!+
		r> 1+ ) 3drop ;

| ================================================================
:rl_destroy_gbuffer
    1 'rl_gbuf_fbo    glDeleteFramebuffers
    1 'rl_gbuf_norm   glDeleteTextures
    1 'rl_gbuf_albedo glDeleteTextures
    1 'rl_gbuf_depth  glDeleteTextures
    0 'rl_gbuf_fbo ! 0 'rl_gbuf_norm ! 0 'rl_gbuf_albedo ! 0 'rl_gbuf_depth !
    ;

:rl_destroy_bloom
	1 'rl_scene_fbo glDeleteFramebuffers
	1 'rl_scene_tex glDeleteTextures
	0 'rl_scene_fbo ! 0 'rl_scene_tex !
	RL_BLOOM_MIPS 2* 'listex glDeleteTextures
	RL_BLOOM_MIPS 2* 'lisfbo glDeleteFramebuffers ;


| ================================================================
| AO: ao_tex (resultado final) + ao_tex2 (ping-pong del blur), formato R8
:RL_FMT_R8  $8229 ;	| GL_R8
:RL_FMT_RGBA8 $8058 ;	| GL_RGBA8

:rl_make_aort | -- tex fbo	; R8 a media resolucion
	RL_FMT_R8 rl_ao_w rl_ao_h GL_NEAREST rl_make_tex2d
	dup rl_make_fbo ;

:rl_init_ao
	rl_w 1+ 2/ 'rl_ao_w !  rl_h 1+ 2/ 'rl_ao_h !	| media resolucion (hp*2 siempre cae dentro del gbuffer)
	rl_make_aort 'rl_ao_fbo ! 'rl_ao_tex !
	rl_make_aort 'rl_ao_fbo2 ! 'rl_ao_tex2 !
	0 'rl_ao_clr !
	| direcciones del blur como 2 int32
	'rl_ao_dirh >a 1 da!+ 0 da!+
	'rl_ao_dirv >a 0 da!+ 1 da!+
	| color de limpieza blanco (AO desactivado)
	'rl_ao_white >a 1.0 f2fp da!+ 1.0 f2fp da!+ 1.0 f2fp da!+ 1.0 f2fp da!+
	;

:rl_destroy_ao
	1 'rl_ao_fbo  glDeleteFramebuffers
	1 'rl_ao_tex  glDeleteTextures
	1 'rl_ao_fbo2 glDeleteFramebuffers
	1 'rl_ao_tex2 glDeleteTextures
	0 'rl_ao_fbo ! 0 'rl_ao_tex ! 0 'rl_ao_fbo2 ! 0 'rl_ao_tex2 !
	;

| ================================================================
| FXAA: imagen LDR intermedia (RGBA8, ya con gamma) que lee el pase FXAA
:rl_init_ldr
	RL_FMT_RGBA8 rl_make_rt 'rl_ldr_fbo ! 'rl_ldr_tex !
	;

:rl_destroy_ldr
	1 'rl_ldr_fbo glDeleteFramebuffers
	1 'rl_ldr_tex glDeleteTextures
	0 'rl_ldr_fbo ! 0 'rl_ldr_tex !
	;

| OJO: estas 3 variables van pegadas (rl_init_vao las convierte a float32 con memfloat)
#RL_BLOOM_INTENSITY [ 0.8 ]
#RL_BLOOM_THRESHOLD [ 0.8 ]
#RL_EXPOSURE        [ 1.0 ]

| ================================================================
:rl_init_vao
	3 'RL_BLOOM_INTENSITY memfloat
    1 'rl_empty_vao glGenVertexArrays
    rl_empty_vao glBindVertexArray
    0 glBindVertexArray
    ;

| ================================================================
:rl_init_ubos
    1 'rl_ubo_matrices glGenBuffers
    GL_UNIFORM_BUFFER rl_ubo_matrices glBindBuffer
    GL_UNIFORM_BUFFER 400 0 GL_DYNAMIC_DRAW glBufferData
    GL_UNIFORM_BUFFER 0 rl_ubo_matrices glBindBufferBase

    1 'rl_ubo_dirlight glGenBuffers
    GL_UNIFORM_BUFFER rl_ubo_dirlight glBindBuffer
    GL_UNIFORM_BUFFER 32 0 GL_DYNAMIC_DRAW glBufferData
    GL_UNIFORM_BUFFER 1 rl_ubo_dirlight glBindBufferBase

    1 'rl_ubo_shadow glGenBuffers
    GL_UNIFORM_BUFFER rl_ubo_shadow glBindBuffer
    GL_UNIFORM_BUFFER 96 0 GL_DYNAMIC_DRAW glBufferData
    GL_UNIFORM_BUFFER 3 rl_ubo_shadow glBindBufferBase

    1 'rl_ubo_plights glGenBuffers
    GL_UNIFORM_BUFFER rl_ubo_plights glBindBuffer
    GL_UNIFORM_BUFFER 528 0 GL_DYNAMIC_DRAW glBufferData
    GL_UNIFORM_BUFFER 2 rl_ubo_plights glBindBufferBase

    GL_UNIFORM_BUFFER 0 glBindBuffer
    ;

|------------- CAMERA ------------------
#camDirty  1

##camAsp 0
##camFov 0.4142
##camNear 0.1	
##camFar 200.0

| ================================================================
| Pasada forward (transparentes, rlforward.r3): dibuja sobre scene_tex (HDR)
| con el depth del gbuffer, despues del light pass y antes del bloom.
| rl_forward_hook = direccion de una palabra (0 = nada). Al ejecutarse ya estan
| puestos el fbo (color = scene_tex, depth = depth del gbuffer) y el viewport.
##rl_forward_hook 0
#rl_fwd_fbo 0

:rl_init_fwd
	1 'rl_fwd_fbo glGenFramebuffers
	GL_FRAMEBUFFER rl_fwd_fbo glBindFramebuffer
	GL_FRAMEBUFFER GL_COLOR_ATTACHMENT0 GL_TEXTURE_2D rl_scene_tex 0 glFramebufferTexture2D
	GL_FRAMEBUFFER GL_DEPTH_ATTACHMENT  GL_TEXTURE_2D rl_gbuf_depth 0 glFramebufferTexture2D
	GL_FRAMEBUFFER 0 glBindFramebuffer ;

:rl_destroy_fwd
	rl_fwd_fbo 1? ( 1 'rl_fwd_fbo glDeleteFramebuffers 0 'rl_fwd_fbo ! ) drop ;

| ================================================================
::rl_resizewin | h w --   (se llama con: sh sw rl_resizewin)
    rl_w =? ( swap rl_h  =? ( 2drop ; ) swap ) 'rl_w ! 'rl_h !
    1 'camDirty !
	rl_destroy_fwd
	rl_destroy_bloom rl_destroy_ao rl_destroy_ldr rl_destroy_gbuffer  
	rl_init_gbuffer rl_init_ao rl_init_ldr rl_init_bloom
	rl_init_fwd
    ;

| ================================================================
::rl_set_projection | tan(fov/2)_fp near_fp far_fp -- (0.4142 = fov 45 grados)
    'camFar ! 'camNear ! 'camFov ! 
	1 'camDirty ! ;

| ================================================================
::rl_Init
	sw 'rl_w ! sh 'rl_h !
	| clip control: origen abajo-izquierda, profundidad ZERO_TO_ONE (requiere glClipControl, GL 4.5 / ARB_clip_control)
	$8CA1 $935F glClipControl
	0.4142 0.1 200.0 rl_set_projection
    rl_init_gbuffer
    rl_init_bloom
    rl_init_fwd
    rl_init_ao
    rl_init_ldr
    rl_init_vao
    rl_init_ubos

    'rl_shader_light      rl_loadsh 'rl_sh_light      !
    'rl_shader_bright     rl_loadsh 'rl_sh_bright     !
    'rl_shader_bloom_down rl_loadsh 'rl_sh_bloom_down !
    'rl_shader_bloom_up   rl_loadsh 'rl_sh_bloom_up   !
    'rl_shader_composite  rl_loadsh 'rl_sh_composite  !
    'rl_shader_ao         rl_loadsh 'rl_sh_ao         !
    'rl_shader_aoblur     rl_loadsh 'rl_sh_aoblur     !
    'rl_shader_fxaa       rl_loadsh 'rl_sh_fxaa       !


    rl_sh_bright     "threshold"      glGetUniformLocation 'rl_u_bright_threshold    !
    rl_sh_bloom_down "texelSize"      glGetUniformLocation 'rl_u_bloom_down_texel    !
    rl_sh_bloom_up   "texelSize"      glGetUniformLocation 'rl_u_bloom_up_texel      !
    rl_sh_composite  "bloomIntensity" glGetUniformLocation 'rl_u_composite_intensity !
    rl_sh_composite  "exposure"       glGetUniformLocation 'rl_u_composite_exposure  !
    rl_sh_aoblur     "dir"            glGetUniformLocation 'rl_u_aoblur_dir          !
    rl_sh_ao         "RADIUS"         glGetUniformLocation 'rl_u_ao_radius           !
    rl_sh_light      "ambScale"       glGetUniformLocation 'rl_u_ambient             !
    
    GL_CULL_FACE glEnable
    GL_BACK glCullFace
    GL_CCW glFrontFace
	0.0 GlDepth
	;
	
::rl_shutdown
    rl_sh_light      glDeleteProgram
    rl_sh_bright     glDeleteProgram
    rl_sh_bloom_down glDeleteProgram
    rl_sh_bloom_up   glDeleteProgram
    rl_sh_composite  glDeleteProgram
    rl_sh_ao         glDeleteProgram
    rl_sh_aoblur     glDeleteProgram
    rl_sh_fxaa       glDeleteProgram

    rl_destroy_fwd
    rl_destroy_gbuffer
    rl_destroy_bloom
    rl_destroy_ao
    rl_destroy_ldr

    1 'rl_empty_vao glDeleteVertexArrays
    1 'rl_ubo_matrices glDeleteBuffers
    1 'rl_ubo_dirlight glDeleteBuffers
    1 'rl_ubo_plights  glDeleteBuffers
    1 'rl_ubo_shadow   glDeleteBuffers
    ;


|----- UBO->GPU
| RL_UBO_Matrices: view(64) proj(64) invView(64) invProj(64) viewProj(64)
| viewPos(16) + invProjView(64) = 400 bytes
#ubo_matView * 64
#ubo_matvProj * 64
#ubo_matvinvView * 64
#ubo_matvinvProj * 64
#ubo_matProjView * 64
#ubo_matViewPos * 16
#ubo_matInvProjView * 64

|------------------------------------
#realproj * 128 | cache proj
#realinvproj * 128 | cache inv proj
#realinvview * 128 | cache inv view

:cache_proj
	camDirty 0? ( drop ; ) drop
	0 'camDirty !
	rl_w 16 << rl_h / 'camAsp ! 
	mpush
	camNear camFar camAsp camFov mperspectiverz | near far asp fov --
	'ubo_matvProj mcpyf
	'realproj mcpy  | copy for precalc proj*view
	minvrz
	'ubo_matvinvProj mcpyf
	'realinvproj mcpy | copy for precalc invView*invProj
	mpop mpop
	;

::rl_camera | 'eye 'to 'up --
	3 pick3 'ubo_matViewPos mem2float | cnt sr ds
	cache_proj
	mat> >r
	mpush
	mlookat
	'ubo_matView mcpyf
	matinv
	'ubo_matvinvView mcpyf
	'realinvview mcpy
	mpop
	'realproj mm* | reverse proj*view
	'ubo_matProjView mcpyf
	mpop
	| invProjView = invView * invProj (reconstruccion de posicion en 1 mat*vec)
	mat> 'realinvproj 16 move
	'realinvview mm*
	'ubo_matInvProjView mcpyf
	r> 'mat> !
	;
	
| ================================================================
::rl_frame_begin | --
    0 'rl_plight_count !
	
	GL_GREATER glDepthFunc
    0 0 rl_w rl_h glViewport
    GL_FRAMEBUFFER rl_gbuf_fbo glBindFramebuffer
	GL_DEPTH_TEST glEnable
	GL_TRUE glDepthMask

	$1800 0 'vcolorgl glClearBufferfv | Normales ATTACHMENT0
	$1800 1 'vcolorgl glClearBufferfv | Albedo ATTACHMENT1
	$1801 0 'vbasegl glClearBufferfv     | Profundidad 

	|--- camera --- shadow?
	rl_ubo_matrices 0 400 'ubo_matview glNamedBufferSubData
	;


| ================================================================
| RL_UBO_DirectLight: lightDir(16) lightColor(16)
::rl_set_sun | 'sun --
	>r rl_ubo_dirlight 0 32 r> glNamedBufferSubData ;

| ================================================================
| Cada PointLight = 32 bytes: pos[4](16) + color[4](16)
#rl_ubo_pl_buf * 528

::rl_point_light | int cr cg cb x y z --
	rl_plight_count 16 >=? ( drop 4drop 3drop ; ) drop	| maximo 16 luces (el buffer es de 528 bytes)
    16 rl_plight_count 5 << + 'rl_ubo_pl_buf + >a 
	swap rot f2fp da!+ f2fp da!+ f2fp da!+ rl_plight_radius f2fp da!+
	swap rot f2fp da!+ f2fp da!+ f2fp da!+ f2fp da!+
    1 'rl_plight_count +!
    ;

| ================================================================
| RL_UBO_PointLights: count[4](16) + 16×(pos[4]+color[4])(32) = 16 + 512 = 528 bytes
:lightpass
	rl_ambient f2fp 'rl_ambf d!
	rl_u_ambient 1 'rl_ambf glUniform1fv
	rl_plight_count 'rl_ubo_pl_buf d!
	
	rl_ubo_plights 0 16 rl_plight_count 5 << + 'rl_ubo_pl_buf glNamedBufferSubData
	GL_TRIANGLES 0 3 glDrawArrays
	;
	
:bpassd | id loc ftex fbos wh --
	0 0 rot ]wh glViewport
	GL_FRAMEBUFFER swap ]fbo glBindFramebuffer
	GL_TEXTURE0 glActiveTexture
	GL_TEXTURE_2D swap ]tex glBindTexture
	1 rot ]afp glUniform2fv 
	GL_TRIANGLES 0 3 glDrawArrays
	;
	
:bpassu | id loc ftex fbos wh base --
	| igual que bpassd pero bindea ademas 'base' (mip de bajada) en la unidad 1
	GL_TEXTURE1 glActiveTexture
	GL_TEXTURE_2D swap ]tex glBindTexture
	bpassd ;

:bloompass
	rl_sh_bright glUseProgram
	rl_u_bright_threshold 1 'RL_BLOOM_THRESHOLD glUniform1fv
	0 0 0 ]wh glViewport
	GL_FRAMEBUFFER 0 ]fbo glBindFramebuffer |bos tex
	GL_TEXTURE0 glActiveTexture 
	GL_TEXTURE_2D rl_scene_tex glBindTexture
	GL_TRIANGLES 0 3 glDrawArrays

	| Downscale chain
	rl_sh_bloom_down glUseProgram
	0 rl_u_bloom_down_texel 0 2 1 bpassd | invw id ftex fbos wh --
	1 rl_u_bloom_down_texel 2 4 2 bpassd | invw id ftex fbos wh --
	2 rl_u_bloom_down_texel 4 6 3 bpassd | invw id ftex fbos wh --
	3 rl_u_bloom_down_texel 6 8 4 bpassd | invw id ftex fbos wh --
	
	| Upscale chain: cada paso suma el mip de bajada del mismo nivel (base)
	rl_sh_bloom_up glUseProgram
	4 rl_u_bloom_up_texel 8 7 3 6 bpassu | id loc src dst vp base --
	3 rl_u_bloom_up_texel 7 5 2 4 bpassu | id loc src dst vp base --
	2 rl_u_bloom_up_texel 5 3 1 2 bpassu | id loc src dst vp base --
	1 rl_u_bloom_up_texel 3 1 0 0 bpassu | id loc src dst vp base --
	;

| ================================================================
| AO: calcula ao_tex (SSAO, media resolucion) y lo filtra con blur bilateral H + V
:aopass
	rl_ao_on 0? ( drop
		| AO desactivado: se limpia a blanco una sola vez, despues la textura sigue blanca
		rl_ao_clr 0? ( drop
			GL_FRAMEBUFFER rl_ao_fbo glBindFramebuffer
			0 0 rl_ao_w rl_ao_h glViewport
			$1800 0 'rl_ao_white glClearBufferfv
			1 'rl_ao_clr ! ; ) drop
		; ) drop
	0 'rl_ao_clr !

	| SSAO -> ao_tex
	GL_FRAMEBUFFER rl_ao_fbo glBindFramebuffer
	0 0 rl_ao_w rl_ao_h glViewport
	rl_sh_ao glUseProgram
	rl_ao_radius f2fp 'rl_ao_radf d!
	rl_u_ao_radius 1 'rl_ao_radf glUniform1fv
	GL_TEXTURE0 glActiveTexture GL_TEXTURE_2D rl_gbuf_norm  glBindTexture
	GL_TEXTURE3 glActiveTexture GL_TEXTURE_2D rl_gbuf_depth glBindTexture
	GL_TRIANGLES 0 3 glDrawArrays

	| blur horizontal: ao_tex -> ao_tex2
	rl_sh_aoblur glUseProgram
	GL_FRAMEBUFFER rl_ao_fbo2 glBindFramebuffer
	GL_TEXTURE0 glActiveTexture GL_TEXTURE_2D rl_ao_tex glBindTexture
	rl_u_aoblur_dir 1 'rl_ao_dirh glUniform2iv
	GL_TRIANGLES 0 3 glDrawArrays

	| blur vertical: ao_tex2 -> ao_tex (resultado final)
	GL_FRAMEBUFFER rl_ao_fbo glBindFramebuffer
	GL_TEXTURE_2D rl_ao_tex2 glBindTexture
	rl_u_aoblur_dir 1 'rl_ao_dirv glUniform2iv
	GL_TRIANGLES 0 3 glDrawArrays
	;

| ================================================================
| FBO de destino del composite: ldr (si hay FXAA) o la pantalla (0)
:aatarget | -- fbo
	rl_aa_on 1? ( drop rl_ldr_fbo ; ) drop 0 ;

::rl_frame_end | --
	rl_shadow_hook 1? ( dup ex ) drop	| pase de sombras (ss3dshadow)
	rl_empty_vao glBindVertexArray
	GL_DEPTH_TEST glDisable
	
	| --- AO pass (+ blur) → ao_tex ---
	aopass
	
	| --- Lighting pass → scene_tex ---
	GL_FRAMEBUFFER rl_scene_fbo glBindFramebuffer
	0 0 rl_w rl_h glViewport
	
	$1800 0 'vcolorgl glClearBufferfv
	
	rl_sh_light glUseProgram
	GL_TEXTURE0 glActiveTexture GL_TEXTURE_2D rl_gbuf_norm   glBindTexture
	GL_TEXTURE1 glActiveTexture GL_TEXTURE_2D rl_gbuf_albedo glBindTexture
	$84C2       glActiveTexture GL_TEXTURE_2D rl_ao_tex      glBindTexture | GL_TEXTURE2
	GL_TEXTURE3 glActiveTexture GL_TEXTURE_2D rl_gbuf_depth  glBindTexture
	GL_TEXTURE4 glActiveTexture GL_TEXTURE_2D rl_shadow_tex  glBindTexture

	| --- Light pass
	lightpass

	| --- Pasada forward (transparentes) sobre scene_tex, antes del bloom ---
	rl_forward_hook 1? (
		GL_FRAMEBUFFER rl_fwd_fbo glBindFramebuffer
		0 0 rl_w rl_h glViewport
		dup ex
		rl_empty_vao glBindVertexArray
		GL_DEPTH_TEST glDisable
		GL_BLEND glDisable
		GL_TRUE glDepthMask
		GL_CULL_FACE glEnable
		GL_TEXTURE0 glActiveTexture ) drop
	
	| --- Bloom bright extraction ---
	bloompass

	| ---- Composite ----
	GL_FRAMEBUFFER aatarget glBindFramebuffer
	0 0 rl_w rl_h glViewport
	
	$1800 0 'vcolorgl glClearBufferfv
	
	rl_sh_composite glUseProgram
	GL_TEXTURE0 glActiveTexture GL_TEXTURE_2D rl_scene_tex glBindTexture
	GL_TEXTURE1 glActiveTexture GL_TEXTURE_2D 1 ]tex glBindTexture | bloom_texs[1]
	rl_u_composite_intensity 1 'RL_BLOOM_INTENSITY glUniform1fv
	rl_u_composite_exposure  1 'RL_EXPOSURE        glUniform1fv
	GL_TRIANGLES 0 3 glDrawArrays

	| ---- FXAA: ldr_tex -> pantalla ----
	rl_aa_on 0? ( drop ; ) drop
	GL_FRAMEBUFFER 0 glBindFramebuffer
	rl_sh_fxaa glUseProgram
	GL_TEXTURE0 glActiveTexture GL_TEXTURE_2D rl_ldr_tex glBindTexture
	GL_TRIANGLES 0 3 glDrawArrays
	;
