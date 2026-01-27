| r3debug
| PHREDA 2025
^r3/lib/memshare.r3
^r3/util/tui.r3
^r3/util/tuiedit.r3

^./infodebug.r3

#vshare 0 0 4096 "/debug.mem"	| vm state
#bshare 0 0 512 "/bp.mem"		| breakpoint
#dshare 0 0 0 "/data.mem" 		| memdata
#cshare 0 0 0 "/code.mem" 		| codedata

#filename * 1024

#cntdicc
#boot
#memc #memd
#memdsize #memcsize
#memcode #memdata
#mdatastack #mretstack

#realdicc

|DICC
|v=(pos<<40)|(dicc[i].mem<<8)|dicc[i].info;

:loadinfo
	here dup "mem/r3code.mem" load 'here !
	d@+ 'cntdicc ! d@+ 'boot !
	d@+ 'memc ! d@+ 'memd !
	d@+ 'memdsize ! d@+ 'memcsize !
	@+ 'memcode ! @+ 'memdata !
	@ dup 'mdatastack ! 504 3 << + 'mretstack !

	here dup "mem/r3dicc.mem" load 'here !
	'realdicc !
	;

#msg * 1024
	
#vincs 0 0
#vwords 0 0
#vtoken 0 0

#lincs
#lwords
#ltokens


|	__int64 vmstate; // msg
|	__int64 vminfo; // msg
|    __int64 ip;
|    __int64 TOS;
|    __int64 *NOS;
|    __int64 *RTOS;
|    __int64 REGA;
|    __int64 REGB;
|    __int64 datastack[252];
|    __int64 retstack[252]; } VirtualMachine;	

:*>end		$fe vshare ! ;
:*>step		$2 vshare ! ;
:*>stepw	$4 vshare ! ;
:*>steps	$6 vshare ! ;
:*>play		$1 vshare ! ;
:*>stop		$0 vshare ! ;

:vmSTATE	vshare @ ;
:vmINFO		vshare 1 3 << + @ ;
:vmIP		vshare 2 3 << + @ ;
:vmTOS		vshare 3 3 << + @ ;
:vmNOS		vshare 4 3 << + @ ;
:vmRTOS		vshare 5 3 << + @ ;
:vmREGA		vshare 6 3 << + @ ;
:vmREGB		vshare 7 3 << + @ ;
:vmDS		vshare 8 3 << + ;
:vmRS		vshare 512 3 << + ;

#dstackoff
#rstackoff
#codeoff
#dataoff

:precalc
	vmDS mdatastack - 8 + 'dstackoff !
	vmRS mretstack - 8 + 'rstackoff !
	cshare memcode - 'codeoff !
	dshare memdata - 'dataoff !
	;

|---- view dicc
:ndicc | n -- entry
	3 << realdicc + @ ;
:dicc>name | nd -- str
	40 >> realdicc cntdicc 3 << + + ;
	
:wcolor
	$10 nand? ( 201 .fc ":" ,s ; ) 196 .fc "#" ,s ;
	
:xwrite.word | str --
	mark
	str$>nro nip
	cntdicc >=? ( drop "" ; ) 
	ndicc wcolor
	dicc>name ,s ,eol 
	empty
	here lwrite ;

