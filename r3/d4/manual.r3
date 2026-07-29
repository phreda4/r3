| view manual
| PHREDA 2026
^r3/lib/console.r3
^r3/util/tui.r3

#manual
#imanual
#cmanual
#nman 0
#mcnt 20

| * *	
| ** **
| ` `
:viewline | n --
	3 << imanual + @ |dup "%h :" .print
	$ffff and manual +
	( c@+ $ff and 32 >=? 
		
		.emit ) 2drop ;
	
:viewmanual
	.cls
	|cmanual "%d:" .println
	manual 
	0 ( 20 <?
		dup nman + viewline .cr
		1+ ) drop
	;

#intable
#incode

|##
|###
|####
:titu | #
	;
	
|- |
|* |
|---
:bull | -
	;
	
|> |	
:blac | >
	;
	
|~~~
|```
:code | ~
	;
	
|| |
:tabl | |
	;

:parseline | adr -- 
	dup manual - a!+
	c@+ 0? ( 2drop ; ) 
	$23 =? ( titu ) | #
	$2d =? ( bull ) | -
	$2a	=? ( bull ) | *
	$3e =? ( blac ) | >
	$7e =? ( code ) | ~
	$60 =? ( code ) | `
	$7c =? ( tabl ) | |
	( 13 <>? drop c@+ ) drop
	parseline ;
	
:main
	mark
	here dup 'manual !
	"doc/r3forth-manual.md" load 0 swap c!
	here only13 0 swap c!+
	dup >a 'imanual !
	manual parseline
	a> 8 - dup imanual - 3 >> 'cmanual !
	'here !

	|'viewmanual tui
	viewmanual
	
	waitesc
	;
	
: main ;