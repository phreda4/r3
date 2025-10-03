| MATH extended precision
| PHREDA 2025
^r3/lib/console.r3
^r3/lib/math.r3

|---- fixed point 32.32
::x*	| a b -- c
	24 *>> dup 63 >> - ;

::x/	| a b -- c
	24 <</ ;

::xint 24 >> ;
::xfix 24 << ;
	
::xceil	| a -- a
	$ffffff + xint ;


:str>xp | "" -- xp
	;
:xp>str | xp -- ""
	;
	
|#define EXP_MAX_INPUT double_to_fixed(20.0)
|#define EXP_MIN_INPUT double_to_fixed(-20.0)
|#define LN2 double_to_fixed(0.693147180559945309417)
	
| Tabla de potencias de e^(1/16)
#exp_table [
    16777216 17905594 19109413 20393825 21764384 23227061 24788274 26454909 
	28234358 30134548 32164008 34331831 36647730 39121092 41762032 44581430 ]

:FIX1 1 24 << ;
:FIX.5 1 23 << ;
:LN2  0.693147180559945309417 8 << ;

:limites | result k
	0 >? ( 40 <? ( << ; ) 2drop $7FFFFFFFFFFFFFFF ; )
	0 <? ( -24 >? ( neg >> ; ) 2drop 0 ; )
	drop ;
	
| ==================== Método 1: Serie de Taylor ====================
::xexp | X -- R |(fixed_t x) {
	
|    if (x > EXP_MAX_INPUT) return 0x7FFFFFFFFFFFFFFFLL;
|   if (x < EXP_MIN_INPUT) return 0;
	0? ( FIX1 nip ; ) |    if (x == 0) return FIXED_ONE;
	dup -? ( neg )

	dup x/ FIX.5 + 24 >>  | x k
	dup 24 << LN2 x* pick2 swap - | x k r
	16 * fix.5 + 24 >>
	15 clamp0max					| x k r n
	swap over 24 << 16 / -			| x k n s
	
	dup FIX1 | x k n s term result
| Serie de Taylor: 1 + s + s²/2! + s³/3! + ... + s⁸/8!	
	over + swap pick2 x* 1 >> swap | s term result
	over + swap pick2 x* 3 / swap | s term result
	over + swap pick2 x* 2 >> swap | s term result
	over + swap pick2 x* 5 / swap | s term result
	over + swap pick2 x* 6 / swap | s term result
	over + swap pick2 x* 7 / swap | s term result
	over + swap rot x* 3 >>  | s term result
	+					|  x k n result
	swap 2 << 'exp_table + d@ x* |  x k result
	swap | x result k
	limites
	swap -? ( drop FIX1 swap x/ ; )
	drop ;	
    
	;
	
:main
	.cls
	0 ( 1.0 <?
		dup "%f " .print
		dup 8 << xexp 8 >> "%f  " .print
		dup exp. " %f " .print
		.cr
		0.25 + ) drop
	;
		
: main waitesc ;
