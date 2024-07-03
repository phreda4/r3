| bfont.r3
| fuentes de ancho fijo 
| PHREDA 2021
|-----------------------------
^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3

#pfont 
##wp ##hp
#op 0 0
#dp 0 0

::bmfont | w h "" --
	loadimg 'pfont !
	2dup 32 << or dup
	'dp 8 + ! 'op 8 + !
	'hp ! 'wp ! 
	;
	
::bcolor | rrggbb --
	pfont swap
	dup 16 >> $ff and over 8 >> $ff and rot $ff and
	SDL_SetTextureColorMod
	;
	
::bfbox | --
	SDLRenderer 'dp SDL_RenderFillRect ;

::bbox | --
	SDLRenderer 'dp SDL_RenderDrawRect ;

::bbox2 | --
	hp 1 >> dup 'dp 4 + d+! 'dp 12 + d!
	SDLRenderer 'dp SDL_RenderDrawRect 
	hp dup 1 >> neg 'dp 4 + d+! 'dp 12 + d!
	;
	
#rec 0 0
::bfillline | x y w h --
	hp * 32 << swap wp * or 
	rot wp * rot hp * 32 << or 
	'rec !+ !
	SDLRenderer 'rec SDL_RenderFillRect ;

::bsrcsize | x y w h -- x y w h
	2swap hp * swap wp * swap 
	2swap hp * swap wp * swap ;
	
	
::bfillemit | "" -- ""
	count wp *
	hp 32 << or
	dp 'rec !+ !
	SDLRenderer 'rec SDL_RenderFillRect ;

::bemit | ascii --
	dup $f and wp * swap 4 >> $f and hp * 32 << or 'op !
	SDLrenderer pfont 'op 'dp SDL_RenderCopy
	wp 'dp d+! ;
	
::bprint
	sprint
::bemits | "" --
	( c@+ 1? bemit ) 2drop ;

|----- double w
:bemitb	
	dup $f and wp * swap 4 >> $f and hp * 32 << or 'op !
	SDLrenderer pfont 'op 'dp SDL_RenderCopy
	wp 1 << 'dp d+! ;

::bprintd
	sprint
::bemitsd | "" --
	wp 1 << hp 32 << or 'dp 8 + !
	( c@+ 1? bemitb ) 2drop 
	wp hp 32 << or 'dp 8 + !
	;

|----- double w h
::bprint2
	sprint
::bemits2 | "" --
	wp 1 << hp 33 << or 'dp 8 + !
	( c@+ 1? bemitb ) 2drop 
	wp hp 32 << or 'dp 8 + ! ;

|------- sized
#advx

:bemitz
	dup $f and wp * swap 4 >> $f and hp * 32 << or 'op !
	SDLrenderer pfont 'op 'dp SDL_RenderCopy
	advx 'dp d+! ;
	
::bprintz | .. "" size --
	>r sprint r>
::bemitsz | "" size --
	wp over 16 *>> dup 'advx ! hp rot 16 *>>
	32 << or 'dp 8 + !
	( c@+ 1? bemitz ) 2drop 
	wp hp 32 << or 'dp 8 + ! 
	;

	
::bat | x y --
	32 << or 'dp ! ;	

::ccx dp $ffffffff and ;
::ccy dp 32 >> ;

::gotoxy | x y --
	hp * swap wp * swap bat ;
::gotox | x --
	wp * 'dp d! ;
::bcr
	0 'dp d!
	hp 'dp 4 + d+! ;
::bsp
	wp 'dp d+! ;
::bnsp | n --
	wp * 'dp d+! ;
	
::bsize | "" -- "" w h
	count wp * hp ;
 
::bpos | -- x y
	dp dup $ffffff and swap 32 >> ;

::brect |  "" -- "" x y w h
	bsize bpos 2swap ;
	
::bcursor | n --
	wp * bpos swap rot + swap wp hp SDLFRect ;

::bcursori | n --
	wp * bpos swap rot + swap hp dup 2 >> - + wp hp 2 >> SDLFRect ;

::bfont1	
	8 16 "media/img/VGA8x16.png" bmfont	;	
	
::bfont2
	16 24 "media/img/font16x24.png" bmfont ;
