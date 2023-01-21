^r3/win/console.r3

:loop
	0 ( 10 <?
		dup "count = %b" .println 
		1 + ) drop ;
:
.cls
33 34 "val1=%d val2=%d" .println
loop
waitesc
;