| Conway Game of Life in buffer
| PHREDA 2021
^r3/win/console.r3
^r3/win/mconsole.r3
^r3/lib/rand.r3

#conw 113 
#conh 28 
#conwh 0
#writeArea [ 0 0 ]

#appIsRunning 1
#consoleBuffer * $fffff 

:rebuffer
	stdout 'consoleBuffer 
	conwh $00000000 'writeArea 
	WriteConsoleOutput ;
	
:clsbuffer
	'consoleBuffer $f0000 conw conh * dfill ;
	
:inicon
	conw 1 - conh 1 - 16 << or 'writearea 4 + d!
	conw conh 16 << or 'conwh !
	
	stdin $18 SetConsoleMode drop 
	
	stdout -1 'writeArea SetConsoleWindowInfo |(wHnd, TRUE, &windowSize);
	stdout conwh SetConsoleScreenBufferSize |(wHnd, bufferSize);
	
	clsbuffer
	rebuffer
	"conway life" SetConsoleTitle
	;	
	
#arena 
#arenan

:check | adr -- adr 
	dup cols - 1 - >a	
	ca@+ ca@+ + ca@ + 
	over 1 - >a	
	ca@+ + 1 a+ ca@ +
	over cols + 1 - >a	ca@+ + ca@+ + ca@ + 	| calc 
	3 =? ( drop 1 cb!+ ; )
	2 <>? ( drop 0 cb!+ ; ) 
	drop
	dup c@ cb!+ ;
	
:evolve
	arenan >b
	arena
	0 ( rows <? 
		0 ( cols <? 
			rot 
			check 1 + rot rot 
			1 + ) drop
		1 + ) 2drop 
	arena arenan cols rows * cmove 
	;
	
:drawscreen
	arena >a
	'consoleBuffer >b
	0 ( rows <? 
		0 ( cols <? 
			ca@+ 16 << $f0000000 or db!+
			1 + ) drop
		1 + ) drop 
	rebuffer		
	;
	
:arenarand
	arena >a
	0 ( rows <? 
		0 ( cols <? 
			rand 9 >> 1 and ca!+
			1 + ) drop
		1 + ) drop ;

|---------------------	
#run 1
#pause 0

:evkey	
	evtkey
	$1B1001 =? ( 0 'run ! ) | esc
	$200039 =? ( pause 1 xor 'pause ! ) 
	drop 
	;

:putpixel
	evtmxy 
	conw * + arena +
	1 swap c! ;
	
:evmouse
	evtmb
	$0 <>? ( putpixel ) | mouse button 
	drop ;
	
:eventos
	inevt
	$1 =? ( evkey )
	$2 =? ( evmouse )
	drop ;
	
:main
	arenarand
	( run 1? drop 
		eventos
		drawscreen
		pause 0? ( evolve ) drop
		) drop ;

: 
	.getconsoleinfo
	rows 'conh ! 
	cols 'conw !
	inicon
	here 1 + cols + 			| one more line for calc
	dup 'arena !			| start of arena
	rows cols * + dup 'arenan !	| copy of arena
	rows cols * + 'here !
	main
	;