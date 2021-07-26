| sdl2opengl test program
| PHREDA 2021

^r3/win/console.r3
^r3/win/sdl2.r3	
^r3/win/sdl2image.r3
^r3/win/sdl2ttf.r3
^r3/win/glew.r3

^r3/lib/sys.r3
^r3/lib/gr.r3

#SDLrenderer
#texture
#textbit

:xypen SDLx SDLy ;

#font

#desrec [ 0 100 200 200 ]
#desrec2 [ 10 100 100 100 ]
#desrec3 [ 200 150 427 240 ]

#vx 0
#vs 0
#vo 0

#srct [ 0 0 427 240 ]
#mpixel 
#mpitch


#textbox [ 0 0 200 100 ]
:RenderText | SDLrender color font "texto" x y --
	swap 'textbox d!+ d!
	2dup 'textbox dup 8 + swap 12 + TTF_SizeText drop
	rot 
	|TTF_RenderText_Solid
	TTF_RenderText_Blended | sdlr surface	
	2dup SDL_CreateTextureFromSurface | sd surface texture
	rot over 0 'textbox SDL_RenderCopy	
	SDL_DestroyTexture
	SDL_FreeSurface ;

	
:drawl

	SDLrenderer 0 0 0 255 SDL_SetRenderDrawColor
	SDLrenderer SDL_RenderClear
	SDLrenderer texture 0 'desrec SDL_RenderCopy
	SDLrenderer texture 0 'desrec2 SDL_RenderCopy
	
	SDLrenderer $ffffff font "Hola a todos" 50 250 RenderText
	SDLrenderer $ff00 font 'desrec3 d@ "x:%d" sprint 50 350 RenderText
	
	SDLrenderer SDL_RenderPresent

	vx 'desrec d+!
	
	SDLkey
	>esc< =? ( exit )
	<le> =? ( 1 'vx ! )
	<ri> =? ( -1 'vx ! )	
	drop ;
		
:draw
	'drawl onshow ;

:ini
	windows
	sdl2
	sdl2image
	sdl2ttf
	glew
	mark 
	;
	

:loadtexture | render "" -- text
	IMG_Load | ren surf
	swap over SDL_CreateTextureFromSurface
	swap SDL_FreeSurface ;


#vert_shader_src 
"#version 150 core                                                            
in vec2 in_Position;                                                         
in vec2 in_Texcoord;                                                         
out vec2 Texcoord;                                                           
void main()                                                                  
{                                                                            
    Texcoord = in_Texcoord;                                                  
    gl_Position = vec4(in_Position, 0.0, 1.0);                               
}"

#frag_shader_src 
"#version 150 core                                                            
in vec2 Texcoord;                                                            
out vec4 out_Color;                                                          
uniform sampler2D tex;                                                       
void main()                                                                  
{                                                                            
    out_Color = texture(tex, Texcoord);                                      
}"

#m_context
#m_vao #m_vbo #m_ebo #m_tex
#m_vert_shader
#m_frag_shader
#m_shader_prog

#status

|#define GL_FRAGMENT_SHADER                0x8B30
|#define GL_VERTEX_SHADER                  0x8B31
|#define GL_COMPILE_STATUS                 0x8B81

:InitShaders
"a" .
    1 'm_vao glGenVertexArrays
"a" .	
    m_vao glBindVertexArray
"a" .
    $8B31 glCreateShader 'm_vert_shader !
"a" .
	m_vert_shader 1 'vert_shader_src 0 glShaderSource
"a" .
    m_vert_shader glCompileShader
"a" .
	m_vert_shader $8B81 'status glGetShaderiv	
"a" .	
	;
	
:InitGeometry
	;
:InitTextures
	;

:GL_init | "" sw sh --
	'sh ! 'sw !
	$3231 SDL_init 
	$1FFF0000 $1FFF0000 sw sh 2 SDL_CreateWindow 'SDL_windows ! 

    17 3 SDL_GL_SetAttribute | SDL_GL_CONTEXT_MAJOR_VERSION
    18 1 SDL_GL_SetAttribute | (SDL_GL_CONTEXT_MINOR_VERSION, 1);
    21 1 SDL_GL_SetAttribute |(SDL_GL_CONTEXT_PROFILE_MASK,  SDL_GL_CONTEXT_PROFILE_CORE);
    5 1 SDL_GL_SetAttribute |(SDL_GL_DOUBLEBUFFER, 1);	
	Sdl_windows SDL_GL_CreateContext 'm_context !
	1 SDL_GL_SetSwapInterval
	glewInit
	InitShaders
    InitGeometry
    InitTextures
	;
	
:GL_close 
	SDL_windows SDL_DestroyWindow
	SDL_quit
	;

#.exit

:loop	
	sdlkey
	>esc< =? ( 1 '.exit ! )
	drop ;
	
:main	
	0 '.exit ! 
	( .exit 0? drop
		loop
		SDLupdate ) drop ;
	
: ini 
"r3gl" 640 480 GL_init 
main 
GL_close ;
