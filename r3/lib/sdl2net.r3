| SDL2_net.dll
| PHREDA 2024

|WIN|^r3/lib/win/core.r3
|LIN|^r3/lib/posix/core.r3

#sys-SDLNet_Init
#sys-SDLNet_Quit
#sys-SDLNet_ResolveHost
#sys-SDLNet_ResolveIP 
#sys-SDLNet_GetLocalAddresses
#sys-SDLNet_TCP_OpenServer
#sys-SDLNet_TCP_OpenClient
#sys-SDLNet_TCP_Open
#sys-SDLNet_TCP_Accept
#sys-SDLNet_TCP_GetPeerAddress
#sys-SDLNet_TCP_Send
#sys-SDLNet_TCP_Recv
#sys-SDLNet_TCP_Close
#sys-SDLNet_AllocPacket
#sys-SDLNet_ResizePacket
#sys-SDLNet_FreePacket
#sys-SDLNet_AllocPacketV
#sys-SDLNet_FreePacketV
#sys-SDLNet_UDP_Open
#sys-SDLNet_UDP_SetPacketLoss
#sys-SDLNet_UDP_Bind
#sys-SDLNet_UDP_Unbind
#sys-SDLNet_UDP_GetPeerAddress
#sys-SDLNet_UDP_SendV
#sys-SDLNet_UDP_Send
#sys-SDLNet_UDP_RecvV
#sys-SDLNet_UDP_Recv
#sys-SDLNet_UDP_Close
#sys-SDLNet_AllocSocketSet
#sys-SDLNet_AddSocket
#sys-SDLNet_DelSocket
#sys-SDLNet_CheckSockets
#sys-SDLNet_FreeSocketSet
#sys-SDLNet_GetError

    |Uint32 host;            /* 32-bit IPv4 host address */
    |Uint16 port;            /* 16-bit protocol port */
|} IPaddress;

|    int channel;        /* The src/dst channel of the packet */
|    Uint8 *data;        /* The packet data */
|    int len;            /* The length of the packet data */
|    int maxlen;         /* The size of the data buffer */
|    int status;         /* packet status after sending */
|   IPaddress address;  /* The source/dest address of an incoming/outgoing packet */
|} UDPpacket;

|    int ready;
|} *SDLNet_GenericSocket;


::SDLNet_Init sys-SDLNet_Init sys0 drop ;
::SDLNet_Quit sys-SDLNet_Quit sys0 drop ; 
::SDLNet_ResolveHost sys-SDLNet_ResolveHost sys3 ;
::SDLNet_ResolveIP sys-SDLNet_ResolveIP sys1 ;
::SDLNet_GetLocalAddresses sys-SDLNet_GetLocalAddresses sys2 ;
::SDLNet_TCP_OpenServer sys-SDLNet_TCP_OpenServer sys1 ; 
::SDLNet_TCP_OpenClient sys-SDLNet_TCP_OpenClient sys1 ;
::SDLNet_TCP_Open sys-SDLNet_TCP_Open sys1 ; 
::SDLNet_TCP_Accept sys-SDLNet_TCP_Accept sys1 ;
::SDLNet_TCP_GetPeerAddress sys-SDLNet_TCP_GetPeerAddress sys1 ; 
::SDLNet_TCP_Send sys-SDLNet_TCP_Send sys3 ;
::SDLNet_TCP_Recv sys-SDLNet_TCP_Recv sys3 ;
::SDLNet_TCP_Close sys-SDLNet_TCP_Close sys1 ;
::SDLNet_AllocPacket sys-SDLNet_AllocPacket sys1 ;
::SDLNet_ResizePacket sys-SDLNet_ResizePacket sys2 ;
::SDLNet_FreePacket sys-SDLNet_FreePacket sys1 drop ; 
::SDLNet_AllocPacketV sys-SDLNet_AllocPacketV sys2 ; 
::SDLNet_FreePacketV sys-SDLNet_FreePacketV sys1 drop ; 
::SDLNet_UDP_Open sys-SDLNet_UDP_Open sys1 ; 
::SDLNet_UDP_SetPacketLoss sys-SDLNet_UDP_SetPacketLoss sys2 drop ; 
::SDLNet_UDP_Bind sys-SDLNet_UDP_Bind sys2 drop ; 
::SDLNet_UDP_Unbind sys-SDLNet_UDP_Unbind sys2 drop ; 
::SDLNet_UDP_GetPeerAddress sys-SDLNet_UDP_GetPeerAddress sys2 ; 
::SDLNet_UDP_SendV sys-SDLNet_UDP_SendV sys3 ; 
::SDLNet_UDP_Send sys-SDLNet_UDP_Send sys3 ; 
::SDLNet_UDP_RecvV sys-SDLNet_UDP_RecvV sys2 ; 
::SDLNet_UDP_Recv sys-SDLNet_UDP_Recv sys2 ; 
::SDLNet_UDP_Close sys-SDLNet_UDP_Close sys1 drop ; 
::SDLNet_AllocSocketSet sys-SDLNet_AllocSocketSet sys1 ; 
::SDLNet_AddSocket sys-SDLNet_AddSocket sys2 ; 
::SDLNet_DelSocket sys-SDLNet_DelSocket sys2 ; 
::SDLNet_CheckSockets sys-SDLNet_CheckSockets sys2 ; 
::SDLNet_FreeSocketSet sys-SDLNet_FreeSocketSet sys1 drop ; 
::SDLNet_GetError sys-SDLNet_GetError sys0 ;


