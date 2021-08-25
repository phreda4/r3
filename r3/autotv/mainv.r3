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

^r3/lib/mem.r3
^r3/lib/key.r3
^r3/lib/sys.r3
^r3/lib/gr.r3


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
#imgglass
#imgball

#id
#fotos
#titulo
#descripcion
#direccion
#telefono
#tfoto
	
|function photoname(path,nom,id){
|let pp=parseInt(id).toString(16);
|while (pp.length<6){pp="0"+pp;}
|return path+"/"+pp.substring(0,2)+"/"+pp.substring(2,4)+"/"+nom+id+".png";

#bpath * 64

:,h2
	$ff and 16 <? ( "0" ,s ) ,h ;
	
:photoname	
	mark
	"autotv/" ,s
	id 
	dup 24 >> ,h2 "/" ,s
	dup 16 >> ,h2 "/" ,s
	dup 8 >> ,h2 "/" ,s
	"fotos%d.png" ,print 
	empty 
	here ;
	
:cartelini
	"autotv/cliente.db" loaddb-i
	
	0 dbfld 'id !
	1 dbfld 'titulo !
	2 dbfld 'direccion !
	3 dbfld 'telefono !
	4 dbfld 'descripcion !	
	6 dbfld 'fotos !

	SDLrenderer "media/img/ball.png" loadtexture 'imgball !
	SDLrenderer "media/img/glass.png" loadtexture 'imgglass !	

	SDLrenderer photoname  loadtexture 'tfoto !		
	
	timeline.clear

|	0.5 0.3 0.4 0.4 xywh%64 $ff00ff +box
|	0.0 +fx.on
	
	imgball 0.4 0.3 0.08 0.08 xywh%64 +img
	0.0 +fx.on

	imgglass 0.0 0.0 0.1 0.1 xywh%64 +img
	0.0 +fx.on

	tfoto 0.05 0.05 0.9 0.9 xywh%64 +img
	0.0 +fx.on
	
	font titulo 0.1 0.1 0.4 0.4 xywh%64 $00ff00ff +tbox |  HVRRGGBB00
	0.0 +fx.on

	font telefono 0.5 0.3 0.4 0.4 xywh%64 $11ff0000 +tbox 
	0.0 +fx.on

	font1 descripcion 0.1 0.1 0.8 0.8 xywh%64 $000000ff +tbox 
	0.0 +fx.on
	
	timeline.start
	;
	

:cartel
	$0 rgbcolor
	SDLrenderer SDL_RenderClear
	timeline.draw
	
	debugtimeline
	;
	
:cartelfin
	"fintt" .println
	imgglass SDL_DestroyTexture
	imgball SDL_DestroyTexture
	tfoto SDL_DestroyTexture
	;

#prgcartel 'cartelini 'cartel 'cartelfin

		
|---------------------------------
:mainloop
	programa ex
	SDLrenderer SDL_RenderPresent
	
	|endtimeline 1? ( exit ) drop
	
	SDLkey
	>esc< =? ( exit )
	<f2> =? ( 'prgajuste changeprg )
	<f1> =? ( 'prgcartel changeprg ) 
	drop ;		


:main
	"r3sdl" 800 600 SDLinit
	44100 $08010 2 4096 Mix_OpenAudio 
	$3 IMG_Init
	8 16 "media/img/VGA8x16.png" bmfont

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
	mark
	timeline.inimem
	;

: ini main ;
