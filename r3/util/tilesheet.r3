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

::[map] | x y -- ad ; address of the map tile x y (x and y are limited to the map)
	maph 1 - clamp0max swap
	mapw 1 - clamp0max swap
	map> ;
	
:[map]@ | x y -- v
	[map] c@ $ff and ;

::drawtile | y x tile -- y x ; draw the tile at the cell x y of the window being drawn (defined twice: the first draws it at its own size, the second, the one that programs get when they import the library, scaled to sw x sh)
	| 0? ( drop ; ) 
	mapt
	pick2 tilew * xm + ym
	tsdraw ;

::tiledraw | w h x y sx sy 'amap -- ; draw a window of w x h tiles of the map starting at the tile x y, at the screen position sx sy
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

::tiledrawv | w h x y sx sy 'amap 'vec -- ; like tiledraw but 'vec transforms every tile number (tile -- tile)
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

::drawtile | y x tile -- y x ; draw the tile at the cell x y of the window being drawn (defined twice: the first draws it at its own size, the second, the one that programs get when they import the library, scaled to sw x sh)
	|0? ( drop ; ) 
	mapt
	pick2 tilew * xm + ym
	tilew tileh
	tsdraws ;
	
::tiledraws | w h x y sx sy sw sh 'amap -- ; like tiledraw with every tile scaled to sw x sh pixels
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
	
::tiledrawvs | w h x y sx sy sw sh 'amap 'v -- ; like tiledraws with 'v transforming every tile number
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
		
::scr2view | xs ys -- xv yv ; screen position to tile position of the last window drawn
	ym - tilew / mapy +
	maph 1 - clamp0max 
	swap
	xm - tileh / mapx +
	mapw 1 - clamp0max 
	swap ;
		
::scr2tile | x y -- adr ; address of the map tile under the screen position x y (only after a tiledraw: it uses its variables)
	scr2view map> ;
	
::loadtilemap | "file" -- amap ; load a tile map (map width and height, tile width and height, the tiles as bytes and then the name of the tileset image); the tileset is loaded with tsload; returns the address of the map
	here dup rot load 'here !
	dup dup
	8 +
	d@+ 'mapw ! d@+ 'maph !
	d@+ 'tilew ! d@+ 'tileh !
	mapw maph * +  | image tilesa
	tilew tileh rot tsload over !
	;