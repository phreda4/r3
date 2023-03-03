| Julian dates library tests
| MC 2011
|---------------------------------------
^r3/win/console.r3
^r3/lib/parse.r3
^r3/lib/jul.r3

:inv3 swap rot ; | ( a b c -- c b a )

:printdatecr jul2date inv3 "%d-%d-%d" .print .cr ;

:main
	.cls
	"julian library tests" .print .cr .cr
	
	now2jul dup jul2daystr "Today : %s " .print printdatecr .cr

	now2jul 5 -  dup jul2daystr "Today-5  : %s " .print printdatecr
	now2jul 5 +  dup jul2daystr "Today+5  : %s " .print printdatecr .cr

	now2jul 20 - dup jul2daystr "Today-20 : %s " .print printdatecr
	now2jul 20 + dup jul2daystr "Today+20 : %s " .print printdatecr .cr

	now2jul 30 - dup jul2daystr "Today-30 : %s " .print printdatecr
	now2jul 30 + dup jul2daystr "Today+30 : %s " .print printdatecr 
		
	waitesc ;

: main ;
