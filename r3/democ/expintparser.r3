| Experimental integer parsing
| from https://kholdstare.github.io/technical/2020/05/26/faster-integer-parsing.html
| PHREDA 2020
|-----------
^r3/win/console.r3

:10* | %1010
	1 << dup 2 << + ;
:100* | %1100100
	2 << dup 3 << dup 1 << + + ;
:10000*
	4 << dup 4 << dup 1 << dup 1 << dup 2 << + + + + ;
:100000000*
	10000* 10000* ;

::bswap
	dup 8 >> $ff00ff00ff00ff and
	swap 8 << $ff00ff00ff00ff00 and or
	dup 16 >> $ffff0000ffff and
	swap 16 << $ffff0000ffff0000 and or
	dup 32 >>> swap 32 << or ;

:parse8char | 'adr -- int
	@
|	bswap
	dup $f000f000f000f00 and 8 >>
	swap $f000f000f000f and 10 * +
	dup $ff000000ff0000 and 16 >>
	swap $ff000000ff and 100 * +
	dup $ffff00000000 and 32 >>
	swap $ffff and 10000 * +
	;

:parse16 | 'adr -- int
	dup 8 + parse8char
	swap parse8char 100000000 * +
	;

|---- fast decimal parse
#bufferparse 0 0 0 
#s 0 | use like mark !

:signo | str -- str signo
	dup c@
	$2b =? ( drop 1 + 0 's ! ; )	| + $2b
	$2d =? ( drop 1 + 1 's ! ; )	| - $2d
	drop 0 's ! ; 

:calcnbig | str nro buff -- str nro
	8 - 'bufferparse >? ( parse8char 100000000 * + ; ) drop ;
	
:calcn | buff str -- nro
	swap 8 - dup parse8char swap calcnbig 
	s 1? ( drop neg ; ) drop ;

:strest | str buff -- str nro
	swap ( c@+ $2f >? $3a <? drop ) drop
	1 - calcn ;

:str>dec | "" -- "" nro
	signo
	'bufferparse 8 +
	swap ( c@+ | buff str cc
		$2f >? $3a <? 
		rot c!+
		's =? ( strest ; ) | #s is end of #bufferparse
		swap ) drop
	1 - calcn ;
|----
	
:
	.cls 

	"0000000000001234" parse16
	"%d" .print .cr

	"0000000000012345" parse16
	"%d" .print .cr

	"0123456789012345" parse16
	"%d" .print .cr

	"1585201087123567" parse16
	"%d" .print .cr
	.cr
	
	"1234" str>dec "%d" .print .cr drop
	"12345" str>dec "%d" .print .cr drop
	"123456789012345" str>dec "%d" .print .cr drop
	"1585201087123567" str>dec "%d" .print .cr drop
	
	"-3m" str>dec "%d" .print .cr drop
	"12345678901234567890" str>dec "%d" .print .cr drop
	
	12345 10* "%d " .print .cr
	12345 100* "%d " .print .cr
	12345 1000* "%d " .print .cr
	.input
	;
