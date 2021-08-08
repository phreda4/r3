|MEM 8192  | 8MB
| r3 plain
| PHREDA 2020
|------------------
^r3/win/console.r3
^./r3base.r3
^./r3pass1.r3
^./r3pass2.r3
^./r3pass3.r3
^./r3pass4.r3

#name * 1024

:genword | adr --
	dup 8 + @
|	$8 and? ( 2drop ; ) 		| cte!!
	$fff000 nand? ( 2drop ; )	| no calls
	1 and ":#" + c@ ,c
	dicc> 16 - <? ( dup adr>dicname ,s )
|	dup @ " | %w" ,print ,cr | debug plain
	adr>toklen
	( 1? 1 - swap
		@+ ,sp ,tokenprintn
|		$7c nand? ( ,cr )
		swap ) 2drop
	,cr ;

:r3-genplain
	mark
	switchmem "|MEM %d" ,print ,cr

	dicc ( dicc> <?
		dup genword
		16 + ) drop

	"r3/plain.r3"
	savemem
	empty ;

::r3plain | str --
	r3name
	here dup 'src !
	

	'r3filename
	dup "load %s." .print cr
	2dup load | "fn" mem
	here =? ( "no source code." .print cr ; )
	0 swap c!+ 'here !
	0 'error !
	0 'cnttokens !
	0 'cntdef !
	'inc 'inc> !
	"pass1.." .print cr
	swap r3-stage-1
	error 1? ( "ERROR %s" .print cr ; ) drop
	cntdef cnttokens cntinc "includes:%d tokens:%d definitions:%d" .print cr
	"pass2.." .print cr
	r3-stage-2
	1? ( "ERROR %s" .print ; ) drop
	code> code - 2 >> "..code:%d" .print
	" pass3" .print
	r3-stage-3
	" pass4" .print
	r3-stage-4
	" genplain" .print
	r3-genplain
	;

:  windows mark
	" PHREDA - 2020" .print cr
	" r3 plain generator" .print cr
	'name "mem/main.mem" load drop
	'name r3plain
	cr "press <enter> to continue..." .print	
	.input
	;

