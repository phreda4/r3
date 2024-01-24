|^r3/win/console.r3

:cona	
	>a ;
	
:conb	
	dup 3 + ;
	
:w1 0 1? ( cona ; ) conb ;

: w1 cona conb ;
