^r3/win/console.r3

::trace | --
	">> trace <<" .print
	.input
	;

::memdump | adr cnt --
	( 1? 1 - 
		swap c@+ $ff and "%h " .print 
		swap ) 2drop ;

::memdumpc | adr cnt --
	( 1? 1 - 
		swap c@+ .emit
		swap ) 2drop ;

::clearlog
	"filelog.txt" delete ;

::filelog | .. str --
	sprint count "filelog.txt" append ;
	
#memini

:.dh
	$f and $30 + $39 >? ( 7 + ) .emit ;
	
:.print2hex | nro --
	dup 4 >> .dh .dh ;
	
:showmem
	.cls
	memini 0
	( 24 <? swap
		dup "%h:" .print
		dup 32 ( 1? 1 - swap c@+ .print2hex swap ) 2drop
		": " .print
		32 ( 1? 1 - swap c@+ 32 <? ( $2e nip ) .emit swap ) drop
		.cr
		swap 1 + ) 2drop ;
	
::memmap | inimem --
	'memini !
	( showmem
		getch $1B1001 <>? 
		$48 =? ( -32 'memini +! ) 
		$50 =? ( 32 'memini +! )
		$49 =? ( -32 23 * 'memini +! ) 
		$51 =? ( 32 23 * 'memini +! )		
		drop ) drop ;

#vmem
#cntbytes
	
:showmem
	.cls
	memini 0
	( 24 <? swap
		pick2 ex .cr
		swap 1 + ) 2drop ;
	 
::memmapv | 'v mem --
	'memini !
	memini over ex memini - 'cntbytes !
	( showmem
		getch $1B1001 <>? 
		$48 =? ( cntbytes neg 'memini +! ) 
		$50 =? ( cntbytes 'memini +! )
		$49 =? ( cntbytes -23 * 'memini +! ) 
		$51 =? ( cntbytes 23 * 'memini +! )		
		drop ) 2drop ;
	