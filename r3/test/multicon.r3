| try to make 2 console
| for debugger

^r3/win/console.r3

#GENERIC_WRITE $40000000
#GENERIC_READ $80000000
#FILE_SHARE_READ $00000001
#FILE_SHARE_WRITE $00000002
#OPEN_EXISTING $00000003
#FILE_ATTRIBUTE_NORMAL $80
#ERROR_ACCESS_DENIED 5

#ATTACH_PARRENT -1

#hConOut

:typec | str cnt --
	hConOut rot rot 0 0 WriteFile drop ;
	
:iniConsole 
	AllocConsole	
	"CONOUT$" $c0000000 $3 0 $3 $80 0 CreateFile 'hConOut !
	hConOut -11 SetStdHandle
	
	;
	
|struct STARTUPINFO
|  cb		  dd ?,?
|  lpReserved	  dq ?
|  lpDesktop	  dq ?
|  lpTitle	  dq ?
|  dwX		  dd ?
|  dwY		  dd ?
|  dwXSize	  dd ?
|  dwYSize	  dd ?
|  dwXCountChars   dd ?
|  dwYCountChars   dd ?
|  dwFillAttribute dd ?
|  dwFlags	  dd ?
|  wShowWindow	  dw ?
|  cbReserved2	  dw ?,?,?
|  lpReserved2	  dq ?
|  hStdInput	  dq ?
|  hStdOutput	  dq ?
|  hStdError	  dq ?

#sinfo * 100

|struct PROCESS_INFORMATION
|  hProcess    dq ?
|  hThread     dq ?
|  dwProcessId dd ?
| dwThreadId  dd ?

#pinfo * 24
	
::newcon | "" --
	'sinfo 0 100 cfill
	68 'sinfo d!
	0 swap 0 0 1 $10 0 0 'sinfo 'pinfo CreateProcess drop
	;
		
:
.cls
"debug console" .println

|"cmd.exe" newcon

iniConsole
"console" 6 typec
"hola" .println

.input
;