| print random numbers
| PHREDA 2021

^r3/win/console.r3
^r3/lib/rand.r3

#array * 160 | 20 * 8bytes

: 	.cls
	rerand
	0 ( 1000000 <? 1 +
		1 
		15 randmax 3 << 'array +  | 0..14
		+!
		) drop 
	'array 
	0 ( 20 <? 
		swap @+ pick2 "%d. %d" .println
		swap 1 + ) 2drop
		;
