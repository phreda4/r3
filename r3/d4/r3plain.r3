| r3 optimizer
| PHREDA 2024
| r3 to r3 optimizer translator
| plan:
|
| + one file, plain lib
| + remove unused words (after inline and fold of constants)
| + translate noname definitions (inline if they call the word that contains them)
| + target system: ##osgen (r3token), inline limit: ##inlinelenmax (r3opt)
|-----------------
^r3/lib/console.r3
^r3/util/utfg.r3
^r3/d4/r3token.r3
^r3/d4/r3opt.r3

#osnames "WIN" "LIN" "MAC" "RPI"

|----------------------------------------
:dataw | n -- n
	dup 4 << dic + @ dic>name "| #%w " ,print ,cr	| info in plain
	dup "#w%h" ,print
	dup 4 << dic + toklend		| n tok len
	( 1? 1- swap ,sp 
		@+ ,tokenstrd
		swap ) 2drop 
	,cr ;

:,tokana | -- ; the tokens of the last analysis
	'tokana ( tokana> <? ,sp
		@+ ,tokenstrw ) drop ,cr ;

|----------------------------------------	
:,anonw | token --
	dup @ 8 >> $ffffffff and 	| to idx
	dup ":a%h" ,print 
	3 << tok +				| to from
	wordanon				| analysis
	,tokana ;

#cnta
#cw			| word of collectanon
#anon * 800 | 100 anon max per word

:addanon | tokaddr -- ; save the ] token, if the anon is a word apart
	cw over anoninline? 1? ( 2drop ; ) drop	| it stays inline in the word
	cnta 100 <? ( 3 << 'anon + ! 1 'cnta +! ; ) 
	drop "too many anonymous words in one word" .println drop ;

:collectanon | nro -- ; address of every ] token of the word in 'anon
	0 'cnta !
	dup 'cw !
	4 << dic + toklen 
	( 1? 1- swap @+ $ff and
		11 =? ( over 8 - addanon ) | ]
		drop swap ) 2drop ;

:withanon | nro --
	collectanon
	0 ( cnta <? 
		'anon over 3 << + @ ,anonw
		1+ ) drop ;
	
:codew | n -- n
	dup withanon
	dup 4 << dic + @ dic>name "| :%w | " ,print	| info in plain
	dup 4 << dic + 8 + @ ,mov ,cr
	dup ":w%h" ,print 
	dup wordanalysis
	,tokana ;

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
	0 ( cntdef 1- <? ,everyword 1+ )
	dup withanon 
	"|-----BOOT-----" ,s ,cr
	":" ,print 
	wordanalysis ,tokana ;

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
	cntdef $ffff >? ( drop "too many definitions (max 65535)" .println ; ) drop
	0 'optovf !
	mark
	switchmem "|MEM %d" ,print ,cr
	"| " ,s 'filename ,s ,cr
	"| r3 optimizer" ,s ,cr
	inlinelenmax "| inlinelenmax %d" ,print ,cr
	'osnames osgen $3 and 2 << + "| target %s" ,print ,cr
	
	generate
	optovf 1? ( drop empty "ERROR: optimizer buffer overflow (word too long or too many big literals), plain.r3 not saved" .println ; ) drop
	"r3/d4/gen/plain.r3" savemem
	empty			| free buffer
	;

::r3plain | str --
	dup "loading %s..." .println
	r3load
	error 1? ( .println ; ) drop
	"tokenized" .println
	deferwi | for opt and inline
	showvar 
	"generating..." .println
	saveopt
	optovf 0? ( "done" .println ) drop
	;
	
|--------------------- BOOT
#optbuf * 128

:loadopts | -- ; mem/build.mem: osgen inlinelenmax inlinebudget fmtunroll (written by r3build)
	'optbuf "mem/build.mem" load 'optbuf -
	16 <? ( drop ; )
	'optbuf @ $3 and 'osgen !
	'optbuf 8 + @ 0 max 99 min 'inlinelenmax !
	32 <? ( drop ; ) drop
	'optbuf 16 + @ 1 max 16 min 'inlinebudget !
	'optbuf 24 + @ 1 and 'fmtunroll ! ;

: 	
	'filename "mem/menu.mem" load drop
	
	.cr
	.reset 
	"Make plain.r3" .println
	|--- generation parameters: set by r3build in mem/build.mem
	|--- (or uncomment to change by hand)
	|1 'osgen !			| target: 0 WIN, 1 LIN, 2 MAC, 3 RPI (default: this system)
	|7 'inlinelenmax !	| max tokens of a word to inline (default 7, 0 = no inline)
	loadopts
	'osnames osgen $3 and 2 << + "target: %s" .println
	inlinelenmax "inline: %d" .println
	inlinebudget "inline budget: x%d" .println
	fmtunroll "unroll formats: %d" .println
	mark
	'filename r3plain
	cols .hline
	|.cr "press any key to continue..." .print waitkey	
	;