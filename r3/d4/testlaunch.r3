^r3/lib/term.r3
^r3/lib/win/core.r3
^r3/lib/netsock.r3

#buflen 4096
#buffer * 4096

#sock
:waitrec
	|( sock buf len flags -- bytes_recv )
	( sock 'buffer buflen 0 socket-recv 0? drop 
		"." .fprint
		50 ms ) | wait rec
	"%d>>" .print
	"recv:" .print
	'buffer .println
	.flush ;

:servidor
	9999 server-socket 'sock !
	( waitrec
	sock "OK" 3 0 socket-send |( sock data len flags -- bytes_sent )\
	"%d<<" .println .flush 
		)
	socket-final ;
	

#sockc 
:cliente
	client-socket 'sockc !
	9999 
	socket-final ;
	
|	client_connect(9999);
|	sock_send("Hola", 4);
|	if (sock_recv() > 0) {
|	printf("Respuesta: %s\n", get_conn()->rx_buf);
|	}
|	sock_close()
|	;

:main
	"test" .println
	"r3.exe r3/term/fire.r3" sysnew |sysnewin
|servidor
	;
	
: 
main 
;