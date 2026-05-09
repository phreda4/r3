| rlshapes.r3 - Geometria + Impostors unificados
| Formas: cubo (geom) | esfera, capsula, cilindro, cono, disco, plano (impostors)
| PHREDA 2026
^./renderlib.r3

| ============================================================
| HANDLES DE SHADERS
| ============================================================

#sh_geom     0
#sh_sphere   0
#sh_capsule  0
#sh_cylinder 0
#sh_cone     0
#sh_disc     0
#sh_plane    0

| Uniforms geometria (cubo)
#u_geom_model   -1
#u_geom_color   -1
#u_geom_normal  -1

| ============================================================
| SHADER - GEOMETRIA (cubo)
| ============================================================

#shader_geom "
@vertex-----------------
#version 440 core
layout(location=0) in vec3 aPos;
layout(location=1) in vec3 aNormal;
layout(std140, binding=0) uniform Matrices {
    mat4 view; mat4 proj; mat4 invView; mat4 invProj; mat4 ProjView; vec4 viewPos; };
uniform mat4 model;
uniform mat3 normalMatrix;
out vec3 vPos; out vec3 vNormal;
void main(){
    vec4 wp = model * vec4(aPos, 1.0);
    vPos    = wp.xyz;
    vNormal = normalMatrix * aNormal;
    gl_Position = ProjView * wp;
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
                   float( uPackColor     &0xFFu)) / 255.0;
}
@-----------------------"

| ============================================================
| SHADER - ESFERA IMPOSTOR
| ============================================================

#shader_sphere "
@vertex-----------------
#version 440 core
layout(location=0) in vec3 aPos;
layout(std140, binding=0) uniform Matrices {
    mat4 view; mat4 proj; mat4 invView; mat4 invProj; mat4 ProjView; vec4 viewPos; };
uniform mat4  model;
uniform float uRadius;
out vec3  vRayDir; out vec3 vCenterView; out float vRadius;
void main(){
    vec4 cv = view * model * vec4(0.0, 0.0, 0.0, 1.0);
    vCenterView = cv.xyz;
    float wr = uRadius * length(vec3(model[0][0], model[1][0], model[2][0]));
    vRadius  = wr;
    float d2    = dot(cv.xyz, cv.xyz);
    float scale = wr * sqrt(d2 / max(d2 - wr * wr, 1e-6)) * 1.1;
    vec3  qv    = cv.xyz + vec3(aPos.x, aPos.y, 0.0) * scale;
    vRayDir     = qv;
    gl_Position = proj * vec4(qv, 1.0);
}
@fragment---------------
#version 440 core
in vec3 vRayDir; in vec3 vCenterView; in float vRadius;
uniform uint uPackColor;
layout(std140, binding=0) uniform Matrices {
    mat4 view; mat4 proj; mat4 invView; mat4 invProj; mat4 ProjView; vec4 viewPos; };
layout(location=0) out vec3 gNormal;
layout(location=1) out vec4 gAlbedo;
void main(){
    vec3  rd   = normalize(vRayDir);
    vec3  oc   = -vCenterView;
    float b    = dot(oc, rd);
    float c    = dot(oc, oc) - vRadius * vRadius;
    float disc = b * b - c;
    if (disc < 0.0) discard;
    float t       = -b - sqrt(disc);
    vec3  hitView = rd * t;
    vec3  nView   = normalize(hitView - vCenterView);
    vec3  nWorld  = normalize((invView * vec4(nView, 0.0)).xyz);
    vec4  clip    = proj * vec4(hitView, 1.0);
    gl_FragDepth  = clip.z / clip.w * 0.5 + 0.5;
    gNormal = nWorld;
    gAlbedo = vec4(float((uPackColor>>24)&0xFFu),
                   float((uPackColor>>16)&0xFFu),
                   float((uPackColor>> 8)&0xFFu),
                   float( uPackColor     &0xFFu)) / 255.0;
}
@-----------------------"

