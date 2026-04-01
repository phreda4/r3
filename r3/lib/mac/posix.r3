| linux system calls
| stdin : 0 
| stdout : 1
| stderr : 2

#sys-open
#sys-creat
#sys-close
#sys-read
#sys-write
#sys-fread
#sys-fwrite
#sys-lseek
#sys-exit
#sys-fork
#sys-wait
#sys-waitpid
#sys-mmap
#sys-munmap
#sys-unlink
#sys-rename
#sys-malloc
#sys-free
#sys-realloc
#sys-usleep
#sys-ftruncate 
#sys-fsync
#sys-mprotect
#sys-signal
#sys-chdir
#sys-mkdir
#sys-rmdir
#sys-getwd
#sys-opendir
#sys-closedir
#sys-readdir
#sys-dirfd
#sys-fstatat
#sys-clock_gettime 
#sys-fcntl 
#sys-time
#sys-localtime
#sys-tcgetattr
#sys-tcsetattr
#sys-system
#sys-select
#sys-ioctl
#sys-stat
#sys-access
#sys-setlocale

#sys-popen
#sys-pclose
#sys-fgets

#sys-socket
#sys-bind
#sys-listen
#sys-accept
#sys-connect
#sys-send
#sys-recv
#sys-setsockopt
#sys-inet_addr
#sys-htons
#sys-inet_aton
#sys-inet_ntoa
#sys-getaddrinfo
#sys-freeaddrinfo
#sys-gai_strerror
#sys-gethostbyname
#sys-gethostbyaddr
#sys-getprotobyname
#sys-getprotobynumber
#sys-getservbyname
#sys-getservbyport
#sys-gethostname

#sys-shm_open
#sys-shm_unlink
#sys-msync

::libc-open sys-open sys3 ;
::libc-creat sys-creat sys2 ;
::libc-close sys-close sys1 ;
::libc-read sys-read sys3 ;
::libc-write sys-write sys3 ;
::libc-fread sys-fread sys4 ;
::libc-fwrite sys-fwrite sys4 ;
::libc-lseek sys-lseek sys3 ;
::libc-exit sys-exit sys1 ;
::libc-fork sys-fork sys0 ;
::libc-wait sys-wait sys1 ;
::libc-waitpid sys-waitpid sys3 ;
::libc-mmap sys-mmap sys6 ;
::libc-munmap sys-munmap sys2 ;
::libc-unlink sys-unlink sys1 ;
::libc-rename sys-rename sys2 ;
::libc-malloc sys-malloc sys1 ;
::libc-free sys-free sys1 ;
::libc-realloc sys-realloc sys2 ;
::libc-usleep sys-usleep sys1 ;
::libc-ftruncate sys-ftruncate sys2 ;
::libc-fsync sys-fsync sys1 ;
::libc-mprotect sys-mprotect sys3 ;
::libc-signal sys-signal sys2 ;
::libc-chdir sys-chdir sys1 ;
::libc-mkdir sys-mkdir sys2 ;
::libc-rmdir sys-rmdir sys1 ;
::libc-getwd sys-getwd sys1 ;
::libc-opendir sys-opendir sys1 ;
::libc-closedir sys-closedir sys1 ;
::libc-readdir sys-readdir sys1 ;
::libc-dirfd sys-dirfd sys1 ;
::libc-fstatat sys-fstatat sys4 ;
::libc-clock_gettime sys-clock_gettime sys2 ;
::libc-fcntl sys-fcntl sys3 ;
::libc-time sys-time sys1 ;
::libc-localtime sys-localtime sys1 ;
::libc-tcgetattr sys-tcgetattr sys2 drop ;
::libc-tcsetattr sys-tcsetattr sys3 drop ;
::libc-system sys-system sys1 ;
::libc-select sys-select sys5 ;
::libc-ioctl sys-ioctl sys3 drop ;
::libc-stat sys-stat sys2 ;
::libc-access sys-access sys2 ;
::libc-setlocale sys-setlocale sys2 ;

::libc-popen sys-popen sys2 ;
::libc-pclose sys-pclose sys1 drop ;
::libc-fgets sys-fgets sys3 ;

::libc-socket sys-socket sys3 ;
::libc-bind sys-bind sys3 ;
::libc-listen sys-listen sys2 ;
::libc-accept sys-accept sys3 ;
::libc-connect sys-connect sys3 ;
::libc-send sys-send sys4 ;
::libc-recv sys-recv sys4 ;
::libc-setsockopt sys-setsockopt sys5 ;
::libc-inet_addr sys-inet_addr sys1 ;
::libc-htons sys-htons sys1 ;
::libc-inet_aton sys-inet_aton sys2 ;
::libc-inet_ntoa sys-inet_ntoa sys1 ;
::libc-getaddrinfo sys-getaddrinfo sys4 ;
::libc-freeaddrinfo sys-freeaddrinfo sys1 ;
::libc-gai_strerror sys-gai_strerror sys1 ;
::libc-gethostbyname sys-gethostbyname sys1 ;
::libc-gethostbyaddr sys-gethostbyaddr sys3 ;
::libc-getprotobyname sys-getprotobyname sys1 ;
::libc-getprotobynumber sys-getprotobynumber sys1 ;
::libc-getservbyname sys-getservbyname sys2 ;
::libc-getservbyport sys-getservbyport sys2 ;
::libc-gethostname sys-gethostname sys2 ;

