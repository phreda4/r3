^r3/lib/console.r3

#t #y #k #e #d #q #c #xp #yp

:gcd | a b -- gcd
	0? ( ; )
	( 1? swap over mod ) drop ;
	
:point | xin --	e	
	d 9 3 */
	'd ! 
	10 4 gcd
	10 4 gcd
	;
: 
	point
	8 'd !
	0 2 gcd "%d" .println
	waitesc
;