^r3/win/console.r3
^r3/win/debugapi.r3

#proc

|typedef struct _DEBUG_EVENT {
|    DWORD dwDebugEventCode;
|    DWORD dwProcessId;
|    DWORD dwThreadId;
|    union {
|        EXCEPTION_DEBUG_INFO      Exception;
|        CREATE_THREAD_DEBUG_INFO  CreateThread;
|        CREATE_PROCESS_DEBUG_INFO CreateProcessInfo;
|        EXIT_THREAD_DEBUG_INFO    ExitThread;
|        EXIT_PROCESS_DEBUG_INFO   ExitProcess;
|        LOAD_DLL_DEBUG_INFO       LoadDll;
|        UNLOAD_DLL_DEBUG_INFO     UnloadDll;
|        OUTPUT_DEBUG_STRING_INFO  DebugString;
|        RIP_INFO                  RipInfo;
|    } u;
|} DEBUG_EVENT, *LPDEBUG_EVENT;

#dbgevt * 176 

|DBG_CONTINUE $00010002
|DBG_EXCEPTION_NOT_HANDLED $80010001
|DBG_REPLY_LATER $40010001
|INFINITE 0xFFFFFFFF
:deevent
	"event..." .println
	
	'dbgevt 1000 WaitForDebugEvent | ms
	"%d)" .println
	
	|'dbgevt ProcessDebugEvent |ProcessDebugEvent(&debug_event);  // User-defined function, not API
 
	'pinfo 16 + d@+ swap d@ 
	$00010002 
	ContinueDebugEvent |(debug_event.dwProcessId,debug_event.dwThreadId,DBG_CONTINUE);
	'dbgevt
	@+ "%h " .print
	@+ "%h " .print
	@+ "%h " .print
	@ "%h " .println
	deevent
	;
|ContinueDebugEvent
:main
	.cls
	"Test debug" .println
	"r3fasm.exe" 
	sysdebug "%d=1" .println
	'pinfo 
	@+ "%h " .print
	@+ "%h " .print
	d@+ "%h " .print
	d@+ "%h " .println
	drop
	|'pinfo 8 + @ ResumeThread "%d=1" .println

	deevent
	.input ;
:
main
;