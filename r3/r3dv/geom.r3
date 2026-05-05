| PHREDA 2026
^./renderlib.r3

#rl_sh_geom       0

#rl_u_model         -1
#rl_u_uPackColor	-1
#rl_u_normal_matrix -1

#rl_shader_geom "
@vertex-----------------
#version 440 core
layout(location=0) in vec3 aPos;
layout(location=1) in vec3 aNormal;
layout(std140, binding=0) uniform Matrices {
    mat4 view; mat4 proj; mat4 invView; mat4 invProj; mat4 ProjView; vec4 viewPos;  };
uniform mat4 model;
uniform mat3 normalMatrix;
out vec3 vPos; out vec3 vNormal;
void main(){
    vec4 wp = model*vec4(aPos,1.0);
    vPos = wp.xyz;
    vNormal = normalMatrix*aNormal;
    gl_Position = ProjView*wp;
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
		float( uPackColor     &0xFFu))/ 255.0;
}
@-----------------------"

#rl_sh_planes 0

#rl_shader_planes "
@vertex-----------------
#version 440 core
layout(location=0) in vec3  aPos;
layout(location=1) in vec3  aNormal;
layout(location=2) in uint  aUV;
layout(std140, binding=0) uniform Matrices {
    mat4 view; mat4 proj; mat4 invView; mat4 invProj; mat4 ProjView; vec4 viewPos; };
uniform vec2 uAtlasSize;
out vec3 vNormal;
out vec2 vUV;
void main(){
    uint u    = aUV & 0xFFFFu;
    uint v    = aUV >> 16u;
    vUV       = vec2(u, v) * uAtlasSize;
    vNormal   = aNormal;
    gl_Position = ProjView * vec4(aPos, 1.0);
}
@fragment---------------
#version 440 core
in vec3 vNormal;
in vec2 vUV;
layout(binding=2) uniform sampler2D uAtlas;
layout(location=0) out vec3 gNormal;
layout(location=1) out vec4 gAlbedo;
void main(){
    gNormal = normalize(vNormal);
    gAlbedo = //texture(uAtlas, vUV);
		vec4(texture(uAtlas, vUV).rgb, 1.0-texture(uAtlas, vUV).a);
}
@-----------------------"

| 24 vertices (4 por cara x 6 caras) con pos, normal
#verts [
-0.5  -0.5  -0.5  0 0 -1.0  0.5  -0.5  -0.5  0 0 -1.0 
 0.5   0.5  -0.5  0 0 -1.0 -0.5   0.5  -0.5  0 0 -1.0 
-0.5  -0.5   0.5  0 0  1.0  0.5  -0.5   0.5  0 0  1.0 
 0.5   0.5   0.5  0 0  1.0 -0.5   0.5   0.5  0 0  1.0 
-0.5   0.5   0.5  -1.0 0 0 -0.5   0.5  -0.5  -1.0 0 0 
-0.5  -0.5  -0.5  -1.0 0 0 -0.5  -0.5   0.5  -1.0 0 0 
 0.5   0.5   0.5   1.0 0 0  0.5   0.5  -0.5   1.0 0 0 
 0.5  -0.5  -0.5   1.0 0 0  0.5  -0.5   0.5   1.0 0 0 
-0.5  -0.5  -0.5  0 -1.0 0  0.5  -0.5  -0.5  0 -1.0 0 
 0.5  -0.5   0.5  0 -1.0 0 -0.5  -0.5   0.5  0 -1.0 0 
-0.5   0.5  -0.5  0  1.0 0  0.5   0.5  -0.5  0  1.0 0 
 0.5   0.5   0.5  0  1.0 0 -0.5   0.5   0.5  0  1.0 0 
]

#idx [
 0  2  1  0  3  2   4  5  6  4  6  7   8  9 10  8 10 11 
12 14 13 12 15 14  16 17 18 16 18 19  20 22 21 20 23 22
]

#g_cube_vao #g_cube_vbo #g_cube_ebo

#pl_count 0

#pl_vao #pl_vbo #pl_ebo

#pl_atlas_tex  0
#pl_u_atlassize -1     | uniform location for uAtlasSize

::IniGeom
	'rl_shader_geom       loadShaderv 'rl_sh_geom       !
	
    rl_sh_geom "model"        glGetUniformLocation 'rl_u_model         !
	rl_sh_geom "uPackColor"   glGetUniformLocation 'rl_u_uPackColor !
    rl_sh_geom "normalMatrix" glGetUniformLocation 'rl_u_normal_matrix !
	
    0 rl_sh_geom  "Matrices"  rl_bind_ubo
	
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
	;

:,fp
	f2fp , ;
	
