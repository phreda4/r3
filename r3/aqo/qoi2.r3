| Almost Quite OK Image Format
| from qoi - https://github.com/phoboslab/qoi
| qoi variation + simple repeat sequencer encoder/decoder 
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
	
:diff16 | val -- | ...ggggg rrrrbbbb
	$1f and 8 << 
	ca@+ dup $f0 and 12 << rot or 
	swap $f and or 
	px xor 'px !
	img!+ ;

:diff24 | val --  | ....aaaa arrrrrgg gggbbbbb
	$f and 25 << 
	ca@+ dup $80 and 17 << rot or 	| aa......
	over $7c and 14 << or 			| aarr....
	swap $3 and 11 << or
	ca@+ dup $e0 and 3 << rot or 	| aarrgg...
	swap $1f and or
	px xor 'px !
	img!+ ;
	
|			else if ((b1 & QOI_MASK_2) == QOI_OP_LUMA) {
|				int b2 = bytes[p++];
|				int vg = (b1 & 0x3f) - 32;
|				px.rgba.r += vg - 8 + ((b2 >> 4) & 0x0f);
|				px.rgba.g += vg;
|				px.rgba.b += vg - 8 +  (b2       & 0x0f);	
	
:decode | -- 
	ca@+
	$80 nand? ( 2 << 'index + d@ $ffffffff and dup 'px ! db!+ ; ) 	| 0.......
	$40 nand? (	$3f and 1 + runlen ; )								| 10......
	$20 nand? ( diff16 ; )											| 110..... diff 16
	$10 nand? ( diff24 ; )											| 1110.... diff 24
	$8 and? ( ca@+ 'px c! ) 
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
:encoderun | run --
|	"run " .print 
	1 - $80 or ca!+ 
	0 'run ! 
	; 

:runencode | -- 
	run 64 =? ( encoderun ; ) drop ;

:encodefull | value mask -- value
|	"full " .print 
	$f0 or dup ca!+
	8 and? ( over ca!+ ) 
	4 and? ( over 8 >> ca!+ ) 
	2 and? ( over 16 >> ca!+ )
	1 and? ( over 24 >> ca!+ )
	drop 
	;

|					signed char vr = px.rgba.r - px_prev.rgba.r;
|					signed char vg = px.rgba.g - px_prev.rgba.g;
|					signed char vb = px.rgba.b - px_prev.rgba.b;
|					signed char vg_r = vr - vg;
|					signed char vg_b = vb - vg;

|					else if (
|						vg_r >  -9 && vg_r <  8 &&
|						vg   > -33 && vg   < 32 &&
|						vg_b >  -9 && vg_b <  8
|					) {
|						bytes[p++] = QOI_OP_LUMA     | (vg   + 32);
|						bytes[p++] = (vg_r + 8) << 4 | (vg_b +  8);

:encode | pixel -- pixel
	px =? ( 1 'run +! runencode ; )
	run 1? ( dup encoderun ) drop
	dup hasha d@ $ffffffff and 
	=? ( 
|		over "index %h" .print  
		dup hash ca!+ 
|		dup ".%h. " .print
		; )  		| INDEX=0
	dup dup hasha d! 
	px over xor 
	0
	over $ff000000 and 1? ( swap 1 or $10 + swap ) drop
	over $ff0000 and 1? ( swap 2 or $10 + swap ) drop
	over $ff00 and 1? ( swap 4 or $10 + swap ) drop
	over $ff and 1? ( swap 8 or $10 + swap ) drop
	swap 
	over 4 >> 1 =? ( 2drop encodefull ; ) drop
	$fff0e0f0 nand? ( | fff0e0f0  zero in this bits
|		"dif16 " .print 
		dup 8 >> $1f and $c0 or ca!+
		dup 12 >> $f0 and swap $f and or ca!+
		drop ; ) 
	over 4 >> 2 =? ( 2drop encodefull ; ) drop
	$e0e0e0e0 nand? ( | e0e0e0e0  zero in this bits
|		"dif24 " .print 
		dup 25 >> $f and $e0 or ca!+
		dup 17 >> $80 and 
		over 14 >> $7c and or
		over 11 >> $3 and or ca!+
		dup 3 >> $e0 and 
		swap $1f and or ca!+
		drop ; )
	drop encodefull ;
	
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
		| ARGB --> ABGR
|		dup $ff and 16 << over $ff0000 and 16 >> or swap $ff00ff00 and or
		encode 
		'px ! 
		swap 

		) 2drop  
	"end" .print
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
	( a> <?
		
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