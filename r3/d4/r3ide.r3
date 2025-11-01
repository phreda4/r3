| TUI IDE
| PHREDA 2025
^r3/util/tui.r3
^r3/util/tuiedit.r3

#filename * 1024
#screenstate 
#pad * 256

|--- term color
#bx #by

:nextl	1 'by +! bx by .at ;
:nextc	-6 'by +! 20 'bx +! bx by .at ;
	
:boxcr
	dup 16 - 6 mod
	0? ( nextl ) drop 
	dup 16 - 36 mod
	0? ( 15 .fc nextc )
	18 =? ( 0 .fc )
	drop
	;
	
|------- 256 Color Palette 
:show256 | --
    .cls
    0 ( 16 <?
		0 =? ( 15 .fc ) 1 =? ( 0 .fc )
        dup .bc dup .d 3 .r. .write .sp
        1+ ) drop 
	8 'by !
	-18  'bx !
	16 ( 232 <?
		boxcr
		124 =? ( 2 'bx ! 10 'by ! bx by .at )
        dup .bc dup .d 3 .r. .write .sp	
		1+ ) drop
    .cr .cr
	15 .fc 4 .col
    232 ( 256 <?
		244 =? ( 0 .fc .cr 4 .col )
        dup .bc 
		dup .d 4 .r. .write .sp
		1+ ) drop 
	.flush 
	waitkey
	;

|---- screen
:scrmapa	
	.reset
	26 flxE 
	|240 .bc
	fx fy .at fh .vline
	|.wfill |.wborde
	|tuWin $1 " Map " .wtitle
	0 1 flpad
	;
	
:scrcons	
	.reset
	8 flxS 
	|242 .bc
	.wfill |.wborde
	fx fy .at fw .hline
	;
	
:main
	.reset .cls 
	1 1 flpad
	|-----------
	1 flxN
	
	4 .bc  7 .fc
	|.rever 
	|.eline
	fx fy .at fw .nsp fx .col
	" R3forth [" .write
	'filename .write 
	"] " .write
	tudebug .write

	|-----------
	screenstate	
	$1 and? ( scrcons )
	$2 and? ( scrmapa )
	drop
	
	1 flxS
	4 .bc  7 .fc
	fx fy .at fw .nsp fx .col
	|.eline 
	" |ESC| Exit |F1| Run |F2| Debug " .write ||F3| Explore |F4| Profile |F5| Compile" .write

	
	
	|-----------
	.reset
	flxRest |tuWin 
|	$1 " Editor " .wtitle
	|$4 'filename .wtitle
	|$23 mark tudebug ,s ,eol empty here .wtitle
	|0 1 flpad 
	tuEditCode
	
	
	uiKey
	[f1] =? ( show256 )
	[f6] =? ( screenstate 1 xor 'screenstate ! )
	[f7] =? ( screenstate 2 xor 'screenstate ! )
	drop
	;
	
|-----------------------------------
: 
	.alsb 
	'filename "mem/menu.mem" load	
	'filename TuLoadCode
	|TuNewCode

	'main onTui 
	.masb .free 
;
