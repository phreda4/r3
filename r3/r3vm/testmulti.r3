| test multi virtual cpu
| PHREDA 2023

^r3/lib/console.r3
^r3/lib/rand.r3
^r3/util/arr16.r3

^r3/r3vm/r3ivm.r3
^r3/r3vm/r3itok.r3
^r3/r3vm/r3iprint.r3

#spad * 256
#output * 8192

|------
:xbye
|	exit 
;


|#wsys "BYE" "shoot" "turn" "adv" "stop"
#wsysdic $23EA6 $34A70C35 $D76CEF $22977 $D35C31 0
#xsys 'xbye

:immediate
	9 ,i | ; in the end
	vmresetr
	code> vmrun drop
	code> 'icode> !
	;

:parse&run
	'spad
|    dup c@ 0? ( 'state ! drop patchend pinput ; ) drop
	r3i2token
	state 0? ( immediate ) drop
	0 'spad ! 
	;

#vm1 #vm2 #vm3

:dumpvm | adr --
	dup vm@ >b
	8 ( 1? 1 - b@+ $ffffffff and "%h " .print ) drop
	.cr
	256 b+
	16 ( 1? 1 -
		16 ( 1? 1 -
			b> ip code + =? ( .red "*" .print .white )
			c@+ $ff and "%h " .print
			>b
			) drop .cr
		) drop
	.cr
	NOS CODE - "d:%d " .print
	CODE 256 + RTOS - "r:%d " .print

	;


:dumpvmcode | adr --
	vm@
	ip "ip:%h " .print
	TOS "TOS:%d " .print 
	|ip code + c@ "(%d) " .print
|	NOS "NOS:%h " .print
|	RTOS @ "RTOS:%d " .print
	NOS CODE 8 + - "d:%d " .print
	CODE 256 + RTOS - "r:%d " .print
	.cr
	mark
	code 256 + | skip stack
	( code> <?				| user
		d@+ code2name ,s 32 ,c 
		d@+ $ffff and + ) drop	
	0 ,c
	empty
	here .println
	;

:step
	vm1 vm@ ip code + 
	vmstep 
	code - 'ip ! vm1 vm!
|	vm2 vm@ ip code + vmstep code - 'ip ! vm2 vm!
|	vm3 vm@ ip code + vmstep code - 'ip ! vm3 vm!
	;

|----------------------------------
:mainloop
	.cls
	.green
	"r3i" .println .cr

	.cr 
	vm1 dumpvmcode
	vm1 dumpvm
	.cr
	
|	.cr vm2 dumpvmcode
|	.cr vm2 dumpvm

|	.cr vm3 dumpvmcode
|	.cr vm3 dumpvm

	.cr .white
	"> " .print
	getch 
	$1000 and? ( drop mainloop ; )
	$ff and 
	0? ( drop mainloop ; )
	$1 =? ( r> 2drop ; ) | <esc>  end
	$1c =? ( step ) | <enter>  step
	drop
	mainloop ;  


:main
	|getch drop

	'wsysdic syswor!
	'xsys vecsys!
	"init" .println
	mark
	$fff vmcpu 'vm1 !
	$fff vmcpu 'vm2 !
	$fff vmcpu 'vm3 !
	"loading" .println
	vm1 "r3/r3vm/robotcode/test1.r3i" vmload
	.cr
	error .println
	|getch drop
|	vm2 "r3/r3vm/robotcode/test2.r3i" vmload
|	vm3 "r3/r3vm/robotcode/test3.r3i" vmload

	mainloop
	;

: main ;