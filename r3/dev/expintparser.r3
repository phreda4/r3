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

:
	.cls 

	"0000000000001234" parse16
	"%d" .print cr

	"0000000000012345" parse16
	"%d" .print cr

	"0123456789012345" parse16
	"%d" .print cr

	"1585201087123567" parse16
	"%d" .print cr
	
	12345 10* "%d " .print cr

	.input
	;
