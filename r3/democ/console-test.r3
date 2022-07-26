| console events in win
| PHREDA 2022
^r3/win/console.r3

|typedef struct _INPUT_RECORD {
|  WORD  EventType;
|  union {
|    KEY_EVENT_RECORD          KeyEvent;
|    MOUSE_EVENT_RECORD        MouseEvent;
|    WINDOW_BUFFER_SIZE_RECORD WindowBufferSizeEvent;
|    MENU_EVENT_RECORD         MenuEvent;
|    FOCUS_EVENT_RECORD        FocusEvent;
|  } Event;
|} INPUT_RECORD;


|typedef struct _MOUSE_EVENT_RECORD {
|  COORD dwMousePosition;
|  DWORD dwButtonState;
|  DWORD dwControlKeyState;
|  DWORD dwEventFlags;
|} MOUSE_EVENT_RECORD;

|typedef struct _KEY_EVENT_RECORD {
|  BOOL  bKeyDown;
|  WORD  wRepeatCount;
|  WORD  wVirtualKeyCode;
|  WORD  wVirtualScanCode;
|  union {
|    WCHAR UnicodeChar;
|    CHAR  AsciiChar;
|  } uChar;
|  DWORD dwControlKeyState;
|} KEY_EVENT_RECORD;

#ne
#nr

##cevent 0
#codekey 0 0 0

#conkey
#conmouse

:evkey 
	codekey 32 >> $1000 or cevent 20 >> xor
	'conkey ! ;
:evmou 
	codekey 
	'conmouse ! ;
:evsiz 
:evmen 
:evfoc 
	;

:conevent
	0 'conkey !
	0 'conmouse !
	stdin 'ne GetNumberOfConsoleInputEvents
	ne 0? ( drop ; )
	( 1? 1 -
		stdin 'cevent 1 'nr ReadConsoleInput
		cevent $ff and
|		dup "%h " .print
		$1 =? ( evkey )
		$2 =? ( evmou )
		$4 =? ( evsiz )
		$8 =? ( evmen )
		$10 =? ( evfoc )
		drop
	) drop ;
	
:inkey	
	;
	
:inicio
	conevent
	( conevent conkey $1B1001 <>? drop
 "." .print	
		) drop

	;

: inicio ;
