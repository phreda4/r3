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

#index * 256 | 64 rgba values

:chash! | v px --
	dup 16 >> xor dup 8 >> xor $3f and 2 << 'index + !	;
	
:chash@ | px -- v
	dup 16 >> xor dup 8 >> xor $3f and 2 << 'index + @	;
	
:chashclear
	'index >a 32 ( 1? 1 - 0 a!+ ) drop ;
	
#px

:runlen | cnt -- 
	( 1? 1 - px a!+ ) drop ;

:img!+ | px --
	dup chash! b!+ ;

:diff8 | val --
	dup 4 >> $3 and 1 - 'px c+!
	dup 2 >> $3 and 1 - 'px 1 + c+!
	$3 and 1 - 			'px 2 + c+! 
	px img!+
	;
	
:diff16 | val --
	$1f and 15 - 		'px c+! 
	ca@+ dup 4 >> 7 - 	'px 1 + c+!
	$f and 7 - 			'px 2 + c+! 
	px img!+
	;

:diff24 | val --
	$f and 1 << ca@+ dup 7 >> $1 and rot or 15 - 	'px c+! |red
	dup $7c and 2 >> 15 - 							'px 1 + c+! | green
	$3 and 3 << ca@+ dup $e0 and 5 >> rot or 15 - 	'px 2 + c+! | blue
	$1f and 15 - 									'px 3 + c+! | alpha
	px img!+
	;
	
:decode | token -- px
	ca@+
	$c0 nand? ( $3f and 2 << 'index + d@ dup 'px ! img!+ ; ) | index
	
	$80 nand? (
		$20 nand? ( $1f and runlen ; ) 				| run 8
		$1f and 8 << ca@+ $ff and or 32 + runlen ;	| run 16
		)
	
|	dup $e0 and 
|	$40 =? ( drop $1f and runlen ; ) | run 8
|	$60 =? ( drop $1f and 8 << ca@+ $ff and or 32 + runlen ; ) | run 16
|	drop

	$80 nand? ( diff8 ; )			| diff 8
	$40 nand? ( diff16 ; )			| diff 16
	$20 nand? ( diff24 ; )			| diff 24
	$8 and? ( ca@+ $ff and 'px c! ) 
	$4 and? ( ca@+ $ff and 'px 1 + c! )
	$2 and? ( ca@+ $ff and 'px 2 + c! )
	$1 and? ( ca@+ $ff and 'px 3 + c! )
	drop
	px img!+
	;

#qmagic "qoif"
#qw #qh
#qsize

::qoi_decode | bitmap data -- 1/0
	d@+ qmagic <>? ( drop 0 ; )
	w@+ 'qw !
	w@+ 'qh !
	d@+ 'qsize !
	>a >b
	chashclear
	$ff000000 'px !
	qw qh * 2 << b> +
	( b> <? decode ) drop 1 ;
	
|------ encode
#run 
#pxprev	| for encode
	
:encoderun
	33 <? ( 1 - $40 or ca!+ 0 'run ! ; )
	33 - dup 8 >> $60 or ca!+ ca!+ 
	;
	
:runlen | run --
	$2020 =? ( encoderun ; )
	over 0? ( drop encoderun ; ) drop
	px pxprev <>? ( drop encoderun ; ) drop 
	drop
	;
	
#vr #vg #vb #va

:getdiff
	px pxprev
	over $ff and over $ff and - 'vr !
	over 8 >> $ff and over 8 >> $ff and - 'vg !
	over 16 >> $ff and over 16 >> $ff and - 'vb !
	swap 24 >> $ff and swap 24 >> $ff and - 'va !
	vr -16 17 between -? ( ; ) drop
	vg -16 17 between -? ( ; ) drop
	vb -16 17 between -? ( ; ) drop
	va -16 17 between -? ( ; ) drop
	
	va 6 <<
	vr 1 + 4 << or
	vg 1 + 2 << or
	vb 1 + or
	$c0 nand? ( $80 or ca!+ 0 ; ) drop
	
	va 11 << 
	vr 15 + 8 << or
	vg 7 + 4 << or
	vb 7 + or
	$e000 nand? ( dup 8 >> $c0 or ca!+ ca!+ 0 ; ) drop

	vr 15 + dup 
	1 >> $e0 or ca!+
	1 and 7 << 
	vg 15 + 2 << or
	vb 15 + 3 >> or ca!+
	vb 15 + $7 and 5 <<
	va 15 + or ca!+
	0 ;
	
:encode | 
	px pxprev =? ( 1 'run +! ) drop
	run 1? ( runlen ; ) drop
	px chash@ px =? ( ca!+ ; ) drop | INDEX=0
	getdiff 1? ( drop ; ) drop
	0 
	vr 1? ( swap 8 or swap )
	vg 1? ( swap 4 or swap )
	vb 1? ( swap 2 or swap )
	va 1? ( swap 1 or swap )
	$f0 or ca!+
	vr 1? ( px ca!+ ) drop
	vg 1? ( px 8 >> ca!+ ) drop
	vb 1? ( px 16 >> ca!+ ) drop
	va 1? ( px 24 >> ca!+ ) drop
	;
	
::qoi_ecode | bitmap x y data -- size
	>a 'qh ! 'qw !
	qmagic da!+
	qw qh 16 << da!+ 
	a> 'qsize ! | where size
	0 da!+
	chashclear
	0 'run !
	$ff00000 dup 'px ! 'pxprev !
	>b |  bitmap
	qh qw * ( 1? 1 -
		db@+ 'px !
		encode
		px 'pxprev !
		) drop  
	a> qsize - 8 + dup 'qsize d!
	;
	