| ============================================================
| SHADER - CAPSULA IMPOSTOR
| Cilindro con caps esfericas. Eje Y. uRadius=radio, uHeight=altura total
| ============================================================

#shader_capsule "
@vertex-----------------
#version 440 core
layout(location=0) in vec3 aPos;
layout(std140, binding=0) uniform Matrices {
    mat4 view; mat4 proj; mat4 invView; mat4 invProj; mat4 ProjView; vec4 viewPos; };
uniform mat4  model;
uniform float uRadius;
uniform float uHeight;
out vec3  vRayDir; out vec3 vAxisA; out vec3 vAxisB; out float vRadius;
void main(){
    float halfH = uHeight * 0.5;
    vec3  sc    = vec3(length(model[0].xyz), length(model[1].xyz), length(model[2].xyz));
    float wr    = uRadius * max(sc.x, sc.z);
    vRadius     = wr;
    vAxisA      = (view * model * vec4(0.0, -halfH, 0.0, 1.0)).xyz;
    vAxisB      = (view * model * vec4(0.0,  halfH, 0.0, 1.0)).xyz;
    vec4  cv    = view * model * vec4(0.0, 0.0, 0.0, 1.0);
    float d     = length(cv.xyz);
    float wh    = halfH * sc.y;
    float total = wh + wr;
    float sc2   = (total + wr) / max(d - total, 0.01) * d * 1.15;
    vec3  qv    = cv.xyz + vec3(aPos.x, aPos.y, 0.0) * sc2;
    vRayDir     = qv;
    gl_Position = proj * vec4(qv, 1.0);
}
@fragment---------------
#version 440 core
in vec3 vRayDir; in vec3 vAxisA; in vec3 vAxisB; in float vRadius;
uniform uint uPackColor;
layout(std140, binding=0) uniform Matrices {
    mat4 view; mat4 proj; mat4 invView; mat4 invProj; mat4 ProjView; vec4 viewPos; };
layout(location=0) out vec3 gNormal;
layout(location=1) out vec4 gAlbedo;
float hitSphere(vec3 rd, vec3 ce, float r){
    vec3 oc = -ce; float b = dot(oc,rd); float c = dot(oc,oc)-r*r;
    float d = b*b-c; if(d<0.0) return 1e9; return -b-sqrt(d);
}
void main(){
    vec3  rd  = normalize(vRayDir);
    vec3  ab  = vAxisB - vAxisA;
    float len = length(ab);
    vec3  ax  = ab / max(len, 1e-6);
    float tBest = 1e9; vec3 nBest = ax;
    //| cilindro
    vec3  rp = rd - dot(rd,ax)*ax;
    vec3  op = -vAxisA - dot(-vAxisA, ax)*ax;
    float a  = dot(rp,rp); float b = dot(rp,op);
    float c  = dot(op,op) - vRadius*vRadius;
    float disc = b*b - a*c;
    if(disc >= 0.0 && a > 1e-6){
        float t = (-b - sqrt(disc)) / a;
        if(t > 0.0){
            vec3  hit = rd*t; float p = dot(hit - vAxisA, ax);
            if(p >= 0.0 && p <= len){ tBest = t; nBest = normalize(hit - vAxisA - ax*p); }
        }
    }
    //| caps esfericas
    float tA = hitSphere(rd, vAxisA, vRadius);
    if(tA < tBest && tA > 0.0){ tBest = tA; nBest = normalize(rd*tA - vAxisA); }
    float tB = hitSphere(rd, vAxisB, vRadius);
    if(tB < tBest && tB > 0.0){ tBest = tB; nBest = normalize(rd*tB - vAxisB); }
    if(tBest >= 1e8) discard;
    vec3 hitView = rd * tBest;
    vec3 nWorld  = normalize((invView * vec4(nBest, 0.0)).xyz);
    vec4 clip    = proj * vec4(hitView, 1.0);
    gl_FragDepth = clip.z / clip.w * 0.5 + 0.5;
    gNormal = nWorld;
    gAlbedo = vec4(float((uPackColor>>24)&0xFFu),
                   float((uPackColor>>16)&0xFFu),
                   float((uPackColor>> 8)&0xFFu),
                   float( uPackColor     &0xFFu)) / 255.0;
}
@-----------------------"

