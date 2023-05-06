|------------------------
^r3/win/console.r3
^r3/lib/rand.r3
^r3/util/heap.r3
^r3/util/dlist.r3

| 30 'dc dc.ini | room for 30 cells (empty now)
| 'dc dc? 		| cnt of cell
| 2 'dc dc.n 	| valu of n
| 12 'dc dc! 	| store a val
| 'dc dc@-		| fetch a val

#heap 0 0

:testheap
	.cls 
	"Heap Test" .println
	
	100 'heap heapini
	
	100		| add 100 numbers
	dup ( 1?
		50 randmax
		dup ">>%d " .print
		'heap heap!
		1 - ) drop
	.cr .cr
	( 1?	| get 100 numbers in orden
		'heap heap@ "%d<< " .print
		1 - ) drop
	.cr
	;

#list 0 0 

:testlist
	.cls 
	"list Test" .println
	
	100 'list dc.ini
	
	10 ( 1?
		50 randmax
		dup "%d " .print
		'list dc!
		1 - ) drop
	.cr
	
	'list dc@ "%d" .println
	10 ( 1?
		'list dc@- "%d " .print
		'list dc? "(%d) " .print
		1 - ) drop
	.cr
	
	;
	
#plist 
#cntfloors 5
:plistini | listmax --
	here dup dup 'plist !
	cntfloors 4 << + 'here ! 
	cntfloors ( 1? swap
		pick2 over dc.ini
		16 + swap 1 - ) 3drop ;

:plistn | n -- adr
	4 << plist + ;
	
:.listp
	plist >a
	cntfloors ( 1? 
		a> dc? "%d " .print
		16 a+
		1 - ) drop 
	.cr .cr ;
	
:testmulti	
	.cls 
	"multi list Test" .println
	30 plistini 

	20 ( 1?
		20 randmax 
		5 randmax 4 << plist +
		dc!
|		.listp
|		.input
		1 - ) drop
	.cr
	20 ( 1?
		5 randmax 4 << plist +
		dc@- "%d) " .print
		.listp
		.input
		1 - ) drop
		
	;
	
:
|	testheap .input
|	testlist .input
	testmulti .input
	;

