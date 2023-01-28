^r3/win/console.r3
^r3/lib/3d.r3
^r3/lib/vec3.r3

::.matprint
	mat>
	@+ "%f " .print @+ "%f " .print @+ "%f " .print @+ "%f " .println
	@+ "%f " .print @+ "%f " .print @+ "%f " .print @+ "%f " .println
	@+ "%f " .print @+ "%f " .print @+ "%f " .print @+ "%f " .println
	@+ "%f " .print @+ "%f " .print @+ "%f " .print @+ "%f " .println
	drop
	;
::.vecprint | v --
	@+ "%f " .print
	@+ "%f " .print
	@ "%f " .print ;
	
::.rotprint
	dup $ffff and "%f " .print
	dup 16 >> $ffff and "%f " .print
	32 >> $ffff and "%f " .print ;
	
#pEye 1.0 1.0 1.0
#pTo 2.0 3.0 3.0
#pUp 0 1.0 0

#v1 2.0 0.0 1.0
#v2 1.0 -1.0 3.0
#s 0 0 0
:
.cls
"mat" .println
matini .matprint cr
'pEye 'pTo 'pUp mlookat | eye to up --
.matprint cr
|1.0 'pto !
|'pEye 'pTo 'pUp mlookat | eye to up --
|.matprint cr


'v1 .vecprint cr
'v2 .vecprint cr
's 'v1 v3= 's .vecprint cr
's 'v2 v3vec 's .vecprint cr

|0.2 0.1 0.5 packrota
|dup .rotprint
|0.1 0.2 -0.1 packrota
|+ $100010001 not and .rotprint


|mpush
|0.9 4.0 3.0 /. 0.1 1000.0 mper .matprint cr
|m* .matprint cr

.input

;