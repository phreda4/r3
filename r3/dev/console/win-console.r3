| console words windows - Enhanced and Consistent
| PHREDA 2021 - Updated 2025

^r3/lib/mem.r3
^r3/lib/parse.r3
^r3/lib/win/conkey.r3

|------- Console Handles -------
##stdin 
##stdout
##stderr

|------- Basic Output -------
::type | str cnt --
    stdout -rot 0 0 WriteFile drop ;

#crb ( 10 13 )
#cc ( 0 0 )
#esc[ ( $1b $5b 0 0 0 0 0 0 0 0 0 0 )

::.cr 'crb 2 type ;
::.sp " " 1 type ;
::.nsp ( 1? 1 - .sp ) drop ;

::.emit | char --
    'cc c! 'cc 1 type ;

::.[ 'esc[ 2 + swap
    ( c@+ 1? rot c!+ swap ) 2drop
    'esc[ swap over - type ;

::.write count type ;
::.print sprintc type ;
::.println sprintlnc type ;

|------- Cursor Control -------
::.home "H" .[ ;
::.cls "H" .[ "J" .[ ;
::.at "%d;%df" sprint .[ ; | x y --
::.eline "K" .[ ; | erase line from cursor
::.escreen "J" .[ ; | erase from cursor to end of screen
::.eline0 "1K" .[ ; | erase from start of line to cursor
::.escreenup "1J" .[ ; | erase from cursor to beginning

::.showc "?25h" .[ ;
::.hidec "?25l" .[ ;
::.savec "s" .[ ; | save cursor position
::.restorec "u" .[ ; | restore cursor position

|------- Cursor Shapes -------
::.ovec "0 q" .[ ; | default cursor
::.insc "5 q" .[ ; | blinking bar
::.blockc "2 q" .[ ; | steady block
::.underc "4 q" .[ ; | steady underscore

|------- Screen Buffer Control -------
::.alsb "?1049h" .[ ; | alternate screen buffer
::.masb "?1049l" .[ ; | main screen buffer

|------- Foreground Colors -------
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

::.fc "38;5;%dm" sprint .[ ; | 256 color foreground

|------- Background Colors -------
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

::.bc "48;5;%dm" sprint .[ ; | 256 color background

|------- RGB Colors (true color) -------
::.fgrgb | r g b --
    "%d;%d;%dm" "38;2;" swap ,s ,s .[ ;
    
::.bgrgb | r g b --
    "%d;%d;%dm" "48;2;" swap ,s ,s .[ ;

|------- Text Attributes -------
::.Bold "1m" .[ ;
::.Dim "2m" .[ ;
::.Italic "3m" .[ ;
::.Under "4m" .[ ;
::.Blink "5m" .[ ;
::.Rever "7m" .[ ;
::.Hidden "8m" .[ ;
::.Strike "9m" .[ ;
::.Reset "0m" .[ ;

|------- Console Information -------
| CONSOLE_SCREEN_BUFFER_INFO structure:
|   COORD      dwSize; (16.16)
|   COORD      dwCursorPosition;(16.16)
|   WORD       wAttributes;16
|   SMALL_RECT srWindow;16.16.16.16
|   COORD      dwMaximumWindowSize;16.16

##consoleinfo 0 0 0
##rows 
##cols
##prevrows 0
##prevcols 0

::.getconsoleinfo | --
    stdout 'consoleinfo GetConsoleScreenBufferInfo drop 
    'consoleinfo 10 + @
    dup 32 >> $ffff and over $ffff and - 'cols !
    dup 48 >> $ffff and swap 16 >> $ffff and - 'rows ! ;

::.getrows rows ; | -- rows
::.getcols cols ; | -- cols

|------- Resize Detection -------
##resized 0
##on-resize 0 | callback address

::.checksize | -- resized?
    prevrows rows <>? ( 
        rows 'prevrows !
        cols 'prevcols !
        .getconsoleinfo
        1 'resized !
        on-resize 0? ( drop 1 ; )
        ex 1 ; 
    ) drop
    prevcols cols <>? ( 
        rows 'prevrows !
        cols 'prevcols !
        .getconsoleinfo
        1 'resized !
        on-resize 0? ( drop 1 ; )
        ex 1 ; 
    ) drop
    0 ;

::.wasresized | -- flag
    resized dup 0? ( ; ) drop
    0 'resized ! 1 ;

::.onresize | 'callback --
    'on-resize ! ;

::.enable-resize | --
    | Windows automatically detects resize through event system
    | This is here for API compatibility
    ;

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
    ( stdin 'eventBuffer 1 'nr ReadConsoleInput drop
      eventBuffer $ff and
      1 =? ( drop igetkey ; )
      4 =? ( drop .getconsoleinfo 1 'resized ! ) | WINDOW_BUFFER_SIZE_EVENT
      drop
    ) ;

::inkey | -- key | 0 if no key pressed
    stdin 'ne GetNumberOfConsoleInputEvents drop
    ne 0? ( 0 ; )
    stdin 'eventBuffer 1 'nr ReadConsoleInput drop
    eventBuffer $ff and
    1 =? ( drop igetkey ; )
    4 =? ( drop .getconsoleinfo 1 'resized ! 0 ; ) | WINDOW_BUFFER_SIZE_EVENT
    drop 0 ;

::waitesc | -- | wait for ESC key
    ( getch $1B1001 <>? drop ) drop ;

|------- Extended Event Handling -------
::evtkey | -- key
    igetkey ;

| MOUSE_EVENT_RECORD:
|   COORD dwMousePosition;  | 2
|   DWORD dwButtonState;    | 6
|   DWORD dwControlKeyState;| 10
|   DWORD dwEventFlags;     | 14

::evtmxy | -- x y | mouse position
    'eventBuffer 4 + w@+ swap w@ ;

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
    stdin 'eventBuffer 1 'nr ReadConsoleInput drop
    eventBuffer $ff and
    dup 4 =? ( .getconsoleinfo 1 'resized ! ) | Handle resize event
    ;

::inevt | -- type | check for event (no wait)
    stdin 'ne GetNumberOfConsoleInputEvents drop
    ne 0? ( 0 ; )
    stdin 'eventBuffer 1 'nr ReadConsoleInput drop
    eventBuffer $ff and
    dup 4 =? ( .getconsoleinfo 1 'resized ! ) | Handle resize event
    ;

|------- Line Input -------
##pad * 256

:ink | char addr --
    $1000 and? ( drop ; ) | ignore key release
    16 >> $ff and swap c!+ ;

:.readln | --
    'pad ( inkey 1? ink ) swap c! ;

::.input | -- | read line to pad
    'pad 
    ( getch $D001C <>? | wait for ENTER key
        $1000 and? ( drop ; ) | ignore key release
        16 >> 0? ( drop ; )
        8 =? ( swap 
            1 - 'pad <? ( 2drop 'pad ; )
            swap .emit "1P" .[ ; )
        dup .emit
        swap c!+ ) drop
    0 swap c! ;

::.inputn | -- n | read number
    .input 'pad str>nro nip ;

|------- Cursor Position Reading -------
::getcursorpos | -- x y
    "6n" .[ .readln 'pad 2 +
    str>nro swap 1 + str>nro nip swap ;

|------- Special Character Printing -------
:emite | char --
    $5e =? ( drop 27 .emit ; ) | ^=escape
    .emit ;

::.printe | "str" -- | print with ^=ESC
    sprint
    ( c@+ 1? emite ) 2drop ;

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

#console-mode-in
#console-mode-out

::evtmouse | -- | enable mouse input
    stdin $18 SetConsoleMode drop ;

::.enable-mouse | -- | enable mouse events
    stdin $1F7 SetConsoleMode drop ;

::.disable-mouse | -- | disable mouse events
    stdin $7 SetConsoleMode drop ;

|------- Initialization and Cleanup -------
::.free | -- | free console
    FreeConsole drop ;

::init-console | -- | initialize console
    AllocConsole drop
    -10 GetStdHandle 'stdin ! | STD_INPUT_HANDLE
    -11 GetStdHandle 'stdout ! | STD_OUTPUT_HANDLE
    -12 GetStdHandle 'stderr ! | STD_ERROR_HANDLE
    
    | Set console modes for ANSI/VT sequences and window events
    stdin $18 SetConsoleMode drop | Enable WINDOW_INPUT
    stdout $7 SetConsoleMode drop
    
    .getconsoleinfo
    rows 'prevrows !
    cols 'prevcols ! ;

|------- Timing (for compatibility) -------
::msec | -- ms | milliseconds (approximation)
    GetTickCount ;

::ms | n -- | sleep n milliseconds
    Sleep drop ;

|------- Entry Point -------
: init-console ;
