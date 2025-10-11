| PHREDA 2025
^r3/lib/term.r3
^./utfg.r3

:testkey
	inevt	
	1 =? ( 
		evtkey 
		[esc] =? ( 2drop ; ) 
		1? ( 
			dup "  %h" sprint .write .cr
			.flush
			)
		drop  | ignora ceros
		)
	|1? ( dup "evt %d" .fprint )
	drop 
	10 ms
	testkey ;


:testkey1
	inkey
	1? ( 
		dup "  %h" sprint .write .cr 
		.flush
		[esc] =? ( drop ; )	
		) | ignora ceros
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
