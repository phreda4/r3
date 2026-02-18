| TUI IDE
| PHREDA 2025
^r3/util/tui.r3
^r3/util/tuiedit.r3
|^r3/lib/trace.r3

^r3/d4/r3token.r3


#msg * 1024		| last line msg

#vlist 
#msglist

#vwords 0 0
#vincs 0 0

#lwords
#lincs

|----
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
	

|---- CHECKCODE
:cntlines | -- nrolin
	1 fuente 
	( lerror <?
		c@+ 13 =? ( rot 1+ -rot ) drop
		) drop ;
		
:coderror | error --
	.cl	15 .fc 1 .bc lerror " %w | " .print
	.write cntlines " in line %d" .print 
	.eline
	'msg strcpybuf ;
	
:codeok
	.cl	2 .bc 0 .fc
	cnttok cntdef cntinc " OK | inc:%d words:%d tokens:%d" .print 
	.eline
	'msg strcpybuf ;
|	makelistwords
|	makelistinc
|	;

:checkcode
	0 'msg !
	fuente 'filename r3loadmem
	error 1? ( coderror ; ) drop 
	codeok 
	;
	
	
|--- F2 analisis
:anacode
	0 'msg !
	fuente 'filename r3loadmem
	error 1? ( coderror ; ) drop 
	codeok 
	|r3tokeninfo
	;

|---- screen
:setcursoride
	vwords uiNindx str$>nro nip
	nro>dic @
	|40 >> src + "%l" sprint 'msg strcpy 
	40 >>> fuente + |1- | :#
	tuiecursor!	;
	
:scrmapa
	.reset
	cols 2/ flxE 
	
|	flxpush
|	8 flxN
|	tuWina $1 "Includes" .wtitle 1 1 flpad 
|	'vincs lincs tuList
|	flxRest
	tuWina $1 "Dicc" .wtitle 1 1 flpad 
	
	'xwrite.word xwrite!
	'vwords lwords tuList | 'var list --
|	tuX? 1? ( setcursoride ) drop
	setcursoride
	xwrite.reset
|	flxpop
	;
	
:scrmsg	
	.reset
	8 flxS tuWina $1 "Imm" .wtitle |242 .bc
	fx fy .at
	'msg .print
	;


:helpmain
	.reset .home 
	4 .bc 7 .fc
	1 flxN 
	
	2 flxS 
	fx fy .at fw .nsp
	" help [" .write 'filename .write "] " .write tuecursor. .write
	
	scrmapa

	flxRest
	tuReadCode
	tuEditShowCursor .ovec tuC! 

	uiKey
	[esc] =? ( exit )
	drop
	;
	
:helpcode
	|editfasthash lasthash =? ( moreinfo ; ) 'lasthash !
	fuente 'filename r3loadmem
	error 1? ( coderror ; ) drop
	codeok
	'helpmain onTui
	;

|-------------------------------
:printfname
	4 .bc 7 .fc .sp 'filename .write .sp ;
	
:moderror
	lerror tuiecursor! ;
	
:runcode
	checkcode error 1? ( drop moderror ; ) drop
	.masb .reset .cls .flush
	TuSaveCode
	'filename
|WIN| 	"cmd /c r3 ""%s"""
|LIN| 	"./r3lin ""%s"""
	sprint sys | run
	.reterm .alsb .flush
	|here dup "error.log" load over =? ( 2drop ; ) 0 swap c!
	|drop "** error **" 'msg strcpy
	;

:debugcode
	checkcode error 1? ( drop moderror ; ) drop
	|.masb .reset .cls .flush
	TuSaveCode
|WIN| 	"r3 r3/d4/r3debug.r3" 
|LIN| 	"./r3lin r3/d4/r3debug.r3"
	sys | run
	.reterm .alsb .flush 
	;
	
:fileplain
	checkcode error 1? ( drop moderror ; ) drop
|	.masb .reset .cls .flush
	TuSaveCode
|WIN| "r3 r3/editor/r3plain.r3"
|LIN| "./r3lin r3/editor/r3plain.r3"
	sys
|	.reterm .alsb .flush 
	;

|------- dev
:fileplaino
	checkcode error 1? ( drop moderror ; ) drop
|	.masb .reset .cls .flush
	TuSaveCode
|WIN| "r3 r3/d4/r3plain.r3"
|LIN| "./r3lin r3/d4/r3plain.r3"
	sys
|	.reterm .alsb .flush 
	;
|------- dev

:filecompile
	checkcode error 1? ( drop moderror ; ) drop
	|.masb .reset .cls .flush
	TuSaveCode
|WIN| "r3 r3/system/r3compiler.r3"
|LIN| "./r3lin r3/system/r3compiler.r3"
	sys
	|.reterm .alsb .flush 
	;

|-------------------------------

:compile
	checkcode error 1? ( drop moderror ; ) drop
	.masb
	.reset .cls
	"[07Building" .awrite .cr .cr .cr .cr 
	
	.cr
	"Code: " .write 'filename .write .cr .cr
	cntinc " includes:%d |" .print
	cntdef " words:%d |" .print
	cnttok " tokens:%d" .println
	.cr .cr
	cols .hline
	"[f2] Win64exe [f3] Plain " .write .cr
	cols .hline
	.reset .cr
	getch 
	[f2] =? ( filecompile )
	[f3] =? ( fileplain ) 
	[f4] =? ( fileplaino ) | dev
	drop
	.alsb
	;
	
|-------------------------------
:main
	.reset .home 
	2 flxS 
	fx fy .at printfname 
	0 .fc 6 .bc .sp tuecursor. .write 
	4 .bc 7 .fc " ^[7mF4^[27m Run ^[7mF5^[27m Debug  ^[7mF10^[27m Build" .printe .eline .cr
	'msg .write
	flxRest
	
	tuEditCode
	uiKey
	| [f2] =? ( helpcode )			| h
	[f3] =? ( anacode )
	[f4] =? ( runcode )
	[f5] =? ( debugcode )
	[f10] =? ( compile )
	toLow
	drop ;

|-----------------------------------
: 
	.alsb
	'filename "mem/menu.mem" load drop
	|"r3/test/testasm.r3" 'filename strcpy
	
	'filename TuLoadCode
	|TuNewCode
	mark
	'main onTui 
	TuSaveCode 

;
