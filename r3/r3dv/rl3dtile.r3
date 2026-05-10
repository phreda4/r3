| PHREDA 2026
^./renderlib.r3

#rl_sh_planes 0

| escala: 1 unidad de grilla = estos valores en mundo
#pl_scaleX 1.0
#pl_scaleY 1.0
#pl_scaleZ 1.0
| offset de centro: 512 para coordenada sin signo 10 bits
#pl_bias 512

#rl_shader_planes "
@vertex-----------------
#version 440 core
layout(location=0) in uint aPackedPos;
layout(location=1) in uint aUV;

layout(std140, binding=0) uniform Matrices {
    mat4 view; mat4 proj; mat4 invView; mat4 invProj;
    mat4 ProjView; vec4 viewPos;
};
uniform vec2 uAtlasSize;

const float scaleX = 1.0;
const float scaleY = 1.0;
const float scaleZ = 1.0;
const float bias   = 512.0;

out vec3 vWorldPos;
out vec2 vUV;
flat out float vColorPk;

void main(){
    float x = (float((aPackedPos >> 20u) & 0x3FFu) - bias) * scaleX;
    float y = (float((aPackedPos >> 10u) & 0x3FFu) - bias) * scaleY;
    float z = (float( aPackedPos         & 0x3FFu) - bias) * scaleZ;
    vWorldPos   = vec3(x, y, z);
    uint u = aUV & 0xFFFu;
    uint v = (aUV >> 12u) & 0xFFFu;
	vColorPk=((aUV >> 24u) & 0xFFu)/255.0;
    vUV    = (vec2(u, v)+0.5) * uAtlasSize;
    gl_Position = ProjView * vec4(vWorldPos, 1.0);
}
@fragment---------------
#version 440 core
in vec3 vWorldPos;
in vec2 vUV;
flat in float vColorPk;

layout(binding=2) uniform sampler2D uAtlas;
uniform vec2 uAtlasSize;

layout(location=0) out vec3 gNormal;
layout(location=1) out vec4 gAlbedo;

void main(){
	vec4 tex = texture(uAtlas, vUV);
	if(tex.a < 0.9) discard;
	vec3 dx = dFdx(vWorldPos);
	vec3 dy = dFdy(vWorldPos);
	gNormal = normalize(cross(dx, dy));
	gAlbedo = vec4(tex.rgb,vColorPk);
}
@-----------------------"

#pl_count 0

#pl_vao 
#pl_vbo 
#pl_ebo

#pl_atlas_tex  0
#pl_u_atlassize -1     | uniform location for uAtlasSize

::t3d_ini
	0 'pl_count ! 
	mark ;

::3dt3 | x y z -- v
	pl_bias + swap pl_bias + 10 << or swap pl_bias + 20 << or ;

::t3d4v | uv p uv p uv p uv p --
	, , , , , , , , 1 'pl_count +! ;
 
::t3d4q | uvp uvp uvp uvp --
	,q ,q ,q ,q 1 'pl_count +! ;
	
::t3dv | (uv x y z) --
	3dt3 , , ;
::t3dq | (uv x y z) --
	t3dv 1 'pl_count +! ;
	
::t3d_end
	empty
	pl_vao glBindVertexArray
	GL_ARRAY_BUFFER pl_vbo glBindBuffer
	GL_ARRAY_BUFFER 0 pl_count 32 * here glBufferSubData
	here >a
	0 ( pl_count 6 * <? 
		dup da!+ dup 1 + da!+ dup 2 + da!+
		dup da!+ dup 2 + da!+ dup 3 + da!+
		4 + ) drop
	GL_ELEMENT_ARRAY_BUFFER pl_ebo glBindBuffer
	GL_ELEMENT_ARRAY_BUFFER 0 pl_count 24 * here glBufferSubData
	0 glBindVertexArray ;

#PL_MAX 8192

::ini3dtile
	'rl_shader_planes loadShaderv 'rl_sh_planes !

	rl_sh_planes glUseProgram
|	rl_sh_planes "uAtlas" glGetUniformLocation 2 swap glUniform1i
	rl_sh_planes "uAtlasSize" glGetUniformLocation 'pl_u_atlassize !
	0 rl_sh_planes "Matrices" rl_bind_ubo

	1 'pl_vao glGenVertexArrays
	1 'pl_vbo glGenBuffers
	1 'pl_ebo glGenBuffers

	pl_vao glBindVertexArray

	GL_ARRAY_BUFFER pl_vbo glBindBuffer
	GL_ARRAY_BUFFER PL_MAX 4 * 32 * 0 GL_DYNAMIC_DRAW glBufferData
	
	GL_ELEMENT_ARRAY_BUFFER pl_ebo glBindBuffer
	GL_ELEMENT_ARRAY_BUFFER PL_MAX 4 * 6 * 4 * 0 GL_DYNAMIC_DRAW glBufferData

| stride = 8 bytes
| attrib 0: aPackedPos  uint  offset 0  → INTEGER attrib
	0 glEnableVertexAttribArray
	0 1 GL_UNSIGNED_INT 8 0 glVertexAttribIPointer
| attrib 1: aUV         uint  offset 4  → INTEGER attrib  
	1 glEnableVertexAttribArray
	1 1 GL_UNSIGNED_INT 8 4 glVertexAttribIPointer
	0 glBindVertexArray
	;

#atlasimgsize 0

::rl_3datlas | "" --
	glLoadImg 
	dup $ffff and 'pl_atlas_tex !
	32 >> dup $ffff and swap 16 >> 
	1.0 swap / f2fp 1.0 rot / f2fp 'atlasimgsize d!+ d!
	
	rl_sh_planes glUseProgram
	pl_u_atlassize 1 'atlasimgsize glUniform2fv ;
	;

::rl_3datlas_reload | "" --
	pl_atlas_tex 1? ( 1 'pl_atlas_tex glDeleteTextures ) drop
	0 'pl_atlas_tex !
	rl_3datlas ;

::end3dtile
	rl_sh_planes glDeleteProgram

	1 'pl_vao glDeleteVertexArrays
	1 'pl_vbo glDeleteBuffers
	1 'pl_ebo glDeleteBuffers

	pl_atlas_tex 1? ( 1 'pl_atlas_tex glDeleteTextures ) drop
	;

::draw3dtiles
	rl_sh_planes glUseProgram
	GL_TEXTURE2 glActiveTexture
	GL_TEXTURE_2D pl_atlas_tex glBindTexture
	pl_vao glBindVertexArray
	GL_TRIANGLES pl_count 6 * GL_UNSIGNED_INT 0 glDrawElements
	0 glBindVertexArray 
	;