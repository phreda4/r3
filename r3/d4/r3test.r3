| r3 optimizer
| PHREDA 2024
| r3 to r3 optimizer translator
| plan:
|
| + one file, plain lib
| + remove unused words
| + translate noname definitions
|-----------------
^r3/lib/win/console.r3
^r3/d4/r3token.r3
^r3/d4/r3opt.r3

:,ntoslit | n --
	0? ( drop ; )
	NOS over 2 - 3 << - over | n NOS n
	( 1 - 1? swap @+ " %d" .print swap ) 2drop
	TOS " %d" .println
	( 1? 1 - .drop ) drop ;

:,2TOSLIT | --
	NOS  @ " %d" .print TOS " %d" .println .2drop ;
	
:nlitpush | n --
	( 1? dup NPUSH 1 - ) drop ;	
	
:.s	
	NOS 'PSP 8 - - 3 >> dup "stack deep:%d" .println ;
	
|--------------------- BOOT
: 	
	.cls
|	'filename "mem/main.mem" load drop
|	'filename r3load
|	'filename .println
|	error 1? ( dup .print .cr ) drop
|	deferwi | for opt	
|	showvar 
	'PSP 8 - 'NOS ! 'RSP 'RTOS !
	0 'TOS ! 0 RTOS !

	"test" .println	 .s
|	8 nlitpush .s
|	8 ,ntoslit .s
|	6 nlitpush .s .+ 5 ,ntoslit .s
	"----3 2 1" .println
	3 nlitpush
	,2TOSLIT
	|3 ,ntoslit
	.s
	.input
	;