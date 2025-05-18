| winsock
| PHREDA 2025
|
|^r3/lib/console.r3

#sys-WSAStartup 
#sys-WSACleanup

#sys-accept
#sys-select
#sys-socket
#sys-bind
#sys-listen
#sys-closesocket
#sys-shutdown
#sys-send
#sys-recv
#sys-getaddrinfo
#sys-ioctlsocket

|typedef struct WSAData {
|    WORD           wVersion;
|    WORD           wHighVersion;
|    unsigned short iMaxSockets;
|	 unsigned short iMaxUdpDg;
|    char           *lpVendorInfo;
|    char           szDescription[256+1];
|    char           szSystemStatus[128+1];
|} WSADATA, *LPWSADATA;

::WSAStartup sys-WSAStartup sys2 ;
::WSACleanup sys-WSACleanup sys0 drop ;

::accept sys-accept sys3 ;
::select sys-select sys5 ;
::socket sys-socket sys3 ;
::bind sys-bind sys3 ;
::listen sys-listen sys2 ;
::closesocket sys-closesocket sys1 drop ;
::shutdown sys-shutdown sys2 ; 
::send sys-send sys4 drop ;
::recv sys-recv sys4 ;
::getaddrinfo sys-getaddrinfo sys4 ;
::ioctlsocket sys-ioctlsocket sys3 ;

|--------- BOOT	
: 
	"WS2_32.DLL" loadlib 
	dup "WSAStartup" getproc 'sys-WSAStartup !
	dup "WSACleanup" getproc 'sys-WSACleanup !
	dup "accept" getproc 'sys-accept !
	dup "select" getproc 'sys-select !
	dup "bind" getproc 'sys-bind !
	dup "socket" getproc 'sys-socket !
	dup "listen" getproc 'sys-listen !
	dup "closesocket" getproc 'sys-closesocket !
	dup "shutdown" getproc 'sys-shutdown !
	dup "send" getproc 'sys-send !
	dup "recv" getproc 'sys-recv !
	dup "getaddrinfo" getproc 'sys-getaddrinfo !
	dup "ioctlsocket" getproc 'sys-ioctlsocket !
	drop 
|	'sys-WSAStartup	( 'sys-recv <? @+ over 'sys-WSAStartup - 3 >> "%d - %h" .println ) drop .input
	;
	