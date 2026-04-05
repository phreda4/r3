| R3LIB 
| PHREDA 2026

^r3/lib/sdl2gl.r3
^r3/lib/glutil.r3

^r3/lib/trace.r3

^./rlmat.r3

| SHADERS ===>
#rl_shader_geom "
@vertex-----------------
#version 440 core
layout(location=0) in vec3 aPos;
layout(location=1) in vec3 aNormal;
layout(std140, binding=0) uniform Matrices {
    mat4 view; mat4 proj; mat4 invView; mat4 invProj; vec4 viewPos; };
uniform mat4 model;
uniform mat3 normalMatrix;
out vec3 vPos; out vec3 vNormal;
void main(){
    vec4 wp = model*vec4(aPos,1.0);
    vPos = wp.xyz;
    vNormal = normalMatrix*aNormal;
    gl_Position = proj*view*wp;
}
@fragment---------------
#version 440 core
in vec3 vPos; in vec3 vNormal;
uniform vec3 uAlbedo; uniform int uRoughness, uMetallic, uGlow;
layout(location=0) out vec3 gNormal;
layout(location=1) out vec4 gAlbedo;
void main(){
    gNormal   = normalize(vNormal);
    int pk = (uRoughness<<5)|(uMetallic<<2)|uGlow;
    gAlbedo = vec4(uAlbedo, float(pk)/255.0);
}
@-----------------------"

#rl_shader_quad_vert "
@vertex-----------------
#version 440 core
layout(location=0) in vec2 aPos;
out vec2 uv;
void main(){ uv=aPos*0.5+0.5; gl_Position=vec4(aPos,0,1); }
@fragment---------------
#version 440 core
void main(){}
@-----------------------"

#rl_shader_light "
@vertex-----------------
#version 440 core
layout(location=0) in vec2 aPos;
out vec2 uv;
void main(){ uv=aPos*0.5+0.5; gl_Position=vec4(aPos,0,1); }
@fragment---------------
#version 440 core
in vec2 uv; out vec4 FragColor;
layout(binding=0) uniform sampler2D gNormal;
layout(binding=1) uniform sampler2D gAlbedo;
layout(binding=2) uniform sampler2D occlusionTex;
layout(binding=3) uniform sampler2D gDepth;
layout(std140,binding=0) uniform Matrices{
    mat4 view;mat4 proj;mat4 invView;mat4 invProj;vec4 viewPos;};
layout(std140,binding=1) uniform DirectLight{
    vec4 lightDir; vec4 lightColor;
    int dirLightEnabled; int _pad[3];};
layout(std140,binding=2) uniform PointLights{
    ivec4 header;
    struct { vec4 pos; vec4 color; } lights[16];
} pl;
uniform int uAOEnabled;
vec3 rl_reconstruct_pos(sampler2D depthTex, vec2 uv,
                        mat4 invProj_, mat4 invView_) {
    float d = texture(depthTex, uv).r;
    vec4 ndc = vec4(uv * 2.0 - 1.0, d * 2.0 - 1.0, 1.0);
    vec4 vp  = invProj_ * ndc;  vp /= vp.w;
    return (invView_ * vp).xyz;
}
const float PI_RCP = 0.31830988618;
float D_GGX(float NdH, float a2){
    float d = NdH*NdH*(a2-1.0)+1.0;
    return a2/(d*d);}
float G_Schlick(float ndv, float k){
    return ndv/(ndv*(1.0-k)+k);}
vec3 F_Schlick(float ct, vec3 F0){
    float f=1.0-ct; float f2=f*f;
    return F0+(1.0-F0)*(f2*f2*f);}
vec3 CookTorrance(float NdH,float NdV,float NdL,float a2,float k,vec3 F){
    return (D_GGX(NdH,a2)*PI_RCP * G_Schlick(NdV,k)*G_Schlick(NdL,k) * F)
           / (4.0*NdV*NdL+0.0001);}
