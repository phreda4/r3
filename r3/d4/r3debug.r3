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

#showpanel 0 | panel
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


|------------------------
:typedef $10 and? ( "#" .write ; ) ":" .write ;
	
:.fcr .cr fx .col ;
	
:.printword | nro -- nro
	cntdicc <? ( ; )
	dup ndicc@ |typedef 40 >> realdicc + 
	|cntdicc 3 << + 
	dicc>name "%w" .print 
	|.write 
	.fcr ;
|localdicc fw 4 - ( 1? 1- swap .printword 1+ swap ) 2drop	
|-----------------------------
	
:wcolor
	$10 nand? ( 201 .fc ":" ,s ; ) 196 .fc "#" ,s ;

:xwriten.word | n --
	1- $ffff and 
	|cntdicc >=? ( drop "" lwrite ; ) 
	mark
	ndicc@ 
	|dup 58 >>> "%d " ,print | nro include
	wcolor dicc>name ,s ,eol 
	empty
	here lwrite ;

:makelistwords
	here dup 'lwords !
	localdicc |0 
	( cntdicc <? 1+
		dup rot w!+ swap
		) drop
	0 swap w!+ 'here ! ;


:panelWatch
	cols 2/ flxE
	.reset tuWina $1 "Watch" .wtitle 1 1 flpad 
	'xwriten.word xwriten!
	'vwords lwords tuListn | 'var list --
	xwriten.reset
|	flxRest
|	.reset tuWina $1 "Mem" .wtitle 1 1 flpad 
	;

|------------------------
:panelInclude
	25 flxO
	.reset tuWina $1 "Includes" .wtitle 1 1 flpad 
	'vincs strinc tuList | 'var list --
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

	codenow "include:%d" .print
	|vmIP memtok .write vmIP memtokn " %h" .print
	" | " .write  codesrc "cs:%h " .print vmIP "ip:%h " .print 
	codesrc vmIP 1- 3 << + @ ":%h:" .print
	.cr	

	"D|" .write .datastack .cr
	"R|" .write .retstack .cr
	
	|*** debug ***
	bplist ( d@+ 1? "%h " .print ) 2drop .cr
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
	" ^[7mF3^[27m BreakP ^[7mF5^[27mRun ^[7mF7^[27mInto ^[7mF8^[27mOver ^[7mF9^[27mOut " .printe
	'statusline strcpybuf ;
	
:.strerr
	errorst
|WIN|	$05 =? ( "Invalid memory (access violation)" .write )
|WIN|	$94 =? ( "Divide by 0" .write )
|WIN|	$1d =? ( "Illegal instruction" .write )
|WIN|	$03 =? ( "Breakpoint" .write )
|LIN|	$4 =? ( "Illegal instruction" .write )
|LIN|	$6 =? ( "Abort" .write )
|LIN|	$7 =? ( "Bus error (invalid memory)" .write )
|LIN|	$8 =? ( "Divide by 0 / FP error" .write )
|LIN|	$b =? ( "Invalid memory (segfault)" .write )
|LIN|	$d =? ( "Broken pipe" .write )
	$100 =? ( "Stack underflow" .write )
	$200 =? ( "Stack overflow" .write )
	drop ;
	
:runtimerror
	stoponerror 'errorst !
	.cl 15 .fc 1 .bc cols .nsp 
	errorst " * RUNTIME ERROR:%h * " .print .strerr
	'statusline strcpybuf ;

:runtimeend
	.cl 15 .fc 1 .bc cols .nsp 
	" * END * " .print 
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

| ftoken=(inc<<48)|(cnt<<40)|(pos<<24)|(xc<<12)|yc	
:showbreakpoint
	1 .bc 7 .fc 
	bplist ( d@+ 1? token>ftoken @ 
		dup 48 >>> codenow =? ( over tokenCursor ) 2drop
		) 2drop ;

|-------------------------------------
| ftoken=(inc<<48)|(cnt<<40)|(pos<<24)|(xc<<12)|yc
:ftokenIP
	codesrc vmIP 
	0? ( nip ; ) | check limits CODE
	1- 3 << + @ ;
	
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

	showpanel
	1 and? ( panelwatch )
	2 and? ( panelinclude )
	drop
	
	
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
		inkey 
		[esc] =? ( *>stop drop ; ) 
		[f5] =? ( *>stop ) 
		[f7] =? ( *>stop ) 
		[f8] =? ( *>stop ) 
		[f9] =? ( *>stop ) 
		drop 
		playshow
		) 
	$ff >? ( 
		ftokenIP dup 48 >> $ff and showcode
		24 >> $ffff and fuente + tuipos!	
		runtimerror ) 
	drop 
|	*>stop
| land in src
	( ftokenIP 48 >> $ff and codenow <>? 
		*>stepo drop ) drop 
	tuR! | redraw
	;
	

|-------------------------------------
#cm -1 | actual cursor

:remakecursor
	ftokenIP
	0? ( drop ; )
	cm =? ( drop ; )
	dup 'cm ! 
	dup 48 >> $ff and showcode
	dup 24 >> $ffff and fuente + tuipos!
|	tuiecursor!	
	tokenCursor
	;
	
:stepout
	vmIP memtokn
	$ff and 
	$86 =? ( drop *>stepu ; ) | word; ->jmp
	$23 =? ( drop *>step ; )
	drop
	*>stepo
	;
|---- main	
:maindb
	.reset .cls .ovec 
	
	1 flxN
	fx fy .at 4 .bc 'topline .write
	
	8 flxS
	fx fy .at 'statusline .write
	vmSTATE " state:%h" .print 
	vmIP memtokn " iptoken:%h" .print
	
	.cr scrMsg
	
	showpanel
	1 and? ( panelwatch )
	2 and? ( panelinclude )
	drop
	
	flxRest 
	tuReadCode 
	tuC! | show user cursor
	
	remakecursor
	showbreakpoint	
	
	uiKey
	[f3] =? ( breakpoint )
	[f4] =? ( viewmemhere ) 
	[f5] =? ( playmode )

	[f7] =? ( *>step )
	[f8] =? ( stepout )
	[f9] =? ( *>stepu )
	
	showpanel 0? ( swap tueKeyMove swap ) drop
	
	tolow
	$69 =? ( showpanel 2 xor 'showpanel ! ) |iI
	$77 =? ( showpanel 1 xor 'showpanel ! ) |wW
	drop 
	checkerror
	;

:main
	'filename run&loadinfo
	'filename makemapdebug
|---- build code links

	makelistwords
	|makelistinc
	
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