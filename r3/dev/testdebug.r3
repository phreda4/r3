| WIN DEBUGGER
| PHREDA 2024
|
^r3/lib/console.r3
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

|DWORD dwContinueStatus = DBG_CONTINUE; // exception continuation 
|for(;;) { 
|// Wait for a debugging event to occur. The second parameter indicates
|// that the function does not return until a debugging event occurs. 
|      WaitForDebugEvent(DebugEv, INFINITE); 
|// Process the debugging event code. 
|      switch (DebugEv->dwDebugEventCode) { 
| case EXCEPTION_DEBUG_EVENT: 
|         // Process the exception code. When handling 
|         // exceptions, remember to set the continuation 
|         // status parameter (dwContinueStatus). This value 
|         // is used by the ContinueDebugEvent function. 
|      switch(DebugEv->u.Exception.ExceptionRecord.ExceptionCode) { 
|               case EXCEPTION_ACCESS_VIOLATION: 
|               // First chance: Pass this on to the system. 
|               // Last chance: Display an appropriate error. 
|                  break;
|               case EXCEPTION_BREAKPOINT: 
|               // First chance: Display the current 
|               // instruction and register values. 
|                  break;
|               case EXCEPTION_DATATYPE_MISALIGNMENT: 
|               // First chance: Pass this on to the system. 
|               // Last chance: Display an appropriate error. 
|                  break;
|               case EXCEPTION_SINGLE_STEP: 
|               // First chance: Update the display of the 
|               // current instruction and register values. 
|                  break;
|               case DBG_CONTROL_C: 
|               // First chance: Pass this on to the system. 
|               // Last chance: Display an appropriate error. 
|                  break;
|               default:
|               // Handle other exceptions. 
|                  break;
|            } 
|            break;
|  case CREATE_THREAD_DEBUG_EVENT: 
|         // As needed, examine or change the thread's registers 
|         // with the GetThreadContext and SetThreadContext functions; 
|         // and suspend and resume thread execution with the 
|         // SuspendThread and ResumeThread functions. 
|            dwContinueStatus = OnCreateThreadDebugEvent(DebugEv);break;
|  case CREATE_PROCESS_DEBUG_EVENT: 
|         // As needed, examine or change the registers of the
|         // process's initial thread with the GetThreadContext and
|         // SetThreadContext functions; read from and write to the
|         // process's virtual memory with the ReadProcessMemory and
|         // WriteProcessMemory functions; and suspend and resume
|         // thread execution with the SuspendThread and ResumeThread
|         // functions. Be sure to close the handle to the process image
|         // file with CloseHandle.
|            dwContinueStatus = OnCreateProcessDebugEvent(DebugEv);break;
|  case EXIT_THREAD_DEBUG_EVENT: 
|         // Display the thread's exit code. 
|            dwContinueStatus = OnExitThreadDebugEvent(DebugEv);break;
|  case EXIT_PROCESS_DEBUG_EVENT: 
|         // Display the process's exit code. 
|            dwContinueStatus = OnExitProcessDebugEvent(DebugEv);break;
|  case LOAD_DLL_DEBUG_EVENT: 
|         // Read the debugging information included in the newly 
|         // loaded DLL. Be sure to close the handle to the loaded DLL 
|         // with CloseHandle.
|            dwContinueStatus = OnLoadDllDebugEvent(DebugEv);break;
|  case UNLOAD_DLL_DEBUG_EVENT: 
|         // Display a message that the DLL has been unloaded. 
|            dwContinueStatus = OnUnloadDllDebugEvent(DebugEv);break;
|  case OUTPUT_DEBUG_STRING_EVENT: 
|         // Display the output debugging string. 
|            dwContinueStatus = OnOutputDebugStringEvent(DebugEv);break;
|  case RIP_EVENT:
|            dwContinueStatus = OnRipEvent(DebugEv);break;
|      } 
|  // Resume executing the thread that reported the debugging event. 
|   ContinueDebugEvent(DebugEv->dwProcessId, DebugEv->dwThreadId, dwContinueStatus);
|   }


:dbgexc
	'dbgevt 12 + d@
	$C0000005 =? ( "%h" .println ) |#define EXCEPTION_ACCESS_VIOLATION ((NTSTATUS)0xC0000005)
	$C00002C5 =? ( "%h" .println ) |#define EXCEPTION_DATATYPE_MISALIGNMENT ((NTSTATUS)0xC00002C5)
	$80000003 =? ( "%h" .println ) |#define EXCEPTION_BREAKPOINT ((NTSTATUS)0x80000003)
	$80000004 =? ( "%h" .println ) |#define EXCEPTION_SINGLE_STEP ((NTSTATUS)0x80000004)
	$40010005 =? ( "%h" .println ) |#define DBG_CONTROL_C ((NTSTATUS)0x40010005)
	"%h<<" .println
	;

:crethr 
	"CREATE_THREAD" .println
	; |#define CREATE_THREAD_DEBUG_EVENT 2
:crepro 
	"CREATE_PROCESS" .println
	; |#define CREATE_PROCESS_DEBUG_EVENT 3
:exithr 
	"EXIT_THREAD" .println
	; |#define EXIT_THREAD_DEBUG_EVENT 4
:exipro 
	"EXIT_PROCESS" .println
	; |#define EXIT_PROCESS_DEBUG_EVENT 5
:loadll 
	"LOAD_DLL" .println
	; |#define LOAD_DLL_DEBUG_EVENT 6
:unlodl 
	"UNLOAD_DLL" .println
	; |#define UNLOAD_DLL_DEBUG_EVENT 7
:outdeb 
	"OUTPUT_DEBUG" .println
	; |#define OUTPUT_DEBUG_STRING_EVENT 8
:ripeve 
	"RIP_EVENT" .println
	; |#define RIP_EVENT 9
 
:eventswitch | evt --
	1 =? ( drop dbgexc ; ) |#define EXCEPTION_DEBUG_EVENT 1
	2 =? ( drop crethr ; ) |#define CREATE_THREAD_DEBUG_EVENT 2
	3 =? ( drop crepro ; ) |#define CREATE_PROCESS_DEBUG_EVENT 3
	4 =? ( drop exithr ; ) |#define EXIT_THREAD_DEBUG_EVENT 4
	5 =? ( drop exipro ; ) |#define EXIT_PROCESS_DEBUG_EVENT 5
	6 =? ( drop loadll ; ) |#define LOAD_DLL_DEBUG_EVENT 6
	7 =? ( drop unlodl ; ) |#define UNLOAD_DLL_DEBUG_EVENT 7
	8 =? ( drop outdeb ; ) |#define OUTPUT_DEBUG_STRING_EVENT 8
	9 =? ( drop ripeve ; ) |#define RIP_EVENT 9
	">>%h" .println
	;
	
|DBG_CONTINUE $00010002
|DBG_EXCEPTION_NOT_HANDLED $80010001
|DBG_REPLY_LATER $40010001

#dbgstatus $00010002

|INFINITE 0xFFFFFFFF
:deevent
	inkey $1B1001 =? ( drop ; ) drop
	'dbgevt -1 WaitForDebugEvent 
	0? ( drop deevent ; ) drop
	'dbgevt d@ eventswitch
	'pinfo 16 + d@+ swap d@ $00010002 ContinueDebugEvent |(debug_event.dwProcessId,debug_event.dwThreadId,DBG_CONTINUE);
	deevent ;

:main
	.cls
	"Test debug" .println
	"r3fasm.exe" sysdebug
	deevent
	;
	
: main ;