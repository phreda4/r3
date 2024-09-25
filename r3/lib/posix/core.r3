| SO core words
| PHREDA 2021

^r3/lib/posix/posix.r3
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
	4 'te libc-clock_gettime drop
	'te @+ 1000 * swap @ 1000000 / + ;

|struct tm {
|   int tm_sec;         /* seconds,  range 0 to 59          */ 0
|   int tm_min;         /* minutes, range 0 to 59           */ 4
|   int tm_hour;        /* hours, range 0 to 23             */ 8
|   int tm_mday;        /* day of the month, range 1 to 31  */ 12
|   int tm_mon;         /* month, range 0 to 11             */ 16
|   int tm_year;        /* The number of years since 1900   */ 20
|   int tm_wday;        /* day of the week, range 0 to 6    */ 24
|   int tm_yday;        /* day in the year, range 0 to 365  */ 28
|   int tm_isdst;       /* daylight saving time             */ 32
#sit 0

::time | -- hms
	0 libc-time 'sit !
	'sit libc-localtime |'sit !
	|'sit 
	dup 8 + d@ 16 <<
	over 4 + d@ 8 << or
	swap d@ or ;

::date | -- ymd
	0 libc-time 'sit !
	'sit libc-localtime |'sit !
	|'sit 
	dup 20 + d@ 1900 + 16 <<
	over 16 + d@ 1+ 8 << or
	swap 12 + d@ or ;

|struct dirent {
|    ino64_t d_ino;        // Inode number 0
|    off64_t d_off;        // Offset to the next dirent 8
|    unsigned short d_reclen; // Length of this record 16
|    unsigned char d_type; // Type of file 18
|    char d_name[];        // Filename (null-terminated) 19
|};

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

::FSIZE
	32 + d@ 10 >> ; | in kb	

#dirp

::ffirst | "path//*" -- fdd/0
	libc-opendir dup 'dirp ! 
	0? ( ; ) 
	libc-readdir ;

::fnext | -- fdd/0
	dirp 0? ( ; ) 
	libc-readdir ;

|0 constant O_RDONLY octal
|1 constant O_WRONLY
|2 constant O_RDWR
|100 constant O_CREAT $40
|200 constant O_TRUNC $80
|2000 constant O_APPEND $400
|4000 constant O_NONBLOCK $800
| 077 octal $1ff

::load | 'from "filename" -- 'to
	0? ( drop ; )
	$0 0 libc-open -? ( drop ; ) | adr FILE
	swap ( 2dup $ffff libc-read 1? + ) drop
	swap libc-close drop
	;

::save | 'from cnt "filename" --
	0? ( 3drop ; )
	$C1 $1ff libc-open -? ( 3drop ; )
	dup >r
	-rot libc-write drop
	r> libc-close drop 
	;

::append | 'from cnt "filename" -- 
	0? ( 3drop ; )
	$441 $1ff libc-open -? ( 3drop ; )
	dup >r
	-rot libc-write drop
	r> libc-close drop 
	;

::delete | "filename" -- 
	libc-unlink drop ;

::filexist | "file" -- 0=no
	0 libc-access not ;

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
	'fileatrib libc-stat ;
	
::sys | "" --
	libc-system drop ;
	
|--- copy and restore registers A B, to system?
::a[ 	a> >r ;
::]a	r> >a ;
::b[ 	b> >r ;
::]b	r> >b ;

