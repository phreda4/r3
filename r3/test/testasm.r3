| test for vm

::count | s1 -- s1 cnt 
	0 over ( c@+ 1?
		drop swap 1 + swap ) 2drop ;
	
|----Boot
: 
	"hola" count 2drop

	;
