| winhttp
| PHREDA 2022
|
^r3/win/console.r3

#sys-WinHttpOpen
#sys-WinHttpConnect
#sys-WinHttpOpenRequest
#sys-WinHttpSendRequest
#sys-WinHttpReceiveResponse
#sys-WinHttpQueryDataAvailable
#sys-WinHttpReadData
#sys-WinHttpCloseHandle


::WinHttpOpen sys-WinHttpOpen sys5 ;
::WinHttpConnect sys-WinHttpConnect	sys4 ;
::WinHttpOpenRequest sys-WinHttpOpenRequest sys7 ;
::WinHttpSendRequest sys-WinHttpSendRequest sys7 ;
::WinHttpReceiveResponse sys-WinHttpReceiveResponse sys2 ;
::WinHttpQueryDataAvailable sys-WinHttpQueryDataAvailable sys2 ;
::WinHttpReadData sys-WinHttpReadData sys4 ;
::WinHttpCloseHandle sys-WinHttpCloseHandle sys1 drop ;

#session
#connect
#request
#size
#dw

::loadurl | buff url -- buff 
	|"WinHTTP/1.0" 
	0
	0 0 0 0 WinHttpOpen
	dup "ses:%h " .println
	0? ( 2drop ; ) 
	
	dup 'session !
	swap 0 0 WinHttpConnect
	dup "con:%h " .println
	0? ( drop ; ) 
	
	dup 'connect ! | buff con
	"GET" 0 0 
	0 0 0 
	WinHttpOpenRequest
	dup "req:%h " .println
	0? ( drop ; ) 
	
	'request !
	>a
	request 0 0 0 0 0 0 WinHttpSendRequest drop
	request 0 WinHttpReceiveResponse drop
	0 ( drop
		request 'size WinHttpQueryDataAvailable drop
		request a> size 'dw WinHttpReadData drop
		size dup a+
		+? ) drop
	
	request WinHttpCloseHandle
	connect WinHttpCloseHandle
	session WinHttpCloseHandle
	a> ;
	
|--------- BOOT	
: 
	"WINHTTP.DLL" loadlib 
	dup "WinHttpOpen" getproc 'sys-WinHttpOpen !
	dup "WinHttpConnect" getproc 'sys-WinHttpConnect !
	dup "WinHttpOpenRequest" getproc 'sys-WinHttpOpenRequest !
	dup "WinHttpSendRequest" getproc 'sys-WinHttpSendRequest !
	dup "WinHttpReceiveResponse" getproc 'sys-WinHttpReceiveResponse !
	dup "WinHttpQueryDataAvailable" getproc 'sys-WinHttpQueryDataAvailable !
	dup "WinHttpReadData" getproc 'sys-WinHttpReadData !
	dup "WinHttpCloseHandle" getproc 'sys-WinHttpCloseHandle !
	drop ;
	