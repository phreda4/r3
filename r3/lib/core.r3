| SO core words
| PHREDA 2021

^r3/lib/str.r3
|LIN| ^r3/lib/posix/posix.r3
|WIN| ^r3/lib/win/kernel32.r3
|MAC| ^r3/lib/mac/posix.r3

::ms | ms --
|WIN|	Sleep 

|LIN|	1000* libc-usleep drop 
|MAC|	1000* libc-usleep drop 
	;

|LIN| #te 0 0 
|MAC| #te 0 0 

::msec | -- msec
|WIN|	GetTickCount 

|LIN|	4 'te libc-clock_gettime drop |4 constant CLOCK_MONOTONIC_RAW
|LIN|	'te @+ 1000* swap @ 1000000/ + 

|MAC|	4 'te libc-clock_gettime drop |4 constant CLOCK_MONOTONIC_RAW
|MAC|	'te @+ 1000* swap @ 1000000/ +
	;
		
#aux	
:32>64 32 << 32 >> ;
	

	
::load | 'from "filename" -- 'to
|WIN|	$80000000 1 0 3 $8000000 0 CreateFile
|WIN|	-1 =? ( drop ; ) swap
|WIN|	0 'aux ! | uso dword! sure 0, when trash in mem..trouble
|WIN|	( 2dup $ffff 'aux 0 ReadFile drop
|WIN|		aux + aux 1? drop ) drop
|WIN|	swap CloseHandle 
|LIN|	0? ( drop ; )
|LIN|	$0 0 libc-open 32>64 -? ( drop ; ) | adr FILE
|LIN|	swap ( 2dup $ffff libc-read 1? + ) drop
|LIN|	swap libc-close drop
|MAC|	0? ( drop ; )
|MAC|	$0 0 libc-open 32>64 -? ( drop ; ) | adr FILE
|MAC|	swap ( 2dup $ffff libc-read 1? + ) drop
|MAC|	swap libc-close drop
	;

::save | 'from cnt "filename" --
|WIN|	$40000000 0 0 2 $8000000 0 CreateFile
|WIN|	-1 =? ( 3drop ; )
|WIN|	dup >r -rot 'aux 0 WriteFile drop
|WIN|	r> CloseHandle 
|LIN|	0? ( 3drop ; )
|LIN|	$241 $1a4 libc-open 32>64 -? ( 3drop ; )
|LIN|	dup >r
|LIN|	-rot libc-write drop
|LIN|	r> libc-close drop 
|MAC|	0? ( 3drop ; )
|MAC|	$1a4 libc-creat 32>64	| O_WRONLY|O_CREAT|O_TRUNC (no variadic open: Apple arm64 ABI)
|MAC|	-? ( 3drop ; )
|MAC|	dup >r
|MAC|	-rot libc-write drop
|MAC|	r> libc-close drop 
	;

::append | 'from cnt "filename" -- 
|WIN|	$4 1 0 4 $80 0 CreateFile
|WIN|	-1 =? ( 3drop ; )
|WIN|	dup >r -rot 'aux 0 WriteFile drop
|WIN|	r> CloseHandle 
|LIN|	0? ( 3drop ; )
|LIN|	$441 $1a4 libc-open 32>64 -? ( 3drop ; )
|LIN|	dup >r
|LIN|	-rot libc-write drop
|LIN|	r> libc-close drop 
|MAC|	0? ( 3drop ; )
|MAC|	dup 0 libc-access 32>64 -? ( over $1a4 libc-creat 32>64 libc-close drop ) drop
|MAC|	$9 0 libc-open 32>64	| O_WRONLY|O_APPEND
|MAC|	-? ( 3drop ; ) dup >r
|MAC|	-rot libc-write drop
|MAC|	r> libc-close drop 
	;


::delete | "filename" -- 
|WIN|	DeleteFile drop 
|LIN|	libc-unlink drop
|MAC|	libc-unlink drop
	;

::filexist | "file" -- 0=no
|WIN|	GetFileAttributes $ffffffff xor 
|LIN|	0 libc-access $ffffffff xor 
|MAC|	0 libc-access 32>64 1+ 	| access: 0 ok / -1 error
	;

	
| atrib creation access write size
|WIN| #fileatrib 0 0 0 0 0
	
| atrib creation access write size
| struct stat (x86_64/aarch64 glibc): size 48, atime 72, mtime 88, ctime 104

|LIN|#fileatrib * 160
|MAC|#fileatrib * 160
	

::fileisize | -- size
|WIN|	'fileatrib 28 + @ dup 32 >>> swap 32 << or 
|LIN|	'fileatrib 48 + @ 
|MAC|	'fileatrib 96 + @ 
	;

