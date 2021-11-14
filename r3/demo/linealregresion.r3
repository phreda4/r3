| linel regresion in 2d fixed point
| PHREDA 2021

^r3/win/sdl2.r3
^r3/win/console.r3
^r3/lib/mem.r3
^r3/lib/rand.r3

#xc #yc | center point
#xs #ys | scale

| point list in x,y
#points
#points>

:p!+ | x y --
	swap points> !+ !+ 'points> ! ;

:randpoints
	5 ( 1? 1 -
		2.0 randmax 1.0 -
		2.0 randmax 1.0 -
		p!+ 
		) drop  ;
	
#xmin #xmax
#ymin #ymax

:limitspoints
	-1.0 dup 'xmin ! 'ymin !
	1.0 dup 'xmax ! 'ymax !	
	points 
|	@+ dup 'xmin ! 'xmax !
|	@+ dup 'ymin ! 'ymax !
	( points> <?
		@+ 
		xmin <? ( dup 'xmin ! )
		xmax >? ( dup 'xmax ! )
		drop
		@+ 
		ymin <? ( dup 'ymin ! )
		ymax >? ( dup 'ymax ! )
		drop
		) drop 
	xmax xmin 
	2dup + 1 >> 'xc !
	- sw 16 << swap /. 'xs ! 
	ymax ymin 
	2dup + 1 >> 'yc !	
	- sh 16 << swap /. 'ys ! 
	;
	
| y = a*x + b	
#a #b 

:linefx | x -- y
	a *. b + ;

#xm | sum x
#ym | sum y
#xq | sum x*x
#xy | sum x*y

:getlinealr
	points 
	@+ dup 'xm ! dup dup *. 'xq !
	swap 
	@+ dup 'ym ! rot *. 'xy !
	( points> <?
		@+ dup 'xm +! dup dup *. 'xq +!
		swap 
		@+ dup 'ym +! rot *. 'xy +!		
		) drop 
	points> points - 4 >> | cnt			
	0? ( drop ; )
	xq over * xm dup *. - | n d
	0? ( 2drop ; ) 
	swap xy * xm ym *. - over /. 'a !
	ym xq *. xm xy *. - swap /. 'b !
	;
	
|---------------------------------------
| world to screen
:xy2scr | x y -- xs ys
	ys *. yc + 16 >> sh 1 >> + swap
	xs *. xc + 16 >> sw 1 >> + swap ;
	
| screen to world	
:scr2xy | x y -- x y 
	sh 1 >> - 16 << yc - ys /. swap
	sw 1 >> - 16 << xc - xs /. swap ;
	
:drawpoints
	$ffffff SDLcolor 
	points ( points> <? >a
		a@+ a@+ xy2scr SDLPoint	
		a> ) drop ;
	
:drawline
	$ff0000 SDLColor
	-0.5 dup linefx xy2scr
	0.5 dup linefx xy2scr
	SDLLine ;
	
:main
	0 SDLclear
	
	drawpoints
	drawline
	
	SDLRedraw 
	SDLkey
	>esc< =? ( exit )
	<f1> =? ( getlinealr ) 					| recalculate
	<f2> =? ( xs 'xs +! ys 'ys +! ) 		| double view
	<f3> =? ( xs 1 >> 'xs ! ys 1 >> 'ys ! ) | half view
	drop
	[ SDLx SDLy scr2xy p!+ getlinealr ; ] SDLClick | add point
	;
		
:
	"r3sdl" 800 600 SDLinit
	here dup 'points ! 'points> !

	limitspoints
	getlinealr
	
	'main SDLShow
	SDLquit 
	;			