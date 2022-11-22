
^r3/win/console.r3
^r3/win/kernel32.r3
^r3/lib/rand.r3

|#stdin
|#stdout

#eventBuffer 0 0 0 0 0

|  SHORT Left;  SHORT Top;  SHORT Right;  SHORT Bottom;
#windowsize ( 0 0 0 0 79 0 49 0 )

#bufferSize ( 80 0 50 0 )
#consoleBuffer * 16000 | 80*50*4
#charBufSize ( 80 0 50 0 )
#characterPos ( 0 0 0 0 ) 
#writeArea2 ( 0 0 0 0 79 0 49 0 )
#writeArea [ 0 $0031004f ]
#nr
#numEvents 
#appIsRunning 1

:rebuffer
	stdout 'consoleBuffer $00320050 |$00320050 |'charBufSize d@ 
	$0 |'characterPos d@ 
	'writeArea 
	WriteConsoleOutput ;
	
:clsbuffer
	'consoleBuffer >a 80 50 * ( 1? 1 - |$f00020
	rand
	da!+ ) drop ;

|---------------------	
#rect [ 0 $004f0031 ]
	
:init
|	-10 GetStdHandle 'stdin ! | STD_INPUT_HANDLE
|	-11 GetStdHandle 'stdout ! | STD_OUTPUT_HANDLE

	
	stdout -1 'rect 
	|'windowsize 
	SetConsoleWindowInfo |(wHnd, TRUE, &windowSize);
	stdout $00500032 SetConsoleScreenBufferSize |(wHnd, bufferSize);
	clsbuffer
	rebuffer
	
	"titulo" SetConsoleTitle
	;
	
|---------------------	
#rect [ 0 $0032004f ]

:resizeconsole |
	stdout -1 'rect SetConsoleWindowInfo
	stdout $00310050 SetConsoleScreenBufferSize
	;
	
:evkey	
	'eventBuffer 6 + w@
	$1B =? ( 0 'appIsRunning ! ) | esc
	$43 =? ( clsbuffer )
	drop 
	;
	
:evmouse
	'eventBuffer 2 + w@+ swap w@ | x y
	80 * + 2 << 'consoleBuffer + >a
	
	'eventBuffer 6 + d@
	$1 =? ( $db ca! rebuffer )
	$2 =? ( $b1 ca! rebuffer )
	$4 =? ( $20 ca! rebuffer )
	drop
	;
		
:eventos
	stdin 'eventBuffer 1 'nr ReadConsoleInput |(rHnd, eventBuffer, numEvents, &numEventsRead);
	eventBuffer $ff and
	$1 =? ( evkey )
	$2 =? ( evmouse )
|	$4 =? ( evsize )
|	$8 =? ( evmenu )
|	$10 =? ( evfocus )
	drop
	;
	
:app
	( appIsRunning 1? drop
		stdin 'numEvents GetNumberOfConsoleInputEvents
		numEvents 1? ( eventos ) drop
		) drop ;
	
:
|init
resizeconsole
|app
clsbuffer
rebuffer

( inkey $1B1001 <>? drop
	clsbuffer
	rebuffer
	) drop
;
