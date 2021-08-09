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

^r3/lib/mem.r3
^r3/lib/key.r3
^r3/lib/sys.r3
^r3/lib/gr.r3

#font

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

|---------------------------------------------------
#programa 'sajuste

:loadprog
	;
	
:freeprog
	;


|---------------------------------------------------
	
:mainloop
	SDLrenderer 0 0 msec $ff SDL_SetRenderDrawColor
	SDLrenderer SDL_RenderClear
	
	programa ex
	
	SDLrenderer SDL_RenderPresent
	
	SDLkey
	>esc< =? ( exit )
	drop ;		


:main
	"r3sdl" 800 600 SDLinit
	44100 $08010 2 4096 Mix_OpenAudio 
	$3 IMG_Init
|	8 16 "media/img/VGA8x16.png" bmfont

	ttf_init
	"media/ttf/roboto-bold.ttf" 48 TTF_OpenFont 'font !
	
|	loadres
	
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
