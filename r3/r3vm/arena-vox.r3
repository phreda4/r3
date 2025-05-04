^r3/lib/gui.r3
^r3/lib/sdl2.r3
^r3/lib/sdl2gl.r3
^r3/lib/sdl2gfx.r3
^r3/lib/3dgl.r3
^r3/lib/rand.r3

^r3/r3vm/voxelgl.r3

^r3/util/varanim.r3
^r3/util/ttext.r3

^./arena-edit.r3
^./tedit.r3
^./rcodevm.r3

#codepath "r3/r3vm/codecube/"

|-------------------------------------
|#eyed 18.0
#pEye 0.0 0.0 18.0
#pTo 0 0 0
#pUp 0 1.0 0

#IDprojection
#fprojection * 64

#IDview
#fview * 64

#IDmodel
#fmodel * 64

|----------------------------------------------------------
#voxels * 4096
#voxels2 * 4096

#paleta [ | uchu
$080a0d $0949ac $b56227 $2e943a
$542690 $a30d30 $fdfdfd $b59944
$878a8b $3984f2 $ff9f5b $64d970
$915ad3 $ea3c65 $cbcdcd $fedf7b ]

:genrandcolor
	'voxels >a 16 16 * 16 * ( 1? 1- 
		$7f randmax 
		15 >? ( 0 nip )
		ca!+ ) drop ;

:buildvox1 | vec --
	'voxels >a
	0 ( $1000 <?
		dup 8 >> $f and 
		over 4 >> $f and 
		pick2 $f and 
		pick4 ex ca!+
		1+ ) 2drop ;

:simple1
	0? ( 3drop 1 ; ) drop 
	0? ( 2drop 2 ; ) drop 
	0? ( drop 3 ; ) drop 
	0 ;
	
	
:buildvox2 | vec --
	'voxels2 >a
	0 ( $1000 <?
		dup 8 >> $f and 
		over 4 >> $f and 
		pick2 $f and 
		pick4 ex ca!+
		1+ ) 2drop ;
		
:emptyvox
	3drop 0 ;

|-------------------------------------
#GL_DEPTH_TEST $0B71
#GL_LESS $0201
#GL_CULL_FACE $0B44

#GL_ARRAY_BUFFER $8892
#GL_UNIFORM_BUFFER $8A11
#GL_STATIC_DRAW $88E4
#GL_DYNAMIC_COPY $88EA
#GL_DYNAMIC_DRAW $88E8
#GL_DYNAMIC_READ $88E9

#GL_ELEMENT_ARRAY_BUFFER $8893

#GL_UNSIGNED_BYTE $1401
#GL_UNSIGNED_SHORT $1403
#GL_INT $1404
#GL_UNSIGNED_INT $1405
#GL_FLOAT $1406

#GL_TRIANGLES $4
#GL_FALSE 0
#GL_FRAMEBUFFER $8D40
#GL_TEXTURE_2D $0DE1

|-----------------------------------------------------------------------
#vertexShaderSource "#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in float aType; // int no funciona !!

out vec3 fragPos;
out vec3 normal;
out vec3 fragColor;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;
//uniform vec3 palette[16];

const vec3 pal[16] = vec3[16](
vec3(0.0313,0.0392,0.0509),vec3(0.0352,0.2862,0.6744),vec3(0.7097,0.3843,0.1529),vec3(0.1803,0.5803,0.2274),
vec3(0.3294,0.1490,0.5646),vec3(0.6392,0.0509,0.1882),vec3(0.9921,0.9921,0.9921),vec3(0.7097,0.5999,0.2666),
vec3(0.5294,0.5411,0.5450),vec3(0.2235,0.5176,0.9490),vec3(1.0000,0.6235,0.3568),vec3(0.3921,0.8509,0.4392),
vec3(0.5686,0.3529,0.8274),vec3(0.9176,0.2352,0.3960),vec3(0.7960,0.8039,0.8039),vec3(0.9960,0.8744,0.4823)
);

void main() {
	int t=int(aType)&0xf;
	if (t==0) { // no draw
		gl_Position = vec4(0.0, 0.0, 0.0, 0.0);
		return;
		}

    int x = gl_InstanceID&0xf;
    int y = (gl_InstanceID>>4)&0xf;
    int z = (gl_InstanceID>>8)&0xf;

	fragColor = pal[t];
	
    //vec3 instanceOffset = vec3(-8.8,-8.8,-8.8)+vec3(x, y, z)*1.1; // (16*1.1)/2
	//vec3 instanceOffset = vec3(-8.4,-8.4,-8.4)+vec3(x, y, z)*1.05; // (16*1.1)/2
	vec3 instanceOffset = vec3(-8.0,-8.0,-8.0)+vec3(x, y, z)*1.0; // (16*1.0)/2

    fragPos = aPos + instanceOffset;
    normal = normalize(aPos); // Normales para sombreado
    gl_Position = projection * view * model * vec4(fragPos, 1.0);
	}"
