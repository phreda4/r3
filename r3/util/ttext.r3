| fuentes de ancho fijo 
| consola
| PHREDA 2025
|-----------------------------
^r3/lib/sdl2gfx.r3
^r3/lib/sdl2image.r3

#style0 [ | campbell
$0C0C0C $0037DA $3A96DD $13A10E | 0 black | 1 blue | 2 cyan | 3 green
$881798 $C50F1F $CCCCCC $C19C00 | 4 purple | 5 red | 6 white | 7 yellow
$767676 $3B78FF $61D6D6 $16C60C | 8 brBlack | 9 brBlue | a brCyan | b brGreen
$B4009E $E74856 $F2F2F2 $F9F1A5  ] | c brPurple | d brRed | e brWhite | f brYellow

#style1 [ | one-half-dark
$282c34 $e06c75 $98c379 $e5c07b
$61afef $c678dd $56b6c2 $dcdfe4
$282c34 $e06c75 $98c379 $e5c07b
$61afef $c678dd $56b6c2 $dcdfe4 ]

#style2 [ | uchu
$080a0d $0949ac $b56227 $2e943a
$542690 $a30d30 $fdfdfd $b59944
$878a8b $3984f2 $ff9f5b $64d970
$915ad3 $ea3c65 $cbcdcd $fedf7b ]

#termcolor 'style0
#pfont

#wp #hp
##advx | width in pixels of a character cell (font width times zoom)
##advy | height in pixels of a character cell

#op 0 0
#dp 0 0

::trgb | c -- ; color $RRGGBB of the font texture (color modulation)
	pfont swap 
	dup 16 >> $ff and over 8 >> $ff and rot $ff and
	SDL_SetTextureColorMod ;
	
::tpal | c -- rgb ; color of the palette entry c (low 4 bits: 0 black, 1 blue, 2 cyan, 3 green, 4 purple, 5 red, 6 white, 7 yellow, 8..15 the bright ones) of the style in termcolor (style0 Campbell)
	$f and 2 << termcolor + d@ ;
	
::tcol | c -- ; set the text color from the palette entry c
	tpal trgb ;
	
::tfbox | -- ; fill the character cell at the cursor with the draw color
	SDLRenderer 'dp SDL_RenderFillRect ;

::tbox | -- ; outline of the character cell at the cursor
	SDLRenderer 'dp SDL_RenderDrawRect ;

::temit | ascii -- ; draw the character at the cursor and move the cursor one character to the right
	dup $f and wp * swap 4 >> $f and hp * 32 << or 'op !
	SDLrenderer pfont 'op 'dp SDL_RenderCopy
	advx 'dp d+! ;
	
::tprint | .. "" -- ; formatted print (see sprint) at the cursor
	sprint
::temits | "" -- ; print the string at the cursor
	( c@+ 1? temit ) 2drop ;
	
::tat | x y -- ; move the cursor to the pixel position x y
	swap $ffffffff and swap 32 << or 'dp ! ;	
::tatx | x -- ; set the cursor x in pixels
	'dp d! ;
	
::txy | x y -- ; move the cursor to the character cell x y
	advy * swap advx * swap tat ;
::tx | x -- ; move the cursor to the character column x
	advx * 'dp d! ;

::tcx | -- x ; cursor x in pixels
	dp 32 << 32 >> ;
::tcy | -- y ; cursor y in pixels
	dp 32 >> ;
	
::tcr | -- ; new line: x = 0 and y down one character
	0 'dp d!
	advy 'dp 4 + d+! ;

::tsp | -- ; move the cursor one character to the right
	advx 'dp d+! ;
::tnsp | n -- ; move the cursor n characters to the right
	advx * 'dp d+! ;
	
::tsbox | "" -- "" w h ; size in pixels of the string (count * advx, advy)
	count advx * advy ;
 
::tpos | -- x y ; cursor position in pixels
	dp dup $ffffff and swap 32 >> ;

::trect | "" -- "" x y w h ; rectangle (position and size in pixels) of the string at the cursor
	tsbox tpos 2swap ;
	
::tcursor | n -- ; fill with the draw color the character cell n characters to the right of the cursor (block cursor)
	advx * tpos swap rot + swap advx advy frect ;

::tcursori | n -- ; like tcursor but a bar of a quarter of the height at the bottom (insert cursor)
	advx * tpos swap rot + swap advy dup 2 >> - + advx advy 2 >> frect ;

::tsize | zoom -- ; set the character size as the font size times zoom (fixed point, 1.0 = normal)
	wp over 16 *>> dup 'advx ! 
	hp rot 16 *>> dup 'advy !
	32 << or 'dp 8 + ! ;
	
::tsrcsize | x y w h -- x y w h ; convert the two pairs from character cells to pixels
	2swap advy * swap advx * swap 
	2swap advy * swap advx * swap ;	

|---------- INI
::tfnt | size w h "file" -- ; load a font image (16x16 grid of characters of w x h pixels) and set its zoom size (fixed point)
	loadimg 
|	dup 0 SDL_SetTextureBlendMode 
|	dup 1 SDL_SetTextureScaleMode
	'pfont !
	2dup 32 << or 'op 8 + !
	'hp ! 'wp ! 
	tsize ;
	
::tini | -- ; load the default font media/img/VGA8x16.png (8x16) at size 1.0
	1.0
	|16 24 "media/img/font16x24.png" 
 	8 16 "media/img/VGA8x16.png" 
	|8 8 "media/img/atascii.png" 
	tfnt ;	