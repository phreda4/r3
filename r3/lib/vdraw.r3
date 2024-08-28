| Virtual Draw
| PHREDA 2020
|-------------
^r3/lib/mem.r3
^r3/lib/math.r3

#vecs
#vecg
#maxw #maxh

::vset! | 'set --
	'vecs ! ;

::vget! | 'get --
	'vecg ! ;

::vsize! | w h --
	'maxh ! 'maxw ! ;

#xa #ya

:ihline | xd yd xa --
	pick2 - 0? ( drop vecs ex ; )
	-? ( rot over + -rot neg )
	( 1? 1 - >r
		2dup vecs ex
		swap 1 + swap
		r> ) 3drop ;

:ivline | x y y --
	over >? ( swap )
	( over <=?
		pick2 over vecs ex
		1 + ) 3drop ;

:rline | xd yd --
	ya =? ( xa ihline ; )
	xa ya pick2 <? ( 2swap )	| xm ym xM yM
	pick2 - 1 + >r			| xm ym xM  r:canty
	pick2 - r@ 16 <</
	rot 16 << $8000 +
	-rot r> 				|xm<<16 ym delta canty
	( 1? 1 - >r >r
		over 16 >> over pick3 r@ + 16 >> ihline
		1 + swap
		r@ + swap
		r> r> )
	4drop ;

::vop | x y  --
	'ya ! 'xa ! ;

::vline | x y --
	2dup rline 'ya ! 'xa ! ;

|---------------
#cf #cc
#sa #sb
#herel

:spanabove | adr y x -- adr y x
	sa 0? ( drop
		2dup swap 1 - -? ( 2drop ; )
		vecg ex cf <>? ( drop ; ) drop
		rot >a 2dup	swap 1 -
		a!+ a!+ a> -rot
		1 'sa ! ; ) drop
	2dup swap 1 - vecg ex cf =? ( drop ; ) drop
	0 'sa ! ;

:spanbelow | adr y x -- adr y x
	sb 0? ( drop
		2dup swap 1 + maxh >=? ( 2drop ; )
		vecg ex cf <>? ( drop ; ) drop
		rot >a 2dup swap 1 +
		a!+ a!+ a> -rot
		1 'sb ! ; ) drop
	2dup swap 1 + vecg ex cf =? ( drop ; ) drop
	0 'sb ! ;

:fillline | adr y x1 -- adr'
	0 'sa ! 0 'sb !
	( maxw <?
		2dup swap vecg ex cf <>? ( 3drop ; ) drop
		dup pick2 vecs ex | adr y x
		spanabove
		spanbelow
		1 + ) 2drop ;

:firstx | y x -- y x
	( +? 2dup swap vecg ex cf <>? ( drop 1 + ; ) drop 1 - ) 1 + ;

::vfill | c x y --
	2dup vecg ex pick3 =? ( 4drop ; )
	'cf ! rot drop |'ink !
	here dup 'herel !
	!+ !+	| x y
 	( herel >? 16 - dup @+ swap @	| adr y x
 		firstx	| adr y x1
		fillline
 		) drop ;

|---------------
::vrect | x1 y1 x2 y2 --
	2over pick3 ihline
	pick3 over pick3 ihline
	2over 1 + pick2 1 - ivline
    2swap nip ivline ;

:2sort over <? ( swap ) ;
	
::vfrect | x1 y1 x2 y2 --
	rot 2sort over - | x1 x2 y1 h
	( 1? 1- 
		pick3 pick2 pick4 ihline
		swap 1+ swap ) 4drop ;

|---------------
#ym #xm
#dx #dy

:iniellipse
	over dup * dup 1 <<		| a b c 2aa
	swap dup >a 'dy ! 		| a b 2aa
	-rot over neg 1 << 1 +	| 2aa a b c
	swap dup * dup 1 << 		| 2aa a c b 2bb
	-rot * dup a+ 'dx !	| 2aa a 2bb
	1 + swap 1				| 2aa 2bb x y
	pick3 'dy +! dy a+
	;

:qf
	xm pick2 - ym pick2 - xm pick4 + ihline
	xm pick2 - ym pick2 + xm pick4 + ihline ;

::vellipse | rx ry x y --
	'ym ! 'xm !
	iniellipse
	xm pick2 - ym xm pick4 + ihline
	( swap 0 >? swap 		| 2aa 2bb x y
		a> 1 <<
		dx >=? ( rot 1 - -rot pick3 'dx +! dx a+ )
		dy <=? ( -rot qf 1 + rot pick4 'dy +! dy a+ )
		drop
		)
	4drop ;

:bor | x y x --
	over vecs ex vecs ex ;

:qfb
	xm pick2 - ym pick2 - xm pick4 + bor
	xm pick2 - ym pick2 + xm pick4 + bor ;

::vellipseb | rx ry x y --
	'ym ! 'xm !
	iniellipse
	xm pick2 - ym xm pick4 + bor
	( swap 0 >? swap 		| 2aa 2bb x y
		a> 1 <<
		dx >=? ( rot 1 - rot qfb rot pick3 'dx +! dx a+ )
		dy <=? ( -rot qfb 1 + rot pick4 'dy +! dy a+ )
		drop
		)
	4drop ;

