^r3/win/console.r3

::trace | --
	">> trace <<" . 
	.input
	;


::clearlog
	0 0 "filelog.txt" save ;

::filelog | .. str --
	sprint count "filelog.txt" append ;