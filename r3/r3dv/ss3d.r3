| ss3d2 - sprites 3d de voxeles, formato .ssv (columnas de bits + tira de colores)
| PHREDA 2026 
|
| "archivo" n ss3dload     carga archivo.ssv (generado por vox2x.r3), n = maximo de instancias
| "archivo" ss3loadnames   carga archivo.txt (nombres)
|
| sombras: usar ss3dshadow.r3
|
| el shader recorre solo X/Z (DDA 2D) y resuelve el rango Y con la mascara de 32 bits
|   texel de columna (x,z) = columnas[atlasIndex + z*sizeX + x] = (mascara, base)
|   color del voxel y = tira[base + y]          (y = capa, 0 = arriba)
^r3/lib/str.r3

##n3dsprites	| cnt sprites
#3dss_max		| max instances
##3dss_array	| instances array

#ss3d_inst

#ss3d_shader

| * color  --  packed material:  0xRRGGBBuma
| *   bits 31-24  R
| *   bits 23-16  G
| *   bits 15- 8  B
| *   bits  7- 5  u  roughness (3 bits)
| *   bits  4- 2  m  metallic  (3 bits)
| *   bits  1- 0  a  glow      (2 bits)
| * instancia: RGB multiplica al color del voxel; uma != 0 reemplaza al del voxel

#ss3d_shader_src "
@vertex-----------------
#version 440 core

layout(location=0) in vec3 a_pos;

struct Instance {
	uint spr_obj;   // bits 15-0: spr_id uint16 | bits 31-16: obj_id uint16
	uint color;
    uint scale3;    // scale x|y<<10|z<<20
    int  qxy;       // int16 qx (lo) | int16 qy (hi)
    int  qzw;       // int16 qz (lo) | int16 qw (hi)
    int  px, py, pz;
};
layout(std430,binding=4) readonly buffer InstanceTable { Instance instances[]; };

struct SpriteDef {
    uint org;       // indice de la primera columna
    uint sz;        // bytes: sizeX | sizeY (capas) << 8 | sizeZ << 16
};
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

    const float kPos  = 1.0/65536.0;

    vec3 trans = vec3(inst.px, inst.py, inst.pz) * kPos;

    // unpack quat 16+16 bits
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
    vLocalPos   = local_pos;
    vRot        = rot;
    vTrans      = trans;
    vColorPk    = inst.color;
    vOrg        = int(spr.org);
	vScl=scl3;
}

@fragment---------------
#version 440 core
#extension GL_ARB_conservative_depth : enable

layout(std140,binding=0) uniform Matrices {
    mat4 view; mat4 proj; mat4 invView; mat4 invProj; mat4 ProjView; vec4 viewPos;
};

in  vec3  vRo;
in  vec3  vLocalPos;
flat in ivec3 vSize;
flat in mat3  vRot;
flat in vec3  vTrans;
flat in uint  vColorPk;
flat in int   vOrg;
flat in vec3  vScl;

