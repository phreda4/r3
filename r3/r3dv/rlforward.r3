| rlforward - pasada forward para renderlib, separada de ss3d
| PHREDA 2026
|
| Dibuja sprites de ss3d (voxeles) SIN pasar por el gbuffer: el fragment hace el DDA,
| ilumina ahi mismo (hemisferico + sol con sombra + luces puntuales, mismo modelo que el
| light pass) y mezcla con alpha. Tiene su propio shader, su propio DDA y su propia lista
| de instancias; de ss3d solo lee los sprites (SS3Dbinddata) y copia instancias.
|
| 1) TRANSPARENTES  (se dibujan solos dentro de rl_frame_end, despues del light pass)
|    fwd_reset                      al empezar el frame
|    ... fwd_set | x y z q scale spr color alpha --   (igual que ss3dset + alpha 0..255)
|    ... fwd_copy | i alpha --       copia la instancia i de ss3d (ya escrita con ss3dset)
|    'eye fwd_sort                  ordena de lejos a cerca ('eye = 3 celdas 16.16 de la camara)
|    El depth test es contra lo opaco (depth del gbuffer), no escriben depth.
|    El alpha de un sprite es uniforme y solo se ve la primera superficie (no sus caras traseras).
|
| 2) PREVIEW  (un sprite fuera de la escena, en su propia textura, luz minima)
|    sprite angulo fwd_preview      renderiza el sprite spr girado angulo (0..$ffff = vuelta)
|    margen fwd_show_tr             lo dibuja arriba a la derecha de la pantalla
|    x y fwd_show                   idem con la esquina inferior izquierda en x y
|    usar despues de rl_frame_end (no dentro de rl_frame_begin..end)
|
| fwd_init | maxinst size --      despues de rl_init y ss3dload  (size = lado de la textura de preview)
| fwd_end                         antes de rl_shutdown
|
| NOTA: el albedo se convierte de sRGB a lineal con el mismo #define que renderlib (ALBEDO_SRGB)
|       en el shader; si se cambia alla, cambiar aca.
^./renderlib.r3
^./ss3d.r3

|----------------------------------------------------------------
#rf_shader_src "
@vertex-----------------
#version 440 core

layout(location=0) in vec3 a_pos;

struct Instance {
	uint spr_obj;   // bits 15-0: spr_id | bits 23-16: alpha (0..255)
	uint color;
	uint scale3;    // scale x|y<<10|z<<20
	int  qxy;
	int  qzw;
	int  px, py, pz;
};
layout(std430,binding=4) readonly buffer InstanceTable { Instance instances[]; };

struct SpriteDef { uint org; uint sz; };
layout(std430,binding=2) readonly buffer SpriteDefTable { SpriteDef sprites[]; };

layout(std140,binding=0) uniform Matrices {
	mat4 view; mat4 proj; mat4 invView; mat4 invProj; mat4 ProjView; vec4 viewPos;
};

     out vec3  vRo;
     out vec3  vLocalPos;
flat out ivec3 vSize;
flat out mat3  vRot;
flat out vec3  vTrans;
flat out uint  vColorPk;
flat out int   vOrg;
flat out vec3  vScl;
flat out float vAlpha;

mat3 quatToMat3(vec4 q) {
	float x=q.x, y=q.y, z=q.z, w=q.w;
	float x2=x*x, y2=y*y, z2=z*z;
	float xy=x*y, xz=x*z, yz=y*z;
	float wx=w*x, wy=w*y, wz=w*z;
	return mat3(
		vec3(1.0-2.0*(y2+z2),    2.0*(xy+wz),  2.0*(xz-wy)),
		vec3(    2.0*(xy-wz),1.0-2.0*(x2+z2),  2.0*(yz+wx)),
		vec3(    2.0*(xz+wy),    2.0*(yz-wx),  1.0-2.0*(x2+y2))
	);
}

