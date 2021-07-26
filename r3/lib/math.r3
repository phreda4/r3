| r3 base - bangle
| 0--360
| 0--2*pi
| 0.0--1.0
| resultado = [0..1.0) [0..$ffff]
|---------------------------------

|------- punto fijo 16.16
::*.u	| a b -- c ; neg not 0
	16 *>> ;

::*.	| a b -- c
	16 *>> dup 63 >> - ;

::/.	| a b -- c
	16 <</ ;

::ceil	| a -- a
	$ffff + 16 >> ;

::sign | v -- v s
	dup 63 >> 1 or ;

:sinp
	$7fff and $4000 -
   	dup dup 16 *>>
	dup 4876210 16 *>>
	2699161 - 16 *>>
	411769 + 16 *>> ;

::cos | v -- r
	$8000 + $8000 nand? ( sinp ; ) sinp neg ;
::sin | v -- r
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
	2dup xor 1 >> rot rot and + ;

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

::between | v min max -- -(out)/+(in)
	pick2 - rot rot - or ;

:sq
	pick2 <=? ( swap 1 + >r - r> ; ) drop ;

::sqrt. | n -- v
	1 <? ( drop 0 ; )
	0 0 rot | root remhi remlo | 15 + bits/2+1
	24 ( 1? 1 - >r
		dup 30 >> $3 and	| ro rh rl rnh
		rot 2 << or			| ro rl rh
		swap 2 << swap
		rot 1 << dup 1 << 1 +		| rl rh ro td
		sq | rl rh ro
		swap rot r> )
    3drop ;

| http://www.quinapalus.com/efunc.html

:l1 over dup 1 >> + +? ( rot drop swap $67cd - ; ) drop ;
:l2 over dup 2 >> + +? ( rot drop swap $3920 - ; ) drop ;
:l3 over dup 3 >> + +? ( rot drop swap $1e27 - ; ) drop ;
:l4 over dup 4 >> + +? ( rot drop swap $f85 - ; ) drop ;
:l5 over dup 5 >> + +? ( rot drop swap $7e1 - ; ) drop ;
:l6 over dup 6 >> + +? ( rot drop swap $3f8 - ; ) drop ;
:l7 over dup 7 >> + +? ( rot drop swap $1fe - ; ) drop ;

::ln. | x --r
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

:ex1 over $58b91 - +? ( rot drop swap 8 << ; ) drop ;
:ex2 over $2c5c8 - +? ( rot drop swap 4 << ; ) drop ;
:ex3 over $162e4 - +? ( rot drop swap 2 << ; ) drop ;
:ex4 over $b172 - +? ( rot drop swap 1 << ; ) drop ;
:ex5 over $67cd - +? ( rot drop swap dup 1 >> + ; ) drop ;
:ex6 over $3920 - +? ( rot drop swap dup 2 >> + ; ) drop ;
:ex7 over $1e27 - +? ( rot drop swap dup 3 >> + ; ) drop ;
:ex8 over $f85 - +? ( rot drop swap dup 4 >> + ; ) drop ;
:ex9 over $7e1 - +? ( rot drop swap dup 5 >> + ; ) drop ;
:exa over $3f8 - +? ( rot drop swap dup 6 >> + ; ) drop ;
:exb over $1fe - +? ( rot drop swap dup 7 >> + ; ) drop ;

:xp
	swap -? ( $b1721 + swap 16 >> ; ) swap ;

::exp. | x --  r	; sin *.
	$10000	| x y
	xp
	ex1 ex2 ex3 ex4 ex5 ex6
	ex7 ex8 ex9 exa exb
	swap
	$100 and? ( swap dup 8 >> + swap )
	$80 and? ( swap dup 9 >> + swap )
	$40 and? ( swap dup 10 >> + swap )
	$20 and? ( swap dup 11 >> + swap )
	$10 and? ( swap dup 12 >> + swap )
	$8 and? ( swap dup 13 >> + swap )
	$4 and? ( swap dup 14 >> + swap )
	$2 and? ( swap dup 15 >> + swap )
	$1 and? ( swap dup 16 >> + swap )
	drop ;

::exp. | x --  r
	$10000	| x y
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
		1 >> rot dup * rot rot )
	drop nip
	;

::pow. | base exp -- r
	swap ln. *. exp. ;

::root. | base root -- r
	swap ln. swap /. exp. ;

::bswap
	dup 8 >> $ff00ff and
	swap 8 << $ff00ff00 and or
	dup 16 >>>
	swap 16 << or ;

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
