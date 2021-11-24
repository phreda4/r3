
|:initfont
|	ttf_init
|	"media/ttf/roboto-bold.ttf" 48 TTF_OpenFont 'font !
|	;
	
#textbox [ 0 0 0 0 ]

::RenderTextB | SDLrender color font "texto" x y --
	swap 'textbox d!+ d!
	2dup 'textbox dup 8 + swap 12 + TTF_SizeText drop
	rot dup $ffffff and swap 32 >> TTF_RenderUTF8_Shaded
	2dup SDL_CreateTextureFromSurface | sd surface texture
	rot over 0 'textbox SDL_RenderCopy	
	SDL_DestroyTexture
	SDL_FreeSurface ;
	
::RenderText | SDLrender color font "texto" x y --
	swap 'textbox d!+ d!
	2dup 'textbox dup 8 + swap 12 + TTF_SizeText drop
	rot TTF_RenderText_Blended 
	2dup SDL_CreateTextureFromSurface | sd surface texture
	rot over 0 'textbox SDL_RenderCopy	
	SDL_DestroyTexture
	SDL_FreeSurface ;

::RenderTextS | SDLrender color font "texto" x y --
	swap 'textbox d!+ d!
	2dup 'textbox dup 8 + swap 12 + TTF_SizeText drop
	rot TTF_RenderText_Solid 
	2dup SDL_CreateTextureFromSurface | sd surface texture
	rot over 0 'textbox SDL_RenderCopy	
	SDL_DestroyTexture
	SDL_FreeSurface ;	
	
	
::RenderTexture | SDLrender font "text" color -- texture
	|TTF_RenderText_Solid ***
	|TTF_RenderText_Blended ***
	dup $ffffff and swap 32 >> TTF_RenderUTF8_Shaded
	dup rot swap SDL_CreateTextureFromSurface | sd surface texture
	swap SDL_FreeSurface ;
