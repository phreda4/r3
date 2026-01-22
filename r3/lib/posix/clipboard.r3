| clipboard in linux
| PHREDA 2026

^r3/lib/posix/posix.r3

::copyclipboard | 'mem cnt -- 
	"xclip -selection clipboard -i" "w" popen
	dup >r fwrite
	r> pclose ;
	
::pasteclipboard | 'mem --
	"xclip -selection clipboard -o 2>/dev/null" "r" popen
	0? ( 2drop ; ) | 'mem pipe
|	( over 256 pick2 fgets 1? drop | 'mem pipe 
|		swap count +
|		swap ) drop nip
	>r 1 8192 r@ fread
	r> pclose ;
	