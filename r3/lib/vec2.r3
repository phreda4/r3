| vector 2d
| PHREDA 2020
| #v2 0 0 | x y
|----------------
^r3/lib/math.r3

::v2= | 'v1 'v2 -- ; v1 = v2 (copy)
	2 move ;

::v2+ | 'v1 'v2 -- ; v1 = v1 + v2
	@+ pick2 +! @ swap 8 + +! ;

::v2- | 'v1 'v2 -- ; v1 = v1 - v2
	@+ neg pick2 +! @ neg swap 8 + +! ;

::v2+* | m 'v1 'v2 -- ; v1 = v1 + v2 * m (m fixed point)
	@+ pick3 *. pick2 +! 
	@ rot *. swap 8 + +! ;

::v2-* | m 'v1 'v2 -- ; v1 = v1 - v2 * m (m fixed point)
	@+ neg pick3 *. pick2 +! 
	@ neg rot *. swap 8 + +! ;

::v2* | 'v1 n -- ; v1 = v1 * n (n fixed point)
	over @ over *. rot !+ | n 'v1y
	dup @ rot *. swap ! ;

::v2/ | 'v1 n -- ; v1 = v1 / n (n fixed point; n = 0 crashes)
	over @ over /. rot !+
	dup @ rot /. swap ! ;

::v2len | 'v -- m ; length of the vector (fixed point)
	@+ dup *. swap @ dup *. + sqrt. ;

::v2nor | 'v -- ; scale the vector to length 1.0 (a zero vector crashes)
	dup v2len v2/ ;

::v2lim | 'v lim -- ; limit the length of the vector to lim (fixed point)
	over v2len over <=? ( 3drop ; )
	/. v2* ;

::v2rot | 'v bang -- ; x' = x*sin - y*cos, y' = x*cos + y*sin (BUG: bang 0 turns the vector 90 degrees, 0.25 leaves it as is)
	sincos pick2 @ dup			| v sin cos x x
	pick2 *. swap pick3 *.		| v sin cos xc xs
	rot pick4 8 + @ *. - 		| v sin xc xscy
	rot pick3 8 + @ *. rot +	| v xscy xcsy
	swap rot !+ ! ;

::v2dot | 'v1 'v2 -- dot ; dot product (fixed point)
	@+ swap @ | v1 v2x v2y
	rot @+ swap @ | v2x v2y v1x v1y
	rot *. -rot *. + ;

::v2perp | 'dst 'src -- ; dst = (-src.y, src.x): src turned 90 degrees counter-clockwise (v1 is the destination)
	@+ swap @ neg rot !+ ! ;
	