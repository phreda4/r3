^r3/win/console.r3

#test "54.0582 85.2368 -73.3944 0.0 0.0 0.0 0.717221 -0.00360072 0.02023 0.197725 -0.00495974 0.0342585 -1.51632e-14 0.0 -2.4848e-17 "	

#test2 "54.0582 85.2368 -73.3944 0.0 0.0 0.0 0.717221 -0.00360072 0.02023 0.197725 -0.00495974 0.0342585 -1.51632e-2 0.0 "	
#test> 0

:getl
'test ( trim dup c@ 1? drop 
	getfenro 
	"%f " .print

	) drop ;
	
#s1 "-1.51632e-14 0.0 "

:nn
	getfenro "%f!" .print dup " >%s< " .print	trim dup " >%s< " .println ;
	
:testp
	's1 
	dup ">>%s<<" .println
	nn nn nn
	drop
	;
:
.cls
"test parse float" .println
getl
|testp
waitesc
;