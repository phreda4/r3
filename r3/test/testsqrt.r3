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
:speedi
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

|    r = (int32_t)v; q = 0; b = 0x40000000UL;
|    while( b != 0x40 ) {
|        t = q + b;
|        if( r >= t ) {
|            r -= t;
|            q = t + b; // equivalent to q += 2*b
|            }
|        r <<= 1;
|        b >>= 1;
|        }
|    q >>= 8;
|    return q;	
:sqrt.2	|
	0 $40000000 | r q b
	( $40 <>?
		2dup +	| r q b t
		pick3 <=? ( 2swap | b t r q
			drop over -	| b t r-t
			rot rot | r b t 
			2dup +
			rot rot )
		drop	| r q b
		rot 1 << rot rot 1 >> ) drop
	8 >> nip ;

:sq
	pick2 <=? ( swap 1 + >r - r> ; ) drop ;	

:sqrt. | n -- v
	1 <? ( drop 0 ; )
	0 0 rot | root remhi remlo | 31 + bits/2
	40 ( 1? 1 - >r
		dup 62 >> $3 and	| ro rh rl rnh
		rot 2 << or			| ro rl rh
		swap 2 << swap
		rot 1 << dup 1 << 1 +		| rl rh ro td
		sq | rl rh ro
		swap rot r> )
    3drop ;
	
:sqrt.3
  dup 1.0 ( over <? + 1 >> 2dup /. ) 
  rot 2drop ;
  
:speedf
	1 'seed !
	msec
	1000000 ( 1? 1000000 randmax sqrt. drop 1 - ) drop
	msec swap - "sqrt. %d" .println
	
	1 'seed !
	msec
	1000000 ( 1? 1000000 randmax sqrt.2 drop 1 - ) drop
	msec swap - "sqrt.2 %d" .println

	1 'seed !
	msec
	1000000 ( 1? 1000000 randmax sqrt.3 drop 1 - ) drop
	msec swap - "sqrt.3 %d" .println	
	;
	
:test
	1 'seed !

	20 ( 1?
		100.0 randmax 
		dup "%f " .print
		dup sqrt. "%f " .print
		dup sqrt.2 "%f " .print
		dup sqrt.3 "%f " .print
		drop
		.cr
		1 - ) drop
	speedf		
	;

:
.cls
test
.input
;