| ============================================================
| SHADER - CILINDRO IMPOSTOR
| Igual que capsula pero caps planas. Eje Y.
| ============================================================

#shader_cylinder "
@vertex-----------------
#version 440 core
layout(location=0) in vec3 aPos;
layout(std140, binding=0) uniform Matrices {
    mat4 view; mat4 proj; mat4 invView; mat4 invProj; mat4 ProjView; vec4 viewPos; };
uniform mat4  model;
uniform float uRadius;
uniform float uHeight;
out vec3  vRayDir; out vec3 vAxisA; out vec3 vAxisB; out float vRadius;
void main(){
    float halfH = uHeight * 0.5;
    vec3  sc    = vec3(length(model[0].xyz), length(model[1].xyz), length(model[2].xyz));
    vRadius     = uRadius * max(sc.x, sc.z);
    vAxisA      = (view * model * vec4(0.0, -halfH, 0.0, 1.0)).xyz;
    vAxisB      = (view * model * vec4(0.0,  halfH, 0.0, 1.0)).xyz;
    vec4  cv    = view * model * vec4(0.0, 0.0, 0.0, 1.0);
    float d     = length(cv.xyz);
    float wh    = halfH * sc.y; float total = wh + vRadius;
    float sc2   = (total + vRadius) / max(d - total, 0.01) * d * 1.15;
    vec3  qv    = cv.xyz + vec3(aPos.x, aPos.y, 0.0) * sc2;
    vRayDir     = qv;
    gl_Position = proj * vec4(qv, 1.0);
}
@fragment---------------
#version 440 core
in vec3 vRayDir; in vec3 vAxisA; in vec3 vAxisB; in float vRadius;
uniform uint uPackColor;
layout(std140, binding=0) uniform Matrices {
    mat4 view; mat4 proj; mat4 invView; mat4 invProj; mat4 ProjView; vec4 viewPos; };
layout(location=0) out vec3 gNormal;
layout(location=1) out vec4 gAlbedo;
void main(){
    vec3  rd  = normalize(vRayDir);
    vec3  ab  = vAxisB - vAxisA;
    float len = length(ab);
    vec3  ax  = ab / max(len, 1e-6);
    float tBest = 1e9; vec3 nBest = ax;
    // cuerpo
    vec3  rp = rd - dot(rd,ax)*ax;
    vec3  op = -vAxisA - dot(-vAxisA,ax)*ax;
    float a  = dot(rp,rp); float b = dot(rp,op);
    float c  = dot(op,op) - vRadius*vRadius;
    float disc = b*b - a*c;
    if(disc >= 0.0 && a > 1e-6){
        float t = (-b - sqrt(disc)) / a;
        if(t > 0.0){
            vec3 hit = rd*t; float p = dot(hit - vAxisA, ax);
            if(p >= 0.0 && p <= len){ tBest = t; nBest = normalize(hit - vAxisA - ax*p); }
        }
    }
    // caps planas
    float dA = dot(rd, ax);
    if(abs(dA) > 1e-6){
        float t = dot(vAxisA, ax) / dA;
        if(t > 0.0 && t < tBest){
            vec3 hit = rd*t;
            if(length(hit - vAxisA) <= vRadius){ tBest = t; nBest = -ax; }
        }
        t = dot(vAxisB, ax) / dA;
        if(t > 0.0 && t < tBest){
            vec3 hit = rd*t;
            if(length(hit - vAxisB) <= vRadius){ tBest = t; nBest = ax; }
        }
    }
    if(tBest >= 1e8) discard;
    vec3 hitView = rd * tBest;
    vec3 nWorld  = normalize((invView * vec4(nBest, 0.0)).xyz);
    vec4 clip    = proj * vec4(hitView, 1.0);
    gl_FragDepth = clip.z / clip.w * 0.5 + 0.5;
    gNormal = nWorld;
    gAlbedo = vec4(float((uPackColor>>24)&0xFFu),
                   float((uPackColor>>16)&0xFFu),
                   float((uPackColor>> 8)&0xFFu),
                   float( uPackColor     &0xFFu)) / 255.0;
}
@-----------------------"

