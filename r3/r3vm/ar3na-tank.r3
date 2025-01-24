| ar3na : tank ;
| PHREDA 2025
|-------------------------
^r3/util/sdlgui.r3
^r3/util/sdledit.r3
^r3/util/sdlbgui.r3
^r3/util/varanim.r3

^./arena-war.r3

#codepath "r3/r3vm/codetank/"

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

|------------


|-------------------
:showeditor
	$7f00007f sdlcolorA	| cursor
	edfill
	$ffffff sdlcolor
	edfocus 		
	edcodedraw
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
	8 532 bat
	" " bprint2
	vmdeep 0? ( drop ; ) 
	stack 8 +
	( swap 1 - 1? swap
		@+ "%d " bprint2 
		) 2drop 
	TOS "%d " bprint2
	;
	
:showinput
	$7f00007f sdlcolorA	| cursor
	0 500 1024 600 SDLfRect

	0 502 bat ":" bprint2
	16 500 immat 1000 32 immbox
	'pad 128 immInputLine2	
	
	$ffffff sdlcolor
	sdlkey
	<ret> =? ( immex )
	<esp> =? ( immex )	
	drop	
	;		

#modo 'showinput
		
#modos 'showinput 'showeditor
#modon 0

:changemodo
	1 'modon +!
	'modos modon $1 and 3 << + @ 'modo !
	;
	
|-------------------
:runscr
	vupdate
	immgui
	mouse
	timer.
	0 sdlcls
	
	|terreno
	|viewmap
	
	$ffff bcolor 8 8 bat "Code Tank" bprint2 bcr2
	|$ffffff bcolor viewpz viewpy viewpx "%d %d %f" bprint2

	war.draw
	
	modo ex
|	showeditor
|	showinput
	
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
	<f1> =? ( changemodo )
	<f2> =? ( war.+rtank )
	drop ;

	
|-------------------
: |<<< BOOT <<<
	"r3 robots" 1024 600 SDLinit
	SDLblend
	64 vaini
	
	bfont1
	
| editor
	1 4 40 24 edwin
	edram
	
	|"media/ttf/roboto-bold.ttf" 20 TTF_OpenFont immSDL
	war.ini
	war.reset
	fillmap
	
	'runscr SDLshow
	SDLquit 
	;
