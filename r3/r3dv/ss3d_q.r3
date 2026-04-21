| ssprite3d - instancias 32 bytes
| PHREDA 2026
^r3/lib/sdl2image.r3
^r3/lib/str.r3

##n3dsprites	| cnt sprites
#3dss_max		| max instances
##3dss_array	| instances array

#dirty_min #dirty_max
#ss3d_inst

#ss3d_shader

| * color  --  packed material:  0xRRGGBBuma
| *   bits 31-24  R
| *   bits 23-16  G
| *   bits 15- 8  B
| *   bits  7- 5  u  roughness (3 bits)
| *   bits  4- 2  m  metallic  (3 bits)
| *   bits  1- 0  a  glow      (2 bits)

#ss3d_shader_src "
@vertex-----------------
#version 440 core

layout(location=0) in vec3 a_pos;

struct Instance {
    uint obj_id;
	uint color;
	uint spr_scl;   // bits 15-0: spr_id uint16 | bits 31-16: scale uint8.8
    int  qxy;       // int16 qx (lo) | int16 qy (hi)
    int  qzw;       // int16 qz (lo) | int16 qw (hi)
    int  px, py, pz;	
};
layout(std430,binding=4) readonly buffer InstanceTable { Instance instances[]; };

struct SpriteDef {
    int twh, nfoff;
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
flat out int   vOffset;
flat out float vScale;

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
    int   spr_id  = int(inst.spr_scl & 0xFFFFu);
    float scale   = float(inst.spr_scl >> 16) / 256.0;   // uint8.8 -> float
    SpriteDef spr = sprites[spr_id];

    vSize = ivec3(spr.twh>>16, spr.nfoff>>16, spr.twh&0xffff);
    vec3 vExt = vec3(vSize) * (0.005 * scale);

    const float kPos  = 1.0/65536.0;
    const float kQuat = 1.0/16387.0; //32767.0;

    vec3 trans = vec3(inst.px, inst.py, inst.pz) * kPos;

    // unpack quat 16+16 bits
    vec4 q = vec4(
        float(inst.qxy << 16 >> 16),   // qx: sign-extend bits 0-15
        float(inst.qxy >> 16),          // qy: bits 16-31
        float(inst.qzw << 16 >> 16),   // qz: sign-extend bits 0-15
        float(inst.qzw >> 16)           // qw: bits 16-31
    ) * kQuat;

    mat3 rot = quatToMat3(normalize(q));

    vec3 dw = viewPos.xyz - trans;

    vRo = vec3(dot(rot[0],dw), dot(rot[1],dw), dot(rot[2],dw));

    vec3 local_pos = a_pos * vExt;
    gl_Position = ProjView * vec4(rot*local_pos + trans, 1.0);
    vLocalPos   = local_pos;
    vRot        = rot;
    vTrans      = trans;
    vColorPk    = inst.color;
    vOffset     = spr.nfoff&0xffff;
	vScale=scale;
}

@fragment---------------
#version 440 core
#extension GL_ARB_conservative_depth : enable
#define BOXMAX 0000

layout(std140,binding=0) uniform Matrices {
    mat4 view; mat4 proj; mat4 invView; mat4 invProj; mat4 ProjView; vec4 viewPos;
};

in  vec3  vRo;
in  vec3  vLocalPos;
flat in ivec3 vSize;
flat in mat3  vRot;
flat in vec3  vTrans;
flat in uint  vColorPk;
flat in int   vOffset;
flat in float vScale;

layout(binding=0) uniform sampler2D  uAlb;
layout(binding=3) uniform usampler1D uIdxBuf;
layout(location=0) out vec3 gNormal;
layout(location=1) out vec4 gAlbedo;
layout(depth_greater) out float gl_FragDepth;

