| sdl2 rotate render texture triangle
| PHREDA 2022
^r3/win/sdl2.r3
^r3/win/sdl2gfx.r3
^r3/win/sdl2image.r3	

#textura
#ssexplode

#vert [
0 0 0 0 0
0 0 0 0 0
0 0 0 0 0
0 0 0 0 0
]

#index [ 0 1 2 2 3 0 ]

#ym #xm | size
#dx #dy

:fillfull
	'vert >a 
	$ffffffff 0 f2fp 1.0 f2fp 
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
	
:ssload | w h file -- ss
	loadimg
	dup 0 0 'dx 'dy SDL_QueryTexture
	here >a a!+ 		| texture
	2dup 32 << or a!+	| wi hi
	1.0 pick2 dx */ 'dx !
	1.0 over dy */ 'dy ! 
	swap | h w
	0 ( 1.0 <?
		0 ( 1.0 <?
			dup pick2 over dx + over dy + | x1 y1 x2 y2
|			pick3 f2fp pick3 f2fp pick3 f2fp pick3 f2fp "%h %h %h %h" .println | any better encode?
			$1ffff and 47 <<
			swap $1ffff and 31 << or
			swap $1ffff and 15 << or
			swap $1ffff and 1 >> or
			a!+
			dx + ) drop
		dy + ) drop
	here a> 'here ! 
	;

:settile | n adr -- adr
	swap 3 << 16 + over +
	@ dup 1 << $1ffff and f2fp | x1
	swap dup 15 >> $1ffff and f2fp 
	swap dup 31 >> $1ffff and f2fp 
	swap 47 >> $1ffff and f2fp 
	'vert >a
	12 a+ pick3 da!+ pick2 da!+
	12 a+ over da!+ pick2 da!+
	12 a+ over da!+ dup da!+
	12 a+ pick3 da!+ dup da!+
	4drop ;
	
:ssprite | x y n ssprite --
	dup 8 + d@+ 1 >> 'xm ! d@ 1 >> 'ym !
	settile >r 
	fillvertxy
	SDLrenderer r> @ 'vert 4 'index 6 SDL_RenderGeometry 
	;

:sspriter | x y a n ssprite --
	dup 8 + d@+ 'xm ! d@ 'ym !
	settile >r 
	sincos 'dx ! 'dy !
	fillvertr
	SDLrenderer r> @ 'vert 4 'index 6 SDL_RenderGeometry 
	;

::sspritez | x y ang zoom n ssprite --
	dup 8 + d@+ 'xm ! d@ 'ym !
	settile >r 
	dup xm *. 'xm ! ym *. 'ym ! 
	sincos 'dx ! 'dy !
	fillvertr
	SDLrenderer r> @ 'vert 4 'index 6 SDL_RenderGeometry 
	;	
	
:main
	$0 SDLcls
	20 20 textura SDLImage
	
	sdlx sdly msec 6 >> $f and ssexplode ssprite 
	sdlx 50 + sdly msec 7 <<  msec 6 << $7ffff and msec 6 >> $f and ssexplode sspritez
	
	SDLredraw
	
	SDLkey
	>esc< =? ( exit )
	drop ;

:
	"r3sdl" 800 600 SDLinit
	"media/img/lolomario.png" loadimg 'textura !
	64 64 "media/img/explo_64x64.png" ssload 'ssexplode !
	fillfull
	'main SDLshow 
	SDLquit
	;

