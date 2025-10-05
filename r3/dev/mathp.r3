^r3/lib/console.r3
^r3/lib/math.r3

:main
	-0.1 ( 5.0 <?
		dup "x:%f " .print
		dup exp. "| exp:%f " .print
		dup ln. "| ln:%f " .print
		dup sqrt. "| sqrt:%f" .print
		.cr
		0.25 + ) drop
	( getch ]esc[ <>? drop ) drop
	;
	
: .cls
main
;