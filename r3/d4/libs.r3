| wordlist
| PHREDA 2025
|
^r3/lib/console.r3
^r3/util/sort.r3
^r3/d4/meta/mlibs.r3


:char>6 | char -- 6bitchar
	$20 - dup $40 and 1 >> or $3f and ;

:str>6 | "name" -- sn 
	0 swap 
	( c@+ 1?
		char>6 rot 6 << or
		$fc0000000000000 and? ( nip ; )
		swap ) 2drop 
	( $fc0000000000000 nand? 	| fill with 0
		6 << ) ;
	
:6>char | 6bc -- char
	$3f and $20 + ;

:6>str | s6 -- ""
	here 12 + 
	0 over 1+ c!
	swap ( 1?
		dup 6>char pick2 c! 
		swap 1- swap 6 >> 
		) drop 1+ ;


|#name "r3/lib/win/winsock.r3"
|#words  "WSAStartup" "WSACleanup" "accept" "select" "socket" "bind" "listen" "closesocket" "shutdown" "send" "recv" "getaddrinfo" "ioctlsocket" 0
|#info ( $2F $0 $3E $5C $3E $3E $2F $1F $2F $4C $4D $4D $3E )
|#r3_lib_win_winsock.r3 'name 'words 'info
|##liblist 'r3_lib_3d.r3

|------------------------------------------
|name word list
| compressname-infoword
#namwlist
#cntwlist
#nowlib
#nowwor
#nowstr

:addwords | info words --
	dup 'nowstr !
	0 'nowwor !
	( dup c@ 1? drop
		dup str>6 a!+ | str6
		over c@ $ff and | stack move
		nowwor 16 << or	| nro word in lib
		over nowstr - 32 << or | str word
		nowlib 48 << or 
		a!+
		>>0	swap 1+ swap
		1 'nowwor +!
		) 3drop ;

:makelist
	0 'cntwlist !
	here dup 'namwlist ! >a
	0 'nowlib !
	'liblist ( @+ 1?
		8 + |@+ .println | print library name
		@+ swap @ swap | info words
		addwords
		1 'nowlib +!
		) 2drop
	0 a!+ | end
	a> dup 'here !
	namwlist - 4 >> dup 1- 'cntwlist !
	namwlist shellsort | len+1 lista -- 
	| resort big words >10 chars
	;


:listrepe
	namwlist >a
	( a@ 1?
		a> 16 + @ =? ( a> namwlist - 4 >> "%d " .print 
		drop
		16 a+
		) 2drop ;
	
:.lib | n -- words
	3 << 'liblist + @ @+ .write @ ;

:.wordinfo | val --
	dup $ff and "%h " .print
	dup 48 >> $ffff and .lib | lib
	" -> " .print
	swap 32 >> $ffff and + .write | name
	;
	
:wordfind | "" -- nro
	dup str>6 
	namwlist >a
	( a@ 1?
		over =? ( 3drop
			a> namwlist - 4 >> 
			; ) drop
		16 a+
		) 3drop 
	-1 ;
	
|---------------------------------	
:find
	'pad wordfind -? ( drop "Not found" .println ; ) 
	4 << namwlist +
	@+ 6>str .write
	@ .wordinfo
	.cr
	;

:ask
	.cr "> " .print
	.input .cr
	'pad c@ 0? ( drop ; ) drop
	find
	ask ;


:main
	makelist
listrepe	
	"r3libs" .println 
	cntwlist "%d words" .println
"---------------" .println	
	namwlist >a
	0 ( 5 <?
		a@+ 6>str .write
		|a@+ "%h " .println 
		a@+ .wordinfo
		.cr
		1+ ) drop
	0 'pad !
	ask
	;

: main ;
	