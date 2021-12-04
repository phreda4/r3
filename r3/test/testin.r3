^r3/win/console.r3


:main
	getch 
	27 =? ( drop ; )
	"getch: %h " .println
	codekey "codekey: %h " .println
	
	main ;
	
: main ;