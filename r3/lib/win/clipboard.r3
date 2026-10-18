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
