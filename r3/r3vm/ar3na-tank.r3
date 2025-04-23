| ar3na tank 
| PHREDA 2025
|-------------------------
^r3/lib/gui.r3
^r3/util/varanim.r3
^r3/util/ttext.r3

^./arena-war.r3
^./arena-edit.r3

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


#serror
#code1
#cpu1
	
|-----------------------
:compilar
	empty mark 
	fuente vmcompile | serror terror
	
|	vmdicc | ** DEBUG
|	cdcnt 'cdtok vmcheckjmp

	 1 >? ( 'terror !
		'fuente> ! | serror
		3 'state !
		clearmark
		fuente> $700ffff addsrcmark 
		0 'cpu1 !
		; ) 2drop

	2 'state ! 
	vmcpu 'cpu1 !
	0 'terror !
	buildvars
	;

:play
	state 2 =? ( drop vareset ; ) drop
	compilar
	state 2 <>? ( drop ; ) drop
	ip vm2src 'fuente> ! 
|	reset.map
	'stepvma 0.1 +vexe
	;	
	
:step
	state 2 =? ( drop stepvmas ; ) drop | stop?
	compilar	
	ip vm2src 'fuente> ! 
|	reset.map
	;
	
:help
	;
	
|--
:playercontrol
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

	;
	
|-------------------
:runscr
	vupdate gui	0 sdlcls
	
	mouse
	
	|terreno
	|viewmap
	
	0 0 tat $5 tcol "Ar3na" temits $3 tcol "Code" temits 
	|$ffffff bcolor viewpz viewpy viewpx "%d %d %f" bprint2

	war.draw

	draw.code	

	sdlredraw
	sdlkey
	>esc< =? ( exit )

	|----
	<f1> =? ( play )
	<f2> =? ( step ) 
	
	<f5> =? ( war.+rtank )
	drop ;

:game
	mark
	0 32 440 540 edwin	
	
|	"r3/r3vm/levels/level0.txt" loadlevel	
|	0.4 %w 0.24 %h 0.58 %w 0.74 %h mapwin
		
|	reset.map
	1 'state ! 0 'code1 ! 0 'cpu1 !

	|"-- go --" infoshow
	mark
	'runscr SDLshow
	empty
	
	vareset
	empty
	
	;
	

|-------------------------------------
:menu
	vupdate gui 0 sdlcls
	
	|$7f3f3f3f sdlcolorA	200 200 200 600 sdlFRect
	
	6.0 tsize
	12 4 tat $5 tcol "Ar3na" temits $3 tcol "Tank" temits tcr
	
	3.0 tsize	
|	32 100 'tutor1 "Tutorial"  $3f00 btnt2
	32 200 'game "Game"  $3f00 btnt2
|	32 300 'freeplay "Free Play"  $3f00 btnt2
|	32 500 'options "Options" $3f btnt2
	32 600 'exit "Exit" $3f0000 btnt2
	
	sdlredraw
	sdlkey
	>esc< =? ( exit )
	<f1> =? ( game )
	|<f2> =? ( options ) 
	drop ;
	
|-------------------
: |<<< BOOT <<<
	"arena tank" 1024 600 SDLinit
	SDLblend
	2.0 8 8 "media/img/atascii.png" tfnt 
	64 vaini
	edram	| editor
	|"media/ttf/roboto-bold.ttf" 20 TTF_OpenFont immSDL
	war.ini
	war.reset
	fillmap
	
	|'menu sdlshow
	game
		
	SDLquit 
	;
