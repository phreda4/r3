| bfont.r3
| fuentes de ancho fijo 
| PHREDA 2021
|-----------------------------
^r3/lib/sdl2gfx.r3
^r3/lib/sdl2image.r3

#pfont 
##wp | width of a character in pixels
##hp | height of a character in pixels
#op 0 0
#dp 0 0

::bmfont | w h "file" -- ; load the font image (a 16x16 grid of 256 characters of w x h pixels: column = low nibble, row = high nibble of the ASCII code) and set the character size
	loadimg 'pfont !
	2dup 32 << or dup
	'dp 8 + ! 'op 8 + !
	'hp ! 'wp ! 
	;
	
::bcolor | rgb -- ; color $RRGGBB of the font texture (color modulation)
	pfont swap
	dup 16 >> $ff and over 8 >> $ff and rot $ff and
	SDL_SetTextureColorMod
	;
	
::bfbox | -- ; fill the character cell at the cursor with the draw color
	SDLRenderer 'dp SDL_RenderFillRect ;

::bbox | -- ; outline of the character cell at the cursor
	SDLRenderer 'dp SDL_RenderDrawRect ;

::bbox2 | -- ; outline of the lower half of the character cell at the cursor
	hp 1 >> dup 'dp 4 + d+! 'dp 12 + d!
	SDLRenderer 'dp SDL_RenderDrawRect 
	hp dup 1 >> neg 'dp 4 + d+! 'dp 12 + d!
	;
	
#rec 0 0
::bfillline | x y w h -- ; fill with the draw color the rectangle given in character cells (x y w h)
	hp * 32 << swap wp * or 
	rot wp * rot hp * 32 << or 
	'rec !+ !
	SDLRenderer 'rec SDL_RenderFillRect ;

::bsrcsize | x y w h -- x y w h ; convert the two pairs from character cells to pixels (x*wp y*hp w*wp h*hp)
	2swap hp * swap wp * swap 
	2swap hp * swap wp * swap ;
	
	
::bfillemit | "" -- "" ; fill with the draw color the area the string would use at the cursor
	count wp *
	hp 32 << or
	dp 'rec !+ !
	SDLRenderer 'rec SDL_RenderFillRect ;

::bfcemit | cnt -- ; fill with the draw color the area of cnt characters at the cursor
	wp * hp 32 << or
	dp 'rec !+ !
	SDLRenderer 'rec SDL_RenderFillRect ;

::bemit | ascii -- ; draw the character at the cursor and move the cursor one character to the right
	dup $f and wp * swap 4 >> $f and hp * 32 << or 'op !
	SDLrenderer pfont 'op 'dp SDL_RenderCopy
	wp 'dp d+! ;
	
::bprint | .. "" -- ; formatted print (see sprint) at the cursor
	sprint
::bemits | "" -- ; print the string at the cursor
	( c@+ 1? bemit ) 2drop ;

|----- double w
:bemitb	
	dup $f and wp * swap 4 >> $f and hp * 32 << or 'op !
	SDLrenderer pfont 'op 'dp SDL_RenderCopy
	wp 1 << 'dp d+! ;

::bprintd | .. "" -- ; formatted print with double width
	sprint
::bemitsd | "" -- ; print the string with double width
	wp 1 << hp 32 << or 'dp 8 + !
	( c@+ 1? bemitb ) 2drop 
	wp hp 32 << or 'dp 8 + !
	;

|----- double w h
::bprint2 | .. "" -- ; formatted print with double width and height
	sprint
::bemits2 | "" -- ; print the string with double width and height
	wp 1 << hp 33 << or 'dp 8 + !
	( c@+ 1? bemitb ) 2drop 
	wp hp 32 << or 'dp 8 + ! ;

|------- sized
#advx

:bemitz
	dup $f and wp * swap 4 >> $f and hp * 32 << or 'op !
	SDLrenderer pfont 'op 'dp SDL_RenderCopy
	advx 'dp d+! ;
	
::bprintz | .. "" size -- ; formatted print scaled by size (fixed point, 1.0 = normal)
	>r sprint r>
::bemitsz | "" size -- ; print the string scaled by size (fixed point, 1.0 = normal)
	wp over 16 *>> dup 'advx ! hp rot 16 *>>
	32 << or 'dp 8 + !
	( c@+ 1? bemitz ) 2drop 
	wp hp 32 << or 'dp 8 + ! 
	;

	
::bat | x y -- ; move the cursor to the pixel position x y
	swap $ffffffff and swap 32 << or 'dp ! ;	

::ccx | -- x ; cursor x in pixels (also defined in pcfont)
	dp 32 << 32 >> ;
::ccy | -- y ; cursor y in pixels (also defined in pcfont)
	dp 32 >> ;

::gotoxy | x y -- ; move the cursor to the character cell x y (also defined in pcfont)
	hp * swap wp * swap bat ;
::gotox | x -- ; move the cursor to the character column x, same y (also defined in pcfont)
	wp * 'dp d! ;
	
::bcr | -- ; new line: x = 0 and y down one character
	0 'dp d!
	hp 'dp 4 + d+! ;
::bcr2 | -- ; new line for double height text (y down two characters)
	0 'dp d!
	hp 2* 'dp 4 + d+! ;
::bcrz | size -- ; new line for text scaled by size (fixed point)
	0 'dp d!
	hp 16 *>> 'dp 4 + d+! ;


::bsp | -- ; move the cursor one character to the right
	wp 'dp d+! ;
::bnsp | n -- ; move the cursor n characters to the right
	wp * 'dp d+! ;
	
::bsize | "" -- "" w h ; size in pixels of the string (count * wp, hp)
	count wp * hp ;
 
::bpos | -- x y ; cursor position in pixels
	dp dup $ffffff and swap 32 >> ;

::brect | "" -- "" x y w h ; rectangle (position and size in pixels) of the string at the cursor
	bsize bpos 2swap ;
	
::bcursor | n -- ; fill with the draw color the character cell n characters to the right of the cursor (block cursor)
	wp * bpos swap rot + swap wp hp frect ;

::bcursori | n -- ; like bcursor but a bar of a quarter of the height at the bottom (insert cursor)
	wp * bpos swap rot + swap hp dup 2 >> - + wp hp 2 >> frect ;

::bcursor2 | n -- ; like bcursor for double size characters
	wp 2* * bpos swap rot + swap wp 2* hp 2* frect ;

::bcursori2 | n -- ; like bcursori for double size characters
	wp 2* * bpos swap rot + swap hp dup 2/ + + wp 2* hp 2/ frect ;
	

::bfont1 | -- ; load the font media/img/VGA8x16.png (8x16 characters)
	8 16 "media/img/VGA8x16.png" bmfont	;	
	
::bfont2 | -- ; load the font media/img/font16x24.png (16x24 characters)
	16 24 "media/img/font16x24.png" bmfont ;
