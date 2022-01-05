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

:encode | pixel -- pixel
	px =? ( 1 'run +! runencode ; )
	run 1? ( dup encoderun ) drop
	dup hasha d@ $ffffffff and 
	=? ( dup hash ca!+ ; )  		| INDEX=0
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
		d@+ $ffffffff and encode 'px ! 
		swap ) 2drop  
	"end" .print
	run 1? ( dup encoderun ) drop
	a> qsize - dup qsize d!
	;
