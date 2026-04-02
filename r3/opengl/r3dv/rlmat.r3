| RLMATH 
| PHREDA 2026

##mat * 128
##mati * 128 | aux inv
#matx * 128 | aux

::cpymatif | 'dest 'src --
	>a >b 16 ( 1? 1- a@+ f2fp db!+ ) drop ;

:a] 3 << a> + ;	
:b] 3 << b> + ;

:camAsp		b@ ;
:camFov		1 b] @ ;
:camNear	2 b] @ ;
:camFar		3 b] @ ;
	
::matProj | 'infocam --
	>b
	'mat 0 16 fill | dvc
	'mat >a
	|...................
		camFov dup camAsp /. 
	a! | m[0]=fov/asp
		|camFov 
	5 a] ! | m[5]=f;
		camNear camFar 2dup + -rot - /. | zn+zf zn-zf
	10 a] ! | m[10]=-(zn+zf)/(zn-zf); 
		-1.0 
	11 a] ! | m[11]=-1.f;
		camNear camFar 2dup - -rot
		*. 2* neg swap /.
	14 a] ! | m[14]=-2.f*zn*zf/(zn-zf); 
	|...................
	'mati 0 16 fill | dvc
	'mati >b 'mat >a
		1.0 a@ /.
	b! | inv_proj.m[0]  =  1.0f / proj.m[0];
		1.0 5 a] @ /.
	5 b] ! |inv_proj.m[5]  =  1.0f / proj.m[5];
		1.0 14 a] @ /.
	11 b] ! | inv_proj.m[11] =  1.0f / proj.m[14];
		-1.0
	14 b] ! | inv_proj.m[14] = -1.0f;
		10 a] @ 14 a] @ /.
	15 b] ! | inv_proj.m[15] =  proj.m[10] / proj.m[14];
	;
	
#fx 0 0 0 |#fy 0 #fz 0 | compiler remove constant problem!!
:fy 'fx 8 + @ ;
:fz 'fx 16 + @ ;
#sx 0 0 0 |#sy 0 #sz 0
:sy 'sx 8 + @ ;
:sz 'sx 16 + @ ;
#ux 0 0 0 |#uy 0 #uz 0 
:uy 'ux 8 + @ ;
:uz 'ux 16 + @ ;
	
::mlookat | 'eye 'to 'up --
	swap
	'fx dup rot v3= dup pick3 v3- v3Nor | eye up
	'sx dup 'fx v3= dup rot v3vec v3Nor | eye
	'ux dup 'sx v3= 'fx v3vec
	mat >b
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
    'sx over v3ddot neg b!+ |mat[12] = -kmVec3Dot(&s, pEye);
    'ux over v3ddot neg b!+ |mat[13] = -kmVec3Dot(&u, pEye);
    'fx swap v3ddot b!+ |mat[14] = kmVec3Dot(&f, pEye);
    1.0 b! |mat[15] = 1.0;
	;	

	
