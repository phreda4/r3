| DEBUGER
| PHREDA 2026

^r3/util/tui.r3
^r3/util/tuiedit.r3

^r3/lib/memshare.r3
^./infodebug.r3

#filename * 1024

#topline * 256
#statusline * 256

| 0 - code
| 1 - mem
#modekey 0
#errorst 0

|--- for show in code
#codenow -1

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

:linemem
	7 .fc
	dup $ffff and 
	":" .write
	.h 4 .r. .write ":" .write
	dup linesn ex
	.sp
	panelMemBytes ( 1? 1- swap 
		c@+ 32 <? ( $2e nip ) .emit 
		swap ) drop ;
	
:panelMem
	.reset
	fx fy .at 
	modekey 1 =? ( fw .hline ) drop
	fx fy .at 
	lmem dup $ffff and swap 16 >> ": %h:%h " .print .cr
	
	1 'fy +! -1 'fh +!
	fw 11 - 3 / 'panelMemBytes !	
	
	lmem
	fh ( 1? 1- swap
		fx .col linemem .cr
		swap ) 2drop 

	modekey	1 <>? ( drop ; ) drop | mode 1
	uiKey
	[DN] =? ( memdn )
	[UP] =? ( memup )
	[PGDN] =? ( mempgdn )
	[PGUP] =? ( mempgup )
	[tab] =? ( 0 'modekey ! 0 'uiKey ! ) 
	toUpp
	
	drop ;

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

:panelIP
	.reset |fx fy 1+ .at fw .hline .cr
	fx fy .at 
	modekey 0 =? ( fw .hline ) drop
	.cr fx .col
	"D)" .write .datastack .cr
	fx .col
	"R)" .write .retstack .cr
	fx .col
	vmREGA	"A:%h | " .print vmREGB "B:%h " .print .cr
	
	|*** debug ***
	fx .col
	vmIP "IP:%h " .print 
	codenow "inc:%d" .print
	|vmIP memtok .write vmIP memtokn " %h" .print
	" | " .write  codesrc "cs:%h " .print vmIP "ip:%h " .print 
	codesrc vmIP 1- 3 << + @ ":%h:" .print
	.cr	
	fx .col
	bplist ( d@+ 1? "%h " .print ) 2drop
	;
	
|-----------------	
:maindb
	.reset .cls 
	
	1 flxN
	0 fy .at 7 .fc 4 .bc .eline 
	'topline .write
	|"DBG" .write
	
	1 flxS
	0 fy .at 7 .fc 4 .bc .eline  
	"|ESC| Exit " .write

	panelMemSize flxS
	panelMem
	
	20 flxO
	fx fw + 1- fy .at fh .vline 
	
	flxpush
	fx fy .at fw 1- .hline 
	fx fy .at "RET" .write
	
	14 flxS
	fx fy .at fw 1- .hline 
	fx fy .at "WATCH" .write 
	flxpop

	panelIPSize flxS
	panelIP
	
	flxRest	
	tuReadCode 
	remakecursor
	tuC! | show user cursor
	
	modekey	1? ( drop ; ) drop | mode 0
	uiKey
	tueKeyMove
	[tab] =? ( 1 'modekey ! ) 
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
	
:main
	|'filename "mem/menu.mem" load drop
	"r3/d4/test2.r3" 'filename strcpy
	
	'filename run&loadinfo
	'filename makemapdebug
	
	|dataini
	here 
	'lmem !
	
	cntinc showcode
	
	'maindb onTuia
	debugend
	;
	
: 
.alsb 
main
.masb .free 
;
