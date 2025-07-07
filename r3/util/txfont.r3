| font with atlas from TTF
| PHREDA 2025

^r3/lib/gui.r3
^r3/lib/sdl2gfx.r3
^r3/lib/sdl2ttf.r3

#ttfont #tsizex #tsizey 

#recbox 0 0
#recdes 0 0 

#curx #cury
#newtex #newtab

#utf8 "áéíóúñÁÉÍÓÚ«»¿×·" 0 

:recbox! | h w y x --
	'recbox d!+ d!+ d!+ d! ;	

:tt< | "" -- surf h w
	ttfont swap $ffffff TTF_RenderUTF8_Blended
	Surf>wh swap ;
	
:tt> | surf --
	SDLrenderer over SDL_CreateTextureFromSurface | surface texture
	SDLrenderer over 0 'recbox SDL_RenderCopy	
	SDL_DestroyTexture
	SDL_FreeSurface ;
	
#estr 0	

:adv | h w --
	curx over + tsizex <? ( drop ; ) drop
	0 'curx ! over 'cury +! ;
	
:fontemit | n --
	'estr tt< adv cury curx recbox! tt> ;

:reccomp
	'recbox @+ swap @ 16 << or ;
	
:fontb!+ | adr -- adr'
	reccomp swap !+ ;
	
:fontw!+ | w --
	8 >> $ff and $80 or 3 << newTab +
	reccomp swap ! ;
	
::txload | "font" size -- nfont
	dup 3 << dup 'tsizey ! 2* 'tsizex !		| aprox 2*1 - 15x15 char 
	TTF_OpenFont 'ttfont !
	here dup 'newTex ! 8 + dup 'newTab ! 2048 + 'here !	| MEM
	newTab 0 256 fill 0 'curx ! 0 'cury !				| CLEAR
	tsizex tsizey texIni | w h --	
	newTab 32 3 << +
	32 ( 128 <? 
		dup 'estr c!+ 0 swap c!
		fontemit
		swap fontb!+
		'recbox 8 + d@ 'curx +!
		swap 1+ ) 2drop 
	'utf8 ( w@+ 1?
		dup 'estr w!+ 0 swap c!
		fontemit
		fontw!+
		'recbox 8 + d@ 'curx +!
		) 2drop
	texEndAlpha 
	dup 1 SDL_SetTextureBlendMode 
	newTex !
	ttfont TTF_CloseFont
	newTab 32 3 << + @ newTab !
	newTex
	;

|------------------------------
::txfont | font --
	dup @ 'newTex ! 8 + 'newTab ! ;
	
::txemit | asci --
	$80 and? ( drop c@+ $80 or ) 
	$ff and 3 << newTab + @ 
	dup 16 >> $ffff0000ffff and 
	dup rot $ffff0000ffff and 
	'recbox !+ ! 
	cury 32 << curx or 'recdes !+ !
	SDLrenderer newTex 'recbox 'recdes SDL_RenderCopy	
	'recdes 8 + d@ 'curx +! ;

::txemits | "" --
	( c@+ 1? txemit ) 2drop ;

::txrgb | c --
	newTex swap 
	dup 16 >> $ff and over 8 >> $ff and rot $ff and
	SDL_SetTextureColorMod ;
	
::txcw | car -- width
	$80 and? ( drop c@+ $80 or ) 
	$ff and 3 << newTab + 2 + w@ ; 
	
::txw | "" -- "" width
	0 over ( c@+ 1? txcw rot + swap ) 2drop ;
	
::txh | -- heigth
	newTab 6 + w@ ;
	
::txat | x y --
	'cury ! 'curx ! ;

:fontbox | asci --
	$80 and? ( drop c@+ $80 or ) 
	$ff and 3 << newTab + @ 
	16 >> $ffff0000ffff and | wh
	cury 32 << curx or 
	'recbox !+ ! ;
	
:curpos | str cur -- 
	swap ( over <? c@+ txcw 'curx +! ) drop 
	c@ 0? ( 32 or ) fontbox ;
	
::txcur | str cur -- 
	|curx >r
	curpos
	SDLRenderer 'recbox SDL_RenderFillRect 
	|r> 'curx ! 
	;
	
::txcuri | str cur --
	|curx >r
	curpos
	'recbox 12 + d@ 2 >>  | h/4
	dup 3 * 'recbox 4 + d+!	'recbox 12 + d!
	SDLRenderer 'recbox SDL_RenderFillRect 
	|r> 'curx ! 
	;	
	