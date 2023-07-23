| code
^r3/win/console.r3
|^r3/lib/rand.r3

::waitesc
	( getch	$1B1001 <>? drop ) drop ;
	
:test
	"test" .println
	waitesc
	;

: test ;
