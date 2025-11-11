^r3/lib/term.r3
^r3/lib/win/core.r3
^r3/lib/netsock.r3

#server_socket

#buflen 4096
#buffer * 4096

#client_socket
#client_addr 0 0
#client_size 16

:waitok
	client_socket 'buffer 'buflen 0 socket-recv
	32 << 32 >>
	-? ( drop ; )
	dup ">>>rec:%d" .fprintln
	'buffer + 0 swap c!
|	::socket-send |( sock data len flags -- bytes_sent )
|::socket-recv |( sock buf len flags -- bytes_recv )
	'buffer .fprintln
	
	client_socket "ide" 3 0 socket-send |( sock data len flags -- bytes_sent )
	">>>send:%d" .fprintln
	;
	
:handlerequest
	inkey [esc] =? ( 2drop ; ) drop
	waitok
	50 ms
	|"." .fprint
	handlerequest ;
	
:serverloop
	"-" .fprint
	server_socket 'client_addr 'client_size socket-accept
|	dup "ok %d" .fprintln 
	inkey [esc] =? ( 2drop ; ) drop
	-? ( drop 100 ms serverloop ; ) 
	'client_socket !
	"cliente conectado" .fprintln
	handlerequest
	;
	
:main
	"test" .fprintln
	9999 server-socket 'server_socket !
	server_socket "socket: %d" .fprintln
	
	"cmd /c r3d ""r3/d4/test.r3""" sysnew |sysnewin
	|actual getname 'path "cmd /c r3d ""%s/%s""" sprint sysnew

	serverloop
	;
	
: 
socket-ini
main 
socket-end
;