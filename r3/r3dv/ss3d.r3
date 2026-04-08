| ssprite3d
| PHREDA 2026
^r3/lib/sdl2image.r3
^r3/lib/str.r3

##n3dsprites	| cnt sprites
#3dss_max		| max instances
#3dss_array		| instances array

#dirty_min #dirty_max | update array
#ss3d_inst			| current cnt instances

#ss3d_shader		| shader program

| * color  --  packed material:  0xRRGGBBuma
| *   bits 31-24  R  (8 bits, 0..255)
| *   bits 23-16  G  (8 bits, 0..255)
| *   bits 15- 8  B  (8 bits, 0..255)
| *   bits  7- 5  u  roughness (3 bits, 0..7)
| *   bits  4- 2  m  metallic  (3 bits, 0..7)
| *   bits  1- 0  a  glow      (2 bits, 0..3)

#ss3d_shader_src "
@vertex-----------------
#version 440 core

layout(location=0) in vec3 a_pos;

struct Instance {
    ivec3 r0; uint obj_id;
    ivec3 r1; uint spr_id;
    ivec3 r2; uint color;
    ivec3 tr; uint inv_s2;
};
layout(std430,binding=4) readonly buffer InstanceTable { Instance instances[]; };

struct SpriteDef {
    int tw, th, sw, sh, nf, offset;
};
layout(std430,binding=2) readonly buffer SpriteDefTable { SpriteDef sprites[]; };

layout(std140,binding=0) uniform Matrices {
    mat4 view; mat4 proj; mat4 invView; mat4 invProj; vec4 viewPos;
};

     out vec3 vRo;
     out vec3 vLocalPos;
flat out vec3 vExt;
flat out ivec2 vTexParam0;
flat out mat3 vRot;
flat out vec3 vWorldTrans;
flat out uint vColorPk;
flat out int  vNF, vOffset;

flat out vec3 vScaleUV;

void main() {
    Instance inst = instances[gl_InstanceID];
    int spr_id = int(inst.spr_id);
    SpriteDef spr = sprites[spr_id];
    vExt = vec3(0.005*float(spr.tw), 0.005*float(spr.nf), 0.005*float(spr.th));
	
	const float k = 1.0/65536.0; // fixed.point>>fp
	mat3 rot = mat3(vec3(inst.r0) * k,vec3(inst.r1) * k,vec3(inst.r2) * k);
	vec3 trans   = vec3(inst.tr) * k;
	float inv_s2 = float(inst.inv_s2) * k;

    vec3 dw = viewPos.xyz - trans;
    vRo = vec3(dot(rot[0],dw), dot(rot[1],dw), dot(rot[2],dw)) * inv_s2;

    vec3 local_pos = a_pos * vExt;
    gl_Position = proj * view * vec4(rot*local_pos + trans, 1.0);
    vLocalPos = local_pos;
    vRot = rot;
    vWorldTrans = trans;
    vTexParam0 = ivec2(spr.tw, spr.th);
    vNF = spr.nf; vOffset = spr.offset;
    vColorPk = inst.color;
	
    vScaleUV = (0.5 / vExt) * vec3(float(spr.tw), float(spr.nf), float(spr.th));
}

@fragment---------------
#version 440 core
#extension GL_ARB_conservative_depth : enable // TEST <----
#define BOXMAX 0000

struct SpriteDef { int tw, th, sw, sh, nf, offset; };
layout(std430,binding=2) readonly buffer SpriteDefTable { SpriteDef sprites[]; };
layout(std140,binding=0) uniform Matrices {
    mat4 view; mat4 proj; mat4 invView; mat4 invProj; vec4 viewPos;
};

in  vec3  vRo;
in  vec3  vLocalPos;
flat in vec3  vExt;
flat in ivec2 vTexParam0;
flat in mat3  vRot;
flat in vec3  vWorldTrans;
flat in uint  vColorPk;
flat in int   vNF, vOffset;
flat in vec3  vScaleUV;

layout(binding=0) uniform sampler2D  uAlb;
layout(binding=3) uniform usampler1D uIdxBuf;
layout(location=0) out vec3 gNormal;
layout(location=1) out vec4 gAlbedo;
layout(depth_greater) out float gl_FragDepth; // TEST<-----

