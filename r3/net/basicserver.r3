^r3/win/console.r3
^r3/win/sdl2.r3
^r3/win/sdl2net.r3

|---------------------
:.ip | nro --
	dup 24 >> $ff and swap
	dup 16 >> $ff and swap
	dup 8  >> $ff and swap
	$ff and "%d.%d.%d.%d " .print
	;
	
:.iport | adr --
	d@+ dup $ff and
	swap 8 >> dup $ff and
	swap 8 >> dup $ff and
	swap 8 >> $ff and
	swap 2swap swap
	"%d.%d.%d.%d" .print
	d@ ":%d" .print
	;	

:.packet | adr --
	@+ "Chan:    %d" .println
	@+ "Data:    %s" .println
	d@+ "Len:     %d" .println
	d@+ "MaxLen:  %d" .println
	d@+ "status:  %d" .println
	@ .ip
	;

#server #client
#ip
#remoteip
#done 0
#message * 1024
#len 

:recing
|        /* read the buffer from client */
	client message 1024 SDLNet_TCP_Recv
	0? ( drop
		SDLNet_GetError "SDLNet_TCP_Recv: %s" .println
		; )
	'len !
|        /* print out the message */
	0 'message len + c!
	message "Received: %s" .println
	
	'message c@
	$51 =? ( drop |Q
		"Disconecting on a Q" .println
		1 'done !
		; )
	$71 =? ( drop |q
		"Disconecting on a q" .println
		; )
	drop
	recing ;
	
|-----------------	
:GetComputerName
	;
	
#compuname "mipc"

:server
	"Starting server..." .println
	'ip 'compuname 9999 SDLNet_ResolveHost
	-1 =? ( drop
		SDLNet_GetError "SDLNet_ResolveHost: %s" .println
		; )
	"IP:" .print ip .ip .cr
	
	'ip SDLNet_TCP_Open 
	0? ( drop 
		SDLNet_GetError "SDLNet_TCP_Open: %s" .println
		; )
	'server !
	( done 0? drop
     | /* try to accept a connection */
		( server SDLNet_TCP_Accept 0? drop 
			100 sdl_delay )
		'client !

|      /* get the clients IP and port number */
		client SDLNet_TCP_GetPeerAddress 
		0? ( drop 
			SDLNet_GetError "SDLNet_TCP_GetPeerAddress: %s" .println
			; )
		'remoteip !
|      /* print out the clients IP and port number */
		"Accepted a connection from " .print
		'remoteip .iport
		recing
		)
	client SDLNet_TCP_Close
	;
|-----------------	
: 
	0 SDL_Init
	SDLNet_Init
	server
	SDLNet_Quit
	SDL_Quit
	"server: bye bye" .println
	waitesc
;

