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
	
:photoname	
	mark
	"autotv/file-com/" ,s 
	id 
	dup 24 >> ,h2 "/" ,s dup 16 >> ,h2 "/" ,s
	"fotos%d.png" ,print 0 ,c
	empty 
	here ;
	
:easeline ;

:cartelini
	"autotv/cliente.db" loaddb-i
	
	0 dbfld str>nro 'id ! drop
	1 dbfld 'titulo !
	2 dbfld 'direccion !
	3 dbfld 'telefono !
	4 dbfld 'descripcion !	
	6 dbfld 'fotos !

	SDLrenderer photoname loadtexture 'tfoto !		
	
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
	
	|musica 0.0 +music
	
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
	
	sonido 2.1 +sound
	
	'pexit 5.0 +event
	timeline.start

	'vfilenow "autotv/videos/%s" sprint 800 600 FFM_open	
	;
	
:cvideo 
	videoframe 'srct 'mpixel 'mpitch SDL_LockTexture
	mpixel FFM_redraw drop
	videoframe SDL_UnlockTexture

	$0 rgbcolor
	SDLrenderer SDL_RenderClear

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
:mainloop
	programa ex
	SDLrenderer SDL_RenderPresent
	
	prgexit 1? ( 'prgcartel changeprg ) drop


	SDLkey
	>esc< =? ( exit )
	<f1> =? ( 'prgcartel changeprg ) 	
	<f2> =? ( 'prgajuste changeprg )
	<f3> =? ( 'prgcvideo changeprg )
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
	
	'prgajuste changeprg
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