void main() {
    vec3 vRd   = vLocalPos - vRo;
    vec3 ir    = sign(vRd) / max(abs(vRd), vec3(1e-7));
    vec3 t0    = (-vExt - vRo) * ir;
    vec3 t1    = ( vExt - vRo) * ir;
    float tmin = max(max(max(min(t0.x,t1.x), min(t0.y,t1.y)), min(t0.z,t1.z)), 1e-5);
    float tmax = min(min(max(t0.x,t1.x), max(t0.y,t1.y)), max(t0.z,t1.z));
    if (tmin >= tmax) discard;

    int itw = vTexParam0.x; int ith = vTexParam0.y;
	
    vec3 rd_g = vec3( vRd.x * vScaleUV.x,
                     -vRd.y * vScaleUV.y,
                      vRd.z * vScaleUV.z);

    vec3 delta_t = 1.0 / max(abs(rd_g), vec3(1e-7));
    ivec3 step_c = ivec3(sign(rd_g));
    ivec3 limit  = ivec3(itw, vNF, ith);

   vec3 entry_g = vec3(
         (vRo.x + vRd.x*tmin + vExt.x) * vScaleUV.x,
        -(vRo.y + vRd.y*tmin + vExt.y) * vScaleUV.y + float(vNF),
         (vRo.z + vRd.z*tmin + vExt.z) * vScaleUV.z);
		 
    ivec3 cell = clamp(ivec3(entry_g), ivec3(0), limit - 1);
    vec3 next_t = vec3(
        ((step_c.x>0) ? float(cell.x+1)-entry_g.x : entry_g.x-float(cell.x)) * delta_t.x,
        ((step_c.y>0) ? float(cell.y+1)-entry_g.y : entry_g.y-float(cell.y)) * delta_t.y,
        ((step_c.z>0) ? float(cell.z+1)-entry_g.z : entry_g.z-float(cell.z)) * delta_t.z
    );

    float tx=min(t0.x,t1.x), ty=min(t0.y,t1.y), tz=min(t0.z,t1.z);
    int last_axis = (tx>=ty && tx>=tz) ? 0 : (ty>=tz ? 1 : 2);

    int   last_layer = -1;
    ivec2 base_texel = ivec2(0);

    for (int i=0; i<BOXMAX; i++) {
        
		if (any(lessThan(cell, ivec3(0))) || any(greaterThanEqual(cell, limit))) break;

        int cy = cell.y;
        if (cy != last_layer) {
            last_layer = cy;
            uint gi    = texelFetch(uIdxBuf, vOffset+cy, 0).r;
            base_texel = ivec2(int(gi&0xFFu)*itw, int(gi>>8)*ith);
        }

        vec4 tex = texelFetch(uAlb, base_texel + ivec2(cell.x, cell.z), 0);

        if (tex.a != 0.0) {
            vec3 n_local;
            if      (last_axis==0) n_local = vec3(-float(step_c.x), 0.0, 0.0);
            else if (last_axis==1) n_local = vec3(0.0, float(step_c.y), 0.0);
            else                   n_local = vec3(0.0, 0.0, -float(step_c.z));
            vec3 world_n = vRot * n_local;

            vec3 b_hit = vec3((float(cell.x)+0.5)/float(itw),
                              1.0-(float(cell.y)+0.5)/float(vNF),
                              (float(cell.z)+0.5)/float(ith));
            vec3 world_hit = vRot*(b_hit*2.0*vExt - vExt) + vWorldTrans + world_n*0.0005;

            vec4 clip = proj * (view * vec4(world_hit, 1.0));
            gl_FragDepth = clip.z/clip.w*0.5 + 0.5;

            vec3 tint = vec3(float((vColorPk>>24)&0xFFu),
                             float((vColorPk>>16)&0xFFu),
                             float((vColorPk>> 8)&0xFFu)) / 255.0;
            gNormal = world_n;
            gAlbedo = vec4(tex.rgb * tint, float(vColorPk&0xFFu)/255.0);
            return;
        }

        bvec3 m = lessThanEqual(next_t, min(next_t.yzx, next_t.zxy));
        next_t += vec3(m) * delta_t;
        cell   += ivec3(m) * step_c;
        last_axis = m.x ? 0 : (m.y ? 1 : 2);
    }
    discard;
}
@-----------------------"

