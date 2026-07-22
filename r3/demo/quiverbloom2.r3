| Swimming Quiverbloom
| a(x,y,d=mag(k=4*cos(x/21),e=y/8-20)) =>
|   circle( q=3*sin(k*2)+.3/k+sin(y/19)*k*(9+2*sin(e*14-d*3+t*2))
|           + 50*cos(c=d-t) + 200 ,
|           q*sin(c) + d*39 - 475 ,
|           k*k>15 ? 2 : 1 )
| from original @yuruyurau

^r3/lib/sdl2gfx.r3
^r3/lib/math.r3

#t #y #k #e #d #q #c
#SCALEX #SCALEY

:rsin | rad -- s
	0.1591549 *. sin ;
:rcos | rad -- s
	0.1591549 *. cos ;

:setcolor | col --
	dup 155 + $ff and 8 << swap
	255 swap - $ff and or
	$ff0000 or SDLColor ;

:point | xin --
	dup 235.0 /. 'y !
	dup 21.0 /. rcos 4.0 *. 'k !

	y 8.0 /. 20.0 - 'e !
	k dup *. e dup *. + sqrt. 'd !

	| q = 3*sin(k*2) + .3/k + sin(y/19)*k*(9+2*sin(e*14-d*3+t*2))
	k 2.0 *. rsin 3.0 *.
	0.3 k /. +
	y 19.0 /. rsin k *.
	e 14.0 *. d 3.0 *. - t 2.0 *. + rsin 2.0 *. 9.0 +
	*. + 'q !
	d t - 'c !

	k 3.0 *. rsin 100.0 *. int. 
	setcolor

	q c rcos 50.0 *. + 200.0 + 
	SCALEX *. int.

	q c rsin *. d 39.0 *. + 475.0 - 
	SCALEY *. int.
	SDLPoint ;

:curve | --
	0.0 ( 10000.0 <=?
		point 1.0 +
		) drop ;

:advance-t | --
	t 0.0125 + 6.2831853 >=? ( 6.2831853 - ) 't ! ;

:draw
	0 SDLcls
	curve
	SDLredraw
	advance-t

	SDLkey
	>esc< =? ( exit )
	drop ;

:main
	"Swimming Quiverbloom v2" 800 600 SDLinit
	800.0 380.0 /. 'SCALEX !
	600.0 400.0 /. 'SCALEY !
	0.0 't !
	'draw SDLshow
	SDLquit ;

: main ;
