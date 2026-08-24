| SDL2 basic graphics 
| PHREDA 2022

^r3/lib/sdl2gfx.r3

|--- convex polygon
#rec
#xy1 #xy2 
#vert [ 0 0 0 0 0	0 0 0 0 0	0 0 0 0 0 ]

::polyop | x y --
	i2fp 32 << swap i2fp $ffffffff and or 'xy1 !
	SDLrenderer 'rec dup 1+ dup 1+ dup 1+ SDL_GetRenderDrawColor
	'vert >a
	xy1 a!+ rec da!+ 8 a+
	8 a+ rec da!+ 8 a+
	8 a+ rec da!+ 
	1 'rec !
	;
	
:drawtri	
	'vert 20 + >a
	xy2 a!+ 12 a+ xy1 a!+ 12 a+
	SDLrenderer 0 'vert 3 0 0 SDL_RenderGeometry 
	xy1 'xy2 ! 
	;
	
::polyline | x y --
	i2fp 32 << swap i2fp $ffffffff and or 'xy1 !
	1 'rec +!
	rec 2 =? ( drop xy1 'xy2 ! ; ) drop
	drawtri
	;
	

#xc #yc #sa #ra 

::fngon | ang n r x y --
	'yc ! 'xc ! 'ra !
	1.0 swap / 'sa !
	dup ra polar 
	swap xc + swap yc + polyop
	0 ( 1.0 <? sa +
		2dup + ra polar 
		swap xc + swap yc + polyline
		) 2drop 
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
	gg1 0? ( drop line ; ) drop
	pick3 pick2 - pick3 pick2 - swap atan2 $4000 + 'ang1 ! | +1/4 de angulo
	2over ang1 calg1 polyop
	0 ( $8000 <? >r
		2dup ang1 r@ + calg1 polyline
		r> ss1 + ) drop
	2dup ang1 $8000 + calg1 polyline
	2drop
	$8000 ( $10000 <? >r
		2dup ang1 r@ + calg1 polyline
		r> ss1 + ) drop
	ang1 calg1 polyline ;

::gop | x y --
	'y1 ! 'x1 ! ;

::gline | x y --
	y1 =? ( swap x1 =? ( 2drop ; ) swap )
	x1 y1 2over  'y1 ! 'x1 ! glinei ;
	
|----------------------------------
::ngon | ang n r x y --
	'yc ! 'xc ! 'ra !
	1.0 swap / 'sa !
	dup ra polar 
	swap xc + swap yc + gop
	0 ( 1.0 <? sa +
		2dup + ra polar 
		swap xc + swap yc + gline
		) 2drop 
	;	
	
