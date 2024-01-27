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
##ttx ##tty
	
::ttcolor | rrggbb --
	dup $ff and 16 <<
	over 16 >> $ff and or 
	swap $ff00 and or 'ttink ! ;
	
::ttfont | font --
	'ttfon ! ;
	
::tt. | "" --
	>r SDLrenderer ttink ttfon r> ttx tty RenderText ;
	
::ttat | x y --
	'tty ! 'ttx ! ;	

::+ttat | x y --
	'tty +! 'ttx +! ;	

::ttsize | "" -- "" w h
	ttfon over 'textbox dup 8 + swap 12 + TTF_SizeText drop
	'textbox 8 + d@+ swap d@ ;
		
::ttprint | "" --
	sprint dup tt. 
	ttfon swap 'textbox dup 8 + swap 12 + TTF_SizeText drop
	'textbox 8 + d@ 'ttx +! ;
	
#backc	
:sizechar | -- w 
	backc 0? ( drop 8 ; ) drop
	ttfon 'backc 'textbox dup 8 + swap 12 + TTF_SizeText drop
	'textbox 8 + d@ ;
	
::ttcursor | str strcur -- str
	dup c@ 'backc c! | str strcur
	0 over c!		| set end
	swap ttsize  | strcur str w h
	ttx rot + tty rot 
	sizechar
	swap SDLFrect
	backc rot c!
	;

::ttcursori | str strcur -- str
	dup c@ 'backc c! | str strcur
	0 over c!		| set end
	swap ttsize  | strcur str w h
	ttx rot + tty rot 
	sizechar | x y h w
	rot 	| x h w y
	rot + 2 -	| x w y+h
	swap 2 sdlFrect
	backc rot c!
	;
	
::ttrect |  "" -- "" x y w h
	ttsize ttx tty 2swap ;
	
