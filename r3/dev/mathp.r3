^r3/lib/console.r3
^r3/lib/math.r3
^r3/lib/rand.r3
	
:aprox | x exp -- exp y
	0 >=? ( swap over >> ; ) 
	swap over neg << ;
	
::log2 | x -- r ;(fixed48_16_t x) {
	0 <=? ( -1 nip ; )
	dup msbl 16 - | x exp
	aprox | exp y
	0 0.5 rot | exp frac b y
	16 ( 1? 1- >r
		dup *. |16 *>>	| exp frac b yy
		2.0 >=? ( 2/ rot pick2 + -rot )
		swap 2/ swap
		r> ) drop
	2drop
	swap 16 << + ;

    
:aprox | bits -- y
	16 >=? ( 15 - 2/ 1.0 swap >> ; ) 
	-17 + 2/ 1.0 swap << ;
	
::sqrt2 | (fixed48_16_t x) {
	0 <=? ( 0 nip ; ) 1.0 =? ( ; )
	dup msbl aprox	| x y
	dup dup 16 *>> pick2 16 *>>	| x y xy2
	3.0 swap - 17 *>>			| x y
	dup dup 16 *>> pick2 16 *>>	| x y xy2
	3.0 swap - 17 *>>			| x y
	dup dup 16 *>> pick2 16 *>>	| x y xy2
	3.0 swap - 17 *>>			| x y
	dup dup 16 *>> pick2 16 *>>	| x y xy2
	3.0 swap - 17 *>>			| x y
	16 *>> ;

:speed1
	msec
	7 'seed !
	10000000 ( 1? 1-
		10.0 randmax sqrt. drop
		) drop
	msec swap - "%d msec" .println

	msec
	7 'seed !
	10000000 ( 1? 1-
		10.0 randmax sqrt2 drop
		) drop
	msec swap - "%d msec" .println
	;
	

:calc1
	10 ( 1? 1- 
		1 62 randmax <<
		63 over msbl - "%d " .print
		dup clzl "%d " .print
		dup "%h     " .print
		drop
		.cr
		) drop
	;
:time2
	msec
	7 'seed !
	10000000 ( 1? 1-
		1 62 randmax <<
		63 swap msbl - drop
		) drop
	msec swap - "%d msec" .println

	msec
	7 'seed !
	10000000 ( 1? 1-
		1 62 randmax <<
		clzl drop
		) drop
	msec swap - "%d msec" .println
	;
	
:main
	-0.5 ( 5.0 <?
		dup "x:%f " .print
		dup exp. "| exp:%f " .print
		dup ln. "| ln:%f " .print
		dup sqrt. "| sqrt:%f" .print
		dup sqrt2  " sqrt2:%f" .print
		dup log2 " log2:%f " .print
		.cr
		0.25 + ) drop
|speed1		
|	calc1
|	time2
	waitesc
	;
	
: .cls
main
;