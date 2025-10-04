^./console.r3
^./f8x8.r3

#.exit 0 :exit 1 '.exit ! ;

:scrmain
	.cls .greenl
	1 1 xat
	"R3Forth" xwrite .cr
	.white .flush
	;
	
:hkey
	evtkey 
	[esc] =? ( exit ) 
	|1? ( dup "%h" .fprint .cr ) 
	drop ;
	
:hmouse
	evtmb 1? (  evtmxy " %d %d " .fprintln ) drop
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
	scrmain
	testkey ;

: .console 
|.enable-mouse 
main 
|.disable-mouse 
.free ;
