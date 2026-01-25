| Kernel32.dll
| PHREDA 2021

#s-AllocConsole
#s-FreeConsole
#s-ExitProcess 
#s-GetStdHandle
#s-SetStdHandle

#s-ReadFile
#s-WriteFile 
#s-GetConsoleMode 
#s-SetConsoleMode
#s-SetConsoleTitle
#s-PeekConsoleInput
#s-PeekNamedPipe
#s-ReadConsoleInput
#s-WriteConsole
#s-ReadConsole
#s-WriteConsoleOutput
#s-FlushConsoleInputBuffer
#s-GetNumberOfConsoleInputEvents

#s-Sleep
#s-WaitForSingleObject 
#s-GetLastError
#s-CreateFile
#s-CreateDirectory
#s-CloseHandle
#s-FlushFileBuffers
#s-DeleteFile
#s-RemoveDirectory
#s-MoveFile
#s-SetFilePointer
#s-SetEndOfFile
#s-GetFileAttributes
#s-GetFileAttributesEx
#s-GetFileSize
#s-FileTimeToSystemTime
#s-SystemTimeToTzSpecificLocalTime

#s-GetProcessHeap
#s-HeapAlloc
#s-HeapFree
#s-HeapReAlloc

#s-GetTickCount
#s-GetLocalTime
#s-FindFirstFile
#s-FindNextFile
#s-FindClose
#s-CreateProcess

#s-GetConsoleScreenBufferInfo

#s-SetConsoleScreenBufferSize
#s-SetConsoleWindowInfo

#s-GetCommandLine
#s-GetConsoleWindow
|#s-GetConsoleCursorInfo

#s-SetConsoleOutputCP 
#s-SetConsoleCP 

#s-SetDllDirectory
#s-SetCurrentDirectory
#s-GetCurrentDirectory

#s-GlobalAlloc
#s-GlobalLock
#s-GlobalUnlock
#s-GlobalFree

#s-OpenFileMappingA
#s-CreateFileMappingA
#s-MapViewOfFile
#s-UnmapViewOfFile

	
::AllocConsole s-allocconsole sys0 drop ;
::FreeConsole s-freeconsole sys0 drop ;

::ExitProcess s-ExitProcess sys1 ;
::GetStdHandle s-GetStdHandle sys1 ;
::SetStdHandle s-SetStdHandle sys2 drop ;

::ReadFile s-ReadFile sys5 ;
::WriteFile s-WriteFile sys5 ;
::GetConsoleMode s-GetConsoleMode sys2 ;
::SetConsoleMode s-SetConsoleMode sys2 ;
::SetConsoleTitle s-SetConsoleTitle sys1 drop ;
::PeekConsoleInput s-PeekConsoleInput sys4 drop ;
::PeekNamedPipe s-PeekNamedPipe sys6 drop ;
::ReadConsoleInput s-ReadConsoleInput sys4 drop ;
::WriteConsole s-WriteConsole sys5 drop ;
::ReadConsole s-ReadConsole sys5 drop ;
::WriteConsoleOutput s-WriteConsoleOutput sys5 drop ;
::GetNumberOfConsoleInputEvents s-GetNumberOfConsoleInputEvents sys2 drop ;

::FlushConsoleInputBuffer s-FlushConsoleInputBuffer sys1 drop ;
::Sleep s-Sleep sys1 drop ;
::WaitForSingleObject s-WaitForSingleObject sys2 drop ;
::GetLastError s-GetLastError sys0 ;
::CreateFile s-CreateFile sys7 ;
::CreateDirectory s-CreateDirectory sys2 ;
::CloseHandle s-CloseHandle sys1 drop ;
::FlushFileBuffers s-FlushFileBuffers sys1 ;
::DeleteFile s-DeleteFile sys1 ;
::RemoveDirectory s-RemoveDirectory sys1 ;
::MoveFile s-MoveFile sys2 ;
::SetFilePointer s-SetFilePointer sys4 ;
::SetEndOfFile s-SetEndOfFile sys1 ;
::GetFileAttributes s-GetFileAttributes sys1 ;
::GetFileAttributesEx s-GetFileAttributesex sys3 ;
::GetFileSize s-GetFileSize sys2 ;
::FileTimeToSystemTime s-FileTimeToSystemTime sys2 drop ;
::SystemTimeToTzSpecificLocalTime s-SystemTimeToTzSpecificLocalTime sys3 drop ;

::GetProcessHeap s-GetProcessHeap sys0 ;
::HeapAlloc s-HeapAlloc sys3 drop ;
::HeapFree s-HeapFree sys3 drop ;
::HeapReAlloc s-HeapReAlloc sys4 drop ;

::GetTickCount s-GetTickCount sys0 ;
::GetLocalTime s-GetLocalTime sys1 drop ;
::FindFirstFile s-FindFirstFile sys2 ;
::FindNextFile s-FindNextFile sys2 ;
::FindClose s-FindClose sys1 drop ;
::CreateProcess s-CreateProcess sys10 ;
::GetConsoleScreenBufferInfo s-GetConsoleScreenBufferInfo sys2 ;

::SetConsoleScreenBufferSize s-SetConsoleScreenBufferSize sys2 drop ;
::SetConsoleWindowInfo s-SetConsoleWindowInfo sys3 drop ;

::GetCommandLine s-GetCommandLine sys0 ;
::GetConsoleWindow s-GetConsoleWindow sys0 ;
::SetDllDirectory s-SetDllDirectory sys1 drop ;
::SetCurrentDirectory s-SetCurrentDirectory sys1 drop ;
::GetCurrentDirectory s-GetCurrentDirectory sys2 drop ;

::SetConsoleOutputCP s-SetConsoleOutputCP sys1 drop ;
::SetConsoleCP s-SetConsoleCP sys1 drop ;

