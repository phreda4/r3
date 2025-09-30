| console words linux - Enhanced and Consistent
| PHREDA 2022 - Updated 2025

^r3/lib/mem.r3
^r3/lib/parse.r3
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

:.getrc rows 16 << cols or ;

|------- Resize Detection -------
##on-resize 0 | callback address

::.checksize | -- 
	on-resize 0? ( drop ; )
	.getconsoleinfo
	.getrc prevrc =? ( 2drop 0 ; ) 'prevrc !
    ex ; 
	
::.onresize | 'callback --
    'on-resize ! ;

|------- Signal Handler Setup (SIGWINCH) -------
|#sigwinch-handler 0

|:sigwinch-handler | sig --
|    drop .getconsolei\nfo ;

|::.enable-resize | --
|    'sigwinch-handler 'sigwinch-handler !
|    28 sigwinch-handler 0 libc-signal drop ; | SIGWINCH = 28

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

|------- Event System (Windows-compatible) -------
#EVT_KEY 1
#EVT_MOUSE 2
|#EVT_RESIZE 4

#mouse-y #mouse-x #mouse-btn #mouse-w

| Formato: ESC[<button;x;yM o m
:mouse-sgr | -- ev
	ch $ffffff and $3c5b1b <>? ( drop 0 ; ) drop
	'ch 3 + | Skip ESC[
	str>nro 'mouse-btn ! 1+ | Skip ;
	str>nro 'mouse-x ! 1+ | Skip ;
	str>nro 'mouse-y ! drop | m/M
	EVT_MOUSE ;

| Mouse not available in standard terminal
::evtmxy mouse-x mouse-y  ;
::evtmb mouse-btn ;
::evtw mouse-w ;
	
::inevt | -- type | 0 if no event
	inkey 0? (	| Check keyboard
		.checksize | Check resize 
		; ) drop | No events
	mouse-sgr 1? ( ; ) drop
	EVT_KEY ; 
	
::getevt | -- type | wait for event
    ( inevt 0? drop 10 ms ) ;

::evtkey | -- key
    ch ;

|------- Mouse Support (extended) -------
#sesc ( $1b $5b )
:.[ sesc 2 type count type ;

::.enable-mouse | --
    "?1000h" .[ ; | enable mouse tracking
    "?1002h" .[ | enable button event tracking
    "?1006h" .[ ; | enable SGR extended mouse mode

::.disable-mouse | --
    "?1006l" .[ 
    "?1002l" .[ 
    "?1000l" .[ ;

|------- Cursor Position Reading -------
|::getcursorpos | -- x y
|    "6n" .[ .readln 'pad 2 +
|    str>nro swap 1 + str>nro nip swap ;
	

|------- Timing -------
::msec | -- ms | milliseconds since start
|    libc-clock 1000 * CLOCKS_PER_SEC / 
	1
	;

::ms | n -- | sleep n milliseconds
    1000 * libc-usleep drop ;

|------- UTF-8 Support -------
::.enable-utf8 | --
    | Set locale to UTF-8
	"en_US.UTF-8" "LC_ALL" libc-setlocale drop
	"en_US.UTF-8" "LC_CTYPE" libc-setlocale drop
    
    | Most modern Linux systems use UTF-8 by default
    | This ensures it's explicitly set
    ;

|------- Cleanup -------
::.free | --
|.disable-mouse
    reset-terminal-mode
    0 libc-exit drop ;

|------- Initialization -------
:	
.enable-utf8
.getconsoleinfo
.getrc 'prevrc ! 
;