void main() {
	Instance inst = instances[gl_InstanceID];
	int   spr_id  = int(inst.spr_obj & 0xFFFFu);
	uint  sc3     = inst.scale3;
	vec3  scl3    = vec3(float(sc3 & 1023u), float((sc3 >> 10) & 1023u), float((sc3 >> 20) & 1023u)) * (1.0/32.0);
	SpriteDef spr = sprites[spr_id];

	vSize = ivec3(int(spr.sz & 255u), int((spr.sz >> 8) & 255u), int((spr.sz >> 16) & 255u));
	vec3 vExt = vec3(vSize) * (0.005 * scl3);

	const float kPos = 1.0/65536.0;
	vec3 trans = vec3(inst.px, inst.py, inst.pz) * kPos;

	vec4 q = vec4(
		float(inst.qxy << 16 >> 16),
		float(inst.qxy >> 16),
		float(inst.qzw << 16 >> 16),
		float(inst.qzw >> 16)
	);
	mat3 rot = quatToMat3(normalize(q));

	vec3 dw = viewPos.xyz - trans;
	vRo = vec3(dot(rot[0],dw), dot(rot[1],dw), dot(rot[2],dw));

	vec3 local_pos = a_pos * vExt;
	gl_Position = ProjView * vec4(rot*local_pos + trans, 1.0);
	vLocalPos = local_pos;
	vRot      = rot;
	vTrans    = trans;
	vColorPk  = inst.color;
	vOrg      = int(spr.org);
	vScl      = scl3;
	vAlpha    = float((inst.spr_obj >> 16) & 0xFFu) * (1.0/255.0);
}

@fragment---------------
#version 440 core
#extension GL_ARB_conservative_depth : enable

// ---- OPCIONES (mantener igual que el light pass de renderlib.r3) ------------
#define ALBEDO_SRGB
const vec3  UP_AXIS       = vec3(0.0, 1.0, 0.0);
const vec3  AMB_SKY       = vec3(0.20, 0.25, 0.35);
const vec3  AMB_GROUND    = vec3(0.06, 0.055, 0.05);
const float MIN_ROUGHNESS = 0.10;
const float GLOW[4] = float[4](0.0, 0.35, 1.2, 5.0);
// -----------------------------------------------------------------------------

layout(location=0) uniform int uLdr;     // 0 = HDR lineal (escena)   1 = LDR ACES+sRGB (preview)
layout(location=1) uniform vec2 uFade;   // x = distancia de corte, y = distancia donde ya es opaco (hits mas cerca que el near se recortan)

layout(std140,binding=0) uniform Matrices {
	mat4 view; mat4 proj; mat4 invView; mat4 invProj; mat4 ProjView; vec4 viewPos;
};
layout(std140, binding = 1) uniform DirectLight { vec4 lightDir; vec4 lightColor; };
layout(std140, binding = 3) uniform ShadowU { mat4 lightVP; vec4 ldir; vec4 sp; };
layout(binding = 4) uniform sampler2DShadow gShadow;
struct PointLight { vec4 pos; vec4 color; };
layout(std140, binding = 2) uniform PointLights { ivec4 header; PointLight lights[16]; } pl;

in  vec3  vRo;
in  vec3  vLocalPos;
flat in ivec3 vSize;
flat in mat3  vRot;
flat in vec3  vTrans;
flat in uint  vColorPk;
flat in int   vOrg;
flat in vec3  vScl;
flat in float vAlpha;

layout(std430,binding=6) readonly buffer Columns { uvec2 cols[]; };
layout(std430,binding=7) readonly buffer Palette { uint pal[]; };
layout(location=0) out vec4 FragColor;
// bbox con winding interior + CULL_FACE BACK: se rasterizan las caras lejanas, el hit queda mas cerca
layout(depth_greater) out float gl_FragDepth;

const float PI     = 3.14159265359;
const float INV_PI = 0.31830988618;
const float EPS    = 0.001;

float pow5(float x) { float x2 = x * x; return x2 * x2 * x; }

float DistributionGGX(float NdotH, float a2) {
	float d = NdotH * NdotH * (a2 - 1.0) + 1.0;
	return a2 / (PI * d * d + EPS);
}
float GeometrySchlickGGX(float NdotX, float k) {
	return NdotX / (NdotX * (1.0 - k) + k);
}
vec3 BRDF(vec3 N, vec3 V, vec3 L, float NdotV, float NdotL,
          vec3 albedo, float metallic, float a2, float k, vec3 F0)
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

