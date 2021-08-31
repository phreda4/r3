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

::libc-open sys-open sys3 ;
::libc-creat" sys-creat sys2 ;
::libc-close" sys-close sys1 ;
::libc-read" sys-read sys3 ;
::libc-write" sys-write sys3 ;
::libc-lseek" sys-lseek sys3 ;
::libc-exit" sys-exit sys1 ;
::libc-fork" sys-fork sys0 ;
::libc-wait" sys-wait sys1 ;
::libc-waitpid" sys-waitpid sys3 ;
::libc-mmap" sys-mmap sys6 ;
::libc-munmap" sys-munmap sys2 ;
::libc-unlink" sys-unlink sys1 ;
::libc-rename" sys-rename sys2 ;
::libc-malloc" sys-malloc sys1 ;
::libc-free" sys-free sys1 ;
::libc-realloc" sys-realloc sys2 ;
::libc-usleep" sys-usleep sys1 ;

::posix
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
	
	drop ;
