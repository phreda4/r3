| winhttp
| PHREDA 2022
|
^r3/win/inet.r3
#sys-URLDownloadToFile
#sys-URLOpenBlockingStreamA


::URLDownloadToFile sys-URLDownloadToFile sys5 ;
::URLOpenBlockingStreamA sys-URLOpenBlockingStreamA	sys5 ;

::url2file | url file -- 
	over DeleteUrlCacheEntry
	0 -rot 0 0 URLDownloadToFile
	;

::url2filec | url file -- ; with cache
	0 -rot 0 0 URLDownloadToFile
	;
	
|--------- BOOT	
: 
	"URLMON.DLL" loadlib 
	dup "URLDownloadToFileA" getproc 'sys-URLDownloadToFile !
	dup "URLOpenBlockingStreamA" getproc 'sys-URLOpenBlockingStreamA !

	drop 
	;
	