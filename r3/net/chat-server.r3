| simple server chat
| PHREDA 2023
^r3/win/console.r3
^r3/win/sdl2.r3
^r3/win/sdl2net.r3

|-----------------	
:.iplocal
	"cmd /c C:\\Windows\\System32\\ipconfig | findstr /i ""ipv4"" > mem\\local.ip" sys
	here "mem\\local.ip" load 0 swap c!
	here .println
	;
	
:.port | nro --
	dup 8 << $ff00 and 
	swap 8 >> $ff and or 
	;
	
#maxpeople  10

| socket(8) peer(8) name(8+8) (16 bytes)
|static struct {
|	TCPsocket sock;
|	IPaddress peer;
|	Uint8 name[16];
#people * 1024 | n <<5
#lpeople 0

#socketset
#serverIP
#servsock

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
	
:showpeople
	0 ( lpeople <?
		dup "%d." .print
		dup 5 << 'people +
		@+ "%h " .print
		@+ "%h " .print
		@+ "%h:" .print
		@ "%h" .println
|		8 + " name:%s " .println
		1+ ) drop ;
		
	
#newsock	
:HandleServer | sr -- sr
	servsock SDLNet_TCP_Accept 
	0? ( drop ; )
	'newsock !
	
	lpeople 5 << 'people + >a 
	newsock a!+
	newsock SDLNet_TCP_GetPeerAddress @ a!
	"New client" .println
	showpeople
	;
|    newsock = SDLNet_TCP_Accept(servsock);
 |   if ( newsock == NULL ) {
  |      return;
   | }	
|        people[which].sock = newsock;
 |       people[which].peer = *SDLNet_TCP_GetPeerAddress(newsock);
  |      SDLNet_TCP_AddSocket(socketset, people[which].sock);

|---------------------------------------------- client
| comm - sock(8) - peer(8) - data	
#data * 1024	
#datalen 

:SendNew | a t --
	swap
	5 << 'people + >a
	1 'data c! | add client
	8 a+
	a@+ 'data 1 + !
	a@+ 'data 9 + ! | name?
	5 << 'people + @ 'data 10 SDLNet_TCP_Send
	;
	
:removeclient | nro sockeready -- nro sockeready	
	"remove client" .println
	;
	
:debugdata
	a[
	'data >a
	datalen ( 1?
		ca@+ $ff and "%h " .print
		1- ) drop 
	]a ;
	
:comunica
	0 ( lpeople <? 
		pick2 over sendnew
		1+ ) drop 
	0 ( lpeople <? 	
		dup pick3 sendnew
		1+ ) drop 
	;
		
:addclient | nro sockeready -- nro sockeready
	"Addclient client" .println
	
|	over 5 << 'people + 16 + >a
|	'data 1 + 
|	8 +
|	@+ a!+ @ a! | name
	
|	'data 1 + 8 + @ .println
|	pick2 5 << 'people + 8 + 8 + ! | store name ( 8bytes)
	
	| comunica
	
	1 'lpeople +!
	showpeople	
	;
	
:msgclient
	0 'data datalen + c!
	over "%d]" .print
	'data 1+ .println
	;
		
:HandleCliente | nro sockeready -- nro sockeready
	"hc??" .print
	over 5 << 'people + @ 'data 512 SDLNet_TCP_Recv
	0 <=? ( drop removeclient ; ) 'datalen !
	datalen "recive len%d" .println
	'data c@
	1 =? ( drop msgclient ; )
	2 =? ( drop addclient ; )
	dup "error client in %d" .println
	drop
	;
	
:servermain
	"Waiting..." .println
	"ESC - quit." .println
	( inkey $1B1001 <>? drop
		"." .print
		socketset 100 SDLNet_CheckSockets
		1? ( 
			"<" .print
			servsock 1? ( HandleServer ) drop
			0 ( maxpeople <? 
				'people over 5 << + @ 
				1? ( HandleCliente ) drop
				1+ ) drop
			) drop
		) drop ;

:initnet
	maxpeople 1+ SDLNet_AllocSocketSet 'socketset !
    'serverIP 0 9999 SDLNet_ResolveHost
	-1 =? ( drop
		SDLNet_GetError "SDLNet_ResolveHost: %s" .println
		; ) drop	
		
	'serverIP 4 + w@ .port "   Network Port. . . . . . . . . . . . . .: %d" .println
	.iplocal	
	|'serverip .ip .cr
	
    'serverIP SDLNet_TCP_Open 
	0? ( drop 
		SDLNet_GetError "SDLNet_TCP_Open: %s" .println
		; )
	'servsock !
	socketset servsock SDLNet_AddSocket drop
 	;
	
: 	
	$ffff SDL_Init
	SDLNet_Init
	
	initnet
	servermain
	
	SDLNet_Quit
	SDL_Quit
	"SERVER: bye." .println	
	;