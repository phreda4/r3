| TUI IDE
| PHREDA 2025
^r3/util/tui.r3
^r3/util/tuiedit.r3
|^r3/lib/trace.r3

^r3/d4/r3token.r3

#filename * 1024

#msg * 1024		| lst line msg

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
	.cl	15 .fc 1 .bc
	lerror " %w " .print
	.write cntlines " in line %d" .print 
	'msg strcpybuf ;
	
:codeok
	.cl	2 .bc 0 .fc
	cnttok cntdef cntinc " OK inc:%d words:%d tokens:%d" .print
	'msg strcpybuf ;
|	makelistwords
|	makelistinc
|	;

:checkcode
	0 'msg !
	fuente 'filename r3loadmem
	error 1? ( coderror ; ) drop 
	codeok ;
	
	
|--- F1 RUN in CHECK	

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

	
:maninfo
	;

#mins " INS "
#movr " OVR "
#mvis " VIS "

#msgmode  mins

|-------------------------------
:printfname
	4 .bc 7 .fc .sp 'filename .write .sp ;
	
:modedit
	.reset .cls 
	1 flxS 
	fx fy .at printfname
	0 .fc 6 .bc msgmode .write tuecursor. .write 
	'msg .write .eline
	flxRest
	tuEditCode
	uiKey
	|[esc] =? ( exit )
	drop ;

:moderror
	lerror tuiecursor! 
	'modedit onTui ;
	
:runcode
	checkcode error 1? ( drop moderror ; ) drop
	.masb .reset .cls .flush
	TuSaveCode
	"mem/errorm.mem" delete
	'filename
|WIN| 	"cmd /c r3 ""%s"" 2>mem/errorm.mem"
|LIN| 	"./r3lin ""%s"" 2>mem/errorm.mem"
	sprint sys | run
	.reterm .alsb .flush
	|here dup "mem/errorm.mem" load over =? ( 2drop ; ) 0 swap c!
	|drop "** error **" 'msg strcpy
	;

:debugcode
	checkcode error 1? ( drop moderror ; ) drop
	.masb .reset .cls .flush
	TuSaveCode
|WIN| 	"r3 r3/d4/r3debug.r3" 
|LIN| 	"./r3lin r3/d4/r3debug.r3"
	sys | run
	.reterm .alsb .flush ;
	
:fileplain
	checkcode error 1? ( drop moderror ; ) drop
	.masb .reset .cls .flush
	TuSaveCode
|WIN| "r3 r3/editor/r3plain.r3"
	sys
	.reterm .alsb .flush ;

:filecompile
	checkcode error 1? ( drop moderror ; ) drop
	.masb .reset .cls .flush
	TuSaveCode
|WIN| "r3 r3/system/r3compiler.r3"
	sys
	.reterm .alsb .flush ;
	
|-------------------------------
#state

:confirm
	0 rows .at printfname 
	6 .bc 0 .fc 
	" exit without save ? (Y/N) " .write .eline
	getch tolow
	$79 <>? ( drop ; ) drop
	$10 'state !
	exit ; 

:main
	.reset .home 
	1 flxS 
	fx fy .at printfname 
	3 .bc 0 .fc 'MVIS .write tuecursor. .write 
	
	4 .bc 7 .fc
	" ^[7m R ^[27mun ^[7m D ^[27mebug  ^[7m P ^[27mlain ^[7m C ^[27mompile ^[7m H ^[27mHelp ^[7m / ^[27mSearch ^[7m Q ^[27muit "  
	.printe
	.eline
	flxRest
	tuReadCode
	|tuEditShowCursor
	.ovec tuC!
	uiKey
	[esc] =? ( 'modedit onTui )
	|$2f =? ( 'modesearch onTui )
	tueKeyMove
	toLow
	$68 =? ( helpcode )			| h
	$71 =? ( $1 'state ! exit ) | q
	$78 =? ( confirm )			| x salir sin grabar
	$72 =? ( runcode )			| r un
	$64 =? ( debugcode )		| d ebug
	$70 =? ( fileplain )		| plain
	$63 =? ( filecompile )		| compile
	drop ;

|-----------------------------------
: 
	.alsb
	'filename "mem/menu.mem" load	
	|"r3/test/testasm.r3" 'filename strcpy
	
	'filename TuLoadCode
	|TuNewCode
	mark
	0 'state !
	'main onTui 
	| state $1 and? ( TuSaveCode ) drop
	TuSaveCode 
	
	.masb .free 
;
