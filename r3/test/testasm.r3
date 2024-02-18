| test for vm

:shift
	-? ( neg >> ; ) << ;
	
|--- fixed point to floating point	
::f2fp | f.p -- fp
	0? ( ; )
	dup 63 >> swap	| sign i
	over + over xor | sign abs(i) 
	dup clz 8 - 	| s i shift
	swap over shift 	| v s shift i
	134 rot - 23 << | s i m | 16 - (fractional part)
	swap $7fffff and or 
	swap $80000000 and or 
	;

::count | s1 -- s1 cnt 
	0 over ( c@+ 1?
		drop swap 1 + swap ) 2drop ;
	
|----Boot
: 
	1.0 f2fp 
	"hola" count 2drop

	;
