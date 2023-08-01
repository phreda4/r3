| simple server chat
| PHREDA 2023
^r3/win/console.r3
^r3/win/sdl2.r3
^r3/win/sdl2net.r3

#server #client |TCPsocket server, client;
#ip |IPaddress ip;
#remoteip |IPaddress *remoteip;
#ipaddr |Uint32 ipaddr;
#message * 1024 | char message[1024];
#len 
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

:waitclient
	( server SDLNet_TCP_Accept 0? drop 
		100 SDL_Delay 
		) 'client !
	client "client:%h " .println
	;
	
:servermain
	.cls
    "Starting server..." .println
    'ip 0 9999 SDLNet_ResolveHost drop
	'ip SDLNet_TCP_Open 'server !
	'ip .ip .cr
	server "%h" .println
	( done 0? drop
		waitclient
		client SDLNet_TCP_GetPeerAddress 'remoteip !
		"Accepted a connection from " .print 'remoteip .ip .cr
		( done 0? drop
			( client 'message 1024 SDLNet_TCP_Recv 0? drop ) 'len !
			0 'message len + c!
			'message .println
			'message "q" = 1? ( 1 'done ! ) drop
	|        if (message[0] == 'q') { printf("Disconecting on a q\n");break;     }
	|        if (message[0] == 'Q') { printf("Closing server on a Q.\n");done = true;break;         }
			) drop
      ) drop
	client SDLNet_TCP_Close
	;
	
: 	
	0 SDL_Init  
	SDLNet_Init 
	servermain
	;
