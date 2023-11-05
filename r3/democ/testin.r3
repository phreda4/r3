^r3/win/console.r3

:main
	getch 
	$1B1001 =? ( drop ; )
	"getch: %h " .println
	main ;

:maini
	inkey 
	$1B1001 =? ( drop ; )
	0? ( drop maini ; )
	"inkey: %h " .println
	maini ;
	
	
: 
	.cls
	"show GETCH value for keys" .println
	"press ESC to quit." .println
|	.cr main 

	"show INKEY value for keys" .println
	"press ESC to quit." .println
	.cr maini 
	;

