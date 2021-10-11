| Señal de ajuste
| PHREDA 2020
|^r3/win/console.r3
^r3/win/SDL2.r3
^r3/win/SDL2ttf.r3
^r3/lib/mem.r3

|---- datetime
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

|----------------
#font

:initfont
	ttf_init
	"media/ttf/roboto-bold.ttf" 48 TTF_OpenFont 'font !
	;

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


:datetime
	SDLrenderer $ffffff font
	mark ,sp ,date ,sp ,eol empty here 
	40 40 RenderText
	
	SDLrenderer $ffffff00000000 font
	mark ,sp ,time ,sp ,eol empty here 
	40 sh 80 - RenderText
	;

|---- colorbars
#col $fdfdfd $fdfc01 $fcfd $fe00 $fd00fb $fc0001 $0100fc

#rf [ 0 0 0 0 ]

:sajuste
	'col sw 7 /mod 1 >> | 'col w x
	( sw 8 - <?
		rot @+ 
		SDLrenderer swap
		dup 16 >> $ff and 
		swap dup 8 >> $ff and 
		swap $ff and 
		$ff SDL_SetRenderDrawColor 
		rot rot 
		sh pick2 0 pick3 'rf d!+ d!+ d!+ d!
		SDLrenderer 'rf SDL_RenderFillRect
		over + )
	3drop ;

|----------------
:main
	sajuste 
	( SDLkey >esc< <>? drop
		datetime
		SDLrenderer SDL_RenderPresent
		SDLupdate ) drop ;	

: 
	"r3sdl" 640 480 SDLinitgl
	initfont

	main
	
	SDLquit
	;