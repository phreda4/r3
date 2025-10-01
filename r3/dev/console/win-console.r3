| console words windows
| PHREDA 2021 - Updated 2025

^r3/lib/mem.r3
^r3/lib/str.r3
^r3/lib/win/conkey.r3

|------- Console Handles -------
##stdin 
##stdout
##stderr

|------- Basic Output -------
::type | str cnt --
    stdout -rot 0 0 WriteFile drop ;

|------- Console Information -------
| CONSOLE_SCREEN_BUFFER_INFO structure:
|   COORD      dwSize; (16.16)
|   COORD      dwCursorPosition;(16.16)
|   WORD       wAttributes;16
|   SMALL_RECT srWindow;16.16.16.16
|   COORD      dwMaximumWindowSize;16.16

#consoleinfo 0 0 0
##rows ##cols
#prevrc 0

::.getconsoleinfo | --
    stdout 'consoleinfo GetConsoleScreenBufferInfo drop 
    'consoleinfo 10 + @
    dup 32 >> $ffff and over $ffff and - 'cols !
    dup 48 >> $ffff and swap 16 >> $ffff and - 'rows ! ;

:.getrc rows 16 << cols or ;

|------- Resize Detection -------
#on-resize 0 | callback address

:.checksize | --
	on-resize 0? ( drop ; ) 
	.getconsoleinfo
	.getrc prevrc =? ( 2drop ; ) 'prevrc !
    ex ; 

::.onresize | 'callback --
    'on-resize ! ;

|------- Keyboard Input -------
| Windows Console Input Format
| Key code format: $ccp0ss
|   ss = scancode
|   cc0000 = character code
|   p000 = press(0) release(1)
| Example: $1B1001 = ESC key release

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

#eventBuffer 0 0 0 0 0
#ne | number of events
#nr | number read

:igetkey | -- key
    'eventBuffer 8 + @ 32 >> $1000 or 
    eventBuffer 20 >> xor ;

::getch | -- key | wait for key
    ( stdin 'eventBuffer 1 'nr ReadConsoleInput
      eventBuffer $ff and
      1 =? ( drop igetkey ; )
      4 =? ( drop .checksize 0 ; ) | WINDOW_BUFFER_SIZE_EVENT
      drop
    ) ;

::inkey | -- key | 0 if no key pressed
    stdin 'ne GetNumberOfConsoleInputEvents 
    ne 0? ( ; ) drop
    stdin 'eventBuffer 1 'nr ReadConsoleInput 
    eventBuffer $ff and
    1 =? ( drop igetkey ; )
    4 =? ( drop .checksize 0 ; ) | WINDOW_BUFFER_SIZE_EVENT
    drop 0 ;

|------- Extended Event Handling -------
::evtkey | -- key
    igetkey ;

| MOUSE_EVENT_RECORD:
|   COORD dwMousePosition;  | 2
|   DWORD dwButtonState;    | 6
|   DWORD dwControlKeyState;| 10
|   DWORD dwEventFlags;     | 14

::evtmxy | -- x y | mouse position
    'eventBuffer 4 + w@+ 1+ swap w@ 1+ ;

::evtmb | -- buttons | mouse button state
    'eventBuffer 8 + d@ ;

::evtmw | -- wheel | mouse wheel delta
    'eventBuffer 8 + d@ 23 >> 1 or ;

::evtm | -- event | mouse event type
    'eventBuffer 16 + d@ ;

| Mouse event flags:
| MOUSE_MOVED 0x0001
| DOUBLE_CLICK 0x0002    
| MOUSE_WHEELED 0x0004
| MOUSE_HWHEELED 0x0008

::getevt | -- type | wait for any event
    stdin 'eventBuffer 1 'nr ReadConsoleInput 
    eventBuffer $ff and
    4 =? ( .checksize ) | Handle resize event
    ;

::inevt | -- type | check for event (no wait)
    stdin 'ne GetNumberOfConsoleInputEvents 
    ne 0? ( ; ) drop
    stdin 'eventBuffer 1 'nr ReadConsoleInput
    eventBuffer $ff and
    4 =? ( .checksize ) | Handle resize event
    ;

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

::evtmouse | -- | enable mouse input
    stdin $18 SetConsoleMode drop ;

::.enable-mouse | -- | enable mouse events
    | ENABLE_EXTENDED_FLAGS (0x80) allows disabling QUICK_EDIT_MODE
    | ENABLE_WINDOW_INPUT (0x08) + ENABLE_MOUSE_INPUT (0x10)
    | ENABLE_VIRTUAL_TERMINAL_INPUT (0x200)
    | Total: 0x80 | 0x08 | 0x10 | 0x200 = 0x298
    stdin $298 SetConsoleMode drop ;

::.disable-mouse | -- | disable mouse events and restore selection
    | Re-enable QUICK_EDIT_MODE for normal console behavior
    stdin $1F7 SetConsoleMode drop ;

|------- Cleanup -------
::.free | -- | free console
    FreeConsole ;

|------- Initialization -------
::.console
	AllocConsole 
	-10 GetStdHandle 'stdin ! | STD_INPUT_HANDLE
    -11 GetStdHandle 'stdout ! | STD_OUTPUT_HANDLE
    -12 GetStdHandle 'stderr ! | STD_ERROR_HANDLE

    | Enable UTF-8 code page (65001)
    65001 SetConsoleOutputCP  | Output UTF-8
    65001 SetConsoleCP | Input UTF-8
    
    | Set console modes for ANSI/VT sequences and window events
    stdin $18 SetConsoleMode drop | Enable WINDOW_INPUT
    stdout $7 SetConsoleMode drop
    
    .getconsoleinfo
    .getrc 'prevrc ! 
	;
