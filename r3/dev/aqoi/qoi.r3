| qoi encoder/decoder
| PHREDA 2021
^r3/lib/math.r3

| QOI_INDEX   0x00 // 00xxxxxx
| QOI_RUN_8   0x40 // 010xxxxx
| QOI_RUN_16  0x60 // 011xxxxx
| QOI_DIFF_8  0x80 // 10xxxxxx
| QOI_DIFF_16 0xc0 // 110xxxxx
| QOI_DIFF_24 0xe0 // 1110xxxx
| QOI_COLOR   0xf0 // 1111xxxx

#px
#qmagic $66696f71 | fioq
##qw ##qh
#qsize
#run 

#index * 256 | 64 rgba values

:hash | color -- hash
	dup 16 >> xor dup 8 >> xor $3f and ;
	
:hasha | color -- adr
	hash 2 << 'index + ;
	
:hashclear
	'index 0 32 fill ;

:runlen | cnt -- 
	( 1? 1 - px db!+ ) drop ;

:img!+ | px --
	dup dup hasha d! db!+ ;

:diff8 | val --
	dup 4 >> $3 and 1 - 'px 2 + c+!
	dup 2 >> $3 and 1 - 'px 1 + c+!
	$3 and 1 - 			'px 0 + c+! 
	px img!+ ;
	
:diff16 | val --
	$1f and 15 - 		'px 2 + c+! 
	ca@+ dup 4 >> 7 - 	'px 1 + c+!
	$f and 7 - 			'px 0 + c+! 
	px img!+ ;

:diff24 | val --
	$f and 1 << ca@+ dup 7 >> $1 and rot or 15 - 	'px 2 + c+! | red
	dup $7c and 2 >> 15 - 							'px 1 + c+! | green
	$3 and 3 << ca@+ dup $e0 and 5 >> rot or 15 - 	'px 0 + c+! | blue
	$1f and 15 - 									'px 3 + c+! | alpha
	px img!+ ;
	
:decode | token -- px
	ca@+
	$c0 nand? ( 					| 00.. index
		2 << 'index + d@ $ffffffff and dup 'px ! db!+ ; ) 
	$80 nand? (						| 01..
		$20 nand? ( $1f and 1 + runlen ; ) 				| 010. run 8
		$1f and 8 << ca@+ $ff and or 33 + runlen ; )	| 011. run 16
	$40 nand? ( diff8 ; )			| 10.. diff 8
	$20 nand? ( diff16 ; )			| 110. diff 16
	$10 nand? ( diff24 ; )			| 1110 diff 24
	$8 and? ( ca@+ 'px 2 + c! ) 
	$4 and? ( ca@+ 'px 1 + c! )
	$2 and? ( ca@+ 'px 0 + c! )
	$1 and? ( ca@+ 'px 3 + c! )
	drop
	px img!+ ;


::qoi_decode | bitmap data -- 1/0
	d@+ drop | qmagic <>? ( drop 0 ; )
	w@+ 'qw !
	w@+ 'qh !
	d@+ 'qsize !
	>a >b
	hashclear
	$ff000000 'px !
	qsize a> +
	( a> >? decode ) ;
	
|------ encode stat

##cntINDEX
##cntRUN8
##cntRUN16
##cntDIFF8
##cntDIFF16
##cntDIFF24
##cntDIFF

:encoderun | run --
	33 <? ( 1 - $40 or ca!+ 0 'run ! 
		1 'cntRUN8 +! ; )
	33 - dup 8 >> $60 or ca!+ ca!+ 
	0 'run !
	1 'cntRUN16 +!
	;

:runencode | px -- px
	run $2020 =? ( encoderun ; ) drop ;

#vr #vg #vb #va

:getdiff
	dup dup hasha d! px	
	over $ff and over $ff and - 'vr !
	over 8 >> $ff and over 8 >> $ff and - 'vg !
	over 16 >> $ff and over 16 >> $ff and - 'vb !
	over 24 >> $ff and swap 24 >> $ff and - 'va !

	vr -15 16 between -? ( ; ) drop
	vg -15 16 between -? ( ; ) drop
	vb -15 16 between -? ( ; ) drop
	va -15 16 between -? ( ; ) drop
	
	vr -1 2 between
	vg -1 2 between or
	vb -1 2 between or
	63 >> va or
	0? ( drop	| ..rrggbb
		vr 1 + 4 << 
		vg 1 + 2 << or
		vb 1 + or
		$80 or ca!+ 
		1 'cntDIFF8 +! 
		0 ; ) drop
	
	vr -15 16 between
	vg -7 8 between or
	vb -7 8 between or
	63 >> va or
	0? ( drop | ...rrrrr ggggbbbb
		vr 15 + $c0 or ca!+
		vg 7 + 4 << 
		vb 7 + or ca!+
		1 'cntDIFF16 +! 
		0 ; ) drop

	| ....rrrr rgggggbb bbbaaaaa
	vr 15 + dup 
	1 >> $e0 or ca!+
	7 << 
	vg 15 + 2 << or
	vb 15 + 3 >> or ca!+
	vb 15 + 5 <<
	va 15 + or ca!+
	1 'cntDIFF24 +!
	0 ;
	
:encode | 
	px =? ( 1 'run +! runencode ; )
	run 1? ( dup encoderun ) drop
	dup hasha d@ $ffffffff and 
	=? ( dup hash ca!+ 1 'cntINDEX +! ; )  		| INDEX=0
	getdiff 0? ( drop ; ) drop
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
	1 'cntDIFF +!
	;
	
::qoi_encode | bitmap w h data -- size
	0 'cntINDEX !
	0 'cntRUN8 !
	0 'cntRUN16 !
	0 'cntDIFF8 !
	0 'cntDIFF16 !
	0 'cntDIFF24 !
	0 'cntDIFF !

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
