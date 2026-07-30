| view manual
| PHREDA 2026
^r3/lib/console.r3
^r3/util/tui.r3

#manual
#imanual
#cmanual
#nman 0

| * *	
| ** **
| ` `
:emitline | adr --
	( c@+ $ff and 32 >=? 
		.emit ) 2drop ;

:nor
	.reset
	$ffff and manual + emitline ;

:tit1 :tit2
	3 .fc
	$ffff and manual + emitline ;

:tit3
	3 .fc
	$ffff and manual + emitline ;

:tit4
	3 .fc
	$ffff and manual + emitline ;
	
:lin
	drop 
	.reset fw .hline ;
	
:bul
	4 .fc " * " .write 
	$ffff and manual + emitline ;
	
:codl 
	8 .fc 
	.savec fw .hline .restorec
	$ffff and manual + emitline ;

:cod	
	8 .fc
	$ffff and manual + emitline ;
	
:tab
	8 .fc
	$ffff and manual + emitline ;
		
#typeline 'nor 'tit1 'tit2 'tit3 'tit4 'lin 'bul 'codl 'cod 'tab

:viewline | n --
	cmanual >=? ( drop ; ) 
	3 << imanual + @ |dup "%h :" .print
	dup 16 >> 3 << 'typeline + @ ex ;
	
:viewmanual
	.reset .cls 
	1 flxS
	2 fy .at "|ESC| Exit " .write
	flxrest
	tuwin $1 " Manual " .wtitle
	1 1 flpad
	manual 
	0 ( fh <?
		fx fy pick2 + .at	
		dup nman + viewline 
		1+ ) drop
		
	uiKey
	[up] =? ( nman 1- 0 max 'nman ! )
	[dn] =? ( nman 1+ cmanual fh - min 'nman ! )
	[pgup] =? ( nman fh - 0 max 'nman ! )
	[pgdn] =? ( nman fh + cmanual fh - min 'nman ! )	
	drop		
	;

|------------------------------
#intable
#incode
#flag

|##
|###
|####
:titu | #
	drop
	0 over ( c@+ $23 =? drop swap 1+ swap ) | adr cnt adr' last
	$20 <>? ( 3drop $23 ; ) drop | adr cnt adr'
	-rot 
	4 min 16 << 'flag ! | 1..4
	drop $23 ;
	
|- |
|* |
|---
:bull | -/*
	drop
	dup d@ | adr D
	$ffffff and
	$2d2d2d =? ( $50000 'flag ! drop >>cr 1- 13 ; )
	8 >> $ff and
	$20 <>? ( drop $2d ; ) drop
	$60000 'flag ! | bullet
	2 + $2d ;
	
|> |	
:blac | >
	over 1+ c@
	$20 <>? ( drop ; ) 2drop
	2 + $3e ;
	
|~~~
|```
:code | ~
	$70000 'flag !
	;
	
|| |
:tabl | |
	$90000 'flag !
	;

:parseline | adr -- 
	dup c@ 0? ( drop 1+ ; ) 
	0 'flag !
	$23 =? ( titu ) | #
	$2d =? ( bull ) | -
	$2a =? ( bull ) | *
	$3e =? ( blac ) | >
	$7e =? ( code ) | ~
	$60 =? ( code ) | `
	$7c =? ( tabl ) | |
	over manual - flag or a!+
	13 =? ( swap 1+ swap )
	( 13 <>? drop c@+ ) drop
	parseline ;
	
:main
	mark
	here dup 'manual !
	"doc/r3forth-manual.md" load 0 swap c!
	here only13 0 swap c!+
	dup >a 'imanual !
	manual parseline
	a> dup imanual - 3 >> 'cmanual !
	'here !
	'viewmanual onTui 
	;
	
: main ;