::fileijul | -- jul ; julian day number of last write date (UTC)
|WIN|	'fileatrib 20 + @ 864000000000 / 2305814 + 
|LIN|	'fileatrib 88 + @ 86400 / 2440588 + 
|MAC|	'fileatrib 48 + @ 86400 / 2440588 +
	;	| julian day number from 1601-01-01 (JD 2305813.5)	
		
::fileinfo | "file" -- 0=not exist
|WIN|	0 'fileatrib GetFileAttributesEx  
|LIN|	'fileatrib libc-stat 32>64 0? ( drop 1 ; ) drop 0 
|MAC|	'fileatrib libc-stat 32>64 0? ( drop 1 ; ) drop 0
	;


::filecreatetime 
	'fileatrib 
|WIN|	4 +	
|LIN|	104 + 
|MAC|	80 +
	;
	
::filelastactime 
	'fileatrib 
|WIN|	12 +	
|LIN|	72 + 
|MAC|	32 +
	;
	
::filelastwrtime 
	'fileatrib 
|WIN|	20 +	
|LIN|	88 + 
|MAC|	48 +
	;

#sit 0 0

::filetimeD | 'time_t -- 'timedate
|WIN|	'aux FileTimeToSystemTime
|WIN|	0 'aux 'sit SystemTimeToTzSpecificLocalTime
|WIN|	'sit
|LIN|	libc-localtime 
|MAC|	libc-localtime 
	;	


| struct stat offsets: LIN x86_64 size 48 atime 72 mtime 88 ctime 104
|                      MAC (64bit inode) atime 32 mtime 48 ctime 64 birth 80 size 96
	
::FSIZEF | adr -- sizebytes
|WIN|	28 + d@+ 32 << swap d@ or 
|LIN|	drop 'st 48 + @ 	
|MAC|	drop 'st 96 + @ 
	; | bytes
	
::FCREADT | adr -- 'timedate | creation date
|WIN|	4 + filetimeD	
|LIN|	drop 'st 104 + libc-localtime 
|MAC|	drop 'st 80 + libc-localtime 
	;

::FLASTDT | adr -- 'timedate  | last acces date
|WIN|	12 + filetimeD
|LIN|	drop 'st 72 + libc-localtime 
|MAC|	drop 'st 72 + libc-localtime
	;

::FWRITEDT | adr -- 'timedate | last write date
|WIN|	20 + filetimeD 
|LIN|	drop 'st 88 + libc-localtime 
|MAC|	drop 'st 48 + libc-localtime
	;


::FNAME | adr -- adrname
|WIN| 44 +
|LIN| 19 +
|RPI| 11 +
|MAC| 21 +               | when _DARWIN_FEATURE_64_BIT_INODE is set !
	;

::FDIR | adr -- 1/0
|WIN| @ 4 >>
|LIN| 18 + c@ 2 >>
|RPI| 10 + c@ 2 >>
|MAC| 20 + c@ 2 >>       | when _DARWIN_FEATURE_64_BIT_INODE is set !
	1 and ;


|WIN|	#fdd * 512 #hfind 
|LIN|	#dirp #dirfd #st * 160 
|LIN|:statent | ent -- ent/0 ; fill 'st for the entry
|LIN|	0? ( ; ) dirfd over FNAME 'st 0 libc-fstatat drop ;
|MAC|	#dirp #dirfd #st * 160 
|MAC|:statent | ent -- ent/0 ; fill 'st for the entry
|MAC|	0? ( ; ) dirfd over FNAME 'st 0 libc-fstatat drop ;

::findata
|WIN|	'fdd 
|LIN|	'dirp
|MAC|	'dirp
	;

::ffirst | "path//*" -- fdd/0
|WIN|	'fdd FindFirstFile
|WIN|	-1 =? ( drop 0 ; ) 'hfind ! 'fdd 
|LIN|	libc-opendir dup 'dirp ! 
|LIN|	0? ( ; ) 
|LIN|	dup libc-dirfd 'dirfd !
|LIN|	libc-readdir statent 
|MAC|	libc-opendir dup 'dirp ! 
|MAC|	0? ( ; ) 
|MAC|	dup libc-dirfd 'dirfd !
|MAC|	libc-readdir statent 
	;

