| test mouse
| PHREDA 2023
^r3/lib/rand.r3
^r3/win/console.r3
^r3/win/kernel32.r3

#conw 80 
#conh 28 

#conwh 0
#writeArea [ 0 0 ]

#eventBuffer 0 0 0 0 0
#nr
#appIsRunning 1
#consoleBuffer * $ffff 

:rebuffer
	stdout 'consoleBuffer 
	conwh $00000000 'writeArea 
	WriteConsoleOutput ;
	
:clsbuffer
	'consoleBuffer $f0000 conw conh * dfill ;

|---------------------	
:inicon
	conw 1 - conh 1 - 16 << or 'writearea 4 + d!
	conw conh 16 << or 'conwh !
	
	stdin $18 SetConsoleMode drop 
	
	stdout -1 'writeArea SetConsoleWindowInfo |(wHnd, TRUE, &windowSize);
	stdout conwh SetConsoleScreenBufferSize |(wHnd, bufferSize);
	
	clsbuffer
	rebuffer
	
	"Mouse Console Draw" SetConsoleTitle
	;
	

|---------------------	
:evkey	
	'eventBuffer 14 + w@
	$1B =? ( 0 'appIsRunning ! ) | esc
	$43 =? ( clsbuffer )
	drop 
	;

:putpixel
	'eventBuffer 4 + w@+ swap w@ | x y
	conw * + 2 << 'consoleBuffer +
	$ff randmax 16 << | color
	$31 or | char
	swap d!
	rebuffer ;
	
:evmouse
	'eventBuffer 8 + d@
	$0 <>? ( putpixel )
	drop ;
		
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
	
:
	inicon
	( appIsRunning 1? drop
		stdin 'nr GetNumberOfConsoleInputEvents
		nr 1? ( eventos ) drop
		) drop ;
	
