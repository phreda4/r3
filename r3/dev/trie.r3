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

	
:]ntrie | c node -- adr
	6 << + 2* triemem + ;
	
:=nodes | a b -- 0/-1
	over ]end c@ over ]end c@ xor 1? ( 3drop 0 ; ) | false si son distintos
	0 ( 32 <?
		pick2 over ]ntrie w@
		pick2 pick2 ]ntrie w@
		2dup or	| a b c na nb or
		-1 <>? ( drop =nodes 0? ( ; ) )
		
		
		1+ ) 
	3drop -1 ;
	
|bool equalNodes(int a, int b) {
|    if (isEnd[a] != isEnd[b]) return false;
|    for (int c = 0; c < ALPHABET; c++) {
|        if (next[a][c] != -1 && next[b][c] != -1) {
|            if (!equalNodes(next[a][c], next[b][c])) return false;
|        } else if (next[a][c] != -1 || next[b][c] != -1) {
|            return false;
|        }
|    }
|    return true;

|// Minimiza (fusiona nodos equivalentes)
|void minimize(int node) {
|    for (int c1 = 0; c1 < ALPHABET; c1++) {
|        if (next[node][c1] != -1) {
|            minimize(next[node][c1]);
|            for (int c2 = c1 + 1; c2 < ALPHABET; c2++) {
|                if (next[node][c2] != -1 &&
|                    equalNodes(next[node][c1], next[node][c2])) {
|                    int duplicate = next[node][c2];
|                    next[node][c2] = next[node][c1]; // fusionar
|                    // "liberar" el duplicado (en un DAWG real usaríamos reciclaje de nodos)
|	
|---------------------------------	
:pc
	-? ( drop "." .print ; ) "%h" .print ;
	
:wa@+
	ca@+ $ff and ca@+ 8 << or ;
	
:printdebug
	triemem >a
	6 ( 1? 1-
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
    "holanda" insert
    "hombre" insert
    "perro" insert
	printdebug	
	

	"hola" search "%d=1" .println
	"hoj" search "%d=0" .println
	"hol" searchpre "%d=1" .println
	"gat" searchpre "%d=0" .println

	.cr
|	0 ( 64 <? dup 6>char .emit 1+ ) drop .cr
	
	waitesc
	;

: 
main ;
	