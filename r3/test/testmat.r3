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
	
#fx 0 #fy 0 #fz 0 
#sx 0 #sy 0 #sz 0
#ux 0 #uy 0 #uz 0 

::mlookat | eye to up --
|	'f rot v3= 'f dup pick3 v3- v3Nor | eye up s s
|	's 'f v3= 's swap v3vec 's v3Nor
|	'u dup 's v3= 'f v3vec
	swap
	'fx dup rot v3= dup pick3 v3- v3Nor | eye up
	'sx dup 'fx v3= dup rot v3vec v3Nor | eye
	'ux dup 'sx v3= 'fx v3vec
	mat> >a
	sx a!+ |mat[0] = s.x;
    ux a!+ |mat[1] = u.x;
    fx neg a!+ |mat[2] = -f.x;
    0 a!+ |mat[3] = 0.0;
    sy a!+ |mat[4] = s.y;
    uy a!+ |mat[5] = u.y;
    fy neg a!+ |mat[6] = -f.y;
    0 a!+ |mat[7] = 0.0;
    sz a!+ |mat[8] = s.z;
    uz a!+ |mat[9] = u.z;
    fz neg a!+ |mat[10] = -f.z;
    0 a!+ |mat[11] = 0.0;
    'sx over v3ddot neg a!+ |mat[12] = -kmVec3Dot(&s, pEye);
    'ux over v3ddot neg a!+ |mat[13] = -kmVec3Dot(&u, pEye);
    'fx swap v3ddot a!+ |mat[14] = kmVec3Dot(&f, pEye);
    1.0 a! |mat[15] = 1.0;
	;
	
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


|'v1 .vecprint cr
|'v2 .vecprint cr
|'s 'v1 v3= 's .vecprint cr
|'s 'v2 v3vec 's .vecprint cr

|0.2 0.1 0.5 packrota
|dup .rotprint
|0.1 0.2 -0.1 packrota
|+ $100010001 not and .rotprint


|mpush
|0.9 4.0 3.0 /. 0.1 1000.0 mper .matprint cr
|m* .matprint cr

.input

;