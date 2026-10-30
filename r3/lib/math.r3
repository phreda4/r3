| r3 base - bangle  0..360..1.0
| resultado = [0..1.0) [0..$ffff]
|---------------------------------

|---- basic size op
##cell 8 | size of a cell in bytes (8)

::cell+ | n -- n' ; add the cell size (8)
	8 + ;
::ncell+ | adr n -- adr' ; adr + n * 8 (address of cell n of a table)
	3 << + ;

::ndword+ | adr n -- adr' ; adr + n * 4 (address of dword n of a table)
	2 << + ;
::nword+ | adr n -- adr' ; adr + n * 2 (address of word n of a table)
	1 << + ;

::1+ | n -- n+1 ; increment
	1 + ;
::1- | n -- n-1 ; decrement
	1 - ;
::2/ | n -- n/2 ; arithmetic shift right by 1 (rounds toward minus infinity)
	1 >> ;
::2* | n -- n*2 ; shift left by 1
	1 << ;

|---- fixed point 48.16
::*.s | a b -- c ; fixed point multiply (a*b >> 16), only for small numbers: the product must fit in 64 bits
	* 16 >> ;

::*. | a b -- c ; fixed point multiply (a*b >> 16 with a 128-bit product), rounds toward minus infinity
	16 *>> ;

::*.f | a b -- c ; like *. but rounds toward zero
	16 *>> dup 63 >> - ;

::/. | a b -- c ; fixed point divide ((a << 16) / b with a 128-bit intermediate)
	16 <</ ;
	
::2/. | a -- a/2 ; divide by 2 rounding toward zero
	1 >> dup 63 >> - ;

::ceil | fix -- int ; round up to an integer
	$ffff + 16 >> ;

::int. | fix -- int ; integer part (shift right 16, rounds toward minus infinity)
	16 >> ;
::fix. | int -- fix ; integer to 48.16 fixed point (shift left 16)
	16 << ;

::sign | v -- v s ; s = 1 if v >= 0, -1 if v < 0
	dup 63 >> 1 or ;
	
:sinp
	$7fff and $4000 -
	dup dup *.
	dup 4872679 *.        | c3 minimax
	2698638 - *.           | c2 minimax
	411775 + *. ;          | c1 = 2pi * 65536
	
::cos | bangle -- r ; cosine of a binary angle (1.0 = full turn); r is fixed point -1.0..1.0
	$8000 + $8000 nand? ( sinp ; ) sinp neg ;
::sin | bangle -- r ; sine of a binary angle (1.0 = full turn); r is fixed point -1.0..1.0
	$4000 + $8000 nand? ( sinp ; ) sinp neg ;

::tan | bangle -- r ; tangent of a binary angle (fixed point)
	$4000 +
	$7fff and $4000 -
	dup dup *.
	dup 134156714 *.      | c5 minimax
	5104633 + *.           | c3 minimax
	411775 + *. ;          | c1 = 2pi * 65536
	
::sincos | bangle -- sin cos ; sine and cosine (cos on top)
	dup sin swap cos ;

::xy+polar | x y bangle r -- x' y' ; move the point by r in the direction bangle: x += sin*r, y += cos*r
	>r sincos r@ *. rot + swap r> *. rot + swap ;
	
::xy+polar2 | x y r bangle -- x' y' ; like xy+polar with r and bangle swapped
	sincos pick2 *. -rot *. -rot + -rot + swap ;	

::ar>xy | xc yc bangle r -- xc yc x y ; point at distance r and direction bangle from the center xc yc (the center is kept)
	>r sincos r@ *. pick2 + swap r> *. pick3 + swap ;

::polar | bangle len -- dx dy ; dx = sin*len, dy = cos*len
	>r sincos r@ *. swap r> *. swap ;

::polar2 | len bangle -- dx dy ; like polar with len and bangle swapped
	sincos pick2 *. -rot *. swap ;
	
::dir2vec | dx dy -- vx vy ; unit vector (length 1.0, fixed point) of the direction dx dy; 0 0 gives 0 0
	over dup * over dup * + 
	0? ( nip nip dup ; ) | 0 0
	sqrt rot over 16 <</ -rot 16 <</ ;

