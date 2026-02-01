| TUI IDE
| PHREDA 2025
^r3/util/tui.r3
^r3/util/tuiedit.r3
|^r3/lib/trace.r3

^r3/d4/r3token.r3

#filename * 1024

#msgstate 0
#msg * 1024		| lst line msg

#errline
#errword * 64

#vlist 
#msglist

#vwords 0 0
#vincs 0 0

#lwords
#lincs

|--------- botton line --------
:posmsg
	fx fy .at fw .nsp ;
	
:msgvoid
	posmsg
	" ^[7m F2 ^[27mHelp ^[7m F3 ^[27mSearch ^[7m F5 ^[27mRun ^[7m F6 ^[27mDebug  ^[7m F7 ^[27mPlain ^[7m F8 ^[27mCompile"  
	.printe 
	;
	
:msgok
	15 .fc 2 .bc posmsg
	'msg .write ;

:msgerr
	15 .fc 1 .bc posmsg
	" " .write 'errword .write " :" .write
	'msg .write errline " in line %d" .print ;

#statusline 'msgvoid 'msgok 'msgerr

:banner
	.reset .cls "[01R[023[03f[04o[05r[06t[07h" .awrite .cr .cr .cr .cr .flush ;

|----
:cntlines
	1 fuente 
	( lerror <?
		c@+ 13 =? ( rot 1+ -rot ) drop
		) drop 'errline ! ;
		
:coderror | error --
	'msg strcpy
	lerror "%w" sprint 'errword strcpy
	cntlines 
	lerror tuiecursor!
	2 'msgstate !
	;

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
	
	
:codeok
	mark
	'msg 'here !
	cnttok cntdef cntinc "OK inc:%d words:%d tokens:%d" ,print
	,eol
	empty
	
	1 'msgstate !
	makelistwords
	makelistinc
	;

:checkcode
	0 'msgstate !
	fuente 'filename r3loadmem
	error 1? ( coderror ; ) drop 
	codeok 
	;
	
	
|--- F1 RUN in CHECK	

:runcheck
	here dup "mem/errorm.mem" load
	over =? ( 2drop ; ) 
	0 swap c!
	banner
	.cr .bred .white " * ERROR * " .write .cr
	.reset .write .cr
	.bblue .white " Any key to continue... " .write .cr
	waitkey ;	
	
:runcode
	banner
	TuSaveCode
	"mem/errorm.mem" delete
	'filename
|WIN| 	"cmd /c r3 ""%s"" 2>mem/errorm.mem"
|LIN| 	"./r3lin ""%s"" 2>mem/errorm.mem"
	sprint sys | run
	.reterm .alsb .flush
	runcheck ;

:debugcode
	checkcode
	TuSaveCode
|WIN| 	"r3 r3/d4/r3debug.r3" 
|LIN| 	"./r3lin r3/d4/r3debug.r3"
	sys | run
	.reterm .alsb .flush 
	0 'msgstate ! ;
	
:fileplain
	TuSaveCode
	.masb .flush
|WIN| "r3 r3/editor/r3plain.r3"
	sys
	.reterm .alsb .flush 
	0 'msgstate ! ;

:filecompile
	TuSaveCode

	.masb .flush
|WIN| "r3 r3/system/r3compiler.r3"
	sys
	.reterm .alsb .flush 
	0 'msgstate ! ;

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

	
|--- F2 HELP
#lasthash -1
:v*********************
	1 flxS 
	fx fy .at fw .nsp
	" |F1| Run |F2| Debug |F3| Check |F4| Profile |F5| Compile"
	|" ^[7m F2 ^[27mHelp ^[7m F3 ^[27mSearch ^[7m F5 ^[27mRun ^[7m F6 ^[27mDebug " ||C|lon |N|ew " 
	.printe 
	;

:helpmain
	.reset .home 
	4 .bc 7 .fc
	1 flxN 
	fx fy .at fw .nsp
	" R3edit [" .write 'filename .write "] " .write tudebug .write
	
	1 flxS 
	msgok
	
	scrmapa

	|-----------
	flxRest
	tuReadCode
	tuEditShowCursor .ovec tuC! 

	uiKey
	[esc] =? ( exit )
	drop
	;
	
:helpcode
	|editfasthash lasthash =? ( moreinfo ; ) 'lasthash !
	0 'msgstate !
	fuente 'filename r3loadmem
	error 1? ( coderror ; ) drop
	codeok
	'helpmain onTui
	0 'msgstate !
	;

	
:maninfo
	;
	

:mainedit
	.reset .home 4 .bc 7 .fc
	1 flxN 
	fx fy .at fw .nsp
	" R3edit [" .write 'filename .write "] " .write tudebug .write
	
	1 flxS 
	msgstate 
	dup $f and 3 << 'statusline + @ ex
|	$10 and? ( wordinfo )
|	$20 and? ( maninfo )
	drop

	|-----------
	flxRest
	tuEditCode
	
|	msgstate 
|	$10 and? ( tuEditShowCursor .ovec tuC! )
|	drop
	
	uiKey
| f1 no usada	
	[f2] =? ( helpcode )
	|[f3] =? ( search )
	|[f4] =? ( )
	[f5] =? ( runcode )
	[f6] =? ( debugcode ) | a debug /profile/compile
	
	[f7] =? ( fileplain )
	[f8] =? ( filecompile )
|[f8] =? ( siguiente??)
|[f9] =? ( breakpoint )
	
	drop
	;
	

|-----------------------------------
: 
	.alsb
	'filename "mem/menu.mem" load	
	|"r3/test/testasm.r3" 'filename strcpy
	
	'filename TuLoadCode
	|TuNewCode
	mark
	'mainedit onTui 
	TuSaveCode 
	
	.masb .free 
;
