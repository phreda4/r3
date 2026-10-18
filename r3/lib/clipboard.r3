| clipboard
| PHREDA 2026
|WIN| ^r3/lib/win/clipboard.r3
|LIN| ^r3/lib/posix/posix.r3
|MAC| ^r3/lib/mac/clipboard.r3


#CF_TEXT		1
#GMEM_MOVEABLE	2

::copyclipboard | 'mem cnt -- 
|WIN|	0 OpenClipboard 0? ( 3drop ; ) drop
|WIN|	EmptyClipboard
|WIN|	GMEM_MOVEABLE over 1+ GlobalAlloc | 'mem cnt alloc
|WIN|	dup GlobalLock | 'mem cnt alloc mlock
|WIN|	dup >r 2swap 1+ cmove | dsc
|WIN|	r@ GlobalUnlock 
|WIN|	CF_TEXT r> SetClipboardData |drop
|WIN|	CloseClipboard

|LIN| 	"xclip -selection clipboard -i" "w" libc-popen 0? ( 3drop ; )
|LIN| 	>r 1 swap r@ libc-fwrite drop
|LIN| 	r> libc-pclose 
	;
		
::pasteclipboard | 'mem -- 
|WIN|	0 OpenClipboard 0? ( 2drop ; ) drop
|WIN|	CF_TEXT IsClipboardFormatAvailable 0? ( 2drop CloseClipboard ; ) drop
|WIN|	CF_TEXT GetClipboardData	| 'mem hdata
|WIN|	dup GlobalLock	| 'mem hdata ptext
|WIN|	rot strcpyl 0 swap c!
|WIN|	GlobalUnlock CloseClipboard 

|LIN| 	"xclip -selection clipboard -o 2>/dev/null" "r" libc-popen
|LIN| 	0? ( drop 0 swap c! ; ) | 'mem pipe
|LIN| 	>r dup 1 8191 r@ libc-fread | 'mem n
|LIN| 	+ 0 swap c!
|LIN| 	r> libc-pclose 
	;


