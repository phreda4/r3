^r3/win/console.r3


:main
	getch 
	$1B1001 =? ( drop ; )
	"getch: %h " .println
	main ;
	
: main ;

