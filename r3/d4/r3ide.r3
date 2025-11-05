| TUI IDE
| PHREDA 2025
^r3/util/tui.r3
^r3/util/tuiedit.r3
^r3/lib/trace.r3

^r3/d4/r3token.r3

#filename * 1024

#screenstate 
| 0 - editor only
| $1 - msg error
| $2 - debug
| $100 - list

#msg * 1024

#vwords 0 0
#vincs 0 0

#lwords
#lincs

:coderror | error --
	'msg strcpy
	lerror 'fuente> !

	1 'screenstate !
	;

|-------	
:makelistwordsfull
	here 'lwords !
	0 ( cntdef <?
		dup nro>dic 
		@ dic>name "%w" ,print ,eol 
		1+ ) drop 
	,eol ;
	
|---- list words
:makelistwords
	here 'lwords !
	0 ( cntdef <?
		dup .h ,s ,eol
		|nro>dic @ dic>name "%w" ,print ,eol 
		1+ ) drop 
	,eol ;

:chooseword
	dup dic - 4 >> .h ,s ,eol ;
	
:makelistwords
	here 'lwords !
	dic< ( dic> <? | solo codigo principal
		chooseword
		16 + ) drop
	,eol ;

:wcolor
	1 and? ( 201 .fc ; ) 196 .fc ;
	
:xwrite.word | str --
	mark
	str$>nro nip
	nro>dic @ wcolor
	dic>name "%w" ,print ,eol 
	empty
	here lwrite ;
	
|---- list inc	
:makelistinc
	here 'lincs !
	0 ( cntinc <? 
		dup 4 << 'inc + @ "%w" ,print ,eol
		1+ ) drop
	,eol ;
	
	
:codeok
	mark
	'msg 'here !
	cnttok cntdef cntinc "inc:%d words:%d tokens:%d" ,print
	,eol
	empty
	
	4 'screenstate !
	makelistwords
	makelistinc
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
	30 flxE 
	flxpush
	
	10 flxN
	tuWina $4 "Includes" .wtitle 1 1 flpad 
	'vincs lincs tuList
	
	flxRest
	tuWina $4 "Dicc" .wtitle 1 1 flpad 
	
	'xwrite.word xwrite!
	'vwords lwords tuList | 'var list --
	xwrite.reset
	flxpop
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
	
:debugcode
	;
	
:editcode
	.reset .cls 
	1 flxN
	
	4 .bc  7 .fc
	|.rever 
	|.eline
	fx fy .at fw .nsp fx .col
	" R3forth EDIT [" .write
	'filename .write 
	"] " .write
	|tudebug .write

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
	flxRest tuWina 
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
	
:main
	editcode
	;
|-----------------------------------
: 
	.alsb 
	'filename "mem/menu.mem" load	
	|"r3/test/testasm.r3" 'filename strcpy
	
	'filename TuLoadCode
	|TuNewCode
	
	mark
	
	'main onTui 
	.masb .free 
;
