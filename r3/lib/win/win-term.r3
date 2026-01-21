| terminal words windows
| PHREDA 2021 - Updated 2025

^r3/lib/mem.r3
^r3/lib/parse.r3

|-------terminal Handles -------
##stdin 
##stdout
##stderr

|------- Basic Output -------
::type | str cnt --
    stdout -rot 0 0 WriteFile drop ;

##rows ##cols
#eventBuffer * 32
#ne | number of events
#prevrc 0

|------- Console Information -------
| CONSOLE_SCREEN_BUFFER_INFO structure:
|   COORD      dwSize; (16.16)
|   COORD      dwCursorPosition;(16.16)
|   WORD       wAttributes;16
|   SMALL_RECT srWindow;16.16.16.16
|   COORD      dwMaximumWindowSize;16.16
:getterminfo | --
    stdout 'eventBuffer GetConsoleScreenBufferInfo drop 
    'eventBuffer 10 + @
    dup 32 >> $ffff and over $ffff and - 'cols !
    dup 48 >> $ffff and swap 16 >> $ffff and - 'rows ! ;

#c1 ( $1b ) "[9999;9999H"
#c2 ( $1b ) "[6n"
:getterminfo2	| read size terminal with esc sequense
	'c1 count type 
	'c2 count type
	stdin 'eventBuffer 32 'ne 0 ReadConsole
	'eventBuffer 2 + 
	getnro 1- 'rows ! 1+ | Skip ;
	getnro 1- 'cols ! 
	drop ;

:getrc rows 16 << cols or ;

|------- Resize Detection -------
#on-resize 0 | callback address

::.onresize | 'callback --
    'on-resize ! ; | something the size is wrong at start

:sizecalc
	'eventBuffer 4 + w@+ 'cols ! w@ 'rows ! ;
	
:sizeex
	getrc prevrc =? ( drop ; ) 'prevrc ! 
	on-resize 0? ( drop ; ) ex ; 

|------- Keyboard Input -------
| INPUT_RECORD structure:
|   WORD  EventType; (1=key, 2=mouse, 4=size, 8=menu, 10=focus)
|   union of event data
| KEY_EVENT_RECORD:
|   BOOL  bKeyDown;        | WORD |2
|   WORD  wRepeatCount;    | 4
|   WORD  wVirtualKeyCode; | 8
|   WORD  wVirtualScanCode;| 12
|   WCHAR/CHAR UnicodeChar;| 14
|   DWORD dwControlKeyState;
::evtkey | -- key
	'eventBuffer dup 4 + c@ 0? ( nip ; ) drop
	14 + c@ $1b <>? ( ; ) 
	56 << ( 8 >> 
	    stdin 'ne GetNumberOfConsoleInputEvents 
		ne 1? drop
		stdin 'eventBuffer 1 'ne ReadConsoleInput
		'eventBuffer 14 + c@ 1? 56 << or ) drop
	( $ff nand? 8 >> ) ;

:getEvent
	stdin 'ne GetNumberOfConsoleInputEvents 
    ne 0? ( ; ) drop
    stdin 'eventBuffer 1 'ne ReadConsoleInput
    eventBuffer $ffff and ;
	
##evtmx ##evtmy
##evtmb
##evtmw
::evtmxy evtmx evtmy ;

| MOUSE_EVENT_RECORD:
|   COORD dwMousePosition;  | 2
|   DWORD dwButtonState;    | 6
|   DWORD dwControlKeyState;| 10
|   DWORD dwEventFlags;     | 14

| Mouse event flags:
| MOUSE_MOVED 0x0001
| DOUBLE_CLICK 0x0002    
| MOUSE_WHEELED 0x0004
| MOUSE_HWHEELED 0x0008

:evnmouse
	0 'evtmw !
	'eventBuffer 16 + c@ 
	1 =? ( drop 'eventBuffer 4 + w@+ 1+ 'evtmx !  w@ 1+ 'evtmy ! ; )
	4 =? ( drop 'eventBuffer 8 + d@ 23 >> 1 or 'evtmw ! ; )
	drop 'eventBuffer 8 + d@ 'evtmb ! ;

:evtsize
	( 4 =? ( sizecalc ) 
		getEvent 2 >? drop | collect
		) drop sizeex ;

::inevt | -- type | check for event (no wait)
	getEvent
    4 =? ( evtsize ; ) | Handle resize event
	2 >? ( drop inevt ; ) 
	2 =? ( evnmouse )
	;	

::getevt | -- type | wait for any event
	( inevt 0? drop 10 ms ) ;

::inkey | -- key | 0 if no key pressed
	inevt 1 =? ( drop evtkey ; ) drop 0 ;
	
|::getch | -- key | wait for key
|    ( inkey 0? drop 10 ms ) ;

|------- Console Mode Management -------
| Input Modes:
| ENABLE_ECHO_INPUT 0x0004
| ENABLE_INSERT_MODE 0x0020
| ENABLE_LINE_INPUT 0x0002
| ENABLE_MOUSE_INPUT 0x0010
| ENABLE_PROCESSED_INPUT 0x0001
| ENABLE_QUICK_EDIT_MODE 0x0040
| ENABLE_WINDOW_INPUT 0x0008
| ENABLE_VIRTUAL_TERMINAL_INPUT 0x0200

| Output Modes:
| ENABLE_PROCESSED_OUTPUT 0x0001
| ENABLE_WRAP_AT_EOL_OUTPUT 0x0002
| ENABLE_VIRTUAL_TERMINAL_PROCESSING 0x0004
| DISABLE_NEWLINE_AUTO_RETURN 0x0008
| ENABLE_LVB_GRID_WORLDWIDE 0x0010

|::.enable-mouse | -- | enable mouse events
    | ENABLE_EXTENDED_FLAGS (0x80) allows disabling QUICK_EDIT_MODE
    | ENABLE_WINDOW_INPUT (0x08) + ENABLE_MOUSE_INPUT (0x10)
    | ENABLE_VIRTUAL_TERMINAL_INPUT (0x200)
    | Total: 0x80 | 0x08 | 0x10 | 0x200 = 0x298
|::.disable-mouse | -- | disable mouse events and restore selection
    | Re-enable QUICK_EDIT_MODE for normal console behavior

|------- Cleanup -------
::.free | -- | free console
	stdin $7 SetConsoleMode drop 
	stdout $3 SetConsoleMode drop 
	FlushConsoleInputBuffer
    FreeConsole ;

|------- Initialization -------
::.reterm  | Set console modes for ANSI/VT sequences and window events
    stdin $298 SetConsoleMode drop | Enable WINDOW_INPUT
    stdout $7 SetConsoleMode drop ;
	
: |:.term
	AllocConsole 
	-10 GetStdHandle 'stdin ! | STD_INPUT_HANDLE
    -11 GetStdHandle 'stdout ! | STD_OUTPUT_HANDLE
    -12 GetStdHandle 'stderr ! | STD_ERROR_HANDLE
	stdin $7 SetConsoleMode drop 
	stdout $3 SetConsoleMode drop 
	getterminfo
	.reterm
|	getterminfo2
	getrc 'prevrc ! 
    | Enable UTF-8 code page (65001)
    65001 SetConsoleOutputCP  | Output UTF-8
    65001 SetConsoleCP | Input UTF-8
	;
