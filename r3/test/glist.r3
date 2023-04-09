
|------------------------
^r3/win/console.r3

|--- generic list
:listdel | 'list 'from --
	dup 1 + pick2 @ cmove
	-1 swap +! ;

:list! | f 'list --
	1 over +! @+ + 1 - c! ;
	
:list- | f 'list
	swap over @+ | 'adr cnt
	( 1? 1- swap
		c@+ pick3 
		=? ( drop nip nip swap listdel ; )
		drop swap ) 
	4drop ;
		
:list@ | 'list -- f/0
	dup @ 0? ( nip ; ) drop
	dup 8 + c@
	swap dup 8 + listdel ;
	
:list? | f 'list -- f/0
	@+ ( 1? 1- swap
		c@+ pick3 =? ( 2drop ; )
		drop swap ) 
	3drop 0 ;
	
:.list | 'l
	@+ | 'adr cnt
	dup "%d:" .print
	( 1? 1- swap
		c@+ "%d " .print
		swap ) 2drop .cr ;
		
	
#testlist 0 * 32

:test
	.cls 
	"hola" .println
	1 'testlist list!
	'testlist .list
	2 'testlist list!
	'testlist .list
	10 'testlist list!
	'testlist .list
	20 'testlist list!
	'testlist .list
	'testlist list@ "%d" .println
	'testlist .list	
	'testlist list@ "%d" .println
	'testlist .list	
	'testlist list@ "%d" .println
	'testlist .list	
	14 'testlist list!
	'testlist .list
	
	;

:
	test
	.input
	;