layout(std430,binding=6) readonly buffer Columns { uvec2 cols[]; };   // x: mascara  y: base en la tira
layout(std430,binding=7) readonly buffer Palette { uint pal[]; };     // tira de colores
layout(location=0) out vec3 gNormal;
layout(location=1) out vec4 gAlbedo;
// El bbox esta definido al reves (winding interior) y con CULL_FACE BACK se rasterizan
// las caras LEJANAS. El hit queda mas cerca => reverse-Z => profundidad mayor => depth_greater.
// NO cambiar a depth_less ni limitar con gl_FragCoord.z (aplanaria la profundidad del sprite).
layout(depth_greater) out float gl_FragDepth;

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

    // rayo en la grilla (x, y = capa desde arriba, z), unidades de voxel por t
    vec3 d = vec3(vRd.x, -vRd.y, vRd.z) * kScale;
    vec3 e = vec3(
         (vRo.x + vRd.x*tmin + vExt.x) * kScale.x,
        -(vRo.y + vRd.y*tmin + vExt.y) * kScale.y + float(iNF),
         (vRo.z + vRd.z*tmin + vExt.z) * kScale.z);
    float tend = tmax - tmin;

    vec3 tmin3 = min(t0, t1);
    int axis = (tmin3.x>=tmin3.y && tmin3.x>=tmin3.z) ? 0 : (tmin3.y>=tmin3.z ? 1 : 2);   // cara por la que entra a la caja

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

        uvec2 col = cols[vOrg + c.y*itw + c.x];       // una lectura: ocupacion + base de colores
        uint m = col.x & mask;
        if (m != 0u) {
            int cy = down ? findLSB(m) : findMSB(m);
            float ty = down ? (float(cy) - e.y)/d.y : (float(cy+1) - e.y)/d.y;
            float th = abs(d.y) < 1e-7 ? tin : clamp(ty, tin, tout);
            int ax = (th > tin) ? 1 : axis;               // golpe dentro de la columna = cara horizontal

            vec3 signs   = vec3(-float(st.x), down ? 1.0 : -1.0, -float(st.y));
            vec3 n_local = signs * vec3(ax==0, ax==1, ax==2);
            vec3 world_n = vRot * n_local;
            vec3 world_hit = vRot*(vRo + vRd*(tmin + th)) + vTrans + world_n*0.0005;
            vec4 clip    = ProjView * vec4(world_hit, 1.0);
            gl_FragDepth = clip.z/clip.w;   // clip ZERO_TO_ONE

            gNormal = world_n;
            uint  vcol = pal[col.y + uint(cy)];           // base + y (aritmetica uint32)
            vec4  tint = unpackUnorm4x8(vColorPk).abgr;
            vec4  vc   = unpackUnorm4x8(vcol).abgr;
            uint  pk   = ((vColorPk & 0xFFu) != 0u) ? (vColorPk & 0xFFu) : (vcol & 0xFFu);
            gAlbedo = vec4(vc.rgb*tint.rgb, float(pk) * (1.0/255.0));
            return;
        }
        if (tout >= tend) break;
        if (nt.x < nt.y) { c.x += st.x; tin = nt.x; nt.x += dl.x; axis = 0; if (uint(c.x) >= uint(itw)) break; }
        else             { c.y += st.y; tin = nt.y; nt.y += dl.y; axis = 2; if (uint(c.y) >= uint(ith)) break; }
    }
    discard;
}
@-----"

##defspr		| tabla de sprites (8 bytes: atlasIndex | sizeX sizeY sizeZ 0)
#colbase #palbase #ncols #ncolors

#ss3d_shadow_src "
@vertex-----------------
#version 440 core

layout(location=0) in vec3 a_pos;

struct Instance {
	uint spr_obj;
	uint color;
    uint scale3;
    int  qxy;
    int  qzw;
    int  px, py, pz;
};
layout(std430,binding=4) readonly buffer InstanceTable { Instance instances[]; };

struct SpriteDef {
    uint org;
    uint sz;
};
layout(std430,binding=2) readonly buffer SpriteDefTable { SpriteDef sprites[]; };

layout(std140,binding=3) uniform ShadowU {
    mat4 lightVP;
    vec4 ldir;      // xyz: direccion de los rayos de luz (hacia la escena)
    vec4 sp;
};

     out vec3  vLocalPos;
flat out ivec3 vSize;
flat out mat3  vRot;
flat out vec3  vTrans;
flat out vec3  vScl;
flat out vec3  vLd;
flat out int   vOrg;

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

    vec3 trans = vec3(inst.px, inst.py, inst.pz) * (1.0/65536.0);
    vec4 q = vec4(
        float(inst.qxy << 16 >> 16),
        float(inst.qxy >> 16),
        float(inst.qzw << 16 >> 16),
        float(inst.qzw >> 16)
    );
    mat3 rot = quatToMat3(normalize(q));

    vec3 local_pos = a_pos * vExt;
    gl_Position = lightVP * vec4(rot*local_pos + trans, 1.0);
    vLocalPos = local_pos;
    vRot      = rot;
    vTrans    = trans;
    vScl      = scl3;
    vOrg      = int(spr.org);
    vLd       = vec3(dot(rot[0],ldir.xyz), dot(rot[1],ldir.xyz), dot(rot[2],ldir.xyz));
}

@fragment---------------
#version 440 core

layout(std140,binding=3) uniform ShadowU {
    mat4 lightVP;
    vec4 ldir;
    vec4 sp;
};

in  vec3  vLocalPos;
flat in ivec3 vSize;
flat in mat3  vRot;
flat in vec3  vTrans;
flat in vec3  vScl;
flat in vec3  vLd;
flat in int   vOrg;

