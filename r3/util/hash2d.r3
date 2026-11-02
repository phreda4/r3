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
^r3/lib/mem.r3

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

::H2d.ini | maxobj -- ; reserve at here the hash table, the object list and the contact list for up to maxobj objects (ids 0..65534)
	dup 4 << nextpow2 1- 'arraylen !	
	|..... MEMMAP .....
	here 
	dup 'matrix !	| hash array
	arraylen 1+ 1 << + 
	dup 'matlist !	| list objs
	swap 3 << + 	| max obj
	'here !
	here 'H2dlist ! | open list!
	;
				
::H2d.clear | -- ; empty the hash table and the contact list (call it every frame before adding the objects)
	matrix -1 arraylen 2 >> 1+ fill	| fill hashtable with -1
	H2dlist 'H2dlist> ! ;
	
::H2d.list | -- 'adr cnt ; list of contacts found: cnt dwords, each (newer object nro << 16) | older object nro
	H2dlist H2dlist> over - 2 >> ;
	
#point  
#cpointx
#cpointy
#cpointr
##checkmax 32 | maximum distance in pixels where the neighbours are looked for (the hash cells are 32 pixels)
#x1 #x2 #y1 #y2
	
	
:gety | val --y
	16 >> $7ffff and ; | 29 << 45 >>
	
:getx | val --x
	35 >> $7ffff and ; | 10 << 45 >>
	
:check | xr yr x y point --
	1+ $ffff nand? ( drop ; ) 1-
	$ffff and dup 3 << matlist + @ 
	dup gety cpointy - abs
	over getx cpointx - abs max
	over 54 >>> cpointr + | getr
	<? ( pick2 point or H2dlist> d!+ 'H2dlist> ! ) drop nip
	check ;

:collect | xyrp xr yr 
	over checkmax - 5 >> 'x1 ! dup checkmax - 5 >> 'y1 !
	over checkmax + 5 >> 'x2 ! dup checkmax + 5 >> 'y2 !
	pick4 16 << 'point !
	pick3 'cpointr !
	pick2 dup 
	gety 'cpointy !
	getx 'cpointx !	
	x1 ( x2 <=? 
		y1 ( y2 <=? 
			2dup hash2 
			1 << matrix + w@ | nro 
			check
			1 + ) drop
		1 + ) drop ;

::h2d+! | nro r x y -- ; add object nro (0..65534) with radius r (0..1023) at x y (pixels, 19 bits) and add to the list its contacts with the objects already added (square test: max(|dx|,|dy|) < r1 + r2)
	$7ffff and dup 16 <<		| nro r x yr yrp
	rot $7ffff and dup 35 << 	| nro r yr yrp xr xrp
	rot or -rot swap			| nro r xyrp xr yr
	collect	hash				| nro r xyrp hash
	rot $3ff and 54 <<			| nro xyrp hash rp
	rot or 						| nro hash rxyp --
	swap 1 << matrix + dup w@	| nro rxhp phash ninhash
	$ffff and rot or 			| nro phash rxhph
	pick2 3 << matlist + !
	w!
	;

::h2d! | x y zoom nro size -- x y zoom ; add object nro at x y with the radius size*zoom (zoom fixed point) and leave x y zoom
|	400 200 2.0 2 8 
	pick2 *. pick4 pick4 h2d+! ;
