| CLIENT
| PHREDA 2024
^r3/win/console.r3
^r3/win/sdl2.r3
^r3/win/sdl2net.r3

#ip
#tcpsock
#socketSet

#msgsend * 1024
#msgrecv * 1024

:juego
	msec ":%h:" sprint 'msgsend strcpy
	
	tcpsock 'msgsend 50 SDLNet_TCP_Send
	-? ( drop ; ) drop
	
	tcpsock 'msgrecv 50 SDLNet_TCP_Recv
	'msgrecv + 0 swap c!
	'msgrecv .print 
	
	inkey $1B1001 =? ( drop ; ) drop
	500 sdl_delay
	juego
	;
	
:client
    "Starting client..." .println
	'ip "192.168.56.1" 1234 SDLNet_ResolveHost 
	-1 =? ( drop
		SDLNet_GetError "SDLNet_ResolveHost: %s" .println
		; ) drop
	'ip SDLNet_TCP_Open 
	0? ( drop
		SDLNet_GetError "SDLNet_TCP_Open: %s" .println
		; )
	'tcpsock !
	
	2 SDLNet_AllocSocketSet 'socketSet !
	socketSet tcpsock SDLNet_AddSocket
	
	juego
	
	socketSet SDLNet_FreeSocketSet
    tcpsock SDLNet_TCP_Close
	;
	
|-----------------	
: 
	$ffff SDL_Init
	SDLNet_Init
	client
	SDLNet_Quit
	SDL_Quit
	"client: bye" .println
	;

