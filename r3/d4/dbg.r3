| DEBUGER
| PHREDA 2026

^r3/util/tui.r3
^r3/util/tuiedit.r3

^r3/lib/memshare.r3
^./infodebug.r3

#filename * 1024

#topline * 256
#statusline * 256

#errorst 0

|--- for show in code
#codenow -1

::bg0 $000 rgb4t .bc ;
::bg1 $112 rgb4t .bc ;
::bg2 $222 rgb4t .bc ;
::bg3 $334 rgb4t .bc ;
::fTx $EEE rgb4t .fc ;
::fMu $889 rgb4t .fc ;
::fDi $556 rgb4t .fc ;
::fPr $FA8 rgb4t .fc ;
::fBl $59E rgb4t .fc ;
::fPu $97D rgb4t .fc ;
::fGr $7D8 rgb4t .fc ;
::fRd $D67 rgb4t .fc ;
::fYe $EA4 rgb4t .fc ;
::fb2 $222 rgb4t .fc ;

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
#lastIP -1 

:ftokenIP
	vmIP 0? ( ; ) | check limits CODE
	1- 3 << codesrc + @ ;

:remakecursor
	vmIP 0? ( drop ; ) | check limits CODE
	lastIP =? ( drop ; ) 
	dup 'lastIP !
	1- 3 << codesrc + @ 
	dup 48 >> $ff and showcode
	dup 24 >> $ffff and fuente + tuipos!
	tokenCursor
	;
|------------------------
#lmem
#panelMemSize 12
#panelMemBytes 32

:memdn		panelMemBytes 'lmem +! ;
:memup		panelMemBytes neg 'lmem +! ;
:mempgdn	panelMemBytes fh * 'lmem +! ;
:mempgup	panelMemBytes fh * neg 'lmem +! ;

:altcolor
	7 over 1 and + .fc ;

:linebytes
	panelMemBytes ( 1? altcolor 1- swap 
		c@+ .h 2 .r. .write 
		swap ) 2drop ;

:lineword
	panelMemBytes 1 >> ( 1? altcolor 1- swap 
		w@+ .h 4 .r. .write 
		swap ) 2drop ;

:linedword
	panelMemBytes 2 >> ( 1? altcolor 1- swap 
		d@+ .h 8 .r. .write 
		swap ) 2drop ;

:lineqword
	panelMemBytes 3 >> ( 1? altcolor 1- swap 
		@+ .h 16 .r. .write 
		swap ) 2drop ;
	
#linesn	'linebytes

:changemem
	linesn
	'lineqword =? ( drop 'linebytes 'linesn ! ; )
	'linedword =? ( 'lineqword nip )
	'lineword =? ( 'linedword nip )
	'linebytes =? ( 'lineword nip )
	'linesn ! ;

:linemem
	5 .fc
	dup $ffff and 
	" :" .write
	.h 4 .r. .write ":" .write
	dup linesn ex
	.sp
	panelMemBytes ( 1? 1- swap 
		c@+ 32 <? ( $2e nip ) .emit 
		swap ) drop ;
	
:panelMem
	.reset
	fx fy .at 5 .fc
	lmem dup $ffff and swap 16 >> " DUMP %h:%h " .print .eline .cr
	.reset
	1 'fy +! -1 'fh +!
	fw 11 - 3 / 'panelMemBytes !	
	
	lmem
	fh ( 1? 1- swap
		fx .col linemem .cr
		swap ) 2drop 
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
|MAC|	$4 =? ( "Illegal instruction" .write )
|MAC|	$6 =? ( "Abort" .write )
|MAC|	$a =? ( "Bus error (invalid memory)" .write )
|MAC|	$8 =? ( "Divide by 0 / FP error" .write )
|MAC|	$b =? ( "Invalid memory (segfault)" .write )
|MAC|	$d =? ( "Broken pipe" .write )
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
		|playshow
		
		) 
	$ff >? ( 
		ftokenIP 
		dup 48 >> $ff and showcode
		24 >> $ffff and fuente + tuipos!	
		runtimerror ) 
	drop 
|	*>stop
| land in src
	( ftokenIP 1? | 0=break
		48 >> $ff and codenow <>? 
		*>stepo drop ) drop 
	tuR! | redraw
	;

:runtocursor
	fuente> fuente - | pos in src
	findtoken
	ftoken>token 
	dup addBP
	playmode		
	delBP
	;
	

	
