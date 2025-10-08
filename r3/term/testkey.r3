| PHREDA 2025
^r3/lib/term.r3
^./utfg.r3

:testkey
	inevt	
	1 =? ( 
		evtkey [esc] =? ( 2drop ; ) 
		1? ( dup "  %h" sprint .write .cr   ) drop  | ignora ceros
		)
	|2 =? ( evtmb evtmxy " %d %d : %d" .print .cr )
	1? ( .flush ) | only redraw with event
	drop 
	10 ms
	testkey ;
	
:main
	.cls .blue
	1 1 .at "Key Codes" .xwrite .cr .cr .cr .cr
	.white .flush
	testkey ;

: .term 
main 
.free ;
