| r3debug
| PHREDA 2025

^r3/lib/memshare.r3
^r3/util/tui.r3
^r3/util/tuiedit.r3

^./infodebug.r3

|^r3/lib/trace.r3

#filename * 1024

|--- for show in code
#codenow -1

#msg * 1024
	
#vincs 0 0
#vwords 0 0
#vwatch 0 0

#lincs
#lwords
#lwatch
	
:wcolor
	$10 nand? ( 201 .fc ":" ,s ; ) 196 .fc "#" ,s ;

:xwriten.word | n --
	1- $ffff and 
	cntdicc >=? ( drop "" ; ) 
	mark
	ndicc@ 
	dup 58 >>> "%d " ,print | nro include
	wcolor dicc>name ,s ,eol 
	empty
	here lwrite ;

:makelistwords
	here dup 'lwords !
	localdicc |0 
	( cntdicc <?
		dup 1+ rot w!+ swap
		1+ )
	swap w!+ 'here ! ;

:makelistinc
	here dup 'lincs !
	0 ( cntinc <? 
		dup 1+ rot w!+ swap
		1+ )
	swap w!+ 'here ! ;


:typedef $10 and? ( "#" .write ; ) ":" .write ;
	
:.fcr .cr fx .col ;
	
:.printword | nro -- nro
	cntdicc <? ( ; )
	dup ndicc@ |typedef 40 >> realdicc + 
	|cntdicc 3 << + 
	dicc>name "%w" .print 
	|.write 
	.fcr ;
	
:scrDicc
	flxPush
|	tuS
	rows 2/ flxS
	.reset tuWina $1 "Watch" .wtitle 1 1 flpad 
	fx fy .at
	|localdicc fw 4 - ( 1? 1- swap .printword 1+ swap ) 2drop
|	cntdicc localdicc "%d %d" .print

	'xwriten.word xwriten!
	'vwords lwords tuListn | 'var list --
	xwriten.reset

	flxRest
	.reset tuWina $1 "Mem" .wtitle 1 1 flpad 
	
	flxPop
	;


:viewmemhere
	;
	
|-------------------------
:.datastack
	mdatastack dup
	( vmNOS <? 
		dup dstackoff + @ " %h" .print 
		8 + ) drop
	vmNOS <=? ( vmTOS " %h" .print ) 
	drop ;

:.retstack
	mretstack 
	( 8 - vmRTOS >? 
		dup rstackoff + |@ 
		" %h" .print
		) drop ;
		
:scrMsg
	.reset |fx fy 1+ .at fw .hline .cr
	vmIP "IP:%h " .print 
	vmREGA	"A:%h " .print vmREGB	"B:%h | " .print 
	vmIP memtok .write
	" | " .write
	codesrc vmIP 1- 3 << + @ ":%h:" .print
	.cr
	
	"D|" .write .datastack .cr
	"R|" .write .retstack 
	;
	
|---- view tokens	
:scrTokens
	.reset fx fy .at fw .hline 
	.fcr

|-------- print dicc
|	localdicc ( cntdicc <? 
|		dup ndicc@ stypedef 40 >> realdicc + cntdicc 3 << + .write .fcr
|		1+ ) drop
	
||	tuWina $1 "Includes" .wtitle 1 1 flpad 
	|'vincs lincs tuList	
|-------- print includes
|	strinc cntinc ( 1? 1- swap
|		dup .write .fcr
|		>>0 swap ) 2drop
	;
	
|-------------------------------------
#statusline * 256
#errorst 0

:slnormal
	.cl	4 .bc 7 .fc cols .nsp
	" ^[7mF5^[27mPlay/Stop ^[7mF9^[27m BreakP ^[7mF10^[27mStep ^[7mF11^[27mInto " .printe
	'statusline strcpybuf ;
	
:runtimerror
	stoponerror 'errorst !
|	vmState 8 >> 'errorst !
|	0 vshare !
|	-1 vshare 2 3 << + +! ||-1 vmIP +!
	
	.cl 15 .fc 1 .bc cols .nsp
	errorst " * RUNTIME ERROR: %h * " .print 
	'statusline strcpybuf ;
	
|-------------------------------------
#labelfilename * 256

:showcode | n --
	codenow =? ( drop ; ) 
	
	dup 'codenow !
	inc2src TuLoadMemC 
	0 'labelfilename c! | build label
	codenow cntinc <? ( 
		strinc over n>>0 'labelfilename strcpy
		" > " 'labelfilename strcat
		) drop
	'filename 'labelfilename strcat ;
	

:playmode
	;

|-------------------------------------
#cm -1

:remake
	dup 'cm ! 
	dup 48 >> $ff and showcode
	dup 24 >> $ffff and fuente + tuipos!
|	tuiecursor!	
	;

:drawcm
	3 .bc 0 .fc |1 .bc 7 .fc
	codesrc vmIP 1- 3 << + @ 
	cm <>? ( remake )
	tokenCursor
	;

#ck 
|#lastinclude

:checkcm
	cm <>? ( remake ) dup 'ck ! ;
	
:drawkeepcm
	codesrc vmIP 1- 3 << + @ 
	|dup 48 >> $ff and lastinclude >=? ( swap checkcm ) 2drop
	checkcm 'ck !
	3 .bc 0 .fc ck tokenCursor
	;
	
:play/stop
	vmstate	1 =? ( drop *>stop ; ) drop *>play ;

|---- main	
:maindb
	.reset .cls
	
	1 flxN
	4 .bc 7 .fc fx fy .at fw .nsp
	" R3debug | " .write 'labelfilename .write
	
	8 flxS
	fx fy .at
	'statusline .write
	vmSTATE " >>%H<<" .PRINT .cr
	scrMsg
	
|	30 flxE |tuWina $1 "Imm" .wtitle |242 .bc
|	scrTokens
	
|	cols 2/ flxE
|	scrDicc
	
	flxRest 
	tuReadCode 
	.ovec tuC! | show user cursor
	msec $100 and? ( drawkeepcm ) drop 
	
	uiKey
	tueKeyMove	
	[f4] =? ( viewmemhere ) 
	[f5] =? ( play/stop )
|	[f9] =? ( *>end )
	[f10] =? ( *>stepo )
	[f11] =? ( *>step )
	drop 
	vmState $ff >? ( runtimerror ) drop
	;
	
:main
	'filename run&loadinfo
	'filename makemapdebug
|---- build code links

|	makelistwords
|	makelistinc
	
	
|	cntinc 2 - 'lastinclude !
|	0 'lastinclude !
	cntinc showcode
	slnormal
|---- run debug	
	'maindb onTuia
	debugend
	;

: 
	.alsb 
	'filename "mem/menu.mem" load
|	"r3/d4/test.r3" 'filename strcpy
	
	main
	.masb .free ;