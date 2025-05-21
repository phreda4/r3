| base64 encode/decode
| PHREDA 2025
|
^r3/lib/math.r3

#d (
66 66 66 66 66 66 66 66 66 64 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 
66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 62 66 66 66 63 52 53 
54 55 56 57 58 59 60 61 66 66 66 65 66 66 66  0  1  2  3  4  5  6  7  8  9 
10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 66 66 66 66 66 66 26 27 28 
29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 66 66 
66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 
66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 
66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 
66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 
66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 66 
66 66 66 66 66 66
)

:trimb 
	( c@+ 64 <? drop ) drop 1- ;

:decode | acc adr nro -- acc adr 
	64 =? ( drop ; )			| space
	66 =? ( drop 0 over c! ; )	| error
	65 =? ( drop 0 over c! ; )	| end data
	rot 6 << or
	$1000000 and? (
		dup 16 >> ca!+
		dup 8 >> ca!+
		ca!+
		1 )
	swap ;

::base64decode | src dest -- 'dest
	>a
	trimb
	1 swap
	( c@+ 1? 
		$ff and 'd + c@ decode
		) 2drop 
	$40000 and? (
		dup 10 >> ca!+
		2 >> ca!+
		a> ; )
	$1000 and? (
		4 >> ca!+
		a> ; )
	drop a> ;
	
#base64 "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	
:encode!+
	$3f and 'base64 + c@ ca!+ ;
	
::base64encode | len src dest -- 'dest
	>a >b
	( 3 >=? 
		cb@+ 
		dup 2 >> 
		encode!+
		cb@+
		swap $3 and 4 << over 4 >> $f and or
		encode!+
		cb@+
		swap $f and 2 << over 6 >> $3 and or 
		encode!+
		encode!+
		3 - ) 
	0? ( drop a> ; )
	cb@+ 
	dup 2 >> 
	encode!+
	swap 1 =? ( 
		drop $3 and 4 << 
		encode!+
		a> ; ) drop
	cb@+
	swap $3 and 4 << over 4 >> $f and or
	encode!+
	$f and 2 <<
	encode!+
	a> ;
	
