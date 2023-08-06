^r3/win/console.r3
^r3/lib/3dgl.r3
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
	
#fx 0 #fy 0 #fz 0 | in compiler again constant remover! 
#sx 0 #sy 0 #sz 0
#ux 0 #uy 0 #uz 0 

::mlookat | eye to up --
|	'f rot v3= 'f dup pick3 v3- v3Nor | eye up s s
|	's 'f v3= 's swap v3vec 's v3Nor
|	'u dup 's v3= 'f v3vec
	swap
	'fx dup rot v3= dup pick3 v3- 
	dup .vecprint .cr
	v3Nor | eye up
	"f:" .print 'fx .vecprint .cr
	
	'sx dup 'fx v3= dup rot v3vec v3Nor | eye

	'ux dup 'sx v3= 'fx v3vec
	"u:" .print 'ux .vecprint .cr
	mat> >b
	
	sx b!+ |mat[0] = s.x;
    ux b!+ |mat[1] = u.x;
    fx neg b!+ |mat[2] = -f.x;
    0 b!+ |mat[3] = 0.0;
    sy b!+ |mat[4] = s.y;
    uy b!+ |mat[5] = u.y;
    fy neg b!+ |mat[6] = -f.y;
    0 b!+ |mat[7] = 0.0;
    sz b!+ |mat[8] = s.z;
    uz b!+ |mat[9] = u.z;
    fz neg b!+ |mat[10] = -f.z;
    0 b!+ |mat[11] = 0.0;
	
    'sx over 
	.cr over .vecprint .cr dup .vecprint .cr 
	v3ddot 
	dup "= %f " .println
	neg b!+ |mat[12] = -kmVec3Dot(&s, pEye);
    'ux over v3ddot neg b!+ |mat[13] = -kmVec3Dot(&u, pEye);
    'fx swap v3ddot b!+ |mat[14] = kmVec3Dot(&f, pEye);
    1.0 b! |mat[15] = 1.0;
	;
	
#pEye 2.0 4.0 -1.0
#pTo 0.0 0.0 0.0
#pUp 1.0 0 0

#v1 1.0 1.0 0.0
#v2 1.0 -1.0 3.0
#s 0 0 0

:test1
"mat" .println
matini .matprint .cr
'pEye 'pTo 'pUp mlookat | eye to up --
.cr
.matprint .cr
matinv
"inv:" .println
.matprint .cr


800.0 0 0 600.0 1.0 0.0 mortho
"ortho:" .println
.matprint .cr

|1.0 'pto !
|'pEye 'pTo 'pUp mlookat | eye to up --
|.matprint .cr


|'v1 .vecprint .cr
|'v2 .vecprint .cr
|'s 'v1 v3= 's .vecprint .cr
|'s 'v2 v3vec 's .vecprint .cr

|0.2 0.1 0.5 packrota
|dup .rotprint
|0.1 0.2 -0.1 packrota
|+ $100010001 not and .rotprint


|mpush
|0.9 4.0 3.0 /. 0.1 1000.0 mper .matprint .cr
|m* .matprint .cr
|.cr
|.cr
|25.0 sqrt. "%f" .println .cr
|25 sqrt "%d" .println .cr
;

:col | mat -- mat'
	dup @ a@+ *.
	over 4 3 << + @ a@+ *. +
	over 8 3 << + @ a@+ *. +
	over 12 3 << + @ a@+ *. +
	b!+ -32 a+
	8 + ;
:matvec* | 'mat 'vec 'vec --
	>b >a
	col	col col
	drop ;

#v1 1.0 1.0 0
#v2 1.0 0.0 1.0
#vr 0 0 0

:test2
matini
"mat" .println
.matprint .cr

'v1 .vecprint  .cr
0.25 0.3 0.1  mrot
0.1 0.32 0.11 mpos
.cr
.matprint .cr
.cr

mat> 'v1 'vr matvec*
'vr .vecprint  .cr
.cr
'v2 'vr v3=
|'v2 .vecprint  
.cr
matinv
|1.0 mat> 120 + !
.matprint .cr
mat> 'v2 'vr matvec*
'vr .vecprint  .cr .cr

"(-0.249946, -0.587559, 0.769420, -0.000000), 
(0.951263, -0.000043, 0.308980, -0.000000), 
(-0.181583, 0.809087, 0.558973, -0.000000), 
(-0.259383, -0.030208, -0.237139, 1.000000))" .println
	;
	
#fmvp * 64
#fviewmat * 64
#fmodelmat * 64
#flightpos [ 4.0 4.0 4.0 ]
	
#pEye 4.0 0.0 0.0
#pTo 0 0 0
#pUp 0 1.0 0

#matcam * 128

:test3
	matini
	0.1 1000.0 0.9 3.0 4.0 /. mperspective 
|	-2.0 2.0 -2.0 2.0 -2.0 2.0 mortho
	'matcam mcpy	| perspective matrix
.matprint .cr
	
	"mat" .println
	matini 

	0.0 0.2 0.5 mrpos
	'fmodelmat mcpyf | model matrix	>>
	
	.matprint .cr		
	|------- mov camara
	mpush 'pTo 'pEye 'pUp mlookat 
	.matprint .cr	
	m* | eye to up -- 
	|------- perspective
	'matcam mm* 	| cam matrix
	'fmvp mcpyf		| mvp matrix >>
	
	.matprint .cr	
	;
:test4
	matini
	'pTo 'pEye 'pUp mlookat 
	.matprint .cr	
	;

:
.cls
test4
.input
;