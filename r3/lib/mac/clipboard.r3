| clipboard in macOS - uses pbcopy / pbpaste (installed by default)
| PHREDA 2026

^r3/lib/mac/posix.r3

::copyclipboard | 'mem cnt -- 
	"pbcopy" "w" libc-popen
	0? ( 3drop ; )
	>r 1 swap r@ libc-fwrite drop	| fwrite(mem,1,cnt,pipe)
	r> libc-pclose ;
	
::pasteclipboard | 'mem --
	"pbpaste" "r" libc-popen
	0? ( 2drop ; ) | 'mem pipe
	>r dup 1 8191 r@ libc-fread | hasta 8k-1
	+ 0 swap c!			| 0 final
	r> libc-pclose ;
