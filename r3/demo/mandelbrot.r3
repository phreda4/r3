| simple mandelbrot viewer
| PHREDA 2010
|---------------------------------
^r3/win/console.r3	
^r3/win/sdl2.r3	

^r3/lib/math.r3
^r3/lib/str.r3

#textbit
#mpixel 
#mpitch
#srct [ 0 0 800 600 ]
#vframe

:renderbitmap
	textbit 'srct 'mpixel 'mpitch SDL_LockTexture
	mpixel vframe 800 600 * dmove 
	textbit SDL_UnlockTexture
	SDLrenderer textbit 0 'srct SDL_RenderCopy		
	SDLrenderer SDL_RenderPresent
	;
	
#xmax #ymax #xmin #ymin

:calc | p q cx cy -- p q cx cy xn yn r
	over dup *. over dup *. - pick4 + | xn
	pick2 pick2 *. 1 << pick4 +		| xn yn
	over dup *. over dup *. +			| xn yn r
	;

:mandel | x y -- x y v
	over xmax xmin - sw */ xmin +	| x y p
	over ymax ymin - sh */ ymin +	| x y p q
	0 0 0 | cx cy it
	( 255 <? >r 	| x y p q cx cy
		calc		| x y p q cx cy xn yn r
		4.0 >? ( 4drop 3drop r> ; )
		drop rot drop rot drop
		r> 1 + )
	nip nip nip nip
	;

:color | c -- color
  dup dup 3 << $ff and
  rot 2 << $ff and
  rot 1 << $ff and
  8 << or 8 << or ;

:calcmandel
	vframe >a
	600 ( 1? 1 -
		800 ( 1? 1 - swap
			mandel color da!+
			swap ) drop
		) drop ;

:main
	here 'vframe !
	
	"r3sdl" 800 600 SDLinit
	800 600 SDLframebuffer 'textbit !
	
	.cls 
	" Calculando..." .println
	
	msec
	2.0 'xmax ! 2.0 'ymax !
	-3.0 'xmin ! -2.0 'ymin !
	calcmandel
	renderbitmap	

	msec swap - " %d ms " .println
	
	.input
	
	SDLquit	
	;

: main ;

