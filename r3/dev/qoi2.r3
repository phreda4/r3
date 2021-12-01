| qoi variation encoder/decoder 
| PHREDA 2021
^r3/lib/math.r3

#qmagic $66696f71 | fioq

#px
##qw ##qh
#qsize
#run 

#index * 512 | 128 rgba values

:hash | color -- hash
	dup 14 >> xor dup 7 >> xor $7f and ;

:hasha | color -- adr
	hash 2 << 'index + ;
	
:hashclear | --
	'index 0 64 fill ;

:runlen | cnt -- 
	( 1? 1 - px db!+ ) drop ;

:img!+ | --
	px dup dup hasha d! db!+ ;
	
:diff16 | val --
	$1f and 15 - 		'px 2 + c+! 
	ca@+ dup 4 >> 7 - 	'px 1 + c+!
	$f and 7 - 			'px c+! 
	img!+ ;

:diff24 | val --
	$f and 1 << ca@+ dup 7 >> $1 and rot or 15 - 	'px 2 + c+! 	| red
	dup $7c and 2 >> 15 - 							'px 1 + c+! | green
	$3 and 3 << ca@+ dup $e0 and 5 >> rot or 15 - 	'px c+! | blue
	$1f and 15 - 									'px 3 + c+! | alpha
	img!+ ;
	
:decode | -- 
	ca@+
	$80 nand? ( 2 << 'index + d@ $ffffffff and dup 'px ! db!+ ; ) 	| 0.......
	$40 nand? (	$3f and 1 + runlen ; )								| 10......
	$20 nand? ( diff16 ; )											| 110..... diff 16
	$10 nand? ( diff24 ; )											| 1110.... diff 24
	$8 and? ( ca@+ 'px 2 + c! ) 
	$4 and? ( ca@+ 'px 1 + c! )
	$2 and? ( ca@+ 'px c! )
	$1 and? ( ca@+ 'px 3 + c! )
	drop
	img!+ ;

::qoi_decode2 | bitmap data -- 1/0
	d@+ drop | qmagic <>? ( drop 0 ; )
	w@+ 'qw !
	w@+ 'qh !
	d@+ 'qsize !
	>a >b
	hashclear
	$ff000000 'px !
	qsize a> +
	( a> >? decode ) ;
	
|------ encode
:encoderun | run --
	1 - $80 or ca!+ 
	0 'run ! ; 

:runencode | -- 
	run 64 =? ( encoderun ; ) drop ;

#vr #vg #vb #va

:encode | pixel -- pixel
	px =? ( 1 'run +! runencode ; )
	run 1? ( dup encoderun ) drop
	
	dup hasha d@ $ffffffff and 
	=? ( dup hash ca!+ ; )  		| INDEX=0
	
	dup dup hasha d! px	
	
	over $ff and over $ff and - 'vr !
	over 8 >> $ff and over 8 >> $ff and - 'vg !
	over 16 >> $ff and over 16 >> $ff and - 'vb !
	over 24 >> $ff and swap 24 >> $ff and - 'va ! 
	
	vr -15 16 between
	vg -7 8 between or
	vb -7 8 between or
	63 >> va or
	0? ( drop | ...rrrrr ggggbbbb
		vr 15 + $c0 or ca!+
		vg 7 + 4 << vb 7 + or ca!+ ; ) drop

	vr -15 16 between 
	vg -15 16 between or
	vb -15 16 between or
	va -15 16 between or
	63 >> va or
	0? ( drop | ....rrrr rgggggbb bbbaaaaa
		vr 15 + dup 1 >> $e0 or ca!+
		7 << vg 15 + 2 << or vb 15 + 3 >> or ca!+
		vb 15 + 5 << va 15 + or ca!+ ; ) drop

	$f0 
	vr 1? ( swap 8 or swap ) drop
	vg 1? ( swap 4 or swap ) drop
	vb 1? ( swap 2 or swap ) drop
	va 1? ( swap 1 or swap ) drop
	ca!+
	vr 1? ( over ca!+ ) drop
	vg 1? ( over 8 >> ca!+ ) drop
	vb 1? ( over 16 >> ca!+ ) drop
	va 1? ( over 24 >> ca!+ ) drop
	;
	
::qoi_encode2 | bitmap w h data -- size
	>a 'qh ! 'qw !
	qmagic da!+
	qw qh 16 << or da!+ 
	a> 'qsize ! | where size
	0 da!+
	hashclear
	0 'run !
	$ff000000 'px !
	qh qw * ( 1? 1 - swap
		d@+ $ffffffff and
		encode
		'px ! 
		swap ) 2drop  
	run 1? ( dup encoderun ) drop
	a> qsize - dup qsize d!
	;