::sdir2vec | scale dx dy -- vx vy ; like dir2vec multiplied by scale (fixed point)
	over dup * over dup * + 
	0? ( nip nip nip dup ; ) | 0 0
	sqrt >r rot r> 16 <</
	rot over *. -rot *. ;	

|--- atan2
:atanf
	|swap pick2 xor 1? ( swap neg swap ) drop
	swap pick2 xor			| sx angle m
	dup -rot xor swap -		| sx angle
	swap $8000 and + $ffff and ;

:atanb | sx sy |x| |y| -- sx sy angle
	over >? ( 16 <</ $21F3 *. $4000 swap - atanf ; )
	swap 16 <</ $21F3 *. atanf ; 
	
::atan2 | x y -- bangle ; angle of the vector (x,y) as binary angle: 0 for +x, 0.25 for +y; fast, low precision
	over 63 >> over 63 >>	| x y sx sy
	2swap					| sx sy x y 
	pick2 xor pick2 - swap
	pick3 xor pick3 - swap	| sx sy |x| |y|
	0? ( swap 0? ( 4drop 0 ; ) swap ) 
	atanb ;

| atan2 extender precition
:atanc
	16 <</ dup dup *. over *.	| r r3
	-$07D2 *. swap $279E *. + ;
	
:atanb
	over >? ( atanc $4000 swap - atanf ; )
	swap atanc atanf ; 

::atan2x | x y -- bangle ; like atan2 but more precise
	over 63 >> over 63 >>	| x y sx sy
	2swap					| sx sy x y 
	pick2 xor pick2 - swap
	pick3 xor pick3 - swap	| sx sy |x| |y|
	0? ( swap 0? ( 4drop 0 ; ) swap ) 
	atanb ;

| max*31/32 + min/4 + min/8 = min*3/8
::distfast | dx dy -- dist ; approximate distance: max*31/32 + min*3/8 (rough for small integers)
    abs swap abs over <? ( swap ) | min max
	dup 5 >> - swap dup 2 >> swap 3 >> + + ; 

::average | x y -- v ; (x+y)/2 rounded down, without overflow
	2dup xor 1 >> -rot and + ;

::min | a b -- m ; the smaller one
	over - dup 63 >> and + ;

::max | a b -- m ; the larger one
	over swap - dup 63 >> and - ;

::clampmax | v max -- v ; v limited to at most max
	swap over - dup 63 >> and + ;

::clampmin | v min -- v ; v limited to at least min
	dup rot - dup 63 >> and - ;

::clamp0 | v -- v ; v limited to at least 0
	dup neg 63 >> and ;

::clamp0max | v max -- v ; v limited to 0..max
	swap over - dup 63 >> and + dup neg 63 >> and ;

::clamps16 | v -- v ; v limited to -32768..32767
	-32768 32767 in? ( ; ) 
	63 >> $7fff xor ;
	
::between | v min max -- n ; n < 0 if v is outside min..max, n >= 0 if inside
	pick2 - -rot - or ;

::msb | x -- n ; index (0-63) of the most significant bit; undefined for 0
	clz 63 xor ;
	
::ctz | x -- n ; number of trailing zero bits (64 if x = 0)
	0? ( 64 + ; ) 
	dup neg and 0 swap
    $00000000FFFFFFFF nand? ( swap 32 + swap ) 
    $0000FFFF0000FFFF nand? ( swap 16 + swap )
    $00FF00FF00FF00FF nand? ( swap 8 + swap )
    $0F0F0F0F0F0F0F0F nand? ( swap 4 + swap )
    $3333333333333333 nand? ( swap 2 + swap )
    $5555555555555555 nand? ( swap 1 + swap )
	drop ;
	
:step | op res one r+o -- op res one
	pick3 >? ( drop swap 2/ swap ; )
	rot 2/ pick2 + | op one r+o nres
	>r neg rot + r> | one nop nres
	rot ;
	
::sqrt. | x -- r ; square root of a fixed point number (0 if x <= 0)
	0 <=? ( drop 0 ; ) 16 << |1.0 =? ( ; )
	0 
	1 pick2 msb 1 nand <<
	( 1? | op res one
		2dup + | op res one r+o
		step 2 >> )
	drop nip ;

|- shift with sign
:shift
	-? ( neg >> ; ) << ;
	
