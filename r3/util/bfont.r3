| bfont.r3
| fuentes de ancho fijo 
| PHREDA 2021
|-----------------------------
^r3/win/sdl2image.r3

#pfont 
#wp #hp
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
	
::bemit | ascii --
	dup $f and wp * swap 4 >> $f and hp * 32 << or 'op !
	SDLrenderer pfont 'op 'dp SDL_RenderCopy
	wp 'dp d+!
	;
	
::bprint | "" --
	( c@+ 1? bemit ) 2drop ;
	
::bat | x y --
	32 << or 'dp ! ;	
	
::bsize | "" -- "" w h
	count wp * hp ;
	
::bpos | -- x y
	dp dup $ffffff and swap 32 >> ;
	
::bcursor | n --
	wp * bpos swap rot + swap wp hp FRect ;

::bcursori | n --
	wp * bpos swap rot + swap hp dup 2 >> - + wp hp 2 >> FRect ;

::bfont1	
	8 16 "media/img/VGA8x16.png" bmfont	;	
	
::bfont2
	16 24 "media/img/font16x24.png" bmfont ;
