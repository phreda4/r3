| vector 2d
| PHREDA 2020
| #v2 0 0 | x y
|----------------
^r3/lib/math.r3

::v2= | 'v1 'v2 -- ; v1=v2
	2 move ;

::v2+ | 'v1 'v2 -- ; v1=v1+v2
	@+ pick2 +! @ swap 8 + +! ;

::v2- | 'v1 'v2 -- ; v1=v1-v2
	@+ neg pick2 +! @ neg swap 8 + +! ;

::v2+* | m 'v1 'v2 -- ; v1=v1+v2*s
	@+ pick3 *. pick2 +! 
	@ rot *. swap 8 + +! ;

::v2-* | m 'v1 'v2 -- ; v1=v1-v2*s
	@+ neg pick3 *. pick2 +! 
	@ neg rot *. swap 8 + +! ;

::v2* | 'v1 n -- ; v1=v1*n
	over @ over *. swap !+
	dup @ rot *. swap ! ;

::v2/ | 'v1 n -- ; v1=v1/n
	over @ over /. swap !+
	dup @ rot /. swap ! ;

::v2len | 'v -- m
	@+ dup *. swap @ dup *. + sqrt. ;

::v2nor | 'v --
	dup v2len v2/ ;

::v2lim | 'v lim --
	over v2len over <=? ( 3drop ; )
	/. v2* ;

::v2rot | 'v bang --
	sincos pick2 @ dup			| v sin cos x x
	pick2 *. swap pick3 *.		| v sin cos xc xs
	rot pick4 8 + @ *. - 		| v sin xc xscy
	rot pick3 8 + @ *. rot +	| v xscy xcsy
	swap rot !+ ! ;

::v2dot | 'v1 'v2 -- dot
	@+ swap @ | v1 v2x v2y
	rot @+ swap @ | v2x v2y v1x v1y
	rot *. -rot *. + ;

::v2perp | 'v1 'v2 --  ; v2 = perpendicular v1
	@+ swap @ neg rot !+ ! ;
	