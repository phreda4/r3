^r3/lib/console.r3

#t #y #k #e #d #q #c #xp #yp

:gcd | a b -- gcd
	0? ( ; )
	( 1? swap over mod ) drop ;

:point | xin --	e	
	10 4 gcd 2
	;

:PROF
	3 + POINT 3 ;

: 
	2
	prof
	1 2 * +
	point
	8 'd !
	0 2 gcd "%d" .println
	waitesc
;