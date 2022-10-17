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
	
:
.cls
"test" .println
loope
|.input
;