void main(){
    vec3  nm  = texture(gNormal,  uv).xyz;
	if(dot(nm,nm)<0.01){FragColor=vec4(0,0,0,1);return;}
    vec3  fp  = rl_reconstruct_pos(gDepth,uv,invProj,invView);
    vec4  aM  = texture(gAlbedo,  uv);
    vec4  sh  = texture(occlusionTex,uv);
    vec3  alb = aM.rgb;
    int   pk  = int(aM.a*255.0+0.5);
    float rough = float((pk>>5)&0x7)/7.0;
    float metal = float((pk>>2)&0x7)/7.0;
    float glow  = float(pk&3);
    float occ = (uAOEnabled==1) ? clamp(1.0-(dot(sh.xyz,nm)+sh.w),0.0,1.0) : 1.0;
    vec3  N   = normalize(nm);
    vec3  V   = normalize(viewPos.xyz-fp);
    float NdV = max(dot(N,V),0.0);
    vec3  F0  = mix(vec3(0.04),alb,metal);
    float a2  = rough*rough*rough*rough;
    float k   = (rough+1.0)*(rough+1.0)*0.125;
    vec3  albDiff = alb * PI_RCP * (1.0-metal);
    vec3  Lo  = vec3(0.0);
    if(dirLightEnabled==1){
        vec3  L   = normalize(-lightDir.xyz);
        vec3  H   = normalize(V+L);
        float NdL = max(dot(N,L),0.0);
        float NdH = max(dot(N,H),0.0);
        vec3  F   = F_Schlick(max(dot(H,V),0.0),F0);
        vec3  spc = CookTorrance(NdH,NdV,NdL,a2,k,F);
        vec3  kD  = (1.0-F)*albDiff;
        vec3  rad = lightColor.xyz*lightColor.w;
        Lo += (kD+spc)*rad*(NdL*occ);
    }
    int lightCount = pl.header.x;
    for(int i=0;i<lightCount;++i){
        vec3  lv      = pl.lights[i].pos.xyz-fp;
        float dist2   = dot(lv,lv);
        float invDist = inversesqrt(dist2);
        float dist    = 1.0/invDist;
        float att     = 1.0/(1.0+dist*(0.09+0.032*dist));
        vec3  L       = lv*invDist;
        vec3  H    = normalize(V+L);
        float NdL  = max(dot(N,L),0.0);
        float NdH  = max(dot(N,H),0.0);
        vec3  F    = F_Schlick(max(dot(H,V),0.0),F0);
        vec3  spc  = CookTorrance(NdH,NdV,NdL,a2,k,F);
        vec3  kD   = (1.0-F)*albDiff;
        vec3  rad  = pl.lights[i].color.rgb * pl.lights[i].color.w;
        Lo += (kD+spc)*rad*(NdL*occ*att);
    }
    vec3 ambient  = alb*(0.015*occ);
    vec3 emission = alb*(1.1*glow);
    FragColor = vec4(ambient+Lo+emission,1.0);
}
@-----------------------"

#rl_shader_bright "
@vertex-----------------
#version 440 core
layout(location=0) in vec2 aPos;
out vec2 uv;
void main(){ uv=aPos*0.5+0.5; gl_Position=vec4(aPos,0,1); }
@fragment---------------
#version 440 core
in vec2 uv; out vec4 FragColor;
layout(binding=0) uniform sampler2D scene;
uniform float threshold;
void main(){
    vec3 c=texture(scene,uv).rgb;
    float lum=dot(c,vec3(0.2126,0.7152,0.0722));
    float soft=clamp((lum-threshold)/max(threshold*0.5,0.0001),0,1);
    FragColor=vec4(c*soft,1);
}
@-----------------------"

#rl_shader_bloom_down "
@vertex-----------------
#version 440 core
layout(location=0) in vec2 aPos;
out vec2 uv;
void main(){ uv=aPos*0.5+0.5; gl_Position=vec4(aPos,0,1); }
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
@vertex-----------------
#version 440 core
layout(location=0) in vec2 aPos;
out vec2 uv;
void main(){ uv=aPos*0.5+0.5; gl_Position=vec4(aPos,0,1); }
@fragment---------------
#version 440 core
in vec2 uv; out vec4 FragColor;
layout(binding=0) uniform sampler2D src;
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
    FragColor=s/12.0;
}
@-----------------------"

#rl_shader_composite "
@vertex-----------------
#version 440 core
layout(location=0) in vec2 aPos;
out vec2 uv;
void main(){ uv=aPos*0.5+0.5; gl_Position=vec4(aPos,0,1); }
@fragment---------------
#version 440 core
in vec2 uv; out vec4 FragColor;
layout(binding=0) uniform sampler2D scene;
layout(binding=1) uniform sampler2D bloom;
uniform float bloomIntensity;
vec3 ACES(vec3 x){
    const float a=2.51,b=0.03,c=2.43,d=0.59,e=0.14;
    return clamp((x*(a*x+b))/(x*(c*x+d)+e),0,1);}
