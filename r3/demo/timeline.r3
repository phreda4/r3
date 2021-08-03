| About timeline
| framerate independient event animation system
| PHREDA 2020
|------------------
|MEM $fff
^r3/win/console.r3
^r3/win/sdl2.r3
^r3/win/sdl2ttf.r3
^r3/win/sdl2image.r3	
^r3/win/sdl2mixer.r3

^r3/lib/mem.r3
^r3/lib/key.r3
^r3/util/timeline.r3

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
:loadtexture | render "" -- text
	IMG_Load | ren surf
	swap over SDL_CreateTextureFromSurface
	swap SDL_FreeSurface ;
	
|-----------------------------
#pfont 
#wp #hp
#op 0 0
#dp 0 0

:bmfont | w h "" --
	SDLrenderer swap loadtexture 'pfont !
	2dup 32 << or dup
	'dp 8 + ! 'op 8 + !
	'hp ! 'wp ! 
	;
	
:bcolor	| rrggbb --
	pfont swap
	dup 16 >> $ff and over 8 >> $ff and rot $ff and
	SDL_SetTextureColorMod
	;
	
:bemit | ascii --
	dup $f and wp * swap 4 >> $f and hp * 32 << or 'op !
	SDLrenderer pfont 'op 'dp SDL_RenderCopy
	wp 'dp d+!
	;
	
:bmprint | "" --
	( c@+ 1? bemit ) 2drop ;
	
:bmat | x y --
	32 << or 'dp ! ;
	
|-----------------------------
#textbox [ 0 0 0 0 ]

:RenderText | SDLrender color font "texto" x y --
	swap 'textbox d!+ d!
	2dup 'textbox dup 8 + swap 12 + TTF_SizeText drop
	rot 
	|TTF_RenderText_Solid ***
	|TTF_RenderText_Blended ***
	dup $ffffff and swap 32 >> TTF_RenderUTF8_Shaded
	2dup SDL_CreateTextureFromSurface | sd surface texture
	rot over 0 'textbox SDL_RenderCopy	
	SDL_DestroyTexture
	SDL_FreeSurface ;

:RenderTexture | SDLrender font "text" color -- texture
	|TTF_RenderText_Solid ***
	|TTF_RenderText_Blended ***
	dup $ffffff and swap 32 >> TTF_RenderUTF8_Shaded
	dup rot swap SDL_CreateTextureFromSurface | sd surface texture
	swap SDL_FreeSurface ;

|-----------------------------	
	
:sdlcolor | col --
	SDLrenderer swap
	dup 16 >> $ff and swap dup 8 >> $ff and swap $ff and 
	$ff SDL_SetRenderDrawColor ;

:demo
	0 sdlcolor
	SDLrenderer SDL_RenderClear
	
	timeline.draw
	
	$ffffff bcolor 
	0 0 bmat "<f1> example 1" bmprint
	|0 16 bmat  "<f2> example 2" bmprint
	
	SDLrenderer SDL_RenderPresent
	SDLkey
	<f1> =? ( example1 )
	
	>esc< =? ( exit )
	drop
|	debugtimeline
	;
	
:loadres

	"media/snd/shoot.mp3" Mix_LoadWAV 'snd_shoot !	

	SDLrenderer "media/img/lolomario.png" loadtexture 'imagen !

	"media/ttf/roboto-bold.ttf" 32 TTF_OpenFont 'font !	

	SDLrenderer font 
	"Hola a todos los que vinieron por los pochoclos que se regalan en la puerta"
	$ffffff0000ff00 RenderTexture 'letras !

	;
	
:main
	"r3sdl" 640 480 SDLinit
	44100 $08010 2 4096 Mix_OpenAudio 
	$3 IMG_Init
	|16 24 "media/img/font16x24.png" bmfont
	8 16 "media/img/VGA8x16.png" bmfont
	ttf_init
	
	loadres
	
	'demo SDLshow
	
	Mix_CloseAudio
	SDLquit
	;

:memory
	windows
	sdl2
	sdl2image
	sdl2mixer
	sdl2ttf
	mark
	timeline.inimem
	;

: memory main  ;


