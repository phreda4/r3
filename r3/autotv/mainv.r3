| sdl2 test program
| PHREDA 2021

^r3/win/console.r3
^r3/win/sdl2.r3	
^r3/win/sdl2image.r3	
^r3/win/sdl2mixer.r3
^r3/win/sdl2ttf.r3
^r3/win/ffm.r3

^r3/util/timeline.r3
^r3/util/fontutil.r3
^r3/util/boxtext.r3
^r3/util/dbtxt.r3

^r3/lib/parse.r3
^r3/lib/mem.r3
^r3/lib/key.r3
^r3/lib/sys.r3
^r3/lib/gr.r3

	
|--------------------------------	
#font
#font1
#font2

|--------------------------------
#programa 0
#prgnow 0
#prgexit 

:pexit 1 'prgexit ! ;
	

:endlast
	prgnow 0? ( drop ; ) 
	16 + @ 0? ( drop ; )
	ex ;
	
:changeprg | adr --
	endlast
	0 'prgexit !
	dup 'prgnow !
	dup 8 + @ 'programa ! 
	@ 0? ( drop ; )
	ex ;


|--------------------------------

|---- colorbars
:,2d
	10 <? ( "0" ,s ) ,d ;

:,time
	time
	dup 16 >> $ff and ,d ":" ,s
	dup 8 >> $ff and ,2d ":" ,s
	$ff and ,2d ;

:,date
	date
	dup $ff and ,d "/" ,s
	dup 8 >> $ff and ,d "/" ,s
	16 >> $ffff and ,d ;


#col $fdfdfd $fdfc01 $fcfd $fe00 $fd00fb $fc0001 $0100fc

#rf [ 0 0 0 0 ]

:rgbcolor | rrggbb --
	SDLrenderer swap dup 16 >> $ff and swap dup 8 >> $ff and swap $ff and $ff
	SDL_SetRenderDrawColor	
	;
	
:sajuste
	'col sw 7 /mod 1 >> | 'col w x
	( sw 8 - <?
		rot @+ rgbcolor
		rot rot sh pick2 0 pick3 
		'rf d!+ d!+ d!+ d!
		SDLrenderer 'rf SDL_RenderFillRect
		over + ) 3drop
	SDLrenderer $ffffff font
	mark ,sp ,date ,sp ,eol empty here 
	40 40 RenderTextB
	SDLrenderer $ffffff font
	mark ,sp ,time ,sp ,eol empty here 
	40 sh 80 - RenderTextB	
	;

#prgajuste 0 'sajuste 0


|---- Hora y temperatura
#buffhora * 128
#bufftemp * 128

:updatehora
	mark ,sp ,date ,sp ,eol empty here 'buffhora strcpy
	;
	
:inihora	
	timeline.clear
	$0 font2 'buffhora 0.05 0.78 0.9 0.2 xywh%64 $22ffff00 +tboxb 
	0.0 +fx.on	
	
	'pexit 20.0 +event
	timeline.start
	;
	
:shora
	$0 rgbcolor
	SDLrenderer SDL_RenderClear
	timeline.draw
	;
	
:finhora	

	;
	
#prghora 'inihora 'shora 'finhora

|---- cartel simple
#id
#fotos
#titulo
#descripcion
#direccion
#telefono
#tfoto

:,h2
	$ff and 16 <? ( "0" ,s ) ,h ;
	
:photoname | id --
	mark
	"autotv/file-com/" ,s 
	dup 24 >> ,h2 "/" ,s dup 16 >> ,h2 "/" ,s
	"fotos%d.png" ,print 0 ,c
	empty 
	here ;
	
:easeline ;

:cartelini
	"autotv/cliente.db" loaddb-i
	
	1 dbfld 'titulo !
	2 dbfld 'direccion !
	3 dbfld 'telefono !
	4 dbfld 'descripcion !	

	SDLrenderer 0 dbfld str>nro nip photoname loadtexture 'tfoto !		
	
	timeline.clear

