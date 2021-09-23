| print console colors
| PHREDA 2021

^r3/win/console.r3

: .cls
	0 ( 11 <? 
		0 ( 10 <? 
			over 10 * over +
			dup 
			"^[%dm %d ^[m" .printe
			1 + ) drop
		cr
		1 + ) drop 
		
	.input
	;
	