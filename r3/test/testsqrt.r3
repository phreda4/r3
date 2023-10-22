^r3/win/console.r3
^r3/lib/rand.r3

|---- method 1
:sql
	pick3 <=? (
		>r rot r> - | res one op
		rot pick2 2* +	| one op res
		2/ rot 2 >> ; )
	drop 2 >> swap 2/ swap ;
	
::sqrt1 | v -- r
	0? ( ; )
	0 $40000000 | op res one
	( pick2 >? 2 >> )
	( 1? 2dup + sql )
	drop nip ;
	
|---- method 2	
:SQrt2
  dup 1 ( over <? + 1 >> 2dup / ) 
  rot 2drop ;
	
|---- test	
:test
	1 'seed !

	20 ( 1?
		1000000 randmax 
		dup "%d " .print
		dup sqrt "%d " .print
		dup sqrt1  "%d " .print
		sqrt2  "%d " .print
		.cr
		1 - ) drop

	1 'seed !
	msec
	1000000 ( 1? 1000000 randmax sqrt drop 1 - ) drop
	msec swap - "sqrt %d" .println
		
	1 'seed !
	msec
	1000000 ( 1? 1000000 randmax sqrt1 drop 1 - ) drop
	msec swap - "sqrt1 %d" .println
	
	1 'seed !
	msec
	1000000 ( 1? 1000000 randmax sqrt2 drop 1 - ) drop
	msec swap - "sqrt2 %d" .println

	
	;

:
.cls
test
.input
;