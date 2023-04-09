| Multiplayer RPG

^r3/win/sdl2gl.r3
^r3/win/sdl2gfx.r3
^r3/win/sdl2net.r3
^r3/util/arr16.r3


#GAME_PACKETSIZE 256	
#GAME_PORT 7777

#sprj
#spre

|-------------------------------------------	
#packets 
#serverIP
#myIP

#server "localhost" |"220.233.28.6";
#tcpsock
#udpsock
#socketset

#data 512

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
	socketset tcpsock SDLNet_AddSocket
	socketset udpsock SDLNet_AddSocket
	;

:SendTCP | "" --
	tcpsock swap count SDLNet_TCP_Send
	;
	
:netclient
	SDLNet_Init
	4 GAME_PACKETSIZE SDLNet_AllocPacketV 'packets !
	
	'server "Connecting to %s" .println
	'serverIP 'server GAME_PORT SDLNet_ResolveHost
	'serverIP SDLNet_TCP_Open 'tcpsock !
	tcpsock .h .println

	tryPorts	
	allocateSocketSet
	udpsock -1 SDLNet_UDP_GetPeerAddress 'myip !
	myip "myip%h" .println
	
	"Hola" SendTCP 
	;

|	if ( serverIP.host == INADDR_NONE ) {
|		cout<<"Couldn't resolve hostname\n"; } else {
|		tcpsock = SDLNet_TCP_Open(&serverIP);
|		if ( tcpsock == NULL ) {
|			cout<<"Connect failed\n";
|			cout<<SDLNet_GetError()<<endl;
#lenpack

:HandleServer
	tcpsock 'data 512 SDLNet_TCP_Recv 
	-? ( "Connection with server lost!" .println drop ; )
	'lenpack !
	"TCP Packet incoming" .println
	
	|
|	'data c@ | ADD DEL ID
	
	;
	
:HandleClient
	udpsock 'packets SDLNet_UDP_Recv drop
	"UDP Packet incoming" .println
	'packets .println
	;

:HandleNet	
	socketset 0 SDLNet_CheckSockets
	tcpsock 1? ( HandleServer ) drop
	udpsock 1? ( HandleClient ) drop
	;
	
|-------------------------------------------
#fx 0 0

#xvp #yvp	| viewport

#xp 30.0 #yp 30.0	| pos player
#vxp 0 #vyp 0		| vel player

#np 0

:viewport
	xp int. sw 1 >> - 'xvp !
	yp int. sh 1 >> - 'yvp !
	;
	

|--------------------------------
#btnpad

:panim | -- nanim	
	msec 5 >> $3 and ;

:dirv	
	-? ( 1 2 << ; ) 2 2 << ;
:xmove
	
	dirv panim + 'np !
	'xp +!
	;
	
:dirh
	-? ( 3 2 << ; ) 0 ;
:ymove
	dirh panim + 'np !
	'yp +!
	;
	
:player	
	xp int. xvp -
	yp int. yvp -
	0 2.0 
	np sprj 
	sspritez

	btnpad
	%1000 and? ( -1.0 ymove  )
	%100 and? ( 1.0 ymove  )
	%10 and? ( -1.0 xmove )
	%1 and? ( 1.0 xmove )
	drop
	
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
	drop 
	;


:jugando
	$666666 SDLcls
	|viewport
	player
	
	SDLredraw
	HandleNet
	teclado 
	;
	
|-------------------------------------------
:main
	"r3sdl" 800 600 SDLinit
	netclient

	17 26 "media\img\scientist.png" loadssheet 'sprj !
	
	viewport
	'jugando SDLshow
	SDLquit ;	
	
: main ;