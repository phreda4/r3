| memory share WIN/LIN
| PHREDA 2026
| 4kb for now

^r3/lib/mem.r3

#mapfilename "/data.mem"
#mapfile
##memshare

|-WIN
|$F001F |FILE_MAP_ALL_ACCESS	
|4 | PAGE_READWRITE,
|-LIN
| $40 OCREATE  $2 RW
|PROT_READ	0x1	PROT_WRITE	0x2

:createmap | 0 -- mapfile
|WIN|	-1 0 4 0 4096 'mapfilename CreateFileMappingA

|LIN|	'mapfilename $42 $1b6 shm_open
|LIN|	dup 4096 ftruncate drop
	;

::iniShare | --
|WIN|	$F001F 0 'mapfilename OpenFileMappingA 0? ( drop createmap ) 'mapfile !
|WIN|	mapfile $f001F 0 0 4096 MapViewOfFile 'memshare !
	
|LIN|	'mapfilename $2 $1b6 shm_open 32 << 32 >> -? ( drop createmap ) 'mapfile !
|LIN|	0 4096 $3 1 mapfile 0 libc-mmap 'memshare !
	;
	
::endShare
|WIN|	memshare UnmapViewOfFile mapfile CloseHandle

|LIN|	mapfile 4096 libc-munmap mapfile libc-close
	;
