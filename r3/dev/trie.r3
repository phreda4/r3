| trie 
| PHREDA 2025
|
^r3/lib/console.r3

:char>6 | char -- 6bitchar
	$20 - dup $40 and 1 >> or $3f and ;

:6>char | 6bc -- char
	$3f and $20 + ;

#triemem
#endmem

#nextnode
#node

:]trie | c -- adr
	node 6 << + 2* triemem + ;
	
:]end | node -- adr
	endmem + ;
	
:insert | word --
	0 'node !
	( c@+ 1? 
		char>6 ]trie	| adrtrie
		dup w@ -1 =? ( drop nextnode dup pick2 w! 1 'nextnode +! )
		'node ! drop
		) 2drop
	-1 node ]end c! ;

:searchpre
	0 'node !
	( c@+ 1?
		char>6 ]trie
		w@ -1 =? ( 2drop 0 ; ) 
		'node ! 
		) 2drop
	-1 ;

:search | word -- n
	searchpre
	node ]end c@ and ;
	
|---------------------------------	
:pc
	-? ( drop "." .print ; ) "%h" .print ;
	
:wa@+
	ca@+ $ff and ca@+ 8 << or ;
	
:printdebug
	triemem >a
	nextnode ( 1? 1-
		64 ( 1? 1- wa@+ pc ) drop .cr
		) drop
	.cr
	;
|---------------------------------	
:main
	"Trie test case" .println .cr

	here 
	dup 'triemem ! $ffff + 
	dup 'endmem ! $fff +
	'here !
	
	triemem -1 $ffff 2 >> dfill
	
	0 'nextnode !
	
	"hola" insert
	"hoja" insert
	"peso" insert
    "holan" insert
    "homre" insert
    "perro" insert
	
	0 ( 64 <? dup 6>char .emit 1+ ) drop .cr
	printdebug	

	"hola" search "%d=-1" .println
	"hoj" search "%d=0" .println
	"hol" searchpre "%d=-1" .println
	"gat" searchpre "%d=0" .println

	.cr

	
	waitesc
	;

: 
main ;
	