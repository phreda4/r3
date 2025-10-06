| r3 base - bangle  0..360..1.0
| resultado = [0..1.0) [0..$ffff]
|---------------------------------

|---- basic size op
##cell 8 	| cell size

::cell+	8 + ;
::ncell+ 3 << + ;
::1+ 1 + ;
::1- 1 - ;
::2/ 1 >> ;
::2* 1 << ;

|---- fixed point 48.16
::*.u	| a b -- c ; all positive
	16 *>> ;

::*.	| a b -- c
	16 *>> dup 63 >> - ;

::/.	| a b -- c
	16 <</ ;
	
::2/. 	| shift and adjust
	1 >> dup 63 >> - ;

::ceil	| a -- a
	$ffff + 16 >> ;

::int. 16 >> ;
::fix. 16 << ;

::sign | v -- v s
	dup 63 >> 1 or ;

:sinp 
	$7fff and $4000 -
   	dup dup 16 *>>
	dup 4876210 16 *>>
	2699161 - 16 *>>
	411769 + 16 *>> ;

::cos | bangle -- r
	$8000 + $8000 nand? ( sinp ; ) sinp neg ;
::sin | bangle -- r
	$4000 + $8000 nand? ( sinp ; ) sinp neg ;

::tan | v -- f
	$4000 +
	$7fff and $4000 -
	dup dup 16 *>>
	dup 130457939 16 *>>
	5161701 + 16 *>>
	411769 + 16 *>> ;

::sincos | bangle -- sin cos
	dup sin swap cos ;

::xy+polar | x y bangle r -- x y
	>r sincos r@ 16 *>> rot + swap r> 16 *>> rot + swap ;
	
::xy+polar2 | x y r ang -- x y
	sincos pick2 *.u -rot *.u -rot + -rot + swap ;	

::ar>xy | xc yc bangle r -- xc yc x y
	>r sincos r@ 16 *>> pick2 + swap r> 16 *>> pick3 + swap ;

::polar | bangle largo -- dx dy
	>r sincos r@ 16 *>> swap r> 16 *>> swap ;

::polar2 | largo bangle  -- dx dy
	sincos pick2 *.u -rot *.u swap ;

:iatan2p
	+? ( 2dup + >r swap - >r 0.125 0.125 r> r> ; )
	2dup - >r + >r 0.375 0.125 r> r> ;

:iatan2 | |x| y -- bangle
	iatan2p 0? ( nip nip nip ; ) */ - ;

::atan2 | x y -- bangle
	swap -? ( neg swap iatan2 neg ; )
	swap iatan2 ;

::distfast | dx dy -- dis
	abs swap abs over <? ( swap ) | min max
	dup 8 << over 3 << + over 4 << - swap 1 << -
	over 7 << + over 5 << - over 3 << + swap 1 << -
	8 >> ;

::average | x y -- v
	2dup xor 1 >> -rot and + ;

::min	| a b -- m
	over - dup 63 >> and + ;

::max	| a b -- m
	over swap - dup 63 >> and - ;

::clampmax | v max -- v
	swap over - dup 63 >> and + ;

::clampmin | v min -- v
	dup rot - dup 63 >> and - ;

::clamp0 | v -- v
	dup neg 63 >> and ;

::clamp0max | v max -- v
	swap over - dup 63 >> and + dup neg 63 >> and ;

::clamps16 | v -- (signed 16bits)v
	-32768 32767 in? ( ; ) 
	63 >> $7fff xor ;
	
::between | v min max -- -(out)/+(in)
	pick2 - -rot - or ;

::msbl | x -- v
	0 swap
	$ffffffff >? ( 32 >> swap 32 + swap )
	$ffff >? ( 16 >> swap 16 + swap )
	$ff >? ( 8 >> swap 8 + swap )
	$7f >? ( 4 >> swap 4 + swap )
	$3 >? ( 2 >> swap 2 + swap )
	2/ + ;

::clzl | x -- v
	63 swap msbl -	;

