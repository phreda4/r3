| font atlas generator
| PHREDA 2024

^r3/lib/gui.r3
^r3/lib/sdl2gfx.r3
^r3/lib/sdl2ttf.r3

#ttfont
#ttfonta

#tsizex 512
#tsizey 256

#recbox 0 0
#recdes 0 0 

#curx #cury

#newtex
#newtab

| 		user image file camera calendar eye lupa check bars  xquis
#fonta $f007 $f03e $f15b $f030 $f133 $f06e $f002 $f00c $f0c9 $f00d 
|fold fo-open <    >	v	  ^
$f07b $f07c $f0d9 $f0da $f0d7 $f0d8 
$f104 $f105 $f107 $f106
$f111 $f058
$f0c8 $f14a
0

#utf8 "áéíóúñÁÉÍÓÚÜüÇç«»¿×·" 0 

#symbol "<>v^<>v^-x-x......"

:recbox! | h w y x --
	'recbox d!+ d!+ d!+ d! ;	

:tt< | "" -- surf h w
	ttfont swap $ffffff TTF_RenderUTF8_Blended
	Surf>wh swap ;
	
:tt<u | "" -- surf h w
	ttfonta swap $ffffff TTF_RenderUNICODE_Blended
	Surf>wh swap ;
	
:tt> | surf --
	SDLrenderer over SDL_CreateTextureFromSurface | surface texture
	SDLrenderer over 0 'recbox SDL_RenderCopy	
	SDL_DestroyTexture
	SDL_FreeSurface ;
	
#estr 0	0

:adv | h w --
	curx over + tsizex <? ( drop ; ) drop
	0 'curx ! over 'cury +! ;
	
:fontemit | --
	'estr tt< adv cury curx recbox! tt> ;

:fontemitu |--
	'estr tt<u adv cury curx recbox! tt> ;
	
:reccomp
	'recbox @+ swap @ 16 << or ;
	
:fontb!+ | adr -- adr'
	reccomp swap !+ ;
	
:fontw!+ | w --
	8 >> $ff and $80 or 
	dup .d .println
	3 << newTab +
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
	'fonta ( @+ 1? |$ffffff and
		'estr !+ 0 swap c!
		fontemitu
		dup 'fonta - 3 >> 
		191 + | 192..
		fontw!+u
		'recbox 8 + d@ 'curx +!
		) 2drop
	texEndAlpha 
	dup 1 SDL_SetTextureBlendMode 
	newTex !
	ttfont TTF_CloseFont 
	ttfonta TTF_CloseFont 
	newTex
	;

|------------------------------
::txfont | font --
	dup @ 'newTex ! 8 + 'newTab ! ;
	
:fontemit | asci --
	$80 and? ( drop c@+ $80 or ) 
	$ff and 3 << newTab + @ 
	dup 16 >> $ffff0000ffff and 
	dup rot $ffff0000ffff and 
	'recbox !+ ! 
	cury 32 << curx or 'recdes !+ !
	SDLrenderer newTex 'recbox 'recdes SDL_RenderCopy	
	'recdes 8 + d@ 'curx +! ;

::txemits | "" --
	( c@+ 1? fontemit ) 2drop ;

::txrgb | c --
	newTex swap 
	dup 16 >> $ff and over 8 >> $ff and rot $ff and
	SDL_SetTextureColorMod ;
	
:fw | car -- width
	$80 and? ( drop c@+ $80 or ) 
	$ff and 3 << newTab + 2 + w@ ; 
	
::txw | "" -- "" width
	0 over ( c@+ 1? fw rot + swap ) 2drop ;
	
::txh | -- heigth
	newTab 32 3 << + 2 + w@ ;
	
::txat | x y --
	'cury ! 'curx ! ;

:fontbox | asci --
	$80 and? ( drop c@+ $80 or ) 
	$ff and 3 << newTab + @ 
	16 >> $ffff0000ffff and | wh
	cury 32 << curx or 
	'recbox !+ ! ;
	
:curpos | str cur -- 
	swap ( over <? c@+ fw 'curx +! ) drop 
	c@ 0? ( 32 or ) fontbox ;
	
::txcur | str cur -- 
	curx >r
	curpos
	SDLRenderer 'recbox SDL_RenderFillRect 
	r> 'curx ! ;
	
::txcuri | str cur --
	curx >r
	curpos
	'recbox 12 + d@ 2 >>  | h/4
	dup 3 * 'recbox 4 + d+!	'recbox 12 + d!
	SDLRenderer 'recbox SDL_RenderFillRect 
	r> 'curx ! ;	
	
|------------------------------		
#font1 0
#font2 0
#font3 0

:game
	$0 SDLcls
	$ffffff sdlcolor
	
	font1 txfont
	10 200 newtex sdlimage
	
	$00ffff txrgb
	10 10 txat ":hola a ""coso"" todo el mundi ;" txemits
	$ff00ff txrgb
	10 50 txat ":hola i ;‼┴" txemits
	'utf8 txemits

	
	font2 txfont
|	10 400 newtex sdlimage
	$ffffff txrgb
	'utf8 txemits
	10 90 txat ":hola a ""coso"" todo el mundi ;" txemits

	font3 txfont
	|500 10 newtex sdlimage
	$ffff00 txrgb
	" djhaskdjahsf" txemits
	'utf8 txemits


	font1 txfont
	$ff00 txrgb
	10 110 txat
	"esto is un cirv"
	msec $80 and? ( 
		$ff sdlcolor 
		over dup msec 9 >> $f and + txcur 
		) drop
	txemits
	
	
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	drop
	;

:main
	"ATLAS FONT GENERATOR" 1024 600 SDLinit
	
	"media/ttf/RobotoMono-Medium.ttf" 20 txload 'font2 !
	"media/ttf/ProggyClean.ttf" 16 txload 'font3 !
	"media/ttf/Roboto-bold.ttf" 32 txload 'font1 !
	
	'game SDLshow 
	SDLquit ;

: main ;