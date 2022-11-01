^r3/win/console.r3

:main
	getch 
	$1B1001 =? ( drop ; )
	"getch: %h " .println
	main ;
	
: 
	.cls
	"show GETCH value for keys" .println
	"press ESC to quit." .println
	cr
	main ;

