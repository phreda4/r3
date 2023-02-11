^r3/win/sdl2.r3
^r3/win/sdl2gl.r3
^r3/win/sdl2gfx.r3
^r3/win/sdl2ttf.r3

| opengl Constant
#GL_DEPTH_TEST $0B71
#GL_LESS $0201
#GL_CULL_FACE $0B44

#GL_TEXTURE_2D $0DE1
#GL_RED $1903
#GL_RGB $1907
#GL_RGBA $1908

#GL_UNSIGNED_BYTE $1401
#GL_TEXTURE_MAG_FILTER $2800
#GL_TEXTURE_MIN_FILTER $2801
#GL_LINEAR $2601
#GL_QUADS 7

|-------------------------------------
:glinit
	5 1 SDL_GL_SetAttribute		|SDL_GL_DOUBLEBUFFER, 1);
	13 1 SDL_GL_SetAttribute	|SDL_GL_MULTISAMPLEBUFFERS, 1);
	14 8 SDL_GL_SetAttribute	|SDL_GL_MULTISAMPLESAMPLES, 8);
    17 4 SDL_GL_SetAttribute |SDL_GL_CONTEXT_MAJOR_VERSION
    18 6 SDL_GL_SetAttribute |SDL_GL_CONTEXT_MINOR_VERSION
	20 2 SDL_GL_SetAttribute |SDL_GL_CONTEXT_FLAGS, SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG);	
	21 2 SDL_GL_SetAttribute |SDL_GL_CONTEXT_PROFILE_MASK,  SDL_GL_CONTEXT_PROFILE_COMPATIBILITY
|	SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);
|	"SDL_RENDER_SCALE_QUALITY" "1" SDL_SetHint	
	
	"test opengl" 800 600 SDLinitGL
	
|	GL_DEPTH_TEST glEnable 
|	GL_CULL_FACE glEnable	
|	GL_LESS glDepthFunc 
	
	0 0 800 600 glViewport
	;	



:mem2float | cnt to from --
	>a >b ( 1? 1 - da@+ f2fp db!+ ) drop ;
	
#font
#ink
#x #y
#t

#surface
:Surface->w surface 16 + d@ ;
:Surface->h surface 20 + d@ ;
:Surface->pixels surface 32 + @ ;
:Surface->format->bpp surface 8 + @ 16 + c@ ;
:GLBPP 
	Surface->format->bpp 
	32 =? ( drop GL_RGBA ; ) 
	24 =? ( drop GL_RGB ; )
	drop GL_RED ;

#t0 [ 0.0 1.0 ]
#t1 [ 1.0 1.0 ]
#t2 [ 1.0 0.0 ]
#t3 [ 0.0 0.0 ]
#v0 0 #v1 0 #v2 0 #v3 0

:glrendertext
	'y ! 'x ! 
	
|  glDisable(GL_DEPTH_TEST);
GL_TEXTURE_2D glEnable
|  glEnable(GL_BLEND);
|  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  
	1 't glGenTextures
    GL_TEXTURE_2D t glBindTexture
	font swap ink TTF_RenderUTF8_Blended 'Surface !
	GL_TEXTURE_2D 0 GLBPP Surface->w Surface->h 0 pick3 GL_UNSIGNED_BYTE Surface->pixels glTexImage2D
	GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_LINEAR glTexParameteri
	GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_LINEAR glTexParameteri
	
	y i2fp x i2fp 'v0 d!+ d!
	y i2fp x Surface->w + i2fp 'v1 d!+ d!
	y Surface->h + i2fp x Surface->w + i2fp 'v2 d!+ d!
	y Surface->h + i2fp x i2fp 'v3 d!+ d!
	
	4 glBegin
    't0 glTexCoord2fv 'v0 glVertex2fv
    't1 glTexCoord2fv 'v1 glVertex2fv
	't2 glTexCoord2fv 'v2 glVertex2fv
	't3 glTexCoord2fv 'v3 glVertex2fv
	glEnd

|  glDisable(GL_BLEND);
GL_TEXTURE_2D glDisable
|  glEnable(GL_DEPTH_TEST);


	1 't glDeleteTextures
	surface SDL_FreeSurface ;	
	
:main
	|gui
	|'dnlook 'movelook onDnMove

	$4100 glClear | color+depth

	"render test" 10 10 glrendertext
	
	SDL_windows SDL_GL_SwapWindow
	SDLkey
	>esc< =? ( exit ) 	
	
	drop ;		
|----------- BOOT
:
	glinit
	ttf_init
	8 't0 't0 mem2float
	"media/ttf/roboto-bold.ttf" 24 TTF_OpenFont 'font !
	$ffff00ff 'ink !
	
	'main SDLshow
	SDL_Quit
	;	