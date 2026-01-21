^r3/lib/console.r3
^r3/lib/win/core.r3
^r3/lib/netsock.r3

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
:infocode
	'buffer 2 +
	w@+ "ip:%h " .fprint
	w@+ "dstack:%h " .fprint
	w@+ "rstack:%h" .fprintln
	@+ "REGA:%h " .fprint
	@+ "REGB:%h" .fprintln
	"D:" .fprint
	@+ "%h " .fprint @+ "%h " .fprint @+ "%h " .fprint @+ "%h " .fprintln
	"R:" .fprint
	@+ "%h " .fprint @+ "%h " .fprint @+ "%h " .fprint @+ "%h " .fprintln
	drop
	;
	
#flags
	
:vminfo	
	client_socket 'buffer 'buflen 0 socket-recv 32 << 32 >> -? ( drop ; ) drop
	'buffer w@
	0? ( infocode )
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
	
:serverloop
	"." .fprint
	server_socket 'client_addr 'client_size socket-accept
	inkey [esc] =? ( 2drop ; ) drop
	-? ( drop 100 ms serverloop ; ) 
	'client_socket !
	vmrec
	|'buffer w@ "%d<<" .fprintln
	"debug conn..." .fprintln
	"[f1] step" .fprintln
	"[f2] step over" .fprintln
	"[f3] step out" .fprintln
	"[f4] step stack" .fprintln
	"[f5] continue" .fprintln
	0 'flags !
	loopdebug
	;
	
:main
	"test" .fprintln
	9999 server-socket 'server_socket !
	server_socket "socket: %d" .fprintln
	
	"cmd /c r3d ""r3/d4/test.r3""" sysnew |sysnewin
	|actual getname 'path "cmd /c r3d ""%s/%s""" sprint sysnew

	serverloop
	waitkey
	;
	
: 
socket-ini
main 
socket-end
;