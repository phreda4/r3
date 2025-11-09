^r3/lib/term.r3
^r3/lib/win/core.r3
^r3/lib/netsock.r3


#server_socket

#buflen 4096
#buffer * 4096

#client_socket
#client_addr 0 0
#client_size 16

:handlerequest
	"cliente conectado" .fprintln
	;
	
:serverloop
	server_socket 'client_addr 'client_size socket-accept
|	dup "ok %d" .fprintln 
	inkey [esc] =? ( 2drop ; ) drop
	-? ( drop 100 ms serverloop ; ) 
	'client_socket !
	handlerequest
	serverloop ;	
	
:main
	"test" .fprintln
	9999 server-socket 'server_socket !
	server_socket "socket: %d" .fprintln
	
	"""../r3evm/r3d.exe"" r3/arco.r3" sysnew |sysnewin
|servidor
	serverloop
	;
	
: 
socket-ini
main 
socket-end
;