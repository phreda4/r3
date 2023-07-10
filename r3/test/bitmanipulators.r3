| many words for bit manipulator
| for examples
| PHREDA 2022
^r3/win/console.r3

:pext | x mask -- res
	0 >a 
	1 swap | x b mask
	( 1? 
		pick2 over dup neg and and
		1? ( pick2 a+ ) drop
		dup 1 - and
		swap dup + swap
		) 3drop
	a> ;

	
:pdep | x mask -- res
	0 >a
	( dup dup neg and | x mask lsb
		1? 
		pick2 63 << 63 >>
		over and a+
		not and
		swap 1 >> swap ) 3drop
	a> ;

:ctz | v -- c
	0? ( drop 32 ; )
	dup | v v
	1 -	| v v-1
	xor	| v^(v-1)
	1 >> | rshift
	0		| v c
	( swap 1? 1 >>> swap 1 + ) | c v
	drop ;

:ctz2 | v -- c
	32 		
	swap dup neg and		
	1? ( swap 1 - swap )
	$ffff and? ( swap 16 - swap )
	$ff00ff and? ( swap 8 - swap )
	$f0f0f0f and? ( swap 4 - swap )
	$33333333 and? ( swap 2 - swap ) | 001100110011
	$55555555 and? ( swap 1 - swap ) | 101010101010
	drop ;
	
:
 .cls
 $12345678 $ff00fff0 pext
 "$12345678 $ff00fff0 pext -- %h" .println
 
 $12567 $ff00fff0 pdep
 "$12567 $ff00fff0 pdep -- %h" .println 

$1000 ctz "$1000 ctz = %d" .println
$100 ctz "$100 ctz = %d" .println
$10 ctz "$10 ctz = %d" .println
$1 ctz "$1 ctz = %d" .println

$1000 ctz2 "$1000 ctz2 = %d" .println
$100 ctz2 "$100 ctz2 = %d" .println
$10 ctz2 "$10 ctz2 = %d" .println
$1 ctz2 "$1 ctz2 = %d" .println

-1 1 >> "-1 1 >> %d" .println
-1 1 >>> "-1 1 >>> %d" .println
314 2 100 */ "-1 1 >>> %d" .println

waitesc
	;