|-----------------------------------------------------------------------
#fragmentShaderSource "#version 330 core
in vec3 fragPos;
in vec3 normal;
in vec3 fragColor;

out vec4 color;

uniform vec3 lightDir = normalize(vec3(1.0, 0.5, 1.5));

void main() {
    float diff = max(dot(normal, lightDir), 0.0);
	float diff2 = max(dot(normal, -lightDir), 0.0)*0.2;
    vec3 litColor = vec3(0.7)*diff2 + fragColor*diff + fragColor*0.6;

    color = vec4(litColor, 1.0);
	}"
|-----------------------------------------------------------------------

#shaderProgram
#VAO #VBO #EBO
#TypeVBO

|----------- data	
#cubeVertices [ 
-0.5 -0.5 -0.5	 0.5 -0.5 -0.5	 0.5  0.5 -0.5	-0.5  0.5 -0.5	
-0.5 -0.5  0.5	 0.5 -0.5  0.5	 0.5  0.5  0.5	-0.5  0.5  0.5 
]
#cubeIndices [ 
0 3 1 3 2 1		1 2 5 2 6 5		5 6 4 6 7 4		
4 7 0 7 3 0		3 7 2 7 6 2		4 0 5 0 1 5 
]

:progshader
	'fragmentShaderSource 
	'vertexShaderSource 
	inishader
	dup "projection" glGetUniformLocation 'IDprojection !
	dup "view" glGetUniformLocation 'IDview !
	dup "model" glGetUniformLocation 'IDmodel !
	0? ( drop .input ; )
	'shaderProgram !
	
|	genrandcolor
|	genrandcolor2
	|fillpaleta
	
	8 3 * 'cubeVertices 2float

    1 'VAO glGenVertexArrays
    1 'VBO glGenBuffers
    1 'EBO glGenBuffers
	1 'typeVBO glGenBuffers
	
    VAO glBindVertexArray

	GL_ARRAY_BUFFER VBO glBindBuffer			| vertices
	GL_ARRAY_BUFFER 8 3 * 4 * 'cubeVertices GL_STATIC_DRAW glBufferData
	GL_ELEMENT_ARRAY_BUFFER EBO glBindBuffer	| indices
	GL_ELEMENT_ARRAY_BUFFER 6 6 * 4 * 'cubeIndices GL_STATIC_DRAW glBufferData
	0 3 GL_FLOAT GL_FALSE 12 0 glVertexAttribPointer
	0 glEnableVertexAttribArray
	GL_ARRAY_BUFFER typeVBO glBindBuffer		| typos
	GL_ARRAY_BUFFER 16 16 * 16 * 'voxels GL_STATIC_DRAW glBufferData
	1 1 GL_UNSIGNED_BYTE GL_FALSE 1 0 glVertexAttribPointer | ??? pasa como float!!!
	1 glEnableVertexAttribArray
    1 1 glVertexAttribDivisor
	GL_ARRAY_BUFFER 0 glBindBuffer
	0 glBindVertexArray
	
	matini
	0.5 400.0 0.9 3.0 4.0 /. mperspective	| perspective matrix
	|-18.0 18.0 -18.0 18.0 -40.0 40.0 mortho
	'fprojection mcpyf 
	
|	rx 'pEye 8 + !
|	ry sincos eyed *. swap eyed *. 'pEye !+ 8 + !
	'pEye 'pTo 'pUp mlookat 'fview mcpyf 	
	;

|----------------------------------------------------------
#framebuffer
#textureColorbuffer
#rbo

:vieww 400 ;	:viewh 300 ;

:GL_TEXTURE_MIN_FILTER $2801 ;
:GL_LINEAR $2601 ;
:GL_TEXTURE_MAG_FILTER $2800 ;
:GL_COLOR_ATTACHMENT0 $8CE0 ;
:GL_RENDERBUFFER $8D41 ;
:GL_DEPTH24_STENCIL8 $88F0 ;
:GL_DEPTH_STENCIL_ATTACHMENT $821A ;

:GL_RGBA $1908 ;

