| INET  
| PHREDA 2021
|

|hOpen = InternetOpen("InetURL/1.0",INTERNET_OPEN_TYPE_DIRECT,NULL,NULL,0); //INTERNET_FLAG_ASYNC
|hURL = InternetOpenUrl(hOpen,(char*)(*(NOS-1)),(char*)(*NOS),0,INTERNET_FLAG_RELOAD,0);
|NOS-=2;
| do { InternetReadFile(hURL,buffData,2048,&readData);
|   buffData+=readData; } while (readData!=0);
| InternetCloseHandle(hURL); InternetCloseHandle(hOpen);

#sys-internetopen  
#sys-InternetOpenUrl 
#sys-InternetReadFile 
#sys-InternetCloseHandle 

::InternetOpen sys-internetopen  sys5 ;
::InternetOpenUrl sys-InternetOpenUrl sys6 ;
::InternetReadFile sys-InternetReadFile sys4 drop ;
::InternetCloseHandle sys-InternetCloseHandle sys1 drop ;

::wininet
	"WININET.DLL" loadlib 
	dup "InternetOpen" getproc 'sys-internetopen !
	dup "InternetOpenUrl" getproc 'sys-InternetOpenUrl !
	dup "InternetReadFile" getproc 'sys-InternetReadFile !
	dup "InternetCloseHandle" getproc 'sys-InternetCloseHandle !
	
	drop ;
	