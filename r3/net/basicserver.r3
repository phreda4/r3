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
:.port | nro --
	dup 8 << $ff00 and 
	swap 8 >> $ff and or 
	;
	
:.iport | adr --
	d@+ dup $ff and
	swap 8 >> dup $ff and
	swap 8 >> dup $ff and
	swap 8 >> $ff and
	swap 2swap swap
	"%d.%d.%d.%d" .print
	w@ .port ":%d" .print
	;	

:.packet | adr --
	@+ "Chan:    %d" .println
	@+ "Data:    %s" .println
	d@+ "Len:     %d" .println
	d@+ "MaxLen:  %d" .println
	d@+ "status:  %d" .println
	@ .ip
	;

#server 
#client
#ip 0 
#remoteip 0 
#done 0
#message * 1024
#len 

:recing
|        /* read the buffer from client */
	client 'message 1024 SDLNet_TCP_Recv
	0? ( drop
		SDLNet_GetError "SDLNet_TCP_Recv: %s" .println
		; )
	'len !
|        /* print out the message */
	0 'message len + c!
	'message len "Rec:[%d] %s" .println

	len 
	1 =? (
		'message c@
		$51 =? ( 2drop |Q
			"Disconecting on a Q" .println
			1 'done !
			; )
		$71 =? ( 2drop |q
			"Disconecting on a q" .println
			; )
		drop
		) drop
	recing ;
	
|-----------------	
:.iplocal
	"cmd /c C:\\Windows\\System32\\ipconfig | findstr /i ""ipv4"" > mem\\local.ip" sys
	here "mem\\local.ip" load 0 swap c!
	here .println
	;
	
#compuname "127.0.0.1"
|#compuname "mipc"

:runserver
	"Starting server..." .println
	
	'ip 0 1234 SDLNet_ResolveHost
|	'ip 'compuname 1234 SDLNet_ResolveHost	
	-1 =? ( drop
		SDLNet_GetError "SDLNet_ResolveHost: %s" .println
		; ) drop
|	"IP:" .print 'ip .iport	.cr
	
	'ip 4 + w@ .port "   Network Port. . . . . . . . . . . . . .: %d" .println
	.iplocal
	
	'ip SDLNet_TCP_Open 
	0? ( drop 
		SDLNet_GetError "SDLNet_TCP_Open: %s" .println
		; )
	'server !
	
	( done 0? drop
		"esperando..." .println
     | /* try to accept a connection */
		( server SDLNet_TCP_Accept 0? drop 
			10 sdl_delay )
		'client !
		"llego" .println
|      /* get the clients IP and port number */
		client SDLNet_TCP_GetPeerAddress 
		0? ( drop 
			SDLNet_GetError "SDLNet_TCP_GetPeerAddress: %s" .println
			; )
		'remoteip !
|      /* print out the clients IP and port number */
		"Accepted a connection from " .print
		'remoteip .iport .cr .cr
		recing
		)
	client SDLNet_TCP_Close
	;
|-----------------	
: 
	$ffff SDL_Init
	SDLNet_Init
	runserver
	SDLNet_Quit
	SDL_Quit
	"server: bye bye" .println
	waitesc
;

