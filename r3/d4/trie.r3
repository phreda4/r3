| trie 
| PHREDA 2025
|
^r3/lib/console.r3
^r3/d4/meta/mlibs.r3

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
	
::trie-insert | word --
	0 'node !
	( c@+ 1? 
		char>6 ]trie	| adrtrie
		dup w@ -1 =? ( drop nextnode dup pick2 w! 1 'nextnode +! )
		'node ! drop
		) 2drop
	-1 node ]end c! ;

::trie-searchpre | word -- 0/-1
	0 'node !
	( c@+ 1?
		char>6 ]trie
		w@ -1 =? ( 2drop 0 ; ) 
		'node ! 
		) 2drop
	-1 ;

::trie-search | word -- n
	trie-searchpre
	node ]end c@ and ;
	
::trie-ini | mem --
	here 
	dup 'triemem ! over + 
	dup 'endmem ! over +
	'here !
	triemem -1 pick2 2 >> dfill
	drop
	0 'nextnode !
	;

|#name "r3/lib/win/winsock.r3"
|#words  "WSAStartup" "WSACleanup" "accept" "select" "socket" "bind" "listen" "closesocket" "shutdown" "send" "recv" "getaddrinfo" "ioctlsocket" 0
|#info ( $2F $0 $3E $5C $3E $3E $2F $1F $2F $4C $4D $4D $3E )
|#r3_lib_win_winsock.r3 'name 'words 'info
|##liblist 'r3_lib_3d.r3
	
#cntwords	
:.plist | info words --
	( dup c@ 1? drop
		over c@ $ff and over "%s %h |"  .print
		dup trie-insert
		1 'cntwords +!
		>>0	swap 1+ swap
		) 3drop
	;
	
	
:ask
	.cr "> " .print
	.input .cr
	
|	'pad .println
	'pad c@ 0? ( drop ; ) drop
	
	
	ask ;
|---------------------------------	
:main
	"r3libs" .println .cr

	$fffff trie-ini
	0 'cntwords !
	'liblist ( @+ 1?
		@+ .println
		@+ swap @ swap | info words
		.plist
		) 2drop
	.cr .cr
	cntwords "%d words" .println
	"list:" .println
	cntwords 4 << "%d bytes" .println
	
	"trie:" .println
	nextnode "last:%d" .println
	nextnode 6 << "%d bytes" .println
|	"hola" trie-insert
|	"hola" trie-search "%d=1" .println
|	"hol" trie-searchpre "%d=1" .println

	ask
	;

: main ;
	