^r3/lib/console.r3
^r3/lib/win/winsock.r3

#WSAData * 512

#AF_INET 2
#SOCK_STREAM 1
#IPPROTO_TCP 6

#PORT 80

#server_socket
#server_addr 0 0

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
	>>cr
	'hbody !
	;
	
|-------------------------- parse vars
| = $3d
| & $26
|
:char>6 | char -- 6bitchar
	$1f - dup $40 and 1 >> or $3f and ;

:6>char | 6bc -- char
	$3f and $1f + ;
	
:parsen | -- vv | a->string
	0 ( ca@+ 1?
		$3d =? ( drop ; )
		char>6 swap 6 << or
		) nip ;

:dighex | c -- dig 
	$3A <? ( $30 - ; ) tolow $57 - ;

:parsev	| -- vv
	a> >b
	( ca@+ 1?
		$26 =? ( drop 0 cb!+ ; ) | =
		$25 =? ( drop ca@+ dighex 4 << ca@+ dighex or ) | %ff
		cb!+
		) cb!+ ;
	
|.. put in list name,value, last name=0	
|.. here body arrayvar 'here ! 
::arrayvar | 'list str -- 'list+
	>a 
	( parsen 1?
		swap !+ a> swap !+
		parsev )
	swap !+ ;

|.. here "val1" searchvar .println
::searchvar | 'list str -- str/0
	>a parsen swap
	( @+ 1?
		over =? ( drop @ ; ) 
		drop 8 + 
		) nip ;
	
#varget
#varpost

:getvars | -- 
	here 
	dup 'varget ! huri arrayvar
	dup 'varpost ! hbody arrayvar
	'here !
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
	".app"	=lpos 1? ( 0 'filemime ! ; ) drop | interna
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
	|'filemime 'filename "file: %s mime: %s" .println
	;
	
:http_not_found
	mark
	hversion ,s " 404 File Not Found" ,s ,nl ,nl 
	client_socket memsize 0 send
	empty
	;
	
|----------------------------------------	
:loadfile
	here swap load 'here ! ;
	
:app
	mark

|	"www/head.app" loadfile
	"www/navbar.app" loadfile
|	"resultado{2{4^" ,s
|	here 'filename load 'here !
	
	| tamplate and exec
	
	sizemem | len body
	mark
	hversion ,s " 200 OK" ,s ,nl
	"Content-Type: text/html" ,s ,nl | siempre html
	"Content-Length: " ,s ,d ,nl ,nl | len body
	client_socket memsize 0 send
	empty
	
	client_socket memsize 0 send
	empty
	;
	
	
:sendresponse	
	fileURL
	filemime 0? ( drop app ; ) drop
	'filename filexist 0? ( drop http_not_found ; ) drop
	
	mark
	here 'filename load 'here !
	
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
	client_addr "-------from: %h" .println
	
	huri .print "|" .print hmethod .print "|" .print
	|hversion .print "|" .print
	|hhost .print "|" .print 
	hreferer .print "|" .print 
	hcookie .print "|" .print 
	hbody .print
	"-------------------" .println
	;

|----------------------------------------			
:handlerequest
	mark
	client_socket 'buffer 1024 0 recv | 'bytesrec !
	0 'buffer rot + c!
	
	parseheader
	dumpreq
	getvars
	sendresponse
	
    client_socket closesocket
	empty
	;
	
|---------------	
:webserver
	server_socket 'client_addr 'client_size accept
	-? ( drop webserver ; ) 
	'client_socket !
	handlerequest
	webserver ;
	
:serverini
	$0202 'WSAData WSAStartup
	1? ( "error %d" .println ; ) drop

	AF_INET SOCK_STREAM IPPROTO_TCP socket 
	-? ( "error %d" .println WSACleanup ; )
	'server_socket !

    AF_INET 'server_addr w!
	PORT dup 8 << swap 8 >> or	'server_addr 2 + w!
	$0 'server_addr 4 + d! |INADDR_ANY

	server_socket 'server_addr 16 bind 
	-? ( "error %d" .println server_socket closesocket WSACleanup ; ) drop
	
	server_socket 1 listen
	-? ( "error %d" .println server_socket closesocket WSACleanup ; ) drop
	
	PORT "App port:%d" .println
	;
	
:serverend	
	"End App" .println
	WSACleanup ;
	
: |<<<<< BOOT <<<<<<<
	serverini
	webserver
	serverend
	;