::log2. | y -- r ; base 2 logarithm of a fixed point number (0 if y <= 0)
	0 <=? ( 0 nip ; ) 
	dup msb 16 - 
	dup 16 << | x bitpos integer
	-rot | integer x bitpos
	neg shift 1.0 - | int xnorm	
    | Polinomio grado 6 Minimax, err max ~1.5e-5 (piso Q48.16)
	-2319                    | c6
	over 16 *>> 9726 +      | c5
	over 16 *>> -19997 +    | c4
	over 16 *>> 30797 +     | c3
	over 16 *>> -47220 +    | c2
	over 16 *>> 94548 +     | c1
	16 *>> + ;
	
::pow2. | y -- r ; 2 to the power y (fixed point)
	dup $ffff and
    | Polinomio grado 4 Minimax, err max ~1.5e-5 (piso Q48.16)
	838                      | c4
	over 16 *>> 3500 +      | c3
	over 16 *>> 15772 +     | c2
	over 16 *>> 45425 +     | c1
	16 *>> 1.0 +
	swap 16 >> shift ;
	
::pow. | x y -- r ; x to the power y (fixed point; 0 if x = 0)
	|0? ( 2drop 1.0 ; ) 
	swap 0? ( nip ; ) | y x
	log2. *. pow2. ;
	
::root. | x n -- r ; nth root of x (fixed point); n is fixed point too: 3.0 for the cube root
	swap 0 <=? ( 2drop 0 ; )
	log2. swap /. pow2. ;

::ln. | x -- r ; natural logarithm (fixed point)
	log2. 45426 *. ;
::exp. | x -- r ; e to the power x (fixed point)
	94548 *. pow2. ;
	
:_tanh	
	6.0 >=? ( drop 1.0 ; ) 0.0625 <? ( ; ) 
	2* exp. dup 1.0 - swap 1.0 + /.  ;

::tanh. | x -- r ; hyperbolic tangent (fixed point)
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
	1.0 min ;
	
::fastanh. | x -- r ; fast approximation of tanh (piecewise polynomial)
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
	60223 + rot - + swap - | accx lnGamma(z)
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

::gamma. | x -- r ; gamma function, approximation (fixed point)
	0 <=? ( -gamma ; ) |0 nip ; )
	gamma_stirling exp. ;

::beta. | x y -- r ; beta function, approximation (fixed point; 0 if x or y < 0)
	0 <? ( 2drop 0 ; )
	swap 0 <? ( 2drop 0 ; )
	2dup + | y x x+y
	rot gamma_stirling
	rot gamma_stirling +
	swap gamma_stirling -
	exp. ;
	

::cubicpulse | c w x -- v ; smooth bump (Inigo Quilez): 1.0 at x = c, 0 when |x-c| >= w (fixed point)
	rot - abs | w x
	over >? ( 2drop 0 ; )
	swap /.
	3.0 over 1 << -
	swap dup *. *.
	1.0 swap - ;

::pow | base exp -- r ; integer power (exp >= 0)
	1 swap | base r exp
	( 1?
		1 and? ( >r over * r> )
		1 >> rot dup * -rot )
	drop nip ;

::bswap32 | v -- vs ; swap the 4 low bytes; the upper bits of the result are garbage (mask with $ffffffff)
	dup 8 >> $ff00ff and
	swap $ff00ff and 8 << or
	dup 16 >>> swap 16 << or ;

::bswap64 | v -- vs ; swap the 8 bytes
	dup 8 >> $ff00ff00ff00ff and
	swap $ff00ff00ff00ff and 8 << or
	dup 16 >> $ffff0000ffff and
	swap $ffff0000ffff and 16 << or
	dup 32 >>> swap 32 << or ;		

| next pow2
::nextpow2 | v -- p2 ; smallest power of 2 that is >= v (0 for 0)
	1-
	dup 1 >> or
	dup 2 >> or
	dup 4 >> or
	dup 8 >> or
	dup 16 >> or
	dup 32 >> or
	1+
	;
	
|---- optimization * and /
	
::6* | n -- n*6 ; multiply by 6
	2* dup 2* + ;
	
::6/ | n -- n/6 ; divide by 6 (multiplies by the reciprocal)
	$2AAAAAAAAAAAAAAB 64 *>> ;
 
::6mod | n -- n%6 ; remainder of n/6
	dup 6/ 6* - ;

::10* | n -- n*10 ; multiply by 10
	2* dup 2 << + ;
	
