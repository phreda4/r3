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

:xypen SDLx SDLy ;

#desrec [ 0 100 200 200 ]
#desrec2 [ 10 100 100 100 ]

#vx 0

:drawl
	SDLrenderer SDL_RenderClear
	SDLrenderer texture 0 'desrec SDL_RenderCopy
	SDLrenderer texture 0 'desrec2 SDL_RenderCopy
	SDLrenderer SDL_RenderPresent

	vx 'desrec d+!
	
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
	
	draw
	SDLquit
	Mix_CloseAudio
	;

: inicio main ;