void main(){
    vec3 col=texture(scene,uv).rgb;
    col+=texture(bloom,uv).rgb*bloomIntensity;
    col=ACES(col);
    col=pow(col,vec3(1.0/2.2));
    FragColor=vec4(col,1);
}
@---" | <======= SHADERS

|-----------------------------------------------------------
#rl_w 1024 #rl_h 768

| GBuffer
#rl_gbuf_fbo    0
#rl_gbuf_norm   0
#rl_gbuf_albedo 0
#rl_gbuf_depth  0

| Scene + Bloom
#rl_scene_fbo   0
#rl_scene_tex   0
#rl_scene_depth 0

| Quad
##rl_quad_vao 0  #rl_quad_vbo 0

| UBOs
#rl_ubo_matrices  0
#rl_ubo_dirlight  0
#rl_ubo_plights   0

| Shaders
#rl_sh_geom       0
#rl_sh_light      0
#rl_sh_bright     0
#rl_sh_bloom_down 0
#rl_sh_bloom_up   0
#rl_sh_composite  0

| Uniform locations
#rl_u_model         -1
#rl_u_albedo        -1
#rl_u_roughness     -1
#rl_u_metallic      -1
#rl_u_glow          -1
#rl_u_normal_matrix -1
#rl_u_ao_enabled    -1
#rl_u_bright_threshold    -1
#rl_u_bloom_down_texel    -1
#rl_u_bloom_up_texel      -1
#rl_u_composite_intensity -1

| Luces puntuales del frame
| PointLight: pos[4] + color[4] = 8 floats = 32 bytes
#rl_plights * 1024 | 32 x32
#rl_plight_count 0

| AO
#rl_ao_texture   0
#rl_ao_white_tex 0

#tid #aux

|----------------------------------
:rl_make_tex2d | ifmt w h fmt type minf magf wrap -- texid
	>r >r >r >r >r >r >r >r
    1 'tid glGenTextures
    GL_TEXTURE_2D tid glBindTexture
    GL_TEXTURE_2D 0 r> r> r> 0 r> r> 0 glTexImage2D
    GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER r> glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER r> glTexParameteri
    r> 1? ( 
		GL_TEXTURE_2D GL_TEXTURE_WRAP_S pick2 glTexParameteri
		GL_TEXTURE_2D GL_TEXTURE_WRAP_T pick2 glTexParameteri
		) drop
	GL_TEXTURE_2D 0 glBindTexture
	tid ;

:rl_make_fbo | color_tex depth_tex -- fbo
    1 'tid glGenFramebuffers
    GL_FRAMEBUFFER tid glBindFramebuffer
	1? ( 
		GL_FRAMEBUFFER GL_DEPTH_ATTACHMENT GL_TEXTURE_2D pick3 0 glFramebufferTexture2D 
		) drop
	1? ( 
		GL_FRAMEBUFFER GL_COLOR_ATTACHMENT0 GL_TEXTURE_2D pick3 0 glFramebufferTexture2D 
		GL_COLOR_ATTACHMENT0 'aux !
		1 'aux glDrawBuffers
		) drop
|	GL_FRAMEBUFFER glCheckFramebufferStatus
|    $8CD5 <>? ( drop "[rl] FBO incompleto" .println ; ) drop   | GL_FRAMEBUFFER_COMPLETE = 0x8CD5
    GL_FRAMEBUFFER 0 glBindFramebuffer
    tid
    ;

| GLenum draws[2] = {GL_COLOR_ATTACHMENT0, GL_COLOR_ATTACHMENT1}
#_gdb_draws [ $8CE0 $8CE1 ]

