| r3 compiler
| pass 3 - calculate static flow of ejecution
| PHREDA 2018
|----------------
^./r3base.r3


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

|--------- caso !+ w!+ c!+
:nextis!+ | stack adr v -- stack adr v v
	over @ $ff and
	$52 <? ( ; ) $54 >? ( ; )  | !+ c!+ w!+
	drop over 4 - @ 8 >> 1 + nip dup
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
		@+ dup $ff and
		$c =? ( overcode ) | call word
		$d =? ( overcode ) | var
		$e =? ( overdire ) | dir word
		$f =? ( overdire ) | dir var
		2drop r> ) 2drop ;

:rdata | stack nro -- stack
	dic>toklen
	( 1? 1 - >r
		@+ dup $ff and
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
		4 - dup @
|        dup dic>adr @ "%w*" slog
        datacode
		) drop ;

