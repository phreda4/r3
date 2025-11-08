| net socket
| PHREDA 2025

|LIN| ^r3/lib/posix/posix.r3
|WIN| ^r3/lib/win/ws2.r3

| ============================================
| Constantes comunes
| ============================================

#AF_INET 2
#SOCK_STREAM 1
#SOL_SOCKET 1
#SO_REUSEADDR 2
#INVALID_SOCKET -1

|LIN| #FIONBIO $5421
|WIN| #FIONBIO $8004667E
|WIN| #FIONBIO_MODE 1

| ============================================
| Inicialización multiplataforma
| ============================================
:socket-init | Windows: inicializar Winsock2
|WIN| $0202 sw2-WSAStartup drop
	;

:socket-cleanup | Windows: limpiar Winsock2
|WIN| sw2-WSACleanup drop
	;

| ============================================
| Abstracción: crear socket
| ============================================
:socket-create |( family type protocol -- sock )
|WIN| sw2-socket
|LIN| libc-socket 
	;

| ============================================
| Abstracción: establecer no-bloqueante
| ============================================
:socket-set-nonblock |( sock -- result )
|LIN| F_SETFL O_NONBLOCK libc-fcntl
|WIN| FIONBIO_MODE sw2-ioctlsocket
	;

| ============================================
| Abstracción: opciones de socket
| ============================================
:socket-set-reuseaddr |( sock -- result )
	1 here ! | Preparar valor (1)
	| setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &value, sizeof(int))
	SOL_SOCKET SO_REUSEADDR here 4 
|WIN| sw2-setsockopt
|LIN| libc-setsockopt
	;

| ============================================
| Abstracción: operaciones básicas
| ============================================
:socket-bind |( sock addr port -- result )
|WIN| sw2-bind
|LIN| libc-bind 
	;

:socket-listen |( sock backlog -- result )
|WIN| sw2-listen
|LIN| libc-listen 
	;
	
:socket-accept |( sock addr addrlen -- newsock )
|WIN| sw2-accept
|LIN| libc-accept 
	;

:socket-connect |( sock addr addrlen -- result )
|WIN| sw2-connect
|LIN| libc-connect 
	;

:socket-send |( sock data len flags -- bytes_sent )
|WIN| sw2-send
|LIN| libc-send 
	;

:socket-recv |( sock buf len flags -- bytes_recv )
|WIN| sw2-recv
|LIN| libc-recv 
	;

| ============================================
| Abstracción: cerrar socket
| ============================================
:socket-close |( sock -- result )
|LIN| libc-close
|WIN| sw2-closesocket
	;

| ============================================
| Abstracción: utilidades de red
| ============================================
:net-addr-to-int |( "ip-string" -- addr )
|LIN| libc-inet_addr
|WIN| sw2-inet_addr
	;

:net-htons |( port -- network_port )
|LIN| libc-htons
|WIN| sw2-htons
	;

:net-get-last-error |( -- error_code )
|LIN| 0 | errno en Linux (requiere acceso a variable global)
|WIN| sw2-WSAGetLastError
	;

| ============================================
| Funciones de alto nivel
| ============================================
:server-socket |( port -- sock )
	socket-init
	AF_INET SOCK_STREAM 0 socket-create
	dup socket-set-nonblock drop
	dup socket-set-reuseaddr drop
	;

:client-socket |( -- sock )
	socket-init
	AF_INET SOCK_STREAM 0 socket-create
	dup socket-set-nonblock drop
	;

:socket-final |( sock -- )
	socket-close drop
	socket-cleanup
	;