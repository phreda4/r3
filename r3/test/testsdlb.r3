| sdl2 test program
| PHREDA 2021

^r3/win/sdl2.r3	
^r3/win/sdl2image.r3	
^r3/win/sdl2mixer.r3
^r3/lib/sys.r3
^r3/lib/gr.r3

#SDLrenderer
#texture
#snd_shoot	
#textbit

:xypen SDLx SDLy ;

#desrec [ 0 100 200 200 ]
#desrec2 [ 10 100 100 100 ]
#desrec3 [ 200 150 427 240 ]

#srct [ 0 0 427 240 ]
#mpixel 
#mpitch

#vx 0

##seed 495090497

::rand | -- r32
  seed 3141592621 * 1 + dup 'seed ! ;

:updatetexbit
	textbit 'srct 'mpixel 'mpitch SDL_LockTexture
	mpixel >a 427 240 * ( 1? 1 - rand da!+ ) drop
	textbit SDL_UnlockTexture
	;
	
:drawl

	updatetexbit
	
	SDLrenderer SDL_RenderClear
	SDLrenderer textbit 0 'desrec3 SDL_RenderCopy		
	SDLrenderer texture 0 'desrec SDL_RenderCopy
	SDLrenderer texture 0 'desrec2 SDL_RenderCopy
	SDLrenderer SDL_RenderPresent

	vx 'desrec3 d+!
	
	SDLkey
	>esc< =? ( exit )
	<le> =? ( 1 'vx ! )
	<ri> =? ( -1 'vx ! )	
	<f1> =? ( -1 snd_shoot 0 -1 Mix_PlayChannelTimed )	
	drop ;
		
:draw
	'drawl onshow ;

#surface

:inicio
	windows
	sdl2
	sdl2image
	sdl2mixer
	mark ;
	
:main
	44100 $08010 2 4096 Mix_OpenAudio 
	
	 "media/snd/shoot.mp3" Mix_LoadWAV 'snd_shoot !
	 
	"r3sdl" 640 480 SDLinit
	SDL_windows -1 0 SDL_CreateRenderer 'SDLrenderer !
	SDLrenderer $ff $ff $ff $ff SDL_SetRenderDrawColor
	$3 IMG_Init

	"media/img/lolomario.png" IMG_Load 'surface !
	SDLrenderer surface SDL_CreateTextureFromSurface 'texture !
	surface SDL_FreeSurface

	SDLrenderer $16362004 1 427 240 SDL_CreateTexture 'textbit !
	
	draw
	
	SDLquit
	Mix_CloseAudio
	;

: inicio main ;
