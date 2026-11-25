| r3 optimizer
| PHREDA 2024
| r3 to r3 optimizer translator
| plan:
|
| + one file, plain lib
| + remove unused words (after inline and fold of constants)
| + remove the vars that are only written (with their stores), see rounds and ,ST in r3opt
| + a lookup of a function (GetProcAddress, dlsym ...) whose result is not used goes away, see pureimp?
| + translate noname definitions (inline if they call the word that contains them)
| + target system: ##osgen (r3token), inline limit: ##inlinelenmax (r3opt)
|-----------------
^r3/lib/console.r3
^r3/util/utfg.r3
^r3/d4/r3token.r3
^r3/d4/r3plainopt.r3

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
#rd * $10000		| 1 byte per definition: var read or with its address used (in this round)
#esc * $10000		| the address of the var escapes (it is not only stored)
#stc * $10000		| stores to the var (0, 1, 2 = many)
#pic * $10000		| the var has a store  "name" GETPROC 'var !  with a name of the list of pureimp?
#wq * $40000
#wq> 'wq

:marked? | nro -- 0/1
	'mk + c@ ;

:pushw | nro -- ; mark and queue
	dup 'mk + c@ 1? ( 2drop ; ) drop
	dup 'mk + 1 swap c!
	wq> d!+ 'wq> ! ;

:rdset | nro -- ; the var is read, or its address is used
	'rd + 1 swap c! ;

:rd? | nro -- 0/1
	'rd + c@ ;

:nextst? | adr -- 0/1 ; the token in adr is a store ( ! C! W! D! +! C+! W+! D+! )
	tokana> >=? ( drop 0 ; )
	@ $ff and 74 77 in? ( drop 1 ; ) 82 85 in? ( drop 1 ; ) drop 0 ;

:escset | nro -- ; the address of the var escapes
	'esc + 1 swap c! ;

:stinc | nro -- ; one store more (2 = many)
	'stc + dup c@ 1+ 2 min swap c! ;

|--- imports that look for a function and have no effects: a call that does not use the result goes away
:pureimp? | str -- 0/1
	dup "SDL_GL_GetProcAddress" cmpstr 0? ( 2drop 1 ; ) drop
	dup "glXGetProcAddress" cmpstr 0? ( 2drop 1 ; ) drop
	dup "glXGetProcAddressARB" cmpstr 0? ( 2drop 1 ; ) drop
	dup "wglGetProcAddress" cmpstr 0? ( 2drop 1 ; ) drop
	dup "eglGetProcAddress" cmpstr 0? ( 2drop 1 ; ) drop
	dup "GetProcAddress" cmpstr 0? ( 2drop 1 ; ) drop
	dup "dlsym" cmpstr 0? ( 2drop 1 ; ) drop
	drop 0 ;

:gpimp? | adr -- 0/1 ; the tokens before  'var !  (adr = token after 'var) are  "name" GETPROC
	'tokana 24 + <? ( drop 0 ; )
	dup 16 - @ $ff and 129 <>? ( 2drop 0 ; ) drop
	dup 24 - @ dup $ff and 6 <>? ( 3drop 0 ; ) drop
	8 >> $ffffffff and strm + pureimp? nip ;

#sv

:scanvadr | adr tok -- ; the token after the .vadr tok is in adr
	8 >> $ffffffff and 'sv !
	dup nextst? 0? ( 2drop sv dup rdset escset ; ) drop
	sv stinc
	dup @ $ff and 74 <>? ( 2drop ; ) drop		| only a ! can be the init of the import
	gpimp? 1? ( 1 sv 'pic + c! ) drop ;

:scanrd | -- ; vars of tokana that are read (.var) or whose address is not only stored (.vadr)
	'tokana ( tokana> <? @+
		dup $ff and
		4 =? ( over 8 >> $ffffffff and rdset )
		5 =? ( pick2 pick2 scanvadr )
		2drop ) drop ;

:scanana | -- ; mark every word referenced by the tokens in tokana
	'tokana ( tokana> <? @+ 
		dup $ff and 2 5 in? ( over 8 >> $ffffffff and pushw ) 2drop ) drop
	scanrd ;

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
		dup $ff and 2 5 in? ( over 8 >> $ffffffff and pushw 4 >=? ( over 8 >> $ffffffff and dup rdset escset ) ) 2drop 
		swap ) 2drop ;

:markitem | nro --
	dup 4 << dic + @ 1 and? ( drop markdata ; ) 
	drop markcode ;

:markall | --
	0 ( cntdef <? dup 'mk + 0 swap c! dup 'rd + 0 swap c!
		dup 'esc + 0 swap c! dup 'stc + 0 swap c! dup 'pic + 0 swap c! 1+ ) drop
	'wq 'wq> !
	cntdef 1- pushw
	'wq ( wq> <? d@+ markitem ) drop ;

|--- dead vars: a var that is only written is removed with its stores (see ,ST in r3opt)
|--- every round marks with the current set ('deadv); the vars without reads join the set,
|--- the ones that are used or whose store can not be removed leave it for good. Until nothing changes.

#dchg #dn

:setd | v -- ; set the state of the var dn (the bit 8 stays)
	dn 'deadv + dup c@ 8 and rot or swap c! ;

:purei? | n -- 0/1 ; an import of a function with no effects: one store, the init, and its address does not escape
	dup 'pic + c@ 0? ( nip ; ) drop
	dup 'esc + c@ 1? ( 2drop 0 ; ) drop
	'stc + c@ 1 =? ( drop 1 ; ) drop 0 ;

:chkpure | n -- ; keep the bit 8 of the var as purei? says
	dup 'dn ! purei?
	dn 'deadv + c@ 3 >> 1 and =? ( drop ; ) drop
	dn 'deadv + dup c@ 8 xor swap c! 1 'dchg ! ;

:vardead | n -- ; state of a var after marking
	dup 'dn !
	'deadv + c@
	2 and? ( drop 4 setd 1 'dchg ! ; )					| a store can not be removed
	1 and? ( drop dn rd? 0? ( drop ; ) drop 4 setd 1 'dchg ! ; )	| dead var that is used
	5 and? ( drop ; )
	drop dn rd? 1? ( drop ; ) drop 1 setd 1 'dchg ! ;

:chkvar | n --
	dup marked? 0? ( 2drop ; ) drop
	dup 4 << dic + @ 1 and? ( drop dup chkpure vardead ; ) 2drop ;

:cleardead | --
	0 ( cntdef <? dup 'deadv + 0 swap c! 1+ ) drop ;

:rounds | -- ; marks for good (mk) with the final set of dead vars
	cleardead
	0 ( 64 <?
		markall
		0 'dchg !
		0 ( cntdef <? dup chkvar 1+ ) drop
		dchg 0? ( 2drop ; ) drop
		1+ ) drop
	cleardead markall ;				| it does not settle: no dead vars

:ndead | -- n ; vars removed
	0 'dn !
	0 ( cntdef <? dup 'deadv + c@ 1 and? ( 1 'dn +! ) drop 1+ ) drop
	dn ;

:,everyword | n -- n
	dup marked? 0? ( drop ; ) drop
	dup 4 << dic + @ 1 and? ( drop dataw ; ) 
	drop codew ;
	
:generate
	rounds
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
	ndead "dead vars: %d" .println
	"mem/plain.r3" savemem
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