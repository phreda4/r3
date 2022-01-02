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
	
:diff16 | val -- | ...ggggg rrrrbbbb
	$1f and 8 << 
	ca@+ 
	dup 12 << $f0000 and or or $f1f0f and 
	px xor 'px !
	
|	$1f and 15 - 		'px c+! 
|	ca@+ dup 4 >> 7 - 	'px 1 + c+!
|	$f and 7 - 			'px 2 + c+! 
	img!+ ;

:diff24 | val --  | ....aaaa arrrrrgg gggbbbbb
	$f and 25 << 
	ca@+ dup 24 << $1000000 and rot or | aa......
	over 14 <<      $1f0000 and rot or | aarr....
	swap 11 <<        $1f00 and or
	ca@+ dup 3 <<     $1f00 and rot or | aarrgg...
	swap $1f and or
	px xor 
	'px !

|	$f and 1 << ca@+ dup 7 >> $1 and rot or 15 - 	'px c+! 	| red
|	dup $7c and 2 >> 15 - 							'px 1 + c+! | green
|	$3 and 3 << ca@+ dup $e0 and 5 >> rot or 15 - 	'px 2 + c+! | blue
|	$1f and 15 - 									'px 3 + c+! | alpha
	
	img!+ ;
	
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
	
	dup dup hasha d! 
	
	px over xor 
	dup $ff and 'vb !
	dup 8 >> $ff and 'vg !
	dup 16 >> $ff and 'vr !
	24 >> $ff and 'va !
	
|	vb vg vr va "a:%h r:%h g:%h b:%h" .println

	va vg 5 >> or
	vr vb or 4 >> or 
	0? ( drop | ...ggggg rrrrbbbb
		$c0 vg or ca!+
		vr 4 << vb or ca!+
		; ) drop
	
	vg 5 >> vr 5 >> or
	vb 5 >> or va 5 >> or
	0? ( drop | ....aaaa arrrrrgg gggbbbbb
		$e0 va 1 >> or ca!+
		va 7 << 
		vr 2 << or
		vg 3 >> or ca!+
		vg 5 <<
		vb or ca!+
		; ) drop
		
		| .....rrr rrrggggg ggbbbbbb

	$f0 
	vb 1? ( swap 8 or swap ) drop
	vg 1? ( swap 4 or swap ) drop
	vr 1? ( swap 2 or swap ) drop
	va 1? ( swap 1 or swap ) drop
	ca!+
	vb 1? ( over ca!+ ) drop
	vg 1? ( over 8 >> ca!+ ) drop
	vr 1? ( over 16 >> ca!+ ) drop
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
		| ARGB --> ABGR
		|dup $ff and 16 << over $ff0000 and 16 >> or swap $ff00ff00 and or
		
		encode
		'px ! 
		swap ) 2drop  
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