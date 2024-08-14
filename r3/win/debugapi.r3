| debugapi.h 
| PHREDA 2024
^r3/win/core.r3

|  WINBOOL IsDebuggerPresent (VOID);
|  VOID OutputDebugStringA (LPCSTR lpOutputString);
|  VOID OutputDebugStringW (LPCWSTR lpOutputString);
|  VOID DebugBreak (VOID);
|  WINBOOL ContinueDebugEvent(DWORD dwProcessId,DWORD dwThreadId,DWORD dwContinueStatus);
|  WINBOOL WaitForDebugEvent(LPDEBUG_EVENT lpDebugEvent,DWORD dwMilliseconds);
|  WINBOOL DebugActiveProcess(DWORD dwProcessId);
|  WINBOOL DebugActiveProcessStop(DWORD dwProcessId);
|  WINBOOL CheckRemoteDebuggerPresent(HANDLE hProcess,PBOOL pbDebuggerPresent);

#sys-IsDebuggerPresent
#sys-OutputDebugStringA
#sys-OutputDebugStringW
#sys-DebugBreak
#sys-ContinueDebugEvent
#sys-WaitForDebugEvent
#sys-DebugActiveProcess
#sys-DebugActiveProcessStop
#sys-CheckRemoteDebuggerPresent  
  
|::checklib
|	'sys-IsDebuggerPresent ( 'sys-CheckRemoteDebuggerPresent <=? @+ "%h" .println ) drop ;

::IsDebuggerPresent sys-IsDebuggerPresent sys0 ;
::OutputDebugStringA sys-OutputDebugStringA sys1 drop ;
::OutputDebugStringW sys-OutputDebugStringW sys1 drop ;
::DebugBreak sys-DebugBreak sys0 drop ;
::ContinueDebugEvent sys-ContinueDebugEvent sys3 ;
::WaitForDebugEvent sys-WaitForDebugEvent sys2 ;
::DebugActiveProcess sys-DebugActiveProcess sys1 ;
::DebugActiveProcessStop sys-DebugActiveProcessStop sys1 ;
::CheckRemoteDebuggerPresent  sys-CheckRemoteDebuggerPresent sys2 ;
  
|typedef struct _DEBUG_EVENT {
|  DWORD dwDebugEventCode;
|  DWORD dwProcessId;
|  DWORD dwThreadId;
|  union {
|    EXCEPTION_DEBUG_INFO      Exception;
|    CREATE_THREAD_DEBUG_INFO  CreateThread;
|    CREATE_PROCESS_DEBUG_INFO CreateProcessInfo;
|    EXIT_THREAD_DEBUG_INFO    ExitThread;
|    EXIT_PROCESS_DEBUG_INFO   ExitProcess;
|    LOAD_DLL_DEBUG_INFO       LoadDll;
|    UNLOAD_DLL_DEBUG_INFO     UnloadDll;
|    OUTPUT_DEBUG_STRING_INFO  DebugString;
|    RIP_INFO                  RipInfo;
|  } u;
|} DEBUG_EVENT, *LPDEBUG_EVENT;  

:
	"KERNEL32.DLL" loadlib 
	dup "IsDebuggerPresent" getproc 'sys-IsDebuggerPresent ! 
	dup "OutputDebugStringA" getproc 'sys-OutputDebugStringA !
	dup "OutputDebugStringW" getproc 'sys-OutputDebugStringW !
	dup "DebugBreak" getproc 'sys-DebugBreak !
	dup "ContinueDebugEvent" getproc 'sys-ContinueDebugEvent !
	dup "WaitForDebugEvent" getproc 'sys-WaitForDebugEvent !
	dup "DebugActiveProcess" getproc 'sys-DebugActiveProcess !
	dup "DebugActiveProcessStop" getproc 'sys-DebugActiveProcessStop !
	dup "CheckRemoteDebuggerPresent" getproc 'sys-CheckRemoteDebuggerPresent !
	drop
	;