layout(std430,binding=6) readonly buffer Columns { uvec2 cols[]; };   // x: mascara de 32 bits

// e: entrada (grilla, y desde arriba)  d: grilla por unidad de t  tend: largo del tramo
// recorre solo X/Z (DDA 2D) y resuelve el rango Y con la mascara de la columna
bool colTrace(vec3 e, vec3 d, float tend, out float th)
{
    ivec3 g  = vSize;
    ivec2 c  = clamp(ivec2(floor(e.x), floor(e.z)), ivec2(0), g.xz - 1);
    ivec2 st = ivec2(d.x > 0.0 ? 1 : -1, d.z > 0.0 ? 1 : -1);
    vec2  dl = 1.0 / max(abs(d.xz), vec2(1e-7));
    vec2  nt = vec2(st.x > 0 ? float(c.x+1) - e.x : e.x - float(c.x),
                    st.y > 0 ? float(c.y+1) - e.z : e.z - float(c.y)) * dl;
    float tin = 0.0;
    bool up = d.y >= 0.0;
    th = 0.0;
    for (int i = 0; i < 64; i++) {
        float tout = min(min(nt.x, nt.y), tend);
        float ya = e.y + d.y*tin, yb = e.y + d.y*tout;
        int lo = clamp(int(floor(min(ya, yb))), 0, g.y-1);
        int hi = clamp(int(floor(max(ya, yb))), 0, g.y-1);
        int n  = hi - lo + 1;
        uint mask = (n >= 32) ? 0xFFFFFFFFu : (((1u << n) - 1u) << lo);
        uint m = cols[vOrg + c.y*g.x + c.x].x & mask;
        if (m != 0u) {
            int cy = up ? findLSB(m) : findMSB(m);
            float t = up ? (float(cy) - e.y)/d.y : (float(cy+1) - e.y)/d.y;
            th = (abs(d.y) < 1e-7) ? tin : clamp(t, tin, tout);
            return true;
        }
        if (tout >= tend) break;
        if (nt.x < nt.y) { c.x += st.x; tin = nt.x; nt.x += dl.x; if (uint(c.x) >= uint(g.x)) break; }
        else             { c.y += st.y; tin = nt.y; nt.y += dl.y; if (uint(c.y) >= uint(g.z)) break; }
    }
    return false;
}

void main() {
    vec3 vExt = vec3(vSize) * (0.005 * vScl);
    vec3 rd = normalize(vLd);
    vec3 ro = vLocalPos - rd * (2.0 * length(vExt));      // origen fuera de la caja, detras

    vec3 ir = sign(rd) / max(abs(rd), vec3(1e-7));
    vec3 t0 = (-vExt - ro) * ir;
    vec3 t1 = ( vExt - ro) * ir;
    float tmin = max(max(max(min(t0.x,t1.x), min(t0.y,t1.y)), min(t0.z,t1.z)), 1e-5);
    float tmax = min(min(max(t0.x,t1.x), max(t0.y,t1.y)), max(t0.z,t1.z));
    if (tmin >= tmax) discard;

    vec3 ks = 100.0 / vScl;
    vec3 p  = ro + rd * tmin;
    vec3 e  = vec3((p.x + vExt.x) * ks.x,
                   float(vSize.y) - (p.y + vExt.y) * ks.y,
                   (p.z + vExt.z) * ks.z);
    vec3 d  = vec3(rd.x * ks.x, -rd.y * ks.y, rd.z * ks.z);

    float th;
    if (!colTrace(e, d, tmax - tmin, th)) discard;

    vec4 clip = lightVP * vec4(vRot * (ro + rd * (tmin + th)) + vTrans, 1.0);
    gl_FragDepth = clip.z / clip.w;
}
@-----"

##ss3dshS 0		| sin reduccion de grilla (lo usa ss3dshadow.r3 para el bias)
#ss3d_shsh

|----GPU
#ssbo_sprites
#ssbo_cols
#ssbo_pal
#ssbo_inst

#vertices [	-1.0 -1.0 -1.0   1.0 -1.0 -1.0   1.0  1.0 -1.0  -1.0  1.0 -1.0 
			-1.0 -1.0  1.0   1.0 -1.0  1.0   1.0  1.0  1.0  -1.0  1.0  1.0	]
