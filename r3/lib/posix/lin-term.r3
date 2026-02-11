| console words linux - Enhanced and Consistent
| PHREDA 2022 - Updated 2025
^r3/lib/posix/posix.r3
^r3/lib/mem.r3
^r3/lib/parse.r3

::type 1 -rot libc-write drop ;

#enable_sgr ( $1B $5B $3F $31 $30 $30 $36 $68 )
#enable_1002 ( $1B $5B $3F $31 $30 $30 $32 $68 )
#disable_sgr ( $1B $5B $3F $31 $30 $30 $36 $6C )
#disable_1002 ( $1B $5B $3F $31 $30 $30 $32 $6C )

#sterm * 64		| termios structure copy (0=no copy)
#flgs

|#define F_DUPFD 0 /* Duplicate file descriptor */
|#define F_GETFD 1 /* Get file descriptor flags */
|#define F_SETFD 2 /* Set file descriptor flags */
|#define F_GETFL 3 /* Get file status flags */
|#define F_SETFL 4 /* Set file status flags */
|#define OFF_IFLAG  0   // 4 bytes, uint32
|#define OFF_OFLAG  4   // 4 bytes, uint32
|#define OFF_CFLAG  8   // 4 bytes, uint32
|#define OFF_LFLAG  12  // 4 bytes, uint32
|#define OFF_LINE   16  // 1 byte
|#define OFF_CC     17  // 32 bytes
::set-terminal-mode | --
	sterm 0? ( 0 'sterm libc-tcgetattr ) drop
	'sterm >a here >b |'stermc >b
	da@+ $FFFFFACD and db!+	| set32(raw, OFF_IFLAG, get32(raw, OFF_IFLAG) & 0xFFFFFACD);
    da@+ $FFFFFFFE and db!+	| set32(raw, OFF_OFLAG, get32(raw, OFF_OFLAG) & 0xFFFFFFFE);
    da@+ $30 or db!+		| set32(raw, OFF_CFLAG, get32(raw, OFF_CFLAG) | 0x30);
	da@+ $FFFF7FF4 and db!+	| set32(raw, OFF_LFLAG, get32(raw, OFF_LFLAG) & 0xFFFF7FF4);	
	ca@ cb!+ | line
    a@+ b!+ a@+ b!+ a@+ b!+ a@ b!
    here 17 + >b | cc[32]
    $7f b> 2 + c!
    1 b> 5 + c!
    0 b> 6 + c!
	0 0 here libc-tcsetattr 
	'enable_1002 8 type
	'enable_sgr 8 type
	;

#showc ( $1B $5B $3f $32 $35 $68 )
::reset-terminal-mode | --
	'disable_sgr 8 type
	'disable_1002 8 type
	'showc 6 type
	|0 2 flgs libc-fcntl drop  ??
	0 0 'sterm libc-tcsetattr 

	0 'sterm !
	;

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
	
:
	.reterm
	.getterminfo
	.getrc 'prevrc ! 
| Set locale to UTF-8
	"en_US.UTF-8" "LC_ALL" libc-setlocale drop
	"en_US.UTF-8" "LC_CTYPE" libc-setlocale drop
	;
	