| use console buffer
| PHREDA 2023

^r3/win/console.r3
^r3/win/kernel32.r3
^r3/lib/rand.r3

| 28 1c
| 113 71

#eventBuffer 0 0 0 0 0
#consoleBuffer * $ffff | 

|  SHORT Left;  SHORT Top;  SHORT Right;  SHORT Bottom;

#nr
#numEvents 
#appIsRunning 1

#writeArea [ 0 $001b0070 ]
:rebuffer
	stdout 'consoleBuffer 
	$001c0071 $00000000 'writeArea 
	WriteConsoleOutput ;
	
:clsbuffer
	'consoleBuffer >a $71 $1c * ( 1? 1 - 
		rand da!+ ) drop ;

|---------------------	
	
:init
|	-10 GetStdHandle 'stdin ! | STD_INPUT_HANDLE
|	-11 GetStdHandle 'stdout ! | STD_OUTPUT_HANDLE

	stdout -1 'writeArea SetConsoleWindowInfo |(wHnd, TRUE, &windowSize);
	stdout $001c0071 SetConsoleScreenBufferSize |(wHnd, bufferSize);
	
	clsbuffer
	rebuffer
	
	"titulo" SetConsoleTitle
	;
	
|---------------------	

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
init
clsbuffer
rebuffer

( inkey $1B1001 <>? drop
	clsbuffer 
	rebuffer 
	) drop
;
