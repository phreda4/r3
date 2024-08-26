| simple server chat
| PHREDA 2023
^r3/win/console.r3
^r3/win/sdl2.r3
^r3/win/sdl2net.r3

#maxpeople  10

| socket(8) peer(8) name(8+8) (16 bytes)
#people * 1024
#lpeople 0

#socketset
#serverIP
#servsock

:.ip | adr --
	d@+ dup $ff and
	swap 8 >> dup $ff and
	swap 8 >> dup $ff and
	swap 8 >> $ff and
	swap 2swap swap
	"%d.%d.%d.%d" .print
	d@ ":%d" .print
	;
	
:showpeople
	0 ( lpeople <=?
		dup 4 << 'people +
		@+ "%h " .print
		dup .ip |"%h " .print
		8 + " name:%s " .println
		1 + ) drop ;
		
:initnet
	0 SDL_Init  
	SDLNet_Init 

	maxpeople 1 + SDLNet_AllocSocketSet 'socketset !
	
    'serverIP "mipc" 9999 SDLNet_ResolveHost
|printf("Server IP: %x, %d\n", serverIP.host, serverIP.port);
	'serverip .ip .cr
	
    'serverIP SDLNet_TCP_Open 'servsock !
	socketset servsock SDLNet_AddSocket drop
 	;
	
#newsock	
:HandleServer | sr -- sr
	servsock SDLNet_TCP_Accept 'newsock !
	lpeople 4 << 'people + >a 
	newsock a!+
	newsock 99999 @ a!
	"new client" .println
	showpeople
	;

| comm - sock(8) - peer(8) - data	
#data * 1024	

:SendNew | a t --
	swap
	4 << 'people + >a
	1 'data c! | add client
	8 a+
	a@+ 'data 1 + !
	a@+ 'data 9 + ! | name?
	4 << 'people + @ 'data 10 SDLNet_TCP_Send
	;
	
:removeclient | nro sockeready -- nro sockeready	
	"remove client" .println
	;
	
:addclient | nro sockeready -- nro sockeready
	"addclient client" .println
	'data 1 + @ 32 >> $ffff and
	pick2 4 << 'people + 8 + 4 + w! | store port
	
	'data 1 + 8 + @ .println
	pick2 4 << 'people + 8 + 8 + ! | store name ( 8bytes)
	
	0 ( lpeople <?
		pick2 over sendnew
		1 + ) drop 
	0 ( lpeople <?
		dup pick3 sendnew
		1 + ) drop 
	
	1 'lpeople +!
	showpeople	
	;
		
:HandleCliente | nro sockeready -- nro sockeready
	over 4 << 'people + @ 'data 512 SDLNet_TCP_Recv
	0 <=? ( drop removeclient ; ) drop
	'data .println
	'data c@
	2 =? ( drop addclient ; )
	dup "error client in %d" .println
	drop
	;
	
:servermain
	( inkey  $1B1001 <>? drop
		socketset -1 SDLNet_CheckSockets
		servsock 1? ( HandleServer ) drop
		0 ( maxpeople <? 
			'people over 4 << + @ 
			1? ( HandleCliente ) drop
			1 + ) drop
		) drop ;
	
: 	
	initnet
	servermain
	;