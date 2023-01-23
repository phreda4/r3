^r3/win/console.r3
^r3/lib/3d.r3

::.matprint
	mat>
	@+ "%f " .print @+ "%f " .print @+ "%f " .print @+ "%f " .println
	@+ "%f " .print @+ "%f " .print @+ "%f " .print @+ "%f " .println
	@+ "%f " .print @+ "%f " .print @+ "%f " .print @+ "%f " .println
	@+ "%f " .print @+ "%f " .print @+ "%f " .print @+ "%f " .println
	drop
	;
:
.cls
"mat" .println
matini .matprint cr
mpush
0.9 4.0 3.0 /. 0.1 1000.0 mper .matprint cr
m* .matprint cr
.input

;