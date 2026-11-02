| pcfont.r3
| fuente de ancho fijo PC
| PHREDA 2024
|-----------------------------
^r3/lib/sdl2gfx.r3
^r3/lib/sdl2image.r3

#pfont 
#op 0 0
#dp 0 0
#ws 3 #hs 4
	
::pccolor | rgb -- ; color $RRGGBB of the font texture (color modulation)
	pfont swap
	dup 16 >> $ff and over 8 >> $ff and rot $ff and
	SDL_SetTextureColorMod
	;
	
::pcemit | ascii -- ; draw the character (8x16) at the cursor and move the cursor one character to the right
	dup $f and ws << swap 4 >> $f and hs 32 + << or 'op !
	SDLrenderer pfont 'op 'dp SDL_RenderCopy
	8 'dp d+!
	;

::pcfbox | -- ; fill the character cell at the cursor with the draw color
	SDLRenderer 'dp SDL_RenderFillRect ;

::pcbox | -- ; outline of the character cell at the cursor
	SDLRenderer 'dp SDL_RenderDrawRect ;

::pcbox2 | -- ; outline of the lower half of the character cell at the cursor
	16 1 >> dup 'dp 4 + d+! 'dp 12 + d!
	SDLRenderer 'dp SDL_RenderDrawRect 
	16 dup 1 >> neg 'dp 4 + d+! 'dp 12 + d!
	;
	
#rec 0 0
::pcfillline | x y w h -- ; fill with the draw color the rectangle given in character cells (x y w h)
	hs << 32 << swap ws << or 
	rot ws << rot hs << 32 << or 
	'rec !+ !
	SDLRenderer 'rec SDL_RenderFillRect ;

::pcsrcsize | x y w h -- x y w h ; convert the two pairs from character cells to pixels (x*8 y*16 w*8 h*16)
	2swap hs << swap ws << swap 
	2swap hs << swap ws << swap ;
	
	
::pcfillemit | "" -- "" ; fill with the draw color the area the string would use at the cursor
	count ws <<
	16 32 << or
	dp 'rec !+ !
	SDLRenderer 'rec SDL_RenderFillRect ;
	
::pcprint | .. "" -- ; formatted print (see sprint) at the cursor
	sprint
::pcemits | "" -- ; print the string at the cursor
	( c@+ 1? pcemit ) 2drop ;

|----- double w
:pcemitb	
	dup $f and ws << swap 4 >> $f and hs 32 + << or 'op !
	SDLrenderer pfont 'op 'dp SDL_RenderCopy
	16 'dp d+! ;
	
::pcprintd | .. "" -- ; formatted print with double width
	sprint
::pcemitsd | "" -- ; print the string with double width
	$1000000010 'dp 8 + ! 
	( c@+ 1? pcemitb ) 2drop 
	$1000000008 'dp 8 + ! ;

|----- double w h
::pcprint2 | .. "" -- ; formatted print with double width and height
	sprint
::pcemits2 | "" -- ; print the string with double width and height
	$2000000010 'dp 8 + ! 
	( c@+ 1? pcemitb ) 2drop 
	$1000000008 'dp 8 + ! ;

|------- sized
#advx

:pcemitz
	dup $f and ws << swap 4 >> $f and hs 32 + << or 'op !
	SDLrenderer pfont 'op 'dp SDL_RenderCopy
	advx 'dp d+! ;
	
::pcprintz | .. "" size -- ; formatted print scaled by size (fixed point, 1.0 = normal)
	>r sprint r>
::pcemitsz | "" size -- ; print the string scaled by size (fixed point, 1.0 = normal)
	8 over 16 *>> dup 'advx ! 16 rot 16 *>>
	32 << or 'dp 8 + !
	( c@+ 1? pcemitz ) 2drop 
	$1000000008 'dp 8 + ! ;
	
	
::pcat | x y -- ; move the cursor to the pixel position x y
	32 << or 'dp ! ;	

::ccx | -- x ; cursor x in pixels (also defined in bfont)
	dp $ffffffff and ;
::ccy | -- y ; cursor y in pixels (also defined in bfont)
	dp 32 >> ;

::gotoxy | x y -- ; move the cursor to the character cell x y (also defined in bfont)
	hs << swap ws << swap pcat ;
::gotox | x -- ; move the cursor to the character column x, same y (also defined in bfont)
	ws << 'dp d! ;
::pccr | -- ; new line: x = 0 and y down 16 pixels
	0 'dp d!
	16 'dp 4 + d+! ;
::pcsp | -- ; move the cursor one character (8 pixels) to the right
	8 'dp d+! ;
::pcnsp | n -- ; move the cursor n characters to the right
	ws << 'dp d+! ;
	
::pcsize | "" -- "" w h ; size in pixels of the string (count * 8, 16)
	count ws << 16 ;
 
::pcpos | -- x y ; cursor position in pixels
	dp dup $ffffff and swap 32 >> ;

::pcrect | "" -- "" x y w h ; rectangle (position and size in pixels) of the string at the cursor
	pcsize pcpos 2swap ;
	
::pccursor | n -- ; fill with the draw color the character cell n characters to the right of the cursor (block cursor)
	ws << pcpos swap rot + swap 8 16 frect ;

::pccursori | n -- ; like pccursor but a bar of a quarter of the height at the bottom (insert cursor)
	ws << pcpos swap rot + swap 16 dup 2 >> - + 8 16 2 >> frect ;

::pcfont | -- ; load the font media/img/VGA8x16.png (8x16 characters in a 16x16 grid) and set the cursor size
	"media/img/VGA8x16.png" 
	loadimg 'pfont !
	$1000000008
	|8 16 32 << or 
	dup 'dp 8 + ! 'op 8 + !
	| 16 'hp ! 8 'wp ! 
	;	
	
