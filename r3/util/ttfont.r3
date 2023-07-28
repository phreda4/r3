| ttfont.r3 - PHREDA 2023
|
|	ttf_init
|	"media/ttf/roboto-bold.ttf" 48 TTF_OpenFont 'font !
|
|-----------------------------
^r3/win/sdl2gfx.r3
^r3/win/sdl2ttf.r3

#textbox [ 0 0 0 0 ]

:RenderTextB | SDLrender color font "texto" x y --
	swap 'textbox d!+ d!
	2dup 'textbox dup 8 + swap 12 + TTF_SizeText drop
	rot dup $ffffff and swap 32 >> TTF_RenderUTF8_Shaded
	2dup SDL_CreateTextureFromSurface | sd surface texture
	rot over 0 'textbox SDL_RenderCopy	
	SDL_DestroyTexture
	SDL_FreeSurface ;
	
:RenderText | SDLrender color font "texto" x y --
	swap 'textbox d!+ d!
	2dup 'textbox dup 8 + swap 12 + TTF_SizeText drop
	rot TTF_RenderText_Blended 
	2dup SDL_CreateTextureFromSurface | sd surface texture
	rot over 0 'textbox SDL_RenderCopy	
	SDL_DestroyTexture
	SDL_FreeSurface ;

:RenderTextS | SDLrender color font "texto" x y --
	swap 'textbox d!+ d!
	2dup 'textbox dup 8 + swap 12 + TTF_SizeText drop
	rot TTF_RenderText_Solid 
	2dup SDL_CreateTextureFromSurface | sd surface texture
	rot over 0 'textbox SDL_RenderCopy	
	SDL_DestroyTexture
	SDL_FreeSurface ;	

#ttink	
#ttfon
#ttx #tty
	
::ttcolor | rrggbb --
	dup $ff and 16 <<
	over 16 >> $ff and or 
	swap $ff00 and or 'ttink ! ;
	
::ttfont | font --
	'ttfon ! ;
	
::ttprint | "" --
	sprint >r SDLrenderer ttink ttfon r> ttx tty RenderText ;
	
::ttat | x y --
	'tty ! 'ttx ! ;	
	
::ttsize | "" -- "" w h
	ttfon over 'textbox dup 8 + swap 12 + TTF_SizeText drop
	'textbox 8 + d@+ swap d@ ;
 
::ttpos | -- x y
	ttx tty ;

::ttrect |  "" -- "" x y w h
	ttsize ttx tty 2swap ;
	