|	0.1 0.1 0.8 0.8 xywh%64 $ff +box
|	0.0 +fx.on
	
	tfoto 0.02 0.02 0.96 0.9 xywh%64 +img
	0.0 +fx.on

|	-0.1 0.0 1.1 0.9 xywh%64 0.1 0.0 1.1 0.9 xywh%64 'easeline 5.0 
|	0.0 +fx.box	
	
	$0 font titulo " %s " sprint 0.05 0.74 0.9 0.2 xywh%64 $02ffffff +tboxb |  HVRRGGBB00
	0.0 +fx.on

	$0 font1 telefono 0.05 0.78 0.9 0.2 xywh%64 $22ffff00 +tboxb 
	0.0 +fx.on

	font1 descripcion 0.05 0.05 0.9 0.8 xywh%64 $00ff0000 +tbox
	0.0 +fx.on
	
	0.05 0.05 0.9 0.8 xywh%64
	0.05 0.05 0.9 0.8 xywh%64
	'Ela_InOut 5.0
	0.0 +fx.box
	
	
	'pexit 5.0 +event
	timeline.start
	;
	

:cartel
	$0 rgbcolor
	SDLrenderer SDL_RenderClear
	timeline.draw
	;
	
:cartelfin
	tfoto SDL_DestroyTexture
	;

##prgcartel 'cartelini 'cartel 'cartelfin

|---- cartel simple
#n1 * 256
#d1 * 256
#t1 * 256

#n2 * 256
#d2 * 256
#t2 * 256

#n3 * 256
#d3 * 256
#t3 * 256

#tfoto2 #tfoto3

:cartelini2
	"autotv/cliente.db" loaddb-i
	1 dbfld 'n1 strcpy
	2 dbfld 'd1 strcpy
	3 dbfld 't1 strcpy
	SDLrenderer 0 dbfld str>nro nip photoname loadtexture 'tfoto !		

	"autotv/cliente.db" loaddb-i
	1 dbfld 'n2 strcpy
	2 dbfld 'd2 strcpy
	3 dbfld 't2 strcpy
	SDLrenderer 0 dbfld str>nro nip photoname loadtexture 'tfoto2 !		

	"autotv/cliente.db" loaddb-i
	1 dbfld 'n3 strcpy
	2 dbfld 'd3 strcpy
	3 dbfld 't3 strcpy
	SDLrenderer 0 dbfld str>nro nip photoname loadtexture 'tfoto3 !		
	

	timeline.clear

	tfoto 0.1 0.1 0.2 0.2 xywh%64 +img
	0.0 +fx.on

	$0 font1 'n1 sprint 0.3 0.1 0.6 0.2 xywh%64 $00ffffff +tboxb |  HVRRGGBB00
	0.0 +fx.on

	$0 font1 't1 0.3 0.1 0.6 0.2 xywh%64 $22ffff00 +tboxb
	0.0 +fx.on

	tfoto2 0.1 0.4 0.2 0.2 xywh%64 +img
	0.0 +fx.on

	$0 font1 'n2 0.3 0.4 0.6 0.2 xywh%64 $00ffffff +tboxb |  HVRRGGBB00
	0.0 +fx.on

	$0 font1 't2 0.3 0.4 0.6 0.2 xywh%64 $22ffff00 +tboxb
	0.0 +fx.on

	tfoto3 0.1 0.7 0.2 0.2 xywh%64 +img
	0.0 +fx.on

	$0 font1 'n3 0.3 0.7 0.6 0.2 xywh%64 $00ffffff +tboxb |  HVRRGGBB00
	0.0 +fx.on

	$0 font1 't3 0.3 0.7 0.6 0.2 xywh%64 $22ffff00 +tboxb
	0.0 +fx.on


	'pexit 5.0 +event
	timeline.start
	;
	

:cartel2
	$0 rgbcolor
	SDLrenderer SDL_RenderClear
	timeline.draw
	;
	
:cartelfin2
	tfoto SDL_DestroyTexture
	tfoto2 SDL_DestroyTexture
	tfoto3 SDL_DestroyTexture
	;