:rl_init_gbuffer
    1 'rl_gbuf_fbo glGenFramebuffers
    GL_FRAMEBUFFER rl_gbuf_fbo glBindFramebuffer
    | gNormal: GL_RGB16F 
    GL_RGB16F rl_w rl_h GL_RGB GL_FLOAT GL_NEAREST GL_NEAREST 0
    rl_make_tex2d 'rl_gbuf_norm !
    | gAlbedo: GL_RGBA8
    GL_RGBA8 rl_w rl_h GL_RGBA GL_UNSIGNED_BYTE GL_NEAREST GL_NEAREST 0
    rl_make_tex2d 'rl_gbuf_albedo !
    | gDepth: GL_DEPTH_COMPONENT32F
    GL_DEPTH_COMPONENT32F rl_w rl_h GL_DEPTH_COMPONENT GL_FLOAT GL_NEAREST GL_NEAREST 0
    rl_make_tex2d 'rl_gbuf_depth !
    GL_FRAMEBUFFER GL_COLOR_ATTACHMENT0 GL_TEXTURE_2D rl_gbuf_norm   0 glFramebufferTexture2D
    GL_FRAMEBUFFER GL_COLOR_ATTACHMENT1 GL_TEXTURE_2D rl_gbuf_albedo 0 glFramebufferTexture2D
    GL_FRAMEBUFFER GL_DEPTH_ATTACHMENT  GL_TEXTURE_2D rl_gbuf_depth  0 glFramebufferTexture2D
    2 '_gdb_draws glDrawBuffers

|    GL_FRAMEBUFFER glCheckFramebufferStatus|
|    $8CD5 <>? ( drop "[rl] GBuffer FBO incompleto" .println ; ) drop

	GL_FRAMEBUFFER 0 glBindFramebuffer
	GL_TEXTURE_2D 0 glBindTexture
	;

| Bloom FBOs y texturas: 5 mips × 2 sides = 10 entradas (dwords)
:RL_BLOOM_MIPS 5 ; 

#listwh [ 0 0 0 0 0 0 ]
#lisafp 0 0 0 0 0 0

#listex [ 0 0 0 0 0 0 ]
#lisfbo [ 0 0 0 0 0 0 ]

:]wh | n -- w h
	2 << 'listwh + d@ dup $ffff and swap 16 >>> ;
:]wh! | wh n --
	2 << 'listwh + d! ;

:]afp | n -- afp
	3 << 'lisafp + ;
:]afp! | afp n -- 
	3 << 'lisafp + ! ;
	
:]tex | n -- tex
	2* 'listex + w@ ;
:]fbo | n -- fbo
	2* 'lisfbo + w@ ;

| ================================================================	
:rl_init_bloom
    | scene_tex: 
    GL_RGBA16F rl_w rl_h GL_RGBA GL_FLOAT GL_LINEAR GL_LINEAR 0
    rl_make_tex2d 'rl_scene_tex !
    | scene_depth: 
    GL_DEPTH_COMPONENT24 rl_w rl_h GL_DEPTH_COMPONENT GL_FLOAT GL_NEAREST GL_NEAREST 0
    rl_make_tex2d 'rl_scene_depth !

    rl_scene_tex rl_scene_depth rl_make_fbo 'rl_scene_fbo !
	
    | Bloom mips
	'listex >a
	'lisfbo >b
    rl_w rl_h 0 ( RL_BLOOM_MIPS <? >r
		swap 2/ 2 max 
		swap 2/ 2 max   | w h
		2dup 16 << or r@ ]wh!
		1.0 pick2 / f2fp $ffffffff and 
		1.0 pick2 / f2fp 32 << or r@ ]afp!
		GL_RGBA16F pick2 pick2 GL_RGBA GL_FLOAT GL_LINEAR GL_LINEAR GL_CLAMP_TO_EDGE rl_make_tex2d 
		dup a> w!+ >a 0 rl_make_fbo b> w!+ >b
		GL_RGBA16F pick2 pick2 GL_RGBA GL_FLOAT GL_LINEAR GL_LINEAR GL_CLAMP_TO_EDGE rl_make_tex2d 
		dup a> w!+ >a 0 rl_make_fbo b> w!+ >b
		r> 1+ ) 3drop ;

