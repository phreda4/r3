| TUI 
| PHREDA 2025
^r3/term/tui.r3
^r3/term/tuiedit.r3

#filename * 1024
#screenstate 
#pad * 256

#outpad * 1024
#linecomm 	| comentarios de linea
#linecomm>
#cerror
#lerror

|----------------------------------
:loadinfo
	linecomm "mem/infomap.db" load 
	0 $fff rot !+ !+ 'linecomm> ! ;
	
:clearinfo
	linecomm 8 +
	0 $fff rot !+ !+ 'linecomm> ! ;

:linetocursor | -- ines
	0 fuente ( fuente> <? c@+
		13 =? ( rot 1+ -rot ) drop ) drop ;
		
:r3info
|WIN|	"r3 r3/d4/r3info.r3"
|LIN|	"./r3lin r3/d4/r3info.r3"
|RPI|	"./r3rpi r3/d4/r3info.r3"
	sys

	0 'cerror !
	mark
|... load file info.
	here "mem/debuginfo.db" load 0 swap c!
	here >>cr trim str>nro 'cerror ! drop
	empty

	loadinfo
	cerror 0? ( drop ; ) drop
|... enter error mode
	fuente cerror + 'fuente> !
	linetocursor 'lerror !
	here >>cr 0 swap c!
	fuente> lerror 1+ here
	" %s in line %d (%w)" sprint 'outpad strcpy
	
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
	flxFill |tuWin 
|	$1 " Editor " .wtitle
	|$4 'filename .wtitle
	|$23 mark tudebug ,s ,eol empty here .wtitle
	|0 1 flpad 
	tuEditCode
	
	uiKey
|	[f1] =? ( show256 )
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
