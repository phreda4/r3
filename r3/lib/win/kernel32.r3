| Kernel32.dll
| PHREDA 2021

#sys-AllocConsole
#sys-FreeConsole
#sys-ExitProcess 
#sys-GetStdHandle
#sys-SetStdHandle

#sys-ReadFile
#sys-WriteFile 
#sys-GetConsoleMode 
#sys-SetConsoleMode
#sys-SetConsoleTitle
#sys-PeekConsoleInput
#sys-PeekNamedPipe
#sys-ReadConsoleInput
#sys-WriteConsole
#sys-ReadConsole
#sys-WriteConsoleOutput
#sys-FlushConsoleInputBuffer
#sys-GetNumberOfConsoleInputEvents

#sys-Sleep
#sys-WaitForSingleObject 
#sys-GetLastError
#sys-CreateFile
#sys-CreateDirectory
#sys-CloseHandle
#sys-FlushFileBuffers
#sys-DeleteFile
#sys-RemoveDirectory
#sys-MoveFile
#sys-SetFilePointer
#sys-SetEndOfFile
#sys-GetFileAttributes
#sys-GetFileAttributesEx
#sys-GetFileSize
#sys-FileTimeToSystemTime
#sys-SystemTimeToTzSpecificLocalTime

#sys-GetProcessHeap
#sys-HeapAlloc
#sys-HeapFree
#sys-HeapReAlloc

#sys-GetTickCount
#sys-GetLocalTime
#sys-FindFirstFile
#sys-FindNextFile
#sys-FindClose
#sys-CreateProcess

#sys-GetConsoleScreenBufferInfo

#sys-SetConsoleScreenBufferSize
#sys-SetConsoleWindowInfo

#sys-GetCommandLine
#sys-GetConsoleWindow
|#sys-GetConsoleCursorInfo

#s-SetConsoleOutputCP 
#s-SetConsoleCP 

#sys-SetDllDirectory
#sys-SetCurrentDirectory
#sys-GetCurrentDirectory

	
::AllocConsole sys-allocconsole sys0 drop ;
::FreeConsole sys-freeconsole sys0 drop ;

::ExitProcess sys-ExitProcess sys1 ;
::GetStdHandle sys-GetStdHandle sys1 ;
::SetStdHandle sys-SetStdHandle sys2 drop ;

::ReadFile sys-ReadFile sys5 ;
::WriteFile sys-WriteFile sys5 ;
::GetConsoleMode sys-GetConsoleMode sys2 ;
::SetConsoleMode sys-SetConsoleMode sys2 ;
::SetConsoleTitle sys-SetConsoleTitle sys1 drop ;
::PeekConsoleInput sys-PeekConsoleInput sys4 drop ;
::PeekNamedPipe sys-PeekNamedPipe sys6 drop ;
::ReadConsoleInput sys-ReadConsoleInput sys4 drop ;
::WriteConsole sys-WriteConsole sys5 drop ;
::ReadConsole sys-ReadConsole sys5 drop ;
::WriteConsoleOutput sys-WriteConsoleOutput sys5 drop ;
::GetNumberOfConsoleInputEvents sys-GetNumberOfConsoleInputEvents sys2 drop ;

::FlushConsoleInputBuffer sys-FlushConsoleInputBuffer sys1 drop ;
::Sleep sys-Sleep sys1 drop ;
::WaitForSingleObject sys-WaitForSingleObject sys2 drop ;
::GetLastError sys-GetLastError sys0 ;
::CreateFile sys-CreateFile sys7 ;
::CreateDirectory sys-CreateDirectory sys2 ;
::CloseHandle sys-CloseHandle sys1 drop ;
::FlushFileBuffers sys-FlushFileBuffers sys1 ;
::DeleteFile sys-DeleteFile sys1 ;
::RemoveDirectory sys-RemoveDirectory sys1 ;
::MoveFile sys-MoveFile sys2 ;
::SetFilePointer sys-SetFilePointer sys4 ;
::SetEndOfFile sys-SetEndOfFile sys1 ;
::GetFileAttributes sys-GetFileAttributes sys1 ;
::GetFileAttributesEx sys-GetFileAttributesex sys3 ;
::GetFileSize sys-GetFileSize sys2 ;
::FileTimeToSystemTime sys-FileTimeToSystemTime sys2 drop ;
::SystemTimeToTzSpecificLocalTime sys-SystemTimeToTzSpecificLocalTime sys3 drop ;

::GetProcessHeap sys-GetProcessHeap sys0 ;
::HeapAlloc sys-HeapAlloc sys3 drop ;
::HeapFree sys-HeapFree sys3 drop ;
::HeapReAlloc sys-HeapReAlloc sys4 drop ;

::GetTickCount sys-GetTickCount sys0 ;
::GetLocalTime sys-GetLocalTime sys1 drop ;
::FindFirstFile sys-FindFirstFile sys2 ;
::FindNextFile sys-FindNextFile sys2 ;
::FindClose sys-FindClose sys1 drop ;
::CreateProcess sys-CreateProcess sys10 ;
::GetConsoleScreenBufferInfo sys-GetConsoleScreenBufferInfo sys2 ;

::SetConsoleScreenBufferSize sys-SetConsoleScreenBufferSize sys2 drop ;
::SetConsoleWindowInfo sys-SetConsoleWindowInfo sys3 drop ;

