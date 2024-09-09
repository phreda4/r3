
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
	w@ ":%d" .print
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
    drop
	'message 
	count 1 >? ( 2drop loopcl ; ) drop
	c@ tolow
	$71 =? ( drop ; ) | q/Q
	drop
	loopcl ;
	
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
	loopcl
    tcpsock SDLNet_TCP_Close
	;
	
|-----------------	
: 
	$ffff SDL_Init
	SDLNet_Init
	client
	SDLNet_Quit
	SDL_Quit
	"client: bye bye" .println
	waitesc
;

