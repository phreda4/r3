| doble decimal math
| 32.32 fixed point math

|"0.0000001" str>f.d nip 
|"0.0000001" str>f.d nip +
|.fd "%s" .println
|
|---------------------------------
^r3/lib/math.r3
^r3/lib/str.r3

|---- fixed point 32.32
::*.d | a b -- c ; 32.32 fixed point multiply (rounds toward minus infinity)
	32 *>> ;

::*.df | a b -- c ; like *.d but rounds toward zero
	32 *>> dup 63 >> - ;

::/.d | a b -- c ; 32.32 fixed point divide
	32 <</ ;
	
::ceil.d | a -- int ; round up to an integer (the result is an integer, not 32.32)
	$ffffffff + 32 >> ;

::.d>i | a -- int ; integer part (shift right 32, rounds toward minus infinity)
	32 >> ;
::i>.d | int -- a ; integer to 32.32 fixed point
	32 << ;
::f>.d | fix -- a ; 48.16 fixed point (math.r3) to 32.32
	16 << ;
::.d>f | a -- fix ; 32.32 fixed point to 48.16 (math.r3)
	16 >> ;

:sinp
	$7fffffff and $40000000 -
	dup dup *.d
	dup 319329696830 *.d     | c3 minimax
	176857405652 - *.d       | c2 minimax
	26986075409 + *.d ;      | c1 = 2pi * 2^32
	
::cos.d | bangle -- r ; cosine of a binary angle in 32.32 (1.0 = full turn); approximation with an error of about 1e-4
	$80000000 + $80000000 nand? ( sinp ; ) sinp neg ;
::sin.d | bangle -- r ; sine of a binary angle in 32.32 (1.0 = full turn); approximation with an error of about 1e-4
	$40000000 + $80000000 nand? ( sinp ; ) sinp neg ;

::tan.d | bangle -- r ; tangent, rough approximation (BUG: the last multiply is *. instead of *.d, so the result is 65536 times too large)
	$40000000 +
	$7fffffff and $40000000 -
	dup dup *.d
	dup 8791996850651 *.d
	334539478585 + *.d
	26986075409 + *. ;

::tan.dc | bangle -- r ; tangent as sin/cos (BUG: it divides with /. instead of /.d, so the result is 48.16 fixed point, not 32.32)
	dup sin.d swap cos.d 0? ( 1+ ) /. ;

:step | op res one r+o -- op res one
	pick3 >? ( drop swap 2/ swap ; )
	rot 2/ pick2 + | op one r+o nres
	>r neg rot + r> | one nop nres
	rot ;
	
::sqrt.d | x -- r ; square root in 32.32 with 16 bits of precision (0 if x <= 0)
	0 <=? ( drop 0 ; ) |1.0 =? ( ; )
	0 
	1 pick2 msb 1 nand <<
	( 1? | op res one
		2dup + | op res one r+o
		step 2 >> )
	drop nip 16 << ;
	
:mc	| y bitpos -- y mant
	+? ( >> ; ) neg << ;
	
::log2.d | x -- r ; base 2 logarithm in 32.32 (0 if x <= 0)
	0 <=? ( 0 nip ; ) 
	dup msb | x bitpos
	32 - dup 32 << -rot 		| bp x bp
	mc $100000000 -	| bp x
    | Polinomio grado 12 Minimax (Remez), err max 2.33e-10 (piso Q32.32)
	-8164909                  | c12 = -0.0019010410
	over *.d 57541287 +       | c11 =  0.0133973750
	over *.d -190003479 +     | c10 = -0.0442386324
	over *.d 400733151 +      | c9  =  0.0933029575
	over *.d -630804128 +     | c8  = -0.1468705312
	over *.d 833827030 +      | c7  =  0.1941404841
	over *.d -1020126191 +    | c6  = -0.2375166377
	over *.d 1237257380 +     | c5  =  0.2880714321
	over *.d -1548890166 +    | c4  = -0.3606290942
	over *.d 2065433125 +     | c3  =  0.4808961239
	over *.d -3098163823 +    | c2  = -0.7213474770
	over *.d 6196328018 +     | c1  =  1.4426950407
	*.d + ;
	
