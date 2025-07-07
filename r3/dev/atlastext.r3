| font atlas generator
| PHREDA 2024

^r3/lib/gui.r3
^r3/lib/sdl2gfx.r3
^r3/lib/sdl2ttf.r3

#uifont
#tsizex 512
#tsizey 256

#recbox 0 0
#recdes 0 0 

#curx #cury


#newtex
#fontchar * 4096
#utf8 "áéíóúñÁÉÍÓÚ«»¿º×" 0 

:recbox! | h w y x --
	'recbox d!+ d!+ d!+ d! ;	

:tt< | "" -- surf h w
	uifont swap $ffffff TTF_RenderUTF8_Blended
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
	'estr c!
	'estr tt< adv cury curx recbox! tt> ;

:fontemitw | n --
	'estr w!+ 0 swap c!
	'estr tt< adv cury curx recbox! tt> ;

:fontb!+ | adr -- adr'
	'recbox @+ swap @ rot !+ !+ ;
	
:fontw!+ | w --
	8 >> $ff and 4 << 'fontchar +
	'recbox @+ swap @ rot !+ !+ ;
	
:generate | "font" size --
	TTF_OpenFont 'uifont !
	tsizex tsizey texIni | w h --	
	'fontchar
	32 ( 128 <? 
		dup fontemit
		swap fontb!+
		'recbox 8 + d@ 'curx +!
		swap 1+ ) 2drop 
	'utf8 ( w@+ 1?
		dup fontemitw 
		fontw!+
		'recbox 8 + d@ 'curx +!
		swap ) 2drop
	texEndAlpha 'newTex !	
	uifont TTF_CloseFont
	;


:asciiemit
	$ff and 4 << 'fontchar + 
	@+ dup rot @ 'recbox !+ ! 
	cury 32 << curx or 'recdes !+ !
	SDLrenderer newTex 'recbox 'recdes SDL_RenderCopy	
	'recdes 8 + d@ 'curx +! ;
	
:fontemit
	32 128 in? ( 32 - asciiemit ; ) 
	drop c@+ asciiemit ; 

:fstring | "" x y --
	'cury ! 'curx !
	( c@+ 1? fontemit ) 2drop ;
		
:game
	$0 SDLcls
	$ffffff sdlcolor
|	9 9 514 256 sdlRect
	|10 10 512 512 newtex sdlimages

	newTex $00 $ff $ff SDL_SetTextureColorMod
	":hola a ""coso"" todo el mundi ;" 10 10 fstring
	newTex $ff $0 $ff SDL_SetTextureColorMod
	":hola i ;" 10 50 fstring
	newTex 0 $ff $0 SDL_SetTextureColorMod
	"¿º×áéíóúñ«»ÁÉÍÓÚ" 10 90 fstring
	
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	drop
	;

	
:main
	"ATLAS FONT GENERATOR" 1024 600 SDLinit
	
	|	"media/ttf/RobotoMono.ttf" 
	"media/ttf/Roboto-regular.ttf" 40 generate
	
	'game SDLshow 
	SDLquit ;

: main ;