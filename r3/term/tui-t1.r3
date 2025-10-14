| TUI 
| PHREDA 2025
^./tui.r3
^./tuiedit.r3

#pad * 256

:botones
	tuwin $1 " Options " .wtitle
	1 1 flpad |1 b.hgrid
	5 'fh ! 'exit "Salir" tuBtn | 'ev "" --
	1 'fy +! 'exit "Coso" tuBtn | 'ev "" --
	;
	
:side
	|-----------
	.reset
	3 flxS 1 0 flpad 
	tuWin $1 " Command " .wtitle
	2 1 flpad
	'pad fw 2 - tuInputLine
	tuX? 1? ( 0 'pad ! tuRefocus ) drop	
	|-----------
	cols 2 >> flxE tuWin
	botones
	;
	
:main
	.reset .cls 
	|-----------
	1 flxN
	fx fy .at 
	.rever .eline
	" R3forth" .write

	|-----------
	1 flxS
	fx fy .at .eline " |ESC| Exit " .write
	
	|-----------
	.reset
	flxFill tuWin 
|	$1 " Editor " .wtitle
	$4 'filename .wtitle
	1 1 flpad 
	tuEditCode
	;
	
|-----------------------------------
: 
	"main.r3" TuLoadCode
	'main onTui 
	.free 
;
