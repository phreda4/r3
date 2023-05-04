
|------------------------
^r3/win/console.r3
^r3/lib/rand.r3
^r3/util/heap.r3

#heap 0 0

:test
	.cls 
	"hola" .println
	
	100 'heap heapini
	
	100
	dup ( 1?
		50 randmax
		dup ">>%d " .print
		'heap heap!
		1 - ) drop
	.cr .cr
	( 1?		
		'heap heap@ "%d<< " .print
		1 - ) drop
	.cr
	;

:
	test
	.input
	;

