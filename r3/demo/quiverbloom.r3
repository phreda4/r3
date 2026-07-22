| Swimming Quiverbloom - puerto de QB64 a r3forth
| https://github.com/oonap0oo/QB64-projects/tree/main
| Original: K Moerman 2026

^r3/lib/sdl2gfx.r3
^r3/lib/math.r3

#t #y #k #e #d #q #c #xp #yp
#SCALEX #SCALEY

| SIN/COS de argumentos en radianes (los que vienen de x, no de t)
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
	dup 11.0 /. 8.0 t *. + rsin 4.0 +
	over 14.0 /. rcos *. 'k !

	y 9.0 /. 19.0 - 'e !

	k dup *. e dup *. + sqrt.
	y 9.0 /. 3.0 t *. + rsin + 'd !

	k 2.0 *. rsin 2.0 *.
	y 17.0 /. rsin k *.
	y d 3.0 *. - rsin 2.0 *. 9.0 +
	*. + 'q !

	d dup *. 50.0 /. 'c !

	q c rcos 50.0 *. - 85.0 - 'xp !
	d 39.0 *. q c rsin *. - 620.0 - 'yp !

	k 3.0 *. rsin 100.0 *. int. 
	setcolor

	xp t cos *. yp t sin *. - 
	190.0 + SCALEX *. int.
	
	xp t sin *. yp t cos *. + 
	200.0 + SCALEY *. int.
	
	SDLPoint ;

:curve | --
	0.0 ( 12000.0 <=?
		point 0.5 +
		) drop ;

| t en turns: 1.0 = 2*PI, avanza PI/400 rad = 1/800 turn por frame
:advance-t | --
	t 0.00125 + $ffff and 't ! ;

:draw
	0 SDLcls
	curve
	SDLredraw
	advance-t

	SDLkey
	>esc< =? ( exit )
	drop ;

:main
	"Swimming Quiverbloom" 800 600 SDLinit
	800.0 380.0 /. 'SCALEX !
	600.0 400.0 /. 'SCALEY !
	0.0 't !
	'draw SDLshow
	SDLquit ;

: main ;
