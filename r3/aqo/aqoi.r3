| Almost Quite OK Image Formatfcnt
| PHREDA 2021
| from qoi - https://github.com/phoboslab/qoi
| qoi variation + simple repeat sequencer encoder/decoder 
| format:
| 0	xxxxxxx index haash
| 10 xxxxxx luma16 0..63 : -32..31 : -16...47
| 110 xxxxx luma16d 0..32 : -16..15 : -48..-17
| 1110 xxxx run 0..15 (1..16)
| 1111 xxxx pixel argb

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

:luma16 | val -- | ..gggggg rrrrbbbb
	$3f and 16 - ca@+
	2dup 4 >> $f and + 8 -	'px 2 + c+! | r
	over 					'px 1 + c+! | g
	$f and + 8 - 			'px c+! 	| b
	img!+ ;

:luma16d | val -- | ...ggggg rrrrbbbb
	$3f and 48 - ca@+
	2dup 4 >> $f and + 7 -	'px 2 + c+! | r
	over 					'px 1 + c+! | g
	$f and + 7 - 			'px c+! 	| b
	img!+ ;

:decode | -- 
	ca@+
	$80 nand? ( 2 << 'index + d@ $ffffffff and dup 'px ! db!+ ; ) 	| 0....... index
	$40 nand? ( luma16 ; )											| 10...... luma16	
	$20 nand? (	luma16d ; )											| 110..... luma16d
	$10 nand? ( $f and 1 + runlen ; )								| 1110.... runlen
	$8 and? ( ca@+ 'px c! ) 										| 1111.... pixel
	$4 and? ( ca@+ 'px 1 + c! )
	$2 and? ( ca@+ 'px 2 + c! )
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
##cntINDEX
##cntRUN
##cntLUMA
##cntXOR
#cntRGB
##cntARGB1
##cntARGB2
##cntARGB3
##cntARGB4

:encoderun | run --
	1 'cntRUN +!
	
	1 - $e0	or ca!+ 0 'run ! ; 

:runencode | -- 
	run 16 =? ( encoderun ; ) drop ;

#vr #vg #vb #va
#vgr #vgb

:encode | pixel -- pixel
	px =? ( 1 'run +! runencode ; )
	run 1? ( dup encoderun ) drop
	dup hasha d@ $ffffffff and 
	=? ( dup hash ca!+ 1 'cntINDEX +! ; )  		| INDEX=0
	dup dup hasha d! 
	px
	over $ff and over $ff and - 'vb !
	over 8 >> $ff and over 8 >> $ff and - 'vg !
	over 16 >> $ff and over 16 >> $ff and - 'vr !
	over 24 >> $ff and over 24 >> $ff and - 'va !
	vr vg - 'vgr !
	vb vg - 'vgb !
	drop
	
| 10 xxxxxx luma16 0..63 : -32..31 : -16...47
	vgr -8 7 between vg -16 47 between or vgb -8 7 between or 63 >> va or
	0? ( drop 
		1 'cntLuma +!
		
		vg 16 + $80	or ca!+ vgr 8 + 4 << vgb 8 + or ca!+
		; ) drop
		
| 110 xxxxx luma16 0..32 : -16..15 : -48..-17
	vgr -7 8 between vg -48 -17 between or vgb -7 8 between or 63 >> va or
	0? ( drop 
		1 'cntXOR +!
		
		vg 48 + $c0	or ca!+ vgr 7 + 4 << vgb 7 + or ca!+
		; ) drop

	0 'cntRGB !

	$f0
	va 1? ( swap 1 or swap 1 'cntRGB +! ) drop	
	vr 1? ( swap 2 or swap 1 'cntRGB +! ) drop
	vg 1? ( swap 4 or swap 1 'cntRGB +! ) drop
	vb 1? ( swap 8 or swap 1 'cntRGB +! ) drop
	
	1 'cntRGB cntRGB 3 << + +!

	dup ca!+
	8 and? ( over ca!+ ) 
	4 and? ( over 8 >> ca!+ ) 
	2 and? ( over 16 >> ca!+ )
	1 and? ( over 24 >> ca!+ )
	drop ;
	
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
		d@+ $ffffffff and encode 'px ! 
		swap ) 2drop  
|	"end" .print
	run 1? ( dup encoderun ) drop
	a> qsize - dup qsize d!
	;

|---------- 2do pass
| 0nnnnnnn - n literal number
| 1nnnnnnn oooooooo - n copy from o ofsset

:lit2 | adr --
	1 + ( 1? 1 - cb@+ ca!+ ) drop ;
	
:dec2pass
	cb@+ $80 nand? ( lit2 ; )
	$7f and 1 +
	a> cb@+ 1 + -
	swap ( 1? 1 -
		swap c@+ ca!+ swap ) 2drop ;

:pass2decode | 'adre adr dst --
	>a >b
	( b> <? 
		dec2pass
		) drop ;
	
|-----------------------
#runlenb
#inisrc	

:findyte | byte hasta desde --
	( over <?
		c@+ pick3 =? ( 
		drop ) 3drop 0 ;
	
:search 
	a> 256 - inisrc max 

	;
	
:encodebyte | byte --
	search
	;
	
:enclit | nro --
	dup 1 - cb!+ 
	( 1? 1 - ca@+ cb!+ ) drop ;
	
:endcpy	| off nro --
	dup a+
	1 - $80 or cb!+ 1 - cb!+ ;
	
:pass2encode | cnt 'scr 'dst --
	>b dup 'inisrc ! >a
	( 1? 1 -
		ca@+
		encodebyte
		) drop ;