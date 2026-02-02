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
::*.d	| a b -- c 
	32 *>> ;

::*.df	| a b -- c ; full adjust
	32 *>> dup 63 >> - ;

::/.d	| a b -- c
	32 <</ ;
	
::ceil.d	| a -- a
	$ffffffff + 32 >> ;

::.d>i 32 >> ;
::i>.d 32 << ;
::f>.d 16 << ;
::.d>f 16 >> ;


:sinp
	$7fffffff and $40000000 -
	dup dup *.d
	dup 308640022 *.d        | c1 = 0.0719
	2757855059 - *.d         | c2 = 0.6421  
	6744473128 + *.d ;       | c3 = 1.5703 (p/2)
	
::cos.d | bangle -- r
	$80000000 + $80000000 nand? ( sinp ; ) sinp neg ;
::sin.d | bangle -- r
	$40000000 + $80000000 nand? ( sinp ; ) sinp neg ;

::tan.d | v -- f
	$40000000 +
	$7fffffff and $40000000 -
	dup dup *.d
	
	dup 8524742410240 *.d
	334217830400 + *.d
	26986729472 + *.d ; 

::tan.dc
	dup sin.d swap cos.d 0? ( 1+ ) /. ;

:step | op res one r+o -- op res one
	pick3 >? ( drop swap 2/ swap ; )
	rot 2/ pick2 + | op one r+o nres
	>r neg rot + r> | one nop nres
	rot ;
	
::sqrt.d | x -- r
	0 <=? ( drop 0 ; ) |1.0 =? ( ; )
	0 
	1 63 pick3 clz - 1 nand <<
	( 1? | op res one
		2dup + | op res one r+o
		step 2 >> )
	drop nip 16 << ;
	
:mc	| y bitpos -- y mant
	+? ( >> ; ) neg << ;
	
::log2.d | x -- r
	0 <=? ( 0 nip ; ) 
	63 over clz - | x bitpos
	32 - dup 32 << -rot 		| bp x bp
	mc $100000000 -	| bp x
	
	-1032911231 
	over *.d 1239493478 +
	over *.d -1549366847 +
	over *.d 2065822463 +
	over *.d -3098733694 +
	over *.d 6197467388 +
	*.d + ;

::pow2.d | y -- r
	dup $ffffffff and
    | Polinomio grado 3 óptimo
    429496729                 | c3 = 0.1
    over *.d 858993459 +      | c2 = 0.2
    over *.d 3013174610 +     | c1 ˜ ln(2)
    *.d $100000000 +          | +1.0
	swap 32 >>
	+? ( << ; ) neg >> ;
:***********
	13673216    | c6 = 0.0032 ? 2?? ? minimax optimizado
	over *.d 90907852 +   | c5 = 0.0212 ? 2??
	over *.d 249678090 +  | c4 = 0.0581 ? 2??
	over *.d 620795693 +  | c3 = 0.1445 ? 2??
	over *.d 1285701837 + | c2 = 0.2993 ? 2??
	over *.d 2977044471 + | c1 = 0.6931 ? 2?? (? ln(2))
	*.d $100000000 + 
	;
	
::pow.d | x y -- r
	|0? ( 2drop 1.0 ; ) 
	swap 0? ( nip ; ) | y x
	log2.d *. pow2.d ;
	
::root.d | x n -- r
	swap 0 <=? ( 2drop 0 ; )
	log2.d swap /.d pow2.d ;

::ln.d | x -- ln(x)
	log2.d $B17217D8 *.d ;

::exp.d | x -- e^x  
	$1715476DC *.d pow2.d ;
	
:_tanh	
	$600000000 >=? ( $100000000 ; ) 
	$10000000 <? ( ; ) 
	2* exp.d dup $100000000 - swap $100000000 + /.d  ;

::tanh.d
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

::gamma.d | x -- r
	0 <=? ( -gamma ; ) |0 nip ; )
	gamma_stirling exp.d ;

::beta.d | x y -- r
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

::str>f.d | adr -- 'adr fnro
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

::f32! swap str>f.d nip swap ! ;

|----- print
#mbuff * 64

:mbuffi | -- adr
	'mbuff 63 + 0 over c! 1- ;

:sign | adr sign -- adr'
	-? ( drop $2d over c! ; ) drop 1+ ;

:.f!
	( 10/mod $30 + pick2 c! swap 1- swap 1? ) drop
	1+ $2e over c! 1-
	over abs 32 >>> 
	( 10/mod $30 + pick2 c! swap 1- swap 1? ) drop
	swap sign ;
	
::.fd | fix -- str
	mbuffi over	abs $ffffffff and 100000000 32 *>> 100000000 + .f! ;