vec3 ACES(vec3 x) {
	const float a=2.51, b=0.03, c=2.43, d=0.59, e=0.14;
	return clamp((x*(a*x+b))/(x*(c*x+d)+e), 0.0, 1.0);
}

vec4 shade(vec3 P, vec3 N, vec3 albedo, uint pk, float alpha, float fade) {
	float roughness = float((pk >> 5) & 7u) * (1.0/7.0);
	float metallic  = float((pk >> 2) & 7u) * (1.0/7.0);
	vec3  emissive  = albedo * GLOW[pk & 3u];
	roughness = max(roughness, MIN_ROUGHNESS);
	float a  = roughness * roughness;
	float a2 = a * a;
	float k  = (roughness + 1.0) * (roughness + 1.0) * 0.125;
	vec3  F0 = mix(vec3(0.04), albedo, metallic);
	vec3  V  = normalize(viewPos.xyz - P);
	float NdotV = max(dot(N, V), 0.0001);

	// ambiente (sin AO)
	vec3 hemi = mix(AMB_GROUND, AMB_SKY, dot(N, UP_AXIS) * 0.5 + 0.5);
	vec3 Rv   = reflect(-V, N);
	vec3 env  = mix(AMB_GROUND, AMB_SKY, dot(Rv, UP_AXIS) * 0.5 + 0.5);
	vec3 Fr   = F0 + (max(vec3(1.0 - roughness), F0) - F0) * pow5(1.0 - NdotV);
	vec3 color = hemi * albedo * (1.0 - metallic)
	           + env * Fr * (1.0 - 0.5 * roughness)
	           + emissive;

	// sol
	vec3  L     = normalize(lightDir.xyz);
	float NdotL = dot(N, L);
	if (NdotL > 0.0) {
		color += BRDF(N, V, L, NdotV, NdotL, albedo, metallic, a2, k, F0)
		       * lightColor.rgb * (lightColor.a * sunShadow(P, N));
	}

	// luces puntuales
	int numLights = min(pl.header.x, 16);
	for (int i = 0; i < numLights; ++i) {
		vec3  toLight = pl.lights[i].pos.xyz - P;
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
				float win  = clamp(1.0 - x * x, 0.0, 1.0);
				float att  = win * win / (1.0 + dist * (0.09 + 0.032 * dist));
				color += BRDF(N, V, Lp, NdotV, NdotLp, albedo, metallic, a2, k, F0)
				       * pl.lights[i].color.rgb * (pl.lights[i].color.a * att);
			}
		}
	}

	if (uLdr != 0) {
		color = ACES(color);
		color = mix(color * 12.92, 1.055 * pow(color, vec3(1.0/2.4)) - 0.055, step(vec3(0.0031308), color));
		return vec4(color, 1.0);
	}
	// el borde (angulo rasante) se ve mas opaco: ayuda a leer la forma
	float al = clamp(alpha + (1.0 - alpha) * pow5(1.0 - NdotV) * 0.6, 0.0, 1.0);
	return vec4(color, al * fade);
}

