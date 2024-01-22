| console test
^r3/win/console.r3

:loopc
	( getch $1B1001 <>? "%h" .println ) drop ;	

|IN
|ENABLE_ECHO_INPUT 0x0004
|ENABLE_INSERT_MODE 0x0020
|ENABLE_LINE_INPUT 0x0002
|ENABLE_MOUSE_INPUT 0x0010
|ENABLE_PROCESSED_INPUT 0x0001
|ENABLE_QUICK_EDIT_MODE 0x0040
|ENABLE_WINDOW_INPUT 0x0008
|ENABLE_VIRTUAL_TERMINAL_INPUT 0x0200
|OUT
|ENABLE_PROCESSED_OUTPUT 0x0001
|ENABLE_WRAP_AT_EOL_OUTPUT 0x0002
|ENABLE_VIRTUAL_TERMINAL_PROCESSING 0x0004
|DISABLE_NEWLINE_AUTO_RETURN 0x0008
|ENABLE_LVB_GRID_WORLDWIDE 0x0010

#console-mode
#consoleold

:.consolemode
	consoleold
	$1 and? ( "ENABLE_PROCESSED_OUTPUT" .println )
	$2 and? ( "ENABLE_WRAP_AT_EOL_OUTPUT" .println )
	$4 and? ( "ENABLE_VIRTUAL_TERMINAL_PROCESSING" .println )
	$8 and? ( "DISABLE_NEWLINE_AUTO_RETURN" .println )
	$10 and? ( "ENABLE_LVB_GRID_WORLDWIDE" .println )
	drop
	;
	
	
:
.cls
"get console mode" .println
|loope
|.input
|loopc
stdout 'consoleold GetConsoleMode 
.consolemode
.cr
consoleold $7 or 'consoleold !
stdout consoleold SetConsoleMode drop	
.consolemode
loopc
;