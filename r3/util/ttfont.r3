| ttfont.r3 - PHREDA 2023
|
|	ttf_init
|	"media/ttf/Roboto-bold.ttf" 48 TTF_OpenFont 'font !
|
|-----------------------------
^r3/lib/sdl2gfx.r3
^r3/lib/sdl2ttf.r3

#textbox [ 0 0 0 0 ]

:RenderTextB | SDLrender color font "texto" x y --
	swap 'textbox d!+ d!
	2dup 'textbox dup 8 + swap 12 + TTF_SizeUTF8 drop
	rot dup $ffffff and swap 32 >> TTF_RenderUTF8_Shaded
	2dup SDL_CreateTextureFromSurface | sd surface texture
	rot over 0 'textbox SDL_RenderCopy	
	SDL_DestroyTexture
	SDL_FreeSurface ;
	
:RenderText | SDLrender color font "texto" x y --
	swap 'textbox d!+ d!
	2dup 'textbox dup 8 + swap 12 + TTF_SizeUTF8 drop
	rot TTF_RenderUTF8_Blended 
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
##ttx | cursor x in pixels
##tty | cursor y in pixels
	
::ttcolor | rrggbb -- ; text color (stored with red and blue swapped, as SDL_Color wants it)
	dup $ff and 16 <<
	over 16 >> $ff and or 
	swap $ff00 and or 'ttink ! ;
	
::ttfont! | font -- ; set the font (from TTF_OpenFont) used by the tt words
	'ttfon ! ;
	
::ttat | x y -- ; move the cursor to the pixel position x y
	'tty ! 'ttx ! ;	

::+ttat | x y -- ; move the cursor by x y pixels
	'tty +! 'ttx +! ;	

::ttwh | "" -- "" w h ; size in pixels of the string with the current font
	ttfon over 'textbox dup 8 + swap 12 + TTF_SizeUTF8 drop
	'textbox 8 + d@+ swap d@ ;

::ttsize | size -- ; set the point size of the current font
	ttfon swap TTF_SetFontSize ;
	
::ttstyle | style -- ; set the style of the current font: bit 0 bold, 1 italic, 2 underline, 3 strikethrough
	ttfon swap TTF_SetFontStyle ;

::ttprint | .. "" -- ; formatted print (see sprint) at the cursor
	sprint	
::ttemits | "" -- ; draw the string at the cursor and move the cursor to its end (a texture is created for each call)
	SDLrenderer ttink ttfon pick3 ttx tty RenderText
	ttfon swap 'textbox dup 8 + swap 12 + TTF_SizeUTF8 drop
	'textbox 8 + d@ 'ttx +! 
	;

::ttemitc | width "" -- ; draw the string centered in width pixels starting at the cursor
	ttwh drop | w "" tw
	rot swap - 2/
	'ttx +!
	ttemits ;

::ttemitr | "" -- ; draw the string right aligned: it ends at the cursor x
	ttwh drop | "" tw
	neg 'ttx +!
	ttemits ;
	
::ttboxcc | w h "" -- ; draw the string centered in a box w x h starting at the cursor
	ttwh | w h "" tw th
	2swap >r | w tw th h "" 
	swap - 2/ 'tty +!
	- 2/ 'ttx +!
	r> ttemits ;
	
#backc	
:sizechar | -- w 
	backc 0? ( drop 8 ; ) drop
	ttfon 'backc 'textbox dup 8 + swap 12 + TTF_SizeUTF8 drop
	'textbox 8 + d@ ;
	
::ttcursor | str strcur -- str ; fill with the draw color the block cursor of the character at strcur (an address inside str); the string is cut there temporarily
	dup c@ 'backc c! | str strcur
	0 over c!		| set end
	swap ttwh  | strcur str w h
	ttx rot + tty rot 
	sizechar
	swap frect
	backc rot c!
	;

::ttcursori | str strcur -- str ; like ttcursor but a bar of 2 pixels at the bottom (insert cursor)
	dup c@ 'backc c! | str strcur
	0 over c!		| set end
	swap ttwh  | strcur str w h
	ttx rot + tty rot 
	sizechar | x y h w
	rot 	| x h w y
	rot + 2 -	| x w y+h
	swap 2 frect
	backc rot c!
	;
	
::ttrect | "" -- "" x y w h ; rectangle (position and size in pixels) of the string at the cursor
	ttwh ttx tty 2swap ;
	
