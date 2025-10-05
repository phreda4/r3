^r3/lib/console.r3

:main
	-1.0 ( 5.0 <?
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