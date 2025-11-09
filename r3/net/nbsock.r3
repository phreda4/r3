| common socket library
| PHREDA 2025
^r3/lib/term.r3
^r3/lib/netsock.r3

:BUFF_SIZE 4096 ;
#LOCALHOST "127.0.0.1"

#AF_INET 2
#SOCK_STREAM 1
#SOL_SOCKET 1
#SO_REUSEADDR 2
#INVALID_SOCKET -1

#IPPROTO_TCP 6
|struct sockaddr_in {
|    short sin_family;         // Offset: 0, Size: 2 bytes
|    unsigned short sin_port;  // Offset: 2, Size: 2 bytes
|    struct in_addr sin_addr;  // Offset: 4, Size: 4 bytes
|    char sin_zero[8];         // Offset: 8, Size: 8 bytes
|};

#server_addr 0 0

    |struct sockaddr_in direccion;
    |direccion.sin_family = AF_INET;
    |direccion.sin_port = htons(puerto);
    |direccion.sin_addr.s_addr = INADDR_ANY;
	
::server |( port -- sock )
    AF_INET 'server_addr w!
	dup 8 << swap 8 >> or	'server_addr 2 + w!
	$0 						'server_addr 4 + d! |INADDR_ANY
| 'server_addr dumpadr

	AF_INET SOCK_STREAM 0 socket-create
	dup 'server_addr 16 socket-bind drop
	dup 1 socket-listen drop | MAXCON
	dup socket-set-nonblock drop 
|	dup socket-set-reuseaddr "2)%d" .println | drop
	;
	
#server_socket

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
	"hola" .fprintln
	
	9999 server 'server_socket !
	server_socket "socket: %d" .fprintln
	
	serverloop

	waitkey
	;
	
: 
socket-ini
main 
socket-end
;
