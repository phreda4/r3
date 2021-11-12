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
	points 
	@+ dup 'xmin ! 'xmax !
	@+ dup 'ymin ! 'ymax !
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

#xm #ym | center point

:getlinealr
	points 
	@+ 'xm ! @+ 'ym !
	( points> <?
		@+ 'xm +! @+ 'ym +!
		) drop 
	points> points - 4 >> | cnt
	xm over / 'xm !
	ym swap / 'ym ! 
	
	ym xm /. 'a !
	points 
	@+ swap @+ rot | next x y
	a *. swap - 'b !
	( points> <?
		@+ swap @+ rot | next x y
		a *. swap - 'b +! 
		) drop 
	points> points - 4 >> | cnt		
	b swap / 'b !
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
	
	$ff00 SDLColor
	4 4 xm ym xy2scr SDLFillEllipse
	
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
	
	|rerand randpoints
	
	-1.0 ( 1.0 <? dup over neg p!+ 0.4 + ) drop

	limitspoints
	getlinealr
	
	'main SDLShow
	SDLquit 
	;			