|::GetConsoleCursorInfo s-GetConsoleCursorInfo sys2 drop ;

::GlobalAlloc s-GlobalAlloc sys2 ; |(UINT uFlags, SIZE_T dwBytes)
::GlobalLock s-GlobalLock sys1 ; |(HGLOBAL hMem)
::GlobalUnlock s-GlobalUnlock sys1 drop ; | (HGLOBAL hMem)
::GlobalFree s-GlobalFree sys1 drop ; |(HGLOBAL hMem)

::OpenFileMappingA s-OpenFileMappingA sys3 ;
::CreateFileMappingA s-CreateFileMappingA sys6 ;
::MapViewOfFile s-MapViewOfFile sys5 ;
::UnmapViewOfFile s-UnmapViewOfFile sys1 drop ;

|------- BOOT
:
	"KERNEL32.DLL" loadlib 
	dup "AllocConsole" getproc 's-AllocConsole !
	dup "FreeConsole" getproc 's-FreeConsole !
	dup "ExitProcess" getproc 's-ExitProcess ! 
	dup "GetStdHandle" getproc 's-GetStdHandle !
	dup "SetStdHandle" getproc 's-SetStdHandle !
	
	dup "ReadFile" getproc 's-ReadFile !
	dup "WriteFile" getproc 's-WriteFile !
	
	dup "GetConsoleMode" getproc 's-GetConsoleMode !
	dup "SetConsoleMode" getproc 's-SetConsoleMode !
	dup "SetConsoleTitleA" getproc 's-SetConsoleTitle !
	dup "PeekConsoleInputA" getproc 's-PeekConsoleInput !
	dup "PeekNamedPipe" getproc 's-PeekNamedPipe !
	dup "ReadConsoleInputA" getproc 's-ReadConsoleInput !
	dup "WriteConsole" getproc 's-WriteConsole !
	dup "ReadConsoleA" getproc 's-ReadConsole !
	dup "WriteConsoleOutputA" getproc 's-WriteConsoleOutput !
	dup "GetNumberOfConsoleInputEvents" getproc 's-GetNumberOfConsoleInputEvents !
	
	dup "FlushConsoleInputBuffer" getproc 's-FlushConsoleInputBuffer !
	dup "Sleep" getproc 's-Sleep !
	dup "WaitForSingleObject" getproc 's-WaitForSingleObject ! 
	dup "GetLastError" getproc 's-GetLastError ! 
	dup "CreateFileA" getproc 's-CreateFile ! 
	dup "CreateDirectoryA" getproc 's-CreateDirectory !
	dup "CloseHandle" getproc 's-CloseHandle !
	dup "FlushFileBuffers" getproc 's-FlushFileBuffers !
	dup "DeleteFileA" getproc 's-DeleteFile !
	dup "RemoveDirectoryA" getproc 's-RemoveDirectory !
	dup "MoveFileA" getproc 's-MoveFile !
	dup "SetFilePointer" getproc 's-SetFilePointer !
	dup "SetEndOfFile" getproc 's-SetEndOfFile !
	dup "GetFileAttributesA" getproc 's-GetFileAttributes !
	dup "GetFileAttributesExA" getproc 's-GetFileAttributesEx !
	dup "GetFileSize" getproc 's-GetFileSize !
	dup "FileTimeToSystemTime" getproc 's-FileTimeToSystemTime !
	dup "SystemTimeToTzSpecificLocalTime" getproc 's-SystemTimeToTzSpecificLocalTime !

	dup "GetProcessHeap" getproc 's-GetProcessHeap !
	dup "HeapAlloc" getproc 's-HeapAlloc !
	dup "HeapFree" getproc 's-HeapFree !
	dup "HeapReAlloc" getproc 's-HeapReAlloc !

	dup "GetLocalTime" getproc 's-GetLocalTime !
	dup "FindFirstFileA" getproc 's-FindFirstFile !
	dup "FindNextFileA" getproc 's-FindNextFile !
	dup "FindClose" getproc 's-FindClose !

	dup "CreateProcessA" getproc 's-CreateProcess	!
	dup "GetTickCount" getproc 's-GetTickCount !
	dup "GetConsoleScreenBufferInfo" getproc 's-GetConsoleScreenBufferInfo !
	dup "GetCommandLineA" getproc 's-GetCommandLine !
|	dup "GetConsoleCursorInfo" getproc 's-GetConsoleCursorInfo !
	dup "SetConsoleScreenBufferSize" getproc 's-SetConsoleScreenBufferSize !
	dup "SetConsoleWindowInfo" getproc 's-SetConsoleWindowInfo !
	
	dup "GetConsoleWindow" getproc 's-GetConsoleWindow !
	dup "SetDllDirectoryA" getproc 's-SetDllDirectory !
	dup "SetCurrentDirectory" getproc 's-SetCurrentDirectory !
	dup "GetCurrentDirectory" getproc 's-GetCurrentDirectory !

	dup "SetConsoleOutputCP" GETPROC 's-SetConsoleOutputCP !
	dup "SetConsoleCP" GETPROC 's-SetConsoleCP !

	dup "GlobalAlloc" getproc 's-GlobalAlloc !
	dup "GlobalLock" getproc 's-GlobalLock !
	dup "GlobalUnlock" getproc 's-GlobalUnlock !
	dup "GlobalFree" getproc 's-GlobalFree !

	dup "OpenFileMappingA" getproc 's-OpenFileMappingA !
	dup "CreateFileMappingA" getproc 's-CreateFileMappingA !
	dup "MapViewOfFile" getproc 's-MapViewOfFile !
	dup "UnmapViewOfFile" getproc 's-UnmapViewOfFile !

	drop
	;
	