::pow2.d | y -- r ; 2 to the power y in 32.32
	dup $ffffffff and
    | Polinomio grado 7 Minimax (Remez), err max 2.33e-10 (piso Q32.32)
	89118                      | c7 = 0.0000207489
	over *.d 627254 +          | c6 = 0.0001460394
	over *.d 5750807 +         | c5 = 0.0013389...
	over *.d 41300961 +        | c4 = 0.0096169...
	over *.d 238389783 +       | c3 = 0.0555005...
	over *.d 1031764899 +      | c2 = 0.2402266...
	over *.d 2977044473 +      | c1 = 0.6931471...
    *.d $100000000 +          | +1.0
	swap 32 >>
	+? ( << ; ) neg >> ;	
	
::pow.d | x y -- r ; x to the power y (0 if x = 0) (BUG: it multiplies with *. instead of *.d, so 2^10 gives 1.0)
	|0? ( 2drop 1.0 ; ) 
	swap 0? ( nip ; ) | y x
	log2.d *. pow2.d ;
	
::root.d | x n -- r ; nth root of x (n in 32.32, 3.0 for the cube root); 0 if x <= 0
	swap 0 <=? ( 2drop 0 ; )
	log2.d swap /.d pow2.d ;

::ln.d | x -- r ; natural logarithm in 32.32
	log2.d $B17217D8 *.d ;

::exp.d | x -- r ; e to the power x in 32.32
	$1715476DC *.d pow2.d ;
	
:_tanh	
	$600000000 >=? ( $100000000 ; ) 
	$10000000 <? ( ; ) 
	2* exp.d dup $100000000 - swap $100000000 + /.d  ;

::tanh.d | x -- r ; hyperbolic tangent in 32.32
	-? ( neg _tanh neg ; ) _tanh ;

:gamma_stirling | v -- r
	0 swap | accx workx
	( $700000000 <?
		swap over ln.d +
		swap $100000000 + )
	| accx work
	dup $80000000 - over ln.d *.d 
	| accx workx term1 
	$100000000 pick2 12 * /.d
	| acc workx term1 term3
	$EB5DFC07 + rot + | accx term1 add
	- swap -
	;

:-gamma | x -- r
	$ffffffff nand? ( drop 0 ; )
	$100000000 swap | acc x
	( $100000000 <? 
		swap over *.d
		swap $100000000 + ) | acc x
	gamma_stirling |exp.d | ??
	swap /.d
	;

::gamma.d | x -- r ; gamma function (BUG: the Stirling step adds x instead of subtracting it and the x <= 0 branch lacks exp.d; gamma 5 gives 3.73 instead of 24)
	0 <=? ( -gamma ; ) |0 nip ; )
	gamma_stirling exp.d ;

::beta.d | x y -- r ; beta function (BUG: same Stirling problem as gamma.d; beta 2 3 gives 0.0129 instead of 0.0833)
	0 <? ( 2drop 0 ; )
	swap 0 <? ( 2drop 0 ; )
	2dup + | y x x+y
	rot gamma_stirling
	rot gamma_stirling +
	swap gamma_stirling -
	exp.d ;
	
|---- parse
#f | fraccion
#e | exponente

:signo | str -- str signo
	dup c@
	$2b =? ( drop 1+ 0 ; )	| + $2b
	$2d =? ( drop 1+ 1 ; )	| - $2d
	drop 0 ;
	
:getfrac | nro adr' char -- nro adr' char
	drop
	1 swap | nro 1 adr'
	( c@+ $2f >?
		$39 >? ( rot 'f ! ; )
		$30 - rot 10* + 
		$100000000 >? ( 'f ! 
			( c@+ $2f >? $3a <? drop ) ; ) 
		swap )
	rot 'f ! ;

::str>f.d | adr -- adr' fix ; skip blanks and read a decimal number with sign and fraction (-43.04) as 32.32; 0 if there is no number
	0 'f !
	trim 
	dup c@ 0? ( ; ) drop
	signo
	over c@ 33 <? ( 2drop 1- 0 ; ) drop | caso + y - solos
	1? ( [ neg ; ] >r ) drop
	0 swap ( c@+ $2f >? $3a <? | 0..9
		$30 - rot 10* + swap )
	$2e =? ( getfrac )
	drop 1- swap
	32 << $100000000 f
	1 over ( 1 >? 10/ swap 10* swap ) drop
	*/ $ffffffff and or
	;

::f32! | "str" 'var -- ; read the decimal number of the text and store it (32.32) at 'var
	swap str>f.d nip swap ! ;


