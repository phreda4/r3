| arena war test
| PHREDA 2024
|-------------------------
^r3/util/sdlgui.r3
^r3/r3vm/arena-war.r3

#map * $ffff | 256x256
#mapcx 128 #mapcy 128
#maptx 32 #mapty 32

#mapsx	512 #mapsy 300

|-------------------
#xo #yo

:dns
	sdlx 'xo ! sdly 'yo ! ;

:mos
	sdlx xo - 'viewpx +! 
	sdly yo - 'viewpy +! 
	dns ;

:mouse
	'dns 'mos onDnMove 
	SDLw 0? ( drop ; )
	0.2 * viewpz +
	0.5 max 5.0 min 'viewpz !
	;
	

:fillmap
	'map >a $ffff ( 1? 1- rand8 4 >> ca!+ ) drop ;

:xymap | x y -- adr
	$ff and 8 << 
	swap $ff and or 
	'map + ;
	
:map2pos
	;
	
:viewmap |
	-6 ( 5 <? 1+
		-6 ( 5 <? 1+
			over 32 * mapsx + 
			over 32 * mapsy + 
		
			pick2 mapcx +
			pick2 mapcy + | rx ry
			xymap c@
			
			imgspr sspriterz
			) drop
		) drop			
	;
	
:terreno
	12343 'seed8 !
	16 ( sw <?
		16 ( sh <?
			
			2dup 2.0 
			rand8 4 >> $3 and 21 + imgspr sspritez
		32 + ) drop
	32 + ) drop	
	;
	
|-------------------
:runscr
	immgui
	mouse
	timer.
	0 sdlcls
	
	|terreno
	|viewmap
	
	$ffff bcolor 8 8 bat "Arena War" bprint2 bcr2
	$ffffff bcolor viewpz viewpy viewpx "%d %d %f" bprint2

	war.draw
	
	sdlredraw
	sdlkey
	>esc< =? ( exit )
	| ---- player control	
	<up> =? ( btnpad %1000 or 'btnpad ! )
	<dn> =? ( btnpad %100 or 'btnpad ! )
	<le> =? ( btnpad %10 or 'btnpad ! )
	<ri> =? ( btnpad %1 or 'btnpad ! )
	>up< =? ( btnpad %1000 nand 'btnpad ! )
	>dn< =? ( btnpad %100 nand 'btnpad ! )
	>le< =? ( btnpad %10 nand 'btnpad ! )
	>ri< =? ( btnpad %1 nand 'btnpad ! )
	<esp> =? ( btnpad $10 or 'btnpad ! )
	
	|----
	
	<f1> =? ( war.+rtank )
	drop ;

	
|-------------------
: |<<< BOOT <<<
	"r3 robots" 1024 600 SDLinit
	bfont1
	
	"media/ttf/roboto-bold.ttf" 20 TTF_OpenFont immSDL
	war.ini
	war.reset
	fillmap
	
	'runscr SDLshow
	SDLquit 
	;
