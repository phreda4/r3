| r3 base - bangle
| 0--360
| 0--2*pi
| 0.0--1.0
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
	>r sincos r@ 16 *>> rot + swap r> 16 *>> rot + swap  ;

::ar>xy | xc yc bangle r -- xc yc x y
	>r sincos r@ 16 *>> pick2 + swap r> 16 *>> pick3 + swap  ;

::polar | bangle largo -- dx dy
	>r sincos r@ 16 *>> swap r> 16 *>> swap ;

::polar2 | largo bangle  -- dx dy
	sincos pick2 16 *>> >r 16 *>> r> ;

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
	-326768 32767 in? ( ; ) 
	63 >> $7fff xor ;
	
::between | v min max -- -(out)/+(in)
	pick2 - -rot - or ;

::sqrt. | v -- r
	dup 1.0 ( over <? + 1 >> 2dup 16 <</ ) drop nip ;	
	
| CLZ don't wrk on 64 bits!
::clzl
	0 swap
	$ffffffff00000000 nand? ( 32 << swap 32 + swap )
	$ffff000000000000 nand? ( 16 << swap 16 + swap )
	$ff00000000000000 nand? ( 8 << swap 8 + swap )
	$f000000000000000 nand? ( 4 << swap 4 + swap )
	$c000000000000000 nand? ( 2 << swap 2 + swap )
	$8000000000000000 nand? ( swap 1 + swap )
	drop ;	
	
| http://www.quinapalus.com/efunc.html

:l1 over dup 1 >> + +? ( -rot nip $67cd - ; ) drop ;
:l2 over dup 2 >> + +? ( -rot nip $3920 - ; ) drop ;
:l3 over dup 3 >> + +? ( -rot nip $1e27 - ; ) drop ;
:l4 over dup 4 >> + +? ( -rot nip $f85 - ; ) drop ;
:l5 over dup 5 >> + +? ( -rot nip $7e1 - ; ) drop ;
:l6 over dup 6 >> + +? ( -rot nip $3f8 - ; ) drop ;
:l7 over dup 7 >> + +? ( -rot nip $1fe - ; ) drop ;

::ln. | x -- r
	-? ( $80000000 nip ; )
	$a65af swap | y x
	$8000 <? ( 16 << swap $b1721 - swap )
	$800000 <? ( 8 << swap $58b91 - swap )
	$8000000 <? ( 4 << swap $2c5c8 - swap )
	$20000000 <? ( 2 << swap $162e4 - swap )
	$40000000 <? ( 1 << swap $b172 - swap ) | y x
	swap | x y
	l1 l2 l3 l4 l5 l6 l7
	$80000000 rot -
	15 >> - ;
	
	
::log2fix | x -- log
	0? ( ; )
	0 swap | y x
	( $10000 <? 1 << swap $10000 - swap )
	( $20000 >=? 1 >> swap $10000 + swap )
	$8000 ( 1? swap | y z b
		dup 16 >> *	| y b z
		$20000 >=? ( 1 >> rot pick2 + -rot )
		swap 1 >> ) 2drop ;

::lnfix |#INV_LOG2_10_Q1DOT31 $268826a1
	log2fix $268826a1 31 *>> ;
	
::log10fix |#INV_LOG2_E_Q1DOT31  $58b90bfc
	log2fix $58b90bfc 31 *>> ;	
	

:ex1 over $58b91 - +? ( -rot nip 8 << ; ) drop ;
:ex2 over $2c5c8 - +? ( -rot nip 4 << ; ) drop ;
:ex3 over $162e4 - +? ( -rot nip 2 << ; ) drop ;
:ex4 over $b172 - +? ( -rot nip 1 << ; ) drop ;
:ex5 over $67cd - +? ( -rot nip dup 1 >> + ; ) drop ;
:ex6 over $3920 - +? ( -rot nip dup 2 >> + ; ) drop ;
:ex7 over $1e27 - +? ( -rot nip dup 3 >> + ; ) drop ;
:ex8 over $f85 - +? ( -rot nip dup 4 >> + ; ) drop ;
:ex9 over $7e1 - +? ( -rot nip dup 5 >> + ; ) drop ;
:exa over $3f8 - +? ( -rot nip dup 6 >> + ; ) drop ;
:exb over $1fe - +? ( -rot nip dup 7 >> + ; ) drop ;

:xp
	swap -? ( $b1721 + swap 16 >> ; ) swap ;

::exp. | x -- r
	1.0 | x y
	xp
	ex1 ex2 ex3 ex4 ex5 ex6
	ex7 ex8 ex9 exa exb
	swap | y x
	over 8 >> *. 8 >> + ;

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

::pow. | base exp -- r
	swap ln. *. exp. ;

::root. | base root -- r
	swap ln. swap /. exp. ;


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

::6/ | n -- r
	dup 1 >> over 3 >> + | n q
	dup 4 >> + dup 8 >> + dup 16 >> + 2 >> | n q
	swap over  | q n q
	dup 1 << + 1 << - | q n-q*6
	2 + 3 >> + ;

::6mod | n -- m
	dup 6/ dup 1 << + 1 << - ;

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

|- shift with sign
:shift
	-? ( neg >> ; ) << ;

|--- integer to floating point
::i2fp | i -- fp
	0? ( ; )
	dup 63 >> swap	| sign i
	over + over xor | sign abs(i) 
	dup clz 8 - 	| s i shift
	swap over shift 	| s shift i
	150 rot - 23 << | s i m
	swap $7fffff and or 
	swap $80000000 and or 
	;

|--- fixed point to floating point	
::f2fp | f.p -- fp
	0? ( ; )
	dup 63 >> swap	| sign i
	over + over xor | sign abs(i) 
	dup clz 8 - 	| s i shift
	swap over shift 	| v s shift i
	134 rot - 23 << | s i m | 16 - (fractional part)
	swap $7fffff and or 
	swap $80000000 and or 
	;
	
|--- floating point	to fixed point (32 bit but sign bit in 64)
::fp2f | fp -- fixed point
	dup $7fffff and $800000 or
	over 23 >> $ff and 134 - 
	shift 
	swap 63 >> - ;
