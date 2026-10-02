| clipboard in linux - need xclip instaled
| sudo apt install xclip
| PHREDA 2026

^r3/lib/posix/posix.r3

::copyclipboard | 'mem cnt -- ; escribe cnt bytes exactos
	"xclip -selection clipboard -i" "w" libc-popen 0? ( 3drop ; )
	>r 1 swap r@ libc-fwrite drop
	r> libc-pclose ;
		
::pasteclipboard | 'mem -- ; deja cadena terminada en 0 (hasta 8191 bytes)
	"xclip -selection clipboard -o 2>/dev/null" "r" libc-popen
	0? ( drop 0 swap c! ; ) | 'mem pipe
	>r dup 1 8191 r@ libc-fread | 'mem n
	+ 0 swap c!
	r> libc-pclose ;
