| debug example
| PHREDA 2025

^r3/lib/console.r3
^r3/lib/trace.r3

#var1 12
#buf1 ( 1 2 3 4 5 6 7 8 ) 
#buf2 [ 1 2 3 4 5 6 7 8 ]
#buf3 1 2 3 4 5 6 7 8

:main
	.reset 
	"demo debug" .println .flush
	1 2 3
	<<trace | view stack here
	*
	<<trace | view stack here
	+
	<<trace | view stack here
	"%d" .println
	'var1 <<memmap | view memory from this var
	;
	
:
33	| say 33 for mark the stack
main
drop | remove 33
"any key to end." .fwrite
waitkey
.free
;