##prgcartel2 'cartelini2 'cartel2 'cartelfin2
		
|---------------------------------
#vfilenow * 1024
#videoframe
#srct [ 0 0 800 600 ]
#mpixel 
#mpitch

#sonido
#musica

:cvideoini 
	"autotv/videos" loadnfile 'vfilenow strcpy
	SDLrenderer $16362004 1 800 600 SDL_CreateTexture 'videoframe !
	
	 "media/snd/shoot.mp3" Mix_LoadWAV 'sonido !
	 "autotv/musica/cronica-tv-musica.mp3" Mix_LoadMUS 'musica !
	 
	timeline.clear
	
	videoframe 0.0 0.0 1.0 1.0 xywh%64 +img
	0.0 +fx.on	
	
	musica 1.0 +music
	
	0.0 0.9 1.0 0.1 xywh%64 $ff0000 +box 	
	0.0 +fx.on
	1.0 0.9 1.0 0.1 xywh%64
	0.0 0.9 1.0 0.1 xywh%64
	'Cub_In 1.0
	0.1 +fx.box	


	$ff0000
	font 'vfilenow 0.05 0.9 0.9 0.1 xywh%64 $0000ff +tboxb
	1.1 +fx.on
	1.0 0.9 1.0 0.1 xywh%64
	0.05 0.9 0.9 0.1 xywh%64
	'Cub_In 1.0
	1.1 +fx.box	
	
	|sonido 2.1 +sound
	
	|'pexit 8.0 +event
	timeline.start

	'vfilenow "autotv/videos/%s" sprint 800 600 FFM_open	
	;
	
:cvideo 
|	$0 rgbcolor SDLrenderer SDL_RenderClear

	videoframe 'srct 'mpixel 'mpitch SDL_LockTexture
	
	mpixel FFM_redraw 1? ( pexit ) drop 
	
	videoframe SDL_UnlockTexture

	timeline.draw
	
	;
	
:cvideofin
	FFM_close
	videoframe SDL_DestroyTexture
	sonido Mix_FreeChunk	
	musica Mix_FreeMusic
	;
	
#prgcvideo 'cvideoini 'cvideo 'cvideofin

|---------------------------------
#mus_fondo

:mfinicio
	"autotv/musica/cronica-tv-musica.mp3" Mix_LoadMUS 'mus_fondo !
	mus_fondo 1 Mix_PlayMusic
	;
	
:mffin
	mus_fondo Mix_FreeMusic ;
	
|---------------------------------

:mainloop
	programa ex
	SDLrenderer SDL_RenderPresent
	
	prgexit 1? ( 'prgcartel2 changeprg ) drop


	SDLkey
	>esc< =? ( exit )
	<f1> =? ( 'prgcartel changeprg ) 	
	<f2> =? ( 'prgajuste changeprg )
	<f3> =? ( 'prgcvideo changeprg )
	<f4> =? ( 'prgcartel2 changeprg )
	
	|<f4> =? ( mus_fondo 0 Mix_PlayMusic )
	drop ;		


:main
	"r3sdl" 800 600 SDLinit
	48000 $08010 2 4096 Mix_OpenAudio 
	$3 IMG_Init
	
	8 16 "media/img/VGA8x16.png" bmfont

	FFM_init
	
	ttf_init
	"media/ttf/roboto-bold.ttf" 48 TTF_OpenFont 'font !
	"media/ttf/roboto-bold.ttf" 32 TTF_OpenFont 'font1 !
	"media/ttf/roboto-bold.ttf" 80 TTF_OpenFont 'font2 !
	
	"autotv/musica/musica-fondo.mp3" Mix_LoadMUS 'mus_fondo !
	
	
	'prgajuste changeprg
	
|mfinicio

	'mainloop SDLshow
	
	Mix_CloseAudio
	SDLquit
	;


:ini
	windows
	sdl2 sdl2image sdl2mixer sdl2ttf
	ffm
	mark
	timeline.inimem
	;

: ini main ;