| ============================================================
| SHADER - CONO IMPOSTOR
| Apex en Y=+uHeight/2, base en Y=-uHeight/2, radio=uRadius
| ============================================================

#shader_cone "
@vertex-----------------
#version 440 core
layout(location=0) in vec3 aPos;
layout(std140, binding=0) uniform Matrices {
    mat4 view; mat4 proj; mat4 invView; mat4 invProj; mat4 ProjView; vec4 viewPos; };
uniform mat4  model;
uniform float uRadius;
uniform float uHeight;
out vec3  vRayDir; out vec3 vApex; out vec3 vBase; out float vRadius; out float vHeight;
void main(){
    float halfH = uHeight * 0.5;
    vec3  sc    = vec3(length(model[0].xyz), length(model[1].xyz), length(model[2].xyz));
    vRadius     = uRadius * max(sc.x, sc.z);
    vHeight     = uHeight * sc.y;
    vApex       = (view * model * vec4(0.0,  halfH, 0.0, 1.0)).xyz;
    vBase       = (view * model * vec4(0.0, -halfH, 0.0, 1.0)).xyz;
    vec4  cv    = view * model * vec4(0.0, 0.0, 0.0, 1.0);
    float d     = length(cv.xyz);
    float total = vHeight * 0.5 + vRadius;
    float sc2   = (total + vRadius) / max(d - total, 0.01) * d * 1.2;
    vec3  qv    = cv.xyz + vec3(aPos.x, aPos.y, 0.0) * sc2;
    vRayDir     = qv;
    gl_Position = proj * vec4(qv, 1.0);
}
@fragment---------------
#version 440 core
in vec3 vRayDir; in vec3 vApex; in vec3 vBase; in float vRadius; in float vHeight;
uniform uint uPackColor;
layout(std140, binding=0) uniform Matrices {
    mat4 view; mat4 proj; mat4 invView; mat4 invProj; mat4 ProjView; vec4 viewPos; };
layout(location=0) out vec3 gNormal;
layout(location=1) out vec4 gAlbedo;
void main(){
    vec3  rd  = normalize(vRayDir);
    vec3  ab  = vBase - vApex;
    float len = length(ab);
    vec3  ax  = ab / max(len, 1e-6);
    float k   = vRadius / max(vHeight, 1e-6);
    float tBest = 1e9; vec3 nBest = ax;
    // superficie del cono (cuadrica)
    vec3  co  = -vApex;
    float rdd = dot(rd, ax); float coo = dot(co, ax);
    float A   = dot(rd,rd) - (1.0+k*k)*rdd*rdd;
    float B   = dot(rd,co) - (1.0+k*k)*rdd*coo;
    float C   = dot(co,co) - (1.0+k*k)*coo*coo;
    float disc = B*B - A*C;
    if(disc >= 0.0 && abs(A) > 1e-6){
        float sq = sqrt(disc);
        for(int i=0; i<2; i++){
            float t = (i==0) ? (-B-sq)/A : (-B+sq)/A;
            if(t > 0.0 && t < tBest){
                vec3  hit  = rd*t;
                float p    = dot(hit - vApex, ax);
                if(p >= 0.0 && p <= len){
                    vec3 lat = hit - vApex - ax*p;
                    vec3 nv  = normalize(lat - ax*(k*length(lat)));
                    tBest = t; nBest = nv;
                }
            }
        }
    }
    // cap base plana
    float dA = dot(rd, ax);
    if(abs(dA) > 1e-6){
        float t = dot(vBase, ax) / dA;
        if(t > 0.0 && t < tBest){
            vec3 hit = rd*t;
            if(length(hit - vBase) <= vRadius){ tBest = t; nBest = -ax; }
        }
    }
    if(tBest >= 1e8) discard;
    vec3 hitView = rd * tBest;
    vec3 nWorld  = normalize((invView * vec4(nBest, 0.0)).xyz);
    vec4 clip    = proj * vec4(hitView, 1.0);
    gl_FragDepth = clip.z / clip.w * 0.5 + 0.5;
    gNormal = nWorld;
    gAlbedo = vec4(float((uPackColor>>24)&0xFFu),
                   float((uPackColor>>16)&0xFFu),
                   float((uPackColor>> 8)&0xFFu),
                   float( uPackColor     &0xFFu)) / 255.0;
}
@-----------------------"