:stepout
	vmIP memtokn
	$ff and 
	$86 =? ( drop *>stepu ; ) | word; ->jmp
	$23 =? ( drop *>step ; )
	drop
	*>stepo
	;


|-------------------------
#panelIPSize 6
	
:.stk | val --
	fx .col 
	.h 8 .r. .write .cr ;
	
:dtackcnt | -- cnt
	vmNOS mdatastack - 3 >> ;
	
:rstackcnt | -- cnt
	mretstack vmRTOS - 3 >> 1- ;
	
:.datastack
	vmNOS 
	mdatastack >? ( vmTOS .stk ) 
	dtackcnt fh min 1- clamp0 swap
	dstackoff +
	( swap 1? 1- swap
		8 - dup @ 
		.stk
		) 2drop ;

:.retstack
	mretstack 
	( 8 - vmRTOS >? 
		dup rstackoff + |@ 
		.stk
		) drop ;
	
:panelIP
	.reset |fx fy 1+ .at fw .hline .cr
	flxpush
	20 flxO fx fy .at
	2 .fc
	fx .col "   IP:" .write vmIP .h 8 .r. .write .sp .cr
	"  RET STK:" .write rstackcnt .d 4 .r. .write .sp .cr
	
	3 .fc
	fx .col "    A:" .write vmREGA .h 8 .r. .write .sp .cr
	fx .col "    B:" .write vmREGB .h 8 .r. .write .sp .cr
	" DATA STK:" .write dtackcnt .d 4 .r. .write .sp .cr
	
	20 flxO fx fy .at .rev
	3 .fc
	.datastack
	
	20 flxO fx fy .at
	2 .fc
	.retstack
	
	flxRest fx fy .at
	15 .fc 1 .bc
	fx .col bplist ( d@+ 1? 
		fx .col " %h " .print .cr
		) 2drop
	|*** debug ***
|	codenow "inc:%d" .print
	|vmIP memtok .write vmIP memtokn " %h" .print
|	" | " .write  codesrc "cs:%h " .print vmIP "ip:%h " .print 
|	codesrc vmIP 1- 3 << + @ ":%h:" .print
|	.cr	
	
	flxpop
	;
	
:keyext
	[SHIFT+DN] =? ( memdn )
	[SHIFT+UP] =? ( memup )
	[SHIFT+PGDN] =? ( mempgdn )
	[SHIFT+PGUP] =? ( mempgup )
	[SHIFT+TAB] =? ( changemem )	
	drop
	;
	
:teclado
	uiKey
	tueKeyMove
	$7f >? ( keyext ; )
	toUpp
	$42 =? ( breakpoint )	| B breakpoint
	$43 =? ( playmode )		| C continue
	
	$4E =? ( stepout )		| N step over (next)`
	$4F =? ( *>stepu )		| O step out
	$51 =? ( exit ) 		| Q uit
	$52 =? ( runtocursor )	| R un to cursor
	$53 =? ( *>step )		| S	
	drop 
	;	
	
|-----------------	
:maindb
	.reset .cls 
	
	1 flxN
	8 .bc 15 .fc 
	0 fy .at 
	'topline .write .eline 
	|"DBG" .write
	
	1 flxS
	0 fy .at .sp 
	.rev "B" .write .nrev "reakpoint  " .write 
	.rev "C" .write .nrev "ontinue  " .write 
	.rev "R" .write .nrev "uncursor  " .write 
	.rev "S" .write .nrev "tep  " .write
	.rev "N" .write .nrev "extover  " .write 
	"step" .write .rev "O" .write .nrev "ut  " .write 
	.rev "Q" .write .nrev "uit" .write 
	.eline
	
	panelMemSize flxS 
	panelMem
	
	20 flxE .reset
	|fx fy .at fw 1- .hline 
	fx fy .at " WATCH" .write 

	panelIPSize flxS
	panelIP
	
	flxRest	.reset
	tuReadCode 
	remakecursor
	tuC! | show user cursor
	showbreakpoint
	
	teclado
	;


	
:main
	|'filename "mem/menu.mem" load drop
	"r3/d4/test2.r3" 'filename strcpy
	
	'filename run&loadinfo
	'filename makemapdebug
	
	|makelistwords
	|makelistinc
	|makelistret 
	
	|dataini
	here 
	'lmem !
	
	clearbp
	
	cntinc showcode
	
	'maindb onTuia
	debugend
	;
	
: 
.alsb 
main
.masb .free 
;
