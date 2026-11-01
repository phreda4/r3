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
^r3/util/utfg.r3
^r3/d4/r3token.r3
^r3/d4/r3opt.r3

#osnames "WIN" "LIN" "MAC" "RPI"

|----------------------------------------
:dataw | n -- n
	| info in plain--
	dup 4 << dic + @ dic>name "| #%w " ,print ,cr
	| info in plain--
	
	dup "#w%h" ,print
	dup 4 << dic + toklend		| dc tok len
	( 1? 1- swap ,sp 
		@+ ,tokenstrd
		swap ) 2drop 
	,cr ;
	
|----------------------------------------	
:,anonw | token --
	dup @ 8 >> $ffffffff and 	| to idx
	dup ":a%h" ,print 
	3 << tok +				| to from
	wordanon					| analysis
	'tokana ( tokana> <? ,sp
		@+ ,tokenstrw 
		) drop ,cr ;

#cnta
#anon * 800 | 100 anon max per word

:collectanon | nro -- ; address of every ] token of the word in 'anon
	0 'cnta !
	4 << dic + toklen 
	( 1? 1- swap @+ $ff and
		11 =? ( over 8 - cnta 3 << 'anon + ! 1 'cnta +! ) | ]
		drop swap ) 2drop ;

:withanon | nro --
	collectanon
	0 ( cnta <? 
		'anon over 3 << + @ ,anonw
		1+ ) drop ;
	
:codew
|dup 4 << dic + @ dic>name "%w" .println | debug

	dup withanon
	
	| info in plain--
	dup 4 << dic + @ dic>name "| :%w | " ,print 
	dup 4 << dic + 8 + @ ,mov ,cr
	| info in plain--
	
	|dup 4 << dic + @ dic>name "%.| :%w | %." filelog
	
	dup ":w%h" ,print 
	
	|"r3/d4/gen/plain.r3" savemem
	
	dup wordanalysis
	
	|"|" ,print ,cr "r3/d4/gen/plain.r3" savemem
	
	'tokana ( tokana> <? ,sp
		@+ ,tokenstrw 
		
		|"r3/d4/gen/plain.r3" savemem
		) drop ,cr ;
	
|---------------------------------------- PASS 2: dead words
| after optimization (inline, folded constants) mark only the words
| that are still referenced, starting from the boot word.
| 'mk 1 byte per definition, 'wq work list

#mk * $10000
#wq * $40000
#wq> 'wq

:marked? | nro -- 0/1
	'mk + c@ ;

:pushw | nro -- ; mark and queue
	dup 'mk + c@ 1? ( 2drop ; ) drop
	dup 'mk + 1 swap c!
	wq> d!+ 'wq> ! ;

:scanana | -- ; mark every word referenced by the tokens in tokana
	'tokana ( tokana> <? @+ 
		dup $ff and 2 5 in? ( over 8 >> $ffffffff and pushw ) 2drop ) drop ;

:markanon | token -- ; analyze the body of one anonymous word
	dup @ 8 >> $ffffffff and 3 << tok + 
	wordanon scanana ;

:markcode | nro --
	dup wordanalysis scanana
	collectanon
	0 ( cnta <? 
		'anon over 3 << + @ markanon
		1+ ) drop ;

:markdata | nro -- ; words/vars referenced from the init of a variable
	4 << dic + toklend 
	( 1? 1- swap @+ 
		dup $ff and 2 5 in? ( over 8 >> $ffffffff and pushw ) 2drop 
		swap ) 2drop ;

:markitem | nro --
	dup 4 << dic + @ 1 and? ( drop markdata ; ) 
	drop markcode ;

:markall | --
	cntdef $ffff >? ( "too many definitions for dead word pass" .println ) drop
	0 ( cntdef <? dup 'mk + 0 swap c! 1+ ) drop
	'wq 'wq> !
	cntdef 1- pushw
	'wq ( wq> <? d@+ markitem ) drop ;

:,everyword | n -- n
	dup marked? 0? ( drop ; ) drop
	dup 4 << dic + @ 1 and? ( drop dataw ; ) 
	drop codew ;
	
:generate
	markall
	0 ( cntdef 1- <?
		,everyword 

|	"r3/d4/gen/plain.r3" savemem
		
		1+ )
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
	switchmem "|MEM %d" ,print ,cr
	"| " ,s 'filename ,s ,cr
	"| r3 optimizer" ,s ,cr
	inlinelenmax "| inlinelenmax %d" ,print ,cr
	'osnames osgen $3 and 2 << + "| target %s" ,print ,cr
	
	generate
	"r3/d4/gen/plain.r3" 
	|"r3/plain.r3" 
	savemem
	empty			| free buffer
	;

::r3plain | str --
	dup "loading %s..." .println
	r3load
	error 1? ( dup .println ; ) drop
	".pass1" .println
	deferwi | for opt and inline
	
	".pass2" .println
	showvar 
	".pass3" .println	
|	resetvm
|	".pass4" .println	
	saveopt
	".genplain" .println
	;
	
|--------------------- BOOT
: 	
	'filename "mem/menu.mem" load drop
	
	.cr
	.reset 
	"Make plain.r3" .println
	|--- generation parameters (external variables, uncomment to change)
	|1 'osgen !			| target: 0 WIN, 1 LIN, 2 MAC, 3 RPI (default: this system)
	|7 'inlinelenmax !	| max tokens of a word to inline (default 7, 0 = no inline)
	'osnames osgen $3 and 2 << + "target: %s" .println
	mark
	'filename r3plain
	cols .hline
	|.cr "press any key to continue..." .print waitkey	
	;