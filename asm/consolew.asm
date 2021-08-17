format PE Console
entry start 

include 'win32a.inc' 
include 'api\kernel32.inc' 


inputHandle dd ?
outputHandler dd ?
title db 'Hola amigos',10,13,0
inputBuffer rb 256 
hasRead dd 0 
mustRead dd 1 

start: 
        stdcall [GetStdHandle], STD_INPUT_HANDLE 
        mov [inputHandle], eax 

       stdcall [GetStdHandle],  STD_OUTPUT_HANDLE
        mov [outputHandler], eax

        stdcall [WriteConsoleA],[outputHandler],title,13,0,0

        stdcall [ReadConsoleA], [inputHandle], inputBuffer, [mustRead], hasRead, NULL 
        stdcall [ExitProcess], 0 

data import 
 library kernel,'KERNEL32.DLL' 

 import kernel,\ 
        ExitProcess, 'ExitProcess',\ 
        GetStdHandle, 'GetStdHandle',\ 
        SetConsoleTitleA, 'SetConsoleTitleA',\ 
        ReadConsoleA,'ReadConsoleA',\ 
        WriteConsoleA, 'WriteConsoleA' 

end data