^r3/win/console.r3

::inkey
|	stdin 'irec 1 'kb PeekConsoleInput		
|	irec $100000001 <>? ( drop ; ) drop
	stdin 'irec 1 'kb ReadConsoleInput
|	codekey 48 >> 
	irec
	;
	
:main
	inkey "%h " .print
	main ;
	
: main ;