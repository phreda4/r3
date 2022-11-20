^r3/win/console.r3

#ant 0
:loope	
	evtcon drop 
	'aconev 8 + @ $1b0001 =? ( drop ; ) drop
	conev
	ant =? ( drop loope ; ) 
	dup 'ant ! 
	"%h" .println
	loope
	;

:loopc
	( getch $1B1001 <>? "%h" .println ) drop ;	
:
.cls
"test" .println
|loope
|.input
loopc
;