::sqrt. | x -- r 
	0 <=? ( drop 0 ; ) |1.0 =? ( ; )
	dup msbl 16 + 2/	| shift
	1 swap <<			| x guess
	2dup /. + 2/
	2dup /. + 2/
	2dup /. + 2/
	2dup /. + 2/
	nip ;

#inf+ $7fffffffffffffff
#inf- $8000000000000001
	
::ln. |x -- r 
	0 <=? ( inf- nip ; ) 
	1.0 =? ( drop 0 ; ) 
	0 swap | n m
	( 2.0 >=? 2/ swap 1+ swap )
	( 0.5 <? 2* swap 1- swap )
	1.0 - dup 2.0 +	/. | n y
	dup dup *.	| n y y2
	8738	| n y y2 result
	over *. 10082 +
	over *. 11915 +
	over *. 14563 +
	over *. 18724 +
	over *. 26214 +
	over *. 43691 +
	over *. 2.0 + | n y y2 result
    nip *.			| n result
	swap 45426 * + ;

:aprox | x exp -- exp y
	0 >=? ( swap over >> ; ) 
	swap over neg << ;
	
::log2. | x -- r ;(fixed48_16_t x) {
	0 <=? ( 0 nip ; )
	dup msbl 16 - | x exp
	aprox | exp y
	0 0.5 rot | exp frac b y
	16 ( 1? 1- >r
		dup 16 *>>	| exp frac b yy
		2.0 >=? ( 2/ rot pick2 + -rot )
		swap 2/ swap
		r> ) drop
	2drop
	swap 16 << + ;
	
::exp. | x -- r
	-1310720 <? ( drop 0 ; )
	1310720 >? ( drop inf- ; )
	dup 94548 *. 0.5 + 16 >> 
	16 >> dup -rot	| n x n 
	16 << 45426 * - 	| n r | r = x - n*LN2 (optimizado) 
	91		| n r result ; 1/6!
	over *. 546 +	| n r result
	over *. 2731 +
	over *. 10923 +
	over *. 32768 +
	over *. 1.0 +
	over *. 1.0 + | n r result
	nip swap
	+? ( 47 >? ( 2drop inf+ ; ) << ; )
	-16 <? ( 2drop 0 ; ) neg >> ;

::pow. | base exp -- r
	swap ln. *. exp. ;

::root. | base root -- r
	swap ln. swap /. exp. ;

::cubicpulse | c w x -- v ; iñigo Quilez
	rot - abs | w x
	over >? ( 2drop 0 ; )
	swap /.
	3.0 over 1 << -
	swap dup *. *.
	1.0 swap - ;

::pow | base exp -- r
	1 swap | base r exp
	( 1?
		1 and? ( >r over * r> )
		1 >> rot dup * -rot )
	drop nip
	;

::bswap32 | v -- vs ; 32 bits
	dup 8 >> $ff00ff and
	swap $ff00ff and 8 << or
	dup 16 >>> swap 16 << or ;

::bswap64 | v -- vs
	dup 8 >> $ff00ff00ff00ff and
	swap $ff00ff00ff00ff and 8 << or
	dup 16 >> $ffff0000ffff and
	swap $ffff0000ffff and 16 << or
	dup 32 >>> swap 32 << or ;		

| next pow2
::nextpow2 | v -- p2
	1 -
	dup 1 >> or
	dup 2 >> or
	dup 4 >> or
	dup 8 >> or
	dup 16 >> or
	1 +
	;
	
::6* | n -- n*6
	1 << dup 1 << + ;

::6/ | n -- n/6
	dup 1 >> over 3 >> + | n q
	dup 4 >> + dup 8 >> + dup 16 >> + 2 >> | n q
	swap over  | q n q
	dup 1 << + 1 << - | q n-q*6
	2 + 3 >> + ;

::6mod | n -- n%6
	dup 6/ 6* - ;

::10/mod | n -- r m
	dup 1 >> over 2 >> + 		| n q
	dup 4 >> + dup 8 >> + dup 16 >> + dup 32 >> + 3 >>	| n q
	over over dup 2 << + 1 << - | n q rem
	6 + 4 >> +					| n q
	swap over dup 2 << + 1 << - | q rem
	;

::100/ | n -- r
	10/mod drop
::10/ | n -- r
	10/mod drop ;
	
::1000000*	1 << dup 2 << +
::100000*	1 << dup 2 << +
::10000*	1 << dup 2 << +
::1000*		1 << dup 2 << +
::100*		1 << dup 2 << +
::10*		1 << dup 2 << + ;

|::10/ $1999a 20 *>> ;
|::10/ $199999999999999A 61 *>> ;
|::10/mod dup 10/ swap over 10* - ;

|- shift with sign
:shift
	-? ( neg >> ; ) << ;

|--- integer to floating point
::i2fp | i -- fp
	0? ( ; )
	dup 63 >> $80000000 and 
	swap abs		| sign abs(i)
	dup clz 8 - 	| s i shift
	swap over shift	| s shift i
	150 rot - 23 << | s i m
	swap $7fffff and or or ;

|--- fixed point to floating point	
::f2fp | f.p -- fp
	0? ( ; )
	dup 63 >> $80000000 and 
	swap abs		| sign abs(i)
	dup clz 8 - 	| s i shift
	swap over shift	| v s shift i
	134 rot - 23 << | s i m | 16 - (fractional part)
	swap $7fffff and or or ;
	
|--- floating point	to fixed point (32 bit but sign bit in 64)
::fp2f | fp -- fixed point
	0? ( ; )
	dup $7fffff and $800000 or
	over 23 >> $ff and 134 - 
	shift swap -? ( drop neg ; ) drop ;

::fp2i | fp -- fixed point
	0? ( ; )
	dup $7fffff and $800000 or
	over 23 >> $ff and 134 - 16 -
	shift swap -? ( drop neg ; ) drop ;

::fp16f | fp16 -- f
	0? ( ; ) 
	dup $3ff and $400 or
	over 10 >> $1f and 15 - 
	shift swap -? ( drop neg ; ) drop ;
	
|::fp2fu | fp -- fixed point
|	dup $7fffff and $800000 or
|	swap 23 >> $ff and 134 - 
|	shift ;
|::fp2f | fp -- fixed point
|	0? ( ; )
|	-? ( fp2fu neg ; ) fp2fu ;

|=--- float 40.24	
::f2fp24 | f -- fp
	0? ( ; )
	dup 63 >> $80000000 and 
	swap abs		| sign abs(i)
	dup clz 8 - 	| s i shift
	swap over shift	| v s shift i
	134 rot 8 + - 23 << | s i m | 16 - (fractional part)
	swap $7fffff and or or ;	
	
|--- floating point	to fixed point (32 bit but sign bit in 64)
::fp2f24 | fp -- fixed point
	0? ( ; )
	dup $7fffff and $800000 or
	over 23 >> $ff and 134 - 8 +
	shift swap -? ( drop neg ; ) drop ;	
	
|:byte2float32N | v -- v
|	$ff and $ff 24 <</ f2fp24 ;

|--- byte 0..255 to normalize 0..1 float32
::byte>float32N | byte -- float
	$ff and 0? ( ; ) 
	32 over clz -			| v msb
	1 over << 1- rot and 	| msb frac
	23 pick2 - <<			| msb mant
	$7fffff and
	swap 119 + 23 << | 8 - 127 +
	or ;
	
|--- float32 to byte 0..255	
::float32N>byte | f32 -- byte
    $80000000 >=? ( drop 0 ; )		| negativos -> 0
    $3f800000 >=? ( drop 255 ; )	| >= 1.0   -> 255
    dup 23 >> $ff and				| extraer exp
    0? ( nip ; ) swap 				| (exp f32)
    $7fffff and $800000 or			| exp mant
    127 rot - >>					| val = mant >> (127 - exp)
    255 * $400000 + 23 >>			| redondeo
    dup $ff >? ( drop $ff ) ;		| clamp

	
:4dif | v1 v2 -- abs
	- dup 15 >> $1000100010001 and 
	$7fff * swap over xor swap - ;