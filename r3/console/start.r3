^./console.r3
^./utfg.r3

#.exit 0 :exit 1 '.exit ! ;

:scrmain
	.cls .bblue .white
	2 1 xat
	"R3" xwrite .bred "Forth" xwrite .cr

	.bgreen 10 10 10 10 .box
	16 15 .at "1234567890" .write
	
	.reset
	18 14 6 4 .boxl
	28 10 10 6 .boxd
	
	.reset .flush
	;
	
:hkey
	evtkey 
	[esc] =? ( exit ) 
	|1? ( dup "%h" .fprint .cr ) 
	drop ;
	
:hmouse
	evtmb 
	1? ( evtmxy .at "." .fwrite ) 
	drop
	;
	
:testkey
	( .exit 0? drop
		inevt	
		1 =? ( hkey )
		2 =? ( hmouse )
		drop 
		20 ms
		) drop ;
	
:main
	'scrmain .onresize
	scrmain
	testkey ;

: .console 
main 
.free ;