void main() {
	vec3 kScale = 100.0/vScl;
	int itw = vSize.x, iNF = vSize.y, ith = vSize.z;
	vec3 vExt = vec3(vSize) * (0.005 * vScl);

	vec3 vRd = vLocalPos - vRo;
	vec3 ir  = sign(vRd) / max(abs(vRd), vec3(1e-7));
	vec3 t0  = (-vExt - vRo) * ir;
	vec3 t1  = ( vExt - vRo) * ir;
	float tmin = max(max(max(min(t0.x,t1.x), min(t0.y,t1.y)), min(t0.z,t1.z)), 1e-5);
	float tmax = min(min(max(t0.x,t1.x), max(t0.y,t1.y)), max(t0.z,t1.z));
	if (tmin >= tmax) discard;

	vec3 d = vec3(vRd.x, -vRd.y, vRd.z) * kScale;
	vec3 e = vec3(
		 (vRo.x + vRd.x*tmin + vExt.x) * kScale.x,
		-(vRo.y + vRd.y*tmin + vExt.y) * kScale.y + float(iNF),
		 (vRo.z + vRd.z*tmin + vExt.z) * kScale.z);
	float tend = tmax - tmin;

	vec3 tmin3 = min(t0, t1);
	int axis = (tmin3.x>=tmin3.y && tmin3.x>=tmin3.z) ? 0 : (tmin3.y>=tmin3.z ? 1 : 2);

	ivec2 c  = clamp(ivec2(floor(e.x), floor(e.z)), ivec2(0), ivec2(itw, ith) - 1);
	ivec2 st = ivec2(d.x > 0.0 ? 1 : -1, d.z > 0.0 ? 1 : -1);
	vec2  dl = 1.0 / max(abs(d.xz), vec2(1e-7));
	vec2  nt = vec2(st.x > 0 ? float(c.x+1) - e.x : e.x - float(c.x),
	                st.y > 0 ? float(c.y+1) - e.z : e.z - float(c.y)) * dl;
	bool  down = d.y >= 0.0;
	float tin  = 0.0;

	for (int i = 0; i < 64; i++) {
		float tout = min(min(nt.x, nt.y), tend);
		float ya = e.y + d.y*tin, yb = e.y + d.y*tout;
		int lo = clamp(int(floor(min(ya, yb))), 0, iNF-1);
		int hi = clamp(int(floor(max(ya, yb))), 0, iNF-1);
		int n  = hi - lo + 1;
		uint mask = (n >= 32) ? 0xFFFFFFFFu : (((1u << n) - 1u) << lo);

		uvec2 col = cols[vOrg + c.y*itw + c.x];
		uint m = col.x & mask;
		if (m != 0u) {
			int cy = down ? findLSB(m) : findMSB(m);
			float ty = down ? (float(cy) - e.y)/d.y : (float(cy+1) - e.y)/d.y;
			float th = abs(d.y) < 1e-7 ? tin : clamp(ty, tin, tout);
			int ax = (th > tin) ? 1 : axis;

			vec3 signs   = vec3(-float(st.x), down ? 1.0 : -1.0, -float(st.y));
			vec3 n_local = signs * vec3(ax==0, ax==1, ax==2);
			vec3 world_n = vRot * n_local;
			vec3 world_hit = vRot*(vRo + vRd*(tmin + th)) + vTrans + world_n*0.0005;
			vec4 clip    = ProjView * vec4(world_hit, 1.0);
			// voxeles pegados a la camara (o con la camara adentro del volumen): se saltean y se desvanecen,
			// si no se ven como caras gigantes
			if (clip.w >= uFade.x) {
			gl_FragDepth = clip.z/clip.w;

			uint  pidx = ((col.y >> 24) == 1u) ? (col.y & 0xFFFFFFu) : (col.y + uint(cy));
			uint  vcol = pal[pidx];
			vec4  tint = unpackUnorm4x8(vColorPk).abgr;
			vec4  vc   = unpackUnorm4x8(vcol).abgr;
			uint  pk   = ((vColorPk & 0xFFu) != 0u) ? (vColorPk & 0xFFu) : (vcol & 0xFFu);
			vec3  albedo = vc.rgb * tint.rgb;
#ifdef ALBEDO_SRGB
			albedo = pow(albedo, vec3(2.2));
#endif
			FragColor = shade(world_hit, world_n, albedo, pk, vAlpha, smoothstep(uFade.x, uFade.y, clip.w));
			return;
			}
		}
		if (tout >= tend) break;
		if (nt.x < nt.y) { c.x += st.x; tin = nt.x; nt.x += dl.x; axis = 0; if (uint(c.x) >= uint(itw)) break; }
		else             { c.y += st.y; tin = nt.y; nt.y += dl.y; axis = 2; if (uint(c.y) >= uint(ith)) break; }
	}
	discard;
}
@-----"

#rf_blit_src "
@vertex-----------------
#version 440 core
out vec2 uv;
void main(){
	vec2 p = vec2((gl_VertexID << 1) & 2, gl_VertexID & 2);   // triangulo fullscreen, uv en [0,1]
	uv = p;
	gl_Position = vec4(p * 2.0 - 1.0, 0.0, 1.0);
}
@fragment---------------
#version 440 core
in vec2 uv;
out vec4 FragColor;
layout(binding=0) uniform sampler2D tex;
void main(){
	vec2 px = min(uv, 1.0 - uv) * vec2(textureSize(tex, 0));
	if (min(px.x, px.y) < 2.0) { FragColor = vec4(0.85, 0.87, 0.95, 1.0); return; }   // marco
	FragColor = vec4(texture(tex, uv).rgb, 1.0);
}
@-----"

