| r3 optimizer
| PHREDA 2024
| r3 to r3 optimizer translator
| plan:
|
| + one file, plain lib
| + remove unused words
| + translate noname definitions
|-----------------
^r3/lib/console.r3
^r3/d4/r3token.r3
^r3/d4/r3opt.r3

|----------------------------------------
:dataw | n -- n
	dup datause? 0? ( drop ; ) drop
	
	| info in plain--
	dup 4 << dic + @ dic>name "| #%w " ,print ,cr
	| info in plain--
	
	dup "#w%h" ,print
	dup 4 << dic + toklend		| dc tok len
	( 1? 1 - swap ,sp 
		@+ ,tokenstrd
		swap ) 2drop 
	,cr ;
	
|----------------------------------------	
:,anonw | token --
	dup @ 8 >> $ffffffff and  	| to from
	dup tok - 3 >> ":a%h" ,print 
	wordanon					| analysis
	'tokana ( tokana> <? ,sp
		@+ ,tokenstrw 
		) drop ,cr ;

#cnta
#anon * 80 | 10 anon max per word !!!!!!

:withanon | nro --
	0 'cnta !
	4 << dic + toklen 
	( 1? 1 - swap @+ $ff and
		11 =? ( over 8 - cnta 3 << 'anon + ! 1 'cnta +! ) | ]
		drop swap ) 2drop 
	0 ( cnta <? 
		'anon over 3 << + @ ,anonw
		1 + ) drop ;
	
:codew
|dup 4 << dic + @ dic>name "%w" .println | debug
	dup worduse? 0? ( drop ; ) drop
	dup withanon
	
	| info in plain--
	dup 4 << dic + @ dic>name "| :%w | " ,print 
	dup 4 << dic + 8 + @ ,mov ,cr
	| info in plain--
	
|	dup 4 << dic + @ dic>name "| :%w | " .println
	
	dup ":w%h" ,print 
	dup wordanalysis
	'tokana ( tokana> <? ,sp
		@+ ,tokenstrw 
		) drop ,cr ;
	
:,everyword | n -- n
	dup 4 << dic + 
	dup 8 + @ $ffff0000 nand? ( 2drop ; ) drop	| no calls
	@ 1 and? ( drop dataw ; ) 
	drop codew ;
	
:generate
	0 ( cntdef 1 - <?
		,everyword 
		1 + )
	dup withanon 
	"|-----BOOT-----" ,s ,cr
	":" ,print 
	wordanalysis
	'tokana ( tokana> <? ,sp
		@+ ,tokenstrw 
		) drop ,cr ;
		
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
	"| " ,s 'filename ,s ,cr
	"| r3 optimizer" ,s ,cr
	generate
	"r3/d4/gen/plain.r3" savemem
	empty			| free buffer
	;

|--------------------- BOOT
: 	
	.cls
	'filename "mem/main.mem" load drop
|	"r3/test/testasm.r3" 'filename strcpy

	'filename r3load
|	'filename .println
	error 1? ( dup .print .cr ) drop
	deferwi | for opt	
|	showvar 
	resetvm
	saveopt
	|.input
	;