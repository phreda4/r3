^r3/win/console.r3
^r3/win/mconsole.r3

^r3/editor/code-print.r3

#src

:drawcode
	20 1 10 src code-print
	;
:main
	mark			| buffer in freemem
	,hidec ,reset ,cls
	drawcode
	,showc
	memsize type	| type buffer
	empty			| free buffer
	.input
	;
	

: 
here $ffff + dup 'src !
"main.r3" load 0 swap !
main ;