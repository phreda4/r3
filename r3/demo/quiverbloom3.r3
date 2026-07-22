| Swimming Quiverbloom v3
| a(m,d=mag(k=9*cos(i/81),e=i/765-13)/4) =>
|   point( (q=79-2*sin(k*3)
|             +sin(k*k<19 ? t*3+d*4 : d/2+4)/2*k*(9+5*sin(d*d-e/6-t+m))
|          )*sin(c=d*d/9-t/16+m) + 200 ,
|          (q+50)*cos(c) + 200 )
| t=0; for i=2e4..0 step -1: a(i, (i%2)*9)
| from original @yuruyurau

^r3/lib/sdl2gfx.r3
^r3/lib/math.r3

#t #i #m #k #e #d #q #c #branch #s
#SCALEX #SCALEY

:rsin | rad -- s
	0.1591549 *. sin ;
:rcos | rad -- s
	0.1591549 *. cos ;

:setcolor | col --
	dup 155 + $ff and 8 << swap
	255 swap - $ff and or
	$ff0000 or SDLColor ;

:nbr
	19.0 <? ( t 3.0 *. d 4.0 *. + ; ) 
	d 2.0 /. 4.0 + ;
	
:point | iin -- iin
	dup 'i !
	dup $10000 and 9 * 'm !

	i 81.0 /. rcos 9.0 *. 'k !
	i 765.0 /. 13.0 - 'e !

	k dup *. e dup *. + sqrt. 4.0 /. 'd !

	| branch = (k*k<19) ? (t*3+d*4) : (d/2+4)
	|k k *. 19.0 <? ( t 3.0 *. d 4.0 *. + ) ( d 2.0 /. 4.0 + ) if. 'branch !

	k k *. nbr 'branch ! drop
	
	| q = 79 - 2*sin(k*3) + sin(branch)/2*k*(9+5*sin(d*d-e/6-t+m))
	79.0
	k 3.0 *. rsin 2.0 *. -
	branch rsin 2.0 /. k *.
	d d *. e 6.0 /. - t - m + rsin 5.0 *. 9.0 +
	*. + 'q !

	d d *. 9.0 /. t 16.0 /. - m + 'c !

	k 3.0 *. rsin 100.0 *. int. 
	setcolor

	q c rsin *. 200.0 + 
	SCALEX *. int.

	q 50.0 + c rcos *. 200.0 + 
	SCALEY *. int.
	SDLPoint ;

:curve | --
	20000.0 ( 0.0 >? 1.0 - point ) drop ;

:advance-t | --
	t 0.125 + 100.53096 >=? ( 100.53096 - ) 't ! ;

:draw
	0 SDLcls
	curve
	SDLredraw
	advance-t

	SDLkey
	>esc< =? ( exit )
	drop ;

:main
	"Swimming Quiverbloom v3" 800 600 SDLinit
	800.0 380.0 /. 'SCALEX !
	600.0 400.0 /. 'SCALEY !
	0.0 't !
	'draw SDLshow
	SDLquit ;

: main ;
