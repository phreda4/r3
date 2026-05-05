| PHREDA 2026
^./renderlib.r3

#rl_sh_geom       0

#rl_u_model         -1
#rl_u_uPackColor	-1
#rl_u_normal_matrix -1

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
const float scaleY = 0.5;
const float scaleZ = 1.0;
const float bias   = 512.0;

out vec3 vWorldPos;
out vec2 vUV;

void main(){
    float x = (float((aPackedPos >> 20u) & 0x3FFu) - bias) * scaleX;
    float y = (float((aPackedPos >> 10u) & 0x3FFu) - bias) * scaleY;
    float z = (float( aPackedPos         & 0x3FFu) - bias) * scaleZ;
    vWorldPos   = vec3(x, y, z);
    uint u = aUV & 0xFFFFu;
    uint v = aUV >> 16u;
    vUV    = vec2(u, v) * uAtlasSize;
    gl_Position = ProjView * vec4(vWorldPos, 1.0);
}
@fragment---------------
#version 440 core
in vec3 vWorldPos;
in vec2 vUV;

layout(binding=2) uniform sampler2D uAtlas;
uniform vec2 uAtlasSize;

layout(location=0) out vec3 gNormal;
layout(location=1) out vec4 gAlbedo;

void main(){
    vec3 dx = dFdx(vWorldPos);
    vec3 dy = dFdy(vWorldPos);
    gNormal  = normalize(cross(dx, dy));
    gAlbedo  = //vec4(texture(uAtlas, vUV).rgb, 1.0);
			vec4(texture(uAtlas, vUV).rgb, 1.0-texture(uAtlas, vUV).a);
}
@-----------------------"

#pl_count 0

#pl_vao #pl_vbo #pl_ebo

#pl_atlas_tex  0
#pl_u_atlassize -1     | uniform location for uAtlasSize


:,fv | x y z --
	pl_bias + 
	swap pl_bias + 10 << or
	swap pl_bias + 20 << or
	,
	;

#vv #vi
:FlushPlanes
	mark
	here 'vv !
	-5 -5 -10 ,fv	$000000 ,
	-5 5 -10 ,fv	$000020 ,
	5 5 -10 ,fv		$200020 ,
	5 -5 -10 ,fv	$200000 ,

	-5 -5 10 ,fv	$200020 ,
	-5 5 10 ,fv		$200040 ,
	5 5 10 ,fv		$400040 ,
	5 -5 10 ,fv		$400020 ,

	-5 10 -5 ,fv	$200000 ,
	-5 10  5 ,fv	$200020 ,
	5 10 5 ,fv		$400020 ,
	5 10 -5 ,fv		$400000 ,
	
	here 'vi !
	0 , 1 , 2 , 0 , 2 , 3 ,	
	4 , 5 , 6 , 4 , 6 , 7 ,
	8 , 9 , 10 , 8 , 10 , 11 ,	
	
	1 'pl_count +!
	1 'pl_count +!
	1 'pl_count +!
	empty

    pl_vao glBindVertexArray

    GL_ARRAY_BUFFER pl_vbo glBindBuffer
    GL_ARRAY_BUFFER pl_count 32 * vv GL_STATIC_DRAW glBufferData

    GL_ELEMENT_ARRAY_BUFFER pl_ebo glBindBuffer
    GL_ELEMENT_ARRAY_BUFFER pl_count 24 * vi GL_STATIC_DRAW glBufferData

	;

	
::ini3dtile
|---------- planes	
    'rl_shader_planes loadShaderv 'rl_sh_planes !

    rl_sh_planes glUseProgram
	
|	rl_sh_planes "uAtlas" glGetUniformLocation 2 swap glUniform1i
	
    rl_sh_planes "uAtlasSize" glGetUniformLocation 'pl_u_atlassize !
	0 rl_sh_planes "Matrices" rl_bind_ubo

    | GPU objects
    1 'pl_vao glGenVertexArrays
    1 'pl_vbo glGenBuffers
    1 'pl_ebo glGenBuffers
	
	FlushPlanes

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
#pl_surface

:imgtex>wh  pl_surface dup 16 + d@ swap 20 + d@ ;
:imgtex>pix pl_surface 32 + @ ;

::rl_3datlas | "" --
    1 'pl_atlas_tex glGenTextures
    GL_TEXTURE_2D pl_atlas_tex glBindTexture

    IMG_Load 'pl_surface !

    GL_TEXTURE_2D 0
        GL_RGBA
        imgtex>wh
        0
        pick3                   | format = same as internal
        GL_UNSIGNED_BYTE
        imgtex>pix
    glTexImage2D

    GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_NEAREST glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_NEAREST glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_WRAP_S GL_CLAMP_TO_EDGE glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_WRAP_T GL_CLAMP_TO_EDGE glTexParameteri


    | query the texture dimensions (R3 runtime word: texSize tex -- w h)
    pl_atlas_tex imgtex>wh     | -- w h
	1.0 swap / f2fp 
	1.0 rot / f2fp 
	'atlasimgsize d!+ d!
	
    pl_surface SDL_FreeSurface
    0 'pl_surface !
	
    | upload to shader
    rl_sh_planes glUseProgram
    pl_u_atlassize 1 'atlasimgsize glUniform2fv ;   | w h consumed by glUniform2f
	
::end3dtile
    rl_sh_planes glDeleteProgram

    1 'pl_vao glDeleteVertexArrays
    1 'pl_vbo glDeleteBuffers
    1 'pl_ebo glDeleteBuffers

    pl_atlas_tex 1? ( 1 'pl_atlas_tex glDeleteTextures ) drop

    0 'pl_count !
    0 'pl_vao !  0 'pl_vbo !  0 'pl_ebo !
	;
	

::draw3dtiles
    rl_sh_planes glUseProgram
	
    GL_TEXTURE2    glActiveTexture
    GL_TEXTURE_2D  pl_atlas_tex  glBindTexture
    pl_vao glBindVertexArray
    GL_TRIANGLES pl_count 6 * GL_UNSIGNED_INT 0 glDrawElements
    0 glBindVertexArray 
	;