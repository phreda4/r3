| windows clipboard
| PHREDA 2026
^r3/lib/win/kernel32.r3
^r3/lib/str.r3

#s-OpenClipboard
#s-CloseClipboard
#s-EmptyClipboard
#s-IsClipboardFormatAvailable
#s-GetClipboardData
#s-SetClipboardData

::OpenClipboard		s-OpenClipboard sys1 ;
::CloseClipboard	s-CloseClipboard sys0 drop ;
::EmptyClipboard	s-EmptyClipboard sys0 drop ;
::IsClipboardFormatAvailable	s-IsClipboardFormatAvailable sys1 ;
::GetClipboardData	s-GetClipboardData sys1 ;
::SetClipboardData	s-SetClipboardData sys2 drop ;

#CF_TEXT		1
#GMEM_MOVEABLE	2

::copyclipboard | 'mem cnt -- 
	0 OpenClipboard 0? ( 3drop ; ) drop
	EmptyClipboard
	GMEM_MOVEABLE over GlobalAlloc | 'mem cnt alloc
	dup GlobalLock | 'mem cnt alloc mlock
	dup >r 2swap 1+ cmove | dsc
	r@ GlobalUnlock 
	CF_TEXT r> SetClipboardData drop
	|r> GlobalFree
	CloseClipboard ;

::pasteclipboard | 'mem -- 
	0 OpenClipboard 0? ( 2drop ; ) drop
	CF_TEXT IsClipboardFormatAvailable 0? ( 2drop CloseClipboard ; ) drop
	CF_TEXT GetClipboardData	| 'mem hdata
	dup GlobalLock	| 'mem hdata ptext
	rot strcpyl 0 swap c!
	GlobalUnlock
	CloseClipboard 
	;
	
|------- BOOT
:
	"USER32.DLL" loadlib 
	dup "OpenClipboard" getproc 's-OpenClipboard !
	dup "CloseClipboard" getproc 's-CloseClipboard !
	dup "EmptyClipboard" getproc 's-EmptyClipboard !	
	dup "IsClipboardFormatAvailable" getproc 's-IsClipboardFormatAvailable !
	dup "GetClipboardData" getproc 's-GetClipboardData !
	dup "SetClipboardData" getproc 's-SetClipboardData !
	drop
	;
