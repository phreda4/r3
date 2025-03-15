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


|typedef struct WSAData {
|    WORD           wVersion;
|    WORD           wHighVersion;
|    unsigned short iMaxSockets;
|	 unsigned short iMaxUdpDg;
|    char           *lpVendorInfo;
|    char           szDescription[256+1];
|    char           szSystemStatus[128+1];
#WSAData * 512

:dump1
	'wsadata
	w@+ "%h " .print w@+ "%h" .print w@+ "%d " .print w@+ "%d " .print @+ "%h" .println
	dup "%s" .println 257 +
	dup "%s" .println 129 +
	drop ;
	
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
	w@+ "%h" .println w@+ "%h" .println d@+ "%h" .println @ "%h" .println ;
	
#client_socket
#client_addr 0 0
#client_size 16

|---------------------

#rlen

#bytes_received
#buffer * 1024

#ctypetext "Content-Type: text/plain"
#ctypehtml "Content-Type: text/html"

#hmethod
#huri
#hversion
#hhost
#hreferer
#hcookie
#hbody

|--------------------- response
:http_bad_request
	hversion ,s " 400 Bad Request" ,s ,nl
	'ctypehtml ,s ,nl ,nl
	"<html><title>Bad Request</title><body><p>Your browser sent a bad request</p></body></html>" ,s ,nl
	;

:http_not_implemented
	hversion ,s " 501 Not Implemented" ,s ,nl
	'ctypehtml ,s ,nl ,nl
	"<html><title>Not Implemented</title><body><p>The server either does not recognise the request method, or it lacks the ability to fulfill the request.</p></body></html>" ,s ,nl
	;

:http_forbidden
	hversion ,s " 403 Forbidden" ,s ,nl
	'ctypehtml ,s ,nl ,nl
	"<html><title>Forbidden</title><body><p>You don't have acces to this content</p></body></html>" ,s ,nl
	;

:http_not_found
	hversion ,s " 404 File Not Found" ,s ,nl
	'ctypehtml ,s ,nl ,nl
	"<html><title>File Not Found</title><body><p>The server could not find the resourse</p></body></html>" ,s ,nl
	;

:http_internal_server_error
	hversion ,s " 500 Internal Server Error" ,s ,nl
	'ctypehtml ,s ,nl ,nl
	"<html><title>Bad Request</title><body><p>Your browser sent a bad request</p></body></html>" ,s ,nl
	;

:http_ok
	hversion ,s " 200 OK" ,s ,nl
	'ctypehtml ,s ,nl 
	"Content-Length: " ,s rlen ,d ,nl
	,nl
	;

|    "HTTP/1.1 200 OK" ,print ,nl
|	"Content-Type: text/plain" ,print ,nl
	|"Set-Cookie: session_id=%s; Path=/\r\n" ,print
|	"Content-Length: 13" ,print ,nl ,nl
|	"Hello, World!" ,print 

|--------------------- request

:>>field | adr -- adr'
	>>sp dup 1+ 0 rot c! ;
	
:getvar | adr pre -- 'adr var
	drop >>sp 1+ dup | var var
	>>cr dup 2 + 
	0 rot c! | | var 'adr
	swap ;
		
:parseline
	dup c@ 13 <=? ( drop ; ) drop
	"Host:" =pre 1? ( getvar 'hhost ! parseline ; ) drop
	"Referer:" =pre 1? ( getvar 'hreferer ! parseline ; ) drop
	"Cookie:" =pre 1? ( getvar 'hcookie ! parseline ; ) drop
	>>cr 2 + |dup "%l" .println
	parseline ;
	
:parseheader
	'buffer | request line
	dup 'hmethod ! >>field 
	dup 'huri ! >>field
	dup 'hversion ! >>field
	>>cr trim | request headers
	
	"" dup 'hhost ! dup 'hreferer ! dup 'hcookie ! 'hbody !
	
	parseline
	'hbody !
	;

:dumpreq
	"Received request:" .println
	"-------------------" .println
	hmethod .print " | " .print
	huri .print " | " .print
	hversion .println
	hhost .print " | " .print
	hreferer .print " | " .print
	hcookie .println
	"-------------------" .println	
	hbody .println
	"-------------------" .println
	;
		
:handlerequest
	client_socket 'buffer 1024 0 recv 'bytes_received !
    0 'buffer bytes_received + c!
	
	parseheader
	
	|dumpreq
	|---------------------------
	mark
	"<body bgcolor=#666666>" ,s
	"<h1>R3 como server</h1>" ,s
	"<br>" ,s
	"coso" ,s
	0 ,c 
	
	sizemem 'rlen !
	mark
	http_ok 0 ,c client_socket memsize 0 send
	empty
	
	client_socket memsize 0 send
	empty
	|---------------------------
    client_socket closesocket
	;
	
:loophandle
	server_socket 'client_addr 'client_size accept
	-? ( drop loophandle ; ) 
	dup "ok %d" .println
	'client_socket !
	handlerequest
	loophandle
	;
	
:webserver
	$0202 'WSAData WSAStartup
	1? ( "error %d" .println ; ) drop
|	dump1 |	"ok" .println
	
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
|	.input
	;
	
: webserver ;
