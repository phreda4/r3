^./console.r3
^./f8x8.r3

:testkey2
    getch
    [esc] =? ( drop ; )
    "%h" .fprintln
    testkey ;
	
:testkey
	inevt	
	1 =? ( evtkey [esc] =? ( 2drop ; ) "%h" .print .cr )
	2 =? ( evtmb evtmxy " %d %d : %d" .print .cr )
	drop 
	 .flush
	testkey ;
	
:main
	.cls .blue
	1 1 xat
	"Key Codes" xwrite .cr
	.white .flush
	testkey ;

: .console main .free ;
