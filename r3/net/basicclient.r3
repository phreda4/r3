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

#ip
#tcpsock
#message * 1024

:loopcl
	"> " .print .input
	'pad 'message strcpy
	.cr 
	'message "sending: %s" .println
	
	tcpsock 'message count SDLNet_TCP_Send
|        if (result < len)  printf("SDLNet_TCP_Send: %s\n", SDLNet_GetError());
    drop
	'message c@ tolow
	$71 =? ( drop | q/Q
		; )
	drop
	loopcl ;
	
:client
    "Starting client..." .println
	'ip "127.0.0.1" 9999 SDLNet_ResolveHost 
	-1 =? ( drop
		SDLNet_GetError "SDLNet_ResolveHost: %s" .println
		; )
	'ip SDLNet_TCP_Open 
	0? ( drop
		SDLNet_GetError "SDLNet_TCP_Open: %s" .println
		; )
	'tcpsock !
	loopcl
    tcpsock SDLNet_TCP_Close
	;
	
|-----------------	
: 
	0 SDL_Init
	SDLNet_Init
	client
	SDLNet_Quit
	SDL_Quit
	"client: bye bye" .println
	waitesc
;

