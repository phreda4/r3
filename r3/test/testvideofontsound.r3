| sdl2 test program
| PHREDA 2021
^r3/win/console.r3
^r3/win/sdl2.r3	
^r3/win/sdl2image.r3	
^r3/win/sdl2mixer.r3
^r3/win/sdl2ttf.r3
^r3/win/ffm.r3
^r3/lib/sys.r3
^r3/lib/gr.r3

#SDLrenderer
#texture
#snd_shoot	
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

:updatevideo
	textbit 'srct 'mpixel 'mpitch SDL_LockTexture
	mpixel FFM_redraw drop
	textbit SDL_UnlockTexture
	;

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
	updatevideo

	SDLrenderer 0 0 0 255 SDL_SetRenderDrawColor
	SDLrenderer SDL_RenderClear
	SDLrenderer textbit 0 'desrec3 SDL_RenderCopy		
	SDLrenderer texture 0 'desrec SDL_RenderCopy
	SDLrenderer texture 0 'desrec2 SDL_RenderCopy
	
font vs TTF_SetFontStyle
font vo TTF_SetFontOutline

	SDLrenderer $ffffff font "Hola a todos" 50 250 RenderText
	SDLrenderer $ff00 font 'desrec3 d@ "x:%d" sprint 50 350 RenderText
	
	SDLrenderer SDL_RenderPresent

	vx 'desrec3 d+!
	
	SDLkey
	>esc< =? ( exit )
	<le> =? ( 1 'vx ! )
	<ri> =? ( -1 'vx ! )	
	<f1> =? ( -1 snd_shoot 0 -1 Mix_PlayChannelTimed )	
	<f2> =? ( 1 'vs +! )
	<f3> =? ( 1 'vo +! )
	drop ;
		
:draw
	'drawl onshow ;

:inicio
	windows
	sdl2
	sdl2image
	sdl2mixer
	sdl2ttf
	ffm
	mark 
	;
	

:loadtexture | render "" -- text
	IMG_Load | ren surf
	swap over SDL_CreateTextureFromSurface
	swap SDL_FreeSurface ;

:main
	44100 $08010 2 4096 Mix_OpenAudio 
	
	 "media/snd/shoot.mp3" Mix_LoadWAV 'snd_shoot !
	 
	"r3sdl" 640 480 SDLinitgl
	SDL_windows -1 0 SDL_CreateRenderer 'SDLrenderer !
|SDLrenderer 640 480 SDL_RenderSetLogicalSize
|SDLrenderer 1 SDL_SetRenderDrawBlendMode 

	$3 IMG_Init
	
	SDLrenderer "media/img/lolomario.png" loadtexture 'texture !
	
	ttf_init
	
	"media/ttf/roboto-bold.ttf" 32 TTF_OpenFont 'font !

	SDLrenderer $16362004 1 427 240 SDL_CreateTexture 'textbit !
	FFM_init "media/test.mp4" 427 240 FFM_open
	
	draw
	
	SDLquit
	Mix_CloseAudio
	;

: inicio main ;