|----- BOOT 
:
|WIN|	"dll/SDL2_net.DLL" loadlib
|LIN|	"libSDL2_net-2.0.so.0" loadlib	
	dup "SDLNet_Init" getproc 'sys-SDLNet_Init !
	dup "SDLNet_Quit" getproc 'sys-SDLNet_Quit !	
	dup "SDLNet_ResolveHost" getproc 'sys-SDLNet_ResolveHost !
	dup "SDLNet_ResolveIP" getproc 'sys-SDLNet_ResolveIP !
	dup "SDLNet_GetLocalAddresses" getproc 'sys-SDLNet_GetLocalAddresses !
	dup "SDLNet_TCP_OpenServer" getproc 'sys-SDLNet_TCP_OpenServer !
	dup "SDLNet_TCP_OpenClient" getproc 'sys-SDLNet_TCP_OpenClient !
	dup "SDLNet_TCP_Open" getproc 'sys-SDLNet_TCP_Open !
	dup "SDLNet_TCP_Accept" getproc 'sys-SDLNet_TCP_Accept !
	dup "SDLNet_TCP_GetPeerAddress" getproc 'sys-SDLNet_TCP_GetPeerAddress !
	dup "SDLNet_TCP_Send" getproc 'sys-SDLNet_TCP_Send !
	dup "SDLNet_TCP_Recv" getproc 'sys-SDLNet_TCP_Recv !
	dup "SDLNet_TCP_Close" getproc 'sys-SDLNet_TCP_Close !
	dup "SDLNet_AllocPacket" getproc 'sys-SDLNet_AllocPacket !
	dup "SDLNet_ResizePacket" getproc 'sys-SDLNet_ResizePacket !
	dup "SDLNet_FreePacket" getproc 'sys-SDLNet_FreePacket !
	dup "SDLNet_AllocPacketV" getproc 'sys-SDLNet_AllocPacketV !
	dup "SDLNet_FreePacketV" getproc 'sys-SDLNet_FreePacketV !
	dup "SDLNet_UDP_Open" getproc 'sys-SDLNet_UDP_Open !
	dup "SDLNet_UDP_SetPacketLoss" getproc 'sys-SDLNet_UDP_SetPacketLoss !
	dup "SDLNet_UDP_Bind" getproc 'sys-SDLNet_UDP_Bind !
	dup "SDLNet_UDP_Unbind" getproc 'sys-SDLNet_UDP_Unbind !
	dup "SDLNet_UDP_GetPeerAddress" getproc 'sys-SDLNet_UDP_GetPeerAddress !
	dup "SDLNet_UDP_SendV" getproc 'sys-SDLNet_UDP_SendV !
	dup "SDLNet_UDP_Send" getproc 'sys-SDLNet_UDP_Send !
	dup "SDLNet_UDP_RecvV" getproc 'sys-SDLNet_UDP_RecvV !
	dup "SDLNet_UDP_Recv" getproc 'sys-SDLNet_UDP_Recv !
	dup "SDLNet_UDP_Close" getproc 'sys-SDLNet_UDP_Close !
	dup "SDLNet_AllocSocketSet" getproc 'sys-SDLNet_AllocSocketSet !
	dup "SDLNet_AddSocket" getproc 'sys-SDLNet_AddSocket !
	dup "SDLNet_DelSocket" getproc 'sys-SDLNet_DelSocket !
	dup "SDLNet_CheckSockets" getproc 'sys-SDLNet_CheckSockets !
	dup "SDLNet_FreeSocketSet" getproc 'sys-SDLNet_FreeSocketSet !
	dup "SDLNet_GetError" getproc 'sys-SDLNet_GetError !
	drop
	;

