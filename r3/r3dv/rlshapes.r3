| rlshapes.r3 - Geometria + Impostors unificados
| Formas: cubo (geom) | esfera, capsula, cilindro, cono, disco, plano (impostors)
| PHREDA 2026
^./renderlib.r3
| NOTA: profundidad con glClipControl ZERO_TO_ONE -> gl_FragDepth = clip.z / clip.w

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


| ============================================================
| UNIFORMS (location explicita, no hace falta glGetUniformLocation)
|   0 model (mat4)   4 uRadius   5 uHeight   6 uPackColor   8 normalMatrix (mat3, solo cubo)
| Las constantes de cada primitiva (eje, largo, coeficientes de la
| ecuacion del rayo, color desempaquetado) se calculan en el vertex
| shader (4 vertices) y llegan al fragment como "flat", en vez de
| recalcularse en cada fragmento.
| ============================================================

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
layout(location=0) uniform mat4 model;
layout(location=6) uniform uint uPackColor;
layout(location=8) uniform mat3 normalMatrix;
out vec3 vNormal;
flat out vec4 vColor;
void main(){
    vNormal     = normalMatrix * aNormal;
    vColor      = unpackUnorm4x8(uPackColor).abgr;
    gl_Position = ProjView * (model * vec4(aPos, 1.0));
}
@fragment---------------
#version 440 core
in vec3 vNormal;
flat in vec4 vColor;
layout(location=0) out vec3 gNormal;
layout(location=1) out vec4 gAlbedo;
void main(){
    gNormal = normalize(vNormal);
    gAlbedo = vColor;
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
layout(location=0) uniform mat4  model;
layout(location=4) uniform float uRadius;
layout(location=6) uniform uint  uPackColor;
out vec3 vRayDir;
flat out vec3  vCenterView;
flat out float vInvR;
flat out float vC;          // |centro|^2 - r^2
flat out vec4  vColor;
void main(){
    vec3  ce = (view * model[3]).xyz;
    float wr = uRadius * length(vec3(model[0][0], model[1][0], model[2][0]));
    float d2 = dot(ce, ce);
    float c  = d2 - wr * wr;
    vCenterView = ce;
    vInvR  = 1.0 / wr;
    vC     = c;
    vColor = unpackUnorm4x8(uPackColor).abgr;
    float scale = wr * sqrt(d2 / max(c, 1e-6));
    vec3  cen = normalize(ce);
    vec3  up  = abs(cen.y) < 0.9 ? vec3(0.0, 1.0, 0.0) : vec3(1.0, 0.0, 0.0);
    vec3  rx  = normalize(cross(up, cen));
    vec3  ry  = cross(cen, rx);
    vec3  qv  = ce + (rx * aPos.x + ry * aPos.y) * scale;
    vRayDir     = qv;
    gl_Position = proj * vec4(qv, 1.0);
}
@fragment---------------
#version 440 core
in vec3 vRayDir;
flat in vec3  vCenterView;
flat in float vInvR;
flat in float vC;
flat in vec4  vColor;
layout(std140, binding=0) uniform Matrices {
    mat4 view; mat4 proj; mat4 invView; mat4 invProj; mat4 ProjView; vec4 viewPos; };
layout(location=0) out vec3 gNormal;
layout(location=1) out vec4 gAlbedo;
void main(){
    vec3  rd   = normalize(vRayDir);
    float b    = dot(vCenterView, rd);
    float disc = b * b - vC;
    if (disc < 0.0) discard;
    vec3  hitView = rd * (b - sqrt(disc));
    vec4  clip    = proj * vec4(hitView, 1.0);
    gl_FragDepth  = clip.z / clip.w;
    gNormal = mat3(invView) * ((hitView - vCenterView) * vInvR);   // ya es unitaria
    gAlbedo = vColor;
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
layout(location=0) uniform mat4  model;
layout(location=4) uniform float uRadius;
layout(location=5) uniform float uHeight;
layout(location=6) uniform uint  uPackColor;
out vec3  vRayDir;
flat out vec3  vAxisA; flat out vec3 vAxisB; flat out vec3 vAx; flat out vec3 vOp;
flat out float vInvR;  flat out float vLen;  flat out float vPA;
flat out float vC;     flat out float vCA;   flat out float vCB;
flat out vec4  vColor;
void main(){
    float halfH = uHeight * 0.5;
    mat4  mv    = view * model;
    vec3  sc    = vec3(length(model[0].xyz), length(model[1].xyz), length(model[2].xyz));
    float wr    = uRadius * max(sc.x, sc.z);
    float r2    = wr * wr;
    vec3  A     = (mv * vec4(0.0, -halfH, 0.0, 1.0)).xyz;
    vec3  B     = (mv * vec4(0.0,  halfH, 0.0, 1.0)).xyz;
    vec3  cv    = (mv * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
    vec3  ab    = B - A;
    float len   = length(ab);
    vec3  ax    = ab / max(len, 1e-6);
    float pa    = dot(A, ax);
    vec3  op    = pa * ax - A;                 // origen respecto del eje, sin la parte axial
    vAxisA = A; vAxisB = B; vAx = ax; vOp = op;
    vInvR  = 1.0 / wr; vLen = len; vPA = pa;
    vC     = dot(op, op) - r2;
    vCA    = dot(A, A) - r2;
    vCB    = dot(B, B) - r2;
    vColor = unpackUnorm4x8(uPackColor).abgr;
    float d     = length(cv);
    float wh    = halfH * sc.y;
    float total = wh + wr;
    float sc2   = (total + wr) / max(d - total, wr * 0.01) * d * 1.15;
    vec3  qv    = cv + vec3(aPos.x, aPos.y, 0.0) * sc2;
    vRayDir     = qv;
    gl_Position = proj * vec4(qv, 1.0);
}
@fragment---------------
#version 440 core
in vec3 vRayDir;
flat in vec3  vAxisA; flat in vec3 vAxisB; flat in vec3 vAx; flat in vec3 vOp;
flat in float vInvR;  flat in float vLen;  flat in float vPA;
flat in float vC;     flat in float vCA;   flat in float vCB;
flat in vec4  vColor;
layout(std140, binding=0) uniform Matrices {
    mat4 view; mat4 proj; mat4 invView; mat4 invProj; mat4 ProjView; vec4 viewPos; };
layout(location=0) out vec3 gNormal;
layout(location=1) out vec4 gAlbedo;
float hitSphere(vec3 rd, vec3 ce, float c){
    float b = dot(ce, rd);
    float d = b * b - c;
    if(d < 0.0) return 1e9;
    return b - sqrt(d);
}
void main(){
    vec3  rd  = normalize(vRayDir);
    float tBest = 1e9; vec3 nBest = vAx;
    float rdax = dot(rd, vAx);
    vec3  rp   = rd - rdax * vAx;
    float a    = dot(rp, rp);
    float b    = dot(rp, vOp);
    float disc = b * b - a * vC;
    if(disc >= 0.0 && a > 1e-6){
        float t = (-b - sqrt(disc)) / a;
        if(t > 0.0){
            float p = t * rdax - vPA;                 // = dot(rd*t - A, ax)
            if(p >= 0.0 && p <= vLen){
                tBest = t;
                nBest = (rd * t - vAxisA - vAx * p) * vInvR;
            }
        }
    }
    float tA = hitSphere(rd, vAxisA, vCA);
    if(tA < tBest && tA > 0.0){ tBest = tA; nBest = (rd * tA - vAxisA) * vInvR; }
    float tB = hitSphere(rd, vAxisB, vCB);
    if(tB < tBest && tB > 0.0){ tBest = tB; nBest = (rd * tB - vAxisB) * vInvR; }
    if(tBest >= 1e8) discard;
    vec3 hitView = rd * tBest;
    vec4 clip    = proj * vec4(hitView, 1.0);
    gl_FragDepth = clip.z / clip.w;
    gNormal = mat3(invView) * nBest;
    gAlbedo = vColor;
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
layout(location=0) uniform mat4  model;
layout(location=4) uniform float uRadius;
layout(location=5) uniform float uHeight;
layout(location=6) uniform uint  uPackColor;
out vec3  vRayDir;
flat out vec3  vAxisA; flat out vec3 vAx; flat out vec3 vOp;
flat out float vInvR;  flat out float vR2;  flat out float vLen;
flat out float vPA;    flat out float vPB;  flat out float vC;
flat out vec4  vColor;
void main(){
    float halfH = uHeight * 0.5;
    mat4  mv    = view * model;
    vec3  sc    = vec3(length(model[0].xyz), length(model[1].xyz), length(model[2].xyz));
    float wr    = uRadius * max(sc.x, sc.z);
    float r2    = wr * wr;
    vec3  A     = (mv * vec4(0.0, -halfH, 0.0, 1.0)).xyz;
    vec3  B     = (mv * vec4(0.0,  halfH, 0.0, 1.0)).xyz;
    vec3  cv    = (mv * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
    vec3  ab    = B - A;
    float len   = length(ab);
    vec3  ax    = ab / max(len, 1e-6);
    float pa    = dot(A, ax);
    vec3  op    = pa * ax - A;
    vAxisA = A; vAx = ax; vOp = op;
    vInvR  = 1.0 / wr; vR2 = r2; vLen = len;
    vPA    = pa; vPB = dot(B, ax);
    vC     = dot(op, op) - r2;
    vColor = unpackUnorm4x8(uPackColor).abgr;
    float d     = length(cv);
    float wh    = halfH * sc.y; float total = wh + wr;
    float sc2   = (total + wr) / max(d - total, wr * 0.01) * d * 1.15;
    vec3  qv    = cv + vec3(aPos.x, aPos.y, 0.0) * sc2;
    vRayDir     = qv;
    gl_Position = proj * vec4(qv, 1.0);
}
@fragment---------------
#version 440 core
in vec3 vRayDir;
flat in vec3  vAxisA; flat in vec3 vAx; flat in vec3 vOp;
flat in float vInvR;  flat in float vR2;  flat in float vLen;
flat in float vPA;    flat in float vPB;  flat in float vC;
flat in vec4  vColor;
layout(std140, binding=0) uniform Matrices {
    mat4 view; mat4 proj; mat4 invView; mat4 invProj; mat4 ProjView; vec4 viewPos; };
layout(location=0) out vec3 gNormal;
layout(location=1) out vec4 gAlbedo;
void main(){
    vec3  rd  = normalize(vRayDir);
    float tBest = 1e9; vec3 nBest = vAx;
    float rdax = dot(rd, vAx);
    vec3  rp   = rd - rdax * vAx;
    float a    = dot(rp, rp);
    float b    = dot(rp, vOp);
    float disc = b * b - a * vC;
    if(disc >= 0.0 && a > 1e-6){
        float t = (-b - sqrt(disc)) / a;
        if(t > 0.0){
            float p = t * rdax - vPA;
            if(p >= 0.0 && p <= vLen){
                tBest = t;
                nBest = (rd * t - vAxisA - vAx * p) * vInvR;
            }
        }
    }
    if(abs(rdax) > 1e-6){
        float invDA = 1.0 / rdax;
        float tCap  = vPA * invDA;                 // cap A: dot(A,ax)/rdax
        if(tCap > 0.0 && tCap < tBest){
            vec3 dif = rd * tCap - vAxisA;
            if(dot(dif, dif) <= vR2){ tBest = tCap; nBest = -vAx; }
        }
        tCap = vPB * invDA;                        // cap B
        if(tCap > 0.0 && tCap < tBest){
            vec3 dif = rd * tCap - (vAxisA + vAx * vLen);
            if(dot(dif, dif) <= vR2){ tBest = tCap; nBest = vAx; }
        }
    }
    if(tBest >= 1e8) discard;
    vec3 hitView = rd * tBest;
    vec4 clip    = proj * vec4(hitView, 1.0);
    gl_FragDepth = clip.z / clip.w;
    gNormal = mat3(invView) * nBest;
    gAlbedo = vColor;
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
layout(location=0) uniform mat4  model;
layout(location=4) uniform float uRadius;
layout(location=5) uniform float uHeight;
layout(location=6) uniform uint  uPackColor;
out vec3  vRayDir;
flat out vec3  vApex; flat out vec3 vBase; flat out vec3 vAx;
flat out float vR2;   flat out float vLen; flat out float vK; flat out float vKK1;
flat out float vCoo;  flat out float vC;   flat out float vPB;
flat out float vCH;   flat out float vCR;
flat out vec4  vColor;
void main(){
    float halfH = uHeight * 0.5;
    mat4  mv    = view * model;
    vec3  sc    = vec3(length(model[0].xyz), length(model[1].xyz), length(model[2].xyz));
    float R     = uRadius * max(sc.x, sc.z);
    float H     = uHeight * sc.y;
    vec3  apex  = (mv * vec4(0.0,  halfH, 0.0, 1.0)).xyz;
    vec3  base  = (mv * vec4(0.0, -halfH, 0.0, 1.0)).xyz;
    vec3  cv    = (mv * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
    vec3  ab    = base - apex;
    float len   = length(ab);
    vec3  ax    = ab / max(len, 1e-6);
    float k     = R / max(H, 1e-6);
    float kk1   = 1.0 + k * k;
    float coo   = -dot(apex, ax);                          // dot(-apex, ax)
    float hr    = inversesqrt(H * H + R * R);              // normal del lateral: (lat/|lat|)*H/hr - ax*R/hr
    vApex = apex; vBase = base; vAx = ax;
    vR2 = R * R; vLen = len; vK = k; vKK1 = kk1; vCoo = coo;
    vC  = dot(apex, apex) - kk1 * coo * coo;
    vPB = dot(base, ax);
    vCH = H * hr; vCR = R * hr;
    vColor = unpackUnorm4x8(uPackColor).abgr;
    float d     = length(cv);
    float total = H * 0.5 + R;
    float sc2   = (total + R) / max(d - total, R * 0.01) * d * 1.2;
    vec3  qv    = cv + vec3(aPos.x, aPos.y, 0.0) * sc2;
    vRayDir     = qv;
    gl_Position = proj * vec4(qv, 1.0);
}
@fragment---------------
#version 440 core
in vec3 vRayDir;
flat in vec3  vApex; flat in vec3 vBase; flat in vec3 vAx;
flat in float vR2;   flat in float vLen; flat in float vK; flat in float vKK1;
flat in float vCoo;  flat in float vC;   flat in float vPB;
flat in float vCH;   flat in float vCR;
flat in vec4  vColor;
layout(std140, binding=0) uniform Matrices {
    mat4 view; mat4 proj; mat4 invView; mat4 invProj; mat4 ProjView; vec4 viewPos; };
layout(location=0) out vec3 gNormal;
layout(location=1) out vec4 gAlbedo;
// impacto lateral valido en t: devuelve true y la normal (unitaria) si cae dentro del cono
bool side(vec3 rd, float rdd, float t, out vec3 nv){
    float p = t * rdd + vCoo;                   // distancia axial desde el apex
    if(p < 0.0 || p > vLen) return false;
    vec3 lat = rd * t - vApex - vAx * p;        // |lat| = k*p sobre la superficie
    nv = lat * (vCH / max(vK * p, 1e-6)) - vAx * vCR;
    return true;
}
void main(){
    vec3  rd  = normalize(vRayDir);
    float tBest = 1e9; vec3 nBest = vAx;
    float rdd  = dot(rd, vAx);
    float A    = 1.0 - vKK1 * rdd * rdd;        // dot(rd,rd) = 1
    float B    = -dot(rd, vApex) - vKK1 * rdd * vCoo;      // dot(rd,co) - kk1*rdd*coo, co = -apex
    float disc = B * B - A * vC;
    if(disc >= 0.0 && abs(A) > 1e-6){
        float sq   = sqrt(disc);
        float invA = 1.0 / A;
        float t0   = (-B - sq) * invA;
        vec3  nv;
        if(t0 > 0.0 && side(rd, rdd, t0, nv)){ tBest = t0; nBest = nv; }
        float t1 = (-B + sq) * invA;
        if(t1 > 0.0 && t1 < tBest && side(rd, rdd, t1, nv)){ tBest = t1; nBest = nv; }
    }
    // cap base plana
    if(abs(rdd) > 1e-6){
        float t = vPB / rdd;
        if(t > 0.0 && t < tBest){
            vec3 dif = rd * t - vBase;
            if(dot(dif, dif) <= vR2){ tBest = t; nBest = -vAx; }
        }
    }
    if(tBest >= 1e8) discard;
    vec3 hitView = rd * tBest;
    vec4 clip    = proj * vec4(hitView, 1.0);
    gl_FragDepth = clip.z / clip.w;
    gNormal = mat3(invView) * nBest;
    gAlbedo = vColor;
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
layout(location=0) uniform mat4  model;
layout(location=4) uniform float uRadius;
layout(location=6) uniform uint  uPackColor;
out vec3  vRayDir;
flat out vec3  vCenter; flat out vec3 vNormalV;
flat out float vDist;   flat out float vR2;
flat out vec4  vColor;
void main(){
    mat4  mv    = view * model;
    vec3  sc    = vec3(length(model[0].xyz), length(model[1].xyz), length(model[2].xyz));
    float wr    = uRadius * max(sc.x, sc.z);
    vec3  cv    = (mv * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
    vec3  n     = normalize((mv * vec4(0.0, 1.0, 0.0, 0.0)).xyz);
    vCenter = cv; vNormalV = n;
    vDist   = dot(cv, n);
    vR2     = wr * wr;
    vColor  = unpackUnorm4x8(uPackColor).abgr;
    float d     = length(cv);
    float sc2   = (wr + 0.01) / max(d - wr, wr * 0.01) * d * 1.2;
    vec3  qv    = cv + vec3(aPos.x, aPos.y, 0.0) * sc2;
    vRayDir     = qv;
    gl_Position = proj * vec4(qv, 1.0);
}
@fragment---------------
#version 440 core
in vec3 vRayDir;
flat in vec3  vCenter; flat in vec3 vNormalV;
flat in float vDist;   flat in float vR2;
flat in vec4  vColor;
layout(std140, binding=0) uniform Matrices {
    mat4 view; mat4 proj; mat4 invView; mat4 invProj; mat4 ProjView; vec4 viewPos; };
layout(location=0) out vec3 gNormal;
layout(location=1) out vec4 gAlbedo;
void main(){
    // el rayo no hace falta normalizarlo: t escala con el, y hit = rd*t es el mismo punto
    float dN = dot(vRayDir, vNormalV);
    if(abs(dN) < 1e-6) discard;
    float t = vDist / dN;
    if(t <= 0.0) discard;
    vec3 hit = vRayDir * t;
    vec3 dif = hit - vCenter;
    if(dot(dif, dif) > vR2) discard;
    vec4  clip   = proj * vec4(hit, 1.0);
    gl_FragDepth = clip.z / clip.w;
    gNormal = mat3(invView) * ((dN < 0.0) ? vNormalV : -vNormalV);
    gAlbedo = vColor;
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
layout(location=0) uniform mat4  model;
layout(location=4) uniform float uRadius;
layout(location=6) uniform uint  uPackColor;
out vec3 vRayDir;
flat out vec3  vCenter; flat out vec3 vNormalV; flat out vec3 vTan; flat out vec3 vBit;
flat out float vDist;   flat out float vHalfSize;
flat out vec4  vColor;
void main(){
    mat4  mv    = view * model;
    vec3  sc    = vec3(length(model[0].xyz), length(model[1].xyz), length(model[2].xyz));
    vec3  n     = normalize((mv * vec4(0.0, 1.0, 0.0, 0.0)).xyz);
    vec3  cv    = (mv * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
    vHalfSize   = (uRadius > 0.001) ? uRadius * max(sc.x, sc.z) : 500.0;
    vCenter = cv; vNormalV = n; vDist = dot(cv, n);
    vTan    = normalize(abs(n.x) < 0.9 ? cross(n, vec3(1.0, 0.0, 0.0))
                                       : cross(n, vec3(0.0, 1.0, 0.0)));
    vBit    = cross(n, vTan);
    vColor  = unpackUnorm4x8(uPackColor).abgr;
    gl_Position = vec4(aPos.x, aPos.y, 0.9999, 1.0);
    vec4 tmp    = invProj * vec4(aPos.x, aPos.y, 1.0, 1.0);
    vRayDir     = tmp.xyz / tmp.w;
}
@fragment---------------
#version 440 core
in vec3 vRayDir;
flat in vec3  vCenter; flat in vec3 vNormalV; flat in vec3 vTan; flat in vec3 vBit;
flat in float vDist;   flat in float vHalfSize;
flat in vec4  vColor;
layout(std140, binding=0) uniform Matrices {
    mat4 view; mat4 proj; mat4 invView; mat4 invProj; mat4 ProjView; vec4 viewPos; };
layout(location=0) out vec3 gNormal;
layout(location=1) out vec4 gAlbedo;
void main(){
    float dN = dot(vRayDir, vNormalV);            // rayo sin normalizar (ver disco)
    if(abs(dN) < 1e-6) discard;
    float t = vDist / dN;
    if(t <= 0.0) discard;
    vec3 hit = vRayDir * t;
    if(vHalfSize < 499.0){
        vec3 rel = hit - vCenter;
        if(abs(dot(rel, vTan)) > vHalfSize) discard;
        if(abs(dot(rel, vBit)) > vHalfSize) discard;
    }
    vec4  clip   = proj * vec4(hit, 1.0);
    gl_FragDepth = clip.z / clip.w;
    gNormal = mat3(invView) * ((dN < 0.0) ? vNormalV : -vNormalV);
    gAlbedo = vColor;
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

| Copiar mat actual y enviar como uniform "model" (location 0)
:imp_model
    'fmodel 'mat cpymatif
    0 1 GL_FALSE 'fmodel glUniformMatrix4fv ;

| ============================================================
| INIT
| ============================================================

::IniShapes
    | Cubo
    'shader_geom     loadShaderv 'sh_geom     !
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
    6 swap glUniform1ui
    'fmodel 'mat cpymatif
    matinv
    'fnormal 'mati cpymatif3
    0 1 GL_FALSE 'fmodel  glUniformMatrix4fv
    8 1 GL_FALSE 'fnormal glUniformMatrix3fv
    g_cube_vao glBindVertexArray
    GL_TRIANGLES 36 GL_UNSIGNED_INT 0 glDrawElements ;

| --- ESFERA impostor | radius rgbmm -- ---
::draw_sphere | radius rgbmm --
    sh_sphere glUseProgram
    6 swap glUniform1ui
    imp_model
    f2fp 'rp1 d!
    4 1 'rp1 glUniform1fv
    imp_draw ;

| --- CAPSULA impostor | radius height rgbmm -- ---
::draw_capsule | radius height rgbmm --
    sh_capsule glUseProgram
    6 swap glUniform1ui
    imp_model
    f2fp 'rp2 d!
    f2fp 'rp1 d!
    4 1 'rp1 glUniform1fv
    5 1 'rp2 glUniform1fv
    imp_draw ;

| --- CILINDRO impostor | radius height rgbmm -- ---
::draw_cylinder | radius height rgbmm --
    sh_cylinder glUseProgram
    6 swap glUniform1ui
    imp_model
    f2fp 'rp2 d!
    f2fp 'rp1 d!
    4 1 'rp1 glUniform1fv
    5 1 'rp2 glUniform1fv
    imp_draw ;

| --- CONO impostor | radius height rgbmm -- ---
::draw_cone | radius height rgbmm --
    sh_cone glUseProgram
    6 swap glUniform1ui
    imp_model
    f2fp 'rp2 d!
    f2fp 'rp1 d!
    4 1 'rp1 glUniform1fv
    5 1 'rp2 glUniform1fv
    imp_draw ;

| --- DISCO impostor | radius rgbmm -- ---
::draw_disc | radius rgbmm --
    sh_disc glUseProgram
    6 swap glUniform1ui
    imp_model
    f2fp 'rp1 d!
    4 1 'rp1 glUniform1fv
    imp_draw ;

| --- PLANO impostor | halfsize rgbmm -- ---
::draw_plane | halfsize rgbmm --
    sh_plane glUseProgram
    6 swap glUniform1ui
    imp_model
    f2fp 'rp1 d!
    4 1 'rp1 glUniform1fv
    imp_draw ;
