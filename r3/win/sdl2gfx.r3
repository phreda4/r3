| SDL2 graf
|
^r3/win/sdl2.r3

::Color | col --
	SDLrenderer swap
	dup 16 >> $ff and swap dup 8 >> $ff and swap $ff and 
	$ff SDL_SetRenderDrawColor ;

::Point | x y --
	SDLRenderer rot rot SDL_RenderDrawPoint ;
	
::Line | x y x y --	
	>r >r >r >r SDLRenderer r> r> r> r> SDL_RenderDrawLine ;

#rec [ 0 0 0 0 ] | aux rect
#w 0 #h 0

::FRect | x y w h --	
	swap 2swap swap 'rec d!+ d!+ d!+ d!
	SDLRenderer 'rec SDL_RenderFillRect ;

::Rect | x y w h --	
	swap 2swap swap 'rec d!+ d!+ d!+ d!
	SDLRenderer 'rec SDL_RenderDrawRect ;

::Images | x y w h img --
	>r
	swap 2swap swap 'rec d!+ d!+ d!+ d!
	SDLrenderer r> 0 'rec SDL_RenderCopy ;
	
::Image | x y img --		
	dup 0 0 'w 'h SDL_QueryTexture >r
	swap 'rec d!+ d!+ h w rot d!+ d!
	SDLrenderer r> 0 'rec SDL_RenderCopy ;
	
::clrscr | color --
	Color SDLrenderer SDL_RenderClear ;
	
::redraw | -- 
	SDLrenderer SDL_RenderPresent ;
	
#ym #xm
#dx #dy

:inielipse | x y --
	'ym ! 'xm !
	over dup * dup 1 <<		| a b c 2aa
	swap dup >a 'dy ! 		| a b 2aa
	rot rot over neg 1 << 1 +	| 2aa a b c
	swap dup * dup 1 << 		| 2aa a c b 2bb
	rot rot * dup a+ 'dx !	| 2aa a 2bb
	1 + swap 1				| 2aa 2bb x y
	pick3 'dy +! dy a+
	;

:qf
	xm pick2 - ym pick2 - xm pick4 + over Line 
	xm pick2 - ym pick2 + xm pick4 + over Line  ;

::FEllipse | rx ry x y --
	a> >r
	inielipse
	xm pick2 - ym xm pick4 + over Line 
	( swap 0 >? swap 		| 2aa 2bb x y
		a> 1 <<
		dx >=? ( rot 1 - rot rot pick3 'dx +! dx a+ )
		dy <=? ( rot rot qf 1 + rot pick4 'dy +! dy a+ )
		drop
		)
	4drop 
	r> >a ;
	
:borde | x y x
	over Point Point ;

:qfb
	xm pick2 - ym pick2 - xm pick4 + borde
	xm pick2 - ym pick2 + xm pick4 + borde ;

::Ellipse | rx ry x y --
	a> >r
    inielipse
	xm pick2 - ym xm pick4 + borde
	( swap 0 >? swap 		| 2aa 2bb x y
		a> 1 <<
		dx >=? ( rot 1 - rot qfb rot pick3 'dx +! dx a+ )
		dy <=? ( rot rot qfb 1 + rot pick4 'dy +! dy a+ )
		drop
		)
	4drop 
	r> >a ;
	
|-------------------
#dx1 0
#dx2 0

:tri | yf x1. x2. yi -- x1. x2.
	( pick3 <? 
		pick2 16 >> over pick3 16 >> over Line
		rot dx1 + rot dx2 + rot
		1 + ) 
	drop rot drop ;
	
:triL | yx1 yx2 yx3 --  ; L
	dup 32 >> >r
	32 << 32 >> rot
	32 << 32 >> rot
	32 << 32 >> 
	pick2 pick2 pick2 min min
	>r max max
	>r >r | max min y
	rot over Line ;

:triV | yx1 yx2 yx3 --  ; V
	pick2 32 >> over 32 >> -
	0? ( drop triL ; ) 
	pick3 32 << 32 >> pick2 32 << 32 >> - 16 <<
	swap / 'dx1 !
	32 << 32 >> 16 <<
	pick2 32 >> swap	| yx1 yx2 yf x3. 
	2swap 				| yf x3. yx1 yx2 
	over 32 << 32 >> over 32 << 32 >> - 16 << | x1 - x2 (fp)
	rot 32 >> pick2 32 >> - 
	/  'dx2 !
	dup	32 << 32 >> 16 <<	|  yf x3. yx2 x2. 
	swap 32 >>
	tri 2drop ;
		
:itriangle | yx1 yx2 yx3 --
	over >? ( swap ) 
	pick2 >? ( rot ) >r 
	over >? ( swap ) r> | yxmax yxmed yxmin
	over 32 >> over 32 >> -
	0? ( drop triV ; )
	pick2 32 << 32 >> pick2 32 << 32 >> - 16 <<
	swap / 'dx1 !
	pick2 32 << 32 >> over 32 << 32 >> - 16 <<
	pick3 32 >> pick2 32 >> - /  'dx2 ! 
	over 32 >> 	over 32 << 32 >> 16 << dup  | yf x1 x1 
	pick3 32 >> | yf x1 x1 yi
	tri
	>r >r drop
	over 32 >> over 32 >> -
	0? ( 3drop r> r> 2drop ; )
	pick2 32 << 32 >> pick2 32 << 32 >> - 16 <<
	swap / 'dx1 !
	swap 32 >> swap
	r> r> rot 32 >>
	tri 2drop ;	
	
:xy 32 << swap $ffffffff and or ;
	
::Triangle | x y x y x y --
	xy >r xy >r xy r> r> itriangle ;

