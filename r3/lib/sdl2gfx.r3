| SDL2 basic graphics 
| PHREDA 2022

^r3/lib/sdl2.r3
^r3/lib/sdl2image.r3	

#rec [ 0 0 0 0 ] | aux rect

#vert [
0 0 0 0 0	0 0 0 0 0
0 0 0 0 0	0 0 0 0 0
]

#index [ 0 1 2 2 3 0 ]

:rgb24 | rgb -- r g b
	dup 16 >> $ff and swap dup 8 >> $ff and swap $ff and ;

:rgb32 | argb -- r g b a
	dup 16 >> $ff and swap dup 8 >> $ff and swap dup $ff and swap 24 >> $ff and ;
	
::color | rgb -- ; set the draw color from $RRGGBB (alpha 255)
	SDLrenderer swap rgb24 $ff SDL_SetRenderDrawColor ;

::colorA | argb -- ; set the draw color from $AARRGGBB
	SDLrenderer swap rgb32 SDL_SetRenderDrawColor ;

::cls | rgb -- ; clear the target with the color $RRGGBB
	color SDLrenderer SDL_RenderClear ;
	
::point | x y -- ; draw a point
	SDLRenderer -rot SDL_RenderDrawPoint ;

::getpixel | x y -- rgb ; color $RRGGBB of the pixel 
	swap 'rec d!+ d!+ $100000001 swap !
	SDLrenderer 'rec $16362004 'vert 4 SDL_RenderReadPixels
	vert $ffffff and ;

::line | x1 y1 x2 y2 -- ; draw a line
	>r >r SDLRenderer -rot r> r> SDL_RenderDrawLine ;
	
::lineH | x1 y x2 -- ; horizontal line from x1 to x2 (both included) at y
	SDLRenderer swap 2swap swap over SDL_RenderDrawLine ;

::lineV | x y1 y2 -- ; vertical line from y1 to y2 (both included) at x
	SDLRenderer swap 2swap rot pick2 swap SDL_RenderDrawLine ;

::frect | x y w h -- ; filled rectangle (it covers x..x+w-1, y..y+h-1)
	swap 2swap swap 'rec d!+ d!+ d!+ d!
	SDLRenderer 'rec SDL_RenderFillRect ;

::rect | x y w h -- ; rectangle outline (same area as frect)
	swap 2swap swap 'rec d!+ d!+ d!+ d!
	SDLRenderer 'rec SDL_RenderDrawRect ;
	
|--- AUX VARS	
#ym #xm
#dx #dy
#d

|-----------------
:inielipse | x y --
	'ym ! 'xm !
	over dup * dup 1 <<		| a b c 2aa
	swap dup >a 'dy ! 		| a b 2aa
	-rot over neg 1 << 1+	| 2aa a b c
	swap dup * dup 1 << 		| 2aa a c b 2bb
	-rot * dup a+ 'dx !	| 2aa a 2bb
	1+ swap 1				| 2aa 2bb x y
	pick3 'dy +! dy a+
	;

:qf
	xm pick2 - ym pick2 - xm pick4 + lineH 
	xm pick2 - ym pick2 + xm pick4 + lineH  ;