::GetCommandLine sys-GetCommandLine sys0 ;
::GetConsoleWindow sys-GetConsoleWindow sys0 ;
::SetDllDirectory sys-SetDllDirectory sys1 drop ;
::SetCurrentDirectory sys-SetCurrentDirectory sys1 drop ;
::GetCurrentDirectory sys-GetCurrentDirectory sys2 drop ;

::SetConsoleOutputCP s-SetConsoleOutputCP sys1 drop ;
::SetConsoleCP s-SetConsoleCP sys1 drop ;

|::GetConsoleCursorInfo sys-GetConsoleCursorInfo sys2 drop ;

|------- BOOT
:
	"KERNEL32.DLL" loadlib 
	dup "AllocConsole" getproc 'sys-AllocConsole !
	dup "FreeConsole" getproc 'sys-FreeConsole !
	dup "ExitProcess" getproc 'sys-ExitProcess ! 
	dup "GetStdHandle" getproc 'sys-GetStdHandle !
	dup "SetStdHandle" getproc 'sys-SetStdHandle !
	
	dup "ReadFile" getproc 'sys-ReadFile !
	dup "WriteFile" getproc 'sys-WriteFile !
	
	dup "GetConsoleMode" getproc 'sys-GetConsoleMode !
	dup "SetConsoleMode" getproc 'sys-SetConsoleMode !
	dup "SetConsoleTitleA" getproc 'sys-SetConsoleTitle !
	dup "PeekConsoleInputA" getproc 'sys-PeekConsoleInput !
	dup "PeekNamedPipe" getproc 'sys-PeekNamedPipe !
	dup "ReadConsoleInputA" getproc 'sys-ReadConsoleInput !
	dup "WriteConsole" getproc 'sys-WriteConsole !
	dup "ReadConsoleA" getproc 'sys-ReadConsole !
	dup "WriteConsoleOutputA" getproc 'sys-WriteConsoleOutput !
	dup "GetNumberOfConsoleInputEvents" getproc 'sys-GetNumberOfConsoleInputEvents !
	
	dup "FlushConsoleInputBuffer" getproc 'sys-FlushConsoleInputBuffer !
	dup "Sleep" getproc 'sys-Sleep !
	dup "WaitForSingleObject" getproc 'sys-WaitForSingleObject ! 
	dup "GetLastError" getproc 'sys-GetLastError ! 
	dup "CreateFileA" getproc 'sys-CreateFile ! 
	dup "CreateDirectoryA" getproc 'sys-CreateDirectory !
	dup "CloseHandle" getproc 'sys-CloseHandle !
	dup "FlushFileBuffers" getproc 'sys-FlushFileBuffers !
	dup "DeleteFileA" getproc 'sys-DeleteFile !
	dup "RemoveDirectoryA" getproc 'sys-RemoveDirectory !
	dup "MoveFileA" getproc 'sys-MoveFile !
	dup "SetFilePointer" getproc 'sys-SetFilePointer !
	dup "SetEndOfFile" getproc 'sys-SetEndOfFile !
	dup "GetFileAttributesA" getproc 'sys-GetFileAttributes !
	dup "GetFileAttributesExA" getproc 'sys-GetFileAttributesEx !
	dup "GetFileSize" getproc 'sys-GetFileSize !
	dup "FileTimeToSystemTime" getproc 'sys-FileTimeToSystemTime !
	dup "SystemTimeToTzSpecificLocalTime" getproc 'sys-SystemTimeToTzSpecificLocalTime !

	dup "GetProcessHeap" getproc 'sys-GetProcessHeap !
	dup "HeapAlloc" getproc 'sys-HeapAlloc !
	dup "HeapFree" getproc 'sys-HeapFree !
	dup "HeapReAlloc" getproc 'sys-HeapReAlloc !

	dup "GetLocalTime" getproc 'sys-GetLocalTime !
	dup "FindFirstFileA" getproc 'sys-FindFirstFile !
	dup "FindNextFileA" getproc 'sys-FindNextFile !
	dup "FindClose" getproc 'sys-FindClose !

	dup "CreateProcessA" getproc 'sys-CreateProcess	!
	dup "GetTickCount" getproc 'sys-GetTickCount !
	dup "GetConsoleScreenBufferInfo" getproc 'sys-GetConsoleScreenBufferInfo !
	dup "GetCommandLineA" getproc 'sys-GetCommandLine !
|	dup "GetConsoleCursorInfo" getproc 'sys-GetConsoleCursorInfo !
	dup "SetConsoleScreenBufferSize" getproc 'sys-SetConsoleScreenBufferSize !
	dup "SetConsoleWindowInfo" getproc 'sys-SetConsoleWindowInfo !
	
	dup "GetConsoleWindow" getproc 'sys-GetConsoleWindow !
	dup "SetDllDirectoryA" getproc 'sys-SetDllDirectory !
	dup "SetCurrentDirectory" getproc 'sys-SetCurrentDirectory !
	dup "GetCurrentDirectory" getproc 'sys-GetCurrentDirectory !

	dup "SetConsoleOutputCP" GETPROC 's-SetConsoleOutputCP !
	dup "SetConsoleCP" GETPROC 's-SetConsoleCP !

	drop
	;
	