|----------------------------------------------------------------
|--- estado
#fwd_max 0
##fwd_n 0
#fwd_array 0
#rf_prog 0
#rf_blit 0
#rf_ssbo 0
#rf_tid 0
#rf_fade 0 0			| uFade (2 floats)

|--- malla del bbox (igual que ss3d: winding interior)
#rf_vertices [	-1.0 -1.0 -1.0   1.0 -1.0 -1.0   1.0  1.0 -1.0  -1.0  1.0 -1.0
				-1.0 -1.0  1.0   1.0 -1.0  1.0   1.0  1.0  1.0  -1.0  1.0  1.0	]
#rf_indices [	0 1 2   0 2 3   4 6 5   4 7 6   0 7 4   0 3 7
				1 5 6   1 6 2   3 2 6   3 6 7   0 4 5   0 5 1 ]
#rf_vao #rf_vbo #rf_ebo

:rf_build_mesh
	24 'rf_vertices memfloat
	1 'rf_vao glGenVertexArrays
	rf_vao glBindVertexArray
	1 'rf_vbo glGenBuffers
	GL_ARRAY_BUFFER rf_vbo glBindBuffer
	GL_ARRAY_BUFFER 24 4 * 'rf_vertices GL_STATIC_DRAW glBufferData
	0 glEnableVertexAttribArray
	0 3 GL_FLOAT GL_FALSE 12 0 glVertexAttribPointer
	1 'rf_ebo glGenBuffers
	GL_ELEMENT_ARRAY_BUFFER rf_ebo glBindBuffer
	GL_ELEMENT_ARRAY_BUFFER 36 4 * 'rf_indices GL_STATIC_DRAW glBufferData
	0 glBindVertexArray
	GL_ARRAY_BUFFER 0 glBindBuffer
	GL_ELEMENT_ARRAY_BUFFER 0 glBindBuffer ;

|----------------------------------------------------------------
|--- lista de transparentes
::fwd_reset | --
	0 'fwd_n ! ;

| escala 5.5 fixed en 10 bits por eje (igual que ss3d)
:rf_enc10 | s -- v
	1024 + 11 >> $3ff and ;

:rf_rec | i -- adr
	5 << fwd_array + ;

