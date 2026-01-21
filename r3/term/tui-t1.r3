| TUI 
| PHREDA 2025
^r3/util/tui.r3
^r3/util/tuiedit.r3

#pad * 256

#bx #by

:nextl
	1 'by +!
	bx by .at ;
	
:nextc
	-6 'by +!
	20 'bx +!
	bx by .at ;
	
:boxcr
	dup 16 - 6 mod
	0? ( nextl ) drop 
	dup 16 - 36 mod
	0? ( 15 .fc nextc )
	18 =? ( 0 .fc )
	drop
	;
	
|------- Page 3: 256 Color Palette -------
:show256 | --
    .cls
    0 ( 16 <?
		0 =? ( 15 .fc )
		1 =? ( 0 .fc )
        dup .bc 
		dup .d 3 .r. .write .sp
        1+ ) drop 
	
	8 'by !
	-18  'bx !
	16 ( 232 <?
		boxcr
		124 =? ( 2 'bx ! 10 'by ! bx by .at )
        dup .bc 
		dup .d 3 .r. .write .sp	
		1+ ) drop
	
    .cr .cr
	15 .fc 4 .col
    232 ( 256 <?
		244 =? ( 0 .fc .cr 4 .col )
        dup .bc 
		dup .d 4 .r. .write .sp
		1+ ) drop 
	.cr
	
	.flush 
	waitkey
	;
	
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
	.reset .home |.cls 
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
	flxRest tuWin 
|	$1 " Editor " .wtitle
	$4 'filename .wtitle
	$23 mark tudebug ,s ,eol empty here .wtitle
	1 1 flpad 
	tuEditCode
	uiKey
	[f1] =? ( show256 )
	drop
	;
	
|-----------------------------------
: 
	.alsb 
	
	"main.r3" TuLoadCode
	|TuNewCode

	'main onTui 
	.masb .free 
;
