| LIST BYTE
|--- 
^r3/lib/console.r3

::blistdel | 'list 'from --
	dup 1 + pick2 @ cmove
	-1 swap +! ;

::blist! | f 'list --
	1 over +! @+ + 1 - c! ;
	
::blist- | f 'list --
	swap over @+ | 'adr cnt
	( 1? 1 - swap
		c@+ pick3 
		=? ( drop nip nip swap blistdel ; )
		drop swap ) 
	4drop ;
		
::blist@ | 'list -- f/0
	dup @ 0? ( nip ; ) drop
	dup 8 + c@
	swap dup 8 + blistdel ;
	
::blist? | f 'list -- f/0
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