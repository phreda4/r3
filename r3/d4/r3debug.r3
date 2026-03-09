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

|-------------------------------------
#topline * 256
#statusline * 256
#errorst 0

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
	cntdicc >=? ( drop "" lwrite ; ) 
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
		1+ ) drop
	0 swap w!+ 'here ! ;

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
|	flxPush
|	tuS
|	rows 2/ flxS
	.reset tuWina $1 "Watch" .wtitle 1 1 flpad 
	fx fy .at
	|localdicc fw 4 - ( 1? 1- swap .printword 1+ swap ) 2drop
|	cntdicc localdicc "%d %d" .print

	'xwriten.word xwriten!
	'vwords lwords tuListn | 'var list --
	xwriten.reset

|	flxRest
|	.reset tuWina $1 "Mem" .wtitle 1 1 flpad 
	
|	flxPop
	;


|-------------------------------------
| ftoken=(inc<<48)|(cnt<<40)|(pos<<24)|(xc<<12)|yc

:findtoken | pos -- codesrc
	codesrc> ( 8 - dup @ 48 >> $ff and 
		codenow >? drop ) drop 
	( dup @ 24 >> $ffff and 
		pick2 >? drop 8 - ) drop ;	
		
:breakpoint
	fuente> fuente - | pos in src
	findtoken
	ftoken>token 
	inbp? 0? ( drop addBP ; ) 
	nip delBP ;

:viewmemhere
	;
	
|-------------------------
:.datastack
	mdatastack dup
	( 8 + vmNOS <? 
		dup dstackoff + @ " %h" .print 
		) drop
	vmNOS <? ( vmTOS " %h" .print ) 
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
	vmIP memtokn " %h" .print
	" | " .write  codesrc "cs:%h " .print vmIP "ip:%h " .print codesrc vmIP 1- 3 << + @ ":%h:" .print
	.cr	
	"D|" .write .datastack .cr
	"R|" .write .retstack .cr
	
	bplist ( d@+ 1? "%h " .print ) 2drop .cr
	vmIP "%h" .print
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
	

:slnormal
	.cl	7 .fc cols .nsp
	" ^[7mF3^[27m BreakP ^[7mF5^[27mPlay/Stop ^[7mF10^[27mStep ^[7mF11^[27mInto " .printe
	'statusline strcpybuf ;
	
:.strerr
	errorst
	$5 =? ( "Invalid memory" .write ) 
	$94 =? ( "divide by 0" .write )
	$100 =? ( "Stack underflow" .write )
	$200 =? ( "Stack overflow" .write )
	drop ;
	
:runtimerror
	stoponerror 'errorst !
	.cl 15 .fc 1 .bc cols .nsp 
	errorst " * RUNTIME ERROR:%h * " .print .strerr
	'statusline strcpybuf ;

:checkerror
	vmState $fe <? ( drop ; ) 
	$fe =? ( drop exit ; ) drop
	runtimerror
	;
	
|-------------------------------------
:showcode | n --
	codenow =? ( drop ; ) dup 'codenow !
	inc2src TuLoadMemC 
	
	.cl 7 .fc cols .nsp
	" r3debug | " .write
	codenow cntinc <? ( 
		strinc over n>>0 .write
		" > " .write
		) drop
	'filename .write
	'topline strcpybuf ;
	

|-------------------------------------
| ftoken=(inc<<48)|(cnt<<40)|(pos<<24)|(xc<<12)|yc
:ftokenIP
	codesrc vmIP 1- 3 << + @ ;
	
:playshow
	ftokenIP 
	dup 48 >> $ff and codenow <>? ( 2drop ; ) drop
	|dup 
	24 >> $ffff and fuente + tuiposq!
	
	.cl .hidec tui
	.reset .cls
	1 flxN
	fx fy .at 5 .bc 'topline .write
	
	8 flxS
	fx fy .at 'statusline .write 
	.cr scrMsg
	
|	30 flxE |tuWina $1 "Imm" .wtitle |242 .bc
|	scrTokens
	
|	cols 2/ flxE
|	scrDicc
	
	flxRest 
	tuReadCode 

	|tokenCursor	| ftokenIP
	.showc
	.flush
	;

| play only in the source 
:playmode
	ftokenIP 48 >> $ff and 'codenow !
	*>play 
| wait for play
	( vmState 0? drop ) drop 
| until stop or error
	( vmState 1 =? drop
		inkey [esc] =? ( *>stop ) drop 
		playshow
		) 
	$ff >? ( runtimerror ) 
	drop 
|	*>stop
| land in src
	( ftokenIP 48 >> $ff and codenow <>? 
		*>stepo drop ) drop 
	tuR! | redraw
	;
	
#ipnow
:stepinsrc	
	ftokenIP dup 'ipnow ! 48 >> $ff and 'codenow !
	( *>step 
		( ftokenIP ipnow =? drop ) dup 'ipnow !
		48 >> $ff and codenow <>? drop ) drop 
	;

:stepout
	vmIP memtokn $ff and 
	$86 <>? ( drop *>stepo ; ) | JMP
	drop *>stepu
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
	ftokenIP
	cm <>? ( remake )
	tokenCursor
	;

#ck 
|#lastinclude

:checkcm
	cm <>? ( remake ) dup 'ck ! ;
	
:drawkeepcm
	ftokenIP
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
	fx fy .at 4 .bc 'topline .write
	
	8 flxS
	fx fy .at 'statusline .write
	vmSTATE " >>%H<<" .PRINT 

	.cr scrMsg
	
|	30 flxE |tuWina $1 "Imm" .wtitle |242 .bc
|	scrTokens
	
|	cols 2/ flxE
|	scrDicc
	
	flxRest 
	tuReadCode 
	.ovec tuC! | show user cursor
	msec $100 and? ( drawkeepcm ) drop
	
	1 .bc 7 .fc 
	bplist ( d@+ 1? token>ftoken @ tokenCursor ) 2drop 
	
	uiKey
	tueKeyMove	
	[f3] =? ( breakpoint )
	[f4] =? ( viewmemhere ) 
|	[f5] =? ( play/stop )
	[f5] =? ( playmode )
	[f9] =? ( stepinsrc )
	[f10] =? ( stepout )
	[f11] =? ( *>step )
	drop 
	checkerror
	;
	
:main
	'filename run&loadinfo
	'filename makemapdebug
|---- build code links

	makelistwords
|	makelistinc
	
	clearbp
	
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