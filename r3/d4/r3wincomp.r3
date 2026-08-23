| r3 win compiler - d4 version
| PHREDA 2026
|------------------
^r3/lib/console.r3

^r3/d4/r3token.r3
|^r3/d4/genx64.r3

#filename * 1024

|------------------ CODE
:codew | nro -- nro
	dup nro>dic @ 1 and? ( drop ; ) | only code
	
	dic>name "; --- :%w " ,print ,cr
	
	dup nro>dic toklen | nro adr len
	( 1? 1- swap
		d@+ "$%h " ,print
		swap ) 2drop
	,cr	
	
	;	
	
:generatecode	
	mark
	";---r3 code" ,print ,cr

	0 ( cntdef 1- <?
		codew
		1+ )
	";-----BOOT-----" ,s ,cr
	codew drop
	0 ,c
	"asm/code.asm"
	savemem 
	empty ;

|------------------ DATA
:coded | nro -- nro
	dup 4 << dic + @ 1 nand? ( drop ; ) | only data

	dic>name "; --- #%w " ,print ,cr | debug
	
	dup nro>dic toklend | nro adr len	
	( 1? 1- swap
		d@+ "$%h " ,print
		swap ) 2drop
	,cr
	;	
	
:generatedata
	mark
	";---r3 data" ,print ,cr

	0 ( cntdef <?
		coded
		1+ ) drop
	0 ,c
	"asm/data.asm"
	savemem 
	empty ;
	
|------------------ SETS
:generatesets
	mark
	";---r3 setings" ,print ,cr
	switchmem 20 << "MEMSIZE equ 0x%h" ,print ,cr
	"VEROPT equ 1" ,print ,cr | version OPT
	0 ,c
	"asm/set.asm"
	savemem 
	empty ;

|------------------ MAIN
:compiling..
	generatecode 
|	generatedata
|	generatesets
	;
	
: 	
	.reset 
	"Win64 Compiler" .println
	
	|'filename "mem/menu.mem" load drop
	"r3/d4/gen/plain.r3" 'filename strcpy
	
	" compiling " .write 'filename .write "..." .println
	'filename r3load
	error 0? ( compiling.. ) drop
	
|	"asm\compile.bat" sys
|	"r3fasm.exe" sys
	.cr
	
	"press any key to continue..." .print
	waitkey
	;

