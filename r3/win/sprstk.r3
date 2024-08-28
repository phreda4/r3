| SDL2 sprite stack
| PHREDA 2024

^r3/win/sdl2gfx.r3	


#vert [
0 0 0 0 0
0 0 0 0 0
0 0 0 0 0
0 0 0 0 0
]

#index [ 0 1 2 2 3 0 ]

:rgb24 | rgb -- r g b
	dup 16 >> $ff and swap dup 8 >> $ff and swap $ff and ;

:rgb32 | argb -- r g b a
	dup 16 >> $ff and swap dup 8 >> $ff and swap dup $ff and swap 24 >> $ff and ;
	
|-------------------	
:fillfull
	'vert >a 
	$ffffffff 0 $3f800000 |1.0 f2fp 
	8 a+ pick2 da!+ over da!+ over da!+
	8 a+ pick2 da!+ dup da!+ over da!+
	8 a+ pick2 da!+ dup da!+ dup da!+
	8 a+ pick2 da!+ over da!+ dup da!
	3drop ;
	

|-------------- ISO
#ym #xm
#dx #dy

##isx 0.87
##isy 0.5
##isz -1.0

::xyz2iso | x y z -- x y
	-rot
	over isx *. over isx *. + | z x y x'
	rot isy neg *. rot isy *. + | x' y'
	rot + ;
	
	
:rotxyiso! | x y x1 y1 -- x y
	over dx * over dy * - | x y x1 y1 x'
	rot dy * rot dx * +	| x y x' y'
	over isx *. over isx *. +   | x y x' y' x''
	17 >> pick4 + i2fp da!+
	swap isy neg *. swap isy *. +   | x y 
	17 >> over + i2fp da!+ 
	;	

:fillvertiso | x y ang --
	sincos 'dx ! 'dy !
	'vert >a
	xm neg ym neg rotxyiso! 12 a+
	xm ym neg rotxyiso! 12 a+
	xm ym rotxyiso! 12 a+
	xm neg ym rotxyiso!
	2drop ;

:fillvertisoy | dy --
	'vert 4 + >a | y
	da@ fp2f over + 16 >> i2fp da!+ 16 a+
	da@ fp2f over + 16 >> i2fp da!+ 16 a+
	da@ fp2f over + 16 >> i2fp da!+ 16 a+
	da@ fp2f over + 16 >> i2fp da!+
	drop ;


|----------------------	
::ssload | w h "file" -- ssprite
	loadimg
	dup 0 0 'dx 'dy SDL_QueryTexture
	here >a a!+ 		| texture
	2dup 32 << or a!+	| wi hi
	$ffff rot dx */ 'dx ! | $ffff = 0.99..
	$ffff swap dy */ 'dy ! 
	0 ( 1.0 dy - <?
		0 ( 1.0 dx - <?
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

::sstint | color --- ; with alpha!! AARRGGBB
	'vert >a 8 a+ dup da!+ 16 a+ dup da!+ 16 a+ dup da!+ 16 a+ da! ;
	
::ssnotint 
	$ffffffff sstint ;

::sspritewh | adr -- h w
	8 + @ dup $ffffffff and swap 32 >>> ;
	
	
::sspriteiso | x y ang zoom n ssprite --
	rot over sspritewh pick2 16 *>> 'ym ! 16 *>> 'xm !
	settile >r fillvertiso
	SDLrenderer r> @ 'vert 4 'index 6 
	SDL_RenderGeometry ;

::sspriteniso | dy n ssprite --
	settile >r fillvertisoy
	SDLrenderer r> @ 'vert 4 'index 6 
	SDL_RenderGeometry ;
	


: fillfull ;