#imgtex | surface
#defspr | sprite definition
#defind | index definition
#ssaendfile
| int tile_w, tile_h, slice_w, slice_h, n_frames, offset; <-- shader

|----GPU
#atlas_tex		| atlas
#ssbo_sprites	| sprites
#idx_tex		| index
#ssbo_inst		| instances

#maxw #maxh #maxz

:dump
	n3dsprites "%d sprites" .println
	defspr >a
	n3dsprites ( 1? 1-
		da@+ "tw:%d " .print
		da@+ "th:%d " .print
		da@+ "sw:%d " .print
		da@+ "sh:%d " .print
		da@+ "z:%d " .print
		da@+ "offset:%d " .print
		.cr
		) drop
	maxz maxh maxw "mw:%d mh:%d mz:%d" .println
	;
	
|----------------------------
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

:imgtex>wh imgtex dup 16 + d@ swap 20 + d@ ;
:imgtex>pix imgtex 32 + @ ;

::ss3dload | "file" instances --
	'3dss_max !
	build_bbox
	mark
	here dup '3dss_array !
	over "%s.ssa" sprint load 
	dup 'ssaendfile !
	'here !	|3dss_array here - "ss3load: %h" .println
	
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
	0 'maxw ! 0 'maxh ! 0 'maxz !
	n3dsprites ( 1? 1- >r
		d@+
		dup 8 >> $ff and da!+ |tw
		dup $ff and da!+	|th
		dup 24 >> $ff and 
		maxw >? ( dup 'maxw ! ) da!+ |sw 
		16 >> $ff and 
		maxh >? ( dup 'maxh ! ) da!+ |sh
		d@+
		dup 16 >> $ffff and 
		maxz >? ( dup 'maxz ! ) da!+ |nf (z)
		$ffff and da!+	| offset
		r> ) drop
	'defind !
|	a> 'here !
|	dump
	
	1 'ssbo_sprites glGenBuffers
	GL_SHADER_STORAGE_BUFFER ssbo_sprites glBindBuffer
	GL_SHADER_STORAGE_BUFFER n3dsprites 24 * defspr 0 glBufferStorage
	GL_SHADER_STORAGE_BUFFER 2 ssbo_sprites glBindBufferBase
	GL_SHADER_STORAGE_BUFFER 0 glBindBuffer

	1 'idx_tex glGenTextures
	GL_TEXTURE_1D idx_tex glBindTexture
	GL_TEXTURE_1D 0 GL_R16UI ssaendfile defind - 0 GL_RED_INTEGER GL_UNSIGNED_SHORT defind glTexImage1D
	GL_TEXTURE_1D GL_TEXTURE_MIN_FILTER GL_NEAREST glTexParameteri
	GL_TEXTURE_1D GL_TEXTURE_MAG_FILTER GL_NEAREST glTexParameteri
	GL_TEXTURE_1D GL_TEXTURE_WRAP_S GL_CLAMP_TO_EDGE glTexParameteri
	GL_TEXTURE_1D 0 glBindTexture
	
	empty
	here '3dss_array !
	3dss_max 64 * 'here +!
	
	1 'ssbo_inst glGenBuffers
    GL_SHADER_STORAGE_BUFFER ssbo_inst glBindBuffer
	GL_SHADER_STORAGE_BUFFER 3dss_max 64 * 0 GL_DYNAMIC_DRAW glBufferData
    GL_SHADER_STORAGE_BUFFER 4 ssbo_inst glBindBufferBase
    GL_SHADER_STORAGE_BUFFER 0 glBindBuffer
	
	$FFFF 'dirty_min ! 0 'dirty_max !

| set BOXMAX constant
	'ss3d_shader_src "0000" findstr
	maxw maxh + maxz + .d 4 .r. 
	4 cmove |dsc	
	
| compile shader	
	'ss3d_shader_src loadShaderv 'ss3d_shader !
	ss3d_shader glUseProgram
	ss3d_shader "uAlb" glGetUniformLocation 0 glUniform1i
	ss3d_shader "uIdxBuf" glGetUniformLocation 3 glUniform1i
	0 glUseProgram
	0 'ss3d_inst !	
	;
	
::SS3Dshutdown
	ssbo_inst 1? ( 1 'ssbo_inst glDeleteBuffers ) drop
	idx_tex 1? ( 1 'idx_tex  glDeleteTextures ) drop
	atlas_tex 1? ( 1 'atlas_tex glDeleteTextures ) drop
	ssbo_sprites 1? ( 1 'ssbo_sprites glDeleteBuffers ) drop
	ss3d_shader 1? ( ss3d_shader glDeleteProgram ) drop
	bbox_vao 1? ( 1 'bbox_vao glDeleteVertexArrays ) drop
	bbox_vbo 1? ( 1 'bbox_vbo glDeleteBuffers ) drop
	bbox_ibo 1? ( 1 'bbox_ibo glDeleteBuffers ) drop
	;
	
::SS3Ddraw
	ss3d_inst 0? ( drop ; ) drop
	dirty_min dirty_max <? (
		GL_SHADER_STORAGE_BUFFER ssbo_inst glBindBuffer
		GL_SHADER_STORAGE_BUFFER 
		dirty_min 64 *  | ini
		dirty_max dirty_min - 64 * | cnt
		3dss_array dirty_min 64 * + | start mem
		glBufferSubData
		GL_SHADER_STORAGE_BUFFER 0 glBindBuffer
		$ffff 'dirty_min ! 0 'dirty_max !
		) drop

	GL_SHADER_STORAGE_BUFFER 2 ssbo_sprites glBindBufferBase
	GL_TEXTURE0 glActiveTexture GL_TEXTURE_2D atlas_tex glBindTexture
	GL_TEXTURE3 glActiveTexture GL_TEXTURE_1D idx_tex glBindTexture
	GL_TEXTURE0 glActiveTexture
	GL_DEPTH_TEST glEnable
	GL_CULL_FACE glEnable
	GL_BACK glCullFace
	GL_GREATER glDepthFunc
	GL_TRUE glDepthMask
	ss3d_shader glUseProgram
	bbox_vao glBindVertexArray
	GL_TRIANGLES 36 GL_UNSIGNED_INT 0 ss3d_inst glDrawElementsInstanced
|	GL_DEPTH_TEST glEnable
|	GL_GREATER glDepthFunc
	0 glBindVertexArray
	;


:dirtycheck
	dirty_min <? ( dup 'dirty_min ! )
	dirty_max >=? ( dup 1+ ss3d_inst >? ( dup 'ss3d_inst ! ) 'dirty_max ! )
	;
	
#cz #sz #cy #sy #cx #sx
#s2

::ss3dset | x y z srxyz color spr i --
	dirtycheck
	dup 6 << 3dss_array + >a
	rot >r swap >r >r |da!+ | obj id da!+ | spr da!+ | color 0 da!+ | pad
	dup sincos 'cz ! 'sz !
	dup 16 >> sincos 'cy ! 'sy !
	dup 32 >> sincos 'cx ! 'sx !
	32 >> $ffff00 and	| 8.8 fixepoint
	dup cy cz *. *. dup					da!+
	dup *. 's2 ! 
	dup cx sz *. sx sy *. cz *. + *. dup da!+
	dup *. 's2 +!	
	dup sx sz *. cx sy *. cz *. - *. dup da!+
	dup *. 's2 +!
	r> da!+	
	dup cy neg sz *. *. 				da!+
	dup cx cz *. sx sy *. sz *. - *.	da!+
	dup sx cz *. cx sy *. sz *. + *.	da!+
	r> da!+
	dup sy *.					da!+
	dup sx neg cy *. *.			da!+
	cx cy *. *.					da!+ | <-- last scale
	r> da!+ 
	rot da!+ swap da!+ da!+ 		| x y z
	1.0 s2 0? ( 1.0 + ) /.		da! | invs2
	;
	
::ss3dcs | color spr i --
	dirtycheck
	6 << 3dss_array + 
	7 2 << + >a da!+
	3 2 << a+ da! ;
	
::ss3dxyz | x y z i --
	dirtycheck
	6 << 3dss_array + 
	12 2 << + >a
	rot da!+ swap da!+ da!
	;