#indices [	0 1 2   0 2 3   4 6 5   4 7 6   0 7 4   0 3 7
			1 5 6   1 6 2   3 2 6   3 6 7   0 4 5   0 5 1 ]
#bbox_vao #bbox_vbo #bbox_ibo

:build_bbox
	24 'vertices memfloat
	1 'bbox_vao glGenVertexArrays
	bbox_vao glBindVertexArray
	1 'bbox_vbo glGenBuffers
	GL_ARRAY_BUFFER bbox_vbo glBindBuffer
	GL_ARRAY_BUFFER 24 4 * 'vertices GL_STATIC_DRAW glBufferData
	0 glEnableVertexAttribArray
	0 3 GL_FLOAT GL_FALSE 12 0 glVertexAttribPointer
	1 'bbox_ibo glGenBuffers
	GL_ELEMENT_ARRAY_BUFFER bbox_ibo glBindBuffer
	GL_ELEMENT_ARRAY_BUFFER 36 4 * 'indices GL_STATIC_DRAW glBufferData
	0 glBindVertexArray
	GL_ARRAY_BUFFER 0 glBindBuffer
	GL_ELEMENT_ARRAY_BUFFER 0 glBindBuffer
	;

::ss3dmem | instances --	; imagen .ssv ya armada en here (mismo formato que el archivo)
	'3dss_max !
	build_bbox
|====== .ssv  (header 16: "SSV2" nspr ncol ncolores)
	here 
	d@+ "SSV2" d@ <>? ( 2drop "not ssv file" .println ; ) drop
	d@+ 'n3dsprites !
	d@+ 'ncols !
	d@+ 'ncolors !
	dup 'defspr !
	n3dsprites 3 << + dup 'colbase !
	ncols 3 << + 'palbase !
|====== sprite definitions (binding 2)
	1 'ssbo_sprites glGenBuffers
	GL_SHADER_STORAGE_BUFFER ssbo_sprites glBindBuffer
	GL_SHADER_STORAGE_BUFFER n3dsprites 3 << defspr 0 glBufferStorage
	GL_SHADER_STORAGE_BUFFER 2 ssbo_sprites glBindBufferBase
|====== columns (binding 6)
	1 'ssbo_cols glGenBuffers
	GL_SHADER_STORAGE_BUFFER ssbo_cols glBindBuffer
	GL_SHADER_STORAGE_BUFFER ncols 3 << colbase GL_DYNAMIC_STORAGE_BIT glBufferStorage
	GL_SHADER_STORAGE_BUFFER 6 ssbo_cols glBindBufferBase
|====== color strip (binding 7)
	1 'ssbo_pal glGenBuffers
	GL_SHADER_STORAGE_BUFFER ssbo_pal glBindBuffer
	GL_SHADER_STORAGE_BUFFER ncolors 2 << palbase GL_DYNAMIC_STORAGE_BIT glBufferStorage
	GL_SHADER_STORAGE_BUFFER 7 ssbo_pal glBindBufferBase
|====== instance mem
	1 'ssbo_inst glGenBuffers
	GL_SHADER_STORAGE_BUFFER ssbo_inst glBindBuffer
	GL_SHADER_STORAGE_BUFFER 3dss_max 5 << 0 GL_DYNAMIC_DRAW glBufferData |32*
	GL_SHADER_STORAGE_BUFFER 4 ssbo_inst glBindBufferBase
	GL_SHADER_STORAGE_BUFFER 0 glBindBuffer
|====== compile shader
	'ss3d_shader_src loadShaderv 'ss3d_shader !
|====== solo queda en memoria la tabla de sprites
	colbase 'here !
|====== reserve mem for instance
	here '3dss_array !
	3dss_max 5 << | 32*
	'here +!			| 32 bytes x inst
	0 'ss3d_inst !
	;

::ss3dload | "file" instances --
	swap here swap "%s.ssv" sprint load drop
	ss3dmem ;

|--- sprites dinamicos: columnas (mask|base, 8 bytes) y tira de colores (4 bytes) modificables
#upo #upb #upm
:ssbosub | off bytes 'mem buf --
	GL_SHADER_STORAGE_BUFFER swap glBindBuffer
	'upm ! 'upb ! 'upo !
	GL_SHADER_STORAGE_BUFFER upo upb upm glBufferSubData
	GL_SHADER_STORAGE_BUFFER 0 glBindBuffer ;

