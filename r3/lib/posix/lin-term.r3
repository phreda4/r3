| console words linux - Enhanced and Consistent
| PHREDA 2022 - Updated 2025
^r3/lib/posix/posix.r3
^r3/lib/mem.r3
^r3/lib/parse.r3

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
	'sterm dup 
	12 + dup d@ $A nand swap d! |&= ~(ICANON | ECHO); 
    0 0 rot 20 + 5 + c!+ c!		| c_cc[VTIME] = 0; c_cc[VMIN] = 0;  
    0 0 'sterm libc-tcsetattr 
	"?1006h" .[ "?1002h" .[  | 1003 mode not work with up btn
	;

::reset-terminal-mode | --
	"?1002l" .[ "?1006l" .[ |:.disable-mouse	
    0 0 'stermc libc-tcsetattr 
	0 2 flgs libc-fcntl drop 
	;

|::reset-terminal-mode
|    stermp 'sterm 12 + w!
|    0 0 'sterm libc-tcsetattr  ;

|------- Console Information -------
##rows ##cols
#prevrc 0

::.getterminfo | --
    1 $5413 'flgs libc-ioctl | TIOCGWINSZ
    flgs dup 16 >> $ffff and 1 - 'cols !
    $ffff and 1 - 'rows ! ;

:.getrc rows 16 << cols or ;

|------- Resize Detection -------
#on-resize 0 | callback address

:.checksize | -- evt
	on-resize 0? ( ; )
	.getterminfo
	.getrc prevrc =? ( 2drop 0 ; ) 'prevrc !
    ex 4 ; |#EVT_RESIZE 4
	
::.onresize | 'callback -
    'on-resize ! ;

|------- Keyboard Input -------
#bufferin * 16

:buffin | -- len
	0 'bufferin 2dup ! 16 libc-read ;

|::getch | -- char
|	( buffin 0? drop ) drop bufferin ;

#tv 0 0
#fds 0 0

::kbhit
	1 'fds 2dup ! 0 0 'tv libc-select ;

::inkey | -- key | 0 if no key
	kbhit 0? ( ; ) drop
	buffin drop
	bufferin ;

|------- Event System (Windows-compatible) -------
##evtmx ##evtmy
##evtmb
##evtmw
::evtmxy evtmx evtmy ;

|--- mode 1006
:dnbtn
	$40 and? ( $1 and 2* 1- neg 'evtmw ! ; ) 
	$3 and 1 swap <<
	evtmb or 'evtmb ! ;
	
:upbtn
	$40 and? ( $1 and 2* 1- 'evtmw ! ; ) 
	$3 and 1 swap << not
	evtmb and 'evtmb ! ;
	
| Formato: ESC[<button;x;yM o m
:check6 | -- button x y
	0 'evtmw !
	'bufferin 3 +
    getnro swap 1+ | Skip ;
    getnro 'evtmx ! 1+ | Skip ;
    getnro 'evtmy ! 
	c@ | m 6d M 4d
	$20 nand? ( drop dnbtn ; ) 
	drop upbtn ;

::inevt | -- type | 0 if no event
	kbhit 0? ( drop .checksize ; ) drop
	buffin 
	6 >? ( drop 
		bufferin $ffffff and
		$3c5b1b =? ( drop check6 2 ; ) | #EVT_MOUSE 2
		) drop
	1 ; |#EVT_KEY 1
	
::getevt | -- type | wait for event
    ( inevt 0? drop 10 ms ) ;

::evtkey | -- key
    bufferin ;

|------- Cleanup -------
::.free | --
    reset-terminal-mode
    |0 libc-exit drop 
	;

|------- Initialization -------
::.reterm
	set-terminal-mode ;
	
: |:.term	
	.reterm
	.getterminfo
	.getrc 'prevrc ! 
| Set locale to UTF-8
	"en_US.UTF-8" "LC_ALL" libc-setlocale drop
	"en_US.UTF-8" "LC_CTYPE" libc-setlocale drop
	;
	