::matinv | -- | mat --> mati |invert
	'mat >a
	'matx >b | b store aux
    0 a] @ 5 a] @ *. 1 a] @ 4 a] @ *. - b!+
    0 a] @ 6 a] @ *. 2 a] @ 4 a] @ *. - b!+
    0 a] @ 7 a] @ *. 3 a] @ 4 a] @ *. - b!+
    1 a] @ 6 a] @ *. 2 a] @ 5 a] @ *. - b!+
    1 a] @ 7 a] @ *. 3 a] @ 5 a] @ *. - b!+
    2 a] @ 7 a] @ *. 3 a] @ 6 a] @ *. - b!+
    8 a] @ 13 a] @ *. 9 a] @ 12 a] @ *. - b!+
    8 a] @ 14 a] @ *. 10 a] @ 12 a] @ *. - b!+
    8 a] @ 15 a] @ *. 11 a] @ 12 a] @ *. - b!+
    9 a] @ 14 a] @ *. 10 a] @ 13 a] @ *. - b!+
    9 a] @ 15 a] @ *. 11 a] @ 13 a] @ *. - b!+
    10 a] @ 15 a] @ *. 11 a] @ 14 a] @ *. - b!+
	
	'matx >b 
    0 b] @ 11 b] @ *. 
	1 b] @ 10 b] @ *. -  
	2 b] @ 9 b] @ *. + 
	3 b] @ 8 b] @ *. + 
	4 b] @ 7 b] @ *. - 
	5 b] @ 6 b] @ *. + 
	0? ( drop ; )
	mati
	1.0 swap /. 
	5 a] @ 11 b] @ *. 6 a] @ 10 b] @ *. - 7 a] @ 9 b] @ *. + over *. rot !+ swap
	2 a] @ 10 b] @ *. 3 a] @ 9 b] @ *. - 1 a] @ 11 b] @ *. - over *. rot !+ swap
    13 a] @ 5 b] @ *. 14 a] @ 4 b] @ *. - 15 a] @ 3 b] @ *. + over *. rot !+ swap
	10 a] @ 4 b] @ *. 11 a] @ 3 b] @ *. - 9 a] @ 5 b] @ *. - over *. rot !+ swap
	
	6 a] @ 8 b] @ *. 4 a] @ 11 b] @ *. - 7 a] @ 7 b] @ *. - over *. rot !+ swap
    0 a] @ 11 b] @ *. 2 a] @ 8 b] @ *. - 3 a] @ 7 b] @ *. + over *. rot !+ swap
	14 a] @ 2 b] @ *. 15 a] @ 1 b] @ *. - 12 a] @ 5 b] @ *. - over *. rot !+ swap
    8 a] @ 5 b] @ *. 10 a] @ 2 b] @ *. - 11 a] @ 1 b] @ *. + over *. rot !+ swap
	
    4 a] @ 10 b] @ *. 5 a] @ 8 b] @ *. - 7 a] @ 6 b] @ *. + over *. rot !+ swap
	1 a] @ 8 b] @ *. 3 a] @ 6 b] @ *. - 0 a] @ 10 b] @ *. - over *. rot !+ swap
    12 a] @ 4 b] @ *. 13 a] @ 2 b] @ *. - 15 a] @ 0 b] @ *. + over *. rot !+ swap
	9 a] @ 2 b] @ *. 11 a] @ 0 b] @ *. - 8 a] @ 4 b] @ *. - over *. rot !+ swap
	
	5 a] @ 7 b] @ *. 6 a] @ 6 b] @ *. - 4 a] @ 9 b] @ *. - over *. rot !+ swap
    0 a] @ 9 b] @ *. 1 a] @ 7 b] @ *. - 2 a] @ 6 b] @ *. + over *. rot !+ swap
	13 a] @ 1 b] @ *. 14 a] @ 0 b] @ *. - 12 a] @ 3 b] @ *. - over *. rot !+ swap
    8 a] @ 3 b] @ *. 9 a] @ 1 b] @ *. - 10 a] @ 0 b] @ *. + *. swap !	
	;

#matid | matrix id
1.0 0 0 0
0 1.0 0 0
0 0 1.0 0
0 0 0 1.0
#mats * 2560 | 20 matrices
##mat> 'mats

#cox #coy #coz
#six #siy #siz

::matini
	'mat 'matid 16 move ;
	
::matrot | rx ry rz -- ; rotate
	'mat >a
	sincos 'coz ! 'siz !
	sincos 'coy ! 'siy !
	sincos 'cox ! 'six !
    coz coy *. 0 a] ! |'m11 !
    cox siz *. coy *. six siy *. + 1 a] ! |'m12 !
    six siz *. coy *. cox siy *. - 2 a] ! |'m13 !
	siz neg 4 a] ! |'m21 !
    cox coz *. 5 a] ! |'m22 !
    six coz *. 6 a] ! |'m23 !
    coz siy *. 8 a] ! |'m31 !
    cox siz *. siy *. six coy *. - 9 a] ! |'m32 !
    six siz *. siy *. cox coy *. + 10 a] ! |'m33 !
	;

::matpos | x y z -- ; traslate
	swap rot 'mat 14 3 << + !+ !+ ! ;
	
::matscale | x y z -- ; scale
	mat >a
	pick2 a@ *. a!+ pick2 a@ *. a!+ pick2 a@ *. a!+ rot a@ *. a!+
	over a@ *. a!+ over a@ *. a!+ over a@ *. a!+ swap a@ *. a!+
	dup a@ *. a!+ dup a@ *. a!+ dup a@ *. a!+ a@ *. a! ;
	