^r3/win/console.r3
^r3/win/sdl2.r3
^r3/win/sdl2net.r3

|---------------------
:.ip | nro
	dup 24 >> $ff and swap
	dup 16 >> $ff and swap
	dup 8  >> $ff and swap
	$ff and "%d.%d.%d.%d " .print
	;

:.packet | adr --
	@+ "Chan:    %d" .println
	@+ "Data:    %s" .println
	d@+ "Len:     %d" .println
	d@+ "MaxLen:  %d" .println
	d@+ "status:  %d" .println
	@ .ip
	;
	
|--------------------------
#MAX_CLIENTS	16
#PORT			20715	
#CLIENT_SIGNAL	0		| A single integer the server can send the client
#CLIENT_GAME	1		| The state of the game. TODO: Should recieve as UDP
#SIGNAL_CONNECT	0		| If the user connects, the value will be their index in the client list.
#SIGNAL_FULL	1		| The the server if full, they get this.

#serverIP	| Holds the IPv4 address and port number for this server.
#sockets	| There are 1 + MAX_CLIENTS sockets to listen for.
| TODO: Eventually we will have both a TCP
| socket and UDP socket. TCP is for everything that
| isn't sending/recieving constant game updates
#tcp_server_socket

| Sends a message to a given socket.
| Local update of client's current data.
#define SERVER_LOCAL_UPDATE		0

