| pcfont.r3
| fuente de ancho fijo PC
| PHREDA 2024
|-----------------------------
^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3

#pfont 
#op 0 0
#dp 0 0
#ws 3 #hs 4
	
::pccolor | rrggbb --
	pfont swap
	dup 16 >> $ff and over 8 >> $ff and rot $ff and
	SDL_SetTextureColorMod
	;
	
::pcemit | ascii --
	dup $f and ws << swap 4 >> $f and hs 32 + << or 'op !
	SDLrenderer pfont 'op 'dp SDL_RenderCopy
	8 'dp d+!
	;

::pcfbox | --
	SDLRenderer 'dp SDL_RenderFillRect ;

::pcbox | --
	SDLRenderer 'dp SDL_RenderDrawRect ;

::pcbox2 | --
	16 1 >> dup 'dp 4 + d+! 'dp 12 + d!
	SDLRenderer 'dp SDL_RenderDrawRect 
	16 dup 1 >> neg 'dp 4 + d+! 'dp 12 + d!
	;
	
#rec 0 0
::pcfillline | x y w h --
	hs << 32 << swap ws << or 
	rot ws << rot hs << 32 << or 
	'rec !+ !
	SDLRenderer 'rec SDL_RenderFillRect ;

::pcsrcsize | x y w h -- x y w h
	2swap hs << swap ws << swap 
	2swap hs << swap ws << swap ;
	
	
::pcfillemit | "" -- ""
	count ws <<
	16 32 << or
	dp 'rec !+ !
	SDLRenderer 'rec SDL_RenderFillRect ;
	
::pcprint
	sprint
::pcemits | "" --
	( c@+ 1? pcemit ) 2drop ;

|----- double w
:pcemitb	
	dup $f and ws << swap 4 >> $f and hs 32 + << or 'op !
	SDLrenderer pfont 'op 'dp SDL_RenderCopy
	16 'dp d+! ;
	
::pcprintd
	sprint
::pcemitsd | "" --
	$1000000010 'dp 8 + ! 
	( c@+ 1? pcemitb ) 2drop 
	$1000000008 'dp 8 + ! ;

|----- double w h
::pcprint2
	sprint
::pcemits2 | "" --
	$2000000010 'dp 8 + ! 
	( c@+ 1? pcemitb ) 2drop 
	$1000000008 'dp 8 + ! ;

|------- sized
#advx

:pcemitz
	dup $f and ws << swap 4 >> $f and hs 32 + << or 'op !
	SDLrenderer pfont 'op 'dp SDL_RenderCopy
	advx 'dp d+! ;
	
::pcprintz | .. "" size --
	>r sprint r>
::pcemitsz | "" size --
	8 over 16 *>> dup 'advx ! 16 rot 16 *>>
	32 << or 'dp 8 + !
	( c@+ 1? pcemitz ) 2drop 
	$1000000008 'dp 8 + ! ;
	
	
::pcat | x y --
	32 << or 'dp ! ;	

::ccx dp $ffffffff and ;
::ccy dp 32 >> ;

::gotoxy | x y --
	hs << swap ws << swap pcat ;
::gotox | x --
	ws << 'dp d! ;
::pccr
	0 'dp d!
	16 'dp 4 + d+! ;
::pcsp
	8 'dp d+! ;
::pcnsp | n --
	ws << 'dp d+! ;
	
::pcsize | "" -- "" w h
	count ws << 16 ;
 
::pcpos | -- x y
	dp dup $ffffff and swap 32 >> ;

::pcrect |  "" -- "" x y w h
	pcsize pcpos 2swap ;
	
::pccursor | n --
	ws << pcpos swap rot + swap 8 16 SDLFRect ;

::pccursori | n --
	ws << pcpos swap rot + swap 16 dup 2 >> - + 8 16 2 >> SDLFRect ;

::pcfont
	"media/img/VGA8x16.png" 
	loadimg 'pfont !
	$1000000008
	|8 16 32 << or 
	dup 'dp 8 + ! 'op 8 + !
	| 16 'hp ! 8 'wp ! 
	;	
	
