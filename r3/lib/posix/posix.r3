| linux system calls
| stdin : 0 
| stdout : 1
| stderr : 2

#sys-open
#sys-creat
#sys-close
#sys-read
#sys-write
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

::libc-open sys-open sys3 ;
::libc-creat sys-creat sys2 ;
::libc-close sys-close sys1 ;
::libc-read sys-read sys3 ;
::libc-write sys-write sys3 ;
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

:
	"/lib/libc.so.6" loadlib
	dup "open" getproc 'sys-open ! 
	dup "creat" getproc 'sys-creat ! 
	dup "close" getproc 'sys-close ! 
	dup "read" getproc 'sys-read ! 
	dup "write" getproc 'sys-write ! 
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
	drop 
    ;
