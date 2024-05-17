| About timeline
| framerate independient event animation system
| PHREDA 2020
|------------------
^r3/win/console.r3
^r3/win/sdl2gfx.r3
^r3/win/sdl2ttf.r3
^r3/win/sdl2image.r3	
^r3/win/sdl2mixer.r3

^r3/lib/mem.r3
^r3/util/timeline.r3
^r3/util/bfont.r3

#imagen | an imge
#letras
#font
#font1
#snd_shoot

#texto "El veloz murciélago hindú comía feliz cardillo y kiwi. 
La cigüeña tocaba el saxofón detrás del palenque de paja"

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

|	$08ff0000 font1 'texto 0.07 0.35 0.54 0.1 xywh%64 $ffffff +tboxb 
	font1 'texto 0.07 0.1 0.54 0.1 xywh%64 $ffffff +tbox
	0.0 +fx.on	

	$7fff0000 font1 'texto 0.47 0.3 0.54 0.1 xywh%64 $11ffffff +tboxb 
	0.0 +fx.on	

	$02ffffff font 'texto 0.1 0.5 0.54 0.1 xywh%64 $110000ff +tboxo
	0.0 +fx.on	
	
	|........................
|	snd_shoot 4.0 +sound

	|........................
	10.0 +restart

	timeline.start
	;

|-----------------------------	

:demo
	0 SDLcls
	
	timeline.draw
	
	$ffffff bcolor 
	0 0 bat "<f1> example 1" bprint
	|0 16 bat  "<f2> example 2" bprint
	
	SDLredraw
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
	"media/ttf/roboto-bold.ttf" 16 TTF_OpenFont 'font1 !	
	SDLrenderer font 
	"Hola a todos los que vinieron por los pochoclos que se regalan en la puerta"
	$ffffff0000ff00 RenderTexture 'letras !
	;
	
:main
	"r3sdl" 640 480 SDLinit
	44100 $08010 2 4096 Mix_OpenAudio 
	bfont2
	loadres
	'demo SDLshow
	
	Mix_CloseAudio
	SDLquit
	;

:memory
	timeline.inimem
	;

: memory main  ;
