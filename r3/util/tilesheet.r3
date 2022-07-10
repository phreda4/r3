| TileSheet Library
| PHREDA 2021
^r3/lib/mem.r3
^r3/lib/math.r3
^r3/win/sdl2image.r3
	
#w #h

::loadts | w h filename -- ts
	loadimg
	dup 0 0 'w 'h SDL_QueryTexture
	here >a
	a!+ | texture
	2dup swap da!+ da!+ | w h 
	0 ( h <? 
		0 ( w <? | w h y x
			2dup da!+ da!+
			pick3 + ) drop 
		over + ) drop
	2drop 
	here a> 'here ! 
	;

::loadtsb | w h filename -- ts ; with 1 space
	loadimg
	dup 0 0 'w 'h SDL_QueryTexture
	here >a
	a!+ | texture
	2dup swap da!+ da!+ | w h 
	0 ( h <? 
		0 ( w <? | w h y x
			2dup da!+ da!+
			pick3 + 
			1 + ) drop 
		over + 
		1 + ) drop
	2drop 
	here a> 'here ! 
	;

::freets | ts --
	@ SDL_DestroyTexture 
	empty ;
	
#rdes [ 0 0 0 0 ]
#rsrc [ 0 0 0 0 ]

::tsdraw | n 'ts x y --
	swap 'rdes d!+ d!
	dup 8 + @ dup 'rdes 8 + ! 'rsrc 8 + !
	SDLrenderer 	| n 'ts ren
	rot rot @+		| ren n 'ts texture
	rot 3 << rot 8 + + 
	@ 'rsrc ! | ren txture rsrc
	'rsrc 'rdes 
	SDL_RenderCopy
	;

::tsdraws | n 'ts x y w h --
	swap 2swap swap 'rdes d!+ d!+ d!+ d!
	dup 8 + @ 'rsrc 8 + !
	SDLrenderer 	| n 'ts ren
	rot rot @+		| ren n 'ts texture
	rot 3 << rot 8 + + 
	@ 'rsrc ! | ren txture rsrc
	'rsrc 'rdes 
	SDL_RenderCopy
	;

|--------------------------------
#mapm #mapt
#mapw #maph 
#mapx #mapy
#tilew #tileh
#xm #ym		

:map> | x y -- a
	mapw * + mapm + ;
	
:[map]@ | x y -- v
	mapw 1 - clamp0max swap
	maph 1 - clamp0max swap
	map> c@ ;

::drawtile | y x tile -- y x 
	0? ( drop ; ) mapt
	pick2 tilew * xm + ym
	tsdraw ;

::tiledraw | w h x y sx sy 'amap --
	@+ 'mapt !
	d@+ 'mapw ! d@+ 'maph !
	d@+ 'tilew ! d@+ 'tileh !
	'mapm ! 
	'ym ! 'xm !
	'mapy ! 'mapx !
	0 ( over <? 
		0 ( pick3 <?
			mapx over + mapy [map]@
			drawtile
			1 + ) drop
		tileh 'ym +!
		1 'mapy +!
		1 + ) drop | w h
	neg dup 'mapy +!	
	tileh * 'ym +!
	drop
	;

::drawtile | y x tile -- y x 
	0? ( drop ; ) mapt
	pick2 tilew * xm + ym
	tilew tileh
	tsdraws ;
	
::tiledraws | w h x y sx sy sw sh 'amap --
	@+ 'mapt !
	d@+ 'mapw ! d@+ 'maph !
	8 + 'mapm ! 
	'tileh ! 'tilew !
	'ym ! 'xm !
	'mapy ! 'mapx !
	0 ( over <? 
		0 ( pick3 <?
			mapx over + mapy [map]@
			drawtile
			1 + ) drop
		tileh 'ym +!
		1 'mapy +!
		1 + ) drop | w h
	neg dup 'mapy +!	
	tileh * 'ym +!
	drop
	;
		
::scr2tile | x y -- adr : only after tilemapdraw (set the vars)
	ym - tilew / mapy +
	maph 1 - clamp0max 
	swap
	xm - tileh / mapx +
	mapw 1 - clamp0max 
	swap
	map> ;
	
::loadtilemap | "" -- amap
	here dup rot load 'here !
	dup dup
	8 +
	d@+ 'mapw ! d@+ 'maph !
	d@+ 'tilew ! d@+ 'tileh !
	mapw maph * +  | image tilesa
	tilew tileh rot loadts over !
	;