| example code

:ri 2 step ;
:dn 4 step ;

:goleft
	( 2 check 1 =? drop 
		ri ) drop ;
		
:pushl | n --
	( 1? 1 - ri ) drop ;
	
:	goleft 
	3 pushl 
	dn dn 
	;
	