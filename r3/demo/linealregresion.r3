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
	500 ( 1? 1 -
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
	
|	xmax xmin "%f %f " .print
|	xc xs "scal:%f center:%f" .println
|	ymax ymin "%f %f " .print
|	yc ys "scal:%f center:%f" .println
	;
	
| y = a*x + b	
#a 0
#b 0

:linefx | x -- y
	a * b + ;

#xm
#ym

:getlr
	points 
	@+ 'xm !
	@+ 'ym !
	( points> <?
		@+ xm + 1 >> 'xm !
		@+ ym + 1 >> 'ym !
		) drop 
	ym xm /. 'a !
	points 
	@+ swap @+ rot 
	a *. + 'b !
	( points> <?
		@+ swap @+ rot 
		a *. + b + 1 >> 'b !
		) drop ;

:getlr
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
	a *. + 'b !
	( points> <?
		@+ swap @+ rot | next x y
		a *. + 'b +! 
		) drop 
	points> points - 4 >> | cnt		
	b swap / 'b !
	;
	
		
|---------------------------------------
:xy2scr | x y -- xs ys
	ys *. yc + 16 >> sh 1 >> + swap
	xs *. xc + 16 >> sw 1 >> + swap ;
	
:scr2xy | x y -- x y 
	sh 1 >> - 16 << yc - ys /. swap
	sw 1 >> - 16 << xc - xs /. swap ;
	
	
:drawpoints
	$ffffff SDLcolor 
	points ( points> <? >a
		a@+ a@+  xy2scr SDLPoint	
		a> ) drop ;
	
:drawline
	$ff0000 SDLColor
	-0.5 dup linefx xy2scr
	0.5 dup linefx xy2scr
	SDLLine
	;
	
:main
	0 SDLclear
	drawpoints
	
	$ff00 SDLColor
	4 4 xm ym xy2scr SDLFillEllipse
	
	drawline
	
	SDLRedraw 
	SDLkey
	>esc< =? ( exit )
	<f1> =? ( getlr )
	<f2> =? ( xs 'xs +! ys 'ys +! )
	<f3> =? ( xs 1 >> 'xs ! ys 1 >> 'ys ! )
	drop
	[ SDLx SDLy scr2xy p!+ ; ] SDLClick
	;
		
:
	"r3sdl" 800 600 SDLinit
	
	here dup 'points ! 'points> !
	0 0 p!+
	
	|rerand 
	|randpoints
	-1.0 ( 1.0 <? dup dup p!+ 0.1 + ) drop
	
	limitspoints
	getlr
	
	'main SDLShow
	SDLquit 
	;			