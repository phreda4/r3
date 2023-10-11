| DICIEMBRE - JUEGO ITINERARIO 2023
|
|------------------
^r3/win/console.r3
^r3/win/sdl2gfx.r3
^r3/util/sdlgui.r3
^r3/util/arr16.r3
^r3/lib/rand.r3

|----
#sprplayer
#mapa1

#btnpad
#xvp #yvp		| viewport
#xvpd #yvpd		| viewport dest
#obj 0 0

|----
#mapgame
#mapw #maph 	| size map
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

|------------ order inscreen render
#sprinscr 
#sprinscr> 
#sprinscr<

:inisprite
	here 1 63 << dup rot !+ !+ 
	dup 'sprinscr ! 
	dup 'sprinscr> ! 
	'sprinscr< ! 
	;
	
:+sprite | N x y --
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
	
	2.0 			| zoom 2.0
	pick3 @			| tilenro
	sprplayer sspritez | x y n ssprite --
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
	
|-------------------------	
:drawmaps | --
	0 sprinscr> !
	xvp $1f and neg 'mapx !
	yvp $1f and neg 'mapy !
	xvp 5 >> 'mapsx !
	yvp 5 >> 'mapsy !
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
:loadmap | filename -- 
	here dup rot load | inimem endmem
	over =? ( 2drop 0 ; ) 'here !
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
	34 'mapsw ! 22 'mapsh !	
	;
	
|------ PLAYER
:teclado
	SDLkey 
	>esc< =? ( exit )
	<up> =? ( btnpad %1000 or 'btnpad ! )
	<dn> =? ( btnpad %100 or 'btnpad ! )
	<le> =? ( btnpad %10 or 'btnpad ! )
	<ri> =? ( btnpad %1 or 'btnpad ! )
	>up< =? ( btnpad %1000 not and 'btnpad ! )
	>dn< =? ( btnpad %100 not and 'btnpad ! )
	>le< =? ( btnpad %10 not and 'btnpad ! )
	>ri< =? ( btnpad %1 not and 'btnpad ! )	
	
|	<f1> =? ( sprinscr ( sprinscr> <? @+ "%h " .print @+ "%h" .println ) drop .cr )
|	<f2> =? ( 1 0 500 randmax +sprite )
	drop 
	;

|---------------------
#persona1 (  0  1  0  2  3  4  3  5  6  7  6  8  9 10  9 11 )
#persona2 ( 12 13 12 14 15 16 15 17 18 19 18 20 21 22 21 23 )
#persona3 ( 24 25 24 26 27 28 27 29 30 31 30 32 33 34 33 35 )
#persona4 ( 36 37 36 38 39 40 39 41 42 43 42 44 45 46 45 47 )

:sumax | adv -- tilew
	0? ( ; ) -? ( drop -20 ; ) drop 16 ;

:xyinmap@ | x y
	16 >> 32 + mapth / swap 
	16 >> maptw / swap 
	map> @ ;
	
:xymove | dx dy --
	a> @ pick2 + 16 >> pick2 sumax + | costados
	maptw / 
	a> 8 + @ pick2 + 16 >> 32 + | piso
	mapth /
	map> @ $1000000000000 and? ( 3drop ; ) 
	
	drop
	a> 8 + +!
	a> +!
	;
	
:poketrigger | adr --
	dup @ $4000000000000 nand? ( 2drop ; ) 
	$8000000000000 or swap ! ;
	
:xytrigger | x y -- x y 
	over 32 - maptw / over 32 + mapth / map>
	dup poketrigger 
	8 + poketrigger ;
	
:viewpostmove
	xvpd xvp - 5 >> 'xvp +!
	yvpd yvp - 5 >> 'yvp +!
	;
	
:viewportx | x -- x
	dup sw 1 >> - 'xvpd ! ;
	
:viewporty | y -- y
	dup sh 1 >> - 'yvpd ! ;
	
:anim! | 'anim --
	a> 2 3 << + ! ; 
	
:anim@
	a> 2 3 << + @+ 2 << swap @ + ;
	
|  x y anim 
:player	
	>a
	btnpad
	%1000 and? ( 3 anim! 0 -2.0 xymove )
	%100 and? ( 0 anim! 0 2.0 xymove  )
	%10 and? ( 1 anim! -2.0 0.0 xymove )
	%1 and? ( 2 anim! 2.0 0.0 xymove )
	1? ( msec 7 >> $3 and nip ) anim@ + c@
	a@+ int. a@+ int. 
	xytrigger
	swap viewportx xvp -
	swap viewporty yvp -
	+sprite | a x y --
	;	

:+jugador | 'per x y --
	'player 'obj p!+ >a
	swap a!+ a!+
	0 a!+ a!+ 
	;	

|---------------------

#randmove ( %0000 %0001 %0010 %0100 %0101 %0110 %1000 %1001 %1010 )

:randir
	40 randmax 1? ( drop ; ) drop
	9 randmax 'randmove + c@
	a> 4 3 << + !
	;
	
:npc
	>a
	randir
	a> 4 3 << + @
	%1000 and? ( 3 anim! 0 -2.0 xymove )
	%100 and? ( 0 anim! 0 2.0 xymove  )
	%10 and? ( 1 anim! -2.0 0.0 xymove )
	%1 and? ( 2 anim! 2.0 0.0 xymove )
	1? ( msec 7 >> $3 and nip ) anim@ + c@
	a@+ int. a@+ int.
	xytrigger
	swap xvp -
	swap yvp -
	+sprite	| a x y
	;	

:+npc | 'dib x y --
	'npc 'obj p!+ >a
	swap a!+ a!+
	0 a!+ a!+ 0 a!+
	;	

|-----------------------------------
:cosa
	>a
	a> 2 3 << + @
	a@+ int. xvp -
	a@+ int. yvp -
	+sprite	| a x y
	;	

:+cosa | ndib x y --
	'cosa 'obj p!+ >a
	swap a!+ a!+
	a!+ 
	;	

	
|----- JUGAR
:jugar
	0 SDLcls
	immgui		| ini IMMGUI	

	inisprite
	'obj p.draw
	drawmaps
	viewpostmove

	SDLredraw
	teclado
	;
	
:reset
	'obj p.clear
	;
		
:randnpc
	4 randmax 4 << 'persona1 +
	( 	2800.0 randmax 32.0 + 
		1200.0 randmax 64.0 +
		2dup xyinmap@ $1000000000000 and? 
		3drop ) drop
	+npc
	;
	
:randcosa	
	48
	( 	2800.0 randmax 32.0 + 
		1200.0 randmax 64.0 +
		2dup xyinmap@ $1000000000000 and? 
		3drop ) drop
	+cosa
	;
	
:juego
	inisprite
	reset
	'persona1 130.0 300.0 +jugador
	200 ( 1? 1 - randnpc ) drop
	10 ( 1? 1 - randcosa ) drop
	'jugar SDLshow
	;	

:main
	"r3sdl" 1024 600 SDLinit
	"media/ttf/Roboto-Medium.ttf" 12 TTF_OpenFont immSDL
	"r3/itinerario/diciembre/escuela1.bmap" loadmap 'mapa1 !
	32 32 "r3/itinerario/diciembre/protagonista.png" ssload 'sprplayer !
	1000 'obj p.ini
	juego
	SDLquit
	;
	
: main ;