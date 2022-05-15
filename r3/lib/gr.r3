| Drawing words
| PHREDA 2018,2020
|--------------------------
^r3/lib/mem.r3

##paper 0
##ink $ff00

##xop 0 ##yop 0
##ccx 0 ##ccy 0	| cursor for text

::cls
  vframe paper sizebuffer dfill ;

::xy>v | x y -- adr
  sw * + 2 << vframe + ;

::pset | x y --
  xy>v ink swap d! ;

::psetc | c x y --
  xy>v d! ;

::pget | x y -- c
  xy>v d@ ;

:hline | xd yd xa --
  pick2 - 0? ( drop pset ; )
  -? ( rot over + rot rot neg )
  >r xy>v ink r> dfill ;

:hlineo | xmin yd xmax --
  pick2 - 0? ( drop pset ; )
  >r xy>v ink r> dfill ;

:vline | x1 y1 cnt
	rot rot xy>v >a
	( 1? 1 - ink da! sw 2 << a+ ) drop ;

:iline | xd yd --
  yop =? ( xop hline ; )
  xop yop
  pick2 <? ( 2swap )   | xm ym xM yM
  pick2 - 1 + >r	   | xm ym xM  r:canty
  pick2 - 0? ( drop r> vline ; )
  r@ 16 <</
  rot 16 << $8000 +
  rot rot r>           | xm<<16 ym delta canty
  ( 1? 1 - >r >r
    over 16 >> over pick3 r@ + 16 >> hline
    1 + swap
    r@ + swap
    r> r> ) 4drop ;

::bline | x y --
  2dup iline
::op | x y --
  'yop ! 'xop ! ;

::fillrect  | w h x y --
  xy>v >a
  ( 1? 1 -
    a> ink pick3 dfill
	sw 2 << a+
    ) 2drop ;

#ym #xm
#dx #dy

:inielipse
	over dup * dup 1 <<		| a b c 2aa
	swap dup >a 'dy ! 		| a b 2aa
	rot rot over neg 1 << 1 +	| 2aa a b c
	swap dup * dup 1 << 		| 2aa a c b 2bb
	rot rot * dup a+ 'dx !	| 2aa a 2bb
	1 + swap 1				| 2aa 2bb x y
	pick3 'dy +! dy a+
	;

:qf
	xm pick2 - ym pick2 - xm pick4 + hlineo
	xm pick2 - ym pick2 + xm pick4 + hlineo ;

::bellipse | x y rx ry --
	'ym ! 'xm !
	inielipse
	xm pick2 - ym xm pick4 + hlineo
	( swap 0 >? swap 		| 2aa 2bb x y
		a> 1 <<
		dx >=? ( rot 1 - rot rot pick3 'dx +! dx a+ )
		dy <=? ( rot rot qf 1 + rot pick4 'dy +! dy a+ )
		drop
		)
	4drop ;

:borde | x y x
	over pset pset ;

:qfb
	xm pick2 - ym pick2 - xm pick4 + borde
	xm pick2 - ym pick2 + xm pick4 + borde ;

::bellipseb | x y rx ry --
	'ym ! 'xm !
    inielipse
	xm pick2 - ym xm pick4 + borde
	( swap 0 >? swap 		| 2aa 2bb x y
		a> 1 <<
		dx >=? ( rot 1 - rot qfb rot pick3 'dx +! dx a+ )
		dy <=? ( rot rot qfb 1 + rot pick4 'dy +! dy a+ )
		drop
		)
	4drop ;

|----------------------
#cf #cc
#sa #sb
#herel

:spanabove | adr y x -- adr y x
	sa 0? ( drop
		2dup swap 1 - -? ( 2drop ; )
		pget cf <>? ( drop ; ) drop
		rot >a 2dup	swap 1 -
		da!+ da!+ a> rot rot
		1 'sa ! ; ) drop
	2dup swap 1 - pget cf =? ( drop ; ) drop
	0 'sa ! ;

:spanbelow | adr y x -- adr y x
	sb 0? ( drop
		2dup swap 1 + sh >=? ( 2drop ; )
		pget cf <>? ( drop ; ) drop
		rot >a 2dup swap 1 +
		da!+ da!+ a> rot rot
		1 'sb ! ; ) drop
	2dup swap 1 + pget cf =? ( drop ; ) drop
	0 'sb ! ;

:fillline | adr y x1 -- adr'
	0 'sa ! 0 'sb !
	( sw <?
		2dup swap pget cf <>? ( 3drop ; ) drop
		dup pick2 pset | adr y x
		spanabove
		spanbelow
		1 + ) 2drop ;

:firstx | y x -- y x
	( +? 2dup swap pget cf <>? ( drop 1 + ; ) drop 1 - ) 1 + ;

::floodfill | c x y --
	2dup pget pick3 =? ( 4drop ; )
	'cf ! rot 'ink !
	here dup 'herel !
	!+ !+	| x y
 	( herel >? 8 - dup @+ swap @	| adr y x
 		firstx	| adr y x1
		fillline
 		) drop ;

|-----------------------------------------
::rectbox | x1 y1 x2 y2 --
	2dup op
	over pick3 bline
	2swap over swap bline
	over bline bline ;

::box.inv | w h x y --
	xy>v >a
	( 1? 1 -
		over ( 1? 1 - da@ not da!+ ) drop
		sw pick2 - 2 << a+
		) 2drop ;

|--------------------------------
:2sort | x y -- max min
	over >? ( swap ) ;

:dot
	dup herel +
	%100 and? ( drop 4 a+ ; ) drop
	da@ not da!+ ;

:dotvline | x y1 y2 --
	2sort
	sh >=? ( 3drop ; ) 0 max
	swap -? ( 3drop ; ) sh 1 - min
	over - 1 +
	>r xy>v >a r>
	( 1? 1 - dot sw 1 - 2 << a+ ) drop ;

:dothline | x1 x2 y --
	-? ( 3drop ; ) sh >=? ( 3drop ; )
	rot	rot 2sort
	sw >=? ( 3drop ; ) 0 max
	swap -? ( 3drop ; ) sw 1 - min
	over - 1 +
	swap rot xy>v >a
	( 1? 1 - dot ) drop ;

::box.dot | x1 y1 x2 y2 --
	SDL_GetTicks 5 >> 'herel !
	pick3 pick3 pick2 dotvline
	herel neg 'herel !
	over pick3 pick2 dotvline
	herel neg 'herel !
	pick3 pick2 rot dothline
	herel neg 'herel !
	swap dothline ;
