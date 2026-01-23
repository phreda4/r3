| clipboard in linux - need xclip instaled
| sudo apt install xclip
| PHREDA 2026

^r3/lib/posix/posix.r3

::copyclipboard | 'mem cnt -- 
	"xclip -selection clipboard -i" "w" libc-popen
	dup >r libc-fwrite
	r> libc-pclose ;
	
::pasteclipboard | 'mem --
	"xclip -selection clipboard -o 2>/dev/null" "r" libc-popen
	0? ( 2drop ; ) | 'mem pipe
	>r 1 8192 r@ libc-fread | hasta 8k
	r> libc-pclose ;
