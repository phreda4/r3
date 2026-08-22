| r3 win compiler - d4 version
| PHREDA 2026
|------------------
^r3/lib/console.r3

^r3/d4/r3token.r3
|^r3/d4/genx64.r3

#filename * 1024

:r3-genset
	mark
	";---r3 setings" ,print ,cr
	switchmem 20 << "MEMSIZE equ 0x%h" ,print ,cr
	"VEROPT equ 1" ,print ,cr | version OPT
	0 ,c
	"asm/set.asm"
	savemem
	empty ;

|------------------
:codew | nro -- nro
	dup 4 << dic + @ dic>name "%w " .print | debug
	;	
	
:generatecode	
	"generate..." .println
	0 ( cntdef 1- <?
		codew
		1+ )
	";-----BOOT-----" ,s ,cr
	codew
	drop
	;

: 	
	.reset 
	"Win64 Compiler" .println
	
	|'filename "mem/menu.mem" load drop
	"r3/d4/gen/plain.r3" 'filename strcpy
	
	'filename .write " compiling..." .println
	
	'filename r3load
	error 0? ( generatecode ) drop
	
|	"asm\compile.bat" sys
|	"r3fasm.exe" sys
	.cr
	
	"press any key to continue..." .print
	waitkey
	;

