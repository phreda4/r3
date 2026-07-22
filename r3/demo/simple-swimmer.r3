| Simple swimmer - puerto de QB64 a r3forth
| https://github.com/oonap0oo/QB64-projects/tree/main

^r3/lib/sdl2gfx.r3
^r3/lib/math.r3

#PI 3.14159265
#t #a #at #b #e #l #w #x #y
#px #py #prevpx #prevpy
#SCALEX #SCALEY #ASTEP

:rsin | rad -- s   
	0.1591549 *. sin ;
:rcos | rad -- s   
	0.1591549 *. cos ;

:setcolor2 | col --
	dup $ff and 16 << $ff00 or
	swap 1 swap - $ff and or
	SDLColor ;

:point-a | a -- 
	'a !

	a 2.0 *. PI *. 8.0 t *. - 'at !

	a 450.0 *. rsin
	a 930.0 *. rsin 0.7 +
	*. 'b !

	2.0 a *.
	a 8.0 *. neg exp.
	*. 'e !

	0.7 a - 1.5 *.
	1.0 b dup *. 8.0 /. -
	*. t + 'l !

	e b *. at rsin 12.0 /. - 0.75 + 'w !

	w l rcos *. 'x !
	w l rsin *. 'y !

	b 4.0 *. a 6.0 *. - rcos 127.0 *. 128.0 + int. 
	setcolor2

	x 1.0 + SCALEX *. int. 'px !
	y 1.0 + SCALEY *. int. 'py !
	
	prevpx 1? ( dup prevpy px py SDLLine ) drop
	px 'prevpx !
	py 'prevpy ! ;

:curve | --
	0 'prevpx !
	0.0 ( 1.0 <=?
		dup point-a
		ASTEP +
		) drop ;

| t en radianes 0..2*PI, paso PI/600 por frame
:advance-t | --
	t 0.00523599 + 6.2831853 >=? ( 6.2831853 - ) 't ! ;

:draw
	0 SDLcls
	curve
	SDLredraw
	advance-t

	SDLkey
	>esc< =? ( exit )
	drop ;

:main
	"Simple swimmer" 1000 900 SDLinit
	500.0 'SCALEX !
	450.0 'SCALEY !
	1.0 2999.0 /. 'ASTEP !
	0.0 't !
	'draw SDLshow
	SDLquit ;

: main ;
