^r3/lib/console.r3
^r3/lib/math.r3

::exp | x -- r
	-1310720 <? ( drop 0 ; )
	1310720 >? ( drop -1 ; ) | -inf
	dup 94548 *. 0.5 + 16 >> 
	| r = x - n*LN2 (optimizado) | x n
	16 >> dup -rot	| n x n 
	16 << 45426 * - 	| n r
	91		| n r result ; 1/6!
	over *. 546 +	| n r result
	over *. 2731 +
	over *. 10923 +
	over *. 32768 +
	over *. 1.0 +
	over *. 1.0 + | n r result
	nip swap
	+? ( 47 >? ( 2drop -1 1 >>> ; ) << ; )
	-16 <? ( 2drop 0 ; )
	neg >> ;
	
::ln |x -- r 
	0 <=? ( drop -1 ; ) | -inf
	1.0 =? ( drop 0 ; ) 
	0 swap | n m
	( 2.0 >=? 2/ swap 1+ swap )
	( 0.5 <? 2* swap 1- swap )
	1.0 - dup 2.0 +	/. | n y
	dup dup *.	| n y y2
	8738	| n y y2 result
	over *. 10082 +
	over *. 11915 +
	over *. 14563 +
	over *. 18724 +
	over *. 26214 +
	over *. 43691 +
	over *. 2.0 + | n y y2 result
    nip *.			| n result
	swap 45426 * +
	;

:main
	-0.1 ( 1.0 <?
		dup "x:%f " .print
		dup exp. "| exp %f " .print
		dup exp "%f " .print
		" | ln: " .print
		dup ln. "%f " .print
		" | sqrt: " .print
		dup sqrt. "%f" .print
		.cr
		0.25 + ) drop
	( getch ]esc[ <>? drop ) drop
	;
	
: .cls
main
;