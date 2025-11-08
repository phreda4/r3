| socket wrapper para r3 - WINDOWS
| syscalls de sockets desde Winsock2

#sys-WSAStartup
#sys-WSACleanup
#sys-socket
#sys-bind
#sys-listen
#sys-accept
#sys-connect
#sys-send
#sys-recv
#sys-closesocket
#sys-setsockopt
#sys-ioctlsocket
#sys-inet_addr
#sys-htons
#sys-inet_aton
#sys-inet_ntoa
#sys-getaddrinfo
#sys-freeaddrinfo
#sys-gai_strerror
#sys-gethostbyname
#sys-gethostbyaddr
#sys-getprotobyname
#sys-getprotobynumber
#sys-getservbyname
#sys-getservbyport
#sys-gethostname
#sys-WSAGetLastError
#sys-WSASetLastError

::ws2-WSAStartup sys-WSAStartup sys2 ;
::ws2-WSACleanup sys-WSACleanup sys0 ;
::ws2-socket sys-socket sys3 ;
::ws2-bind sys-bind sys3 ;
::ws2-listen sys-listen sys2 ;
::ws2-accept sys-accept sys3 ;
::ws2-connect sys-connect sys3 ;
::ws2-send sys-send sys4 ;
::ws2-recv sys-recv sys4 ;
::ws2-closesocket sys-closesocket sys1 ;
::ws2-setsockopt sys-setsockopt sys5 ;
::ws2-ioctlsocket sys-ioctlsocket sys3 ;
::ws2-inet_addr sys-inet_addr sys1 ;
::ws2-htons sys-htons sys1 ;
::ws2-inet_aton sys-inet_aton sys2 ;
::ws2-inet_ntoa sys-inet_ntoa sys1 ;
::ws2-getaddrinfo sys-getaddrinfo sys4 ;
::ws2-freeaddrinfo sys-freeaddrinfo sys1 ;
::ws2-gai_strerror sys-gai_strerror sys1 ;
::ws2-gethostbyname sys-gethostbyname sys1 ;
::ws2-gethostbyaddr sys-gethostbyaddr sys3 ;
::ws2-getprotobyname sys-getprotobyname sys1 ;
::ws2-getprotobynumber sys-getprotobynumber sys1 ;
::ws2-getservbyname sys-getservbyname sys2 ;
::ws2-getservbyport sys-getservbyport sys2 ;
::ws2-gethostname sys-gethostname sys2 ;
::ws2-WSAGetLastError sys-WSAGetLastError sys0 ;
::ws2-WSASetLastError sys-WSASetLastError sys1 ;

:
	"ws2_32.dll" loadlib
	dup "WSAStartup" getproc 'sys-WSAStartup !
	dup "WSACleanup" getproc 'sys-WSACleanup !
	dup "socket" getproc 'sys-socket !
	dup "bind" getproc 'sys-bind !
	dup "listen" getproc 'sys-listen !
	dup "accept" getproc 'sys-accept !
	dup "connect" getproc 'sys-connect !
	dup "send" getproc 'sys-send !
	dup "recv" getproc 'sys-recv !
	dup "closesocket" getproc 'sys-closesocket !
	dup "setsockopt" getproc 'sys-setsockopt !
	dup "ioctlsocket" getproc 'sys-ioctlsocket !
	dup "inet_addr" getproc 'sys-inet_addr !
	dup "htons" getproc 'sys-htons !
	dup "inet_aton" getproc 'sys-inet_aton !
	dup "inet_ntoa" getproc 'sys-inet_ntoa !
	dup "getaddrinfo" getproc 'sys-getaddrinfo !
	dup "freeaddrinfo" getproc 'sys-freeaddrinfo !
	dup "gai_strerror" getproc 'sys-gai_strerror !
	dup "gethostbyname" getproc 'sys-gethostbyname !
	dup "gethostbyaddr" getproc 'sys-gethostbyaddr !
	dup "getprotobyname" getproc 'sys-getprotobyname !
	dup "getprotobynumber" getproc 'sys-getprotobynumber !
	dup "getservbyname" getproc 'sys-getservbyname !
	dup "getservbyport" getproc 'sys-getservbyport !
	dup "gethostname" getproc 'sys-gethostname !
	dup "WSAGetLastError" getproc 'sys-WSAGetLastError !
	dup "WSASetLastError" getproc 'sys-WSASetLastError !
	drop
;