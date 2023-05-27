^r3/win/console.r3
^r3/win/sdl2net.r3
^r3/util/arr16.r3

#GAME_MAXPEOPLE	10
#GAME_PORT	7777

|	TCPsocket sock;
|	IPaddress peer;
|	Uint8 name;
| socket | peer | name
#p.s * 256
#p.p * 256
#p.n * 256
#p.last

#framegame * 512

:]sock	3 << 'p.s + @ ;
:sock!	3 << 'p.s + ! ;

#serverIP
#socketset
#servsock

#udpSocket
#udpPacket

|---------------------
:.ip | nro
	dup 24 >> $ff and swap
	dup 16 >> $ff and swap
	dup 8  >> $ff and swap
	$ff and "%d.%d.%d.%d" .println
	;

:.packet | adr --
	@+ "Chan:    %d" .println
	@+ "Data:    %s" .println
	d@+ "Len:     %d" .println
	d@+ "MaxLen:  %d" .println
	d@+ "status:  %d" .println
	@ .ip
	;

|---------------------
:initNET
	SDLNet_Init

	GAME_PORT SDLNet_UDP_Open 'udpSocket !
	
	512 SDLNet_AllocPacket 'udpPacket !
	
	0 'p.last !
	'p.s 0 GAME_MAXPEOPLE fill

	GAME_MAXPEOPLE 1 + SDLNet_AllocSocketSet 
	0? ( "Error alloc" .println )
	'socketset ! 
	
	'serverIP 0 GAME_PORT SDLNet_ResolveHost
	serverIP .ip
|	"Server IP: %h" .println
	
	'serverIP SDLNet_TCP_Open 
	0? ( "Error tcp open" .println )
	'servsock !
	
	socketset servsock SDLNet_AddSocket drop
	;

#newsock
#which

:SendNew |(int about, int to)

|	data[0] = GAME_ADD;
|	data[GAME_ADD_SLOT] = about;
|	memcpy(&data[GAME_ADD_HOST], &people[about].peer.host, 4);
|	memcpy(&data[GAME_ADD_PORT], &people[about].peer.port, 2);
|	data[GAME_ADD_NLEN] = n;
|	memcpy(&data[GAME_ADD_NAME], people[about].name, n); //if more info, add it here on next line ie appearance/colour
	SDLNet_TCP_Send |(people[to].sock, data, GAME_ADD_NAME+n);
	;

:SendID | which --
|    data[0] = GAME_ID;
|    data[1] = which;
    SDLNet_TCP_Send |(people[which].sock,data,GAME_ID_LEN+1);
;


#data * 512

:HandleServer | --
	servsock SDLNet_TCP_Accept 
	0? ( drop ; )
	'newsock !
	| newsock roomfull
	"new client" .println
|	if ( which == GAME_MAXPEOPLE ) { findInactivePersonSlot(which); }
|	if ( which == GAME_MAXPEOPLE ) { roomFull(newsock); } else { addInactiveSocket(which, newsock); }

	newsock p.last 3 << 'p.s + ! | socket
	newsock SDLNet_TCP_GetPeerAddress p.last 3 << 'p.p + ! | peer adress
|     people[which].sock = newsock;
|     people[which].peer = *SDLNet_TCP_GetPeerAddress(newsock);
	socketset newsock SDLNet_AddSocket drop
	
|	1 'data c!
|	p.last 'data 1 + !
	
|	newsock 'data 10 SDLNet_TCP_Send

	|SendNew
	|p.last SendID
	
	1 'p.last +!
	
	0 ( p.last <?
		dup 3 << 'p.p + @ "%h" .println
		1 + ) drop
	;


:newclient
	;
	
:deleteConnection | n -- n
	socketset over ]sock SDLNet_DelSocket drop
	dup ]sock SDLNet_TCP_Close
	0 over sock!
	;
	
:HandleClient | n sock -- n
	'data 512 SDLNet_TCP_Recv
	|dup "%d" .println
	0 <=? ( drop 
|		notifyAllConnectionClosed(data, which);
		deleteConnection
|		"error" .println
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
	
#sttcpsoc	
:handleTCP
	socketset 0 SDLNet_CheckSockets 
	dup 'sttcpsoc !
	0? ( drop ; ) | no in
	-? ( drop ; ) 
	drop

	servsock 1? ( HandleServer ) drop
	0 ( GAME_MAXPEOPLE <?
		dup ]sock 1? ( dup HandleClient ) drop
		1 + ) drop
	;
	
	
	
:send2Client

|	'serverIP d@ packet 28 + d!
|	'serverIP 4 + w@ packet 32 + w!
	
	10 udppacket 16 + d!
	"hola co" @ udppacket 8 + @ ! 
	
|	packet .packet
	
	udpSocket -1 udppacket SDLNet_UDP_Send drop
	"send udp" .println
	;	
	
:handleUDP
	udpSocket udpPacket SDLNet_UDP_Recv 0? ( drop ; ) drop
	"rev UDP" .println
	
|	udpPacket .packet
	udpPacket 8 + @ @ "%h" .println

|			sendOutUDPs((char *)udpPacket->data, udpPacket->channel);
	;

:closeNET
	servsock 1? ( dup SDLNet_TCP_Close ) drop
	socketset 1? ( dup SDLNet_FreeSocketSet ) drop
	udpPacket SDLNet_FreePacket
	SDLNet_Quit
	;
	
:screen 
	.cls
	servsock "ss:%h " .print
	sttcpsoc "status:%h" .println
	0 ( GAME_MAXPEOPLE <?
		dup ]sock 
		over "%d %h " .print
		dup 3 << 'p.p + @ .ip
		1 + ) drop	
	10 ms
	;
	
: |<<<<<<<< BOOT
.cls
"RPG Server" .println
initNET
( inkey $1B1001 <>? drop
|	screen
	handleTCP
	handleUDP
	) drop
closeNET
;

