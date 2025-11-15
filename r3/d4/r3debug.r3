^r3/util/tui.r3
^r3/util/tuiedit.r3

^r3/lib/term.r3
^r3/lib/win/core.r3
^r3/lib/netsock.r3

#state 0
#filename * 1024

#msg * 1024
#server_socket

#buflen 4096
#buffer * 4096

#client_socket
#client_addr 0 0
#client_size 16

:vmrec
	client_socket 'buffer 'buflen 0 socket-recv
	32 << 32 >>	0 >? ( drop ; ) drop
	inkey [esc] =? ( drop ; ) drop
	50 ms 
	vmrec ;
	
|---------------------------------
|	short type;
|	unsigned short ip;		|2
|	short dstack,rstack;	|4 6
|	__int64 REGA;			| 8
|	__int64 REGB;			| 16
|	__int64 DATA[4];		| 24..
|	__int64 RETU[4];		|
#infodb * 88
:infocode
|	'buffer 2 +
	'infodb 2 +
	w@+ "ip:%h " .print
	w@+ "dstack:%h " .print
	w@+ "rstack:%h" .println
	@+ "REGA:%h " .print
	@+ "REGB:%h" .println
	"D:" .print
	@+ "%h " .print @+ "%h " .print @+ "%h " .print @+ "%h " .println
	"R:" .print
	@+ "%h " .print @+ "%h " .print @+ "%h " .print @+ "%h " .println
	drop
	;
	
#flags
	
:vminfo	
	client_socket 'buffer 'buflen 0 socket-recv 32 << 32 >> -? ( drop ; ) drop
	'buffer w@
	0? ( |infocode 
		'infodb 'buffer 11 move |DSC
		)
	-1 =? ( 1 'flags ! )
	drop
	;
	
:vmsend1 | n --
	'buffer c! 
	client_socket 'buffer 1 0 socket-send drop ;
	
:vmsend2 | i n --
	'buffer c!+ d!
	client_socket 'buffer 5 0 socket-send drop ;
	
:loopdebug
	( flags 1 nand? drop 
		inkey
		[esc] =? ( 1 'flags ! ) 
		[f1] =? ( 0 vmsend1 )
		[f2] =? ( 1 vmsend1 )
		[f3] =? ( 2 vmsend1 )
		[f4] =? ( 3 vmsend1 )
		[f5] =? ( 4 vmsend1 )
		
		[f7] =? ( 6 vmsend1 )	| end debug
		drop
		vminfo
		100 ms
		) drop 
	"fin debug" .fprintln
	;
	
|---- screen
:scrViews
	.reset
	cols 2/ flxO 
	flxpush
	
	8 flxN
	tuWina $1 "Watch" .wtitle 1 1 flpad 
|	'vincs lincs tuList
	
	flxRest
	tuWina $1 "Stack" .wtitle 1 1 flpad 
	
	infocode
	
|	'xwrite.word xwrite!
|	'vwords lwords tuList | 'var list --
|	xwrite.reset
	flxpop
	;
	

:scrmsg	
	.reset
	4 flxS tuWina $1 "Imm" .wtitle |242 .bc
	fx fy .at
	'msg .print
	;

	
:maindb
	.reset .cls 
	2 flxN
	4 .bc 7 .fc
	fx fy .at fw .nsp fx .col
	" R3forth DEBUG [" .write
	'filename .write 
	"] " .write
	client_socket "%h" .write

	scrmsg
	scrViews
	
	.reset
	flxRest tuWina 
	$4 'filename .wtitle
	$23 mark tudebug ,s ,eol empty here .wtitle
	1 1 flpad 
	|tuEditCode
	tuReadCode | 
	
	
	uiKey
	|[esc] =? ( 1 'flags ! ) 
	[f1] =? ( 0 vmsend1 ) 	|"[f1] step" .fprintln
	[f2] =? ( 1 vmsend1 ) |"[f2] step over" .fprintln
	[f3] =? ( 2 vmsend1 ) |"[f3] step out" .fprintln
	[f4] =? ( 3 vmsend1 ) |"[f4] step stack" .fprintln
	[f5] =? ( 4 vmsend1 ) |"[f5] continue" .fprintln
	
	[f7] =? ( 6 vmsend1 )	| end debug
	
|	[f1] =? ( checkcode ) |show256 )
|	[f2] =? ( debugcode ) |show256 )
	
|	[f6] =? ( screenstate 1 xor 'screenstate ! )
|	[f7] =? ( screenstate 2 xor 'screenstate ! )
	drop
	vminfo
	|100 ms
	;

:connect
	"." .fprint
	inkey [esc] =? ( 2drop ; ) drop
	server_socket 'client_addr 'client_size socket-accept
	-? ( drop 100 ms connect ; ) 
	'client_socket ! ;
	
:main
	9999 server-socket 'server_socket !
|	server_socket "socket: %d" .fprintln
	
	'filename 
	"cmd /c r3d ""%s""" sprint
	sysnew 

	connect
	client_socket 0? ( drop ; ) drop
	vmrec
	'maindb onTui
	6 vmsend1  | end
	;

: 
	socket-ini
	.alsb 
	|'filename "mem/menu.mem" load	
	"r3/d4/test.r3" 'filename strcpy
	
	'filename TuLoadCode
	|TuNewCode
	
	mark
	main
	.masb .free 

	socket-end
	;