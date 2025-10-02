^./console.r3
^./f8x8.r3

:testkey
    getch
    [esc] =? ( drop ; )
    "%h" .fprintln
    testkey ;
	
:main
	.cls .blue
	1 1 xat
	"Key Codes" xwrite .cr
	.white .flush
	testkey ;

: .console main .free ;
