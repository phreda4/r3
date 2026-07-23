| TUI IDE
| PHREDA 2025

^r3/util/tui.r3
^r3/util/tuiedit.r3
|^r3/lib/trace.r3

^r3/d4/helplib.r3
^r3/d4/r3token.r3

#msg * 1024		| last line msg

#vlist 
#msglist

#vwords 0 0
#vincs 0 0

#lwords
#lincs

#xsplit 40
#panelinfo 0

|---- change error mode
:moderror
	lerror tuiecursor! ;

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
	
|----
#helpword * 32

:cpyhelpword
	fuente> ( dup 1- | find start
		c@ $ff and 32 >? 
		drop 1- ) drop 
	'helpword 
	31 ( 1? 1- -rot		| copy word
		swap c@+ $ff and 
		32 <=? ( 2drop 0 swap c! drop ; )
		rot c!+ rot
		) drop
	0 swap c! 
	drop ;
	
|	'fuente> ! 
|	tuR! ;
	
|---- screen
:setcursoride
	vwords uiNindx str$>nro nip
	nro>dic @
	|40 >> src + "%l" sprint 'msg strcpy 
	40 >>> fuente + |1- | :#
	tuiecursor!	;
	
:scrmapa
|	.reset
|	cols 2/ flxE 
	
|	flxpush
|	8 flxN
|	tuWina $1 "Includes" .wtitle 1 1 flpad 
|	'vincs lincs tuList
|	flxRest
	.reset
|	tuWina $1 "Words" .wtitle 1 1 flpad 
	.wfill
	
	'xwrite.word xwrite!
	'vwords lwords tuList | 'var list --

|	tuX? 1? ( setcursoride ) drop

|	setcursoride
	xwrite.reset

|	flxpop
	;
	
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

:checkcode
	TuSaveCode
	0 'msg !
	fuente 'filename r3loadmem
	error 1? ( coderror ; ) drop 
	codeok 
	;
	
	
|--- F3 analisis
:anacode
	checkcode error 1? ( drop moderror ; ) drop
|	0 'msg !
|	fuente 'filename r3loadmem
|	error 1? ( coderror ; ) drop 
|	codeok 
|	r3tokeninfo
	makelistwords
	makelistinc
	'scrmapa 'panelinfo !
	;

	
:scrmsg	
	.reset
	8 flxS tuWina $1 "Imm" .wtitle |242 .bc
	fx fy .at
	'msg .print
	;
	
|--- F2 help	
:panelhelp
	.reset .wfill fx fy .at 
	"- Help -" .write
	;
	
:helpcode
	checkcode error 1? ( drop moderror ; ) drop
|	fuente 'filename r3loadmem
|	error 1? ( coderror ; ) drop
|	codeok
	'panelhelp 'panelinfo !
	;

|-------------------------------
:printfname
	4 .bc 7 .fc .sp 'filename .write .sp ;
	
:runcode
	checkcode error 1? ( drop moderror ; ) drop
	.masb .reset .cls .flush
	'filename r3run
	.reterm .alsb .flush
	|here dup "error.log" load over =? ( 2drop ; ) 0 swap c!
	|drop "** error **" 'msg strcpy
	tuR!
	;

:debugcode
	checkcode error 1? ( drop moderror ; ) drop
	|.masb .reset .cls .flush
	"r3/d4/r3debug.r3" r3run
	.reterm .alsb .flush 
	tuR! ;

|------- old
:fileplain
	checkcode error 1? ( drop moderror ; ) drop
	"r3/editor/r3plain.r3" r3run
	tuR! ;
|------- old

:fileplaino
	checkcode error 1? ( drop moderror ; ) drop
	"r3/d4/r3plain.r3" r3run
|	.reterm .alsb .flush 
	"r3/d4/gen/plain.r3" r3run
	tuR! ;

:filecompile
	checkcode error 1? ( drop moderror ; ) drop
	"r3/system/r3compiler.r3" r3run
	|.reterm .alsb .flush 
	tuR! ;

:filecompileo
	checkcode error 1? ( drop moderror ; ) drop
	|"r3/d4/r3plain.r3" r3run
	"r3/d4/r3wincomp.r3" r3run
	|.reterm .alsb .flush 
	tuR! ;

|-------------------------------

:compile
	checkcode error 1? ( drop moderror ; ) drop
	.masb .reset .cls
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
	[f4] =? ( filecompileo )
	
	[f3] =? ( fileplaino ) 
	[f5] =? ( fileplain ) | dev
	
	
	drop
	.alsb
	;
	
	
:panel
	panelinfo 0? ( drop ; ) 
	xsplit flxE
	ex ;
	
|-------------------------------
:main
	.reset .home 
	1 flxN 
	4 .bc 7 .fc " r3IDE | " .write printfname 
	" | " .write tuecursor. .write 
	.eline
	
	1 flxS 
	fx fy .at 
	4 .bc 7 .fc 
	" ^[7mF2^[27m Help ^[7mF3^[27m Check ^[7mF4^[27m Run ^[7mF5^[27m Debug  ^[7mF10^[27m Build " .printe 
	'helpword .write
	'msg .write
	.eline
	
	panel
	flxRest
	
	tuEditCode
	uiKey
	[f2] =? ( helpcode )			| h
	[f3] =? ( anacode )
	[f4] =? ( runcode )
	[f5] =? ( debugcode )
	
	[f6] =? ( cpyhelpword  )
	
	[f10] =? ( compile )
	toLow
	drop ;

|-----------------------------------
: 
	.alsb
	'filename "mem/menu.mem" load drop
	|"r3/test/testasm.r3" 'filename strcpy
	
	cols 2/ 'xsplit !
	'filename TuLoadCode
	|TuNewCode
	mark
	'main onTui 
	TuSaveCode 
;
