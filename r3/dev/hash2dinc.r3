| simple matrix version
| PHREDA 2024
| incremental

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

:.radio 6 ncell+ ;
|:.hi 6 ncell+ ;
:.vx 8 ncell+ ;
:.vy 9 ncell+ ;
:.va 10 ncell+ ;

|------------------------------
| 0..$fffffffe objects
#spacing
#ts
#matrix	
#matlist
#colist
#colist>

:H2d.ini | maxobj spc --
	'spacing !
	dup 1 << nextpow2 1 - 'ts !	
	|..... MEMMAP .....
	here 
	dup 'matrix !
	ts 1 + 2 << + | tablesize (32bits) 0..ts
	dup 'matlist !
	swap 2 << + | max obj
	'here !
	here 'colist ! | open list!
	;
				
:hash | x y -- hash
	|92837111 * swap 689287499 * xor 
	10 << xor
	ts and ;
	
:H2d.clear
	matrix -1 ts 1 >> 1 + fill	| fill hashtable with -1
	colist 'colist> !
	;
	
:H2d.+! | nro hash --
	2 << matrix + dup d@	| nro hash link
	pick2 2 << matlist + d!	| link to prev
	d!			| obj in matrix
	;

|'vector | nro -- ; check and add to colist
:H2d.collect |  nro hash -- nro
	-? ( drop ; )
	dup pick2 32 << or 
|	dup "%h" .println
	colist> !+ 'colist> ! 
	2 << matlist + d@
	H2d.collect ;
	
|-------------------------------------------------
|..... query
:addq | list --
	-? ( drop ; )
	dup 1 + da!+
	2 << matlist + d@
	addq ;
	
#x1 #x2 #y1 #y2					
:qH2d | r x y -- ; here =list
	dup pick3 - spacing >> 'y1 ! pick2 + spacing >> 'y2 !
	dup pick2 - spacing >> 'x1 ! + spacing >> 'x2 !
	here >a
	x1 ( x2 <=? 
		y1 ( y2 <=? 
			2dup hash 
			2 << matrix + d@ addq
			1 + ) drop
		1 + ) drop
	0 da!
	;

:nH2 | 'v r x y --
	here >a ( da@+ 1? 
		1 -	'arr p.nro | r x y adr
		dup .x @ pick3 - dup *. | r x y adr XX
		swap .y @ pick2 - dup *. + | | r x y D2
		pick3 <? ( pick4 ex ) drop | nro : [a> 4 - d@ 1 -]
		) nip 4drop ;

|-- in box
:inbox | 'v r x y adr -- 'v r x y
	dup .x @ pick3 - abs pick4 >? ( 2drop ; ) drop
	.y @ over - abs pick3 >? ( drop ; ) drop
	pick3 ex | nro : [a> 4 - d@ 1 -]
	;
	
:nH2b | 'v r x y --
	here >a ( da@+ 1? 
		1 -	'arr p.nro  | r x y adr
		inbox
		) nip 4drop ;
|-------------------------------------------------

|------------------------------
:hitx over .vx dup @ neg swap ! ;
:hity over .vy dup @ neg swap ! ;

:obj | adr -- adr/adr 0 delete
	dup .vx @ over .x +!
	dup .vy @ over .y +!
	dup .va @ over .a +!
	dup .x @ int. 0 <? ( hitx ) sw >? ( hitx ) drop
	dup .y @ int. 0 <? ( hity ) sh >? ( hity ) drop
		
	dup 8 + >a 
	a@+ int. a@+ int.  | x y

	over 3 >> over 3 >> hash | adr x y hash
	
	pick2 pick2 bat
	dup "%h" bprint
	
	pick3 'arr p.nnow		| adr x y hash nro ; adr list -- nro
	
	over 2 << matrix + d@ H2d.collect		| adr x y hash nro ; nro hash -- nro
	
	swap H2d.+!				| nro hash --
	
	a@+ a@+ 0 a@+ 
	|sspriterz
	4drop 2drop
	drop
	;

:+obj | img zoom ang y x --
	'obj 'arr p!+ >a
	a!+ a!+ a!+ a!+ 
	dup a!+ | img
	SDLimagewh max a!+
	8 a+
	0 0 0 a!+ a!+ a!+
|	0.1 randmax 0.05 - a!+ | vx
|	0.1 randmax 0.05 - a!+ | vy	
|	0.005 randmax 0.0025 - a!+ | va
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
	'arr p.nro
	dup .radio @ over .zoom @ 16 *>> | adr radio
	over .x @ int. over 1 >> - 		| adr radio xmin
	rot .y @ int. pick2 1 >> - 	| adr radio ymin ymin
	rot dup SDLREct
	;

:objset 	
	a> 4 - d@ 1 - drawrect ;
	
:drawcl	| o1 o2 --
	'arr p.nro dup .x @ int. swap .y @ int.
	rot 'arr p.nro dup .x @ int. swap .y @ int.
	sdlline 
	;
	
	
:main
	$0 SDLcls
	
	H2d.clear
	'arr p.draw | calc/draw/hash

	$ff sdlcolor
	colist ( colist> <?
		@+ dup 32 >> swap $ffffffff and drawcl
		) drop
	
	$ff00 sdlcolor	
	sdlx sdly 20 - bat
	sdlx 3 >> sdly 3 >> hash "%h" bprint
	
	SDLredraw
	
	SDLkey
	>esc< =? ( exit )
	<f1> =? ( +randobj )
	drop
	;

:inicio
	.cls
	"hash2d" 1024 600 SDLinit
	16 16 "media/img/tank.png" ssload 'tssprite !
	bfont1
	1000 'arr p.ini
	'arr p.clear
	
	1000 19 H2d.ini | 1000*4 matriz 4.0*4.0 cell
	
	50 insobj
	'main SDLshow
	
	SDLquit ;
	
: inicio ;