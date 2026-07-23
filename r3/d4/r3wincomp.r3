| r3 win compiler - d4 version
| PHREDA 2026
|------------------
^r3/lib/console.r3
^r3/util/utfg.r3

^r3/d4/r3token.r3
^r3/d4/genx64.r3

#name * 1024

:r3-genset
	mark
	";---r3 setings" ,print ,cr
	switchmem 20 << "MEMSIZE equ 0x%h" ,print ,cr
	"VEROPT equ 1" ,print ,cr | version OPT
	0 ,c
	"asm/set.asm"
	savemem
	empty ;

::r3c | str --
	r3name
	here dup 'src !
	'r3filename
	dup "loading %s..." .println
	2dup load | "fn" mem
	here =? ( 3drop "no source code" .println ; )
	0 swap c!+ 'here !
	0 'error !
	0 'cnttokens !
	0 'cntdef !
	'inc 'inc> !
	".pass1" .println
	swap r3-stage-1

	error 1? ( 4drop "ERROR %s" .println lerror "%l" .println ; ) drop
	cntdef cnttokens cntinc "includes:%d tokens:%d definitions:%d" .println

	".pass2" .println 
	r3-stage-2
	1? ( 4drop "ERROR %s" .println lerror "%l" .println ; ) drop
	code> code - 2 >> "tokens:%d" .println

	".pass3" .println
	r3-stage-3
	".pass4" .println 
	r3-stage-4
	3drop
	|-----------------
	".genset" .println
	r3-genset
	".gencode" .println 
	r3-gencode
	".gendata" .println
	r3-gendata
	;

:no10place | adr
	lerror 0? ( ; )
	0 src ( pick2 <? c@+
		10 <>? ( rot 1 + -rot )
		drop ) drop nip ;

:savedebug
	mark
	error ,s ,cr
	no10place ,d ,cr
	"mem/debuginfo.db" savemem
	empty
	;

: 	
	.reset "[07Win64 Compiler" .awrite .cr .cr .cr .cr 
	
	'name r3c
	error 1? ( drop savedebug ; ) drop
	
|	"asm\compile.bat" sys
|	"r3fasm.exe" sys
	cols .hline
	"press any key to continue..." .print
	waitkey
	;

