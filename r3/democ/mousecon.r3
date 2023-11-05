| test mouse
| PHREDA 2023
^r3/lib/rand.r3
^r3/win/console.r3
^r3/win/kernel32.r3

#conw 113 
#conh 28 
#conwh 0
#writeArea [ 0 0 ]

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
	evtkey
	$1B1001 =? ( 0 'appIsRunning ! ) | esc
	$43 =? ( clsbuffer )
	drop 
	;

:putpixel
	evtmxy 
	conw * + 2 << 'consoleBuffer +
	$ff randmax 16 << | color
	pick2 $30 + or | char
	swap d!
	rebuffer ;
	
:evmouse
	evtmb
	$0 <>? ( putpixel )
	drop ;
	
:eventos
	getevt
	$1 =? ( evkey )
	$2 =? ( evmouse )
	drop ;
	
:	inicon
	( appIsRunning 1? drop
		eventos
		) drop ;