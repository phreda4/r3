| find collision structure
| hash with x,y,z
| array in 16bits (max 65535 objects)
| objs in 128bits x,y,z|radio,link(16)

| PHREDA 2026

^r3/lib/mem.r3

#arraylen
#matrix	
#matlist

#H2dlist #H2dlist>		| list of contact (16)(16)

:hash3 | packed -- hash
    -7046029254386353131 *
    arraylen and ;

::pack3 | x y z -- packed
	     $1fffff and 42 <<
	swap $1fffff and 21 << or
	swap $1fffff and or
	;

::getx | val -- x
	43 << 43 >> ;
	
::gety | val -- y
	22 << 43 >> ;
	
::getz | val -- z
	1 << 43 >> ;
	

::H3d.ini | maxobj --
	dup 4 << nextpow2 1- 'arraylen !	
	|..... MEMMAP .....
	here 
	dup 'matrix !	| hash array
	arraylen 1+ 2* + 
	dup 'matlist !	| list objs
	swap 4 << + 	| max obj (128bits)
	'here !
	here 'H2dlist ! | open list!
	;
				
::H3d.clear
	matrix -1 arraylen 2 >> 1+ fill	| fill hashtable with -1
	H2dlist 'H2dlist> ! ;
	
::H3d.list	| -- 'adr cnt
	H2dlist H2dlist> over - 2 >> ;
	
#point  
#cpointx
#cpointy
#cpointz
#cpointr
##checkmax 32	| check max in pixels
#x1 #x2 #y1 #y2 #z1 #z2
	
:21dif | v1 v2 -- val ; aprox
    - dup 20 >> $40000200001 and $1fffff * 
    swap over xor swap -
    dup 42 >> or dup 21 >> or $1fffff and ;
		
:check | xyz point --
	1+ $ffff nand? ( drop ; ) 1-
	$ffff and dup 4 << matlist + @ 
	pick4 21dif
|	pick4 <? ( 2over db!+ ) 
	check ;
	
:chkA dup hash3 2* matrix + w@ check ;
	
:linA chkA $1 + chkA $1 + chkA $200000 $2 - + ;

:boxA linA linA linA $40000000000 $600000 - + ;

::collect | nro r xyrp -- nro r xyrp --
	dup $40000200001 - | x-1,y-1,z-1
	boxA boxA boxA 
	drop
	;
	
| xyz-id|rad|idp
::h3d+! | id r x y z -- 
	pack3	| id r xyz
	collect	| id r xyz
	|swap >r | id xyz
	nip
	|rot 32 << rot $ffff and 16 << or rot | idr xyz
	dup hash3	| id xyz cell
	2* matrix + dup >r w@	| id xyz prev
	
	swap pick2 4 << matlist + !+ !
	r> w!
	;

::h3d! | x y zoom nro sizepixel/2 -- x y zoom 
|	400 200 2.0 2 8 
	pick2 *. pick4 pick4 h3d+! ;
	
::ldebug
	matrix 
	arraylen ( 1? 1- swap
		w@+ "%d " .print
		swap ) 2drop
	.cr
	matlist
	arraylen ( 1? 1- swap
		@+ "%d:" .print
		@+ "%d " .print
		swap ) 2drop 
	"" .println
	;