::shm_open sys-shm_open sys3 ;
::shm_unlink sys-shm_unlink sys1 drop ;
::msync sys-msync sys3 drop ;

:
	"/lib/libc.so.6" loadlib
	dup "open" getproc 'sys-open ! 
	dup "creat" getproc 'sys-creat ! 
	dup "close" getproc 'sys-close ! 
	dup "read" getproc 'sys-read ! 
	dup "write" getproc 'sys-write ! 
	dup "fread" getproc 'sys-fread ! 
	dup "fwrite" getproc 'sys-fwrite ! 
	
	dup "lseek" getproc 'sys-lseek ! 
	dup "exit" getproc 'sys-exit ! 
	dup "fork" getproc 'sys-fork ! 
	dup "wait" getproc 'sys-wait ! 
	dup "waitpid" getproc 'sys-waitpid ! 
	dup "mmap" getproc 'sys-mmap ! 
	dup "munmap" getproc 'sys-munmap ! 
	dup "unlink" getproc 'sys-unlink ! 
	dup "rename" getproc 'sys-rename ! 
	dup "malloc" getproc 'sys-malloc ! 
	dup "free" getproc 'sys-free ! 
	dup "realloc" getproc 'sys-realloc ! 
	dup "usleep" getproc 'sys-usleep ! 
	
	dup "ftruncate" getproc 'sys-ftruncate !
	dup "fsync" getproc 'sys-fsync !
	dup "mprotect" getproc 'sys-mprotect !
	dup "signal" getproc 'sys-signal !

	dup "chdir" getproc 'sys-chdir !
	dup "mkdir" getproc 'sys-mkdir !
	dup "rmdir" getproc 'sys-rmdir !
	dup "getwd" getproc 'sys-getwd !
	dup "opendir" getproc 'sys-opendir !
	dup "closedir" getproc 'sys-closedir !
	dup "readdir" getproc 'sys-readdir !
	dup "fstatat" getproc 'sys-fstatat !
	dup "dirfd" getproc 'sys-dirfd !
	dup "clock_gettime" getproc 'sys-clock_gettime !
	dup "fcntl" getproc 'sys-fcntl ! 
	dup "time" getproc 'sys-time !
	dup "localtime" getproc 'sys-localtime !

	dup "tcgetattr" getproc 'sys-tcgetattr !
	dup "tcsetattr" getproc 'sys-tcsetattr !

	dup "system" getproc 'sys-system !
	dup "select" getproc 'sys-select !
	dup "ioctl" getproc 'sys-ioctl !
	dup "stat" getproc 'sys-stat !
	dup "access" getproc 'sys-access !
	dup "setlocale" getproc 'sys-setlocale !

	dup "popen" getproc 'sys-popen !
	dup "pclose" getproc 'sys-pclose !
	dup "fgets" getproc 'sys-fgets !
	
	dup "socket" getproc 'sys-socket !
	dup "bind" getproc 'sys-bind !
	dup "listen" getproc 'sys-listen !
	dup "accept" getproc 'sys-accept !
	dup "connect" getproc 'sys-connect !
	dup "send" getproc 'sys-send !
	dup "recv" getproc 'sys-recv !
	dup "setsockopt" getproc 'sys-setsockopt !
	dup "inet_addr" getproc 'sys-inet_addr !
	dup "htons" getproc 'sys-htons !
	dup "inet_aton" getproc 'sys-inet_aton !
	dup "inet_ntoa" getproc 'sys-inet_ntoa !
	dup "getaddrinfo" getproc 'sys-getaddrinfo !
	dup "freeaddrinfo" getproc 'sys-freeaddrinfo !
	dup "gai_strerror" getproc 'sys-gai_strerror !
	dup "gethostbyname" getproc 'sys-gethostbyname !
	dup "gethostbyaddr" getproc 'sys-gethostbyaddr !
	dup "getprotobyname" getproc 'sys-getprotobyname !
	dup "getprotobynumber" getproc 'sys-getprotobynumber !
	dup "getservbyname" getproc 'sys-getservbyname !
	dup "getservbyport" getproc 'sys-getservbyport !
	dup "gethostname" getproc 'sys-gethostname !	
	
	| librt.so.1 in old distro <<<<
	dup "shm_open" getproc 'sys-shm_open !
	dup "shm_unlink" getproc 'sys-shm_unlink !
	dup "msync" getproc 'sys-msync !
	drop 
    ;
