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
	
::SDLColor | col --
	SDLrenderer swap rgb24 $ff SDL_SetRenderDrawColor ;

::SDLColorA | col --
	SDLrenderer swap rgb32 SDL_SetRenderDrawColor ;

::SDLcls | color --
	SDLColor SDLrenderer SDL_RenderClear ;
	
::SDLPoint | x y --
	SDLRenderer -rot SDL_RenderDrawPoint ;

::SDLGetPixel | x y -- v
	swap 'rec d!+ d!+ $10001 swap !
	SDLrenderer 'rec $16362004 'vert 1 SDL_RenderReadPixels 
	vert $ffffff and ;

::SDLLine | x y x y --	
	>r >r SDLRenderer -rot r> r> SDL_RenderDrawLine ;
	
::SDLLineH | x y x --	
	SDLRenderer swap 2swap swap over SDL_RenderDrawLine ;

::SDLLineV | x y y --	
	SDLRenderer swap 2swap rot pick2 swap SDL_RenderDrawLine ;

::SDLFRect | x y w h --	
	swap 2swap swap 'rec d!+ d!+ d!+ d!
	SDLRenderer 'rec SDL_RenderFillRect ;

::SDLRect | x y w h --	
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
	xm pick2 - ym pick2 - xm pick4 + SDLLineH 
	xm pick2 - ym pick2 + xm pick4 + SDLLineH  ;

