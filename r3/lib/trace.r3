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
		swap c@+ emit
		swap ) 2drop ;

::clearlog
	0 0 "filelog.txt" save ;

::filelog | .. str --
	sprint count "filelog.txt" append ;
	
#memini

:.dh
	$f and $30 + $39 >? ( 7 + ) emit ;
	
:.print2hex | nro --
	dup 4 >> .dh .dh ;
	
:showmem
	.cls
	memini 0
	( 24 <? swap
		dup "%h:" .print
		dup 32 ( 1? 1 - swap c@+ .print2hex swap ) 2drop
		": " .print
		32 ( 1? 1 - swap c@+ 32 <? ( $2e nip ) emit swap ) drop
		cr
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
	