::10/ | n -- n/10 ; divide by 10 (multiplies by the reciprocal, rounds toward minus infinity)
	$199999999999999A 64 *>> ;
	
::10/mod | n -- q r ; quotient and remainder of n/10
    dup 10/	swap over 10* - ;		| r = n - q*10	

::1000000/ | n -- n/1000000 ; divide by one million (multiplies by the reciprocal)
	18446744073710 64 *>> ;

:clzd
	clz 32 - ; |0 max ;

|--- integer to floating point
::i2fp | i -- fp ; integer to float32 bits (in the low 32 bits)
	0? ( ; )
	dup 63 >> $80000000 and 
	swap abs		| sign abs(i)
	dup clzd 8 - 	| s i shift
	swap over shift	| s shift i
	150 rot - 23 << | s i m
	swap $7fffff and or or ;

|--- fixed point to floating point	
::f2fp | fix -- fp ; 48.16 fixed point to float32 bits (in the low 32 bits)
	0? ( ; )
	dup 63 >> $80000000 and 
	swap abs		| sign abs(i)
	dup clzd 8 - 	| s i shift
	swap over shift	| v s shift i
	134 rot - 23 << | s i m | 16 - (fractional part)
	swap $7fffff and or or ;

::memfloat | cnt adr -- ; convert in place cnt 32-bit fixed point values at adr to float32
	>a ( 1? 1- da@ f2fp da!+ ) drop ;
	
::mem2float | cnt src dst -- ; convert cnt 64-bit fixed point values at src to float32 (4 bytes each) at dst
	>b >a ( 1? 1- a@+ f2fp db!+ ) drop ;

::memd2float | cnt src dst -- ; convert cnt 32-bit fixed point values at src to float32 (4 bytes each) at dst
	>b >a ( 1? 1- da@+ f2fp db!+ ) drop ;
	
|--- floating point	to fixed point (32 bit but sign bit in 64)
::fp2f | fp -- fix ; float32 bits to 48.16 fixed point; negative values need fp sign-extended to 64 bits (as d@ reads it)
	0? ( ; )
	dup $7fffff and $800000 or
	over 23 >> $ff and 134 - 
	shift swap -? ( drop neg ; ) drop ;

::fp2i | fp -- int ; float32 bits to integer, truncated; negative values need fp sign-extended like in fp2f
	0? ( ; )
	dup $7fffff and $800000 or
	over 23 >> $ff and 134 - 16 -
	shift swap -? ( drop neg ; ) drop ;

::fp16f | fp16 -- fix ; half float (16 bits) to 48.16 fixed point; negative values need the 16 bits sign-extended (as w@ reads it)
	0? ( ; ) 
	dup $3ff and $400 or
	over 10 >> $1f and 9 - 
	shift swap -? ( drop neg ; ) drop ;
	
|=--- float 40.24	
::f2fp24 | f -- fp ; 40.24 fixed point to float32 bits
	0? ( ; )
	dup 63 >> $80000000 and 
	swap abs		| sign abs(i)
	dup clzd 8 - 	| s i shift
	swap over shift	| v s shift i
	134 rot 8 + - 23 << | s i m | 16 - (fractional part)
	swap $7fffff and or or ;	
	
|--- floating point	to fixed point (32 bit but sign bit in 64)
::fp2f24 | fp -- f ; float32 bits to 40.24 fixed point; negative values need fp sign-extended like in fp2f
	0? ( ; )
	dup $7fffff and $800000 or
	over 23 >> $ff and 134 - 8 +
	shift swap -? ( drop neg ; ) drop ;	
	
|:byte2float32N | v -- v
|	$ff and $ff 24 <</ f2fp24 ;

|--- byte 0..255 to normalize 0..1 float32
::byte>float32N | byte -- float ; byte 0..255 to float32 normalized 0..1 (BUG: returns about byte/128, 255 gives 1.996)
	$ff and 0? ( ; ) 
	32 over clzd -			| v msb
	1 over << 1- rot and 	| msb frac
	23 pick2 - <<			| msb mant
	$7fffff and
	swap 119 + 23 << | 8 - 127 +
	or ;
	
|--- float32 to byte 0..255	
::float32N>byte | f32 -- byte ; float32 normalized 0..1 to byte 0..255, rounded (negative gives 0, >= 1.0 gives 255)
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