| SO core words
| PHREDA 2021

^r3/posix/posix.r3
^r3/lib/str.r3
	
#process-heap

::ms | ms --
	1000 * libc-usleep drop ;
	
::allocate |( n -- a ior ) 
    libc-malloc dup  ;
   
::free |( a -- ior )
    libc-free drop 0 ; 

::resize |( a n -- a ior ) 
	libc-realloc dup 0 ;

|4 constant CLOCK_MONOTONIC_RAW
#te 0 0 
::msec | -- msec
   'te 4 libc-clock_gettime drop
   'te @+ 1000 * swap @ 1000000 / + ;

|struct tm {
|   int tm_sec;         /* seconds,  range 0 to 59          */
|   int tm_min;         /* minutes, range 0 to 59           */
|   int tm_hour;        /* hours, range 0 to 23             */
|   int tm_mday;        /* day of the month, range 1 to 31  */
|   int tm_mon;         /* month, range 0 to 11             */
|   int tm_year;        /* The number of years since 1900   */
|   int tm_wday;        /* day of the week, range 0 to 6    */
|   int tm_yday;        /* day in the year, range 0 to 365  */
|   int tm_isdst;       /* daylight saving time             */	
#sit 0
	

::time | -- hms
    'sit libc-time
    'sit libc-localtime 'sit !

|		time(&sit);sitime=localtime(&sit);
|		NOS++;*NOS=TOS;TOS=(sitime->tm_hour<<16)|(sitime->tm_min<<8)|sitime->tm_sec;continue;	

|	'sistime 8 + @
|	dup 32 >> $ffff and 
|	over 16 >> $ffff and 
|	rot $ffff and
|	8 << or 8 << or 
	;

	
::date | -- ymd
    'sit libc-time
    'sit libc-localtime 'sit !

|		time(&sit);sitime=localtime(&sit);
|		NOS++;*NOS=TOS;TOS=(sitime->tm_year+1900)<<16|(sitime->tm_mon+1)<<8|sitime->tm_mday;continue;

|	'sistime @
|	dup 48 >> $ffff and 
|	over 16 >> $ffff and
|	rot $ffff and
|	8 << or 8 << or
	;

|struct dirent {
|    ino64_t d_ino;        // Inode number 0
|    off64_t d_off;        // Offset to the next dirent 8
|    unsigned short d_reclen; // Length of this record 16
|    unsigned char d_type; // Type of file 18
|    char d_name[];        // Filename (null-terminated) 19
|};

#dirp

::ffirst | "path//*" -- fdd/0
    libc-opendir dup 'dirp ! 
    0? ( ; ) 
    libc-readdir ;

::fnext | -- fdd/0
    dirp 0? ( ; ) 
    libc-readdir ;

::load | 'from "filename" -- 'to
    0? ( drop ; )
    0 libc-open -? ( drop ; ) | adr FILE
    swap ( 2dup $ffff libc-read 1? + ) drop
    swap libc-close drop
    ;
 
::save | 'from cnt "filename" --
    0? ( 3drop ; )
    1 libc-open -? ( 3drop ; )
	dup >r
	-rot libc-write drop
    r> libc-close drop 
    ;

::append | 'from cnt "filename" -- 
    0? ( 3drop ; )
    2 libc-open -? ( 3drop ; )

|	dup 0 0 2 SetFilePointer drop
|	dup >r rot rot 'cntf 0 WriteFile
|	r> swap 0? ( 2drop ; ) drop
|	CloseHandle 
|    r> libc-close drop 
    ;

::delete | "filename" -- 
    libc-unlink drop ;
	
::filexist | "file" -- 0=no
|	GetFileAttributes $ffffffff xor 
    ;
	
| atrib creation access write size
#fileatrib 0 0 0 0 0
	
::fileisize | -- size
	'fileatrib 28 + @ 
	dup 32 >> swap 32 << or ;

::fileijul | -- jul
	'fileatrib 20 + @
	86400000000 / | segundos>days
	23058138 + | julian from 1601-01-01 (2305813.5) (+3??)
	10 /	
	;	
	
::fileinfo | "file" -- 0=not exist
    'fileatrib 'libc-stat
    ;
	

::sys | "" --
    libc-system drop ;
	
|--- copy and restore registers A B, to system?
::a[ 	a> >r ;
::]a	r> >a ;
::b[ 	b> >r ;
::]b	r> >b ;

