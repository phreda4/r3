^./console.r3
^./utfg.r3

:testkey2
    getch
    [esc] =? ( drop ; )
    "%h" .fprintln
    testkey2 ;
	
:testkey
	inevt	
	1 =? ( 
		evtkey [esc] =? ( 2drop ; ) 
		1? ( dup "%h" .print .cr ) drop  | ignora ceros
		)
	|2 =? ( evtmb evtmxy " %d %d : %d" .print .cr )
	drop 
	10 ms
	.flush
	 
	testkey ;
	
:main
	.cls .blue
	1 1 xat
	"Key Codes" xwrite .cr
	.white .flush
	testkey ;

: .console 
|.enable-mouse 
main 
|.disable-mouse 
.free ;
