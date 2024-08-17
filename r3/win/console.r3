| console words
| PHREDA 2021

^r3/win/core.r3
^r3/lib/mem.r3
^r3/lib/parse.r3

##stdin 
##stdout
##stderr

::type | str cnt --
	stdout -rot 0 0 WriteFile drop ;

|-----------------------------------------------	
#crb ( 10 13 0 0 )
#esc[ ( $1b $5b 0 0 0 0 0 0 0 0 0 0 )

::.cr 'crb 2 type ;
::.sp " " 1 type ;
::.nsp ( 1? 1 - .sp ) drop ;

::.emit | nro
	" " dup rot swap c! 1 type ;
	
::.[ 'esc[ 2 + swap
	( c@+ 1? rot c!+ swap ) 2drop
	'esc[ swap over - type ;

::.write count type ;
	
::.print sprintc type ;

::.println sprintlnc type ;

::.home	"H" .[ ; | home
::.cls "H" .[ "J" .[ ; | cls 
::.at "%d;%df" sprint .[ ; | x y -- 
::.eline "K" .[ ; | erase line from cursor

::.fc "38;5;%dm" sprint .[ ; | Set foreground color.
::.bc  "48;5;%dm" sprint .[ ; 

::.Black "30m" .[ ;
::.Red "31m" .[ ;
::.Green "32m" .[ ;
::.Yellow "33m" .[ ;
::.Blue "34m" .[ ;
::.Magenta "35m" .[ ;
::.Cyan "36m" .[ ;
::.White "37m" .[ ;
::.Blackl "30;1m" .[ ;
::.Redl "31;1m" .[ ;
::.Greenl "32;1m" .[ ;
::.Yellowl "33;1m" .[ ;
::.Bluel "34;1m" .[ ;
::.Magental "35;1m" .[ ;
::.Cyanl "36;1m" .[ ;
::.Whitel "37;1m" .[ ;
	
::.BBlack "40m" .[ ;
::.BRed "41m" .[ ;
::.BGreen "42m" .[ ;
::.BYellow "43m" .[ ;
::.BBlue "44m" .[ ;
::.BMagenta "45m" .[ ;
::.BCyan "46m" .[ ;
::.BWhite "47m" .[ ;
::.BBlackl "40;1m" .[ ;
::.BRedl "41;1m" .[ ;
::.BGreenl "42;1m" .[ ;
::.BYellowl "43;1m" .[ ;
::.BBluel "44;1m" .[ ;
::.BMagental "45;1m" .[ ;
::.BCyanl "46;1m" .[ ;
::.BWhitel "47;1m" .[ ;

::.Bold "1m" .[ ;
::.Under "4m" .[ ;
::.Rever "7m" .[ ;
::.Reset "0m" .[ ;

::.alsb	"?1049h" .[ ; | alternate screen buffer
::.masb "?1049l" .[ ; | main screen buffer

::.showc "?25h" .[ ;
::.hidec "?25l" .[ ;
::.ovec "0 q" .[ ;
::.insc "5 q" .[ ;

|-------- console

|  COORD      dwSize; (16.16)
|  COORD      dwCursorPosition;(16.16)
|  WORD       wAttributes;16
|  SMALL_RECT srWindow;16.16.16.16
|  COORD      dwMaximumWindowSize;16.16

##consoleinfo 0 0 0
##rows 
##cols

::.getconsoleinfo 
	stdout 'consoleinfo GetConsoleScreenBufferInfo drop 
	'consoleinfo 
	10 + @
	dup 32 >> $ffff and over $ffff and - 'cols !
	dup 48 >> $ffff and swap 16 >> $ffff and - 'rows !
	;
	
|------- full console input (key,mouse,size,menu,focos)
|typedef struct _INPUT_RECORD {
|  WORD  EventType;
|  union {
|    KEY_EVENT_RECORD          KeyEvent;
|    MOUSE_EVENT_RECORD        MouseEvent;
|    WINDOW_BUFFER_SIZE_RECORD WindowBufferSizeEvent;
|    MENU_EVENT_RECORD         MenuEvent;
|    FOCUS_EVENT_RECORD        FocusEvent;

|typedef struct _KEY_EVENT_RECORD {
|  BOOL  bKeyDown; 		| WORD |2
|  WORD  wRepeatCount;	|	4
|  WORD  wVirtualKeyCode; WORD  wVirtualScanCode; |8 12
|  union {
|    WCHAR UnicodeChar; CHAR  AsciiChar; |14 
|  } uChar;
|  DWORD dwControlKeyState;

|typedef struct _COORD { |  SHORT X; |  SHORT Y;

|typedef struct _MOUSE_EVENT_RECORD {
|  COORD dwMousePosition;	| 2
|  DWORD dwButtonState;		| 6
|  DWORD dwControlKeyState;
|  DWORD dwEventFlags;

|typedef struct _WINDOW_BUFFER_SIZE_RECORD {
|  COORD dwSize;

|typedef struct _MENU_EVENT_RECORD {
|  UINT dwCommandId;

|typedef struct _FOCUS_EVENT_RECORD {
|  BOOL bSetFocus;

#eventBuffer 0 0 0 0 0
#ne | cnt event
#nr | cnt event

|--- format key =  $ccp0ss
|    scancode			    ss
|    char				cc0000
|    press(0) release(1)  p000
|   
| ej: $1B1001 = release esc

:igetkey
	'eventBuffer 8 + @ 32 >> $1000 or eventBuffer 20 >> xor ;
	
::getch | -- key | wait key
	stdin 'eventBuffer 1 'nr ReadConsoleInput 
	igetkey ;

::inkey	| -- key | no wait key
	stdin 'ne GetNumberOfConsoleInputEvents
	ne 0? ( ; ) drop
	stdin 'eventBuffer 1 'nr ReadConsoleInput |(rHnd, eventBuffer, numEvents, &numEventsRead);
	eventBuffer $ff and
	1 =? ( drop igetkey ; )
	drop 0 ;

::waitesc
	( getch $1B1001 <>? drop ) drop ;

|---------------------	
::evtkey | -- key
	|'eventBuffer 14 + w@ 
	igetkey
	;

::evtmxy | -- x y 
	'eventBuffer 4 + w@+ swap w@ ;
	
::evtmb | -- b
	'eventBuffer 8 + d@ ;
	
::getevt | -- typevent | wait event
	stdin 'eventBuffer 1 'nr ReadConsoleInput |(rHnd, eventBuffer, numEvents, &numEventsRead);
	eventBuffer $ff and
|	$1 =? ( evkey )
|	$2 =? ( evmouse )
|	$4 =? ( evsize )
|	$8 =? ( evmenu )
|	$10 =? ( evfocus )
|	drop
	;
	
::inevt | -- typevent | no wait event
	stdin 'ne GetNumberOfConsoleInputEvents
	ne 0? ( ; ) drop
	stdin 'eventBuffer 1 'nr ReadConsoleInput |(rHnd, eventBuffer, numEvents, &numEventsRead);
	eventBuffer $ff and ;

##pad * 256

:ink
	$1000 and? ( drop ; ) | upkey
|	$ff0000 nand? ( drop ; ) 
	16 >> $ff and swap c!+ ;
	
:.readln
	'pad ( inkey 1? ink ) swap c! ;

::getcursorpos | -- x y 
	"6n" .[ .readln 'pad 2 + | get cursor position
	str>nro swap 1 + str>nro nip swap ;

:.char
	$1000 and? ( drop ; )
	16 >> 0? ( drop ; )
	8 =? ( swap 
		1 - 'pad <? ( 2drop 'pad ; )
		swap .emit "1P" .[ ; )
	dup .emit
	swap c!+ ;
	
::.input | --
	'pad 
	( getch $D001C <>? 
		.char ) drop
	0 swap c! ;

::.inputn | -- nro
	.input 'pad str>nro nip ;

:emite | char --
	$5e =? ( drop 27 .emit ; ) | ^=escape
	.emit ;
	
::.printe | "" --
	sprint
	( c@+ 1? emite ) 2drop ;

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

::evtmouse
	stdin $18 SetConsoleMode drop ; 
|	stdin $1f7 SetConsoleMode drop | don't work mouse event, show select
	
::.free
	FreeConsole ;
	
:
	AllocConsole 
	-10 GetStdHandle 'stdin ! | STD_INPUT_HANDLE
	-11 GetStdHandle 'stdout ! | STD_OUTPUT_HANDLE
	-12 GetStdHandle 'stderr ! | STD_ERROR_HANDLE
	
	stdin 0 SetConsoleMode drop 
	stdout $7 SetConsoleMode drop	
	; 
	
