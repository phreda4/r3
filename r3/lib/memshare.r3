| memory share WIN/LIN
| PHREDA 2026

||||| memshare mapfile size filename 
|		  0 8 16   24
| #vshare 0 0 4096 "/data"

| 'vshar inishare | filename need be static (no buffer)
| vshar -> mem 
| 'vshar endshare

^r3/lib/mem.r3

:createmapv | 'varshare -- 'varshare mapfile
|WIN|	-1 0 4 0 pick4 16 + @+ swap CreateFileMappingA

|LIN|	dup 24 + $42 $1b6 shm_open			| $42 OCREATE|RW
|LIN|	dup over 16 + @ ftruncate drop
	;

|$F001F |FILE_MAP_ALL_ACCESS	
::inisharev | 'varshare --
|WIN|	$F001F 0 pick2 24 + OpenFileMappingA 0? ( drop createmapv ) dup pick2 8 + !
|WIN|	$f001F 0 0 pick4 16 + @ MapViewOfFile swap !
	
|LIN|	dup 24 + $2 $1b6 shm_open 32 << 32 >> -? ( drop createmapv ) over 8 + !
|LIN|	0 over 16 + @  $3 1 pick4 8 + @ 0 libc-mmap swap ! | $3 PROT_READ|PROT_WRITE
	;
	
::endSharev | 'varshare --
|WIN|	@+ UnmapViewOfFile swap @ CloseHandle

|LIN|	dup 8 + @+ swap @ libc-munmap 8 + @ libc-close
	;
