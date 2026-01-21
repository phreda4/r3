| PHREDA 2025
^r3/lib/console.r3
^r3/util/utfg.r3

:testkey
	inevt	
	1 =? ( 
		evtkey 
		[esc] =? ( 2drop ; ) 
		1? ( dup "%h " sprint .write .flush	)
		drop  | ignora ceros
		)
	4 =? ( cols rows "(%d:%d)" .print .flush )
	1? ( dup "[%d]" .fprint )
	drop 
	10 ms
	testkey ;

:testkey2
	inkey
	1? ( 
		dup "  %h" sprint .write .cr 
		[esc] =? ( drop ; )	
		) | ignora ceros
	drop 
	.flush
	10 ms
	testkey ;
	
:main
	.bblack .cls .blue
	1 1 .at "Key Codes" .xwrite .cr .cr .cr .cr
	
	3000000 1000000/ "%d" .println
	.white .flush
	testkey ;

:  
[ ; ] .onresize
main 
.free ;
