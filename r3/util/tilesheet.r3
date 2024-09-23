| TileSheet Library
| PHREDA 2021
^r3/lib/mem.r3
^r3/lib/math.r3
^r3/lib/sdl2image.r3
^r3/lib/sdl2gfx.r3	

|--------------------------------
#mapm #mapt
#mapw #maph 
#mapx #mapy
#tilew #tileh
#xm #ym		

:map> | x y -- a
	mapw * + mapm + ;

::[map] | x y -- ad
	maph 1 - clamp0max swap
	mapw 1 - clamp0max swap
	map> ;
	
:[map]@ | x y -- v
	[map] c@ $ff and ;

::drawtile | y x tile -- y x 
	| 0? ( drop ; ) 
	mapt
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

::tiledrawv | w h x y sx sy 'amap 'vec --
	>r
	@+ 'mapt !
	d@+ 'mapw ! d@+ 'maph !
	d@+ 'tilew ! d@+ 'tileh !
	'mapm ! 
	'ym ! 'xm !
	'mapy ! 'mapx !
	0 ( over <? 
		0 ( pick3 <?
			mapx over + mapy [map]@ | y x tile
			r@ ex 					| tile->tile
			mapt pick2 tilew * xm + ym tsdraw
			1 + ) drop
		tileh 'ym +!
		1 'mapy +!
		1 + ) drop | w h
	neg dup 'mapy +!	
	tileh * 'ym +!
	r> 2drop
	;

::drawtile | y x tile -- y x 
	|0? ( drop ; ) 
	mapt
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
	
::tiledrawvs | w h x y sx sy sw sh 'amap 'v --
	>r
	@+ 'mapt !
	d@+ 'mapw ! d@+ 'maph !
	8 + 'mapm ! 
	'tileh ! 'tilew !
	'ym ! 'xm !
	'mapy ! 'mapx !
	0 ( over <? 
		0 ( pick3 <?
			mapx over + mapy [map]@
			r@ ex	| tile->tile
			mapt pick2 tilew * xm + ym tilew tileh tsdraws
			1 + ) drop
		tileh 'ym +!
		1 'mapy +!
		1 + ) drop | w h
	neg dup 'mapy +!	
	tileh * 'ym +!
	r> 2drop
	;	
		
::scr2view | xs ys -- xv yv
	ym - tilew / mapy +
	maph 1 - clamp0max 
	swap
	xm - tileh / mapx +
	mapw 1 - clamp0max 
	swap ;
		
::scr2tile | x y -- adr : only after tilemapdraw (set the vars)
	scr2view map> ;
	
::loadtilemap | "" -- amap
	here dup rot load 'here !
	dup dup
	8 +
	d@+ 'mapw ! d@+ 'maph !
	d@+ 'tilew ! d@+ 'tileh !
	mapw maph * +  | image tilesa
	tilew tileh rot tsload over !
	;