^r3/win/console.r3

:.time
	time
	dup 16 >> $ff and "%d:" .print
	dup 8 >> $ff and "%d:" .print
	$ff and "%d" .println ;
	
: windows
.cls
"hora" .println 
.time

.input
;