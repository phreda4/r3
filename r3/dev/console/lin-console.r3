| console words linux - Enhanced and Consistent
| PHREDA 2022 - Updated 2025

^r3/lib/mem.r3
^r3/lib/parse.r3
^r3/lib/posix/conkey.r3

|------- Basic Output -------
::type | str cnt --
    1 -rot libc-write drop ;

#sesc ( $1b $5b )
:.[ sesc 2 type count type ;

|------- Terminal State Management -------
#sterm * 64		| termios structure (NCC=32)
#stermc * 64	| backup of terminal flags
#flgs

|#define F_DUPFD         0       /* Duplicate file descriptor */
|#define F_GETFD         1       /* Get file descriptor flags */
|#define F_SETFD         2       /* Set file descriptor flags */
|#define F_GETFL         3       /* Get file status flags */
|#define F_SETFL         4       /* Set file status flags */

::set-terminal-mode | --
    0 'sterm libc-tcgetattr 
	'sterm 'stermc 8 move | sdc 
	
	0 3 0 libc-fcntl 'flgs !
	0 2 flgs $800 or libc-fcntl drop | 

	'sterm dup 
	12 + dup d@ $A nand swap d! |&= ~(ICANON | ECHO); 
    1 0 rot 20 + 5 + c!+ c!		| c_cc[VTIME] = 0; c_cc[VMIN] = 1;  
    0 0 'sterm libc-tcsetattr 
	
	"?1000h" .[ ; | enable mouse tracking
	;

::reset-terminal-mode | --
	"?1000l" .[ 
    0 0 'stermc libc-tcsetattr 
	0 2 flgs libc-fcntl drop | 
	;

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
#on-resize 0 | callback address

::.checksize | -- 
	on-resize 0? ( drop ; )
	.getconsoleinfo
	.getrc prevrc =? ( 2drop ; ) 'prevrc !
    ex ; 
	
::.onresize | 'callback -
    'on-resize ! ;

|------- Keyboard Input -------
#bufferin * 16
#bufferlen
#mouse-y #mouse-x #mouse-btn

:checkm | key -- key
	dup $ffffff and
	$4d5b1b <>? ( drop ; ) drop
	'bufferin 3 +
	c@+ 'mouse-btn !
	c@+ 'mouse-x !
	c@ 'mouse-y !
	;
	
:buffin | -- len
	0 'bufferin 10 libc-read ;

::getch | -- char
	( buffin 0? drop ) drop bufferin ;

::inkey | -- key | 0 if no key
	buffin 0? ( ; ) drop
	bufferin ;

|------- Event System (Windows-compatible) -------
#EVT_KEY 1
#EVT_MOUSE 2
|#EVT_RESIZE 4

| Mouse not available in standard terminal
::evtmxy mouse-x mouse-y  ;
::evtmb mouse-btn ;
	
::inevt | -- type | 0 if no event
	inkey 0? (	| Check keyboard
		.checksize | no event..Check resize 
		; ) 
	checkm
	EVT_KEY ; 
	
::getevt | -- type | wait for event
    ( inevt 0? drop 10 ms ) ;

::evtkey | -- key
    bufferin ;

|------- Cleanup -------
::.free | --
    reset-terminal-mode
    0 libc-exit drop ;

|------- Initialization -------
:	
set-terminal-mode
.getconsoleinfo
.getrc 'prevrc ! 
| Set locale to UTF-8
"en_US.UTF-8" "LC_ALL" libc-setlocale drop
"en_US.UTF-8" "LC_CTYPE" libc-setlocale drop

;