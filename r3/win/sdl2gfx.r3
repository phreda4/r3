| SDL2 basic graphics 
| PHREDA 2022

^r3/win/sdl2.r3

#sdlink

::SDLColor | col --
	dup 'sdlink !
	SDLrenderer swap
	dup 16 >> $ff and swap dup 8 >> $ff and swap $ff and 
	$ff SDL_SetRenderDrawColor ;

::SDLcls | color --
	SDLColor SDLrenderer SDL_RenderClear ;
	
::SDLredraw | -- 
	SDLrenderer SDL_RenderPresent ;
	
::SDLPoint | x y --
	SDLRenderer rot rot SDL_RenderDrawPoint ;
	
::SDLLine | x y x y --	
	>r >r >r >r SDLRenderer r> r> r> r> SDL_RenderDrawLine ;

#rec [ 0 0 0 0 ] | aux rect

::SDLFRect | x y w h --	
	swap 2swap swap 'rec d!+ d!+ d!+ d!
	SDLRenderer 'rec SDL_RenderFillRect ;

::SDLRect | x y w h --	
	swap 2swap swap 'rec d!+ d!+ d!+ d!
	SDLRenderer 'rec SDL_RenderDrawRect ;

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
	xm pick2 - ym pick2 - xm pick4 + over SDLLine 
	xm pick2 - ym pick2 + xm pick4 + over SDLLine  ;

::SDLFEllipse | rx ry x y --
	a> >r
	inielipse
	xm pick2 - ym xm pick4 + over SDLLine 
	( swap 0 >? swap 		| 2aa 2bb x y
		a> 1 <<
		dx >=? ( rot 1 - rot rot pick3 'dx +! dx a+ )
		dy <=? ( rot rot qf 1 + rot pick4 'dy +! dy a+ )
		drop
		)
	4drop 
	r> >a ;
	
:borde | x y x
	over SDLPoint SDLPoint ;

:qfb
	xm pick2 - ym pick2 - xm pick4 + borde
	xm pick2 - ym pick2 + xm pick4 + borde ;

::SDLEllipse | rx ry x y --
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
	
#vert [
0 0 0 0 0
0 0 0 0 0
0 0 0 0 0
0 0 0 0 0
]

#index [ 0 1 2 2 3 0 ]

::SDLTriangle | x y x y x y --
	'vert >a
	swap i2fp da!+ i2fp da!+ sdlink da!+ 8 a+
	swap i2fp da!+ i2fp da!+ sdlink da!+ 8 a+
	swap i2fp da!+ i2fp da!+ sdlink da!+ 
	SDLrenderer 0 'vert 3 0 0 SDL_RenderGeometry 
	;

|-------------------
::SDLImage | x y img --		
	dup 0 0 'xm 'ym SDL_QueryTexture >r
	swap 'rec d!+ d!+ ym xm rot d!+ d!
	SDLrenderer r> 0 'rec SDL_RenderCopy ;
	
::SDLImages | x y w h img --
	>r
	swap 2swap swap 'rec d!+ d!+ d!+ d!
	SDLrenderer r> 0 'rec SDL_RenderCopy ;
	
::SDLImageb | box img --
	SDLrenderer swap rot 0 swap SDL_RenderCopy ;
	
::SDLImagebb | box box img --
	SDLrenderer swap 2swap SDL_RenderCopy ;	
	
		
:fillvertr | x y --
	'vert >a
	over xm dx *. xm dy *. + - i2fp da!+ 
	dup ym dy *. ym dx *. + - i2fp da!+ $ffffffff da!+ 0.0 f2fp da!+ 0.0 f2fp da!+
	over xm dx *. xm dy *. + + i2fp da!+ 
	dup ym dy *. ym dx *. + - i2fp da!+ $ffffffff da!+ 1.0 f2fp da!+ 0.0 f2fp da!+
	over xm dx *. xm dy *. + + i2fp da!+ 
	dup ym dy *. ym dx *. + + i2fp da!+ $ffffffff da!+ 1.0 f2fp da!+ 1.0 f2fp da!+
	swap xm dx *. xm dy *. + - i2fp da!+ 
	ym dy *. ym dx *. + + i2fp da!+ $ffffffff da!+ 0.0 f2fp da!+ 1.0 f2fp da!+
	;
	
::SDLSpriteR | x y ang img --
	dup 0 0 'xm 'ym SDL_QueryTexture >r
	xm 1 >> 'xm ! ym 1 >> 'ym !
	sincos 'dx ! 'dy !
	fillvertr
	SDLrenderer r> 'vert 4 'index 6 SDL_RenderGeometry 
	;

:fillvertz | x y --
	'vert >a
	over xm - i2fp da!+ dup ym - i2fp da!+ $ffffffff da!+ 0.0 f2fp da!+ 0.0 f2fp da!+
	over xm + i2fp da!+ dup ym - i2fp da!+ $ffffffff da!+ 1.0 f2fp da!+ 0.0 f2fp da!+
	over xm + i2fp da!+ dup ym + i2fp da!+ $ffffffff da!+ 1.0 f2fp da!+ 1.0 f2fp da!+
	swap xm - i2fp da!+ ym + i2fp da!+ $ffffffff da!+ 0.0 f2fp da!+ 1.0 f2fp da!+
	;

::SDLspriteZ | x y zoom img --
	dup 0 0 'xm 'ym SDL_QueryTexture >r
	dup xm 17 *>> 'xm ! ym 17 *>> 'ym ! 
	fillvertz
	SDLrenderer r> 'vert 4 'index 6 SDL_RenderGeometry 
	;