|----------------------------
:send_message_to_client |(TCPsocket socket, client_message* message) {
  SDLNet_TCP_Send(socket, message, sizeof(client_message));
  return 1;
	;

:recv_message_from_server |(TCPsocket socket, client_message* result) {
  return SDLNet_TCP_Recv(socket, result, sizeof(client_message));
	;

#buf * 1024 |[16];

:send_message_to_server |(TCPsocket server_socket, server_message* message) {
|	SDLNet_Write32(message->data.local.x, buf);
|	SDLNet_Write32(message->data.local.y, buf + 4);
|	SDLNet_Write32(message->data.local.rot, buf + 8);
|	SDLNet_Write32(message->data.local.level_id, buf + 12);
	"xyrl" 'buf strcpy
	server_socket 'buf 16 SDLNet_TCP_Send
	;

#recvd

:recv_message_from_client | -- recvd ;(TCPsocket client_socket, server_message* result) {
	client_socket 'buf 16 SDLNet_TCP_Recv 'recvd !
	recvd 1 <? ( ; )
|  result->data.local.x = SDLNet_Read32(buf);
|  result->data.local.y = SDLNet_Read32(buf + 4);
|  result->data.local.rot = SDLNet_Read32(buf + 8);
|  result->data.local.level_id = SDLNet_Read32(buf + 12);

	;	
|----------------------------

#clients * 1024 |client_connect clients[MAX_CLIENTS];
#num_clients 0;


| Scans the clients array and sets all to inactive
:set_all_clients_inactive
	'clients 0 128 fill
|  for(i = 0; i < MAX_CLIENTS; i++) {
|    clients[i].data.active = 0;
|    clients[i].tcp_socket = NULL;
 	;

#num_ready
#curr_time
#last_time

#temp_socket
#add_result

:clientconn	
	"server: client connection" .println
    -1 'num_ready +!
	tcp_server_socket SDLNet_TCP_Accept 'temp_socket !
	temp_socket add_client_to_server 'add_result !
	add_result -2 =? ( drop ; ) drop | SDLNet fail
	
	client_message connect_message;
	connect_message.type = CLIENT_SIGNAL;
	add_result -2 =? ( drop ; ) drop | SDLNet fail	  
      if(add_result != -1) {
        connect_message.data.signal.type = SIGNAL_CONNECT;
        connect_message.data.signal.value = add_result;
      } else {
        connect_message.data.signal.type = SIGNAL_FULL;
        | Not neccesssary, but it's nice not to have junk values.
        connect_message.data.signal.value = -1;
      }
	temp_socket 'buf 16 SDLNet_TCP_Send
	
:send_message_to_client |(TCPsocket socket, client_message* message) {
  SDLNet_TCP_Send(socket, message, sizeof(client_message));
  return 1;
  
      send_message_to_client(temp_socket, &connect_message);
	  
	;
	
| The main server processing loop.
:server
	| Whenever any activity is detected, we will pick
	| it up with this variable.
	sockets 10 SDLNet_CheckSockets 'num_ready !
	num_ready 
	-1 =? ( drop SDLNet_GetError "server: SDLNet_CheckSockets: %s" .print ; ) 
	0 =? ( drop server ; ) 
	drop

    | At this point, we have activity on a socket. We need to figure out
    | what that is.
    num_ready "server: I detected activity on %d sockets" .println

	tcp_server_socket SDLNet_SocketReady 
	1? ( clientconn )
	drop


    for(int i = 0; num_ready > 0 && i < MAX_CLIENTS; i++) {
      if(clients[i].data.active && SDLNet_SocketReady(clients[i].tcp_socket)) {
        num_ready--;

        server_message message;
        int result = recv_message_from_client(clients[i].tcp_socket, &message);

        if(result < 1) {
          i "server: client %d disconnected. bye bye" .println
          clients[i].data.active = 0;
          SDLNet_TCP_DelSocket(sockets, clients[i].tcp_socket);
          SDLNet_TCP_Close(clients[i].tcp_socket);
        } else {
         | printf("client %d: x %d y %d rot %d level %d\n",
         |         i, message.data.local.x, message.data.local.y, message.data.local.rot, message.data.local.level_id);
          clients[i].data.level_id = message.data.local.level_id;
          clients[i].data.x = message.data.local.x;
          clients[i].data.y = message.data.local.y;
          clients[i].data.rot = message.data.local.rot;

          | Send message back to client.
          client_message game;
          game.type = CLIENT_GAME;
          int j;
          for(j = 0; j < MAX_CLIENTS; j++)
            game.data.game[j] = clients[j].data;
          send_message_to_client(clients[i].tcp_socket, &game);
        }
      }
    }
  }
}

| When a user connects, we will attempt to add them
:add_client_to_server |(TCPsocket to_add) {
	0? ( drop
		SDLNet_GetError "server: SDLNet_TCP_Accept: %s" .println
		-2 ; )

	| Now we need to find a spot for the new client if possible.
	num_clients MAX_CLIENTS =? ( drop 
		| TODO: send message to the client
		"server: I'm full. Bye bye." .println
		To_add SDLNet_TCP_Close
		-1 ; )

	| Otherwise, we find a spot to put the new client in.
  int i = 0;
  for(i = 0; i < MAX_CLIENTS; i++) {
    if(clients[i].data.active == 0) {
      clients[i].data.active = 1;
      clients[i].tcp_socket = to_add;
      num_clients++;
      break;
    }
  }

  SDLNet_TCP_AddSocket(sockets, to_add);

	return i
	;

:endserver
	tcp_server_socket SDLNet_TCP_Close
	"server: shutting down" .println
	;
	
:main
	"server: SDL initialized" .println
	'serverIP 0 PORT SDLNet_ResolveHost
	serverIP .ip
	
	'serverIP SDLNet_TCP_Open 
	0? ( drop "Error tcp open" .println 
		; )
	'tcp_server_socket !

	MAX_CLIENTS 1+ SDLNet_AllocSocketSet 
	0? ( drop "Error allocSocketSet" .println 
		endserver ; )
	'sockets ! 
	
	sockets tcp_server_socket SDLNet_AddSocket drop
	"server: starting" .println
	PORT "server: listening on port %d" .println

	set_all_clients_inactive
	0 'last_time !
	0 'curr_time !
	server
	endserver
	;

	
: 
	0 SDL_Init
	SDLNet_Init
	main 
	SDLNet_Quit
	SDL_Quit
	"server: bye bye" .println
	.input
;