::ss3dupcols | off bytes 'mem --	; sube bytes de columnas (off en bytes desde la primera columna)
	ssbo_cols ssbosub ;

::ss3duppal | off bytes 'mem --	; sube bytes de la tira de colores
	ssbo_pal ssbosub ;

##ss3names

::ss3loadnames | "" --
	here dup 'ss3names !
	swap "%s.txt" sprint load
	0 swap c!+ 'here !
	ss3names dup >a
	trim ( c@+ 1? $ff and 
		10 =? ( 0 ca!+ ) | linux store 10 only
		31 >? ( dup ca!+ )
		drop ) 2drop
	0 a> c!+ 'here !
	;

::ss3idname | name -- id
	ss3names
	0 ( n3dsprites <? swap
		pick2 =pre 1? ( 2drop nip ; ) drop
		>>0 trim
		swap 1+ ) 3drop
	-1 ;

::ssnameid | id -- name
	ss3names swap ( 1? 1- swap >>0 trim swap ) drop ;

::SS3Dshadowbuild | --	; shadow shader.. after ss3dload
	'ss3d_shadow_src loadShaderv 'ss3d_shsh ! ;

::SS3Dshadowdraw | --	; draw inst in active fbo UBO ShadowU en binding 3
	ss3d_inst 0? ( drop ; ) drop
	ss3d_shsh 0? ( drop ; ) drop
	GL_SHADER_STORAGE_BUFFER 2 ssbo_sprites glBindBufferBase
	GL_SHADER_STORAGE_BUFFER 4 ssbo_inst glBindBufferBase
	GL_SHADER_STORAGE_BUFFER 6 ssbo_cols glBindBufferBase
	GL_DEPTH_TEST glEnable
	GL_CULL_FACE glEnable
	GL_BACK glCullFace
	GL_LESS glDepthFunc
	GL_TRUE glDepthMask
	ss3d_shsh glUseProgram
	bbox_vao glBindVertexArray
	GL_TRIANGLES 36 GL_UNSIGNED_INT 0 ss3d_inst glDrawElementsInstanced
	0 glBindVertexArray
	;

