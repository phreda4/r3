| TUI IDE
| PHREDA 2025
^r3/util/tui.r3
^r3/util/tuiedit.r3

^r3/d4/r3token.r3

#filename * 1024

#screenstate 
| 0 - editor only
| $1 - msg error
| $2 - debug
| $100 - list

#msg * 1024

:coderror | error --
	'msg strcpy
	lerror 'fuente> !

	1 'screenstate !
	;
	
:codeok
	"Code OK%.fullinfo" 'msg strcpy
	2 'screenstate !
	;
	
|---  F1 RUN
:checkcode
	0 'screenstate !
	fuente 'filename r3loadmem
	
	error 1? ( coderror ; ) drop 
	codeok 
	;
	
|--- F2 DEBUG
:debugcode
	0 'screenstate !
	fuente 'filename r3loadmem
	
	error 1? ( coderror ; ) drop
	codeok
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
	
:screrr
	.7 .fc 1 .bc
	2 flxS
	|242 .bc
	.wfill |.bordec
	fx 1+ fy .at |fw .hline
	'msg .print
	;

:scrmsg	
	.reset
	8 flxS
	|242 .bc
	|.wfill |.wborde
	|fx fy .at fw .hline
	'msg .print
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
	|tudebug .write
	here "%h" .print
	

	|-----------
	screenstate	
	$1 and? ( screrr )
	$2 and? ( scrmsg )
	$4 and? ( scrmapa )
	drop
	
|	1 flxS
|	4 .bc  7 .fc fx fy .at fw .nsp fx .col 
| |ESC| Exit |F1| Run |F2| Debug |F3| Explore |F4| Profile |F5| Compile" .write

	
	
	|-----------
	.reset
	flxRest  tuWin 
	$4 'filename .wtitle
	$23 mark tudebug ,s ,eol empty here .wtitle
	1 1 flpad 
	tuEditCode
	
	
	uiKey
	[f1] =? ( checkcode ) |show256 )
	[f2] =? ( debugcode ) |show256 )
	
|	[f6] =? ( screenstate 1 xor 'screenstate ! )
|	[f7] =? ( screenstate 2 xor 'screenstate ! )
	drop
	;
	
|-----------------------------------
: 
	.alsb 
	|'filename "mem/menu.mem" load	
	"r3/test/testasm.r3" 'filename strcpy
	
	'filename TuLoadCode
	|TuNewCode
	
	mark
	
	'main onTui 
	.masb .free 
;
