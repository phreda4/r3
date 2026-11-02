| bmap mapa de mosaicos con capas
| PHREDA
|------------------
^r3/lib/rand.r3
^r3/lib/console.r3
^r3/lib/sdl2gfx.r3
^r3/util/arr16.r3

|----
#mapgame
#mapw #maph		| size map
#mapx #mapy		| ini screen
#maptw #mapth	| tile size
#mapsx #mapsy	| size screen
#mapsw #mapsh	| size screen

#tileset
#tilew #tileh	| tile size in file
#tsimg
#tsmap

#boxsrc [ 0 0 0 0 ]
#boxdst [ 0 0 0 0 ]

:defsprite | x y n --
	3drop ; | nota draw
	
##bsprdraw 'defsprite | word that drawmaps calls for each sprite of the list: x y n --  (the default one does nothing)

|------------ order inscreen render
#sprinscr 
#sprinscr> 
#sprinscr<

::inisprite | -- ; start the list of sprites drawn in order with the map rows (call it every frame before +sprite); the list is in free memory at here
	here 1 63 << dup rot !+ !+
	dup 'sprinscr !
	dup 'sprinscr> !
	'sprinscr< !
	;
	
::+sprite | N x y -- ; add the sprite N at screen position x y to the sorted list; it is ignored if it is outside the screen
	mapth neg <? ( 3drop ; ) sh mapth + >? ( 3drop ; ) 32 << 
	swap -32 <? ( 3drop ; ) sw 32 + >? ( 3drop ; )
	$ffffffff and or | compress
	sprinscr>
	( 16 - dup @ 						| adr yx adr' yx'
		pick2 >? 
		over 8 + @ swap
		pick2 16 + !+ !
		) drop
	16 + !+ ! | store 128bits
	16 'sprinscr> +! 
	;


:drawobj | ylim a vyx -- ylim 'a
	dup 32 << 32 >> | x
	swap 32 >>		| adr x y
	pick2 @			| tilenro
	bsprdraw ex
|sprplayer ssprite | x y n ssprite --
	8 +
	;

:drawlineobj | y -- y
	dup mapth * mapy + | y limit
	32 << | in high
	sprinscr< ( @+ 1? pick2 <? drawobj ) drop 
	8 - 'sprinscr< !
	drop
	;

|------ DRAW MAP
:map> | tx ty -- adr
	mapw * + 3 << mapgame + ;

:layer | ts n -- 
	$fff and 0? ( drop ; )
	3 << tsmap + @ 'boxsrc ! | texture 'ts n  r
	SDLrenderer tsimg 'boxsrc 'boxdst SDL_RenderCopy ;

:setxy | y x --	y x
	over mapth * mapy + 32 << 
	over maptw * mapx + $ffffffff and or
	'boxdst ! ;
	
:drawtile1 | y x -- y x
	mapsx over + -? ( drop ; ) mapw >=? ( drop ; )
	mapsy pick3 + -? ( 2drop ; ) maph >=? ( 2drop ; ) 
	map> @ 
	dup layer | back
	12 >> layer | back2
	;

| capa de arriba
:drawup | y x -- y x
	2dup ( swap 1 - swap
		setxy 
		mapsx over + 
		mapsy pick3 + -? ( 4drop ; )
		map> @ $2000000000000 and?
		dup 24 >> layer | Front
		36 >> layer | Front2
		) 3drop ;

#cond 
:tiledcond | tile
	$4000000000000 and? ( cond 24 + >> layer ; ) | Front/2
	dup 24 >> layer | Front
	36 >> layer | Front2
	;
	
:cdrawup | y x -- y x
	2dup ( swap 1 - swap
		setxy 
		mapsx over + 
		mapsy pick3 + -? ( 4drop ; )
		map> @ 
		$2000000000000 and?
		tiledcond
		) 3drop ;
	
:cdrawtile2
	0 'cond !
	$8000000000000 and? ( 12 >> 12 'cond ! )
	24 >> layer | Front
	cdrawup
	;
	
:cerasemap
	mapgame >a
	mapw maph * ( 1? 1 -
		a@ $7ffffffffffff and a!+
		) drop ;
	
:drawtile2 | y x -- y x 
	mapsx over + -? ( drop ; ) mapw >=? ( drop ; )
	mapsy pick3 + -? ( 2drop ; ) maph >=? ( 2drop ; ) 
	map> @ 
	$2000000000000 and? ( drop ; ) | nodibujar
	$4000000000000 and? ( cdrawtile2 ; ) | condicional
	dup 24 >> layer | Front
	36 >> layer | Front2
	drawup 
	;

:drawtilelast | y x -- y x  ; dibujar los que falta
	mapsx over + -? ( drop ; ) mapw >=? ( drop ; )
	mapsy pick3 + -? ( 2drop ; ) maph >=? ( 2drop ; ) 
	map> @ 
	$2000000000000 nand? ( drop ; ) | 
	$4000000000000 and? ( cdrawtile2 ; )
	dup 24 >> layer | Front
	36 >> layer | Front2
	;
	
|------------------------- 32x32 pixel
::drawmaps | xvp yvp -- ; draw the map with its sprites from the viewport position xvp yvp in pixels (tiles of 32x32): back layers, then the sprites row by row, then the front layers
	dup $1f and neg 'mapy ! 5 >> 'mapsy ! 
	dup $1f and neg 'mapx ! 5 >> 'mapsx !
	0 sprinscr> !
	0 ( mapsh <? 
		0 ( mapsw <? 
			setxy drawtile1 
			1 + ) drop
		drawlineobj | antes de dibujar la linea dibujo los sprite que estan arriba
		0 ( mapsw <?
			setxy drawtile2
			1 + ) drop
		1 + ) 1 - 
		0 ( mapsw <?
			setxy drawtilelast
			1 + ) 2drop		
	cerasemap ;

|------ LOAD MAP
::loadmap | "filename" -- ; load a map file (8 bytes header, mapw maph, mapw*maph cells of 64 bits, tilew tileh, tileset image name) and its tileset; the view is 34x23 tiles of 32 pixels
	here dup rot load | inimem endmem
	over =? ( 2drop ; ) 'here !
	8 +
	d@+ 'mapw ! d@+ 'maph !
	dup 'mapgame !
	mapw maph * 3 << +					| map size
	d@+ 'tilew ! d@+ 'tileh !
	| muchos mapas, 1 tileset?
	tilew tileh rot tsload 'tileset !	| tileset
	32 'maptw ! 32 'mapth ! 
	maptw mapth 32 << or 'boxdst 8 + !	| size dst
	tilew tileh 32 << or 'boxsrc 8 + ! 	| size src w h 
	tileset @+ 'tsimg ! 8 + 'tsmap !
	34 'mapsw ! 23 'mapsh !	| conf?
	;

::bmap2xy | x y -- x y ; tile position x y to the pixel position in the tileset size (x*tilew, y*tileh) as fixed point
	swap tilew * fix. swap tileh * fix. ;
::whbmap | -- w h ; size of the map in tiles
	mapw maph ;
	
::xyinmap@ | x y -- cell ; map cell (64 bits) at the position x y given as fixed point pixels (no range check)
	16 >> mapth / swap 16 >> maptw / swap map> @ ;
	
:poketrigger | adr --
	dup @ $4000000000000 nand? ( 2drop ; ) 
	$8000000000000 or swap ! ;
	
::xytrigger | x y -- x y ; mark with the trigger flag (bit 51) the conditional tiles (bit 50) of the cells around x y; drawmaps clears the flag at the end of the frame
	over 32 - maptw / over 32 + mapth / map>
	dup poketrigger 
	8 + poketrigger ;
	