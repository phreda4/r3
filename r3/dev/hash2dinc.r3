| find collision structure
| hash with x,y
| array in 16bits (max 65535 objects)
| objs in 64bits x,y,..(48)|link(16)
| PHREDA 2024

^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3
^r3/lib/rand.r3
^r3/util/arr16.r3
^r3/util/bfont.r3

#tssprite
#arr 0 0	| array

| 1 2  3   4   5   6   7 8  9  10 
| x y ang zoom img rad h vx vy va 

:.x 1 ncell+ ;
:.y 2 ncell+ ;
:.a 3 ncell+ ;
:.zoom 4 ncell+ ;
:.ani 5 ncell+ ;

:.radio 6 ncell+ ;
:.vx 8 ncell+ ;
:.vy 9 ncell+ ;
:.va 10 ncell+ ;

|------------------------------
| r(10)x(19)y(19)h(16) - 1024|512k|512k|64k
| radio not used .. (24)(24)(16)
| in 3d (16)(16)(16)(16) . with 128bits (1)(21)(21)(21)(16)
|
#arraylen
#matrix	
#matlist

#colist #colist>		| list of collition (16)(16)

::H2d.list	| -- 'adr cnt
	colist colist> over - 2 >>
	;
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
	here 'colist ! | open list!
	;
				
::H2d.clear
	matrix -1 arraylen 2 >> 1 + fill	| fill hashtable with -1
	colist 'colist> !
	;
	
#point  
#cpointx
#cpointy
#cpointr
#maxr 32
#x1 #x2 #y1 #y2
	
:check | xr yr x y point --
	1 + $ffff nand? ( drop ; ) 1 -
	$ffff and dup 3 << matlist + @ 
	dup 16 >> $7ffff and cpointy - abs
	over 35 >> $7ffff and cpointx - abs max
	over 54 >>> cpointr + 
	|2dup "%d %d " .print
	<? ( pick2 point or colist> d!+ 'colist> ! 
		|"*" .println 
		) drop nip
	check ;

:collect | xyrp xr yr 
	over maxr - 5 >> 'x1 ! dup maxr - 5 >> 'y1 !
	over maxr + 5 >> 'x2 ! dup maxr + 5 >> 'y2 !
	pick4 16 << 'point !
	pick3 'cpointr !
	pick2 dup 
	16 >> $7ffff and 'cpointy !
	35 >> $7ffff and 'cpointx !
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

|------------------------------
:hitx over .vx dup @ neg swap ! ;
:hity over .vy dup @ neg swap ! ;

:obj | adr -- adr/adr 0 delete
	dup .vx @ over .x +!
	dup .vy @ over .y +!
	dup .va @ over .a +!
	dup .x @ int. 0 <? ( hitx ) sw >? ( hitx ) drop
	dup .y @ int. 0 <? ( hity ) sh >? ( hity ) drop

	dup 'arr p.nro | nro
	32 |dup .radio @
	pick2 .x @ int. | x 
	pick3 .y @ int. | y
	h2d+!
	
	dup 8 + >a 
	a@+ int. a@+ int. a@+ a@+ 0 a@+ sspriterz 
	drop
	;

:+obj | img zoom ang y x --
	'obj 'arr p!+ >a
	a!+ a!+ a!+ a!+ 
	dup a!+ | img
	SDLimagewh max a!+
	8 a+
	|0 0 0 a!+ a!+ a!+
	0.2 randmax 0.1 - a!+ | vx
	0.2 randmax 0.1 - a!+ | vy	
	0.005 randmax 0.0025 - a!+ | va
	;

#btnpad

|------------------- player tank
:motor | m --
 	a> .a @ 32 >> neg 0.5 + swap polar 
	a> .y +! a> .x +! ;

:turn | a --
	32 << a> .a +! ;

:drawspr | arr -- arr
	dup 'arr p.nro | nro
	32
	pick2 .x @ int.  | x 
	pick3 .y @ int.  | y
	h2d+!	

	dup 8 + >a
	a@+ int. a@+ int. a@+ dup 32 >> swap $ffffffff and | rot zoom
	a@ timer+ dup a!+ anim>n 			| n
	
	a@+ sspriterz
	;
	
