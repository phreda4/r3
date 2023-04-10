^r3/win/console.r3
^r3/win/sdl2net.r3
^r3/util/arr16.r3

#GAME_MAXPEOPLE	10
#GAME_PORT	7777

|	int active;
|	TCPsocket sock;
|	IPaddress peer;
|	Uint8 name[256+1];
| 8 16 24 32
| active | socket | peer | name
#p.a * 256
#p.s * 256
#p.p * 256
#p.n * 256
#p.last

#serverIP
#socketset
#servsock
#udpSocket
#udpPacket

:initNET
	SDLNet_Init

	GAME_PORT SDLNet_UDP_Open 'udpSocket !
	512 SDLNet_AllocPacket 'udpPacket !
	
	0 'p.last !
	'p.a 0 GAME_MAXPEOPLE fill
	'p.s 0 GAME_MAXPEOPLE fill

	GAME_MAXPEOPLE 1 + SDLNet_AllocSocketSet 
	0? ( "Error alloc" .println )
	'socketset ! 
	
	'serverIP 0 GAME_PORT SDLNet_ResolveHost
	serverIP "Server IP: %h" .println
	
	'serverIP SDLNet_TCP_Open 
	0? ( "Error tcp open" .println )
	'servsock !
	
	socketset servsock SDLNet_AddSocket drop
	;

#newsock
#which

:HandleServer | --
	servsock SDLNet_TCP_Accept 
	0? ( drop ; )
	'newsock !
	| newsock roomfull
	"new client" .println
|	if ( which == GAME_MAXPEOPLE ) { findInactivePersonSlot(which); }
|	if ( which == GAME_MAXPEOPLE ) { roomFull(newsock); } else { addInactiveSocket(which, newsock); }

	newsock p.last 3 << 'p.s + !
	newsock SDLNet_TCP_GetPeerAddress p.last 3 << 'p.p + !
|     people[which].sock = newsock;
|     people[which].peer = *SDLNet_TCP_GetPeerAddress(newsock);
	socketset newsock SDLNet_AddSocket drop
	1 'p.last +!
	
	0 ( p.last <?
		dup 3 << 'p.p + @ "%h" .println
		1 + ) drop
	;

#data * 512

:newclient
	;
	
:HandleClient | n sock -- n
	'data 512 SDLNet_TCP_Recv
	-? ( drop 
|		notifyAllConnectionClosed(data, which);
|		deleteConnection(which);
		"error" .println
		; ) drop
	"Activating socket" .println
	'data 8 + .println
	'data d@
	33 =? ( newclient )
	drop
	
|	switch (data[0]) {
|		case GAME_HELLO: {
|				memcpy(&people[which].peer.port, &data[GAME_HELLO_PORT], 2);
|				memcpy(people[which].name, 	&data[GAME_HELLO_NAME], 256);
|				people[which].name[256] = 0;
               
|				/* Notify all active clients */
|				for (int i=0; i<GAME_MAXPEOPLE; ++i ) {
|					if ( people[i].active ) {
|						SendNew(which, i);

|				/* Notify about all active clients */
|				people[which].active = 1;
|				for (int i=0; i<GAME_MAXPEOPLE; ++i ) {
|					if ( people[i].active ) {
|						SendNew(i, which);
				
|				/*Tell player which one in the slot they are */
|				SendID(which);
	;
	
:loop
|"ch" .println
	socketset 0 SDLNet_CheckSockets 0 <=? ( drop ; ) drop

	servsock 1? ( HandleServer ) drop
	0 ( GAME_MAXPEOPLE <?
		dup 3 << 'p.s + @ 1? ( dup HandleClient ) drop
		1 + ) drop
	;
	
: |<<<<<<<< BOOT
.cls
"RPG Server" .println
initNET
( inkey $1B1001 <>? drop
	loop
	) drop
SDLNet_Quit
;

