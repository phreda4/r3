| DEBUGER (style of r3repl)
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

|---------------- palette (true color, same as r3repl)
:bg0 0 0 0 .bgrgb ;
:bg1 24 24 28 .bgrgb ;
:bg2 36 36 42 .bgrgb ;
:bg3 56 56 66 .bgrgb ;
:fTx 238 238 238 .fgrgb ;
:fMu 140 140 152 .fgrgb ;
:fDi 88 88 98 .fgrgb ;
:fPr 250 178 131 .fgrgb ;
:fBl 92 156 245 .fgrgb ;
:fPu 157 124 216 .fgrgb ;
:fGr 127 216 143 .fgrgb ;
:fRd 224 108 117 .fgrgb ;
:fYe 245 167 66 .fgrgb ;

|-------------------------------------
:showcode | n --
	codenow =? ( drop ; ) dup 'codenow !
	inc2src TuLoadMemC

	.cl fMu
	codenow cntinc <? (
		strinc over n>>0 .write
		"  >  " .write
		) drop
	fTx 'filename .write
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

|------------------------ memory panel
#lmem
#panelMemSize 12
#panelMemBytes 32

:memdn		panelMemBytes 'lmem +! ;
:memup		panelMemBytes neg 'lmem +! ;
:mempgdn	panelMemBytes fh * 'lmem +! ;
:mempgup	panelMemBytes fh * neg 'lmem +! ;

:altcolor | n -- n ; alternate columns
	dup 1 and 0? ( drop fTx ; ) drop fMu ;

:linebytes
	panelMemBytes ( 1? altcolor 1- swap
		c@+ $ff and .h 2 .r. .write
		swap ) 2drop ;

:lineword
	panelMemBytes 1 >> ( 1? altcolor 1- swap
		w@+ $ffff and .h 4 .r. .write
		swap ) 2drop ;

