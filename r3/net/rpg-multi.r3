| Multiplayer RPG

^r3/win/sdl2gl.r3
^r3/win/sdl2gfx.r3
^r3/win/sdl2net.r3
^r3/util/arr16.r3
^r3/lib/rand.r3

#objs 0 0

#sprj
#spre
#xvp #yvp

|------- estado de juego


|-------------------------------------------	
#GAME_PACKETSIZE 256	
#GAME_PORT 7777
#server "localhost" |"220.233.28.6";

#serverIP
#myIP

#tcpsock
#udpsock
#socketset

#udpPacket
#packets 
#data * 512

:.ip | nro --
	"ip:" .print
	dup 24 >> $ff and swap
	dup 16 >> $ff and swap
	dup 8  >> $ff and swap
	$ff and "%d.%d.%d.%d" .println ;

|    int channel;        /* The src/dst channel of the packet */ 0
|    Uint8 *data;        /* The packet data */					8
|    int len;            /* The length of the packet data */	16
|    int maxlen;         /* The size of the data buffer */		20
|    int status;         /* packet status after sending */		24
|   IPaddress address;  /* The source/dest address of an incoming/outgoing packet */ 24
|} UDPpacket;
    |Uint32 host;            /* 32-bit IPv4 host address */	28
    |Uint16 port;            /* 16-bit protocol port */		32
|} IPaddress;

:.packet | adr --
	@+ "Chan:    %d" .println
	@+ "Data:    %s" .println
	d@+ "Len:     %d" .println
	d@+ "MaxLen:  %d" .println
	d@+ "status:  %d" .println
	@ .ip
	;


|/* Try ports in the range {GAME_PORT - GAME_PORT+10} */
:tryPorts
	0 ( 10 <?
		dup GAME_PORT + SDLNet_UDP_Open
		1? ( 'udpsock ! drop ; ) drop
		1 + ) drop
	tcpsock SDLNet_TCP_Close
	"Couldn't create UDP endpoint" .println
	;
	
|/* Allocate the socket set for polling the network */	
:allocateSocketSet
	2 SDLNet_AllocSocketSet 
	0? ( "Couldn't create socket set" .println drop ; ) 
	'socketset !
	socketset tcpsock SDLNet_AddSocket drop
	socketset udpsock SDLNet_AddSocket drop
	;

:netclient
	SDLNet_Init
	512 SDLNet_AllocPacket 'udpPacket !
	4 GAME_PACKETSIZE SDLNet_AllocPacketV 'packets !
	
	'server "Connecting to %s" .println
	'serverIP 'server GAME_PORT SDLNet_ResolveHost
	'serverIP SDLNet_TCP_Open 'tcpsock !
	tcpsock .h .println
	"server:" .print
	serverIP .ip

	tryPorts	
	allocateSocketSet
	udpsock -1 SDLNet_UDP_GetPeerAddress 'myip !
	myip "myip:%h" .println
	
|	"Hola" SendTCP 
	'data >a
	33 da!+
	myip da!+
	"hola" d@ da!+
	0 da!+
	
	tcpsock 'data 512 SDLNet_TCP_Send drop
	"send" .println
	;

|	if ( serverIP.host == INADDR_NONE ) {
|		cout<<"Couldn't resolve hostname\n"; } else {
|		tcpsock = SDLNet_TCP_Open(&serverIP);
|		if ( tcpsock == NULL ) {
|			cout<<"Connect failed\n";
|			cout<<SDLNet_GetError()<<endl;
#lenpack
#idI

:HandleServer
	tcpsock 'data 512 SDLNet_TCP_Recv 
	-? ( "Connection with server lost!" .println drop ; )
	'lenpack !
	"TCP Packet incoming" .println
	
	|
	'data c@ | ADD DEL ID
	1 =? ( 'data 1 + @ 'idI ! )
	drop
	
	;
	
:HandleClient
	udpsock 'packets SDLNet_UDP_Recv drop
	"UDP Packet incoming" .println
|	'packets .println
	;

	
:send2server
	'serverIP d@ udpPacket 28 + d!
	'serverIP 4 + w@ udpPacket 32 + w!
	
	10 udpPacket 16 + d!
	msec udpPacket 8 + @ ! 
	
|	udppacket .packet
	
	udpsock -1 udpPacket SDLNet_UDP_Send drop
	".send udp" .println
	;


:HandleNet
	socketset 0 SDLNet_CheckSockets 0 <=? ( drop ; ) drop
	tcpsock 1? ( HandleServer ) drop
	udpsock 1? ( HandleClient ) drop
	;
	
:closeNET
	udpPacket SDLNet_FreePacket
	;
		
|-------------------------------------------
:randxy |  -- x y
	800.0 randmax 
	800.0 randmax 
	;
	
:ocoso	
	>a a@ dup 0.1 + a!+ 
	16 >> $3 and sprj 
	16 a+
	a@+ int. xvp -
	a@+ int. yvp - 
	2swap
	0 2.0 
	2swap
	sspritez
	;
	
:+coso | x y --
	'ocoso 'objs p!+ >a 0 a!+ 0 a!+ 0 a!+ swap a!+ a! 
	;

|-------------------------------------------
#btnpad
#face

:xymove | d --
	a@ + a! ;

:facebtnpad | 0..3 -- n
	btnpad 0? ( swap ) drop
	face +
	;

:viewport | x y -- 
	over sw 1 >> - 'xvp !
	dup sh 1 >> - 'yvp !
	;
	
:player	
	dup >a
	btnpad
	24 a+
	%10 and? ( -1.0 xymove 4 'face ! )
	%1 and? ( 1.0 xymove 8 'face ! )
	8 a+
	%1000 and? ( -1.0 xymove 12 'face ! )
	%100 and? ( 1.0 xymove 0 'face ! )
	drop	

	>a a@ dup 0.1 + a!+ 
	16 >> $3 and facebtnpad
	sprj 
	16 a+
	a@+ int. 
	a@+ int. 
	viewport
	swap xvp -
	swap yvp -
	2swap
	0 2.0 
	2swap
	sspriterz
	;
	
:+player | x y --
	'player 'objs p!+ >a 0 a!+ 0 a!+ 0 a!+ swap a!+ a! 
	;
	
:teclado
	SDLkey 
	>esc< =? ( exit )
	<up> =? ( btnpad %1000 or 'btnpad ! )
	<dn> =? ( btnpad %100 or 'btnpad ! )
	<le> =? ( btnpad %10 or 'btnpad ! )
	<ri> =? ( btnpad %1 or 'btnpad ! )
	>up< =? ( btnpad %1000 not and 'btnpad ! )
	>dn< =? ( btnpad %100 not and 'btnpad ! )
	>le< =? ( btnpad %10 not and 'btnpad ! )
	>ri< =? ( btnpad %1 not and 'btnpad ! )	
	
	<f1> =? ( randxy +coso ) 
	<f2> =? ( send2server )
	drop 
	;


:jugando
	$666666 SDLcls
	'objs p.drawo
	SDLredraw
	
	HandleNet
	teclado 
	5 'objs p.sort	
	;
	
|-------------------------------------------
:main
	"r3sdl" 800 600 SDLinit
	netclient
	17 26 "media\img\scientist.png" ssload 'sprj !

	100 'objs p.ini
	30.0 30.0 +player
	'jugando SDLshow
	closeNET
	SDLquit ;	
	
: main ;