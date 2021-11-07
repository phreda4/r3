| INET  
| PHREDA 2021
|

#sys-internetopen  
#sys-InternetOpenUrl 
#sys-InternetReadFile 
#sys-InternetCloseHandle 

::InternetOpen sys-internetopen sys5 ;
::InternetOpenUrl sys-InternetOpenUrl sys6 ;
::InternetReadFile sys-InternetReadFile sys4 drop ;
::InternetCloseHandle sys-InternetCloseHandle sys1 drop ;

	
| R4 source code in C
|case OPENURL: // url header buff -- buff/0
|  buffData=(char*)TOS;
|  hOpen = InternetOpen("InetURL/1.0",INTERNET_OPEN_TYPE_DIRECT,NULL,NULL,0); //INTERNET_FLAG_ASYNC
|  hURL = InternetOpenUrl(hOpen,(char*)(*(NOS-1)),(char*)(*NOS),0,INTERNET_FLAG_RELOAD,0);
|  NOS-=2;
|  do {
|    InternetReadFile(hURL,buffData,2048,&readData);
|    buffData+=readData;
|  } while (readData!=0);
|  InternetCloseHandle(hURL);
|  InternetCloseHandle(hOpen);
|  TOS=(int)buffData;
|  continue;   

#cnt
		 
::openurl | url header buff -- buff 
	>r "InetURL/1.0" 1 0 0 0 InternetOpen  | url head hopen |1 0 0 0=direct
	dup >r rot rot 0 $80000000 0 InternetOpenUrl | hopen
	r> swap r>
	( 2dup 8192 'cnt InternetReadFile cnt + cnt 1? drop ) drop
	swap InternetCloseHandle
	swap InternetCloseHandle ;
	
|--------- BOOT	
: 
	"WININET.DLL" loadlib 
	dup "InternetOpenA" getproc 'sys-internetopen !
	dup "InternetOpenUrlA" getproc 'sys-InternetOpenUrl !
	dup "InternetReadFile" getproc 'sys-InternetReadFile !
	dup "InternetCloseHandle" getproc 'sys-InternetCloseHandle !
	
	drop ;
	