:linedword
	panelMemBytes 2 >> ( 1? altcolor 1- swap
		d@+ $ffffffff and .h 8 .r. .write
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

:memmode | -- "str"
	linesn
	'linebytes =? ( drop "bytes" ; )
	'lineword =? ( drop "words" ; )
	'linedword =? ( drop "dwords" ; )
	drop "qwords" ;

:asciich | c --
	32 <? ( drop $2e .emit ; )
	127 >? ( drop $2e .emit ; )
	.emit ;

:linemem
	fBl dup $ffff and .h 4 .r. .write
	fDi "  " .write
	dup linesn ex
	"  " .write fMu 
	panelMemBytes ( 1? 1- swap
		c@+ $ff and asciich
		swap ) drop ;

:panelMem
	bg1 fx fy fw fh .boxf
	fx 1+ fy .at fPr .Bold "Memory" .write .NBold
	fMu lmem dup $ffff and swap 16 >> "  %h:%h" .print
	fx fw + 10 - fy .at fDi memmode .write
	1 'fy +! -1 'fh +!
	fx 1+ fy .at
	fw 12 - 3 / 'panelMemBytes !

	lmem
	fh ( 1? 1- swap
		linemem .cr fx 1+ .col
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
	.cl fRd "x " .write fTx
	errorst "runtime error %h  " .print fMu .strerr
	'statusline strcpybuf ;

:runtimeend
	.cl fGr "+ " .write fMu "program ended" .write
	'statusline strcpybuf ;

| play only in the source
:playmode
	0 'statusline c!
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

|------------------------- sidebar (registers, stacks, breakpoints, watch)
#fmt '.h

:chgfmt
	fmt
	'.h =? ( drop '.d 'fmt ! ; )
	'.d =? ( drop '.f 'fmt ! ; )
	'.f =? ( drop '.b 'fmt ! ; )
	drop
	'.h 'fmt ! ;

:fmtname | -- "str"
	fmt
	'.h =? ( drop "hex" ; )
	'.d =? ( drop "dec" ; )
	'.f =? ( drop "fix" ; )
	drop "bin" ;

#sdx 0 #sdy 0 #sde 0 #sdw 34 #sdl 0 #sds 0

:sline | "txt" --
	sdy sde <? ( drop sdx sdy .at .write 1 'sdy +! ; ) 2drop ;

:kv | "label" "value" --
	sdy sde <? ( drop
		fMu sdx sdy .at swap .write
		fTx sdx 8 + .col .write
		1 'sdy +! ; ) 3drop ;

:sec | "title" --
	1 'sdy +!
	fPr .Bold sline .NBold ;

:stk. | val --
	sdy sde >=? ( 2drop ; ) drop
	sdx sdy .at fmt ex 24 .r. .write 1 'sdy +! ;

:dtackcnt | -- cnt
	vmNOS mdatastack - 3 >> ;

:rstackcnt | -- cnt
	mretstack vmRTOS - 3 >> 1- ;

:.datastack
	fTx
	vmNOS
	mdatastack >? ( vmTOS stk. ) fMu
	dtackcnt sdl min 1- clamp0 swap
	dstackoff +
	( swap 1? 1- swap
		8 - dup @ stk.
		) 2drop ;

:.retstack
	fMu
	mretstack
	( 8 - vmRTOS >?
		dup rstackoff + |@
		stk.
		) drop ;

:limit+ | n -- ; limit the section to n lines
	sde 'sds !
	sdy + sde min 'sde ! ;

:limit- sds 'sde ! ;

:regs
	"Registers" sec
	"ip" vmIP .h kv
	"a" vmREGA .h kv
	"b" vmREGB .h kv
	"data" dtackcnt .d kv
	"return" rstackcnt .d kv ;

:tagfmt | -- ; format tag at the right of the title
	sdx sdw 6 - + 8 -
	sdy 1- .at fDi fmtname "[%s]" sprint .write ;

:datasec
	"Data stack" sec tagfmt
	sdy sdl limit+
	.datastack
	sdy =? ( fDi "(empty)" sline ) drop
	limit- ;

:retsec
	"Return stack" sec
	sdy sdl limit+
	.retstack
	sdy =? ( fDi "(empty)" sline ) drop
	limit- ;

:bpsec
	"Breakpoints" sec
	sdy 3 limit+
	fMu bplist ( d@+ 1? "$%h" sprint sline ) 2drop
	sdy =? ( fDi "(none)" sline ) drop
	limit- ;

:watchsec
	"Watch" sec
	fDi "(none)" sline ;

:drawside
	bg1 fx fy fw fh .boxf
	fx 2 + 'sdx ! fy 'sdy ! fy fh + 'sde !
	|fTx .Bold "r3debug" sline .NBold
	|fMu sdx sdy .at sdw 4 - 'filename lwrite 1 'sdy +!
	regs
	sde sdy - 8 - 2/ 2 max 'sdl !
	datasec retsec bpsec watchsec ;

|------------------------- header, status and footer
:drawhead
	bg0 fx fy .at fw .nsp
	fx 1+ fy .at fPr .Bold "# " .write fTx "r3debug" .write .NBold
	fMu "  -  " .write 'topline .write
	|bg0 fDi fx fy 1+ .at fw 45 .nch 
	;

:banner | status line, only when there is one
	'statusline c@ 0? ( drop ; ) drop
	1 flxN
	bg1 fx fy fw fh .boxf
	fx 1+ fy .at 'statusline .write bg0 ;

:key | "k" "label" --
	fTx swap .write fDi .write ;

:drawfoot
	bg0 fx fy .at fw .nsp
	fx 2 + fy .at
	"b" " breakpoint   " key
	"c" " continue   " key
	"r" " run cursor   " key
	"s" " step   " key
	"n" " next over   " key
	"o" " step out   " key
	"q" " quit" key
	fw 112 <? ( drop ; ) drop
	fx fw + 26 - fy .at
	"^f" " format   " key
	"enter" " memory" key ;

|------------------------- keys
:keyext
	[SHIFT+DN] =? ( memdn )
	[SHIFT+UP] =? ( memup )
	[SHIFT+PGDN] =? ( mempgdn )
	[SHIFT+PGUP] =? ( mempgup )
	|[SHIFT+TAB] =? ( changemem )
	drop ;

:keyctrl
	3 =? ( exit )	| CTRL+C
	4 =? ( exit )	| CTRL+D
	6 =? ( chgfmt )	| CTRL+F
	13 =? ( changemem ) | +M
	drop ;

:teclado
	uiKey
	tueKeyMove
	$7f >? ( keyext ; )
	32 <? ( keyctrl ; )
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
:calcsw
	cols 100 <? ( drop 28 'sdw ! ; ) drop 36 'sdw ! ;

:maindb
	.reset bg0 fTx .cls
	calcsw

	1 flxN
	drawhead
	banner

	1 flxS
	drawfoot

	sdw flxE
	drawside

	panelMemSize flxS
	panelMem

	flxRest .reset
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
