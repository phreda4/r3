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
::SDLimagewh | img -- w h
	0 0 'xm 'ym SDL_QueryTexture xm ym ;

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
	
:fillvertz | x y --
	'vert >a
	over xm - i2fp da!+ dup ym - i2fp da!+ 12 a+ |$ffffffff da!+ x1 f2fp da!+ y1 f2fp da!+
	over xm + i2fp da!+ dup ym - i2fp da!+ 12 a+ |$ffffffff da!+ x2 f2fp da!+ y1 f2fp da!+
	over xm + i2fp da!+ dup ym + i2fp da!+ 12 a+ |$ffffffff da!+ x2 f2fp da!+ y2 f2fp da!+
	swap xm - i2fp da!+ ym + i2fp da!+ 12 a+ |$ffffffff da!+ x1 f2fp da!+ y2 f2fp da!+
	;

::SDLspriteZ | x y zoom img --
	dup 0 0 'xm 'ym SDL_QueryTexture >r
	dup xm 17 *>> 'xm ! ym 17 *>> 'ym ! 
	fillvertz
	SDLrenderer r> 'vert 4 'index 6 SDL_RenderGeometry 
	;
		
:rotxy | x y -- x' y'
	over dx * over dy * -
	rot dy * rot dx * + ;
	
:coord | x y 'x 'y -- 
	swap 17 >> pick3 + i2fp da!+
	17 >> over + i2fp da!+ ;

:rotxya! | x y x1 y1 -- x y
	over dx * over dy * - | x y x1 y1 x'
	17 >> pick4 + i2fp da!+
	swap dy * swap dx * + | x y y'
	17 >> over + i2fp da!+ 
	;	

:fillvertr | x y --
	'vert >a
	xm neg ym neg rotxya! 12 a+ |x1 f2fp da!+ y1 f2fp da!+
	xm ym neg rotxya! 12 a+ |x2 f2fp da!+ y1 f2fp da!+
	xm ym rotxya! 12 a+ |x2 f2fp da!+ y2 f2fp da!+
	xm neg ym rotxya! 12 a+ |x1 f2fp da!+ y2 f2fp da!+
	2drop
	;
	
::SDLSpriteR | x y ang img --
	dup 0 0 'xm 'ym SDL_QueryTexture >r
	sincos 'dx ! 'dy !
	fillvertr
	SDLrenderer r> 'vert 4 'index 6 SDL_RenderGeometry 
	;

::SDLspriteRZ | x y ang zoom img --
	dup 0 0 'xm 'ym SDL_QueryTexture >r
	dup xm *. 'xm ! ym *. 'ym ! 
	sincos 'dx ! 'dy !
	fillvertr
	SDLrenderer r> 'vert 4 'index 6 SDL_RenderGeometry 
	;

|-------------- sprite in tilesheet
::SDLspr.tilesheet | nro width height -- | 2 .25 .25
	'vert >a
	rot pick2 /mod | w h yn xn
	2swap 1.0 rot / 1.0 rot / | yn xn dw dh
	
	
	
	|x1 y1 x2 y2 ************8
	0 f2fp 0 f2fp 1.0 f2fp 1.0 f2fp 
	12 a+ pick3 da!+ pick2 da!+
	12 a+ over da!+ pick2 da!+
	12 a+ over da!+ dup da!+
	12 a+ pick3 da!+ dup da!+
	4drop
	;
	
::SDLspr.tilefull 
	'vert >a 
	$ffffffff 0 f2fp 1.0 f2fp 
	8 a+ pick2 da!+ over da!+ over da!+
	8 a+ pick2 da!+ dup da!+ over da!+
	8 a+ pick2 da!+ dup da!+ dup da!+
	8 a+ pick2 da!+ over da!+ dup da!+
	3drop
	;

::SDLspr.load | tw th filename -- ts
	|loadimg
	here >a a!+ | texture
	1.0 rot / da!+
	1.0 swap / da!+
	
	2dup swap da!+ da!+ | w h 
|	0 ( h <? 
|		0 ( w <? | w h y x
|			2dup da!+ da!+
|			pick3 + ) drop 
|		over + ) drop
	2drop 
	here a> 'here ! 
	;

: SDLspr.tilefull ;