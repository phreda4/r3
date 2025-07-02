| SO core words
| PHREDA 2021

^r3/lib/win/kernel32.r3
^r3/lib/str.r3
	
#process-heap

::ms | ms --
	Sleep ;

::msec | -- msec
	GetTickCount ;
	
|************** not used	
::iniheap	
	GetProcessHeap 'process-heap ! ;
	
::allocate |( n -- a ior ) 
	process-heap 0 rot HeapAlloc ;
	
::free |( a -- ior ) 
	process-heap 0 rot HeapFree ;

::resize |( a n -- a ior ) 
	process-heap -rot 0 rot HeapReAlloc ;

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

::sysdate | -- 'dt
	'sistime GetLocalTime
	'sistime ;
	
#fdd * 512
#hfind 

|struct WIN32_FIND_DATAA
|  dwFileAttributes   dd ? 0
|  ftCreationTime     FILETIME 4
|  ftLastAccessTime   FILETIME 12
|  ftLastWriteTime    FILETIME 20
|  nFileSizeHigh      dd ? 28
|  nFileSizeLow	     dd ? 32
|  dwReserved0	     dd ? 36
|  dwReserved1	     dd ? 40
|  cFileName	     db MAX_PATH dup (?) 44
|  cAlternateFileName db 14 dup (?)
::findata	'fdd ;

::ffirst | "path//*" -- fdd/0
	'fdd FindFirstFile
	-1 =? ( drop 0 ; )
	'hfind !
	'fdd ;

::fnext | -- fdd/0
	hfind 'fdd FindNextFile
	1? ( drop 'fdd ; )
	hfind FindClose ;

::FNAME | adr -- adrname
	44 + ;

::FDIR | adr -- 1/0
	@ 4 >> 1 and ;
	
::FSIZE | adr -- sizekb
	32 + d@ 10 >> ; | in kb	
	
::FSIZEF | adr -- sizebytes
	28 + @ dup 32 >> swap 32 << or ; | bytes

#aux 0 0 | for time and file

::filetimeD | 'FILETIME -- 'timedate
	'aux FileTimeToSystemTime
	0 'aux 'sistime SystemTimeToTzSpecificLocalTime
	'sistime ;		

::FCREADT | adr -- 'timedate | creation date
	4 + filetimeD ;	

::FLASTDT | adr -- 'timedate  | last acces date
	12 + filetimeD ;	

::FWRITEDT | adr -- 'timedate | last write date
	20 + filetimeD ;	

|  WORD wYear;
|  WORD wMonth;
|  WORD wDayOfWeek;
|  WORD wDay;
|  WORD wHour;
|  WORD wMinute;
|  WORD wSecond;
|  WORD wMilliseconds;

::date.d ::time.ms 48 >> $ffff and ;
::date.dw ::time.s 32 >> $ffff and ;
::date.m ::time.m 16 >> $ffff and ;
::date.y ::time.h $ffff and ;

::load | 'from "filename" -- 'to
	$80000000 1 0 3 $8000000 0 CreateFile
	-1 =? ( drop ; ) swap
	0 'aux ! | uso dword! sure 0, when trash in mem..trouble
	( 2dup $ffff 'aux 0 ReadFile drop
		aux + aux 1? drop ) drop
	swap CloseHandle ;
	
::save | 'from cnt "filename" -- 
	$40000000 0 0 2 $8000000 0 CreateFile
	-1 =? ( 3drop ; )
	dup >r -rot 'aux 0 WriteFile
	r> swap 0? ( 2drop ; ) drop
	CloseHandle ;
	
::append | 'from cnt "filename" -- 
	$4 1 0 4 $80 0 CreateFile
	-1 =? ( 3drop ; )
	dup 0 0 2 SetFilePointer drop
	dup >r -rot 'aux 0 WriteFile
	r> swap 0? ( 2drop ; ) drop
	CloseHandle ;

::delete | "filename" --
	DeleteFile drop ;
	
::filexist | "file" -- 0=no
	GetFileAttributes $ffffffff xor ;
	
|typedef struct _WIN32_FILE_ATTRIBUTE_DATA {
|DWORD dwFileAttributes; // attributes (the same as for the function GetFileAttributes)
|FILETIME ftCreationTime; // creation time
|FILETIME ftLastAccessTime; // last access time
|FILETIME ftLastWriteTime; // last modification time
|DWORD nFileSizeHigh; // the high DWORD of the file size (it is zero unless the file is over four gigabytes)
|DWORD nFileSizeLow; // the low DWORD of the file size
|} WIN32_FILE_ATTRIBUTE_DATA;

| atrib creation access write size
#fileatrib 0 0 0 0 0
	
::fileisize | -- size
	'fileatrib 28 + @ dup 32 >> swap 32 << or ;

::fileijul | -- jul
	'fileatrib 20 + @
	86400000000 / | segundos>days
	23058138 + | julian from 1601-01-01 (2305813.5) (+3??)
	10 / ;	
	
::fileinfo | "file" -- 0=not exist
	0 'fileatrib GetFileAttributesEx  ;
	
::filecreatetime	'fileatrib 4 + ;
::filelastactime	'fileatrib 12 + ;
::filelastwrtime	'fileatrib 20 + ;

|struct STARTUPINFO
|0  cb		  dd ?,?
|1  lpReserved	  dq ?
|2  lpDesktop	  dq ?
|3  lpTitle	  dq ?
|4  dwX		  dd ?  dwY		  dd ?
|5  dwXSize	  dd ?  dwYSize	  dd ?
|6  dwXCountChars   dd ? dwYCountChars   dd ?
|7  dwFillAttribute dd ?  dwFlags	  dd ?
|8  wShowWindow	  dw ? cbReserved2	  dw ?,?,?
|9  lpReserved2	  dq ?
|10  hStdInput	  dq ?
|11  hStdOutput	  dq ?
|12  hStdError	  dq ?

##sinfo * 104

|struct PROCESS_INFORMATION
|0  hProcess    dq ?
|1  hThread     dq ?
|2  dwProcessId dd ? dwThreadId  dd ?

##pinfo * 24

:ininfo
	'sinfo 0 16 fill | 104/8=13+3=16
|	'pinfo 0 3 fill | 24/8=3 ^^ +3
	104 'sinfo d!
	;
	
::sys | "" --
	ininfo
	0 swap 0 0 0 0 0 0 'sinfo 'pinfo CreateProcess drop
	pinfo -1 WaitForSingleObject
	;
	
|https://learn.microsoft.com/en-us/windows/win32/procthread/process-creation-flags	
| $10 new console
::sysnew | "" --
	ininfo	
	0 swap 0 0 0 $10 0 0 'sinfo 'pinfo CreateProcess drop
	pinfo -1 WaitForSingleObject
	;
	

|https://learn.microsoft.com/es-mx/windows/win32/debug/creating-a-basic-debugger?redirectedfrom=MSDN
|https://www.codeproject.com/Articles/43682/Writing-a-basic-Windows-debugger

|#DEBUG_ONLY_THIS_PROCESS $00000002
|#DEBUG_PROCESS $00000001

::sysdebug | "" -- 
	ininfo
	|0 swap 
	0
	0 0 0 $2 0 0 'sinfo 'pinfo CreateProcess drop
|	pinfo -1 WaitForSingleObject
	;