void main() {
    const float kScale = 100.0/vScale;
    int itw = vSize.x, iNF = vSize.y, ith = vSize.z;
	vec3 vExt = vec3(vSize) * (0.005 * vScale); 

    vec3 vRd = vLocalPos - vRo;
    vec3 ir  = sign(vRd) / max(abs(vRd), vec3(1e-7));
    vec3 t0  = (-vExt - vRo) * ir;
    vec3 t1  = ( vExt - vRo) * ir;
    float tmin = max(max(max(min(t0.x,t1.x), min(t0.y,t1.y)), min(t0.z,t1.z)), 1e-5);
    float tmax = min(min(max(t0.x,t1.x), max(t0.y,t1.y)), max(t0.z,t1.z));
    if (tmin >= tmax) discard;

    vec3 rd_g   = vec3(vRd.x, -vRd.y, vRd.z) * kScale;
    vec3 delta_t = 1.0 / max(abs(rd_g), vec3(1e-7));
    ivec3 step_c = ivec3(sign(rd_g));
    ivec3 limit  = ivec3(itw, iNF, ith);

    vec3 entry_g = vec3(
         (vRo.x + vRd.x*tmin + vExt.x) * kScale,
        -(vRo.y + vRd.y*tmin + vExt.y) * kScale + float(iNF),
         (vRo.z + vRd.z*tmin + vExt.z) * kScale);

    ivec3 cell  = clamp(ivec3(entry_g), ivec3(0), limit - 1);
    vec3 next_t = vec3(
        ((step_c.x>0) ? float(cell.x+1)-entry_g.x : entry_g.x-float(cell.x)) * delta_t.x,
        ((step_c.y>0) ? float(cell.y+1)-entry_g.y : entry_g.y-float(cell.y)) * delta_t.y,
        ((step_c.z>0) ? float(cell.z+1)-entry_g.z : entry_g.z-float(cell.z)) * delta_t.z);

    vec3 tmin3   = min(t0, t1);
    int last_axis = (tmin3.x>=tmin3.y && tmin3.x>=tmin3.z) ? 0 : (tmin3.y>=tmin3.z ? 1 : 2);
    ivec3 exit_cell = ivec3(step_c.x>0?limit.x:-1, step_c.y>0?limit.y:-1, step_c.z>0?limit.z:-1);

    int   last_layer = -1;
    ivec2 base_texel = ivec2(0);

    for (int i=0; i<BOXMAX; i++) {
        if (any(equal(cell, exit_cell))) break;
        int cy = cell.y;
        if (cy != last_layer) {
            last_layer = cy;
            uint gi    = texelFetch(uIdxBuf, vOffset+cy, 0).r;
            base_texel = ivec2(int(gi&0xFFu)*itw, int(gi>>8)*ith);
        }
        vec4 tex = texelFetch(uAlb, base_texel + ivec2(cell.x, cell.z), 0);
        if (tex.a != 0.0) {
            vec3 signs   = vec3(-float(step_c.x), float(step_c.y), -float(step_c.z));
            vec3 n_local = signs * vec3(last_axis==0, last_axis==1, last_axis==2);
            vec3 world_n = vRot * n_local;
            vec3 b_hit   = vec3((float(cell.x)+0.5)/float(itw),
                                1.0-(float(cell.y)+0.5)/float(iNF),
                                (float(cell.z)+0.5)/float(ith));
            vec3 world_hit = vRot*(b_hit*2.0*vExt - vExt) + vTrans + world_n*0.0005;
            vec4 clip    = ProjView * vec4(world_hit, 1.0);
            gl_FragDepth = clip.z/clip.w*0.5 + 0.5;
            vec3 tint    = vec3(float((vColorPk>>24)&0xFFu),
                                float((vColorPk>>16)&0xFFu),
                                float((vColorPk>> 8)&0xFFu)) / 255.0;
            gNormal = world_n;
            gAlbedo = vec4(tex.rgb * tint, float(vColorPk&0xFFu)/255.0);
            return;
        }
        bvec3 m   = lessThanEqual(next_t, min(next_t.yzx, next_t.zxy));
        next_t   += vec3(m) * delta_t;
        cell     += ivec3(m) * step_c;
        last_axis = m.x ? 0 : (m.y ? 1 : 2);
    }
    discard;
}
@-----"

