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
::*.s	| a b -- c ; small numbers 
	* 16 >> ;

::*.	| a b -- c 
	16 *>> ;

::*.f	| a b -- c ; full adjust
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
	dup dup *.
	dup 4846800 *.
	2688000 - *.
	404000 + *. ;
	
::cos | bangle -- r
	$8000 + $8000 nand? ( sinp ; ) sinp neg ;
::sin | bangle -- r
	$4000 + $8000 nand? ( sinp ; ) sinp neg ;

::tan | v -- f
	$4000 +
	$7fff and $4000 -
	dup dup *.
	dup 129890000 *.
	5078000 + *.
	395600 + *. ;

::sincos | bangle -- sin cos
	dup sin swap cos ;

::xy+polar | x y bangle r -- x y
	>r sincos r@ *. rot + swap r> *. rot + swap ;
	
::xy+polar2 | x y r ang -- x y
	sincos pick2 *. -rot *. -rot + -rot + swap ;	

::ar>xy | xc yc bangle r -- xc yc x y
	>r sincos r@ *. pick2 + swap r> *. pick3 + swap ;

::polar | bangle largo -- dx dy
	>r sincos r@ *. swap r> *. swap ;

::polar2 | largo bangle  -- dx dy
	sincos pick2 *. -rot *. swap ;

:iatan2 | |x| y -- bangle
	swap
	+? ( 2dup + 0? ( nip nip ; )
		-rot swap - 0.125 rot */ 0.125 swap - ; )
	2dup - 0? ( nip nip ; )
	-rot + 0.125 rot */ 0.375 swap - ;
::atan2 | x y -- bangle
    swap -? ( neg iatan2 neg ; ) iatan2 ;

::distfast | dx dy -- dis
    abs swap abs over <? ( swap ) | min max
    dup 3 >> -		| max*7/8 (max - max/8)
    swap 1 >> + ;	| Calcular: max*7/8 + min/2

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

::msb
	63 swap clz - ;

:step | op res one r+o -- op res one
	pick3 >? ( drop swap 2/ swap ; )
	rot 2/ pick2 + | op one r+o nres
	>r neg rot + r> | one nop nres
	rot ;
	
::sqrt. | x -- r
	0 <=? ( drop 0 ; ) |1.0 =? ( ; )
	0 
	1 63 pick3 clz - 1 nand <<
	( 1? | op res one
		2dup + | op res one r+o
		step 2 >> )
	drop nip 8 << ;

:mcalc | x bitpos -- m
	+? ( >> ; ) neg << ;
	
::log2. | y -- r
	0 <=? ( 0 nip ; ) 
	63 over clz - 
	16 - dup 16 << | x bitpos integer
	-rot | integer x bitpos
	mcalc 1.0 - | int xnorm
	19697
	over * 16 >> 51259 -
	over * 16 >> 97098 +
	* 16 >> + ;
	
::pow2. | y -- r
	dup $ffff and
	5089
	over * 16 >> 14850 +
	over * 16 >> 45600 +
	* 16 >> 1.0 +
	swap 16 >>
	+? ( << ; ) neg >> ;

::pow. | x y -- r
	|0? ( 2drop 1.0 ; ) 
	swap 0? ( nip ; ) | y x
	log2. *. pow2. ;
	
::root. | x n -- r
	swap 0 <=? ( 2drop 0 ; )
	log2. swap /. pow2. ;

::ln.	log2. 45426 *. ;
::exp.	94544 *. pow2. ;
	
:_tanh	
	6.0 >=? ( 1.0 ; ) 0.0625 <? ( ; ) 
	2* exp. dup 1.0 - swap 1.0 + /.  ;

::tanh.
	-? ( neg _tanh neg ; ) _tanh ;

:_softclip
	0.8 <? ( 
		dup dup 16 *>> over 16 *>> 
		0.185 16 *>> - ; )
	1.6 <? ( 0.8 -
		dup dup 16 *>> 0.05625 16 *>> neg
		swap 0.32599 16 *>> 0.70528 + + ; )
	2.4 <? ( 1.6 -
		dup dup 16 *>> 0.02281 16 *>> neg
		swap 0.08625 16 *>> 0.92167 + + ; )
	2.4 -
	0.02722 16 *>> 0.98367 +
|	1.0 <? ( ; ) 1.0 nip 
|	$ffff <? ( ; ) $ffff and
	;
	
::fastanh.
	-? ( neg _softclip neg ; ) _softclip ;
	
	
:gamma_stirling | v -- r
	0 swap | accx workx
	( 7.0 <?
		swap over ln. +
		swap 1.0 + )
	| accx work
	dup 0.5 - over ln. *. 
	| accx workx term1 
	1.0 pick2 12 * /.
	| acc workx term1 term3 | HALF_LN_2PI = 60223
	60223 + rot + | accx term1 add
	- swap -
	;

:-gamma | x -- r
	$ffff nand? ( drop 0 ; )
	1.0 swap | acc x
	( 1.0 <? 
		swap over *. 
		swap 1.0 + ) | acc x
	gamma_stirling |exp. | ??
	swap /.
	;

::gamma. | x -- r
	0 <=? ( -gamma ; ) |0 nip ; )
	gamma_stirling exp. ;

::beta. | x y -- r
	0 <? ( 2drop 0 ; )
	swap 0 <? ( 2drop 0 ; )
	2dup + | y x x+y
	rot gamma_stirling
	rot gamma_stirling +
	swap gamma_stirling -
	exp. ;
	

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
	drop nip ;

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
	1-
	dup 1 >> or
	dup 2 >> or
	dup 4 >> or
	dup 8 >> or
	dup 16 >> or
	1+
	;
	
|---- optimization * and /
	
::6* | n -- n*6
	2* dup 2* + ;
::6/ | n -- n/6
	$AAAAAAAAAAAAAAAB 65 *>> ;
 
::6mod | n -- n%6
	dup 6/ 6* - ;

::100000*	1 << dup 2 << +
::10000*	1 << dup 2 << +
::1000*		dup 10 << over 4 << - swap 3 << - ;
::1000000*	1000* 1000* ;
::100*		1 << dup 2 << +
::10*		1 << dup 2 << + ;

::10/
	$199999999999999A 64 *>> ;
	
::10/mod | n -- q r
    dup 10/	swap over 10* - ;		| r = n - q*10	

::1000000/
	18446744073710 64 *>> ;

|- shift with sign
:shift
	-? ( neg >> ; ) << ;

:clzd
	clz 32 - ; |0 max ;

|--- integer to floating point
::i2fp | i -- fp
	0? ( ; )
	dup 63 >> $80000000 and 
	swap abs		| sign abs(i)
	dup clzd 8 - 	| s i shift
	swap over shift	| s shift i
	150 rot - 23 << | s i m
	swap $7fffff and or or ;

|--- fixed point to floating point	
::f2fp | f.p -- fp
	0? ( ; )
	dup 63 >> $80000000 and 
	swap abs		| sign abs(i)
	dup clzd 8 - 	| s i shift
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
	
|=--- float 40.24	
::f2fp24 | f -- fp
	0? ( ; )
	dup 63 >> $80000000 and 
	swap abs		| sign abs(i)
	dup clzd 8 - 	| s i shift
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
	32 over clzd -			| v msb
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

|--- pack 4 words, get diference 	
:4dif | v1 v2 -- abs
	- dup 15 >> $1000100010001 and 
	$7fff * swap over xor swap - ;