| find collision structure
| hash with x,y
| array in 16bits (max 65535 objects)
| objs in 64bits x,y,..(48)|link(16)
| PHREDA 2024

|------------------------------
| r(10)x(19)y(19)h(16) - 1024|512k|512k|64k
| radio not used .. (24)(24)(16)
| in 3d (16)(16)(16)(16) . with 128bits (1)(21)(21)(21)(16)
|
#arraylen
#matrix	
#matlist

#H2dlist #H2dlist>		| list of contact (16)(16)

:hash | x y -- hash
	5 >> 92837111 * swap 
	5 >> 689287499 * xor 
	arraylen and ;
	
:hash2 | x y -- hash
	92837111 * swap 
	689287499 * xor 
	arraylen and ;

::H2d.ini | maxobj --
	dup 4 << nextpow2 1 - 'arraylen !	
	|..... MEMMAP .....
	here 
	dup 'matrix !	| hash array
	arraylen 1 + 1 << + 
	dup 'matlist !	| list objs
	swap 3 << + 	| max obj
	'here !
	here 'H2dlist ! | open list!
	;
				
::H2d.clear
	matrix -1 arraylen 2 >> 1 + fill	| fill hashtable with -1
	H2dlist 'H2dlist> !
	;
	
::H2d.list	| -- 'adr cnt
	H2dlist H2dlist> over - 2 >>
	;
	
#point  
#cpoint
#maxr 32
#x1 #x2 #y1 #y2
	
:check | xr yr x y point --
	1 + $ffff nand? ( drop ; ) 1 -
	$ffff and dup 3 << matlist + @ 
	dup 16 >> $7ffff and cpoint 16 >> $7ffff and - abs
	over 35 >> $7ffff and cpoint 35 >> $7ffff and - abs max
	maxr <? ( pick2 point or H2dlist> d!+ 'H2dlist> ! ) drop nip
	check ;

:collect | xyrp xr yr 
	over maxr - 5 >> 'x1 ! dup maxr - 5 >> 'y1 !
	over maxr + 5 >> 'x2 ! dup maxr + 5 >> 'y2 !
	pick4 16 << 'point !
	pick2 'cpoint !
	x1 ( x2 <=? 
		y1 ( y2 <=? 
			2dup hash2 
			1 << matrix + w@ | nro 
			check
			1 + ) drop
		1 + ) drop ;

::h2d+! | nro r x y -- 
	$7ffff and dup 16 <<		| nro r x yr yrp
	rot $7ffff and dup 35 << 	| nro r yr yrp xr xrp
	rot or rot rot swap			| nro r xyrp xr yr
	collect	hash				| nro r xyrp hash
	rot $3ff and 54 <<			| nro xyrp hash rp
	rot or 						| nro hash rxyp --
	swap 1 << matrix + dup w@	| nro rxhp phash ninhash
	$ffff and rot or 			| nro phash rxhph
	pick2 3 << matlist + !
	w!
	;