| ================================================================
:rl_destroy_gbuffer
    rl_gbuf_fbo    1? ( 1 'rl_gbuf_fbo    glDeleteFramebuffers ) drop
    rl_gbuf_norm   1? ( 1 'rl_gbuf_norm   glDeleteTextures     ) drop
    rl_gbuf_albedo 1? ( 1 'rl_gbuf_albedo glDeleteTextures     ) drop
    rl_gbuf_depth  1? ( 1 'rl_gbuf_depth  glDeleteTextures     ) drop
    0 'rl_gbuf_fbo !  0 'rl_gbuf_norm !  0 'rl_gbuf_albedo !  0 'rl_gbuf_depth !
    ;

:rl_destroy_bloom
    rl_scene_fbo   1? ( 1 'rl_scene_fbo   glDeleteFramebuffers ) drop
    rl_scene_tex   1? ( 1 'rl_scene_tex   glDeleteTextures     ) drop
    rl_scene_depth 1? ( 1 'rl_scene_depth glDeleteTextures     ) drop
	'listex >a
	'lisfbo >b
	RL_BLOOM_MIPS ( 1? 1-
		da@+
		1 over 16 >> glDeleteTextures
		1 swap $ffff glDeleteTextures
		db@+
		1 over 16 >> glDeleteFramebuffers
		1 swap $ffff glDeleteFramebuffers
		) drop ;


#_quad_verts [ -1.0 -1.0  1.0 -1.0  -1.0 1.0  1.0 1.0 ]
#RL_BLOOM_INTENSITY [ 1.2 ]
#RL_BLOOM_THRESHOLD [ 0.8 ]

| ================================================================
:rl_init_quad
	10 '_quad_verts memfloat 
	
    1 'rl_quad_vao glGenVertexArrays
    1 'rl_quad_vbo glGenBuffers
    rl_quad_vao glBindVertexArray
    GL_ARRAY_BUFFER rl_quad_vbo glBindBuffer
    GL_ARRAY_BUFFER 8 4 * '_quad_verts GL_STATIC_DRAW glBufferData
    0 glEnableVertexAttribArray
    0 2 GL_FLOAT GL_FALSE 2 4 * 0 glVertexAttribPointer
    0 glBindVertexArray
    ;

| ================================================================
:rl_init_ubos
    1 'rl_ubo_matrices glGenBuffers
    GL_UNIFORM_BUFFER rl_ubo_matrices glBindBuffer
    GL_UNIFORM_BUFFER 272 0 GL_DYNAMIC_DRAW glBufferData
    GL_UNIFORM_BUFFER 0 rl_ubo_matrices glBindBufferBase

    1 'rl_ubo_dirlight glGenBuffers
    GL_UNIFORM_BUFFER rl_ubo_dirlight glBindBuffer
    GL_UNIFORM_BUFFER 48 0 GL_DYNAMIC_DRAW glBufferData
    GL_UNIFORM_BUFFER 1 rl_ubo_dirlight glBindBufferBase

    1 'rl_ubo_plights glGenBuffers
    GL_UNIFORM_BUFFER rl_ubo_plights glBindBuffer
    GL_UNIFORM_BUFFER 528 0 GL_DYNAMIC_DRAW glBufferData
    GL_UNIFORM_BUFFER 2 rl_ubo_plights glBindBufferBase

    GL_UNIFORM_BUFFER 0 glBindBuffer
	| rl_ubo_plights rl_ubo_dirlight rl_ubo_matrices "%d %d %d" .println
    ;

| ================================================================
:rl_bind_ubo | binding prog "name" --
	over swap glGetUniformBlockIndex  | binding prog index
	|(idx!=GL_INVALID_INDEX)
	rot glUniformBlockBinding ;

| ================================================================

| Textura blanca 1×1 para AO neutro
#_white_px [ $ffffffff ]   | RGBA 255,255,255,255 como dword

::rl_Init
    rl_init_gbuffer
    rl_init_bloom
    rl_init_quad
    rl_init_ubos
	
	|'_intensity d@ fp2f "%f" .println
	
    'rl_shader_geom       loadShaderv 'rl_sh_geom       !
    'rl_shader_light      loadShaderv 'rl_sh_light      !
    'rl_shader_bright     loadShaderv 'rl_sh_bright     !
    'rl_shader_bloom_down loadShaderv 'rl_sh_bloom_down !
    'rl_shader_bloom_up   loadShaderv 'rl_sh_bloom_up   !
    'rl_shader_composite  loadShaderv 'rl_sh_composite  !

    0 rl_sh_geom  "Matrices"     rl_bind_ubo
    0 rl_sh_light "Matrices"     rl_bind_ubo
    1 rl_sh_light "DirectLight"  rl_bind_ubo
    2 rl_sh_light "PointLights"  rl_bind_ubo

    rl_sh_geom "model"        glGetUniformLocation 'rl_u_model         !
    rl_sh_geom "uAlbedo"      glGetUniformLocation 'rl_u_albedo        !
    rl_sh_geom "uRoughness"   glGetUniformLocation 'rl_u_roughness     !
    rl_sh_geom "uMetallic"    glGetUniformLocation 'rl_u_metallic      !
    rl_sh_geom "uGlow"        glGetUniformLocation 'rl_u_glow          !
    rl_sh_geom "normalMatrix" glGetUniformLocation 'rl_u_normal_matrix !

    rl_sh_bright     "threshold"      glGetUniformLocation 'rl_u_bright_threshold    !
    rl_sh_bloom_down "texelSize"      glGetUniformLocation 'rl_u_bloom_down_texel    !
    rl_sh_bloom_up   "texelSize"      glGetUniformLocation 'rl_u_bloom_up_texel      !
    rl_sh_composite  "bloomIntensity" glGetUniformLocation 'rl_u_composite_intensity !
    rl_sh_light      "uAOEnabled"     glGetUniformLocation 'rl_u_ao_enabled          !
    
    1 'rl_ao_white_tex glGenTextures
    GL_TEXTURE_2D rl_ao_white_tex glBindTexture
    GL_TEXTURE_2D 0 GL_RGBA8 1 1 0 GL_RGBA GL_UNSIGNED_BYTE '_white_px glTexImage2D
    GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_NEAREST glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_NEAREST glTexParameteri
    GL_TEXTURE_2D 0 glBindTexture
	
    rl_ao_white_tex 'rl_ao_texture ! |0

    GL_CULL_FACE glEnable
    GL_BACK glCullFace
    GL_CCW glFrontFace
	;
	
::rl_shutdown
    rl_sh_geom       glDeleteProgram
    rl_sh_light      glDeleteProgram
    rl_sh_bright     glDeleteProgram
    rl_sh_bloom_down glDeleteProgram
    rl_sh_bloom_up   glDeleteProgram
    rl_sh_composite  glDeleteProgram

    rl_destroy_gbuffer
    rl_destroy_bloom

    1 'rl_quad_vao glDeleteVertexArrays
    1 'rl_quad_vbo glDeleteBuffers
    1 'rl_ao_white_tex glDeleteTextures
    1 'rl_ubo_matrices glDeleteBuffers
    1 'rl_ubo_dirlight glDeleteBuffers
    1 'rl_ubo_plights  glDeleteBuffers
    ;

|------------- CAMERA ------------------
#camDirty  1

##camParam 0	| ASPECT
#camFov 0.4142		| really atan 
#camNear 0.5	
#camFar 200.0

##camEye 0.0 2.0  6.0
##camTo  0.0 0.0  0.0
##camUp  0.0 1.0  0.0

| ================================================================
::rl_resizewin | w h --
    rl_h =? ( swap rl_w  =? ( 2drop ; ) ) 'rl_w ! 'rl_h !
    1 'camDirty !
	rl_destroy_bloom rl_destroy_gbuffer  
	rl_init_gbuffer rl_init_bloom
    ;

| ================================================================
::rl_set_projection | fov_deg_fp near_fp far_fp --
    'camFar ! 'camNear ! 'camFov ! 
	1 'camDirty ! ;


|----- UBO->GPU
| RL_UBO_Matrices: view(64) proj(64) invView(64) invProj(64) viewPos(16) = 272 bytes
#ubo_matView * 64
#ubo_matvProj * 64
#ubo_matvinvView * 64
#ubo_matvinvProj * 64
#ubo_matvviewPos * 16


|****DEBUUG
::.printfm
	>a 4 ( 1? 1- 4 ( 1? 1- da@+ fp2f "%f " .print ) drop .cr ) drop "" .println ;

::.printfm3
	>a 3 ( 1? 1- 3 ( 1? 1- da@+ fp2f "%f " .print ) drop .cr ) drop "" .println ;
	
::.printv
	>a da@+ fp2f da@+ fp2f da@ fp2f "(%f %f %f)" .println ;
	
:debugmat
	"view" .println 'ubo_matView .printfm .cr
	"pro" .println 'ubo_matvProj .printfm .cr
	"inv view" .println 'ubo_matvinvView .printfm .cr
	"inv proj" .println 'ubo_matvinvProj .printfm .cr
	'ubo_matvviewPos .printv .cr ;
	
|------------------------------------
:cache_proj
	camDirty 0? ( drop ; ) drop
	0 'camDirty !
	rl_w 16 << rl_h / 'camParam ! |camParam "%f" .println
	'camParam matProj 
	'ubo_matvProj 'mat cpymatif 
	'ubo_matvinvProj 'mati cpymatif
	;

::rl_set_camera | --
	cache_proj
	'camEye 'camTo 'camUp mlookat
	'ubo_matView 'mat cpymatif
	matinv
	'ubo_matvinvView 'mati cpymatif
	3 'camEye 'ubo_matvviewPos mem2float | cnt sr ds

|//	debugmat <<trace
	GL_UNIFORM_BUFFER rl_ubo_matrices glBindBuffer
	GL_UNIFORM_BUFFER 0 272 'ubo_matview glBufferSubData
	GL_UNIFORM_BUFFER 0 glBindBuffer
	;

#deepValue 0
#clearColorPtr [ 0 0 0 0 ]

| ================================================================
::rl_frame_begin | --
    0 'rl_plight_count !
    |0 'rl_ao_texture !

	GL_GREATER glDepthFunc
	
    0 0 rl_w rl_h glViewport
    GL_FRAMEBUFFER rl_gbuf_fbo glBindFramebuffer
	GL_DEPTH_TEST glEnable
	GL_TRUE glDepthMask

	$1800 0 'clearColorPtr glClearBufferfv | Limpiar Normales (ATTACHMENT0 -> Índice 0)
	$1800 1 'clearColorPtr glClearBufferfv | Limpiar Albedo (ATTACHMENT1 -> Índice 1)
	$1801 0 'deepValue glClearBufferfv     | Limpiar Profundidad (ATTACHMENT_DEPTH -> )

	rl_set_camera
	|rl_sh_geom glUseProgram
    ;

| RL_UBO_DirectLight: lightDir(16) lightColor(16) dirLightEnabled(4) _pad(12) = 48 bytes
#rl_ubo_dl_buf  * 48
	
| ================================================================
| dx_fp dy_fp dz_fp  r_fp g_fp b_fp intensity_fp enabled
::rl_set_sun | 'sun --
	'rl_ubo_dl_buf swap 12 dmove |d s c
    GL_UNIFORM_BUFFER rl_ubo_dirlight glBindBuffer
    GL_UNIFORM_BUFFER 0 48 'rl_ubo_dl_buf glBufferSubData
    GL_UNIFORM_BUFFER 0 glBindBuffer
    ;

| ================================================================
| Cada PointLight = 32 bytes: pos[4](16) + color[4](16)
::rl_point_light | int cr cg cb x y z --
    rl_plight_count 5 << 'rl_plights + >a  | ptr a este slot (32*i = i<<5)
	swap rot f2fp da!+ f2fp da!+ f2fp da!+ 0 da!+
	swap rot f2fp da!+ f2fp da!+ f2fp da!+ f2fp da!+
    1 'rl_plight_count +!
    ;

| ================================================================
::rl_set_ao_texture | texid --
    'rl_ao_texture !
    ;

| ================================================================
| RL_UBO_PointLights: count[4](16) + 16×(pos[4]+color[4])(32) = 16 + 512 = 528 bytes

#_ao_on 1
#rl_ubo_pl_buf * 528

:lightpass
	| Upload point lights
	rl_plight_count 'rl_ubo_pl_buf d!          | count[0]
	'rl_ubo_pl_buf 16 + 'rl_plights rl_plight_count 5 << cmove |dsc
	GL_UNIFORM_BUFFER rl_ubo_plights glBindBuffer
	GL_UNIFORM_BUFFER 0 16 rl_plight_count 5 << + 'rl_ubo_pl_buf glBufferSubData
	GL_UNIFORM_BUFFER 0 glBindBuffer
	GL_TRIANGLE_STRIP 0 4 glDrawArrays
	;
	
	
:bpassd | invw id ftex fbos wh --
	0 0 rot ]wh glViewport
	GL_FRAMEBUFFER swap ]fbo glBindFramebuffer
	GL_TEXTURE0 glActiveTexture
	GL_TEXTURE_2D swap ]tex glBindTexture
	1 rot ]afp glUniform2fv 
	GL_TRIANGLE_STRIP 0 4 glDrawArrays
	;
	
:bloompass
	rl_sh_bright glUseProgram
	rl_u_bright_threshold 1 'RL_BLOOM_THRESHOLD glUniform1fv
	0 0
	0 ]wh
	glViewport
	GL_FRAMEBUFFER 0 ]fbo glBindFramebuffer |bos tex
	GL_TEXTURE0 glActiveTexture 
	GL_TEXTURE_2D rl_scene_tex glBindTexture
	GL_TRIANGLE_STRIP 0 4 glDrawArrays
	
	| Downscale chain
	rl_sh_bloom_down glUseProgram
	0 rl_u_bloom_down_texel 0 2 1 bpassd | invw id ftex fbos w h --
	1 rl_u_bloom_down_texel 2 4 2 bpassd | invw id ftex fbos w h --
	2 rl_u_bloom_down_texel 4 6 3 bpassd | invw id ftex fbos w h --
	3 rl_u_bloom_down_texel 6 8 4 bpassd | invw id ftex fbos w h --
	
	| Upscale chain
	rl_sh_bloom_up glUseProgram
	4 rl_u_bloom_up_texel 8 7 3 bpassd | invw id ftex fbos w h --
	3 rl_u_bloom_up_texel 7 5 2 bpassd | invw id ftex fbos w h --
	2 rl_u_bloom_up_texel 5 3 1 bpassd | invw id ftex fbos w h --
	1 rl_u_bloom_up_texel 3 1 0 bpassd | invw id ftex fbos w h --
	
	;

	
| ================================================================
::rl_frame_end | --
    rl_quad_vao glBindVertexArray
    | --- Lighting pass → scene_tex ---
    0 0 rl_w rl_h glViewport
    GL_FRAMEBUFFER rl_scene_fbo glBindFramebuffer

	$1800 0 'clearColorPtr glClearBufferfv
	
    GL_DEPTH_TEST glDisable
    rl_sh_light glUseProgram
    GL_TEXTURE0 glActiveTexture GL_TEXTURE_2D rl_gbuf_norm   glBindTexture
    GL_TEXTURE1 glActiveTexture GL_TEXTURE_2D rl_gbuf_albedo glBindTexture  | GL_TEXTURE1
    GL_TEXTURE2 glActiveTexture GL_TEXTURE_2D rl_ao_white_tex glBindTexture  | GL_TEXTURE2
    GL_TEXTURE3 glActiveTexture GL_TEXTURE_2D rl_gbuf_depth  glBindTexture  | GL_TEXTURE3
	
    rl_u_ao_enabled 0 glUniform1i

	| --- Light pass
	lightpass
	
    | --- Bloom bright extraction ---
	bloompass

	| ---- Composite ----
	GL_FRAMEBUFFER 0 glBindFramebuffer
	0 0 rl_w rl_h glViewport
	
	$1800 0 'clearColorPtr glClearBufferfv
	
	rl_sh_composite glUseProgram
	GL_TEXTURE0 glActiveTexture GL_TEXTURE_2D rl_scene_tex glBindTexture
	GL_TEXTURE1 glActiveTexture GL_TEXTURE_2D 1 ]tex glBindTexture | bloom_texs[1]
	rl_u_composite_intensity 1 'RL_BLOOM_INTENSITY glUniform1fv
	GL_TRIANGLE_STRIP 0 4 glDrawArrays
	
    | --- Blit depth ---
    GL_READ_FRAMEBUFFER rl_gbuf_fbo glBindFramebuffer
    GL_DRAW_FRAMEBUFFER 0 glBindFramebuffer
    0 0 rl_w rl_h 2over 2over
	|0 0 rl_w rl_h 
	GL_DEPTH_BUFFER_BIT GL_NEAREST glBlitFramebuffer
    GL_FRAMEBUFFER 0 glBindFramebuffer
    ;
	

::rl_gbuffer_textures | 'out_norm 'out_depth --
    rl_gbuf_depth swap d!
    rl_gbuf_norm  swap d!
    ;

| ================================================================
::rl_ProgGeom
	rl_sh_geom glUseProgram ;

#colora [ 0 0 0 ]

::rl_setcolor | rgbmm --
    rl_u_roughness over 2 >> $7 and glUniform1i
    rl_u_metallic over 5 >> $7 and glUniform1i
	rl_u_glow over $3 and glUniform1i
	dup   8 >> $ff and 1.0 8 *>> f2fp
	over 16 >> $ff and 1.0 8 *>> f2fp
	rot  24 >> $ff and 1.0 8 *>> f2fp
	'colora d!+ d!+ d!
	rl_u_albedo 1 'colora glUniform3fv
	|'cola d@+ fp2f "%f " .print d@+ fp2f "%f " .print d@ fp2f "%f " .println <<trace
	;
	
::rl_geomat	| normal model --
	>r rl_u_model 1 GL_FALSE r> glUniformMatrix4fv
	>r rl_u_normal_matrix 1 GL_FALSE r> glUniformMatrix3fv 
	;

