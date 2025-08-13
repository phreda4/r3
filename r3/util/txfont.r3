| font with atlas from TTF
| pseudo utf-8
| PHREDA 2025

^r3/lib/gui.r3
^r3/lib/sdl2gfx.r3
^r3/lib/sdl2ttf.r3

#ttfont #tsizex #tsizey 
#ttfonta #txline

#recbox 0 0
#recdes 0 0 

#curx #cury
#newtex #newtab

#utf8 "áéíóúñÁÉÍÓÚÜüÇç«»¿×·" 0  
| 		user image file camera calendar eye lupa check bars  xquis
#fonta $f007 $f03e $f15b $f030 $f133 $f06e $f002 $f00c $f0c9 $f00d 
|fold fo-open <    >	v	  ^
$f07b $f07c $f0d9 $f0da $f0d7 $f0d8 
$f104 $f105 $f107 $f106
$f111 $f058
$f0c8 $f14a
0

:recbox! | h w y x --
	'recbox d!+ d!+ d!+ d! ;	

:tt< | "" -- surf h w
	ttfont swap $ffffff TTF_RenderUTF8_Blended
	Surf>wh dup txline max 'txline !
	swap ;

:tt<u | "" -- surf h w
	ttfonta swap $ffffff TTF_RenderUNICODE_Blended
	Surf>wh dup txline max 'txline !
	swap ;
	
:tt> | surf --
	SDLrenderer over SDL_CreateTextureFromSurface | surface texture
	SDLrenderer over 0 'recbox SDL_RenderCopy	
	SDL_DestroyTexture
	SDL_FreeSurface ;
	
#estr 0	0

:adv | h w --
	curx over + tsizex <? ( drop ; ) drop
	0 'curx ! txline 'cury +! 
	0 'txline ! ;
	
:fontemit | n --
	'estr tt< adv cury curx recbox! tt> ;

:fontemitu 
	'estr tt<u adv cury curx recbox! tt> ;
	
:reccomp
	'recbox @+ swap @ 16 << or ;
	
:fontb!+ | adr -- adr'
	reccomp swap !+ ;
	
:fontw!+ | w --
	8 >> $ff and $80 or 3 << newTab +
	reccomp swap ! ;

:fontw!+u | w --
	3 << newTab +
	reccomp swap ! ;	
	
::txload | "font" size -- nfont
	"media/ttf/Font Awesome 7 Free-Solid-900.otf" over 4 - TTF_OpenFont 'ttfonta !
	dup 3 << dup 'tsizey ! 2* 'tsizex !		| aprox 2*1 - 15x15 char 
	TTF_OpenFont 'ttfont !
	here dup 'newTex ! 8 + dup 'newTab ! 2048 + 'here !	| MEM
	newTab 0 256 fill 0 'curx ! 0 'cury !				| CLEAR
	tsizex tsizey texIni 	| w h --	
	newTab 32 3 << +		| start in ascii 32
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
	'fonta ( @+ 1?
		'estr !+ 0 swap c!
		fontemitu
		dup 'fonta - 3 >> 191 + | 192..
		fontw!+u
		'recbox 8 + d@ 'curx +!
		) 2drop		
	texEndAlpha 
	|dup 1 SDL_SetTextureBlendMode 
	newTex !
	ttfont TTF_CloseFont
	ttfonta TTF_CloseFont
	newTab 32 3 << + @	| width ESP
	dup newTab !			| 0
	dup newTab 13 3 << + !	| cr
	dup $ffff0000 and 2 << swap $ffffffff0000ffff and or 
	newTab 9 3 << + !	| tab
	newTex ;	| reuturn ini font

|------------------------------
:decode
	$80 nand? ( ; )
	$40 and? ( drop c@+ $80 or ; )
	$40 or ;
	
::txfont | font --
	dup @ 'newTex ! 8 + 'newTab ! ;
	
::txfont@ | -- font
	newTab 8 - ;
	
::txrgb | c --
	newTex swap 
	dup 16 >> $ff and over 8 >> $ff and rot $ff and
	SDL_SetTextureColorMod ;
	
::txcw | car -- width
	decode
	$ff and 3 << newTab + 2 + w@ ; 
	
::txw | "" -- "" width
	0 over ( c@+ 1? txcw rot + swap ) 2drop ;
	
::txh | -- heigth
	newTab 6 + w@ ;
	
::txat | x y --
	'cury ! 'curx ! ;

::tx+at | x y --
	'cury +! 'curx +! ;

::txpos | -- x y 
	curx cury ;
	
::txemit | utf8' --
	decode
	$ff and 3 << newTab + @ 
	dup 16 >> $ffff0000ffff and 
	dup rot $ffff0000ffff and 
	'recbox !+ ! 
	cury 32 << curx or 'recdes !+ !
	SDLrenderer newTex 'recbox 'recdes SDL_RenderCopy	
	'recdes 8 + d@ 'curx +! ;

::txemits | "" --
	( c@+ 1? txemit ) 2drop ;

::txemitr | "" --
	txw neg 'curx +!
	txemits ;
	
::txprint | .. "" --
	sprint txemits ;

::txprintr | .. "" --
	sprint txemitr ;

:fontbox | utf8' --
	decode
	$ff and 3 << newTab + @ 
	16 >> $ffff0000ffff and | wh
	cury 32 << curx or 
	'recbox !+ ! ;
	
:curpos | str cur -- 
	swap ( over <? c@+ txcw 'curx +! ) drop 
	c@ fontbox ;
	
::txcur | str cur -- 
	curpos
	SDLRenderer 'recbox SDL_RenderFillRect ;
	
::txcuri | str cur --
	curpos
	'recbox 12 + d@ 
	dup 2 >> swap over - | h/4
	'recbox 4 + d+!	'recbox 12 + d!
	SDLRenderer 'recbox SDL_RenderFillRect ;	
	
	