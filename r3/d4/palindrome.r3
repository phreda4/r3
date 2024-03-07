| print palindrome numbers
^r3/win/console.r3

:testp | nro - 0 is palindrome
	0 over ( 10 /mod rot 10 * + swap 1? ) drop - ;

:printcapi
	dup testp 1? ( drop ; ) drop
	dup "%d " .print
	;
	
: 0 ( 500000 <? printcapi 1 + ) drop .input ;

