| r3debug
| PHREDA 2025
^r3/lib/memshare.r3
^r3/util/tui.r3
^r3/util/tuiedit.r3

^./infodebug.r3

#vshare 0 0 4096 "/debug.mem"

#state 0
#filename * 1024

#cntdicc
#boot
#memc
#memd

#memcode
#memdata

#dstack * 1024
#dstack>

#rstack * 1024
#rstack>

#dicc
#dicc>

|fwrite(&cntdicc,sizeof(int),1,file);
|fwrite(&boot,sizeof(int),1,file);
|fwrite(&memc,sizeof(int),1,file);
|fwrite(&memd,sizeof(int),1,file);
|fwrite((void*)memcode,sizeof(int),memc,file);
|fwrite((void*)memdata,1,memd,file);

|v=(pos<<40)|(dicc[i].mem<<8)|dicc[i].info;

#realdicc

:loadinfo
	here dup "mem/r3code.mem" load 'here !
	d@+ 'cntdicc !
	d@+ 'boot !
	d@+ 'memc !
	d@+ 'memd !
	dup 'memcode !
	memc 2 << + 
	'memdata !

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
	4 flxS |tuWina $1 "Imm" .wtitle |242 .bc
	fx fy .at
	cols .hline .cr
	
	'dstack ( dstack> <? @+ "%d " .print ) .cr
	'msg .print
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
	
#step	
:Infovm
	fx fy .at
	.reset
	step "---%d---" .println
	vshare >a
	10 ( 1? 1-
		a@+ "%h " .println
		) drop
	tuR!
	1 'step +!
	;

|---- main	
:maindb
	.reset .cls 
	1 flxN
	4 .bc 7 .fc
	fx fy .at fw .nsp fx .col
	" R3forth DEBUG [" .write
	'filename .write 
	"] " .write
	
	1 flxS
	fx fy .at fw .nsp fx .col
	" F1-step F2-over F3-out F4-stack F5-Play" .write

|	scrMsg
|	scrViews
	
	flxRest 
	Infovm
	|scrtxcode
	
	|scrtokens
	
	uiKey
	|[esc] =? ( 1 'flags ! ) 
|	[f1] =? ( 0 vmsend1 ) 	|"[f1] step" .fprintln
|	[f2] =? ( 1 vmsend1 ) |"[f2] step over" .fprintln
||	[f3] =? ( 2 vmsend1 ) |"[f3] step out" .fprintln
|	[f4] =? ( 3 vmsend1 ) |"[f4] step stack" .fprintln
|	[f5] =? ( 4 vmsend1 ) |"[f5] Play" .fprintln
	
|	[f7] =? ( 6 vmsend1 )	| end debug
	
|	[f1] =? ( checkcode ) |show256 )
|	[f2] =? ( debugcode ) |show256 )
	
|	[f6] =? ( screenstate 1 xor 'screenstate ! )
|	[f7] =? ( screenstate 2 xor 'screenstate ! )
	drop
	|100 ms
	;


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

	'maindb onTui
	;

: 
	'vshare inisharev
	.alsb 
	|'filename "mem/menu.mem" load	
|	"r3/d4/test.r3" 
	"r3/audio/parse.r3" 
	'filename strcpy
	
	'filename TuLoadCode
	mark
	main
	'vshare endsharev	
	.masb .free 

	;