:SetupFramebuffer
	1 'framebuffer glGenFramebuffers
	GL_FRAMEBUFFER framebuffer glBindFramebuffer
	1 'textureColorbuffer glGenTextures
	GL_TEXTURE_2D textureColorbuffer glBindTexture
	GL_TEXTURE_2D 0 GL_RGBA vieww 2* viewh 0 GL_RGBA GL_UNSIGNED_BYTE 0 glTexImage2D
	GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_LINEAR glTexParameteri
	GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_LINEAR glTexParameteri
	GL_TEXTURE_2D 0 glBindTexture
	GL_FRAMEBUFFER GL_COLOR_ATTACHMENT0 GL_TEXTURE_2D textureColorbuffer 0 glFramebufferTexture2D
	1 'rbo glGenRenderbuffers
	GL_RENDERBUFFER rbo glBindRenderbuffer
	GL_RENDERBUFFER GL_DEPTH24_STENCIL8 vieww 2* viewh glRenderbufferStorage
	GL_FRAMEBUFFER GL_DEPTH_STENCIL_ATTACHMENT GL_RENDERBUFFER rbo glFramebufferRenderbuffer
	GL_FRAMEBUFFER 0 glBindFramebuffer
	;

:renderviews
	GL_FRAMEBUFFER framebuffer glBindFramebuffer
|<<<<<<<<<<<<<<<<<<<<
	SDLGLcls
	shaderProgram glUseProgram
	IDprojection 1 0 'fprojection glUniformMatrix4fv 
	IDview 1 0 'fview glUniformMatrix4fv 
	IDmodel 1 0 'fmodel glUniformMatrix4fv 
	VAO glBindVertexArray
	|..................
	0 0 vieww viewh glViewport
	GL_ARRAY_BUFFER typeVBO glBindBuffer		| typos
	GL_ARRAY_BUFFER 0 16 16 * 16 * 'voxels glBufferSubData
	GL_TRIANGLES 36 GL_UNSIGNED_INT 0 16 16 * 16 * glDrawElementsInstanced
	|..................
	vieww 0 vieww viewh glViewport
	GL_ARRAY_BUFFER typeVBO glBindBuffer		| typos
	GL_ARRAY_BUFFER 0 16 16 * 16 * 'voxels2 glBufferSubData
	GL_TRIANGLES 36 GL_UNSIGNED_INT 0 16 16 * 16 * glDrawElementsInstanced
	
	0 glBindVertexArray
|<<<<<<<<<<<<<<<<<<<<
	GL_FRAMEBUFFER 0 glBindFramebuffer
	;

:CreateSDLTextureFromOpenGL | -- texture
	GL_TEXTURE_2D textureColorbuffer glBindTexture
	GL_TEXTURE_2D 0 GL_RGBA GL_UNSIGNED_BYTE here glGetTexImage
	GL_TEXTURE_2D 0 glBindTexture
	here vieww 2* vieww 32 vieww 3 << $16362004 SDL_CreateRGBSurfaceWithFormatFrom |#SDL_PIXELFORMAT_ARGB32 $16362004
	SDLrenderer over SDL_CreateTextureFromSurface
	swap SDL_FreeSurface
	;

|--------------------------------------------
#timev

:ix 
	over $f and 32 << vmpush ;
:iy
	over 4 >> $f and 32 << vmpush ;
:iz 
	over 8 >> $f and $f and 32 << vmpush ;
:it
	timev 32 << vmpush ;
:irand
	vmpop 32 >> randmax 32 << vmpush ;
:imin
	vmpop 32 >> vmpop 32 >> min 32 << vmpush ;
:imax
	vmpop 32 >> vmpop 32 >> max 32 << vmpush ;

#wordt * 80
#words "rand" "x" "y" "z" "t" "min" "max" 0
#worde	irand ix iy iz it imin imax
#wordd ( $f1 $01 $01 $01 $01 $e1 $e1 0 )  

|--------------------------------------------
#serror
#code1
#cpu1
	
|-----------------------
:compilar
	msec 7 >> $f and 'timev ! |!!!!
	
	empty mark 
	fuente vmcompile | serror terror
|	vmdicc | ** DEBUG
|	cdcnt 'cdtok vmcheckjmp

	 1 >? ( 'terror !
		'fuente> ! | serror
		3 'state !
		clearmark
		fuente> $700ffff addsrcmark 
		0 'cpu1 !
		; ) 2drop

	2 'state ! 
	vmcpu 'cpu1 !
	0 'terror !
|	buildvars
	;
	
|----------------------------------------
:play
	state 2 =? ( drop vareset ; ) drop
	compilar
	state 2 <>? ( drop ; ) drop
	ip vm2src 'fuente> ! 
