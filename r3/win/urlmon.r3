| winhttp
| PHREDA 2022
|

#sys-URLDownloadToFile
#sys-URLOpenBlockingStreamA


::URLDownloadToFile sys-URLDownloadToFile dup "%h" .println sys5 ;
::URLOpenBlockingStreamA sys-URLOpenBlockingStreamA	sys5 ;



::url2file | url file -- 
	0 rot rot 0 0 URLDownloadToFile
	;
	
|--------- BOOT	
: 
	"URLMON.DLL" loadlib 
	dup "URLDownloadToFileA" getproc 'sys-URLDownloadToFile !
	dup "URLOpenBlockingStreamA" getproc 'sys-URLOpenBlockingStreamA !
	
	
	drop ;
	