| try speed up collision from
| Copyright 2022 Matthias Müller - Ten Minute Physics
| https://github.com/matthias-research/pages/blob/master/tenMinutePhysics/11-hashing.html
| but 2d
| simple matrix version
| PHREDA 2024

^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3
^r3/lib/rand.r3
^r3/util/arr16.r3
^r3/util/bfont.r3

#spr_ball
#arr 0 0	| array

| 1 2  3   4   5   6   7 8  9  10 11    
| x y ang zoom img rad h vx vy va hash

:.x 1 ncell+ ;
:.y 2 ncell+ ;
:.a 3 ncell+ ;
:.zoom 4 ncell+ ;

:.radio 6 ncell+ ;
|:.hi 6 ncell+ ;
:.vx 8 ncell+ ;
:.vy 9 ncell+ ;
:.va 10 ncell+ ;
:.hash 11 ncell+ ;

|------------------------------
#spacing
#ts
#matrix
#matlist

:iniHash2d | maxobj spc --
	'spacing !
	dup 1 << nextpow2 1 - 'ts !	
	|..... MEMMAP .....
	here 
	dup 'matrix !
	ts 1 << + | tablesize (16bits)
	dup 'matlist !
	swap 1 << + | max obj
	'here !
	;
				
:hashCoord | x y -- hash
	92837111 * swap 689287499 * 
	xor ts and ;
	
:addlist | nro hash -- nro
	dup 1 << matrix + w@	| nro hash link
	pick2 1 << matlist + w!	| link to prev
	over swap 1 << matrix + w!
	;
	
:buildH2d | 'arr --
	matrix -1 ts 2 >> 1 + fill	| fill hashtable with 0
	'arr p.cnt	
	0 ( over <?
		dup 'arr p.nro .hash @ | nro hash 
		
		addlist | nro hash -- nro
		1 + ) 2drop ;
	
|..... query

:addq | list --
	-? ( drop ; )
	dup 1 + da!+
	1 << matlist + w@
	addq ;
	
#x1 #x2 #y1 #y2					
:qH2d | r x y -- ; here =list
	dup pick3 - spacing >> 'y1 ! pick2 + spacing >> 'y2 !
	dup pick2 - spacing >> 'x1 ! + spacing >> 'x2 !
	here >a
	x1 ( x2 <=? 
		y1 ( y2 <=? 
			2dup hashCoord 
			1 << matrix + w@ addq
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
	over 3 >> over 3 >> hashCoord pick3 .hash ! | set hash
	a@+ a@+ a@+ SDLspriteRZ | x y ang zoom img --

	drop
	;

:+obj | img zoom ang y x --
	'obj 'arr p!+ >a
	a!+ a!+ a!+ a!+ 
	dup a!+ | img
	SDLimagewh max a!+
	8 a+
	1.9 randmax a!+ | vx
	1.9 randmax a!+ | vy	
	0.05 randmax 0.025 - a!+ | va
	;

|------------------------------
:+randobj
	spr_ball 			| img
	0.5 |0.4 randmax 0.1 +	| zoom
	1.0 randmax			| ang
	600.0 randmax 		| y
	1024.0 randmax		| x 
	+obj ;
	
:insobj
	800 ( 1? 1 -
		+randobj
		) drop ;	
	
|------------------------------
:.dumpdebug
	.home
	[ dup .hash @ "%h " .print ; ] 'arr p.mapv .eline .cr
	
	matrix 
	ts ( 1? 
		swap w@+ "%d " .print | start cellstart cnt
		swap 1 - ) 2drop .eline .cr
	
	matlist
	'arr p.cnt 
	( 1? swap
		w@+ "%d " .print 
		swap 1 - ) 2drop
	.eline .cr
	;

:drawrect | nro -- 
	'arr p.nro
	dup .radio @ over .zoom @ 16 *>> | adr radio
	over .x @ int. over 1 >> - 		| adr radio xmin
	rot .y @ int. pick2 1 >> - 	| adr radio ymin ymin
	rot dup SDLREct
	;

:objset 	
	a> 4 - d@ 1 - drawrect ;
	
	
:main
	$0 SDLcls
	'arr p.draw | calc/draw/hash
	
	buildH2d
|	.cls .dumpdebug

	30.0 sdlx 16 << sdly 16 << qH2d

	$ffffff sdlcolor
|	'objset 900.0 sdlx 16 << sdly 16 << nH2
	'objset 30.0 sdlx 16 << sdly 16 << nH2b

|	here ( d@+ 1? 1 - drawrect ) 2drop
		
	SDLredraw
	
	SDLkey
	>esc< =? ( exit )
	<f1> =? ( +randobj )
	drop
	;

:inicio
	"hash2d" 1024 600 SDLinit
	"media/img/ball.png" loadimg 'spr_ball !
	bfont1
	1000 'arr p.ini
	'arr p.clear
	1000 19 iniHash2d
	insobj
	.cls
	'main SDLshow
	
	SDLquit ;
	
: inicio ;