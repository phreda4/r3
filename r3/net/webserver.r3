^r3/lib/console.r3
^r3/lib/win/winsock.r3

|typedef struct WSAData {
|    WORD           wVersion;
|    WORD           wHighVersion;
|    unsigned short iMaxSockets;
|	 unsigned short iMaxUdpDg;
|    char           *lpVendorInfo;
|    char           szDescription[256+1];
|    char           szSystemStatus[128+1];
|} WSADATA, *LPWSADATA;
#WSAData * 512

:webserver
	$2002 'WSAData WSAStartup
	1? ( "error %d" .println ; ) drop
	"ok" .println
	
	WSACleanup
	.input
	;
	
: webserver ;
