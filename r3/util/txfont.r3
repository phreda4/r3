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
		swap 1+ ) 2drop ;
	

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
	dup newTab 10 3 << + !	| ln
	dup $ffff0000 and 2 << swap $ffffffff0000ffff and or 
	newTab 9 3 << + !	| tab
	newTex ;	| reuturn ini font

|------------------------------
::txfont | font -- ; select the atlas font (from txload) used by the tx words
	dup @ 'newTex ! 8 + 'newTab ! ;
	
::txfont@ | -- font ; the atlas font selected now
	newTab 8 - ;
	
::txrgb | c -- ; color $RRGGBB of the font texture (color modulation)
	newTex swap 
	dup 16 >> $ff and over 8 >> $ff and rot $ff and
	SDL_SetTextureColorMod ;
	
::txcw | adr car -- adr' width ; width in pixels of a character
	$ff and 3 << newTab + 2 + w@ ; 
	
::txw | "" -- "" width ; width in pixels of the string
	0 over ( c@+ 1? txcw rot + swap ) 2drop ;
	
::txfit | w "" -- ncar ; number of bytes of the string that fit in w pixels
	0 over
	( c@+ 1? txcw	| w "" l "" cw
		rot +		| w "" "" cw+l
		pick3 >? ( drop swap - nip ; )
		swap
		) drop nip 
	swap - nip ;
	
::txch | adr car -- adr' h ; height of a character (same protocol as txcw)
	$ff and 3 << newTab + 6 + w@ ;
	
::txh | -- h ; height of the font (line height)
	newTab 6 + w@ ;
	
::txat | x y -- ; move the cursor to the pixel position x y
	'cury ! 'curx ! ;

::tx+at | x y -- ; move the cursor by x y pixels
	'cury +! 'curx +! ;

::txcr | -- ; new line: x = 0 and y down one line height
	0 'curx ! txh 'cury +! ;
	
::txpos | -- x y ; cursor position in pixels
	curx cury ;
	
::txemit | adr car -- adr' ; draw one character at the cursor and advance it
	$ff and 3 << newTab + @ 
	dup 16 >> $ffff0000ffff and 
	dup rot $ffff0000ffff and 
	'recbox !+ ! 
	cury 32 << curx or 'recdes !+ !
	SDLrenderer newTex 'recbox 'recdes SDL_RenderCopy	
	'recdes 8 + d@ 'curx +! ;

::txwrite | "" -- ; draw the string at the cursor
	( c@+ 1? txemit ) 2drop ;

::txemitr | "" -- ; draw the string right aligned: it ends at the cursor x
	txw neg 'curx +!
	txwrite ;

::txemitc | w "" -- ; draw the string centered in w pixels starting at the cursor x
	txw rot swap - 2/ 'curx +!
	txwrite ;

::txprint | .. "" -- ; formatted print (see sprint) at the cursor
	sprint txwrite ;

::txprintr | .. "" -- ; formatted print right aligned
	sprint txemitr ;

:fontbox | char --
	$ff and 3 << newTab + @ 
	16 >> $ffff0000ffff and | wh
	cury 32 << curx or 
	'recbox !+ ! ;
	
:curpos | str cur -- 
	swap ( over <? c@+ txcw 'curx +! ) drop 
	c@ fontbox ;
	
::txcur | str cur -- ; block cursor 
	curpos
	SDLRenderer 'recbox SDL_RenderFillRect ;
	
::txcuri | str cur -- ; insert cursor
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

:testw | w h x y str -- str
	pick4 over txfit | w h x y str ncar
	over count nip >=? ( drop ; )
	over a!+ 		| newline
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

::lwrite | w "str" -- ; left aligned text for txText (ignores w)
	nip txwrite ;
::cwrite | w "str" -- ; centered text in w pixels for txText
	txw rot swap - 2/ 0 tx+at
	txwrite ;
::rwrite | w "str" -- ; right aligned text in w pixels for txText
	txw rot swap - 0 tx+at
	txwrite ;
	
:vtop	drop ;
:vcen	cntlines txh * - 2/ + txh 2/ + ;
:vbot	cntlines 1- txh * - +  ;

#halign 'cwrite
#valign 'vcen

::txalign | $VH -- ; alignment for txText: low 2 bits horizontal (0 left, 1 center, 2 right), bits 4-5 vertical (0 top, 1 center, 2 bottom)
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

::txText | w h x y "" -- ; draw the string wrapped by words in the box x y w h with the txalign alignment; CR, LF and ; start a new line
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
	
|--- Edita linea
#cmax
#padi>	| inicio
#pad>	| cursor
#padf>	| fin

:lins  | c -- ;
	padf> padi> - cmax >=? ( 2drop ; ) drop
	pad> dup 1- padf> over - 1+ cmove> 1 'padf> +!
:lover | c -- ;
	pad> c!+ dup 'pad> !
	padf> <=? ( drop ; )
	dup padi> - cmax >=? ( swap 1- swap -1 'pad> +! ) drop
	'padf> ! ;
:0lin 0 padf> c! ;
:kdel pad> padf> >=? ( drop ; ) drop 1 'pad> +! | --;
:kback pad> padi> <=? ( drop ; ) dup 1- swap padf> over - 1+ cmove -1 'padf> +! -1 'pad> +! ;
:kder pad> padf> <? ( 1+ ) 'pad> ! ;
:kizq pad> padi> >? ( 1- ) 'pad> ! ;
:kup
	pad> ( padi> >?
		1- dup c@ $ff and 32 <? ( drop 'pad> ! ; )
		drop ) 'pad> ! ;
:kdn
	pad> ( c@+ 1?
		$ff and 32 <? ( drop 'pad> ! ; )
		drop ) drop 1- 'pad> ! ;

#modo 'lins

::pad.reset | 'var max -- 'var max ; prepare the line editor on the buffer 'var of max bytes: cursor at the end, insert mode
	1- 'cmax !
	dup dup 'padi> !
	( c@+ 1? drop ) drop 1-
	dup 'pad> ! 'padf> !
	'lins 'modo ! ;

:chmode
	modo 'lins =? ( drop 'lover 'modo ! ; )
	drop 'lins 'modo ! ;

:drawcur
	msec $100 and? ( drop ; ) drop
	$a0a0a0 color
	padi> pad> 
	modo 'lins =? ( drop txcur ; ) drop
	txcuri ;

::pad.draw | 'buff -- ; draw the edited line at the cursor with a blinking cursor and handle the keys: SDLchar to insert or overwrite, left, right, backspace, delete, home, end and insert to change the mode
	txpos drawcur
	txat txwrite
	
	SDLchar 1? ( modo ex ; ) drop
	
	SDLkey
	<ins> =? ( chmode )
	
	|--pc mode
	<le> =? ( kizq ) <ri> =? ( kder )
	<back> =? ( kback ) <del> =? ( kdel )
	<home> =? ( padi> 'pad> ! ) <end> =? ( padf> 'pad> ! )
	|-- vim ...
	
	drop
	;