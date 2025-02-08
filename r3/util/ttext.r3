| fuentes de ancho fijo 
| consola
| PHREDA 2025
|-----------------------------
^r3/lib/sdl2gfx.r3
^r3/lib/sdl2image.r3

#style0 [
$0C0C0C $0037DA $3A96DD $13A10E | 0 black | 1 blue | 2 cyan | 3 green
$881798 $C50F1F $CCCCCC $C19C00 | 4 purple | 5 red | 6 white | 7 yellow
$767676 $3B78FF $61D6D6 $16C60C | 8 brightBlack | 9 brightBlue | a brightCyan | b brightGreen
$B4009E $E74856 $F2F2F2 $F9F1A5 | c brightPurple | d brightRed | e brightWhite | f brightYellow
]

#termcolor 'style0
#pfont 

#wp #hp
#advx #advy

#op 0 0
#dp 0 0

::trgb | c --
	pfont swap 
	dup 16 >> $ff and over 8 >> $ff and rot $ff and
	SDL_SetTextureColorMod ;
	
::tcol | c --
	$f and 2 << termcolor + d@ trgb ;
	
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
	
::tsize | "" -- "" w h
	count advx * advy ;
 
::tpos | -- x y
	dp dup $ffffff and swap 32 >> ;

::trect |  "" -- "" x y w h
	tsize tpos 2swap ;
	
::tcursor | n --
	wp * bpos swap rot + swap wp hp SDLFRect ;

::tcursori | n --
	wp * bpos swap rot + swap hp dup 2 >> - + wp hp 2 >> SDLFRect ;

::tsize | zoom --
	wp over 16 *>> dup 'advx ! 
	hp rot 16 *>> dup 'advy !
	32 << or 'dp 8 + ! ;

|---------- INI
::tini
 	8 16 "media/img/VGA8x16.png" 
	|16 24 "media/img/font16x24.png" 
	loadimg 'pfont !
	2dup 32 << or 'op 8 + !
	'hp ! 'wp ! 
	1.0 tsize ;	
