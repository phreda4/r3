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
##advx ##advy

#op 0 0
#dp 0 0

::trgb | c --
	pfont swap 
	dup 16 >> $ff and over 8 >> $ff and rot $ff and
	SDL_SetTextureColorMod ;
	
::tpal | c -- rgb
	$f and 2 << termcolor + d@ ;
	
::tcol | c --
	tpal trgb ;
	
::tfbox | --
	SDLRenderer 'dp SDL_RenderFillRect ;

::tbox | --
	SDLRenderer 'dp SDL_RenderDrawRect ;

::temit | ascii --
	dup $f and wp * swap 4 >> $f and hp * 32 << or 'op !
	SDLrenderer pfont 'op 'dp SDL_RenderCopy
	advx 'dp d+! ;
	
::tprint
	sprint
::temits | "" --
	( c@+ 1? temit ) 2drop ;
	
::tat | x y --
	swap $ffffffff and swap 32 << or 'dp ! ;	
::tatx | x --
	'dp d! ;
	
::txy | x y --
	advy * swap advx * swap tat ;
::tx | x --
	advx * 'dp d! ;

::tcx dp 32 << 32 >> ;
::tcy dp 32 >> ;
	
::tcr
	0 'dp d!
	advy 'dp 4 + d+! ;

::tsp
	advx 'dp d+! ;
::tnsp | n --
	advx * 'dp d+! ;
	
::tsbox | "" -- "" w h
	count advx * advy ;
 
::tpos | -- x y
	dp dup $ffffff and swap 32 >> ;

::trect |  "" -- "" x y w h
	tsbox tpos 2swap ;
	
::tcursor | n --
	advx * tpos swap rot + swap advx advy SDLFRect ;

::tcursori | n --
	advx * tpos swap rot + swap advy dup 2 >> - + advx advy 2 >> SDLFRect ;

::tsize | zoom --
	wp over 16 *>> dup 'advx ! 
	hp rot 16 *>> dup 'advy !
	32 << or 'dp 8 + ! ;
	
::tsrcsize | x y w h -- x y w h
	2swap advy * swap advx * swap 
	2swap advy * swap advx * swap ;	

|---------- INI
::tfnt | size w h ""
	loadimg 
|	dup 0 SDL_SetTextureBlendMode 
|	dup 1 SDL_SetTextureScaleMode
	'pfont !
	2dup 32 << or 'op 8 + !
	'hp ! 'wp ! 
	tsize ;
	
::tini
	1.0
	|16 24 "media/img/font16x24.png" 
 	8 16 "media/img/VGA8x16.png" 
	|8 8 "media/img/atascii.png" 
	tfnt ;	