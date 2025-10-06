^r3/lib/console.r3


:
9 36 <<
"%h" .println
60 ( +? 
	1 over << clz "%d" .println
	3 - ) drop
waitesc
;
