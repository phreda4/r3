| ar3na tank 
| PHREDA 2025
|-------------------------
^r3/lib/gui.r3
^r3/util/varanim.r3
^r3/util/ttext.r3

^./arena-war.r3

^./tedit.r3
^./rcodevm.r3

#codepath "r3/r3vm/codetank/"

#map * $ffff | 256x256
#mapcx 128 #mapcy 128
#maptx 32 #mapty 32

#mapsx	512 #mapsy 300

|---------
:btnt | x y v "" col --
	pick4 pick4 128 24 guiBox
	[ dup 2* or ; ] guiI sdlcolor
	[ 2swap 2 + swap 2 + swap 2swap ; ] guiI
	2over 128 24 sdlfrect
	2swap 4 + swap 4 + swap tat
	$e tcol temits	
	onClick ;

:btnt2 | x y v "" col --
	pick4 pick4 256 48 guiBox
	[ dup 2* or ; ] guiI sdlcolor
	[ 2swap 2 + swap 2 + swap 2swap ; ] guiI
	2over 256 48 sdlfrect
	2swap 8 + swap 8 + swap tat
	$e tcol temits	
	onClick ;
	
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
	0.1 * viewpz +
	0.2 max 6.0 min 'viewpz !
	;
	

:fillmap
	'map >a $ffff ( 1? 1- rand8 4 >> ca!+ ) drop ;

:xymap | x y -- adr
	$ff and 8 << 
	swap $ff and or 
	'map + ;
	
	
|:drawmap | arr -- arr
|	a@+ viewpz *. int. viewpx + 
|	a@+ viewpz *. int. viewpy +	| x y
|	zoomm viewpz *. | zoom	 
|	a@+ sspritez
|	;
	
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
#lerror

:immex	
|	r3reset
|	'pad r3i2token drop 'lerror !
	0 'pad !
	refreshfoco
|	code> ( icode> <? 
	| vmcheck
|		vmstep ) drop
	;
	
:showstack
	8 532 tat
	" " tprint
	vmdeep 0? ( drop ; ) 
	stack 8 +
	( swap 1 - 1? swap
		@+ "%d " tprint
		) 2drop 
	TOS "%d " tprint
	;
	
:showinput
	$7f00007f sdlcolorA	| cursor
	0 500 1024 600 SDLfRect
	$ff0000 trgb
	0 502 tat ":" tprint
|	16 500 immat 1000 32 immbox
|	'pad 128 immInputLine2	
	;		


|-------------------
:runscr
	vupdate
	gui
	mouse
	0 sdlcls
	
	|terreno
	|viewmap
	
	$ffff trgb 8 8 tat "Ar3na Tank" tprint
	|$ffffff bcolor viewpz viewpy viewpx "%d %d %f" bprint2

	war.draw
	
	showinput
	
	sdlredraw
	sdlkey
	>esc< =? ( exit )
	<ret> =? ( immex )
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

	<f2> =? ( war.+rtank )
	drop ;

	
|-------------------
: |<<< BOOT <<<
	"arena tank" 1024 600 SDLinit
	SDLblend
	64 vaini
	
	|"media/ttf/roboto-bold.ttf" 20 TTF_OpenFont immSDL
	war.ini
	war.reset
	fillmap
	
	'runscr SDLshow
	SDLquit 
	;
