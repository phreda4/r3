| SDL2 basic graphics 
| PHREDA 2022

^r3/win/sdl2gfx.r3

|--- convex polygon
#segs * 8192	| mem polys | 1024
#px #py
#ymin #ymax
#dx #dy #sx #sy

::SDLop | x y --
	ymin 3 << segs + >a
	ymax ymin - 1+ ( 1? 1 - $7fffffff da!+ -1 da!+ ) drop |  -1 $7ffff
	dup 'ymin ! dup 'ymax !
	over dup pick2 3 << segs + d!+ d!
	'py ! 'px !
	;

::SDLop2 | x y --
	ymin <? ( dup 'ymin ! )
 	ymax >? ( dup 'ymax ! )
	dup 'py !
	3 << segs + >a
	da@+ <? ( dup a> 4 - d! )
	da@+ >? ( dup a> 4 - d! )
	'px ! ;

:bdot | x y --
	3 << segs + >a
	da@+ <? ( dup a> 4 - d! )
	da@+ >? ( dup a> 4 - d! )
	drop ;

:bline2
	dy dup neg |2/
	swap
	( 1? 1 - >r
		pick2 pick2 bdot
		dx + swap sy + swap
		dx neg >? ( dy - rot sx + rot rot )
		r> ) 2drop
	bdot ;

::SDLpline | x y --
	py over - 0? ( drop over 'px ! bdot ; )
	sign 'sy ! abs 'dy !
	px pick2 -
	sign 'sx ! abs 'dx !
	ymin <? ( dup 'ymin ! )
 	ymax >? ( dup 'ymax ! )
	2dup 'py ! 'px !
	dx dy <=? ( drop bline2 ; )
	dup |2/
	swap | err n
	2over bdot
	( 1 - 1? >r
		dy - rot sx + rot rot
		dy <? ( dx +
				pick2 sx - pick2 bdot
				swap sy + swap
				pick2 pick2 bdot
				)
		r> ) 2drop
	bdot ;

::SDLpoly
	ymax
	ymin dup 3 << segs + >b
	( over <=?
		db@+ over db@+ b> >r 
		over SDLLine
		r> >b
		1 + ) 2drop ;