::fnext | -- fdd/0
|WIN|	hfind 'fdd FindNextFile
|WIN|	1? ( drop 'fdd ; ) hfind FindClose 
|LIN|	dirp 0? ( ; ) 
|LIN|	libc-readdir
|LIN|	0? ( drop dirp libc-closedir drop 0 'dirp ! 0 ; )
|LIN|	statent 
|MAC|	dirp 0? ( ; ) 
|MAC|	libc-readdir
|MAC|	0? ( drop dirp libc-closedir drop 0 'dirp ! 0 ; )
|MAC|	statent 
	;

::date.d 
|LIN|	12 + d@ ;
|MAC|	12 + d@ ;
::time.ms 
|WIN|	48 >> $ffff and 
|LIN|	drop 0  | not exist!!
|MAC|	drop 0  | not exist!!
	;
::date.dw 
|LIN|	24 + d@ ;
|MAC|	24 + d@ ;
::time.s 
|WIN|	32 >> $ffff and 
|LIN|	d@
|MAC|	d@
	;
::date.m 
|LIN|	16 + d@ 1+ ; | 1..12
|MAC|	16 + d@ 1+ ; | 1..12
::time.m
|WIN|	16 >> $ffff and 
|LIN|	4 + d@ 
|MAC|	4 + d@ 
	;
::date.y 
|LIN|	20 + d@ 1900 + ;
|MAC|	20 + d@ 1900 + ;
::time.h
|WIN|	$ffff and 
|LIN|	8 + d@
|MAC|	8 + d@
	;

::time | -- hms
|WIN|	'sit GetLocalTime
|WIN|	'sit 8 + @
|WIN|	dup 32 >> $ffff and over 16 >> $ffff and 
|WIN|	rot $ffff and 8 << or 8 << or 

|LIN|	0 libc-time 'sit !
|LIN|	'sit libc-localtime 
|LIN|	dup 8 + d@ 16 << over 4 + d@ 8 << or swap d@ or 

|MAC|	0 libc-time 'sit !
|MAC|	'sit libc-localtime 
|MAC|	dup 8 + d@ 16 << over 4 + d@ 8 << or swap d@ or 
	;

::date | -- ymd
|WIN|	'sit GetLocalTime
|WIN|	'sit @
|WIN|	dup 48 >> $ffff and over 16 >> $ffff and
|WIN|	rot $ffff and 8 << or 8 << or

|LIN|	0 libc-time 'sit !
|LIN|	'sit libc-localtime 
|LIN|	dup 20 + d@ 1900 + 16 << over 16 + d@ 1+ 8 << or swap 12 + d@ or 
|MAC|	0 libc-time 'sit !
|MAC|	'sit libc-localtime 
|MAC|	dup 20 + d@ 1900 + 16 << over 16 + d@ 1+ 8 << or swap 12 + d@ or 

	;

::sysdate
|WIN|	'sit GetLocalTime 'sit
|LIN|	0 libc-time 'sit ! 'sit libc-localtime 
|MAC|	0 libc-time 'sit ! 'sit libc-localtime 
	;


##sinfo * 104
##pinfo * 24

|WIN|:ininfo
|WIN|	'sinfo 0 16 fill | 104/8=13+3=16 |	'pinfo 0 3 fill | 24/8=3 ^^ +3
|WIN|	104 'sinfo d! ;
		
		
	
::sys | "" --
|WIN|	ininfo
|WIN|	0 swap 0 0 0 0 0 0 'sinfo 'pinfo CreateProcess drop
|WIN|	pinfo -1 WaitForSingleObject
|WIN|	'pinfo @+ CloseHandle @ CloseHandle
|LIN|	libc-system drop 
|MAC|	libc-system drop 
	;

|WIN----
|https://learn.microsoft.com/en-us/windows/win32/procthread/process-creation-flags	
| $10 new console
::sysnew | "" -- ; 
|WIN|	GetConsoleWindow >r
|WIN|	ininfo	
|WIN|	1 'sinfo $38 + d! |    si.dwFlags = STARTF_USESHOWWINDOW;
|WIN|	4 'sinfo $40 + w! |    si.wShowWindow = SW_SHOWNOACTIVATE
|WIN|	0 swap 0 0 0 $10 0 0 'sinfo 'pinfo CreateProcess drop
|WIN|	'pinfo @+ CloseHandle @ CloseHandle | no wait
|WIN|	100 ms
|WIN|	r> SetForegroundWindow

|LIN|	|here "x-terminal-emulator -e bash -c '" ,s swap ,s "'" ,s ,eol
|LIN|	libc-system drop 

|LMAC|	libc-system drop 
	;
	

|https://learn.microsoft.com/es-mx/windows/win32/debug/creating-a-basic-debugger?redirectedfrom=MSDN
|https://www.codeproject.com/Articles/43682/Writing-a-basic-Windows-debugger
|#DEBUG_ONLY_THIS_PROCESS $00000002
|#DEBUG_PROCESS $00000001

::sysdebug | "" -- 
|WIN|	ininfo
|WIN|	0 swap 0 0 0 $2 0 0 'sinfo 'pinfo CreateProcess drop
	;
