| r3help
| PHREDA 20225

^r3/util/tui.r3
^r3/d4/meta/mlibs.r3

#padcom * 256

#lstwords
#txtmanual

#inc> 'liblist

:includes
	0 0 .at
	'liblist ( @+ 1? 
		@ .write .cr
		) 2drop 
	0 0 .at
	inc> @ 8 + @
	( dup c@ 1? drop
		dup .write .cr 
		>>0
		) 2drop ;

:main
	.bblack .cls
	|___________
	4 flxN
	fx fy .at "[01R[023[03f[04o[05r[06t[07h [08Help" .awrite 
	|.tdebug |2dup " %d %d " .print
	|___________
	.reset
	4 flxN
	tuWin $1 "Help" .wtitle
	1 1 flpad
	'padcom fw tuInputLine
	|___________	
	cols 2/ flxO
		flxpush
		rows 2/ flxN
		tuWin $1 "Words" .wtitle
		1 1 flpad
		flxRest
		tuWin $1 "Includes" .wtitle
		1 1 flpad
		flxpop
	flxRest
	tuwin $1 "Manual" .wtitle
	1 1 flpad 
	
	uikey
	[esc] =? ( exit )
	[dn] =? ( 8 'inc> +! )
	[up] =? ( -8 'inc> +! )
	drop
	;

|-----
: .alsb  
	'main onTui 
	.masb .free ;

