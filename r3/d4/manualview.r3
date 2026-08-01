| view .md files
| PHREDA 2026
^r3/lib/console.r3
^r3/util/tui.r3

#manual
#imanual
#cmanual

#nman 0


#mrever
:rever mrever 1 xor 1 and? ( .rever 'mrever ! ; ) .nrever 'mrever ! ; 


| * *	negrita
| ** ** italica
| ` ` codigo
:emitline | l --
	$fffff and manual + 
	( c@+ $ff and 32 >=? 
|		$2a =? ( drop 1+ ; ) |*
		|$60 =? ( drop c@+ rever ) |''
		$5c =? ( drop c@+ ) |\
		.emit ) 2drop ;

:,rever 
	mrever 1 xor 1 and? ( 
	$5b1b ,w "7m" ,s 'mrever ! ; ) 
	$5b1b ,w "27m" ,s 'mrever ! ; 
		
:emitfield | v -- v' str
	$fffff and manual + 
	( c@+ $ff and 32 >=? 
|		$2a =? ( drop 1+ ; ) |*!!
		|$60 =? ( drop 32 dup ,c ,rever ) |''!!
		$7c <>?  | |
		$5c =? ( drop c@+ ) |\
		,c ) drop 
	0 ,c
	manual - 
	;
	

:nor
	.reset emitline ;

:tit1 :tit2
	fw over 24 >> $ff and - 2/ 32 swap .nch | center
	|dup 24 >> $ff and "%d:" .print
	.Bold 14 .fc .Under emitline ;

:tit3
	.sp .Bold 14 .fc emitline ;

:tit4
	14 .fc emitline ;
	
:lin
	drop .reset .sp fw 2 - .hline ;
	
:bul
	9 .fc " * " .write emitline ;
	
:bla	
	5 .fc " │ " .write emitline ;
	
:codi
	"  " .write 
	12 .fc
	.savec fw 5 - "─" .rep "┐" .write .restorec
	"┌" .write emitline ;

:codf	
	"  " .write 
	12 .fc
	.savec fw 5 - "─" .rep "┘" .write .restorec
	"└" .write emitline ;
	
:codl 
	.sp .sp
	12 .fc "│" .write
	.savec 32 fw 6 - .nch "│" .write .restorec
	emitline ;
	
:tab
	dup 24 >> $ff and 1 max
	fw over / | cnt len
	32 over 2/ .nch | espacio
	4 .bc 7 .fc
	swap 1- ( 1? 	| v len cnt
		mark
		rot 				| len cnt v
		here >r emitfield	| len cnt v 
		-rot
		over r> cwrite | len str
		empty
		1- 1? ( "│" .write )
		) 3drop 
	.reset ;
	
	
:tabl	
	24 >> $ff and 1 max
	fw over / | cnt len
	32 over 2/ .nch | espacio
	4 .bc 7 .fc
	swap 1- ( 1? 
		over "─" .rep 
		1- 1? ( "┼" .write )
		) 2drop .reset ;
		
#typeline 'nor 'tit1 'tit2 'tit3 'tit4 'lin 'bul 'bla 'codi 'codf 'codl 'tab 'tabl

:viewline | n --
	cmanual >=? ( drop ; ) 
	2 << imanual + d@ |dup "%h :" .print
	dup 17 >> $78 and 'typeline + @ ex ;
	
::viewmanual
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
	
::gomanual | nro --
	'nman ! ;
	
	
|------------------------------
#intable
#incode
#flag

:titu | # |## |### |####
	drop
	0 over ( c@+ $23 =? drop swap 1+ swap ) | adr cnt adr' last
	$20 <>? ( 3drop $23 ; ) drop | adr cnt adr'
	-rot 
	4 min 'flag +! | 1..4
	drop $23 ;
	
|- ||* ||---
:bull | -/*
	drop
	dup d@ $ffffff and
	$2d2d2d =? ( $5 'flag +! drop >>cr 13 ; )
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
	
|~~~ |```
:code | ~
	over d@ $ffffff and
	$606060 <>? ( drop ; ) drop
	$8 'flag +!
	flag 
	$A00 xor 
	$8 =? ( 1+ )
	'flag !
	swap 3 + swap
	;

:isline | adr -- 0/13
	( c@+ 13 >? 
		$7c =? ( $2d nip )
		$2d <>? ( 2drop 0 ; )
		drop ) nip ;
|| |
:tabl | |
	swap 1+ swap 
	over isline
	13 =? ( drop $c 'flag +! ; )
	drop $b 'flag +! 
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

	
:addlen | adr off flag -- adr off len|flag --
	over manual + lenreal
	$ff and 4 << or
	;
	
|-------------------		
:lensep
	1 swap ( c@+ $ff and 13 >? 
		$5c =? ( drop 1+ c@+ )
		$7c =? ( rot 1+ -rot ) 
		drop
		) 2drop ;

:addsep	| adr off flag -- adr off len|flag --
	over manual + lensep
	$ff and 4 << or
	;
	
|-------------------	
	
:parseline | adr -- 
	dup c@ 0? ( 2drop ; ) 
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
	$B <? ( addlen )
	$B >=? ( addsep )
	20 << or da!+
	13 =? ( swap 1+ swap )
	( 13 <>? drop c@+ ) drop
	parseline ; | really loop
	
::loadmanual
	mark
	here dup 'manual !
	"doc/r3forth-manual.md" load 0 swap c!
	here only13 0 swap c!+
	dup >a 'imanual !
	manual parseline
	a> dup imanual - 2 >> 'cmanual !
	'here !
	;
	
