| LIST BYTE
|--- 
^r3/lib/console.r3

::blistdel | 'list 'from -- ; remove the byte at address 'from, moving the next bytes down, and decrement the count (the list is a count cell followed by the bytes)
	dup 1 + pick2 @ cmove
	-1 swap +! ;

::blist! | f 'list -- ; append the byte f at the end
	1 over +! @+ + 1 - c! ;
	
::blist- | f 'list -- ; remove the first byte equal to f (BUG: it calls blistdel with the arguments swapped and the address after the byte, which corrupts the list; fix: 1 - blistdel instead of swap blistdel)
	swap over @+ | 'adr cnt
	( 1? 1 - swap
		c@+ pick3 
		=? ( drop nip nip swap blistdel ; )
		drop swap ) 
	4drop ;
		
::blist@ | 'list -- f/0 ; remove and return the first byte (0 if the list is empty)
	dup @ 0? ( nip ; ) drop
	dup 8 + c@
	swap dup 8 + blistdel ;
	
::blist? | f 'list -- f/0 ; f if the list has that byte, 0 if not (BUG: when found it also leaves the remaining count; fix: 3drop ; instead of 2drop ;)
	@+ ( 1? 1 - swap
		c@+ pick3 =? ( 2drop ; )
		drop swap ) 
	3drop 0 ;
	
:.list | 'l
	@+ | 'adr cnt
	dup "%d:" .print
	( 1? 1- swap
		c@+ "%d " .print
		swap ) 2drop .cr ;