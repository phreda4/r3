| search words in entire libs
| PHREDA 2023

^r3/system/meta/refelibs.r3
^r3/lib/console.r3

:?word | adr 'dicc -- nro/-1
	0 swap			| adr 0 'r3base
	( dup c@ 1? drop
		pick2 over =s 1? ( 2drop nip ; ) drop
		>>0 swap 1 + swap ) 4drop
	-1 ;
	
:searchword | word -- 'list nro/-1
	'liblist ( @+ 1?		| word list 'l
		8 + @				| word list 'lw
		pick2 swap ?word	| word list nro/-1
		0 >=? ( rot drop ; )
		drop
		) 2drop 
	-1 ;
	
	
:snamelib | adr	
	8 - @ @ .println ;
	
:.wlib | lib word --
	-1 =? ( 2drop "NO" .println ; )
	"%d " .print snamelib ;
	
|#lib 'name 'words 'info	
:viewwords | adr --
	|@+ drop | .println | name lib
	8 +
	@ ( dup c@ 1? drop
		dup .write .sp | word
		>>0 ) 2drop
|	.cr
	;
	
:viewlibs
	'liblist ( @+ 1?
		viewwords
		) 2drop ;
		
:view
|	viewlibs
	"sin " dup .print searchword .wlib
	"sina " dup .print searchword .wlib
	.input
	;
	
: view ;