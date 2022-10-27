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