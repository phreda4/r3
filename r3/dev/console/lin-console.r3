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
