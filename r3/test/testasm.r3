
^r3/win/console.r3

: 
	.cls
	( key? dup "%d " .print
		0? drop )
	dup "%d" .print
	;