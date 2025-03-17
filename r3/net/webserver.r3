^r3/lib/console.r3
^r3/lib/win/winsock.r3

#basefolder

#MAX_BUFFER      1024

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
	hversion ,s " 400 Bad Request" ,s ,nl ,nl ;

:http_not_implemented
	hversion ,s " 501 Not Implemented" ,s ,nl ,nl ;

:http_forbidden
	hversion ,s " 403 Forbidden" ,s ,nl ,nl ;

:http_internal_server_error
	hversion ,s " 500 Internal Server Error" ,s ,nl ,nl ;

:http_relocate
	hversion ,s " 302 Found" ,s ,nl
	"Location: " ,s "../index.html" ,s ,nl ,nl ;
	
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
	
:$get[ | name -- value
	huri 
	;
	
:$post[ | name -- value
	hbody
	;	
	
|--------------------------
#filename * 1024
#filemime * 32
#basedir "www"
	
:mimeURL | strl -- strl
	"text/html" 'filemime strcpy 
	".css"	=lpos 1? ( "text/css" 'filemime strcpy ; ) drop
	".scss" =lpos 1? ( "text/x-scss" 'filemime strcpy ; ) drop
	".css"	=lpos 1? ( "text/css" 'filemime strcpy ; ) drop
	".php"	=lpos 1? ( "text/plain" 'filemime strcpy ; ) drop
	".txt"	=lpos 1? ( "text/plain" 'filemime strcpy ; ) drop
	".jpg"	=lpos 1? ( "image/jpeg" 'filemime strcpy ; ) drop
	".jpeg" =lpos 1? ( "image/jpeg" 'filemime strcpy ; ) drop
	".bmp"	=lpos 1? ( "image/bmp" 'filemime strcpy ; ) drop
	".gif"	=lpos 1? ( "image/gif" 'filemime strcpy ; ) drop
	".png"	=lpos 1? ( "image/png" 'filemime strcpy ; ) drop
	".js"	=lpos 1? ( "application/js" 'filemime strcpy ; ) drop
	".woff2" =lpos 1? ( "font/woff2" 'filemime strcpy ; ) drop
	".woff"	=lpos 1? ( "font/woff" 'filemime strcpy ; ) drop
	".ttf"	=lpos 1? ( "font/ttf" 'filemime strcpy ; ) drop
	;
	
:remove? | ladr -- ladr
	dup ( 'filename =? ( drop ; )
		dup c@ $3f <>? drop 1- ) drop |?
	nip	
	0 over c! ;
	
:fileURL
	'basedir 'filename strcpyl 1-	| base
	huri swap strcpyl 1-			| filename
	remove?
	dup 1- c@ $2f =? ( "index.html" rot strcpyl swap ) drop
	mimeURL
	'filemime 'filename "file: %s mime: %s" .println
	;
	
:http_not_found
	mark
	hversion ,s " 404 File Not Found" ,s ,nl ,nl 
	client_socket memsize 0 send
	empty
	;
	
:sendresponse	
	fileURL
	'filename filexist 0? ( drop http_not_found ; ) drop
	
	mark
	here 'filename load 'here !
	
	| tamplate and exec
	
	sizemem | len body
	mark
	hversion ,s " 200 OK" ,s ,nl
	"Content-Type: " ,s 'filemime ,s ,nl 
	"Content-Length: " ,s ,d ,nl ,nl | len body
	client_socket memsize 0 send
	empty
	
	client_socket memsize 0 send
	empty
	;
	
|--------------------------	
:dumpreq
	"-------------------" .println
	hmethod .print "|" .print huri .print "|" .print hversion .print "|" .print
	hhost .print "|" .print hreferer .print "|" .print hcookie .println
	"-------------------" .println	
	hbody .println "-------------------" .println
	;
		
:handlerequest
	client_socket 'buffer 1024 0 recv | 'bytesrec !
	0 'buffer rot + c!
	
	parseheader
	dumpreq
	sendresponse
	
    client_socket closesocket
	;
	
|---------------	
:webserver
	server_socket 'client_addr 'client_size accept
	-? ( drop webserver ; ) 
	|dup "ok %d" .println
	'client_socket !
	handlerequest
	webserver ;
	
:serverini
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
	;
	
:serverend	
	"fin Servidor" .println
	WSACleanup ;
	
: |<<<<< BOOT <<<<<<<
	serverini
	webserver
	serverend
	;
