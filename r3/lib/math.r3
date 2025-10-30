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
    dup 4846800 16 *>>
    2688000 - 16 *>>
    404000 + 16 *>> ;	
::cos | bangle -- r
	$8000 + $8000 nand? ( sinp ; ) sinp neg ;
::sin | bangle -- r
	$4000 + $8000 nand? ( sinp ; ) sinp neg ;

::tan | v -- f
    $4000 +
    $7fff and $4000 -
    dup dup 16 *>>
    dup 129890000 16 *>>
    5078000 + 16 *>>
    395600 + 16 *>> ;

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

::sqrt. | x -- r 
	0 <=? ( drop 0 ; ) |1.0 =? ( ; )
	dup msb 16 + 2/	| shift
	1 swap <<			| x guess
	2dup /. + 2/
	2dup /. + 2/
	2dup /. + 2/
	2dup /. + 2/
	nip ;

#inf+ $7fffffffffffffff
#inf- $8000000000000001
	
:reduce | n m 
	63 over clz	- | n m shift
	16 >? ( 16 - rot over + -rot >> ; )
	15 <? ( 15 swap - rot over - -rot << ; )
	drop ;
	
::ln. |x -- r 
	0 <=? ( inf- nip ; ) 
	1.0 =? ( drop 0 ; ) 
	0 swap | n m
	reduce
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
	0 <=? ( inf- nip ; )
	dup msb 16 - | x exp
	aprox | exp y
	0 0.5 rot | exp frac b y
	16 ( 1? 1- >r
		dup 16 *>>	| exp frac b yy
		2.0 >=? ( 2/ rot pick2 + -rot )
		swap 2/ swap
		r> ) drop
	2drop
	swap 16 << + ;
	
::log10.	log2. $352B5 /. ;
::logn2.	log2. $17154 /. ;
	
::exp. | x -- r
	1.0 swap 
	-? ( $b1721 + swap 16 >> swap )
	$58b91 >=? ( $58b91 - swap 8 << swap ) 
	$2c5c8 >=? ( $2c5c8 - swap 4 << swap )
	$162e4 >=? ( $162e4 - swap 2 << swap )
	$b172 >=? ( $b172 - swap 1 << swap ) 
	$67cd >=? ( $67cd - swap dup 1 >> + swap )
	$3920 >=? ( $3920 - swap dup 2 >> + swap )
	$1e27 >=? ( $1e27 - swap dup 3 >> + swap )
	$f85 >=? ( $f85 - swap dup 4 >> + swap ) 
	$7e1 >=? ( $7e1 - swap dup 5 >> + swap ) 
	$3f8 >=? ( $3f8 - swap dup 6 >> + swap ) 
	$1fe >=? ( $1fe - swap dup 7 >> + swap ) 
    | Taylor orden 2: r × (1 + x(1 + x/2))
    dup 17 >> 65536 +       | r x (1+x/2)    [3 ops]
    16 *>> 65536 +          | r (1+x(1+x/2)) [2 ops]
    16 *>> ;                | resultado      [1 op]
	
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

::1000*		dup 10 << over 4 << - rot 3 << - ;
	
::1000000*	1000* 1000* ;
::100000*	1 << dup 2 << +
::10000*	1 << dup 2 << +
::1000*		dup 10 << over 4 << - swap 3 << - ;
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