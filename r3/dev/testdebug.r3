^r3/win/console.r3
^r3/win/debugapi.r3

#proc

#dbgevt 0 0 0 0

|DBG_CONTINUE $00010002
|DBG_EXCEPTION_NOT_HANDLED $80010001
|DBG_REPLY_LATER $40010001
:deevent
	"event..." .println
	
	'dbgevt 100 WaitForDebugEvent | ms
	"%d)" .print
	
	|'dbgevt ProcessDebugEvent |ProcessDebugEvent(&debug_event);  // User-defined function, not API
    |'dbgevt 4 + d@+ swap d@ swap 
	'pinfo @+ swap @ swap
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
	"r3fasm.exe" sysdebug "%d=1" .println
	'pinfo 
	@+ "%h" .println
	@+ "%h" .println
	@ "%h" .println
	|'pinfo 8 + @ ResumeThread "%d=1" .println

	deevent
	.input ;
:
main
;