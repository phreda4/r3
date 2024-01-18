| r3 optimizer
| PHREDA 2024
| r3 to r3 optimizer translator
| plan:
|
| + one file, plain lib
| + remove unused words
| - remove noname definitions
| - reorder stack?, minimice heigth ( 2 3 4 + + =>> 3 4 + 2 + )
| - reemplace constant
| - inline words
| - calculate pure stack words
| - folder constant
| - cte * transform
| - cte / mod transform
|-----------------
^r3/win/console.r3
^r3/d4/r3token.r3

:,str | str --
	34 ,c 
	( c@+ 1? 34 =? ( 34 ,c ) ,c ) drop
	34 ,c ;
	
:,token | tok nro --
	,sp 
	6 =? ( drop 8 >> $ffffff and strm + ,str ; ) 				| str
	drop
	40 >>> src + "%w" ,print ;
	
:dataw
	toklend		| dc tok len
	( 1? 1 - swap
		@+ dup $ff and ,token
		swap ) 2drop 
	,cr ;
	
:codew
	toklen 
	( 1? 1 - swap
		@+ dup $ff and ,token
		swap ) 2drop 
	,cr ;
	
:,everyword | n -- n
	dup 4 << dic + 
	dup 8 + @ $fff0000 nand? ( 2drop ; ) drop	| no calls
	dup @ 
|	$8 and? ( 2drop ; ) 		| cte!!
	dup 1 and ":#" + c@ ,c
	dup 40 >>> src + "%w" ,print
	1 and? ( drop dataw ; ) drop codew 
	;

	
:generate
	0 ( cntdef <?
		,everyword 
		1 + ) drop ;
		
|--------------------------------			
:showvar
	cntdef "def:%d" .print  
	dic> dic - 4 >> "(%d) " .print
	cnttok "tok:%d" .print  
	tok> tok - 3 >> "(%d) " .print
	cntstr "str:%d" .print  
	strm> strm - "(%d) " .print
	fmem> fmem - "m:%d" .print
	.cr
	;

|---------------------		
:saveopt | --
	error 1? ( drop ; ) drop
	mark
	"| r3 optimizer" ,s ,cr
	generate
	"r3/d4/main.r3" savemem
	empty			| free buffer
	;

|--------------------- BOOT
: 	
	.cls
|	'filename "mem/main.mem" load drop
|	"r3/demo/textxor.r3" 
|	"r3/democ/palindrome.r3" 
	"r3/test/testasm.r3"
	r3load
	
	'filename .println
	error 1? ( dup .print .cr ) drop
	showvar 
	
|	r3exec 
	resetvm
	saveopt
|	.input
	;