|	reset.map
	'stepvma 0.1 +vexe
	;	
	
	
:step
	state 2 =? ( drop stepvmas ; ) drop | stop?
	compilar	
	ip vm2src 'fuente> ! 
|	reset.map
	;
	
|----------------------------------------
:runvox
	vmreset
	dup $f and 32 << vmpush
	dup 4 >> $f and 32 << vmpush
	dup 8 >> $f and 32 << vmpush
	ip ( vmstepck 1? 	
		terror 1? ( 2drop ; ) drop
		) drop 
	vmpop 32 >>		
	;
	
:runplay
	state 2 =? ( drop vareset ; ) drop
	compilar
	state 2 <>? ( drop ; ) drop
	'voxels2
	0 ( $1000 <?
		runvox
		terror 1? ( 3drop			
			clearmark
			ip vm2src 'fuente> ! 
			fuente> $700ffff addsrcmark 
			3 'state !
			; ) drop
		rot c!+
		swap 1+ ) 2drop 
	1 'state ! 		
	;
	
|-------------------------------------------------

#rx #ry

:eyecam
	matini
	rx ry 0 mrot
	'fmodel mcpyf
	;

#glviewport

:redoingviewport
	eyecam
	glviewport SDl_DestroyTexture
    renderviews
	CreateSDLTextureFromOpenGL 'glviewport !	
	;
	
|------ vista
#xm #ym

:dnlook
	SDLx SDLy 'ym ! 'xm ! ;

:movelook
	SDLx SDLy
	ym over 'ym ! - 7 << neg 'rx +!
	xm over 'xm ! - 7 << 'ry +!  
	redoingviewport
	;
	
#vista1 [ 0 0 0 0 ]
#vista2 [ 0 0 0 0 ]
#screenv [ 0 0 0 0 ]	
	
:inivox
	viewh vieww 
	2dup 'vista1 8 + d!+ d!
	2dup dup 'vista2 d!
	'vista2 8 + d!+ d!
	'screenv 8 + d!+ d!
	;
	
:drawvox	
	0 620 'screenv d!+ d!
	$333333 sdlcolor
	SDLRenderer 'screenv SDL_RenderFillRect 
	SDLrenderer glviewport 'vista1 'screenv SDL_RenderCopy

	300 620 'screenv d!+ d!
	$000033 sdlcolor
	SDLRenderer 'screenv SDL_RenderFillRect 
	SDLrenderer glviewport 'vista2 'screenv SDL_RenderCopy
	;
	
:runscr
	vupdate gui	
	'dnlook 'movelook onDnMove
	0 sdlcls

	0 0 tat $5 tcol "Cube" temits $3 tcol " Code" temits 

	draw.code	
	drawvox
	
	|... paleta
	|0 ( 15 <? dup 2 << 'paleta + d@ sdlcolor dup 5 << 500 + 560 32 32 sdlfrect 1+ ) drop
		
	sdlkey
	>esc< =? ( exit )
	<f1> =? ( runplay redoingviewport )
	drop 
	SDLGLupdate
	SDLredraw
	;

|-----------------------
#startcode
": | x y z 

	; | color
"
	
:copycode | "" --
	fuente strcpy edset ;
	
:game
	mark
	160 32 440 540 edwin	
|	"r3/r3vm/levels/level0.txt" loadlevel	
|	0.4 %w 0.24 %h 0.58 %w 0.74 %h mapwin
		
|	reset.map
	1 'state ! 0 'code1 ! 0 'cpu1 !
	
|	genrandcolor
	'simple1 buildvox1
	'emptyvox buildvox2
	
	'startcode copycode
	fuente 11 + 'fuente> !
	
	redoingviewport
	
	|"-- go --" infoshow
	
	mark
	'runscr SDLshow
	empty
	
	vareset
	empty	
	;
	
|-----------------
:glinit
	"Arena Vox" 1024 600 SDLinitSGL
	SDLblend
	glInfo
	GL_DEPTH_TEST glEnable 
	GL_CULL_FACE glEnable	
	GL_LESS glDepthFunc 
	;	
	
:glend
	shaderProgram glDeleteProgram
    SDL_Quit ;
	
|----------- BOOT
:
	glinit
	progshader
	SetupFramebuffer
	redoingviewport
	inivox
	
	2.0 8 8 "media/img/atascii.png" tfnt 
	64 vaini
	edram	| editor
	
	'wordt 'words vmlistok 
	'wordt 'worde 'wordd vmcpuio
	
	game
	glend 
	;	