::fellipse | rx ry x y -- ; filled ellipse with radii rx ry centered at x y
	ab[
	inielipse
	xm pick2 - ym xm pick4 + lineH
	( swap 0 >? swap 		| 2aa 2bb x y
		a> 1 <<
		dx >=? ( rot 1- -rot pick3 'dx +! dx a+ )
		dy <=? ( -rot qf 1+ rot pick4 'dy +! dy a+ )
		drop
		)
	4drop 
	]ba ;


|-----------------	
:borde | x y x
	over or b!+ or b!+ ;

:qfb
	xm pick2 - ym pick2 - 32 << xm pick4 + borde
	xm pick2 - ym pick2 + 32 << xm pick4 + borde ;

::ellipse | rx ry x y -- ; ellipse outline with radii rx ry centered at x y (BUG: the center row is missing, so there is a one pixel gap at each end)
	ab[
    inielipse
	here >b
	xm pick2 - ym xm pick4 + borde
	( swap 0 >? swap 		| 2aa 2bb x y
		a> 1 <<
		dx >=? ( rot 1- rot qfb rot pick3 'dx +! dx a+ )
		dy <=? ( -rot qfb 1+ rot pick4 'dy +! dy a+ )
		drop
		) 4drop 
	SDLrenderer here b> over - 3 >> SDL_RenderDrawPoints 
	]ba ;
	
|-----------------
:8points
	xm over - ym pick3 - xm dx + pick3 + lineH
	xm over - ym dy + pick3 + xm dx + pick3 + lineH
	xm pick2 - ym pick2 - ym dy + pick3 + lineV
	xm dx + pick2 + ym pick2 - ym dy + pick3 + lineV	 ;

:stepd
	d -? ( over 2 << 6 + + 'd ! ; )
	over pick3 - 2 << 10 + + 'd ! 
	8points swap 1- swap ;

::fround | r x y w h -- ; filled rectangle x y w h with rounded corners of radius r
	1- pick4 2* - 'dy ! 
	1- pick3 2* - 'dx !
	pick2 + 'ym ! over + 'xm !
	3 over 2* - 'd ! 
	0 ( over <=? stepd 1+ ) drop 
	xm over - ym pick2 -
	rot 2* 1+ dx over + dy rot +
	frect ;

|-----------------
:2points | x y x --
	over or a!+ or a!+ ;
	
:8points
	xm dx + over + ym dy + pick3 + 32 << xm pick3 - 2points
	xm dx + over + ym pick3 - 32 << xm pick3 - 2points
	xm dx + pick2 + ym dy + pick2 + 32 << xm pick4 - 2points
	xm dx + pick2 + ym pick2 - 32 << xm pick4 - 2points ;
	
:stepd
	b> -? ( over 2 << 6 + + >b ; )
	over pick3 - 2 << 10 + + >b 
	swap 1- swap ;

::round | r x y w h -- ; outline of a rectangle x y w h with rounded corners of radius r
	1- pick4 2* - 'dy ! 
	1- pick3 2* - 'dx !
	pick2 pick2 + over dx pick2 + lineH
	pick2 pick2 + over dy + pick4 2* + dx pick2 + lineH
	2dup pick4 + dy over + lineV
	over dx + pick3 2* + over pick4 + dy over + lineV	
	pick2 + 'ym ! over + 'xm !
	ab[
	3 over 2* - >b here >a
	0 ( 8points over <=? stepd 1+ ) 2drop 
	SDLrenderer here a> over - 3 >> SDL_RenderDrawPoints 
	]ba ;
	
|-----------------
:irect
	xm over - ym pick3 + xm pick3 + lineH
	xm over - ym pick3 - xm pick3 + lineH
	xm pick2 + ym pick2 - ym pick3 + lineV
	xm pick2 - ym pick2 - ym pick3 + lineV
	;
	
::fcircle | r x y -- ; filled circle of radius r centered at x y
	'ym ! 'xm !
	ab[
	3 over 2* - >b |'d !
	0 ( irect over <=? stepd 1+ ) 
	]ba
	xm over - ym pick3 -
	2swap 2* swap 2*
	frect ;

|-----------------
:8points
	xm over + ym pick3 + 32 << xm pick3 - 2points
	xm over + ym pick3 - 32 << xm pick3 - 2points
	xm pick2 + ym pick2 + 32 << xm pick4 - 2points
	xm pick2 + ym pick2 - 32 << xm pick4 - 2points ;
	
::circle | r x y -- ; circle outline of radius r centered at x y
	'ym ! 'xm !
	ab[
	3 over 2* - >b here >a
	0 ( 8points over <=? stepd 1+ ) 2drop
	SDLrenderer here a> over - 3 >> SDL_RenderDrawPoints 	
	]ba ;
	
|-----------------
:polyxy
	i2fp 32 << swap i2fp $ffffffff and or 'ym ! ;

::polyop | x y -- ; start a filled polygon with its first point 
	polyxy
	SDLrenderer 'rec dup 1+ dup 1+ dup 1+ SDL_GetRenderDrawColor
	'vert >a
	ym a!+ rec da!+ 8 a+
	8 a+ rec da!+ 8 a+
	8 a+ rec da!+ 
	1 'rec !
	;
	
:drawtri	
	'vert 20 + >a
	xm a!+ 12 a+ ym a!+ 12 a+
	SDLrenderer 0 'vert 3 0 0 SDL_RenderGeometry 
	ym 'xm ! 
	;
	
::polyline | x y -- ; add a point to the polygon: from the third point on each new point draws a filled triangle with the first point and the previous one
	polyxy
	1 'rec +!
	rec 2 =? ( drop ym 'xm ! ; ) drop
	drawtri
	;
		
|-----------------	
::triangle | x1 y1 x2 y2 x3 y3 -- ; filled triangle
	polyop polyline polyline ;

|-------------------
::image | x y img -- ; draw the texture at x y with its own size
	dup SDLTexwh 'ym ! 'xm ! >r
	swap 'rec d!+ d!+ ym xm rot d!+ d!
	SDLrenderer r> 0 'rec SDL_RenderCopy ;
	
::images | x y w h img -- ; draw the texture scaled to the rectangle x y w h
	>r
	swap 2swap swap 'rec d!+ d!+ d!+ d!
	SDLrenderer r> 0 'rec SDL_RenderCopy ;
	
::imageb | 'dst img -- ; draw the whole texture into the box 'dst (x y w h, four int32)
	SDLrenderer swap rot 0 swap SDL_RenderCopy ;
	
::imagebb | 'src 'dst img -- ; draw the box 'src of the texture into the box 'dst (x y w h, four int32 each)
	SDLrenderer swap 2swap SDL_RenderCopy ;	

|------------------- TILESET	
::tsload | w h "file" -- ts ; load an image as a tileset of tiles w x h (left to right, top to bottom); the table is kept in memory at here
	loadimg
	dup SDLTexwh 'ym ! 'xm ! 
	ab[
	here >a
	a!+ | texture
	2dup swap da!+ da!+ | w h 
	0 ( ym <? 
		0 ( xm <? | w h y x
			2dup da!+ da!+
			pick3 + ) drop 
		over + ) drop
	2drop 
	here a> 'here ! 
	]ba ;

::tscolor | rgb ts -- ; color modulation $RRGGBB of the tileset texture
	@ swap rgb24 SDL_SetTextureColorMod	;
	
::tsalpha | alpha ts -- ; alpha modulation (0..255) of the tileset texture
	@ swap SDL_SetTextureAlphaMod ;
	
#rdes [ 0 0 0 0 ]

::tsdraw | n ts x y -- ; draw tile n of the tileset at x y (its own size)
	swap 'rdes d!+ d!
	dup 8 + @ dup 'rdes 8 + ! 'rec 8 + !
	SDLrenderer 	| n 'ts ren
	-rot @+		| ren n 'ts texture
	rot 3 << rot 8 + + 
	@ 'rec ! | ren txture rsrc
	'rec 'rdes SDL_RenderCopy ;

::tsdraws | n ts x y w h -- ; draw tile n scaled to the rectangle x y w h
	swap 2swap swap 'rdes d!+ d!+ d!+ d!
	dup 8 + @ 'rec 8 + !
	SDLrenderer 	| n 'ts ren
	-rot @+		| ren n 'ts texture
	rot 3 << rot 8 + + 
	@ 'rec ! | ren txture rsrc
	'rec 'rdes SDL_RenderCopy ;

::tsbox | 'box n ts -- ; fill the 'box (x y w h, four int32) with the source rectangle of tile n
	dup 8 + @ pick3 8 + ! | w h
	| 'box n ts
	16 + swap 3 << + @ swap ! ;

::tsfree | ts -- ; free the texture of the tileset (the table stays in memory)
	@ SDL_DestroyTexture ;	
	
|-------------------	
:fillfull
	'vert >a 
	-1 0 $3f800000 |1.0 f2fp 
	8 a+ pick2 da!+ over da!+ over da!+
	8 a+ pick2 da!+ dup da!+ over da!+
	8 a+ pick2 da!+ dup da!+ dup da!+
	8 a+ pick2 da!+ over da!+ dup da!
	3drop ;
	
	
:fillvertxy | x y --
	'vert >a
	over xm - i2fp da!+ dup ym - i2fp da!+ 12 a+ 
	over xm + i2fp da!+ dup ym - i2fp da!+ 12 a+
	over xm + i2fp da!+ dup ym + i2fp da!+ 12 a+
	swap xm - i2fp da!+ ym + i2fp da!+
	;

:rotxya! | x y x1 y1 -- x y
	over dx * over dy * - | x y x1 y1 x'
	17 >> pick4 + i2fp da!+
	swap dy * swap dx * + | x y y'
	17 >> over + i2fp da!+ 
	;	

:fillvertr | x y ang --
	sincos 'dx ! 'dy !
	'vert >a
	xm neg ym neg rotxya! 12 a+
	xm ym neg rotxya! 12 a+
	xm ym rotxya! 12 a+
	xm neg ym rotxya!
	2drop ;

|-------------------------
::sprite | x y img -- ; draw the texture centered at x y
	|dup >r SDLTexwh 2/ 'ym ! 2/ 'xm !
	dup >r SDLTexwh 1+ 2/ 'ym ! 1+ 2/ 'xm ! | for not loss a line
	ab[ fillfull fillvertxy ]ba 
	SDLrenderer r> 'vert 4 'index 6 
	SDL_RenderGeometry ;
	
::spriteZ | x y zoom img -- ; draw the texture centered at x y with zoom (fixed point, 1.0 = normal size)
	dup >r SDLTexwh 1+ pick2 17 *>> 'ym ! 1+ 17 *>> 'xm !
	ab[ fillfull fillvertxy ]ba 
	SDLrenderer r> 'vert 4 'index 6 
	SDL_RenderGeometry ;

::spriteR | x y ang img -- ; draw the texture centered at x y rotated by ang (1.0 = full turn)
	dup >r SDLTexwh 'ym ! 'xm !
	ab[ fillfull fillvertr ]ba 
	SDLrenderer r> 'vert 4 'index 6 
	SDL_RenderGeometry ;

::spriteRZ | x y ang zoom img -- ; draw the texture centered at x y rotated by ang (1.0 = full turn) with zoom (fixed point)
	dup >r SDLTexwh 1+ pick2 16 *>> 'ym ! 1+ 16 *>> 'xm !
	ab[ fillfull fillvertr ]ba 
	SDLrenderer r> 'vert 4 'index 6 
	SDL_RenderGeometry ;

|----------------------	
::ssload | w h "file" -- ssprite ; load an image as a spritesheet of frames w x h (left to right, top to bottom) for the ssprite words; the table is kept in memory at here
	loadimg
	dup SDLTexwh 'dy ! 'dx !
	ab[
	here >a a!+ 		| texture
	2dup 32 << or a!+	| wi hi
	dy 16 <</ 'dy ! 
	dx 16 <</ 'dx ! | $ffff = 0.99..
	0 ( 1.0 dy - <=?
		0 ( 1.0 dx - <=?
			dup pick2 over dx + over dy + | x1 y1 x2 y2
			$1fffe and 47 << 
			swap $1fffe and 31 << or
			swap $1fffe and 15 << or
			swap $1fffe and 1 >> or
			a!+
			dx + ) drop
		dy + ) drop
	here a> 'here ! 
	]ba
	;
	
::sscnt | ssprite -- ssprite n ; number of frames (only right after ssload, while here has not changed)
	here over - | bytes
	16 - | header
	3 >> 
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

::sstint | argb -- ; tint color $AARRGGBB (with alpha) used by the ssprite words
	dup 2dup 'vert 8 + d!+ 16 + d!+ 16 + d!+ 16 + d! ;
	
::ssnotint | -- ; no tint for the ssprite words ($ffffffff)
	$ffffffff sstint ;

::sspritewh | ssprite -- w h ; size of a frame 
	8 + @ dup $ffffffff and swap 32 >>> ;
	
::ssprite | x y n ssprite -- ; draw frame n of the spritesheet centered at x y
	ab[
	dup sspritewh 1+ 2/ 'ym ! 1+ 2/ 'xm !
	settile >r fillvertxy
	SDLrenderer r> @ 'vert 4 'index 6 
	SDL_RenderGeometry 
	]ba ;

::sspriter | x y ang n ssprite -- ; draw frame n centered at x y rotated by ang (1.0 = full turn)
	ab[
	dup sspritewh 'ym ! 'xm !
	settile >r fillvertr
	SDLrenderer r> @ 'vert 4 'index 6 
	SDL_RenderGeometry 
	]ba ;

::sspritez | x y zoom n ssprite -- ; draw frame n centered at x y with zoom (fixed point, 1.0 = normal size)
	ab[
	rot over sspritewh 1+ pick2 17 *>> 'ym ! 1+ 17 *>> 'xm ! | /2
	settile >r fillvertxy
	SDLrenderer r> @ 'vert 4 'index 6 
	SDL_RenderGeometry 
	]ba ;
	
::sspriterz | x y ang zoom n ssprite -- ; draw frame n centered at x y rotated by ang (1.0 = full turn) with zoom
	ab[	
	rot over sspritewh 1+ pick2 16 *>> 'ym ! 1+ 16 *>> 'xm !
	settile >r fillvertr
	SDLrenderer r> @ 'vert 4 'index 6 
	SDL_RenderGeometry 
	]ba ;
	
::createSurf | w h -- surface ; create a 32-bit ARGB surface
	0 -rot 32 
	$ff0000 $ff00 $ff $ff000000  | ARGB
	SDL_CreateRGBSurface ;
	
::Surf>pix | surface -- surface pixels ; also leave the address of the pixels
	dup 32 + @ ;	

::Surf>wha | surface -- surface 'wh ; also leave the address of w and h (two int32)
	dup 16 + ;

::Surf>wh | surface -- surface w h ; also leave the width and the height
	dup 16 + d@+ swap d@ ;

::Surf>pixpi | surface -- pixels pitch ; address of the pixels and bytes per row (the surface is consumed)
	dup 32 + @ swap 24 + d@ ;

|------ compose texture
#comptex
	
::texIni | w h -- ; create a target texture w x h and draw into it (instead of the window) until texEnd; only one at a time
| $16362004 |ARGB
	>r >r SDLrenderer $16462004 2 r> r> SDL_CreateTexture 
	dup 'comptex !
	SDLrenderer swap SDL_SetRenderTarget ;
	
::texEnd | -- texture ; stop drawing into the texture, back to the window, and return the texture
	SDLrenderer 0 SDL_SetRenderTarget
	comptex	;
	
::texEndAlpha | -- texture ; like texEnd with alpha blending enabled on the texture
	texEnd
	dup 1 SDL_SetTextureBlendMode ;
	
::Tex2Surface | tex -- tex surface ; copy the pixels of a target texture into a new surface
	dup 'xm 'ym 'dx 'dy SDL_QueryTexture | xm=format 
	0 dx dy 0 xm SDL_CreateRGBSurfaceWithFormat | tex surf
	SDLrenderer pick2 SDL_SetRenderTarget
	SDLrenderer 0 xm pick3 Surf>pixpi SDL_RenderReadPixels
	SDlrenderer 0 SDL_SetRenderTarget ;

::Tex2Static | tex -- newtex ; convert a target texture into a static one (the original texture is freed)
	Tex2Surface
	SDLrenderer over SDL_CreateTexturefromSurface | new texture
	-rot SDL_FreeSurface SDL_destroytexture ;
	

: fillfull ;
