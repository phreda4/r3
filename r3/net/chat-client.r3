| simple client chat
| PHREDA 2023
^r3/lib/win/console.r3
^r3/lib/sdl2.r3
^r3/lib/sdl2net.r3

#ip |    IPaddress ip;
#tcpsock |    TCPsocket tcpsock;
#len
#result
#done 0

#msg * 1024


:.port | nro --
	dup 8 << $ff00 and 
	swap 8 >> $ff and or 
	;
	
:.ip | adr --
	d@+ dup $ff and
	swap 8 >> dup $ff and
	swap 8 >> dup $ff and
	swap 8 >> $ff and
	swap 2swap swap
	"%d.%d.%d.%d" .print
	w@ .port ":%d" .print
	;
	
#myname "JCarlos" 	
:SayHello
	'msg >a
	2 ca!+	| token new
	'ip @ a!+
	'myname @ a!+
	'myname 8 + @ a!+
	
	tcpsock 'msg 26 SDLNet_TCP_Send 'result !
	"Say Hello" .println
	;
	
:sendpad
	"> " .print .input .cr
	'pad count 'len !
	len 0? ( drop ; ) drop
	1 'msg c!
	'pad 'msg 1+ strcpy 
	tcpsock 'msg count SDLNet_TCP_Send 'result !
	result "send:result %d" .println
	'pad "q" = 1? ( 1 'done ! ) drop 
	;
	
:clientmain
	.cls
    "Starting client..." .println
	'ip "192.168.56.1" 9999 SDLNet_ResolveHost drop
	'ip .ip .cr
	( 'ip SDLNet_TCP_Open 0? drop 
		"Open error" .println ) 
	dup "open on %h" .println
	'tcpsock !
	SayHello
	( done 0? drop
		sendpad ) drop
    tcpsock SDLNet_TCP_Close
	;
	
: 	
	$ffff SDL_Init  
	SDLNet_Init 
	
	clientmain
	
	SDLNet_Quit
	SDL_Quit
	"CLIENT: bye." .println	
	;