| ============================================================
| SHADER - DISCO IMPOSTOR
| Circulo plano doble cara. Normal = eje Y del model.
| ============================================================

#shader_disc "
@vertex-----------------
#version 440 core
layout(location=0) in vec3 aPos;
layout(std140, binding=0) uniform Matrices {
    mat4 view; mat4 proj; mat4 invView; mat4 invProj; mat4 ProjView; vec4 viewPos; };
uniform mat4  model;
uniform float uRadius;
out vec3  vRayDir; out vec3 vCenter; out vec3 vNormalV; out float vRadius;
void main(){
    vec3 sc  = vec3(length(model[0].xyz), length(model[1].xyz), length(model[2].xyz));
    vRadius  = uRadius * max(sc.x, sc.z);
    vec4 cv  = view * model * vec4(0.0, 0.0, 0.0, 1.0);
    vCenter  = cv.xyz;
    vNormalV = normalize((view * model * vec4(0.0, 1.0, 0.0, 0.0)).xyz);
    float d  = length(cv.xyz);
    float sc2 = (vRadius + 0.01) / max(d - vRadius, 0.01) * d * 1.2;
    vec3  qv  = cv.xyz + vec3(aPos.x, aPos.y, 0.0) * sc2;
    vRayDir   = qv;
    gl_Position = proj * vec4(qv, 1.0);
}
@fragment---------------
#version 440 core
in vec3 vRayDir; in vec3 vCenter; in vec3 vNormalV; in float vRadius;
uniform uint uPackColor;
layout(std140, binding=0) uniform Matrices {
    mat4 view; mat4 proj; mat4 invView; mat4 invProj; mat4 ProjView; vec4 viewPos; };
layout(location=0) out vec3 gNormal;
layout(location=1) out vec4 gAlbedo;
void main(){
    vec3  rd = normalize(vRayDir);
    float dN = dot(rd, vNormalV);
    if(abs(dN) < 1e-6) discard;
    float t  = dot(vCenter, vNormalV) / dN;
    if(t <= 0.0) discard;
    vec3  hit = rd * t;
    if(length(hit - vCenter) > vRadius) discard;
    vec3  nv     = (dN < 0.0) ? vNormalV : -vNormalV;
    vec3  nWorld = normalize((invView * vec4(nv, 0.0)).xyz);
    vec4  clip   = proj * vec4(hit, 1.0);
    gl_FragDepth = clip.z / clip.w * 0.5 + 0.5;
    gNormal = nWorld;
    gAlbedo = vec4(float((uPackColor>>24)&0xFFu),
                   float((uPackColor>>16)&0xFFu),
                   float((uPackColor>> 8)&0xFFu),
                   float( uPackColor     &0xFFu)) / 255.0;
}
@-----------------------"

