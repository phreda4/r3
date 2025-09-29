| console words linux - Enhanced and Consistent
| PHREDA 2022 - Updated 2025

^r3/lib/mem.r3
^r3/lib/str.r3
^r3/lib/posix/conkey.r3

|------- Terminal State Management -------
#sterm * 52 | termios structure (NCC=32)
#stermp      | backup of terminal flags

::set-terminal-mode | --
    0 'sterm libc-tcgetattr drop
    'sterm 12 + dup w@ dup 'stermp !
    10 nand swap w! | ~(ICANON | ECHO)
    0 0 'sterm libc-tcsetattr drop ;

::reset-terminal-mode | --
    stermp 'sterm 12 + w!
    0 0 'sterm libc-tcsetattr drop ;

|------- Basic Output -------
::type | str cnt --
    1 rot rot libc-write drop ;

#crb ( 10 13 )
#cc ( 0 0 )
#esc[ ( $1b $5b 0 0 0 0 0 0 ) 0 0

::.cr 'crb 2 type ;
::.sp " " 1 type ;
::.nsp ( 1? 1 - .sp ) drop ;

::.emit | char --
    'cc c! 'cc 1 type ;

::.[ 'esc[ 2 + swap
    ( c@+ 1? rot c!+ swap ) 2drop
    'esc[ swap over - type ;

::.write count type ;
::.print sprint count type ;
::.println sprint count type .cr ;

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
    "38;2;%d;%d;%dm" sprint .[ ;
    
::.bgrgb | r g b --
    "48;2;%d;%d;%dm" sprint .[ ;

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
#ci 0 
##rows ##cols
#prevrc 0

::.getconsoleinfo | --
    1 $5413 'ci libc-ioctl | TIOCGWINSZ
    ci dup 16 >> $ffff and 1 - 'cols !
    $ffff and 1 - 'rows ! ;

::.getrc rows 16 << cols or ;

|------- Resize Detection -------
##resized 0
##on-resize 0 | callback address

::.checksize | -- resized?
	.getconsoleinfo
	.getrc prevrc =? ( drop 0 ; ) 'prevrc !
    1 'resized !
    on-resize 1? ( dup ex ) drop 1 ; 
	
::.onresize | 'callback --
    'on-resize ! ;

|------- Signal Handler Setup (SIGWINCH) -------
#sigwinch-handler 0

:sigwinch-handler | sig --
    drop
    .getconsoleinfo
    1 'resized ! ;

::.enable-resize | --
    'sigwinch-handler 'sigwinch-handler !
    28 sigwinch-handler 0 libc-signal drop ; | SIGWINCH = 28

|------- Keyboard Input -------
##ch 0 0

::getch | -- char
    set-terminal-mode
    0 'ch ! 0 'ch 16 libc-read drop ch 
    reset-terminal-mode ;

#tv 0 0
#fds * 128

::kbhit | -- flag
    'tv 0 2 fill 
    'fds 0 16 fill
    1 'fds !
    1 'fds 0 0 'tv libc-select ;

::inkey | -- key | 0 if no key
    set-terminal-mode
    kbhit 0? ( reset-terminal-mode ; ) drop
    0 'ch ! 0 'ch 16 libc-read drop ch
    reset-terminal-mode ;

::waitesc | -- | wait for ESC key
    ( getch $1B <>? drop ) drop ;

|------- Line Input -------
##pad * 256

::.input | -- | read line to pad
    'pad 
    ( getch $a <>? 
        .emit ) drop
    0 swap c! ;

::.inputn | -- n | read number
    .input 'pad str>nro nip ;

|------- Special Character Printing -------
:emite | char --
    $5e =? ( drop 27 .emit ; ) | ^=escape
    .emit ;

::.printe | "str" -- | print with ^=ESC
    sprint
    ( c@+ 1? emite ) 2drop ;

|------- Timing -------
::msec | -- ms | milliseconds since start
    libc-clock 1000 * CLOCKS_PER_SEC / ;

::ms | n -- | sleep n milliseconds
    1000 * libc-usleep drop ;

|------- Mouse Support (extended) -------
#mouse-x 0
#mouse-y 0
#mouse-buttons 0
#mouse-event 0

::.enable-mouse | --
    "?1000h" .[ | enable mouse tracking
    "?1002h" .[ | enable button event tracking
    "?1006h" .[ ; | enable SGR extended mouse mode

::.disable-mouse | --
    "?1006l" .[ 
    "?1002l" .[ 
    "?1000l" .[ ;

|------- UTF-8 Support -------
::.enable-utf8 | --
    | Set locale to UTF-8
    "en_US.UTF-8" "LC_ALL" libc-setlocale drop
    "en_US.UTF-8" "LC_CTYPE" libc-setlocale drop
    
    | Most modern Linux systems use UTF-8 by default
    | This ensures it's explicitly set
    ;

|------- Initialization -------
::init-console | --
    .enable-utf8
    .getconsoleinfo
	.getrc 'prevrc ! 
    .enable-resize ;

|------- Cleanup -------
::posix-bye | --
    reset-terminal-mode
    0 libc-exit drop ;

: init-console ;
