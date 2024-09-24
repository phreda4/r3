| r3 plain
| PHREDA 2020
|------------------
^r3/lib/console.r3
^r3/system/r3base.r3
^r3/system/r3pass1.r3
^r3/system/r3pass2.r3
^r3/system/r3pass3.r3
^r3/system/r3pass4.r3

#name * 1024

:genword | adr --
	dup 16 + @
|	$8 and? ( 2drop ; ) 		| cte!!
	$fff000 nand? ( 2drop ; )	| no calls
	1 and ":#" + c@ ,c
	dicc> 32 - <? ( dup adr>dicname ,s )
|	dup @ " | %w" ,print ,cr | debug plain
	adr>toklen
	( 1? 1 - swap
		d@+ ,sp ,tokenprintn
|		$7c nand? ( ,cr )
		swap ) 2drop
	,cr ;

:r3-genplain
	mark
	switchmem "|MEM %d" ,print ,cr

	dicc ( dicc> <?
		dup genword
		32 + ) drop

	"r3/plain.r3"
	savemem
	empty ;

::r3plain | str --
	r3name
	here dup 'src !
	'r3filename
	dup "load %s" .println
	2dup load | "fn" mem
	here =? ( 3drop "no source code." .println ; )
	0 swap c!+ 'here !
	0 'error !
	0 'cnttokens !
	0 'cntdef !
	'inc 'inc> !
	"pass1" .println
	swap 
	r3-stage-1
	error 1? ( 4drop "ERROR %s" .println ; ) drop
	cntdef cnttokens cntinc "includes:%d tokens:%d definitions:%d" .println
	"pass2" .println
	r3-stage-2
	1? ( "ERROR %s" .println 3drop ; ) drop
	code> code - 2 >> "tokens:%d" .println
	" pass3" .println
	r3-stage-3
	" pass4" .println
	r3-stage-4
	3drop
	" genplain" .println
	r3-genplain
	;

:  	" PHREDA - 2020" .println
	" r3 plain generator" .println
	'name "mem/main.mem" load drop
	'name r3plain
	
	.cr "press <enter> to continue..." .print	
	.input
	;

