| fuentes de ancho fijo 
| consola
| PHREDA 2025
|-----------------------------
^r3/lib/sdl2gfx.r3
^r3/lib/sdl2image.r3

#termcolor 
$0C0C0C | 0 black
$0037DA | 1 blue
$3A96DD | 2 cyan
$13A10E | 3 green
$881798 | 4 purple
$C50F1F | 5 red
$CCCCCC | 6 white
$C19C00 | 7 yellow
$767676 | 8 brightBlack
$3B78FF | 9 brightBlue
$61D6D6 | a brightCyan
$16C60C | b brightGreen
$B4009E | c brightPurple
$E74856 | d brightRed
$F2F2F2 | e brightWhite
$F9F1A5 | f brightYellow

#pfont 

#wp #hp
#advx #advy

#op 0 0
#dp 0 0

::trgb | c --
	dup 16 >> $ff and over 8 >> $ff and rot $ff and
	SDL_SetTextureColorMod ;
	
::tcol | c --
	pfont swap $f and 3 << 'termcolor + @ trgb ;
	
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
