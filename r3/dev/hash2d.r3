| try speed up collision from
| Copyright 2022 Matthias Müller - Ten Minute Physics
| https://github.com/matthias-research/pages/blob/master/tenMinutePhysics/11-hashing.html
| but 2d
| PHREDA 2023

^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3
^r3/lib/rand.r3
^r3/util/arr16.r3
|^r3/util/bfont.r3


#spr_ball
#arr 0 0	| array

| 0 1  2    3   4  5   6  7  8  9 10   11    12		13
| x y ang zoom img rad h vx vy va hash

:.x  ;
:.y 1 ncell+ ;
:.a 2 ncell+ ;
:.zoom 3 ncell+ ;

:.radio 5 ncell+ ;
|:.hi 6 ncell+ ;
:.vx 7 ncell+ ;
:.vy 8 ncell+ ;
:.va 9 ncell+ ;
:.hash 10 ncell+ ;

|------------------------------
#spacing
#maxNumObjects
#ts
#cellStart
#cellEntries

:iniHash2d | maxobj spc --
	'spacing !
	dup 'maxNumObjects !
	nextpow2 1 - 'ts !

	here 
	dup 'cellEntries !
	maxNumObjects 1 << + | maxNumObjects (16bits)
	dup 'cellStart !
	ts 2 + 1 << + | tablesize+1 (16bits)
	'here !
	;
				
:hashCoord | x y -- hash
	92837111 * swap 689287499 * xor ts and ;
	
:buildH2d | 'arr --
	cellStart 0 ts 2 + 1 << cfill
	cellEntries 0 maxNumObjects 1 << cfill
	
	'arr 8 + @
	'arr p.cnt
	( 1? swap
		1 over 8 + .hash @ 1 << cellStart + +!
		128 + swap 1 - ) 2drop
	
	0 cellStart 
	ts 1 + ( 1? >r
		dup w@ | start cellstart cnt
		rot + | cellstart start 
		dup rot | start start cellstart 
		w!+
		r> 1 - ) drop
	w!

	'arr 8 + @
	'arr p.cnt
	( 1? swap
		dup 8 + .hash @ 1 << cellStart + 
		-1 over w+!
		w@ 1 << cellEntries + 
		pick2 swap w!
		128 + swap 1 - ) 2drop
	;
	
:qq | fromcs tocs --
	swap ( over <?
		dup 1 << cellEntries + w@ ,
		1 + ) 2drop ;
					
#x1 #x2 #y1 #y2					
:qH2d | r x y -- ; here =list
	dup pick3 - spacing >> 'y1 ! pick2 + spacing >> 'y2 !
	dup pick2 - spacing >> 'x1 ! + spacing >> 'x2 !
	mark
	y1 ( y2 <=? 
		x1 ( x2 <=? 
			2dup hashCoord 1 << cellStart +
			w@+ swap w@ | from to
			qq
			1 + ) drop
		1 + ) drop
	0 ,
	empty
	;
	

|------------------------------

:hitx over .vx dup @ neg swap ! ;
:hity over .vy dup @ neg swap ! ;

:obj | adr -- adr/adr 0 delete
 	dup 
	dup .vx @ over .x +!
	dup .vy @ over .y +!
	dup .va @ over .a +!
	dup .x @ int. 0 <? ( hitx ) sw >? ( hitx ) drop
	dup .y @ int. 0 <? ( hity ) sh >? ( hity ) drop
		
	>a 
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
	0.9 randmax a!+ | vx
	0.9 randmax a!+ | vy	
	0.1 randmax 0.05 - a!+ | va
	;

|------------------------------
:+randobj
	spr_ball 			| img
	0.4 randmax 0.1 +	| zoom
	1.0 randmax			| ang
	600.0 randmax 		| y
	1024.0 randmax		| x 
	+obj ;
	
:insobj
	10 ( 1? 1 -
		+randobj
		) drop ;	
	
|------------------------------
:.dumpdebug
	.cls
	[ dup 8 + .hash @ "%h " .print ; ] 'arr p.mapv .cr
	cellStart 
	ts 1 + ( 1? 
		swap w@+ "%h " .print | start cellstart cnt
		swap 1 - ) 2drop .cr
	
	cellEntries
	'arr p.cnt
	( 1? swap
		w@+ "%h " .print 
		swap 1 - ) 2drop
	.cr
	;

:drawrect | nro -- 
	
	'arr p.nro 8 +
	dup .radio @ over .zoom @ 16 *>> | radio
	over .x @ int. over 1 + 1 >> - 		| radio xmin
	pick2 .y @ int. pick2 1 + 1 >> - 	| radio ymin ymin
	rot dup SDLFREct
	
	;
	
:main
	$0 SDLcls
	'arr p.draw
	
	buildH2d	
	.dumpdebug

	3.0 sdlx 16 << sdly 16 << qH2d
	
	$ffffff sdlcolor
	here ( d@+ 1? 
		drawrect drop
		) 2drop
		
	SDLredraw
	
	SDLkey
	>esc< =? ( exit )
	<f1> =? ( +randobj )
	drop
	;

:inicio
	"hash2d" 1024 600 SDLinit
	"media/img/ball.png" loadimg 'spr_ball !
	100 'arr p.ini
	'arr p.clear
	100 19 iniHash2d
	insobj

	'main SDLshow
	
	SDLquit ;
	
: inicio ;