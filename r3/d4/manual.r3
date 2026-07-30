| view manual
| PHREDA 2026
^r3/lib/console.r3
^r3/util/tui.r3

#manual
#imanual
#cmanual
#nman 0

| * *	negrita
| ** ** italica
| ` ` codigo
:emitline | l --
	$fffff and manual + 
	( c@+ $ff and 32 >=? 
		
	
		.emit ) 2drop ;

:nor
	.reset
	emitline ;

:tit1 :tit2
	3 .fc
	.Bold .Cyan .Under
	emitline ;

:tit3
	3 .fc
	.Bold .Cyan
	emitline ;

:tit4
	3 .fc
	emitline ;
	
:lin
	drop 
	.reset .sp fw 2 - .hline ;
	
:bul
	4 .fc " * " .write 
	emitline ;
	
:bla	
	5 .fc " | " .write 
	emitline ;
	

:cod	
	8 .fc
	.savec 2 .nsp fw 2 - .hline .restorec
	"  " .write emitline ;
	
:codl 
	8 .fc 
	" |" .write
	emitline ;
	
:tab
	8 .fc
	emitline ;
		
#typeline 'nor 'tit1 'tit2 'tit3 'tit4 'lin 'bul 'bla 'cod 'codl 'tab

:viewline | n --
	cmanual >=? ( drop ; ) 
	2 << imanual + d@ |dup "%h :" .print
	dup 17 >> $78 and 'typeline + @ ex ;
	
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
	4 min 'flag +! | 1..4
	drop $23 ;
	
|- |
|* |
|---
:bull | -/*
	drop
	dup d@ $ffffff and
	$2d2d2d =? ( $5 'flag +! drop >>cr 1- 13 ; )
	8 >> $ff and
	$20 <>? ( drop $2d ; ) drop
	$6 'flag +! | bullet
	2 + $2d ;
	
|> |	
:blac | >
	over 1+ c@
	$20 <>? ( drop ; ) 2drop
	$7 'flag +! | bullet
	2 + $3e ;
	
|~~~
|```
:code | ~
	over d@ $ffffff and
	$606060 <>? ( drop ; ) drop
	$8 'flag +!
	$900 flag xor 'flag !
	swap 3 + swap
	;

:codel | ~
	$9 'flag +!
	;
	
|| |
:tabl | |
	$A 'flag +!
	;
	
|-------------------
:lenesc | adr car -- adr
	drop c@+
	$5b =? ( ( drop c@+ $ff and 64 >=? 127 <=? ) ) |esc
	drop ;
	
:lencar | adr car -- adr
	27 =? ( lenesc ; )
	$5c =? ( drop 1+ ; ) |\
	$2a =? ( drop 1+ ; ) |*
	$60 =? ( drop 1+ ; ) |''
	drop 
	swap 1+ swap
	;
	
:lenreal | adr -- count
	0 swap ( c@+ $ff and 13 >?
		lencar
		) 2drop ;
|-------------------	
	
:addlen | adr off flag -- adr off len|flag --
	|pick2 lenreal
	10
	$ff and 24 << or
	;
	
:parseline | adr -- 
	dup c@ 0? ( drop 1+ ; ) 
	flag $ff00 and 'flag !
	$23 =? ( titu ) | #
	$2d =? ( bull ) | -
	$2a =? ( bull ) | *
	$3e =? ( blac ) | >
	$7e =? ( code ) | ~
	$60 =? ( code ) | `
	$7c =? ( tabl ) | |
	over manual - 
	flag $ff00 and? ( $ff nand? ( 8 >> ) )
	$f and 
	7 >? ( addlen )
	20 << or da!+
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
	a> dup imanual - 2 >> 'cmanual !
	'here !
	'viewmanual onTui 
	;
	
: main ;