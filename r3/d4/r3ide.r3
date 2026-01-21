| TUI IDE
| PHREDA 2025
^r3/util/tui.r3
^r3/util/tuiedit.r3
^r3/lib/trace.r3

^r3/d4/r3token.r3

#filename * 1024

#mode 0
#screenstate 
| 0 - editor only
| $1 - msg error
| $2 - debug
| $100 - list

#msg * 1024
#errline
#errword * 64

#vwords 0 0
#vincs 0 0

#lwords
#lincs

:cntlines
	1 fuente 
	( lerror <?
		c@+ 13 =? ( rot 1+ -rot ) drop
		) drop 'errline ! ;
		
:coderror | error --
	'msg strcpy
	lerror "%w" sprint 'errword strcpy
	cntlines
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
	1 'mode !
	;
	
|--- F2 DEBUG
:debugcode
	0 'screenstate !
	fuente 'filename r3loadmem
	
	error 1? ( coderror ; ) drop
	codeok
	1 'mode !
	;
	
|--- F1 RUN in CHECK	
:runcheck
	.cls 
	"[01R[023[03f[04o[05r[06t[07h" .awrite .cr .cr .cr .cr .flush
	here dup "mem/errorm.mem" load
	over =? ( 2drop ; ) 
	0 swap c!
	.cr .bred .white " * ERROR * " .write .cr
	.reset .write .cr
	.bblue .white " Any key to continue... " .write .cr
	.flush 
	waitkey ;	
	
:runcode
	"mem/errorm.mem" delete
	'filename
|WIN| 	"cmd /c r3 ""%s"" 2>mem/errorm.mem"
|LIN| 	"./r3lin ""%s"" 2>mem/errorm.mem"
	sprint sys | run
	.reterm .alsb .flush
	runcheck
	tuR! ;
	
|---- screen
:scrmapa
	.reset
	30 flxE 
	flxpush
	
	8 flxN
	tuWina $1 "Includes" .wtitle 1 1 flpad 
	'vincs lincs tuList
	
	flxRest
	tuWina $1 "Dicc" .wtitle 1 1 flpad 
	
	'xwrite.word xwrite!
	'vwords lwords tuList | 'var list --
	xwrite.reset
	flxpop
	;
	

:scrmsg	
	.reset
	8 flxS tuWina $1 "Imm" .wtitle |242 .bc
	fx fy .at
	'msg .print
	;

:debugcode
	.reset .cls 
	1 flxN
	
	2 .bc 15 .fc
	fx fy .at fw .nsp fx .col
	" R3debug [" .write
	'filename .write 
	"] " .write
	|tudebug .write

	1 flxS
	fx fy .at 
	" |ESC| Exit |F1| Run |F2| Debug |F3| Check |F4| Profile |F5| Compile"
	.write

	scrmsg
	scrmapa

	|-----------
	.reset
	flxRest tuWina 
	$4 'filename .wtitle
	$23 mark tudebug ,s ,eol empty here .wtitle
	1 1 flpad 
	tuReadCode | 
	
	uiKey
	[f1] =? ( runcode ) |0 'mode ! ) |checkcode ) |show256 )
|	[f2] =? ( debugcode ) |show256 )
	
|	[f6] =? ( screenstate 1 xor 'screenstate ! )
|	[f7] =? ( screenstate 2 xor 'screenstate ! )
	drop
	;


:screrr
	.reset  
	5 flxS .wfill
	tuWina $1 " Error " .wtitle
	1 1 flpad 	
	fx fy .at 
	'msg .write flcr
	15 .fc 1 .bc 'errword .write flcr
	.reset
	errline "in line %d" .print
	;
	
:editcode
	.reset .home |.cls 
	1 flxN
	|4 .bc 7 .fc
	fx fy .at fw .nsp fx .col
	" R3edit [" .write
	'filename .write 
	"] " .write
	|tudebug .write
	
	1 flxS
	fx fy .at 
	" |ESC| Exit |F1| Check |F2| Debug |F3| Check |F4| Profile |F5| Compile"
	.write

	|-----------
	screenstate	
	$1 and? ( screrr )
	drop

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
	
#listmode 'editcode 'debugcode	
:main
	mode 3 << 'listmode + @ ex
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
