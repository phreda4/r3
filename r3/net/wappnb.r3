| wapp
| PHREDA 2025

^r3/lib/console.r3
^r3/lib/win/winsock.r3

#PORT 80
#WSAData * 512

#AF_INET 2
#SOCK_STREAM 1
#IPPROTO_TCP 6
#FIONBIO $80667E00 

|#hint 0 0 0 0 0 0
|#hont 0 0 0 0 0 0
|#result	'hont

#server_socket
#server_addr 0 0

#client_socket
#client_addr 0 0
#client_size 16

#iMode 1 | // 0 para bloqueante, 1 para no bloqueante

|--------------------------	
:dumpreq
	client_addr "-------from: %h" .println
|	hmethod .print "|" .print huri .print "|" .print hversion .print "|" .print
|	hhost .print "|" .print hreferer .print "|" .print hcookie .println
|	hbody .println 
	"-------------------" .println
	;
		
|struct sockaddr_in {
|    short sin_family;         // Offset: 0, Size: 2 bytes
|    unsigned short sin_port;  // Offset: 2, Size: 2 bytes
|    struct in_addr sin_addr;  // Offset: 4, Size: 4 bytes
|    char sin_zero[8];         // Offset: 8, Size: 8 bytes
		
:handlerequest
	mark
	client_socket here 1024 0 recv | 'bytesrec !
	0 here rot + c!
	
|	parseheader
	dumpreq
|	getvars
	
|	sendresponse
	
    client_socket closesocket
	empty
	;

#readset * 516 | 64*8 +4
#timeout 0 100 | 0 sec 100 usec

:webserver
	100 0 'timeout !+ !
	server_socket 1 'readset d!+ !
	
	0 'readset 0 0 'timeout select
	|0 0 0 0 'timeout select 
	32 << 32 >>
|	dup "> %h" .println
|	server_socket <>? ( 0 nip ) 
	0? ( drop	| IDLE
		inkey 
		$1b1001 =? ( drop ; ) 
		drop
		webserver ; )
	-? ( drop 	| ERROR
		|"error" .println 
		webserver 
		; )
	drop	| IN
	server_socket 'client_addr 'client_size accept
	-? ( drop webserver ; ) 
	'client_socket !
	
	handlerequest
	
	10 ms
	webserver
	;

|---------------------------------------------- 
:serverini
	$0202 'WSAData WSAStartup
	1? ( "error %d" .println ; ) drop

|	'hint >a
|	1 da!+			| flags=AI_PASSIVE
|	AF_INET da!+	| family 
|	SOCK_STREAM da!+	| socktype
|	IPPROTO_TCP da!		| protocol
	
|	0 "80" 'hint 'result getaddrinfo
|	1? ( "error %d" .println ; ) drop

	
	AF_INET SOCK_STREAM IPPROTO_TCP socket 
	-? ( "error %d" .println WSACleanup ; )
	'server_socket !

|	server_socket 1 'readset d!+ !
	
|	server_socket FIONBIO 'imode ioctlsocket
|	-? ( "error %d" .println WSACleanup ; ) drop
	
    AF_INET 'server_addr w!
	PORT dup 8 << swap 8 >> or	'server_addr 2 + w!
	$0 'server_addr 4 + d! |INADDR_ANY

	server_socket 'server_addr 16 bind 32 << 32 >>
	-? ( "error %d" .println server_socket closesocket WSACleanup ; ) drop
	
	server_socket 1 listen 32 << 32 >>
	-? ( "error %d" .println server_socket closesocket WSACleanup ; ) drop
	
	PORT "App port:%d" .println
	server_socket "Sock:%h" .println
	;
	
:serverend	
	"End App" .println
	WSACleanup ;
	
: |<<<<< BOOT <<<<<<<
	serverini
	webserver
	serverend
	;
