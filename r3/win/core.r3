| SO core words
| PHREDA 2021

^r3/win/kernel32.r3
^r3/lib/str.r3
	
#process-heap

::ms | ms --
	Sleep ;
	
::allocate |( n -- a ior ) 
	process-heap 0 rot HeapAlloc ;
	
::free |( a -- ior ) 
	process-heap 0 rot HeapFree ;
	
::resize |( a n -- a ior ) 
	process-heap rot rot 0 rot HeapReAlloc ;

::msec | -- msec
	GetTickCount ;
	
|----------
#sistime 0 0 | 16 bytes

::time | -- hms
	'sistime GetLocalTime
	'sistime 8 + @
	dup 32 >> $ffff and 
	over 16 >> $ffff and 
	rot $ffff and
	8 << or 8 << or 
	;
	
::date | -- ymd
	'sistime GetLocalTime
	'sistime @
	dup 48 >> $ffff and 
	over 16 >> $ffff and
	rot $ffff and
	8 << or 8 << or
	;
	
#fdd * 260
#hfind 
|struct WIN32_FIND_DATAA
|  dwFileAttributes   dd ?
|  ftCreationTime     FILETIME
|  ftLastAccessTime   FILETIME
|  ftLastWriteTime    FILETIME
|  nFileSizeHigh      dd ?
|  nFileSizeLow	     dd ?
|  dwReserved0	     dd ?
|  dwReserved1	     dd ?
|  cFileName	     db MAX_PATH dup (?)
|  cAlternateFileName db 14 dup (?)

::ffirst | "path//*" -- fdd/0
	'fdd FindFirstFile
	-1 =? ( drop 0 ; )
	'hfind !
	'fdd ;

::fnext | -- fdd/0
	hfind 'fdd FindNextFile
	1? ( drop 'fdd ; )
	hfind FindClose ;

#cntf
	
::load | 'from "filename" -- 'to
	$80000000 1 0 3 $8000000 0 CreateFile
	-1 =? ( drop ; ) swap
	( 2dup $ffff 'cntf 0 ReadFile drop
		cntf + cntf 1? drop ) drop
	swap CloseHandle ;
	
::save | 'from cnt "filename" -- 
	$40000000 0 0 2 $8000000 0 CreateFile
	-1 =? ( 3drop ; )
	dup >r rot rot 'cntf 0 WriteFile
	r> swap 0? ( 2drop ; ) drop
	CloseHandle ;
	
::append | 'from cnt "filename" -- 
	$4 0 0 2 $8000000 0 CreateFile
	-1 =? ( 3drop ; )
	dup >r rot rot 'cntf 0 WriteFile
	r> swap 0? ( 2drop ; ) drop
	CloseHandle ;

|struct STARTUPINFO
|  cb		  dd ?,?
|  lpReserved	  dq ?
|  lpDesktop	  dq ?
|  lpTitle	  dq ?
|  dwX		  dd ?
|  dwY		  dd ?
|  dwXSize	  dd ?
|  dwYSize	  dd ?
|  dwXCountChars   dd ?
|  dwYCountChars   dd ?
|  dwFillAttribute dd ?
|  dwFlags	  dd ?
|  wShowWindow	  dw ?
|  cbReserved2	  dw ?,?,?
|  lpReserved2	  dq ?
|  hStdInput	  dq ?
|  hStdOutput	  dq ?
|  hStdError	  dq ?

#sinfo * 100

|struct PROCESS_INFORMATION
|  hProcess    dq ?
|  hThread     dq ?
|  dwProcessId dd ?
| dwThreadId  dd ?

#pinfo * 24

::sys | "" --
	'sinfo 0 100 cfill
	68 'sinfo d!
	0 swap 0 0 1 0 0 0 'sinfo 'pinfo CreateProcess drop
	pinfo -1 WaitForSingleObject
	;
	
:
	GetProcessHeap 'process-heap !
	;