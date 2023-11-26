| r3debug
| PHREDA 2020
|------------------
^r3/win/console.r3
^r3/win/mconsole.r3
^r3/editor/code-print.r3
^r3/system/meta/metalibs.r3

#strerror 0
#filename * 1024

#src

:r3load | 'filename --
	"" 'strerror !
	dup 'filename strcpy
	here dup 'src !
	swap load 
	here =? ( drop "no source code." 'strerror ! ; ) 
	0 swap c!+ 'here !
	src only13 
	;
	
:showsrc
	src 0? ( drop ; ) >r
	235 ,bc 
	1 2 rows 10 - cols 1 - r> code-print ;
	
:main | key --
	drop
	mark
	,reset ,hidec ,cls ,bblue
	'filename ,s "  " ,s strerror ,s
	
	showsrc
	
	,showc
	memsize type	| type buffer
	empty			| free buffer
	;
	
|--------------------- BOOT
: 	
|	'name "mem/main.mem" load drop
	"r3/demo/textxor.r3" r3load

	.getconsoleinfo
	.alsb .ovec .cls

	0 ( main getch $1B1001 <>? ) drop 
	.masb
	;