#imgtex
##defspr
#defind
#ssaendfile

|----GPU
#atlas_tex
#ssbo_sprites
#idx_tex
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

:imgtex>wh  imgtex dup 16 + d@ swap 20 + d@ ;
:imgtex>pix imgtex 32 + @ ;

#maxsize #nowsize
:cheksize nowsize maxsize >? ( 'maxsize ! ; ) drop ;

::ss3dload | "file" instances --
	'3dss_max !
	build_bbox
	here dup '3dss_array !
	over "%s.ssa" sprint load
	dup 'ssaendfile !
	'here !
	"%s.png" sprint IMG_load 'imgtex !

	1 'atlas_tex glGenTextures
	GL_TEXTURE_2D atlas_tex glBindTexture
	GL_TEXTURE_2D 0 GL_RGBA imgtex>wh 0 GL_RGBA GL_UNSIGNED_BYTE imgtex>pix glTexImage2D
	GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_NEAREST glTexParameteri
	GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_NEAREST glTexParameteri
	GL_TEXTURE_2D GL_TEXTURE_WRAP_S GL_CLAMP_TO_EDGE glTexParameteri
	GL_TEXTURE_2D GL_TEXTURE_WRAP_T GL_CLAMP_TO_EDGE glTexParameteri
	GL_TEXTURE_2D 0 glBindTexture
	imgtex SDL_FreeSurface

	3dss_array d@+ $41005353 <>? ( 2drop "not ssa file" .println ; ) drop
	w@+ 'n3dsprites !
	here dup 'defspr ! >a
	0 'maxsize !
	n3dsprites ( 1? 1- >r
		d@+
		dup 8 >> $ff and  dup 'nowsize !
		16 << swap $ff and dup 'nowsize +!
		or da!+
		d@+
		dup 16 >> $ffff and 'nowsize +!
		da!+
		cheksize
		r> ) drop
	'defind !

	1 'ssbo_sprites glGenBuffers
	GL_SHADER_STORAGE_BUFFER ssbo_sprites glBindBuffer
	GL_SHADER_STORAGE_BUFFER n3dsprites 8 * defspr 0 glBufferStorage
	GL_SHADER_STORAGE_BUFFER 2 ssbo_sprites glBindBufferBase
	GL_SHADER_STORAGE_BUFFER 0 glBindBuffer

	1 'idx_tex glGenTextures
	GL_TEXTURE_1D idx_tex glBindTexture
	GL_TEXTURE_1D 0 GL_R16UI ssaendfile defind - 0 GL_RED_INTEGER GL_UNSIGNED_SHORT defind glTexImage1D
	GL_TEXTURE_1D GL_TEXTURE_MIN_FILTER GL_NEAREST glTexParameteri
	GL_TEXTURE_1D GL_TEXTURE_MAG_FILTER GL_NEAREST glTexParameteri
	GL_TEXTURE_1D GL_TEXTURE_WRAP_S GL_CLAMP_TO_EDGE glTexParameteri
	GL_TEXTURE_1D 0 glBindTexture

	3dss_max 32 * 'here +!			| 32 bytes por instancia
	1 'ssbo_inst glGenBuffers
	GL_SHADER_STORAGE_BUFFER ssbo_inst glBindBuffer
	GL_SHADER_STORAGE_BUFFER 3dss_max 32 * 0 GL_DYNAMIC_DRAW glBufferData
	GL_SHADER_STORAGE_BUFFER 4 ssbo_inst glBindBufferBase
	GL_SHADER_STORAGE_BUFFER 0 glBindBuffer

	$FFFF 'dirty_min ! 0 'dirty_max !

	'ss3d_shader_src "0000" findstr
	maxsize .d 4 .r.
	4 cmove

	'ss3d_shader_src loadShaderv 'ss3d_shader !
	ss3d_shader glUseProgram
	ss3d_shader "uAlb"    glGetUniformLocation 0 glUniform1i
	ss3d_shader "uIdxBuf" glGetUniformLocation 3 glUniform1i
	0 glUseProgram
	0 'ss3d_inst !
	;

##ss3names

::ss3loadnames | "" --
	here dup 'ss3names !
	swap "%s.txt" sprint load
	0 swap c!+ 'here !
	;

::ss3idname | name -- id
	ss3names
	0 ( n3dsprites <? swap
		pick2 =pre 1? ( 2drop nip ; ) drop
		>>cr trim
		swap 1+ ) 3drop
	-1 ;

::ssnameid | id -- name
	ss3names swap ( 1? 1- swap >>cr trim swap ) drop ;

::SS3Dshutdown
	ssbo_inst   1? ( 1 'ssbo_inst   glDeleteBuffers  ) drop
	idx_tex     1? ( 1 'idx_tex     glDeleteTextures ) drop
	atlas_tex   1? ( 1 'atlas_tex   glDeleteTextures ) drop
	ssbo_sprites 1? ( 1 'ssbo_sprites glDeleteBuffers ) drop
	ss3d_shader 1? ( ss3d_shader glDeleteProgram     ) drop
	bbox_vao    1? ( 1 'bbox_vao   glDeleteVertexArrays ) drop
	bbox_vbo    1? ( 1 'bbox_vbo   glDeleteBuffers   ) drop
	bbox_ibo    1? ( 1 'bbox_ibo   glDeleteBuffers   ) drop
	;

::SS3Ddraw
	ss3d_inst 0? ( drop ; ) drop
	dirty_min dirty_max <? (
		GL_SHADER_STORAGE_BUFFER ssbo_inst glBindBuffer
		GL_SHADER_STORAGE_BUFFER
		dirty_min 32 *
		dirty_max dirty_min - 32 *
		3dss_array dirty_min 32 * +
		glBufferSubData
		GL_SHADER_STORAGE_BUFFER 0 glBindBuffer
		$ffff 'dirty_min ! 0 'dirty_max !
		) drop

	GL_SHADER_STORAGE_BUFFER 2 ssbo_sprites glBindBufferBase
	GL_TEXTURE0 glActiveTexture GL_TEXTURE_2D atlas_tex glBindTexture
	GL_TEXTURE3 glActiveTexture GL_TEXTURE_1D idx_tex glBindTexture

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

:dirtycheck
	dirty_min <? ( dup 'dirty_min ! )
	dirty_max >=? ( dup 1+ ss3d_inst >? ( dup 'ss3d_inst ! ) 'dirty_max ! )
	;

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

|struct Instance {
|    uint obj_id;
|    uint color;
|    uint spr_scl;   // bits 15-0: spr_id uint16 | bits 31-16: scale uint8.8
|    int  qxy;       // int16 qx (lo) | int16 qy (hi)
|    int  qzw;       // int16 qz (lo) | int16 qw (hi)
|    int  px, py, pz;

::ss3dset | x y z qxyzw scale color spr i --
	dirtycheck
	ab[
	dup 5 << 3dss_array + >a 
	da!+		|obj_id
	swap da!+	| color
	swap 8 >> 16 << or da!+ | scale|spr
	a!+
	rot da!+ swap da!+ da!  | x y z
	]ba
	;

::ss3dcs | scale spr color i --
	dirtycheck
	ab[
	5 << 3dss_array + 1 2 << + >a				| -> dword 1
	da!+
	swap 8 >> 16 << or da!	| scale|sprite
	]ba ;

::ss3dxyz | x y z i --
	dirtycheck
	ab[
	5 << 3dss_array + 5 2 << + >a
	rot da!+ swap da!+ da! 
	]ba ;

::ss3dqua | quat i --
	dirtycheck 
	5 << 3dss_array + 3 2 << + ! ;

::ss3dxyzq | x y z quat i --
	dirtycheck 
	ab[
	5 << 3dss_array + 3 2 << + >a
	a!+
	rot da!+ swap da!+ da! 
	]ba ;
	
	
::ss3dreset  
	0 'ss3d_inst ! ;
