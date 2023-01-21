| OpenGL example - first example without shaders
| PHREDA 2023
^r3/win/sdl2.r3
^r3/win/sdl2gl.r3

#window
#context

#v0 [ -0.8 -0.8 0.8 ]
#v1 [ 0.8 -0.8 0.8 ]
#v2 [ 0.0 0.8 0.8 ]

#c0 ( 255 0 0 255 )
#c1 ( 0 255 0 255 )
#c2 ( 0 0 255 255 )

:mem2float | cnt to from --
	>a >b ( 1? 1 - da@+ f2fp db!+ ) drop ;

:fillv
	9 'v0 'v0 mem2float ;
	
:drawtri
	4 glBegin
	'c0 glColor4ubv 'v0 glVertex3fv
	'c1 glColor4ubv	'v1 glVertex3fv
	'c2 glColor4ubv	'v2 glVertex3fv
	glEnd
	;
	
:glInfo
	$1f00 glGetString .println | vendor
	$1f01 glGetString .println | render
	$1f02 glGetString .println | version
	$8B8C glGetString .println | shader
	;
	
:initgl
    | select opengl version
	5 1 SDL_GL_SetAttribute |  SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
    17 4 SDL_GL_SetAttribute |(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    18 0 SDL_GL_SetAttribute |(SDL_GL_CONTEXT_MINOR_VERSION, 3);
	20 2 SDL_GL_SetAttribute |(SDL_GL_CONTEXT_FLAGS, SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG);	
	21 2 SDL_GL_SetAttribute |(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);	
|	SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);
|	13 1 SDL_GL_SetAttribute |  SDL_GL_SetAttribute(SDL_GL_MULTISAMPLEBUFFERS, 1);
|	14 4 SDL_GL_SetAttribute   |SDL_GL_SetAttribute(SDL_GL_MULTISAMPLESAMPLES, 8);
	
	$3231 SDL_init 	
	$1FFF0000 dup 800 600 $2 SDL_CreateWindow 'window !
	window SDL_GL_CreateContext 'context !
|	window context SDL_GL_MakeCurrent
	1 SDL_GL_SetSwapInterval

	InitGLAPI	
	glInfo	
	
	0 0 800 600 glViewport
|	0 233 0 0 glClearColor
	;
		
:glend
	context SDL_Gl_DeleteContext
    SDL_Quit
	;

:main
	$4100 glClear
	drawtri
	
	window SDL_GL_SwapWindow
	
	SDLkey
	>esc< =? ( exit ) 
	drop ;	
	
|----------- BOOT
:
	fillv	
	initgl 
	'main SDLshow
	glend 
	;