::fwd_set | x y z q scale spr color alpha --
	ab[
	fwd_n fwd_max 1 - min rf_rec >a
	$ff and 16 << rot or da!+		| spr | alpha<<16
	da!+							| color
	rf_enc10 dup 10 << over 20 << or or da!+	| scale uniforme x|y<<10|z<<20
	a!+								| quaternion
	rot da!+ swap da!+ da!			| x y z
	]ba
	fwd_n fwd_max <? ( 1 'fwd_n +! ) drop ;

::fwd_copy | i alpha --
	fwd_n fwd_max >=? ( 3drop ; ) drop
	fwd_n rf_rec				| i alpha dst
	rot 5 << 3dss_array +		| alpha dst src
	over swap 4 move			| alpha dst
	dup d@ $ffff and			| alpha dst spr
	rot $ff and 16 << or		| dst v
	swap d!
	1 'fwd_n +! ;

|--- orden de lejos a cerca ** reemplazar por radixsort lib
#rf_ex #rf_ey #rf_ez
#rf_key * 16384			| claves (distancia^2), hasta 2048 instancias
#rf_tmp * 32
#rf_kk
#rf_cnt

:rf_key@ | i -- k
	3 << 'rf_key + @ ;
:rf_key! | k i --
	3 << 'rf_key + ! ;
:rf_dist | i -- d2
	5 << fwd_array + 20 + d@+ rf_ex - dup *.
	swap d@+ rf_ey - dup *. rot +
	swap d@ rf_ez - dup *. + ;

:rf_place | j --
	rf_kk over rf_key! rf_rec 'rf_tmp 4 move ;

:rf_ins | i --
	dup rf_key@ 'rf_kk !
	'rf_tmp over rf_rec 4 move
	( 1?
		dup 1 - rf_key@ rf_kk >=? ( drop rf_place ; )
		drop
		dup rf_rec over 1 - rf_rec 4 move
		dup 1 - rf_key@ over rf_key!
		1 - )
	rf_place ;

::fwd_sort | 'eye --
	@+ 'rf_ex ! @+ 'rf_ey ! @ 'rf_ez !
	fwd_n 2048 min 'rf_cnt !
	0 ( rf_cnt <? dup rf_dist over rf_key! 1 + ) drop
	1 ( rf_cnt <? dup rf_ins 1 + ) drop ;

:rf_setfade | near full --		; uFade del program activo
	'rf_fade 4 + d! 'rf_fade d!
	2 'rf_fade memfloat
	1 1 'rf_fade glUniform2fv ;

|--- pasada de la escena (hook de renderlib: fbo scene_tex + depth del gbuffer ya puestos)
:rf_scene_pass
	|fwd_n 0? ( drop ; ) drop
	|rf_prog 0? ( drop ; ) drop
	GL_SHADER_STORAGE_BUFFER rf_ssbo glBindBuffer
	GL_SHADER_STORAGE_BUFFER 0 fwd_n 5 << fwd_array glBufferSubData
	GL_SHADER_STORAGE_BUFFER 0 glBindBuffer
	GL_DEPTH_TEST glEnable
	GL_GREATER glDepthFunc
	GL_FALSE glDepthMask
	GL_CULL_FACE glEnable
	GL_BACK glCullFace
	GL_BLEND glEnable
	GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA glBlendFunc
	rf_prog glUseProgram
	0 0 glUniform1i
	camNear 2* camNear 6 * rf_setfade		| corte a 2x near, opaco a 6x near
	SS3Dbinddata
	GL_SHADER_STORAGE_BUFFER 4 rf_ssbo glBindBufferBase
	rf_vao glBindVertexArray
	GL_TRIANGLES 36 GL_UNSIGNED_INT 0 fwd_n glDrawElementsInstanced
	0 glBindVertexArray ;

|----------------------------------------------------------------
|--- PREVIEW
#rf_psize 256
#rf_ptex 0
#rf_pdep 0
#rf_pfbo 0
#rf_pssbo 0
#rf_ubo_m 0
#rf_ubo_s 0
#rf_ubo_p 0
#rf_ubo_h 0
#rf_pinst * 32
#rf_pcam * 400
#rf_proj * 128
#rf_psun * 32
#rf_zero * 528
#rf_bg * 16
#rf_eye 0 0 0
#rf_to 0 0 0
#rf_up 0 1.0 0

| textura 2D rf_psize x rf_psize, clamp (igual que rl_make_tex2d de renderlib)
:rf_texpar | v par -- v
	GL_TEXTURE_2D swap pick2 glTexParameteri ;

:rf_maketex | ifmt fmt type filter -- texid
	>r >r >r >r
	1 'rf_tid glGenTextures
	GL_TEXTURE_2D rf_tid glBindTexture
	GL_TEXTURE_2D 0 r> rf_psize dup 0 r> r> 0 glTexImage2D
	r> GL_TEXTURE_MIN_FILTER rf_texpar GL_TEXTURE_MAG_FILTER rf_texpar drop
	GL_CLAMP_TO_EDGE GL_TEXTURE_WRAP_S rf_texpar GL_TEXTURE_WRAP_T rf_texpar drop
	GL_TEXTURE_2D 0 glBindTexture
	rf_tid ;

:rf_makefbo | color depth -- fbo
	>r >r
	1 'rf_tid glGenFramebuffers
	GL_FRAMEBUFFER rf_tid glBindFramebuffer
	GL_FRAMEBUFFER GL_COLOR_ATTACHMENT0 GL_TEXTURE_2D r> 0 glFramebufferTexture2D
	GL_FRAMEBUFFER GL_DEPTH_ATTACHMENT  GL_TEXTURE_2D r> 0 glFramebufferTexture2D
	GL_FRAMEBUFFER 0 glBindFramebuffer
	rf_tid ;

:rf_makeubo | size 'data -- id
	>r
	1 'rf_tid glGenBuffers
	GL_UNIFORM_BUFFER rf_tid glBindBuffer
	GL_UNIFORM_BUFFER swap r> GL_DYNAMIC_DRAW glBufferData
	GL_UNIFORM_BUFFER 0 glBindBuffer
	rf_tid ;

:rf_preview_init | --
	GL_RGBA8 GL_RGBA GL_UNSIGNED_BYTE GL_LINEAR rf_maketex 'rf_ptex !
	GL_DEPTH_COMPONENT32F GL_DEPTH_COMPONENT GL_FLOAT GL_NEAREST rf_maketex 'rf_pdep !
	rf_ptex rf_pdep rf_makefbo 'rf_pfbo !
	1 'rf_pssbo glGenBuffers
	GL_SHADER_STORAGE_BUFFER rf_pssbo glBindBuffer
	GL_SHADER_STORAGE_BUFFER 32 0 GL_DYNAMIC_DRAW glBufferData
	GL_SHADER_STORAGE_BUFFER 0 glBindBuffer
	| fondo del preview
	'rf_bg >a
	0.10 f2fp da!+ 0.11 f2fp da!+ 0.14 f2fp da!+ 1.0 f2fp da!+
	| luz minima: un sol (el ambiente hemisferico es fijo en el shader), sin luces puntuales ni sombra
	'rf_psun >a
	0.55 f2fp da!+ 0.80 f2fp da!+ 0.60 f2fp da!+ 0 da!+
	1.0 f2fp da!+ 0.96 f2fp da!+ 0.90 f2fp da!+ 2.4 f2fp da!+
	400 'rf_pcam rf_makeubo 'rf_ubo_m !
	32 'rf_psun rf_makeubo 'rf_ubo_s !
	528 'rf_zero rf_makeubo 'rf_ubo_p !
	96 'rf_zero rf_makeubo 'rf_ubo_h ! ;

| UBOs del preview en los bindings 0..3 / los de la escena
:rf_pbind
	GL_UNIFORM_BUFFER 0 rf_ubo_m glBindBufferBase
	GL_UNIFORM_BUFFER 1 rf_ubo_s glBindBufferBase
	GL_UNIFORM_BUFFER 2 rf_ubo_p glBindBufferBase
	GL_UNIFORM_BUFFER 3 rf_ubo_h glBindBufferBase ;

:rf_punbind
	GL_UNIFORM_BUFFER 0 rl_ubo_matrices glBindBufferBase
	GL_UNIFORM_BUFFER 1 rl_ubo_dirlight glBindBufferBase
	GL_UNIFORM_BUFFER 2 rl_ubo_plights  glBindBufferBase
	GL_UNIFORM_BUFFER 3 rl_ubo_shadow   glBindBufferBase ;

| media diagonal del sprite a escala 1 (16.16)
:rf_radius | spr -- r
	dup ss3dLX dup *
	over ss3dLY dup * +
	swap ss3dLZ dup * +
	32 << sqrt 0.005 *. ;

| matrices de la camara del preview (solo ProjView y viewPos, que es lo que lee el shader)
:rf_camfill | --
	mat> >r
	3 'rf_eye 'rf_pcam 320 + mem2float
	mpush
	0.02 100.0 1.0 camFov mperspectiverz
	'rf_proj mcpy
	mpop
	mpush
	'rf_eye 'rf_to 'rf_up mlookat
	'rf_proj mm*
	'rf_pcam 256 + mcpyf
	r> 'mat> ! ;

:rf_pinstfill | spr ang --
	ab[
	'rf_pinst >a
	swap $ffff and $ff0000 or da!+		| spr | alpha 255
	$ffffff00 da!+						| color: el del voxel
	$2008020 da!+						| escala 1.0
	$ffff and 16 << rxyz>q16 a!+		| giro en y
	0 da!+ 0 da!+ 0 da!+
	]ba ;

::fwd_preview | spr ang --
	|rf_prog 0? ( 3drop ; ) drop
	| camara: encuadra el sprite segun su tamano
	over rf_radius 2.9 *. -rot rf_pinstfill
	dup 0.50 *. 'rf_eye !
	dup 0.40 *. 'rf_eye 8 + !
	0.75 *. 'rf_eye 16 + !
	rf_camfill
	GL_SHADER_STORAGE_BUFFER rf_pssbo glBindBuffer
	GL_SHADER_STORAGE_BUFFER 0 32 'rf_pinst glBufferSubData
	GL_SHADER_STORAGE_BUFFER 0 glBindBuffer
	rf_ubo_m 0 400 'rf_pcam glNamedBufferSubData
	GL_FRAMEBUFFER rf_pfbo glBindFramebuffer
	0 0 rf_psize dup glViewport
	GL_TRUE glDepthMask
	$1800 0 'rf_bg glClearBufferfv
	$1801 0 'rf_zero glClearBufferfv
	GL_DEPTH_TEST glEnable
	GL_GREATER glDepthFunc
	GL_BLEND glDisable
	GL_CULL_FACE glEnable
	GL_BACK glCullFace
	rf_pbind
	GL_TEXTURE4 glActiveTexture GL_TEXTURE_2D rl_shadow_tex glBindTexture
	GL_TEXTURE0 glActiveTexture
	rf_prog glUseProgram
	0 1 glUniform1i
	0.04 0.12 rf_setfade
	SS3Dbinddata
	GL_SHADER_STORAGE_BUFFER 4 rf_pssbo glBindBufferBase
	rf_vao glBindVertexArray
	GL_TRIANGLES 36 GL_UNSIGNED_INT 0 1 glDrawElementsInstanced
	0 glBindVertexArray
	rf_punbind
	GL_FRAMEBUFFER 0 glBindFramebuffer
	0 0 rl_w rl_h glViewport ;

::fwd_show | x y --		; esquina inferior izquierda del cuadro (origen abajo-izquierda)
	|rf_blit 0? ( 3drop ; ) drop
	GL_FRAMEBUFFER 0 glBindFramebuffer
	GL_DEPTH_TEST glDisable
	GL_BLEND glDisable
	rf_psize dup glViewport
	rf_blit glUseProgram
	GL_TEXTURE0 glActiveTexture GL_TEXTURE_2D rf_ptex glBindTexture
	rl_empty_vao glBindVertexArray
	GL_TRIANGLES 0 3 glDrawArrays
	0 glBindVertexArray
	0 0 rl_w rl_h glViewport ;

|----------------------------------------------------------------
::fwd_init | maxinst size --
	'rf_psize !
	'fwd_max !
	here 'fwd_array !
	fwd_max 5 << 'here +!
	'rf_shader_src loadShaderv 'rf_prog !
	'rf_blit_src loadShaderv 'rf_blit !
	rf_build_mesh
	1 'rf_ssbo glGenBuffers
	GL_SHADER_STORAGE_BUFFER rf_ssbo glBindBuffer
	GL_SHADER_STORAGE_BUFFER fwd_max 5 << 0 GL_DYNAMIC_DRAW glBufferData
	GL_SHADER_STORAGE_BUFFER 0 glBindBuffer
	rf_preview_init
	0 'fwd_n !
	'rf_scene_pass 'rl_forward_hook ! ;

::fwd_end | --			; glDelete* ignora el nombre 0
	0 'rl_forward_hook !
	rf_prog glDeleteProgram
	rf_blit glDeleteProgram
	1 'rf_ssbo glDeleteBuffers
	1 'rf_pssbo glDeleteBuffers
	1 'rf_ubo_m glDeleteBuffers
	1 'rf_ubo_s glDeleteBuffers
	1 'rf_ubo_p glDeleteBuffers
	1 'rf_ubo_h glDeleteBuffers
	1 'rf_pfbo glDeleteFramebuffers
	1 'rf_ptex glDeleteTextures
	1 'rf_pdep glDeleteTextures
	1 'rf_vao glDeleteVertexArrays
	1 'rf_vbo glDeleteBuffers
	1 'rf_ebo glDeleteBuffers
	0 'rf_prog ! 0 'rf_blit ! 0 'rf_ssbo ! 0 'rf_pssbo ! ;
