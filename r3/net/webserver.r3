^r3/lib/console.r3
^r3/lib/win/winsock.r3


#MAX_BUFFER      1024

#type
     "htm"  "text/html" 
     "html" "text/html" 
     "scss" "text/x-scss" 
     "css"  "text/css"    
     "jpg"  "image/jpeg" 
     "jpeg" "image/jpeg" 
     "bmp"  "image/bmp"  
     "gif"  "image/gif"  
     "png"  "image/png"  
     "js"  "application/x-javascript" 
     "woff2" "font/woff2" 
     "woff"  "font/woff"  
     "ttf"   "font/ttf"   

#HDR_URI_SZ      1024
#HDR_METHOD_SZ   5
#HDR_VERSION_SZ  10

|    char version[HDR_VERSION_SZ];
|    char method[HDR_METHOD_SZ];
|    char uri[HDR_URI_SZ];

|    char *saveptr = NULL, *data = strtok_r(buffer, " \r\n", &saveptr);
 |   strcpy(hdr->method, data);
  |  data = strtok_r(NULL, " \r\n", &saveptr);
|    strcpy(hdr->uri, data);
 |   data = strtok_r(NULL, " \r\n", &saveptr);
  |  strcpy(hdr->version, data);

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

:dump1
	'wsadata
	w@+ "%h " .print
	w@+ "%h" .println
	w@+ "%d " .print
	w@+ "%d " .print
	@+ "%h" .println
	dup "%s" .println
	257 +
	dup "%s" .println
	129 +
	drop
	;
#AF_INET 2
#SOCK_STREAM 1
#IPPROTO_TCP 6

#PORT 8080
#BUFFER_SIZE 1024
#SESSION_ID_LENGTH 33

|struct sockaddr_in {
|    short sin_family;         // Offset: 0, Size: 2 bytes
|    unsigned short sin_port;  // Offset: 2, Size: 2 bytes
|    struct in_addr sin_addr;  // Offset: 4, Size: 4 bytes
|    char sin_zero[8];         // Offset: 8, Size: 8 bytes
|};
#server_socket
#server_addr 0 0

:dumpadr
	w@+ "%h" .println
	w@+ "%h" .println
	d@+ "%h" .println
	@ "%h" .println
	;
	
#client_socket
#client_addr 0 0
#client_size 16

#bytes_received
#buffer * 1024

:handle
	client_socket 'buffer 1024 0 recv 'bytes_received !
	
    0 'buffer bytes_received + c!
	
	"Received request:" .println
	'buffer .println
  
	mark
    "HTTP/1.1 200 OK" ,print ,nl
	"Content-Type: text/plain" ,print ,nl
	|"Set-Cookie: session_id=%s; Path=/\r\n" ,print
	"Content-Length: 13" ,print ,nl
	,nl
	"Hello, World!" ,print 
	0 ,c
	
	client_socket memsize 0 send
	empty
	
    client_socket closesocket
	;
	
:loophandle
|	16 'client_size !
	server_socket 'client_addr 'client_size accept
	-? ( drop loophandle ; ) 
	dup "ok %d" .println 
	'client_socket !
	handle
	loophandle
	;
	
:webserver
	$0202 'WSAData WSAStartup
	1? ( "error %d" .println ; ) drop
	dump1
	"ok" .println
	
	AF_INET SOCK_STREAM IPPROTO_TCP socket 
	-? ( "error %d" .println WSACleanup ; )
	'server_socket !

    AF_INET 'server_addr w!
	PORT dup 8 << swap 8 >> or	'server_addr 2 + w!
	$0 'server_addr 4 + d! |INADDR_ANY

| 'server_addr dumpadr

	server_socket 'server_addr 16 bind 
	-? ( "error %d" .println server_socket closesocket WSACleanup ; ) drop
	
	server_socket 1 listen
	-? ( "error %d" .println server_socket closesocket WSACleanup ; ) drop
	
	PORT "Servidor HTTP iniciado en el puerto %d" .println
	loophandle
	"fin Servidor" .println
	WSACleanup
	.input
	;
	
: webserver ;
