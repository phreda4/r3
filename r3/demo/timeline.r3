| About timeline
| framerate independient event animation system
| PHREDA 2020
|------------------
^r3/win/console.r3
^r3/win/sdl2.r3
^r3/win/sdl2ttf.r3
^r3/win/sdl2image.r3	
^r3/win/sdl2mixer.r3

^r3/lib/mem.r3
^r3/util/timeline.r3
^r3/util/fontutil.r3
^r3/util/bfont.r3

#imagen | an imge
#letras
#font
#snd_shoot

|-------------------- asorted animations
:example1 | --
	timeline.clear

	|........................
	0.1 0.1 0.8 0.8 xywh%64
	$ff00 +box
	
	0.5 +fx.on

	0.1 0.1 0.8 0.8 xywh%64
	0.4 0.2 0.2 0.6 xywh%64
	'Ela_InOut 3.0
	2.0 +fx.box

	0.4 0.2 0.2 0.6 xywh%64
	0.1 0.1 0.8 0.8 xywh%64
	'Ela_InOut 3.0
	6.0 +fx.box
	
	$ff00 $0000ff 'Ela_InOut 7.0 2.0 +fx.color
	
	9.5 +fx.off
	
	|........................
	0.2 0.2 0.3 0.4 xywh%64
	$ff +box
	
	0.0 +fx.on
	
	0.2 0.2 0.3 0.4 xywh%64
	1.2 0.4 0.3 0.4 xywh%64	
	'Quad_In 4.0
	1.0 +fx.box
	
	|........................
	imagen 0 +img
	
	0.0 +fx.on

	0.1 0.3 0.1 0.1 xywh%64
	1.1 0.8 0.3 0.3 xywh%64
	'Quad_In 1.0
	1.0 +fx.box

	1.1 0.8 0.3 0.3 xywh%64
	0.1 0.3 0.1 0.1 xywh%64	
	'Quad_In 2.0
	3.0 +fx.box
	
	10.0 +fx.off

|........................
	letras 
	0 0 0.2 0.2 xywh%64	
	0.1 0.8 0.2 0.2 xywh%64	
	+txt
	
	0 +fx.on 
	
	0.2 0.2 0.4 0.2 xywh%64
	0.8 0.2 0.1 0.1 xywh%64
	'Quad_In 1.0
	1.0 +fx.box
	
	|........................
	snd_shoot 4.0 +sound

	|........................
	10.0 +restart

	timeline.start
	;

|-----------------------------	

:sdlcolor | col --
	SDLrenderer swap
	dup 16 >> $ff and swap dup 8 >> $ff and swap $ff and 
	$ff SDL_SetRenderDrawColor ;

:demo
	0 SDLclear
	
	timeline.draw
	
	$ffffff bcolor 
	0 0 bmat "<f1> example 1" bmprint
	|0 16 bmat  "<f2> example 2" bmprint
	
	SDLRedraw
	SDLkey
	<f1> =? ( example1 )
	
	>esc< =? ( exit )
	drop
|	debugtimeline
	;
	
:loadres
	"media/snd/shoot.mp3" Mix_LoadWAV 'snd_shoot !	
	SDLrenderer "media/img/lolomario.png" loadimg 'imagen !
	"media/ttf/roboto-bold.ttf" 32 TTF_OpenFont 'font !	
	SDLrenderer font 
	"Hola a todos los que vinieron por los pochoclos que se regalan en la puerta"
	$ffffff0000ff00 RenderTexture 'letras !
	;
	
:main
	"r3sdl" 640 480 SDLinit
	44100 $08010 2 4096 Mix_OpenAudio 
	
	bfont2
	
	ttf_init
	
	loadres
	
	'demo SDLshow
	
	Mix_CloseAudio
	SDLquit
	;

:memory
	timeline.inimem
	;

: memory main  ;