:makelistwords
	here 'lwords !
	0 ( cntdicc <?
|	dic< ( dic> <? | solo codigo principal
		|chooseword
		dup .h ,s ,eol
		1+ ) drop
	,eol ;

|---- token	
	
:ndicc>toklen | n -- tok len
	|$10 and? ( to
	dup 8 >> $ffffffff and 
	;	
	
|---- screen
:scrViews
	.reset
	cols 3 / flxO 
	flxpush
	
	12 flxN
	tuWina $1 "Dicc" .wtitle 1 1 flpad 
	'xwrite.word xwrite!
	'vwords lwords tuList | 'var list --
	xwrite.reset
	
	flxRest
	tuWina $1 "Stack" .wtitle 1 1 flpad 
	
|	fx fy .at
|	infocode
	
|	'xwrite.word xwrite!
|	'vwords lwords tuList | 'var list --
|	xwrite.reset
	flxpop
	;

:scrMsg	
	.reset
	8 flxS |tuWina $1 "Imm" .wtitle |242 .bc
	fx fy .at
	cols .hline .cr

	vmIP	"IP:%h " .print 
	vmTOS	"TOS:%h " .print
	vmNOS	"NOS:%h " .print
	vmRTOS	"RTOS:%h " .print .cr
	vmREGA	"A:%h " .print
	vmREGB	"B:%h " .print 
	vmDS	"DS:%h " .print
	vmRS	"RS:%h " .print .cr

	cntdicc "cnddicc:%h " .print
	boot "boot:%h " .print
	memc "memc:%h " .print
	memd "memd:%h " .print
	memdsize "memdsize:%h " .print 
	memcsize "memcsize:%h " .print .cr
	
	memcode "memcode:%h " .print 
	memdata "memdat:%h " .print 
	mdatastack "stack:%h " .print 
	mretstack "rstack:%h " .print .cr

	
	mdatastack dup
	( 8 + vmNOS <? 
		|dup mdatastack - vmDS + 8 + @ 
		dup dstackoff + @ 
		" %h" .print 
		) drop
	vmNOS <? ( vmTOS " %h <TOP" .print ) drop .cr
	
	mretstack 
	( 8 - vmRTOS >=? 
		dup |rstackoff + |@ 
		"%h " .print
		) drop .cr
		
|	mretstack ( 8 + vmRTOS <?
|		dup rstackoff + @
|		"%h " .print
|		) drop .cr
		
|	'msg .print
	;
	
:scrtxcode
	|tuWina $4 'filename .wtitle
	|$23 mark tudebug ,s ,eol empty here .wtitle
	|1 1 flpad 
	
	|tuEditCode
	tuReadCode 
	;
	
|---- view tokens	
:scrtokens
	fx fy .at
	memcode 4 + >a
|	|memc 
	12
	( 1? 1-
		da@+ .token .write .sp
		|$ffffffff and "%h " .print
		) drop
	;
	
:Infovm
	fx fy .at
	.reset
	vshare >a
	10 ( 1? 1-
		a@+ "%h " .println
		) drop ;

|---- main	
:maindb
	.reset .cls
	1 flxN
	4 .bc 7 .fc
	fx fy .at fw .nsp fx .col
	" R3forth DEBUG [" .write 'filename .write "] " .write
	
	1 flxS
	fx fy .at fw .nsp fx .col
	" F2-Step F3-Over F4-Stack F5-Play | F9-End" .write

	scrMsg
|	scrViews
	
	flxRest 
	scrtxcode
	|scrtokens
	
	uiKey
	[f2] =? ( *>step )
	[f3] =? ( *>stepw )
	[f4] =? ( *>steps )
	[f5] =? ( *>play )
	
	[f9] =? ( *>end )
	
	drop ;
	
:main
	| start the server
	"mem/r3dicc.mem" delete | "filename" --
	
	| start debug
	'filename 
	"cmd /c r3d ""%s""" sprint
	sysnew 

	| wait info
	"mem/r3dicc.mem"  
	( dup filexist 0? drop 100 ms ) 
	2drop 
	
	loadinfo
	makelistwords

	memdsize 'dshare 16 + !			| data mem size
	memcsize 'cshare 16 + !	| code mem size
	
	'vshare inisharev
	'bshare inisharev
	'dshare inisharev
	'cshare inisharev

	precalc

	'maindb onTuia
	
|	100 sleep
	*>end
|	100 sleep

	'cshare endsharev
	'dshare endsharev
	'bshare endsharev
	'vshare endsharev
	;

: 
	.alsb 
	|'filename "mem/menu.mem" load	
	"r3/d4/test.r3" 
|	"r3/audio/parse.r3" 
	'filename strcpy
	
	'filename TuLoadCode
	mark
	main
	
	.masb .free 

	;