::SDLFEllipse | rx ry x y --
	ab[
	inielipse
	xm pick2 - ym xm pick4 + SDLLineH
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

::SDLEllipse | rx ry x y --
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
::SDLTriangle | x y x y x y --
	SDLrenderer 'rec dup 1+ dup 1+ dup 1+ SDL_GetRenderDrawColor
	'vert >a
	swap i2fp da!+ i2fp da!+ rec da!+ 8 a+
	swap i2fp da!+ i2fp da!+ rec da!+ 8 a+
	swap i2fp da!+ i2fp da!+ rec da!+ 
	SDLrenderer 0 'vert 3 0 0 SDL_RenderGeometry  ;
	
|-----------------
:8points
	xm over - ym pick3 - xm dx + pick3 + sdlLineH
	xm over - ym dy + pick3 + xm dx + pick3 + sdlLineH
	xm pick2 - ym pick2 - ym dy + pick3 + sdlLineV
	xm dx + pick2 + ym pick2 - ym dy + pick3 + sdlLineV	 ;

:stepd
	d -? ( over 2 << 6 + + 'd ! ; )
	over pick3 - 2 << 10 + + 'd ! 
	8points swap 1- swap ;

::SDLFRound | r x y w h --
	1- pick4 2* - 'dy ! 
	1- pick3 2* - 'dx !
	pick2 + 'ym ! over + 'xm !
	3 over 2* - 'd ! 
	0 ( over <=? stepd 1+ ) drop 
	xm over - ym pick2 -
	rot 2* 1+ dx over + dy rot +
	SDLfRect ;

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

::SDLRound | r x y w h --
	1- pick4 2* - 'dy ! 
	1- pick3 2* - 'dx !
	pick2 pick2 + over dx pick2 + SDLLineH
	pick2 pick2 + over dy + pick4 2* + dx pick2 + SDLLineH
	2dup pick4 + dy over + SDLLineV
	over dx + pick3 2* + over pick4 + dy over + SDLLineV	
	pick2 + 'ym ! over + 'xm !
	ab[
	3 over 2* - >b here >a
	0 ( 8points over <=? stepd 1+ ) 2drop 
	SDLrenderer here a> over - 3 >> SDL_RenderDrawPoints 
	]ba ;
	
|-----------------
:rect
	xm over - ym pick3 + xm pick3 + sdlLineH
	xm over - ym pick3 - xm pick3 + sdlLineH
	xm pick2 + ym pick2 - ym pick3 + sdlLineV
	xm pick2 - ym pick2 - ym pick3 + sdlLineV
	;
	
::SDLFCircle | r x y --
	'ym ! 'xm !
	ab[
	3 over 2* - >b |'d !
	0 ( rect over <=? stepd 1+ ) 
	]ba
	xm over - ym pick3 -
	2swap 2* swap 2*
	sdlfrect ;

|-----------------
:8points
	xm over + ym pick3 + 32 << xm pick3 - 2points
	xm over + ym pick3 - 32 << xm pick3 - 2points
	xm pick2 + ym pick2 + 32 << xm pick4 - 2points
	xm pick2 + ym pick2 - 32 << xm pick4 - 2points ;
	
::SDLCircle | r x y --
	'ym ! 'xm !
	ab[
	3 over 2* - >b here >a
	0 ( 8points over <=? stepd 1+ ) 2drop
	SDLrenderer here a> over - 3 >> SDL_RenderDrawPoints 	
	]ba ;

|-------------------
::SDLImage | x y img --		
	dup SDLTexwh 'ym ! 'xm ! >r
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

|------------------- TILESET	
::tsload | w h filename -- ts
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

::tscolor | rrggbb 'ts --
	@ swap rgb24 SDL_SetTextureColorMod	;
	
::tsalpha | alpha 'ts --
	@ swap SDL_SetTextureAlphaMod ;
	
#rdes [ 0 0 0 0 ]

::tsdraw | n 'ts x y --
	swap 'rdes d!+ d!
	dup 8 + @ dup 'rdes 8 + ! 'rec 8 + !
	SDLrenderer 	| n 'ts ren
	-rot @+		| ren n 'ts texture
	rot 3 << rot 8 + + 
	@ 'rec ! | ren txture rsrc
	'rec 'rdes SDL_RenderCopy ;

::tsdraws | n 'ts x y w h --
	swap 2swap swap 'rdes d!+ d!+ d!+ d!
	dup 8 + @ 'rec 8 + !
	SDLrenderer 	| n 'ts ren
	-rot @+		| ren n 'ts texture
	rot 3 << rot 8 + + 
	@ 'rec ! | ren txture rsrc
	'rec 'rdes SDL_RenderCopy ;

::tsbox | 'boxsrc n 'ts --
	dup 8 + @ pick3 8 + ! | w h
	| 'box n ts
	16 + swap 3 << + @ swap ! ;

::tsfree | ts --
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
::sprite | x y img --
	|dup >r SDLTexwh 2/ 'ym ! 2/ 'xm !
	dup >r SDLTexwh 1+ 2/ 'ym ! 1+ 2/ 'xm ! | for not loss a line
	ab[ fillfull fillvertxy ]ba 
	SDLrenderer r> 'vert 4 'index 6 
	SDL_RenderGeometry ;
	
::spriteZ | x y zoom img --
	dup >r SDLTexwh 1+ pick2 17 *>> 'ym ! 1+ 17 *>> 'xm !
	ab[ fillfull fillvertxy ]ba 
	SDLrenderer r> 'vert 4 'index 6 
	SDL_RenderGeometry ;

::spriteR | x y ang img --
	dup >r SDLTexwh 'ym ! 'xm !
	ab[ fillfull fillvertr ]ba 
	SDLrenderer r> 'vert 4 'index 6 
	SDL_RenderGeometry ;

::spriteRZ | x y ang zoom img --
	dup >r SDLTexwh 1+ pick2 16 *>> 'ym ! 1+ 16 *>> 'xm !
	ab[ fillfull fillvertr ]ba 
	SDLrenderer r> 'vert 4 'index 6 
	SDL_RenderGeometry ;

|----------------------	
::ssload | w h "file" -- ssprite
	loadimg
	dup SDLTexwh 'dy ! 'dx !
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
	
::ssprite | x y n ssprite --
	ab[
	dup sspritewh 1+ 2/ 'ym ! 1+ 2/ 'xm !
	settile >r fillvertxy
	SDLrenderer r> @ 'vert 4 'index 6 
	SDL_RenderGeometry 
	]ba ;

::sspriter | x y ang n ssprite --
	ab[
	dup sspritewh 'ym ! 'xm !
	settile >r fillvertr
	SDLrenderer r> @ 'vert 4 'index 6 
	SDL_RenderGeometry 
	]ba ;

::sspritez | x y zoom n ssprite --
	ab[
	rot over sspritewh 1+ pick2 17 *>> 'ym ! 1+ 17 *>> 'xm ! | /2
	settile >r fillvertxy
	SDLrenderer r> @ 'vert 4 'index 6 
	SDL_RenderGeometry 
	]ba ;
	
::sspriterz | x y ang zoom n ssprite --
	ab[	
	rot over sspritewh 1+ pick2 16 *>> 'ym ! 1+ 16 *>> 'xm !
	settile >r fillvertr
	SDLrenderer r> @ 'vert 4 'index 6 
	SDL_RenderGeometry 
	]ba ;
	
::createSurf | w h -- surface
	0 -rot 32 
	$ff0000 $ff00 $ff $ff000000  | ARGB
	SDL_CreateRGBSurface ;
	
::Surf>pix | surface -- surf pixels
	dup 32 + @ ;	

::Surf>wha
	dup 16 + ;

::Surf>wh | surface -- surf w h
	dup 16 + d@+ swap d@ ;

::Surf>pixpi | surface -- 'pixel pitch
	dup 32 + @ swap 24 + d@ ;

|------ compose texture
#comptex
	
::texIni | w h --	
| $16362004 |ARGB
	>r >r SDLrenderer $16462004 2 r> r> SDL_CreateTexture 
	dup 'comptex !
	SDLrenderer swap SDL_SetRenderTarget ;
	
::texEnd | -- texture
	SDLrenderer 0 SDL_SetRenderTarget
	comptex	;
	
::texEndAlpha | -- texture
	texEnd
	dup 1 SDL_SetTextureBlendMode ;
	
::tex2static | tex -- newtexture
	dup 'xm 'ym 'dx 'dy SDL_QueryTexture | xm=format 
	0 dx dy 0 xm SDL_CreateRGBSurfaceWithFormat 
	SDLrenderer pick2 SDL_SetRenderTarget
	SDLrenderer 0 xm pick3 Surf>pixpi SDL_RenderReadPixels
	SDLrenderer 0 SDL_SetRenderTarget	
	SDLrenderer over SDL_CreateTexturefromSurface | new texture
	-rot SDL_FreeSurface SDL_destroytexture ;
			
|.... time control
#prevt
#deltatime

::timer< msec 'prevt ! 0 'deltatime ! ; 			| reset timer
::timer. msec dup prevt - 'deltatime ! 'prevt ! ;	| adv timer
::timer+ deltatime + ; 								| add timer
| $ffffffff7fffffff and  ; 	| for ring counter
::timer- deltatime - ; 								| sub timer

|.... animation
| fff ff fff ........
| inicio(12) cnt(8) escala(12) time(32) (49 dias)
|                      
::ICS>anim | init cnt scale -- val
	32 << swap 44 << or swap 52 << or ;
	
::vICS>anim | v init cnt scale -- val
	ICS>anim swap $ffffffff and or ;
	
::anim>n | ani -- t
	dup |$ffffffff and
	dup 32 >> $fff and * $ffff and
	over 44 >> $ff and 16 *>>
	swap 52 >>> +
	;

::anim>c | ani -- c
	dup |$ffffffff and
	dup 32 >> $fff and * $ffff and
	swap 44 >> $ff and 16 *>>
	;
	
::anim>stop | ani -- ani
	$ff00000000000 nand ;
	
: fillfull ;
