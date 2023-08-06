| simple client chat
| PHREDA 2023
^r3/win/console.r3
^r3/win/sdl2.r3
^r3/win/sdl2net.r3

#ip |    IPaddress ip;
#tcpsock |    TCPsocket tcpsock;
#len
#result
#done 0

:.ip | adr --
	d@+ dup $ff and
	swap 8 >> dup $ff and
	swap 8 >> dup $ff and
	swap 8 >> $ff and
	swap 2swap swap
	"%d.%d.%d.%d" .print
	d@ ":%d" .print
	;
	
:SayHello
	'pad >a
	2 ca!+
	ip @ a!+
	"Pepe" @ a!+
|	memcpy(&hello[CHAT_HELLO_PORT], &myip->port, 2);
	tcpsock 'pad len SDLNet_TCP_Send 'result !
	;
	
:sendpad
	"> " .print .input .cr
	'pad count 'len !
	len 0? ( drop ; ) drop
	tcpsock 'pad len SDLNet_TCP_Send 'result !
	'pad "q" = 1? ( 1 'done ! ) drop 
	;
	
:clientmain
	.cls
    "Starting client..." .println
	'ip "127.0.0.1" 9999 SDLNet_ResolveHost drop
	'ip .ip .cr
	'ip SDLNet_TCP_Open 'tcpsock !
	SayHello
	( done 0? drop
		sendpad ) drop
    tcpsock SDLNet_TCP_Close
	;
	
: 	
	0 SDL_Init  
	SDLNet_Init 
	clientmain
	;
