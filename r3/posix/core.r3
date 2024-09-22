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


|        file=fopen((char*)TOS,"rb");
|        TOS=*NOS;NOS--;
|        if (file==NULL) continue;
|        do { op=fread((void*)TOS,sizeof(char),1024,file); TOS+=op; } while (op==1024);
|        fclose(file);continue;
	
::load | 'from "filename" -- 'to
    0? ( drop ; )
    2 $1ff libc-open     | 0=O_RDONLY 2= O_RDWR   1ff = 777 
    0? ( drop ; ) | adr FILE
    swap 
    ( 2dup $ffff libc-read +? + ) drop
    swap libc-close drop
    ;
 

|    case SAVE: //SAVE: // 'from cnt "filename" --
|        if (TOS==0||*NOS==0) { remove((char*)TOS);
|		NOS-=2;TOS=*NOS;NOS--;continue; }
|        file=fopen((char*)TOS,"wb");
|        TOS=*NOS;NOS--;
|        if (file==NULL) { NOS--;TOS=*NOS;NOS--;continue; }
|        fwrite((void*)*NOS,sizeof(char),TOS,file);
|        fclose(file);
	
::save | 'from cnt "filename" --
    0? ( 3drop ; )
    3 $1ff libc-open     | 1=O_WRONLY?? 2= O_RDWR   1ff = 777 
	-1 =? ( 3drop ; )
|	dup >r rot rot 'cntf 0 WriteFile
    libc-close drop 
    ;

|    case APPEND: //APPEND: // 'from cnt "filename" --
|        if (TOS==0||*NOS==0) { NOS-=2;TOS=*NOS;NOS--;continue; }
|        file=fopen((char*)TOS,"ab");
|       TOS=*NOS;NOS--;
|        if (file==NULL) { NOS--;TOS=*NOS;NOS--;continue; }
|        fwrite((void*)*NOS,sizeof(char),TOS,file);
|        fclose(file);
|        NOS--;TOS=*NOS;NOS--;continue;
	
::append | 'from cnt "filename" -- 
    0? ( 3drop ; )
    3 $1ff libc-open     | 1=O_WRONLY?? 2= O_RDWR   1ff = 777 
	-1 =? ( 3drop ; )
|	dup 0 0 2 SetFilePointer drop
|	dup >r rot rot 'cntf 0 WriteFile
|	r> swap 0? ( 2drop ; ) drop
|	CloseHandle 
    ;

::delete | "filename" --
|	DeleteFile 
drop 
    ;
	
::filexist | "file" -- 0=no
|	GetFileAttributes $ffffffff xor 
    ;
	
| atrib creation access write size
#fileatrib [ 0 ] 0 0 0 0
	
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
|	0 'fileatrib GetFileAttributesEx  
    ;
	

::sys | "" --
    libc-system drop ;
	