| ============================================================
| SHADER - PLANO IMPOSTOR
| uRadius = half-size acotado (0 = infinito/grande)
| Normal = eje Y del model. Ocupa todo el clip space.
| ============================================================

#shader_plane "
@vertex-----------------
#version 440 core
layout(location=0) in vec3 aPos;
layout(std140, binding=0) uniform Matrices {
    mat4 view; mat4 proj; mat4 invView; mat4 invProj; mat4 ProjView; vec4 viewPos; };
uniform mat4  model;
uniform float uRadius;
out vec3 vRayDir; out vec3 vCenter; out vec3 vNormalV; out float vHalfSize;
void main(){
    vec3 sc   = vec3(length(model[0].xyz), length(model[1].xyz), length(model[2].xyz));
    vHalfSize = (uRadius > 0.001) ? uRadius * max(sc.x, sc.z) : 500.0;
    vCenter   = (view * model * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
    vNormalV  = normalize((view * model * vec4(0.0, 1.0, 0.0, 0.0)).xyz);
    gl_Position = vec4(aPos.x, aPos.y, 0.9999, 1.0);
    vRayDir     = (invProj * vec4(aPos.x, aPos.y, 1.0, 1.0)).xyz;
}
@fragment---------------
#version 440 core
in vec3 vRayDir; in vec3 vCenter; in vec3 vNormalV; in float vHalfSize;
uniform uint uPackColor;
layout(std140, binding=0) uniform Matrices {
    mat4 view; mat4 proj; mat4 invView; mat4 invProj; mat4 ProjView; vec4 viewPos; };
layout(location=0) out vec3 gNormal;
layout(location=1) out vec4 gAlbedo;
void main(){
    vec3  rd = normalize(vRayDir);
    float dN = dot(rd, vNormalV);
    if(abs(dN) < 1e-6) discard;
    float t  = dot(vCenter, vNormalV) / dN;
    if(t <= 0.0) discard;
    vec3 hit = rd * t;
    vec3 rel = hit - vCenter;
    if(vHalfSize < 499.0){
        if(abs(rel.x) > vHalfSize || abs(rel.y) > vHalfSize) discard;
    }
    vec3  nv     = (dN < 0.0) ? vNormalV : -vNormalV;
    vec3  nWorld = normalize((invView * vec4(nv, 0.0)).xyz);
    vec4  clip   = proj * vec4(hit, 1.0);
    gl_FragDepth = clip.z / clip.w * 0.5 + 0.5;
    gNormal = nWorld;
    gAlbedo = vec4(float((uPackColor>>24)&0xFFu),
                   float((uPackColor>>16)&0xFFu),
                   float((uPackColor>> 8)&0xFFu),
                   float( uPackColor     &0xFFu)) / 255.0;
}
@-----------------------"

| ============================================================
| MALLA CUBO (24 vertices pos+normal, 36 indices)
| ============================================================

#verts [
-0.5  -0.5  -0.5  0 0 -1.0   0.5  -0.5  -0.5  0 0 -1.0
 0.5   0.5  -0.5  0 0 -1.0  -0.5   0.5  -0.5  0 0 -1.0
-0.5  -0.5   0.5  0 0  1.0   0.5  -0.5   0.5  0 0  1.0
 0.5   0.5   0.5  0 0  1.0  -0.5   0.5   0.5  0 0  1.0
-0.5   0.5   0.5  -1.0 0 0  -0.5   0.5  -0.5  -1.0 0 0
-0.5  -0.5  -0.5  -1.0 0 0  -0.5  -0.5   0.5  -1.0 0 0
 0.5   0.5   0.5   1.0 0 0   0.5   0.5  -0.5   1.0 0 0
 0.5  -0.5  -0.5   1.0 0 0   0.5  -0.5   0.5   1.0 0 0
-0.5  -0.5  -0.5  0 -1.0 0   0.5  -0.5  -0.5  0 -1.0 0
 0.5  -0.5   0.5  0 -1.0 0  -0.5  -0.5   0.5  0 -1.0 0
-0.5   0.5  -0.5  0  1.0 0   0.5   0.5  -0.5  0  1.0 0
 0.5   0.5   0.5  0  1.0 0  -0.5   0.5   0.5  0  1.0 0
]