:ptank | adr -- adr
	dup >a
	btnpad
	$1 and? ( 0.01 turn )
	$2 and? ( -0.01 turn )
	$4 and? ( -0.4 motor )
	$8 and? ( 0.4 motor )
	$10 and? ( btnpad $10 not and 'btnpad ! )
	drop
	drawspr	
	drop
	;

:+ptank | sheet ani zoom ang x y --
	'ptank 'arr p!+ >a
	swap a!+ a!+	| x y 
	32 << or a!+	| ang zoom
	a!+ a!+			| anim sheet
	0 a!+ 0 a!+ 	| vx vy
	0 a!			| end
	;
|------------------------------
:+randobj
	tssprite 			| img
	2.0 |0.4 randmax 0.1 +	| zoom
	1.0 randmax			| ang
	400.0 randmax 100.0 +	| y
	800.0 randmax 100.0 +		| x 
	+obj ;
	
:insobj | cnt --
	( 1? 1 -
		+randobj
		) drop ;	
	
|------------------------------
:drawrect | nro -- 
	'arr p.adr
	dup .radio @ over .zoom @ 16 *>> | adr radio
	over .x @ int. over 1 >> - 		| adr radio xmin
	rot .y @ int. pick2 1 >> - 	| adr radio ymin ymin
	rot dup SDLREct
	;

:objset 	
	a> 4 - d@ 1 - drawrect ;
	

:drawcl	| o1 o2 --
	'arr p.adr dup .x @ int. swap .y @ int.
	rot 'arr p.adr dup .x @ int. swap .y @ int.
	sdlline
	;

:printmat
	.cr
	0 ( 10 <?
		dup 3 << matlist + @ "%h" .print .cr
		1 + ) drop
	.cr
	matrix 
	0 ( arraylen <? swap
		w@+ "%d " .print
		swap 1+ ) 2drop
	.cr
	;
	
:viewobj | list --
	1 + $ffff nand? ( drop ; ) 1 -
	dup "%h " bprint bcr
	$ffff and 3 << matlist + @
	viewobj ;

:debug
	$ff0000 bcolor
	0 ( sw <?
		0 ( sh <?
			over over over 8 + over 16 + bat
			hash 1 << matrix + w@ 
			+? ( dup "%d" bprint ) drop
			32 + ) drop
		32 + ) drop
		
	$ff00 bcolor
	0 0 bat
|	sdlx sdly hash dup "%h" bprint bcr
|	1 << matrix + w@ viewobj

	colist> colist - 2 >> "%d" bprint bcr
	$ff00 sdlcolor
	colist ( colist> <?
		d@+ |"%h" bprint bcr
		dup 16 >>> swap $ffff and drawcl
		) drop
	;
	
:main
	$0 SDLcls
	
	H2d.clear
	'arr p.draw | calc/draw/hash

	debug
	
	SDLredraw
	
	SDLkey
	>esc< =? ( exit )
	<f1> =? ( +randobj )
	<f2> =? ( printmat )
	| ---- player control	
	<up> =? ( btnpad %1000 or 'btnpad ! )
	<dn> =? ( btnpad %100 or 'btnpad ! )
	<le> =? ( btnpad %10 or 'btnpad ! )
	<ri> =? ( btnpad %1 or 'btnpad ! )
	>up< =? ( btnpad %1000 not and 'btnpad ! )
	>dn< =? ( btnpad %100 not and 'btnpad ! )
	>le< =? ( btnpad %10 not and 'btnpad ! )
	>ri< =? ( btnpad %1 not and 'btnpad ! )
	<esp> =? ( btnpad $10 or 'btnpad ! )	
	drop
	;

|--------------- TEST2
#x2 #y2

:drawhit
	0 0 bat
	H2d.list
	( 1? 1 - swap
		d@+ 
		dup 16 >>> "%d " bprint
		$ffff and "%d " bprint
		bcr
		swap ) 2drop ;
		
:main2
	$0 SDLcls
	
	H2d.clear
	
	300 200 1.0 
	1 8 pick2 *. pick4 pick4 h2d+!
	0 tssprite sspritez

	400 200 2.0 
	2 8 pick2 *. pick4 pick4 h2d+!
	0 tssprite sspritez
	
	600 200 3.0 
	3 8 pick2 *. pick4 pick4 h2d+!
	0 tssprite sspritez

	800 200 4.0 
	4 8 pick2 *. pick4 pick4 h2d+!
	0 tssprite sspritez
	
	x2 y2 2.0 
	0 8 pick2 *. pick4 pick4 h2d+!
	0 tssprite sspritez

	drawhit

	sdlx 'x2 !
	sdly 'y2 !
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	drop
	;
	
:inicio
	.cls
	"hash2d" 1024 600 SDLinit
	16 16 "media/img/tank.png" ssload 'tssprite !
	bfont1
	1000 'arr p.ini
	'arr p.clear
	tssprite 0 0 0 ICS>anim 2.0 0.0 100.0 100.0 +ptank 	
	40 insobj
	
	100 H2d.ini
	
	|'main SDLshow
	'main2 SDLshow
	
	SDLquit ;
	
: inicio ;