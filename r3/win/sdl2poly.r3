| SDL2 basic graphics 
| PHREDA 2022

^r3/win/sdl2gfx.r3

|--- convex polygon
#segs * 8192	| mem polys | 1024
#px #py
#ymin #ymax
#dx #dy #sx #sy

::SDLop | x y --
	a>
	ymin 3 << 'segs + >a
	ymax ymin - 1+ ( 1? 1 - 
		$7fffffff da!+ -1 da!+ ) drop
	>a
	dup 'ymin ! dup 'ymax !
	over dup pick2 3 << 'segs + d!+ d!
	'py ! 'px !
	;

:bdot | x y --	
	3 << 'segs + swap 				| a x
	over d@ <? ( dup pick2 d! )
	swap 4 + swap
	over d@ >? ( dup pick2 d! )
	2drop ;

::SDLop2 | x y --
	ymin <? ( dup 'ymin ! )
 	ymax >? ( dup 'ymax ! )
	2dup 'py ! 'px !
	bdot ;

:bline2
	dy dup neg 
	swap
	( 1? 1 - >r
		pick2 pick2 bdot
		dx + swap sy + swap
		dx neg >? ( dy - rot sx + -rot )
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
	dup swap | err n
	2over bdot
	( 1 - 1? >r
		dy - rot sx + -rot
		dy <? ( dx +
				pick2 sx - pick2 bdot
				swap sy + swap
				pick2 pick2 bdot
				)
		r> ) 2drop
	bdot ;

::SDLpoly
	a>
	ymax
	ymin dup 3 << 'segs + >a
	( over <=?
		da@+ over da@+ over SDLLine		
		1 + ) 2drop 
	>a 	;
	
#xc #yc #sa #ra 

::SDLFngon | ang n r x y --
	'yc ! 'xc ! 'ra !
	1.0 swap / 'sa !
	dup ra polar 
	swap xc + swap yc + SDLop
	0 ( 1.0 <? sa +
		2dup + ra polar 
		swap xc + swap yc + SDLpline
		) 2drop 
	SDLpoly
	;
			
|--------------------- lineas gruesas
#gg1 0 #ss1 0 #ang1 
#x1 #y1 

|---- lineas gruesas
:calcsum | n -- n suma
	2 <? ( $800 ; )
	8 <? ( $400 ; )
	32 <? ( $200 ; )
	128 <? ( $100 ; )
	$80 ;

::linegr!	| grosor --
	calcsum 'ss1 ! 'gg1 ! ;

::linegr	| -- grosor
	gg1 ;

:calg1 | angulo -- x y
	sincos 
	gg1 16 *>> rot + swap 
	gg1 16 *>> rot + swap ;

:glinei |x y x y --
	gg1 0? ( drop SDLLine ; ) drop
	pick3 pick2 - pick3 pick2 - atan2 $4000 + 'ang1 ! | +1/4 de angulo
	2over ang1 calg1 SDLop
	0 ( $8000 <? >r
		2dup ang1 r@ + calg1 SDLpline
		r> ss1 + ) drop
	2dup ang1 $8000 + calg1 SDLpline
	2drop
	$8000 ( $10000 <? >r
		2dup ang1 r@ + calg1 SDLpline
		r> ss1 + ) drop
	ang1 calg1 SDLpline 
	SDLpoly ;

::gop | x y --
	'y1 ! 'x1 ! ;

::gline | x y --
	y1 =? ( swap x1 =? ( 2drop ; ) swap )
	x1 y1 2over  'y1 ! 'x1 ! glinei ;
	
|----------------------------------
::SDLngon | ang n r x y --
	'yc ! 'xc ! 'ra !
	1.0 swap / 'sa !
	dup ra polar 
	swap xc + swap yc + gop
	0 ( 1.0 <? sa +
		2dup + ra polar 
		swap xc + swap yc + gline
		) 2drop 
	;	
	
:
	'segs >a
	1024 ( 1? 1 - $7fffffff da!+ -1 da!+ ) drop 
	;