#idx [
 0  2  1  0  3  2   4  5  6  4  6  7   8  9 10  8 10 11
12 14 13 12 15 14  16 17 18 16 18 19  20 22 21 20 23 22
]

| Quad billboard - compartido por TODOS los impostors
#sp_verts [
-1.0 -1.0  0.0
 1.0 -1.0  0.0
-1.0  1.0  0.0
 1.0  1.0  0.0
]

| ============================================================
| GPU OBJECTS
| ============================================================

#g_cube_vao  #g_cube_vbo  #g_cube_ebo
#g_quad_vao  #g_quad_vbo

| Buffers CPU
#fmodel  * 64   | mat4
#fnormal * 36   | mat3
#rp1         | float param1 (radius)
#rp2         | float param2 (height)

| ============================================================
| HELPER INTERNO - draw del quad billboard
| ============================================================

:imp_draw
    GL_CULL_FACE glDisable
    g_quad_vao glBindVertexArray
    GL_TRIANGLE_STRIP 0 4 glDrawArrays
    GL_CULL_FACE glEnable
    0 glBindVertexArray ;

| Copiar mat actual y enviar como uniform "model" del shader dado
:imp_model | shader --
    'fmodel 'mat cpymatif
    "model" glGetUniformLocation 1 GL_FALSE 'fmodel glUniformMatrix4fv ;

| ============================================================
| INIT
| ============================================================

::IniShapes
    | Cubo
    'shader_geom     loadShaderv 'sh_geom     !
    sh_geom "model"        glGetUniformLocation 'u_geom_model  !
    sh_geom "uPackColor"   glGetUniformLocation 'u_geom_color  !
    sh_geom "normalMatrix" glGetUniformLocation 'u_geom_normal !
    0 sh_geom "Matrices"   rl_bind_ubo
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
    | Quad compartido
    4 3 * 'sp_verts memfloat
    1 'g_quad_vao glGenVertexArrays
    1 'g_quad_vbo glGenBuffers
    g_quad_vao glBindVertexArray
    GL_ARRAY_BUFFER g_quad_vbo glBindBuffer
    GL_ARRAY_BUFFER 4 3 * 4 * 'sp_verts GL_STATIC_DRAW glBufferData
    0 glEnableVertexAttribArray
    0 3 GL_FLOAT GL_FALSE 3 4 * 0 glVertexAttribPointer
    0 glBindVertexArray
    | Impostors
    'shader_sphere   loadShaderv 'sh_sphere   !
    'shader_capsule  loadShaderv 'sh_capsule  !
    'shader_cylinder loadShaderv 'sh_cylinder !
    'shader_cone     loadShaderv 'sh_cone     !
    'shader_disc     loadShaderv 'sh_disc     !
    'shader_plane    loadShaderv 'sh_plane    !
    0 sh_sphere   "Matrices" rl_bind_ubo
    0 sh_capsule  "Matrices" rl_bind_ubo
    0 sh_cylinder "Matrices" rl_bind_ubo
    0 sh_cone     "Matrices" rl_bind_ubo
    0 sh_disc     "Matrices" rl_bind_ubo
    0 sh_plane    "Matrices" rl_bind_ubo
    ;

