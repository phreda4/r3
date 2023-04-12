| SDL2 basic graphics 
| PHREDA 2022

^r3/win/sdl2.r3
^r3/win/sdl2image.r3	

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

|-------------------	
:fillfull
	'vert >a 
	$ffffffff 0 $3f800000 |1.0 f2fp 
	8 a+ pick2 da!+ over da!+ over da!+
	8 a+ pick2 da!+ dup da!+ over da!+
	8 a+ pick2 da!+ dup da!+ dup da!+
	8 a+ pick2 da!+ over da!+ dup da!+
	3drop ;
	
:fillvertxy | x y --
	'vert >a
	over xm - i2fp da!+ dup ym - i2fp da!+ 12 a+ 
	over xm + i2fp da!+ dup ym - i2fp da!+ 12 a+
	over xm + i2fp da!+ dup ym + i2fp da!+ 12 a+
	swap xm - i2fp da!+ ym + i2fp da!+ 12 a+
	;

:rotxya! | x y x1 y1 -- x y
	over dx * over dy * - | x y x1 y1 x'
	17 >> pick4 + i2fp da!+
	swap dy * swap dx * + | x y y'
	17 >> over + i2fp da!+ 
	;	

:fillvertr | x y --
	'vert >a
	xm neg ym neg rotxya! 12 a+
	xm ym neg rotxya! 12 a+
	xm ym rotxya! 12 a+
	xm neg ym rotxya! 12 a+
	2drop ;

|-------------------------	
::SDLspriteZ | x y zoom img --
	dup 0 0 'xm 'ym SDL_QueryTexture >r
	dup xm 17 *>> 'xm ! ym 17 *>> 'ym ! 
	fillfull
	fillvertxy
	SDLrenderer r> 'vert 4 'index 6 SDL_RenderGeometry 
	;	

::SDLSpriteR | x y ang img --
	dup 0 0 'xm 'ym SDL_QueryTexture >r
	sincos 'dx ! 'dy !
	fillfull
	fillvertr
	SDLrenderer r> 'vert 4 'index 6 SDL_RenderGeometry 
	;

::SDLspriteRZ | x y ang zoom img --
	dup 0 0 'xm 'ym SDL_QueryTexture >r
	dup xm *. 'xm ! ym *. 'ym ! 
	sincos 'dx ! 'dy !
	fillfull
	fillvertr
	SDLrenderer r> 'vert 4 'index 6 SDL_RenderGeometry 
	;

|----------------------	
::loadssheet | w h file -- ss
	loadimg
	dup 0 0 'dx 'dy SDL_QueryTexture
	here >a a!+ 		| texture
	2dup 32 << or a!+	| wi hi
	1.0	pick2 dx */ 'dx !
	1.0 over dy */ 'dy ! 
	swap | h w
	0 ( 1.0 <?
		0 ( 1.0 <?
			dup pick2 over dx + over dy + | x1 y1 x2 y2
			$1fffe and 47 << 
			swap $1fffe and 31 << or
			swap $1fffe and 15 << or
			swap $1fffe and 1 >> or
			a!+
			dx + ) drop
		dy + ) drop
	here a> 'here ! 
	;

:settile | n adr -- adr
	swap 3 << 16 + over +
	@ dup 1 << $1fffe and f2fp | x1
	swap dup 15 >> $1fffe and f2fp 
	swap dup 31 >> $1fffe and f2fp 
	swap 47 >> $1fffe and f2fp 
	'vert >a
	12 a+ pick3 da!+ pick2 da!+
	12 a+ over da!+ pick2 da!+
	12 a+ over da!+ dup da!+
	12 a+ pick3 da!+ dup da!+
	4drop ;
	
::ssprite | x y n ssprite --
	dup 8 + d@+ 1 >> 'xm ! d@ 1 >> 'ym !
	settile >r 
	fillvertxy
	SDLrenderer r> @ 'vert 4 'index 6 SDL_RenderGeometry 
	;

::sspriter | x y ang n ssprite --
	dup 8 + d@+ 'xm ! d@ 'ym !
	settile >r 
	sincos 'dx ! 'dy !
	fillvertr
	SDLrenderer r> @ 'vert 4 'index 6 SDL_RenderGeometry 
	;

::sspritez | x y zoom n ssprite --
	dup 8 + d@+ 1 >> 'xm ! d@ 1 >> 'ym !
	settile >r 
	dup xm *. 'xm ! ym *. 'ym ! 
	fillvertxy
	SDLrenderer r> @ 'vert 4 'index 6 SDL_RenderGeometry 
	;
	
::sspriterz | x y ang zoom n ssprite --
	dup 8 + d@+ 'xm ! d@ 'ym !
	settile >r 
	dup xm *. 'xm ! ym *. 'ym ! 
	sincos 'dx ! 'dy !
	fillvertr
	SDLrenderer r> @ 'vert 4 'index 6 SDL_RenderGeometry 
	;	

: fillfull ;