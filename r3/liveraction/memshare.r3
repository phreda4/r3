| memory share
| PHREDA 2026
| 4kb for now

^r3/lib/mem.r3

#mapfilename "data.mem" |"mem/comlr.dat"
#mapfile
##memshare

|$F001F |FILE_MAP_ALL_ACCESS	
|4 | PAGE_READWRITE,

:createmap | 0 -- mapfile
	-1 0 4 0 4096 'mapfilename CreateFileMappingA 
	;
	
::iniShare | --
	$F001F 0 'mapfilename OpenFileMappingA 0? ( createmap ) 'mapfile !
	mapfile $f001F 0 0 4096 MapViewOfFile 'memshare !
	;
	
::endShare
	memshare UnmapViewOfFile
	mapfile CloseHandle
	;