::endShapes
    sh_geom glDeleteProgram  sh_sphere glDeleteProgram
    sh_capsule glDeleteProgram  sh_cylinder glDeleteProgram
    sh_cone glDeleteProgram  sh_disc glDeleteProgram  sh_plane glDeleteProgram
    1 'g_cube_vao glDeleteVertexArrays  1 'g_cube_vbo glDeleteBuffers
    1 'g_cube_ebo glDeleteBuffers
    1 'g_quad_vao glDeleteVertexArrays  1 'g_quad_vbo glDeleteBuffers
    ;

| ============================================================
| API PUBLICA
| Convencion: draw_xxx recibe los parametros de la forma
| y el color empaquetado (rgbmm) al final.
| ============================================================

| --- CUBO (geometria) | rgbmm -- ---
::draw_cube | rgbmm --
    sh_geom glUseProgram
    u_geom_color swap glUniform1ui
    'fmodel 'mat cpymatif
    matinv
    'fnormal 'mati cpymatif3
    u_geom_model  1 GL_FALSE 'fmodel  glUniformMatrix4fv
    u_geom_normal 1 GL_FALSE 'fnormal glUniformMatrix3fv
    g_cube_vao glBindVertexArray
    GL_TRIANGLES 36 GL_UNSIGNED_INT 0 glDrawElements ;

| --- ESFERA impostor | radius rgbmm -- ---
::draw_sphere | radius rgbmm --
    sh_sphere glUseProgram
    sh_sphere "uPackColor" glGetUniformLocation swap glUniform1ui
    sh_sphere imp_model
    f2fp 'rp1 d!
    sh_sphere "uRadius"    glGetUniformLocation 1 'rp1 glUniform1fv
    imp_draw ;

| --- CAPSULA impostor | radius height rgbmm -- ---
::draw_capsule | radius height rgbmm --
    sh_capsule glUseProgram
    sh_capsule "uPackColor" glGetUniformLocation swap glUniform1ui
    sh_capsule imp_model
    f2fp 'rp2 d!
    f2fp 'rp1 d!
    sh_capsule "uRadius" glGetUniformLocation 1 'rp1 glUniform1fv
    sh_capsule "uHeight" glGetUniformLocation 1 'rp2 glUniform1fv
    imp_draw ;

| --- CILINDRO impostor | radius height rgbmm -- ---
::draw_cylinder | radius height rgbmm --
    sh_cylinder glUseProgram
    sh_cylinder "uPackColor" glGetUniformLocation swap glUniform1ui
    sh_cylinder imp_model
    f2fp 'rp2 d!
    f2fp 'rp1 d!
    sh_cylinder "uRadius" glGetUniformLocation 1 'rp1 glUniform1fv
    sh_cylinder "uHeight" glGetUniformLocation 1 'rp2 glUniform1fv
    imp_draw ;

| --- CONO impostor | radius height rgbmm -- ---
::draw_cone | radius height rgbmm --
    sh_cone glUseProgram
    sh_cone "uPackColor" glGetUniformLocation swap glUniform1ui
    sh_cone imp_model
    f2fp 'rp2 d!
    f2fp 'rp1 d!
    sh_cone "uRadius" glGetUniformLocation 1 'rp1 glUniform1fv
    sh_cone "uHeight" glGetUniformLocation 1 'rp2 glUniform1fv
    imp_draw ;

| --- DISCO impostor | radius rgbmm -- ---
::draw_disc | radius rgbmm --
    sh_disc glUseProgram
    sh_disc "uPackColor" glGetUniformLocation swap glUniform1ui
    f2fp 'rp1 d!
    sh_disc imp_model
    sh_disc "uRadius" glGetUniformLocation 1 'rp1 glUniform1fv
    imp_draw ;

| --- PLANO impostor | halfsize rgbmm -- ---
::draw_plane | halfsize rgbmm --
    sh_plane glUseProgram
    sh_plane "uPackColor" glGetUniformLocation swap glUniform1ui
    f2fp 'rp1 d!
    sh_plane imp_model
    sh_plane "uRadius" glGetUniformLocation 1 'rp1 glUniform1fv
    imp_draw ;