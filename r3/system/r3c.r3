| r3 compiler
| PHREDA 2019
|------------------
^./r3base.r3
^./r3pass1.r3
^./r3pass2.r3
^./r3pass3.r3
^./r3pass4.r3
^./r3gencod.r3
^./r3gendat.r3

:r3-genset
	mark
	";---r3 setings" ,ln
	switchmem 20 << "MEMSIZE equ 0x%h" ,print ,cr
	0 ,c
	"asm/set.asm"
	savemem
	empty ;

::r3c | str --
	r3name
	here dup 'src !
	'r3filename

	dup "load %s" .print

	2dup load | "fn" mem
	here =? ( "no src" .print ; )
	0 swap c!+ 'here !
	0 'error !
	0 'cnttokens !
	0 'cntdef !
	'inc 'inc> !
	" pass1" .print
	swap r3-stage-1
	error 1? ( "ERROR %s" .print ; ) drop
	cntdef cnttokens "toks:%d def:%d" .print
	" pass2" .print
	r3-stage-2
	1? ( "ERROR %s" .print ; ) drop
	code> code - 2 >> "..code:%d" .print
	" pass3" .print
	r3-stage-3
	" pass4" .print
	r3-stage-4
	" genset" .print
	r3-genset
	" gencode" .print
	r3-gencode
	" gendata" .print
	r3-gendata
	;

: 	.cls
	" PHREDA - 2019" .println
	" r3 compiler" .println

	"r3/test/test.r3"
|	"r3/test/testgui.r3"
	r3c

|    "asm\fasm.exe asm\r3fasm.asm > log.asm" sys
    "asm\fasm.exe asm\r3fasm.asm" sys
	waitesc
	;

