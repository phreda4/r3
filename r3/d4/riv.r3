| Riv Ide Editor
| PHREDA 2026

^r3/lib/console.r3
^r3/lib/clipboard.r3
^r3/util/utfg.r3
|^r3/lib/trace.r3

#hashfile 
#filename * 1024

#src
#src>
#src$

#mode 0
#ncount	

#line * 2048
#linelen 10

#pad * 512
#msg * 512

#scrsize 0
:termx scrsize 36 >> $fff and ;
:termy scrsize 24 >> $fff and ;
:termw scrsize 12 >> $fff and ;
:termh scrsize $fff and ;

#cursor
:curx cursor $fff and ;
:cury cursor 12 >> $fff and ;
:viex cursor 24 >> $fff and ;
:viey cursor 36 >> $fff and ;

#strmodo " NOR " " INS " " REP " " VIS " " CMD "

:drawscreen
	.cls
	termh 2 -
	0 ( over <?
		dup "%h" .print .cr
		1+ ) drop 
	.rever
	termw .nsp
	mode 6 * 'strmodo + .write 
	ncount " %d " .print
	cury curx " %d:%d " .print
	.cr
	.reset
	mode 
	4 =? ( ":" .write ) | CMD mode
	drop
	'msg c@ 1? ( 'msg .write ) drop
	
	|cursor srview -
	cursor dup 24 >> - 
	dup $fff and swap 12 >> $fff and .at
	.flush
	;

:ccle
	curx 0? ( drop ; )  1- cursor $fff nand or 'cursor ! ;
:ccri
	curx linelen >? ( drop ; ) 1+ cursor $fff nand or 'cursor ! ;

:ccdn
	;
	
:ccup
	;
	
:kmove
	;
	

:kcount
	$30 $39 in? ( dup $30 - ncount 10* + 'ncount ! ) ;
	
|---NORMAL
:knor
	evtkey
	[esc] =? ( -1 'mode ! ) 
	kcount
	toUpp
	$49 =? ( 1 'mode ! ) | I
	$52 =? ( 2 'mode ! ) | R
	$56 =? ( 3 'mode ! ) | V
	$3A =? ( 4 'mode ! ) | :
	$2F =? ( 4 'mode ! ) | /
	$48 =? ( ccle ) |H
	$4A =? ( ccup ) |J
	$51 =? ( ccdn ) |K
	$4C =? ( ccri ) |L
	drop ;
	
|---INSERT
:kins
	evtkey
	[esc] =? ( 0 'mode ! ) 
	
	drop ;
|---REPLACE
:krep
	evtkey
	[esc] =? ( 0 'mode ! ) 
	
	drop ;
|---VISUAL
:kvis
	evtkey
	[esc] =? ( 0 'mode ! ) 
	
	drop ;
|---CMD
:kcmd
	evtkey
	[esc] =? ( 0 'mode ! ) 
	|[enter] =? ( ) |ejecuta
	
	drop ;

#kmode 'knor 'kins 'krep 'kvis 'kcmd

:hkey

:getevent
	inevt
	1 =? ( drop 'kmode mode 3 << + @ ex ; )
	| 2 =? ( hmou )
	drop
	20 ms getevent ;
	
:editor
	( drawscreen
		getevent
		mode -1 <>? drop
		) drop ;
	
|---------------	
:
	mark 
	here
	dup 'src ! $ffff +
	dup 'src$ ! $fff +
	'here
	src 'src> !
	0 'cursor !
	0 'mode !
	.alsb
	cols 12 << rows or 'scrsize !
	.ovec
	editor
	.masb 
	.free
	;