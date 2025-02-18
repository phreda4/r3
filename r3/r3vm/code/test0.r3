| follow maze

#dir 0

:rdir	
	dir 2 - $7 and ; 
	
:adv 	
	dir step ;
	
:checkr 
	rdir check 
	1 =? ( drop 
		rdir 'dir ! adv ; )
	drop
	dir check 
	1 =? ( drop
		adv ; )
	drop
	2 'dir +! 
	checkr ;
	
:run
	100 ( 1? 1 -
		checkr ) drop ;
	
: run ;
	