#vv #vi
:FlushPlanes
	mark
	here 'vv !
	-5.0 ,fp -5.0 ,fp -15.0 ,fp
	0 ,fp 1.0 ,fp 0 ,fp
	0 ,

	-5.0 ,fp 5.0 ,fp -15.0 ,fp
	0 ,fp 1.0 ,fp 0 ,fp
	$0020 ,

	5.0 ,fp 5.0 ,fp -15.0 ,fp
	0 ,fp 1.0 ,fp 0 ,fp
	$200020 ,

	5.0 ,fp -5.0 ,fp -15.0 ,fp
	0 ,fp 1.0 ,fp 0 ,fp
	$200000 ,

	-5.0 ,fp -5.0 ,fp 15.0 ,fp
	0 ,fp 1.0 ,fp 0 ,fp
	$200020 ,

	-5.0 ,fp 5.0 ,fp 15.0 ,fp
	0 ,fp 1.0 ,fp 0 ,fp
	$200040 ,

	5.0 ,fp 5.0 ,fp 15.0 ,fp
	0 ,fp 1.0 ,fp 0 ,fp
	$400040 ,

	5.0 ,fp -5.0 ,fp 15.0 ,fp
	0 ,fp 1.0 ,fp 0 ,fp
	$400020 ,
	
	here 'vi !
	0 , 1 , 2 , 0 , 2 , 3 ,	
	4 , 5 , 6 , 4 , 6 , 7 ,
	
	1 'pl_count +!
	1 'pl_count +!
	empty

    pl_vao glBindVertexArray

    GL_ARRAY_BUFFER pl_vbo glBindBuffer
    GL_ARRAY_BUFFER pl_count 112 * vv GL_STATIC_DRAW glBufferData

    GL_ELEMENT_ARRAY_BUFFER pl_ebo glBindBuffer
    GL_ELEMENT_ARRAY_BUFFER pl_count 24 * vi GL_STATIC_DRAW glBufferData

	;

	
::Iniplanes
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

    | stride = 28 bytes
    | attrib 0: aPos    vec3 float  offset  0
    0 glEnableVertexAttribArray
    0 3 GL_FLOAT GL_FALSE 28 0  glVertexAttribPointer
    | attrib 1: aNormal vec3 float  offset 12
    1 glEnableVertexAttribArray
    1 3 GL_FLOAT GL_FALSE 28 12 glVertexAttribPointer
    | attrib 2: aUV     uint        offset 24  (integer attrib — no normalization)
    2 glEnableVertexAttribArray
    2 1 GL_UNSIGNED_INT 28 24 glVertexAttribIPointer
    0 glBindVertexArray
	;


#atlasimgsize 0
#pl_surface

:imgtex>wh  pl_surface dup 16 + d@ swap 20 + d@ ;
:imgtex>pix pl_surface 32 + @ ;

::rl_load_atlas | "" --
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
	
::endGeom
    rl_sh_geom glDeleteProgram
	
	1 'g_cube_vao glDeleteVertexArrays
	1 'g_cube_vbo glDeleteBuffers
	1 'g_cube_ebo glDeleteBuffers
	
    rl_sh_planes glDeleteProgram

    1 'pl_vao glDeleteVertexArrays
    1 'pl_vbo glDeleteBuffers
    1 'pl_ebo glDeleteBuffers

    pl_atlas_tex 1? ( 1 'pl_atlas_tex glDeleteTextures ) drop

    0 'pl_count !
    0 'pl_vao !  0 'pl_vbo !  0 'pl_ebo !
	;
	
::rl_ProgGeom
	rl_sh_geom glUseProgram ;

::rl_setcolor | rgbmm --
	rl_u_uPackColor swap glUniform1ui ;

::rl_geomat	| normal model --
	>r rl_u_model 1 GL_FALSE r> glUniformMatrix4fv
	>r rl_u_normal_matrix 1 GL_FALSE r> glUniformMatrix3fv 
	;
	
	
#fmodel * 64 | mat4x4
#fnormal * 36 | mat3x3	

::draw_cube 
	'fmodel 'mat cpymatif
	matinv
	'fnormal 'mati cpymatif3
	'fnormal 'fmodel rl_geomat	
	g_cube_vao glBindVertexArray
    GL_TRIANGLES 36 GL_UNSIGNED_INT 0 glDrawElements ;

::draw_planes
    |pl_count 0? ( drop ; ) drop
    rl_sh_planes glUseProgram
	
    GL_TEXTURE2    glActiveTexture
    GL_TEXTURE_2D  pl_atlas_tex  glBindTexture
    pl_vao glBindVertexArray
    GL_TRIANGLES pl_count 6 * GL_UNSIGNED_INT 0 glDrawElements
    0 glBindVertexArray 
	;