::SS3Dshutdown
	ssbo_inst    1? ( 1 'ssbo_inst    glDeleteBuffers ) drop
	ssbo_sprites 1? ( 1 'ssbo_sprites glDeleteBuffers ) drop
	ssbo_cols    1? ( 1 'ssbo_cols    glDeleteBuffers ) drop
	ssbo_pal     1? ( 1 'ssbo_pal     glDeleteBuffers ) drop
	ss3d_shader  1? ( ss3d_shader glDeleteProgram     ) drop
	ss3d_shsh    1? ( ss3d_shsh glDeleteProgram       ) drop
	bbox_vao     1? ( 1 'bbox_vao   glDeleteVertexArrays ) drop
	bbox_vbo     1? ( 1 'bbox_vbo   glDeleteBuffers   ) drop
	bbox_ibo     1? ( 1 'bbox_ibo   glDeleteBuffers   ) drop
	;

::SS3Ddraw
	ss3d_inst 0? ( drop ; ) drop
	GL_SHADER_STORAGE_BUFFER ssbo_inst glBindBuffer
	GL_SHADER_STORAGE_BUFFER 0 ss3d_inst 5 << 3dss_array glBufferSubData
	GL_SHADER_STORAGE_BUFFER 0 glBindBuffer

	GL_SHADER_STORAGE_BUFFER 2 ssbo_sprites glBindBufferBase
	GL_SHADER_STORAGE_BUFFER 4 ssbo_inst glBindBufferBase
	GL_SHADER_STORAGE_BUFFER 6 ssbo_cols glBindBufferBase
	GL_SHADER_STORAGE_BUFFER 7 ssbo_pal glBindBufferBase

	GL_DEPTH_TEST glEnable
	GL_CULL_FACE glEnable
	GL_BACK glCullFace
	GL_GREATER glDepthFunc
	GL_TRUE glDepthMask

	ss3d_shader glUseProgram
	bbox_vao glBindVertexArray
	GL_TRIANGLES 36 GL_UNSIGNED_INT 0 ss3d_inst glDrawElementsInstanced
	0 glBindVertexArray
	;

|--- tamano de cada sprite (voxels)
::ss3dinfo | n -- v		; entrada de la tabla (8 bytes: atlasIndex | sizeX sizeY sizeZ 0)
	3 << defspr + @ ;
::ss3dLX | n -- v		; ancho (x)
	3 << defspr + 4 + c@ $ff and ;
::ss3dLY | n -- v		; alto: capas (y)
	3 << defspr + 5 + c@ $ff and ;
::ss3dLZ | n -- v		; fondo (z)
	3 << defspr + 6 + c@ $ff and ;

:growinst | i -- i	; ss3d_inst llega al menos a i+1
	ss3d_inst >=? ( dup 1+ 'ss3d_inst ! ) ;

#cz #sz #cy #sy #cx #sx

| rxyz -> qxyzw
::rxyz>q16 | rxyz -- qxyzw
	dup sincos 'cz ! 'sz !
	dup 16 >> sincos 'cy ! 'sy !
	32 >> sincos 'cx ! 'sx !
	| Euler ZYX -> quat (floats Q16)
	cx cy *.s cz *.s sx sy *.s sz *.s +		| qw
	2 >> $ffff and 48 <<
	cx cy *.s sz *.s sx sy *.s cz *.s -		| qz
	2 >> $ffff and 32 << or
	cx sy *.s cz *.s sx cy *.s sz *.s +		| qy
	2 >> $ffff and 16 << or
	sx cy *.s cz *.s cx sy *.s sz *.s -		| qx
	2 >> $ffff and or
	;

|------ pack 3 pos in 63bits (21x3) (13.8) 
::pack21 | x y z -- vp
	8 >> $1fffff and swap
	8 >> $1fffff and 21 << or swap
	8 >> $1fffff and 42 << or ;
	
::unpack21 | x -- x y z
	dup 1 << 43 >> 8 << swap
	dup 22 << 43 >> 8 << swap
	43 << 43 >> 8 << ;

::unpack21r | x -- z y x
	dup 43 << 43 >> 8 << swap
	dup 22 << 43 >> 8 << swap
	1 << 43 >> 8 << ;

::packq | rx ry rz rw -- rp
	2 >> $ffff and 48 << swap
	2 >> $ffff and 32 << or swap
	2 >> $ffff and 16 << or swap
	2 >> $ffff and or ;

::unpackq | rp -- rw rz ry rx
	dup 48 >> 2 << swap
	dup 16 << 48 >> 2 << swap
	dup 32 << 48 >> 2 << swap
	48 << 48 >> 2 << ;

::packq* | rx ry rz rw s -- rp
	dup >r *. 2 >> $ffff and 48 << swap
	r@ *. 2 >> $ffff and 32 << or swap
	r@ *. 2 >> $ffff and 16 << or swap
	r> *. 2 >> $ffff and or ;

::packv21 | x y z -- vp
	4 >> $1fffff and swap
	4 >> $1fffff and 21 << or swap
	4 >> $1fffff and 42 << or ;
	
::unpackv21 | x -- x y z
	dup 1 << 43 >> 4 << swap
	dup 22 << 43 >> 4 << swap
	43 << 43 >> 4 << ;


|--- escala: punto fijo 5.5 por eje (10 bits): valor = v/32
|    rango 0 .. 31.97 ; paso 1/32 ; 0 = oculto
:enc10 | fp16.16 -- v10
	1024 + 11 >> $3ff and ;

:dec10 | v10 -- fp16.16
	11 << ;

:enc3 | s -- v		; mismo valor en x y z
	enc10 dup 10 << over or swap 20 << or ;

:enc3x | sx sy sz -- v
	enc10 20 <<
	swap enc10 10 << or
	swap enc10 or ;

::ss3dset | x y z qxyzw scale spr color i --
	growinst
	ab[
	dup 5 << 3dss_array + >a			| A = &instancia
	$ffff and 16 << rot or da!+			| spr_obj: obj_id = i | spr
	da!+								| color
	enc3 da!+							| scale xyz
	a!+									| quaternion
	rot da!+ swap da!+ da!				| x y z
	]ba ;

::ss3dmax | -- n	; cantidad maxima de instancias
	3dss_max ;

::ss3dcs | scale spr color i --
	growinst
	ab[
	5 << 3dss_array + >a
	swap a> w!							| sprite (no toca obj_id)
	4 a+ da!+							| color
	enc3 da!							| scale xyz
	]ba ;

::ss3dscl3 | sx sy sz i --	; escala por eje (16.16)
	growinst
	>r enc3x r> 5 << 3dss_array + 8 + d! ;

::ss3dobj | id i --		; obj_id (16 bits)
	growinst
	5 << 3dss_array + 2 + w! ;

::ss3dobj@ | i -- id
	5 << 3dss_array + d@ 16 >> $ffff and ;

::ss3dxyz | x y z i --
	growinst
	ab[
	5 << 3dss_array + 20 + >a
	rot da!+ swap da!+ da!
	]ba ;

::ss3dqua | quat i --
	growinst
	5 << 3dss_array + 12 + ! ;

::ss3dxyzq | x y z quat i --
	growinst
	ab[
	5 << 3dss_array + 12 + >a
	a!+
	rot da!+ swap da!+ da!
	]ba ;
	
::ss3dreset  
	0 'ss3d_inst ! ;
	
::ss3dfloor | scale n -- val
	ss3dLY * 0.005 *. ;

::ss3difloor | i -- val
	5 << 3dss_array +
	dup 8 + d@ 10 >> $3ff and dec10	| adr sy
	swap d@ $ffff and				| sy spr
	ss3dfloor ;

|--- lectura de instancias
::ss3dxyz@ | i -- x y z
	5 << 3dss_array + 20 + d@+ swap d@+ swap d@ ;

::ss3dqua@ | i -- quat
	5 << 3dss_array + 12 + @ ;

::ss3dscl@ | i -- sx sy sz	; escala por eje (16.16)
	5 << 3dss_array + 8 + d@
	dup $3ff and dec10 swap
	dup 10 >> $3ff and dec10 swap
	20 >> $3ff and dec10 ;

::ss3dspr@ | i -- spr
	5 << 3dss_array + d@ $ffff and ;

::ss3dcol@ | i -- color
	5 << 3dss_array + 4 + d@ $ffffffff and ;

::ss3dcol | color i --	; solo el color
	growinst
	5 << 3dss_array + 4 + d! ;

|--- copiar instancias / cantidad dibujada
::ss3dcopy | src dst --	; copia los 32 bytes de la instancia src en dst
	growinst
	ab[
	5 << 3dss_array + >b
	5 << 3dss_array + >a
	a@+ b!+ a@+ b!+ a@+ b!+ a@ b!
	]ba ;

::ss3dlen! | n --	; cantidad de instancias que se dibujan (0..n-1)
	'ss3d_inst ! ;

|--- picking: rayo contra la caja orientada (OBB) de cada instancia
|    el rayo se pasa al espacio local de la instancia (rotando por el
|    quaternion conjugado) y se corta con las 3 placas +-h de la caja

#pkqx #pkqy #pkqz #pkqw		| quaternion conjugado (inversa) de la instancia
#pktx #pkty #pktz			| t = 2 * (q x v), temporal de pkrot
#pkro #pkrd					| rayo actual: 'origen 'direccion
#pkl * 72					| espacio local: o(0..2) d(3..5) h(6..8)
#pkbest #pkbi				| mejor distancia e instancia de ss3dpick

:pkvec@ | 'v -- x y z		; lee 3 qwords
	>a a@+ a@+ a@ ;

:pkvec! | x y z 'v --		; escribe 3 qwords
	>a a> 16 + ! a> 8 + ! a! ;

:pkvsub | cx cy cz 'v -- x y z	; v - c, cada resta consume su c
	>a
	a> 16 + @ swap - >r
	a> 8 + @ swap - >r
	a@ swap -
	r> r> ;

:pkrot | x y z -- rx ry rz	; v + w*t + q x t   (q ya conjugado)
	pkqy over *. pkqz pick3 *. - 2* 'pktx !
	pkqz pick3 *. pkqx pick2 *. - 2* 'pkty !
	pkqx pick2 *. pkqy pick4 *. - 2* 'pktz !
	pkqw pktz *. + pkqx pkty *. + pkqy pktx *. - >r		| rz (consume z)
	pkqw pkty *. + pkqz pktx *. + pkqx pktz *. - >r		| ry (consume y)
	pkqw pktx *. + pkqy pktz *. + pkqz pkty *. -		| rx (consume x)
	r> r> ;

:pkext | sx sy sz spr -- hx hy hz	; semi-extension de la caja
	>b
	b> ss3dLZ * 0.005 *.
	swap b> ss3dLY * 0.005 *. swap
	rot b> ss3dLX * 0.005 *. -rot ;

:pkslab | o d h -- min max	; intervalo del rayo dentro de la placa +-h
	over abs 32 <? ( drop nip		| paralelo al plano: o h
		swap abs swap >? ( drop $7fffffffffff -1 ; )
		drop 0 $7fffffffffff ; ) drop
	rot 2dup - -rot + neg			| d (h-o) (-h-o)
	pick2 /. swap rot /.			| a b
	2dup min -rot max ;

:pkclip | tn tf min max -- tn tf
	swap >r min swap r> max swap ;

:pkaxis | tn tf k -- tn tf
	3 << 'pkl + >a
	a@ a> 24 + @ a> 48 + @
	pkslab pkclip ;

:pkloc | i --		; rayo y caja en espacio local -> 'pkl
	dup ss3dqua@ unpackq neg 'pkqx ! neg 'pkqy ! neg 'pkqz ! 'pkqw !
	dup ss3dscl@ pick3 ss3dspr@ pkext 'pkl 48 + pkvec!
	ss3dxyz@ pkro pkvsub pkrot 'pkl pkvec!
	pkrd pkvec@ pkrot 'pkl 24 + pkvec! ;

:pkhit | i -- t		; usa el rayo pkro pkrd
	pkloc
	0 $7fffffffffff
	0 pkaxis 1 pkaxis 2 pkaxis
	>? ( drop -1 ; ) ;

::ss3dhit | 'orig 'dir i -- t	; distancia (16.16) al borde de la caja, -1 si no la toca
	-rot 'pkrd ! 'pkro ! pkhit ;

::ss3dpick | 'orig 'dir n -- i	; instancia mas cercana que toca el rayo (-1 = ninguna)
	-rot 'pkrd ! 'pkro !
	-1 'pkbi ! $7fffffffffff 'pkbest !
	( 1? 1-							| recorre n-1..0: en empate gana el menor indice
		dup pkhit
		0 >=? ( pkbest <=? ( dup 'pkbest ! over 'pkbi ! ) ) drop
		) drop
	pkbi ;

|--- cota de las instancias (para ajustar el mapa de sombras) ----------------
#bx0 #by0 #bz0 #bx1 #by1 #bz1 #bms
#bsx #bsy #bsz #bpx #bpy #bpz #brr

:binst | i --
	dup ss3dxyz@ 'bpz ! 'bpy ! 'bpx !
	dup ss3dscl@ 'bsz ! 'bsy ! 'bsx !
	ss3dspr@ >r
	r@ ss3dLX bsx * dup *.
	r@ ss3dLY bsy * dup *. +
	r> ss3dLZ bsz * dup *. +
	sqrt. 0.005 *. 'brr !				| radio de la caja del sprite (mitad de la diagonal)
	bpx brr - bx0 min 'bx0 !  bpx brr + bx1 max 'bx1 !
	bpy brr - by0 min 'by0 !  bpy brr + by1 max 'by1 !
	bpz brr - bz0 min 'bz0 !  bpz brr + bz1 max 'bz1 !
	bsx bsy max bsz max bms max 'bms ! ;

::SS3Dbounds | -- cx cy cz r maxscl	; esfera que contiene todas las instancias y la mayor escala (16.16)
	ss3d_inst 0? ( drop 0 0 0 1.0 1.0 ; ) drop
	$3fffffffff dup dup 'bx0 ! 'by0 ! 'bz0 !
	$3fffffffff neg dup dup 'bx1 ! 'by1 ! 'bz1 !
	0 'bms !
	0 ( ss3d_inst <? dup binst 1+ ) drop
	bx0 bx1 + 1 >>
	by0 by1 + 1 >>
	bz0 bz1 + 1 >>
	bx1 bx0 - dup *. by1 by0 - dup *. + bz1 bz0 - dup *. + sqrt. 1 >>
	bms ;
