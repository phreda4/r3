^r3/win/console.r3

#test "54.0582 85.2368 -73.3944 0.0 0.0 0.0 0.717221 -0.00360072 0.02023 0.197725 -0.00495974 0.0342585 -1.51632e-14 0.0 -2.4848e-17 "	

#test "54.0582 85.2368 -73.3944 0.0 0.0 0.0 0.717221 -0.00360072 0.02023 0.197725 -0.00495974 0.0342585 -1.51632e-14 0.0"	
#test> 0

:getl
'test ( dup c@ 1? drop 
	trim |0? ( drop ; )
	getfenro 
|	str>nro 
	"%f " .print
	>>sp
	) drop ;

:
.cls
"test parse float" .println
getl
waitesc
;