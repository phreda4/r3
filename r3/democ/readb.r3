| print a row
^r3/win/console.r3
^r3/util/dbtxt.r3

:printdb
	rowdb "** %d **" .println
	0 ( 4 <? 
		">>" .print
		dup dbfld .println
		1 + ) drop ;
		
:main
	"dbtest" .println
	( getch 27 <>? drop
		"media/db/test.db" loaddb-i
		printdb
		) drop
	;

	
: main ;