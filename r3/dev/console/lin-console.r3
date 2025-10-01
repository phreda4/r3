| console words linux - Enhanced and Consistent
| PHREDA 2022 - Updated 2025

^r3/lib/mem.r3
^r3/lib/parse.r3
^r3/lib/posix/conkey.r3

|------- Basic Output -------
::type | str cnt --
    1 -rot libc-write drop ;

#sesc ( $1b $5b )
:.[ 'sesc 2 type count type ;

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
	'stermc 'sterm 8 move | dsc 
	
	0 3 0 libc-fcntl 'flgs !
	0 2 flgs $800 or libc-fcntl drop |

	'sterm dup 
	12 + dup d@ $A nand swap d! |&= ~(ICANON | ECHO); 
    0 0 rot 20 + 5 + c!+ c!		| c_cc[VTIME] = 0; c_cc[VMIN] = 0;  
    0 0 'sterm libc-tcsetattr 
	;

::reset-terminal-mode | --
    0 0 'stermc libc-tcsetattr 
	0 2 flgs libc-fcntl drop 
	;

::.enable-mouse		"?1003h" .[ ;	
::.disable-mouse	"?1003l" .[ ;
	
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

#mouse-y #mouse-x 
##evtmb
##evtmw

::evtmxy mouse-x mouse-y ;
	
:bitbtn
	32 34 in? ( $3 and 1 swap << evtmb or 'evtmb ! ; )
	$4 and? ( $3 and 1 swap << not evtmb and 'evtmb ! ; )
	drop ;
	
:checkm | key -- key
	0 'evtmw !
	'bufferin 3 +
	c@+ 32 - 
	$40 and? ( nip $1 and 2* 1- 'evtmw ! ; ) 
|	bitbtn
	$3 and 1 swap << 'evtmb !
	c@+ 32 - 'mouse-x !
	c@ 32 - 'mouse-y !
	;
	
::inevt | -- type | 0 if no event
	buffin 0? ( .checksize ; ) 
	3 >? (	bufferin $ffffff and
		$4d5b1b =? ( 2drop checkm EVT_MOUSE ; ) 
		drop ) drop
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