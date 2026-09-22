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

|------------------------
#lmem
#cntbytes 32

:memdn		cntbytes 'lmem +! ;
:memup		cntbytes neg 'lmem +! ;
:mempgdn	cntbytes fh * 'lmem +! ;
:mempgup	cntbytes fh * neg 'lmem +! ;

:altcolor
	7 over 1 and + .fc ;

:linebytes
	cntbytes ( 1? altcolor 1- swap 
		c@+ .h 2 .r. .write 
		swap ) 2drop ;

:lineword
	cntbytes 1 >> ( 1? altcolor 1- swap 
		w@+ .h 4 .r. .write 
		swap ) 2drop ;

:linedword
	cntbytes 2 >> ( 1? altcolor 1- swap 
		d@+ .h 8 .r. .write 
		swap ) 2drop ;

:lineqword
	cntbytes 3 >> ( 1? altcolor 1- swap 
		@+ .h 16 .r. .write 
		swap ) 2drop ;
	
#linesn	'linebytes

:linemem
	7 .fc
	dup |$ffff and 
	.h 8 .r. .write " " .write
	dup linesn ex
	" " .write
	cntbytes ( 1? 1- swap 
		c@+ 32 <? ( $2e nip ) .emit 
		swap ) drop ;
	
:panelMem
	fx fy .at
	lmem
	fh ( 1? 1- swap
		fx .col linemem .cr
		swap ) 2drop 
	uiKey
	[DN] =? ( memdn )
	[UP] =? ( memup )
	[PGDN] =? ( mempgdn )
	[PGUP] =? ( mempgup )
	drop ;


:maindb
	.reset .cls 
	
	1 flxN
	0 fy .at 7 .fc 4 .bc .eline 
	'topline .write
	|"DBG" .write
	
	1 flxS
	0 fy .at 7 .fc 4 .bc .eline  
	"|ESC| Exit " .write

	.reset
	12 flxS
	fx fy .at fw .hline 
	|fx fy .at "MEM" .write
	1 'fy +! -1 'fh +!
	panelMem
	
	20 flxO
	fx fw + 1- fy .at fh .vline 
	
	flxpush
	fx fy .at fw 1- .hline 
	fx fy .at "WATCH" .write
	
	14 flxS
	fx fy .at fw 1- .hline 
	fx fy .at "RET" .write 
	flxpop

	6 flxS
	fx fy .at fw .hline 
	|fx fy .at "IP" .write
	
	flxRest
	|fx fy .at "CODE" .write
	tuReadCode 
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
	
	'maindb onTui
	debugend
	;
	
: 
.alsb 
main
.masb .free 
;
