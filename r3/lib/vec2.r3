| vector 2d
| PHREDA 2020
|----------------
^r3/lib/math.r3

:2d+ | 'v1 'v2 -- ; v1=v1+v2
	@+ pick2 +! @ swap 4 + +! ;

:2d* | 'v1 n -- ; v1=v1*n
	over @ over *. swap !+
	dup @ rot *. swap ! ;

:2d/ | 'v1 n -- ; v1=v1/n
	over @ over /. swap !+
	dup @ rot /. swap ! ;

:2dmag | 'v -- m
	@+ dup *. swap @ dup *. + sqrt. ;

:2dnor | 'v --
	dup 2dmag 2d/ ;

:2dlim | 'v lim --
	over 2dmag over <=? ( 3drop ; )
	/. 2d* ;

:2drot | 'v bang --
	swap dup >r
	@+ swap @ rot
	sincos	| x y sin cos
	pick3 over *. pick3 pick3 neg *. +
	r> !+ >r
	rot rot *. rot rot *. +
	r> ! ;
