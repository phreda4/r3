| font with atlas from TTF
| pseudo utf-8
| PHREDA 2025

^r3/lib/sdl2gfx.r3
^r3/lib/sdl2ttf.r3

#ttfont #tsizex #tsizey 
#ttfonta #txline

#recbox 0 0
#recdes 0 0 

#curx #cury
#newtex #newtab

#utf8 "áéíóúñÁÉÍÓÚÜüÇç«»¿" 0  

#fonta | 128..
$f0d9 $f0da $f0d7 $f0d8 | < > v ^
$f104 $f105 $f107 $f106 | < > v ^
$f111 $f058
$f0c8 $f14a
|fold fo-open user image file camera calendar eye lupa check bars xquis
$f07b $f07c $f007 $f03e $f15b $f030 $f133 $f06e $f002 $f00c $f0c9 $f00d 
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
	
:regularchar
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
		) 2drop ;
	
	
::txloadwicon | "font" size -- nfont
	"media/ttf/Font Awesome 7 Free-Solid-900.otf"
	over 2 - TTF_OpenFont 'ttfonta !
	dup 3 << dup 'tsizey ! 2* 'tsizex !		| aprox 2*1 - 15x15 char 
	TTF_OpenFont 'ttfont !
	here dup 'newTex ! 8 + dup 'newTab ! 2048 + 'here !	| MEM
	newTab 0 256 fill 0 'curx ! 0 'cury !				| CLEAR
	tsizex tsizey texIni 	| w h --	
	newTab 32 3 << +		| start in ascii 32
	regularchar
	'fonta ( @+ 1?
		'estr !+ 0 swap c!
		fontemitu
		dup 'fonta - 3 >> 191 + | 192.. 128..
		fontw!+u
		'recbox 8 + d@ 'curx +!
		) 2drop		
	texEndAlpha 
	tex2static
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


::txload | "font" size -- nfont
	dup 3 << dup 'tsizey ! 2* 'tsizex !		| aprox 2*1 - 15x15 char 
	TTF_OpenFont 'ttfont !
	here dup 'newTex ! 8 + dup 'newTab ! 2048 + 'here !	| MEM
	newTab 0 256 fill 0 'curx ! 0 'cury !				| CLEAR
	tsizex tsizey texIni 	| w h --	
	newTab 32 3 << +		| start in ascii 32
	regularchar	
	texEndAlpha 
	tex2static
	|dup 1 SDL_SetTextureBlendMode 
	newTex !
	ttfont TTF_CloseFont
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
	$40 or ; | 128 >> 192
	
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
	
::txch | car -- height
	decode
	$ff and 3 << newTab + 6 + w@ ;
	
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

::txwrite | "" --
	( c@+ 1? txemit ) 2drop ;

::txemitr | "" --
	txw neg 'curx +!
	txwrite ;
	
::txprint | .. "" --
	sprint txwrite ;

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
	
	
|---- Text
#strsplit
#strsplit>
#lines
#cntlines

:emit0
	13 =? ( drop dup c@ 10 =? ( swap 1+ swap ) drop 0 ; )
	10 =? ( drop dup c@ 13 =? ( swap 1+ swap ) drop 0 ; )
	$3b =? ( 0 nip ) ;
	
:<<sp | stro str -- str'
	swap over
	( over <? ( 2drop ; ) 
		dup c@ $ff and 32 >? 
		drop 1- ) drop nip nip ;

:testw | str -- str
	pick4 >r utf8count 
	r> swap >? ( drop ; ) | str count
	over a!+ | newline
	utf8bytes | str bytes
	over + <<sp
	0 swap c!+
	testw ;
	
:splitlines | str --
	here dup >a 'strsplit ! 
	( c@+ 1? emit0 ca!+ ) nip | put 0 in ; or cr
	a> 'strsplit> !
	ca!+ 
	a> 'lines !
	strsplit ( strsplit> <?
		testw dup a!+ >>0
		) drop
	0 a!+
	a> dup 'here ! 
	lines - 3 >> 'cntlines !
	;	

::lwrite | w "str" --
	nip txwrite ;
::cwrite | w "str" --
	txw rot swap - 2/ 0 tx+at
	txwrite ;
::rwrite | w "str" --
	txw rot swap - 0 tx+at
	txwrite ;
	
:vtop	drop ;
:vcen	cntlines txh * - 2/ + txh 2/ + ;
:vbot	cntlines 1- txh * - +  ;

#halign 'cwrite
#valign 'vcen

::txalign | $VH --
	dup $3 and
	0 =? ( 'lwrite 'halign !  )
	1 =? ( 'cwrite 'halign ! )
	2 =? ( 'rwrite 'halign ! )
	drop
	4 >> $3 and
	0 =? ( 'vtop 'valign ! )
	1 =? ( 'vcen 'valign ! )
	2 =? ( 'vbot 'valign ! )
	drop ;

::txText | w h x y "" --
	mark ab[ 
	splitlines 
	rot 	| w x y h
	valign ex
	lines >a ( 
		2dup txat
		a@+ 1? 
		pick3 swap halign ex 
		txh + ) drop
	3drop
	]ba empty ;	