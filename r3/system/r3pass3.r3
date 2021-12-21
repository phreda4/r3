| r3 compiler
| pass 3 
| traverse code from :
| calculate static flow of ejecution
|
| PHREDA 2018
|----------------
^r3/system/r3base.r3


|----------------------------
|---- Arbol de llamadas
|----------------------------
:overcode | stack adr tok ctok -- stack adr .tok .ctok
	drop 8 >> dup
	dic>inf dup
	@ dup $1000 + rot !		| +call
	$3ff000 and 1? ( ; )	| n v
	drop rot !+ swap
	dup dup ;

|--------- caso !+ c!+ w!+ d!+ 
:nextis!+ | stack adr v -- stack adr v v
	over d@ $ff and
	$55 <? ( ; ) $58 >? ( ; ) | "!+" "C!+" "W!+" "D!+" 
	drop over 4 - d@ 8 >> 1 + nip dup
	dic>inf dup
	@ dup $1000 + $4 or rot !	| set adr!
	$3ff000 and 1? ( ; )
	drop rot !+ swap
	dup dup ;

:overdire | stack adr tok ctok -- stack adr .tok .ctok
	drop 8 >> dup
	dic>inf dup
	@ dup $1000 + $4 or rot !		| +call y adr!
	$3ff000 and 1? ( drop nextis!+ ; )	| n v
	drop rot !+ swap
	dup nextis!+ ;

:rcode | stack nro -- stack
	dic>toklen
	( 1? 1 - >r
		d@+ dup $ff and
		$c =? ( overcode ) | call word
		$d =? ( overcode ) | var
		$e =? ( overdire ) | dir word
		$f =? ( overdire ) | dir var
		2drop r> ) 2drop ;

:rdata | stack nro -- stack
	dic>toklen
	( 1? 1 - >r
		d@+ dup $ff and
|		dup "%h " .print
		$c >=? ( $f <=? ( overdire ) )
		2drop r> ) 2drop ;


:datacode
	dup dic>inf @ 1 and? ( drop rdata ; )
	drop rcode ;

::r3-stage-3 | --
	| ...arbol de llamadas...
	cntdef 1 -
	dup dic>inf dup @ $1000 + swap ! | marca ultima palabra
	here !+
	( here >?
		8 - dup @
|        dup dic>adr @ "%w " .print 
        datacode
		) drop 	;
