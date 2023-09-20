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

#btnpad
#np 0

#xvp #yvp		| viewport

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
	mapth neg <? ( 3drop ; ) sh mapth + >? ( 3drop ; )
	32 << swap $ffffffff and or | compress
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

|------ 
#mapcol | 0 0 0 0 0 
#maplink | matrix paint/link ; dibujo/no dibujo/dibuja el de arriba

:paintnor | y x val -- y x val ; dibujo
	pick2 mapsw * pick2 + maplink +
	0 swap c! 
	;
:paintlin | y x val -- y x val
	pick2 mapsw * pick2 + maplink +
	1 swap c!
	;
	
:deferpaint? | y x val -- y x val
	$1000000000000 and? ( | wall
		pick2 pick2 mapcol + c!
		paintnor
		; ) 
	dup 24 >> 0? ( dup pick3 mapcol + c! ) drop
	over mapcol + c@ | link?
	1? ( drop paintlin ; ) drop
	paintnor
	;
	
	
:defermap |y x -- y x
	over mapsw * over + maplink + c@ 13 +
	3 << tsmap + @ 'boxsrc ! | texture 'ts n  r
	SDLrenderer tsimg 'boxsrc 'boxdst SDL_RenderCopy	
	;
	
:deferpaint | y x val --

	;

|------ DRAW MAP
:map> | tx ty -- adr
	mapw * + 3 << mapgame + ;

:layer | ts n -- 
	$fff and 0? ( drop ; )
	3 << tsmap + @ 'boxsrc ! | texture 'ts n  r
	SDLrenderer tsimg 'boxsrc 'boxdst SDL_RenderCopy ;

:setxy | y x --	
	over mapth * mapy + 32 << 
	over maptw * mapx + $ffffffff and or
	'boxdst ! ;
	
:drawtile1 | y x -- y x
	mapsx over + -? ( drop ; ) mapw >=? ( drop ; )
	mapsy pick3 + -? ( 2drop ; ) maph >=? ( 2drop ; ) 
	map> @ 
	deferpaint?
	dup layer | back
	12 >> layer | back2
	
	defermap
	;

:drawtile1s
	mapsh ( 1? 1 - 
		0 ( mapsw <? 
			setxy drawtile1 
			1 + ) 
		drop ) drop ;

| capa de arriba
:drawtile2 | y x -- y x 
	mapsx over + -? ( drop ; ) mapw >=? ( drop ; )
	mapsy pick3 + -? ( 2drop ; ) maph >=? ( 2drop ; ) 
	map> @ 
	dup 24 >> layer | Front
	36 >> layer | Front2
	;
		
:drawtile2s
	0 ( mapsh <? 
		drawlineobj | antes de dibujar la linea dibujo los sprite que estan arriba
		0 ( mapsw <?
			setxy |drawtile2
			1 + ) drop
		1 + ) drop ;
		
|-------------------------

:setxy2 | y x --	
	over mapsy - mapth * mapy + 32 << 
	over mapsx - maptw * mapx + $ffffffff and or
	'boxdst ! ;

:drawtile
	2dup swap map> @ 
	dup layer | back
	dup 12 >> layer | back2
|	mapcollink
	drop
|	dup 24 >> layer | Front
|	36 >> layer | Front2
	|boxdst mlink!
	;
	
:filltiles1
	mapsh mapsy + maph min
	mapsw mapsx + mapw min
	0 mapsy max
	( pick2 <?
		0 mapsx max 
		( pick2 <? | y x --
			setxy2 drawtile
			1 + ) drop 
		1 + ) 3drop ;

:filltiles2
	mapsh ( 1? 1 - 
		drawlineobj | antes de dibujar la linea dibujo los sprite que estan arriba
		0 ( mapsw <? 
			setxy drawtile2
			1 + ) 
		drop ) drop ;

|-------------------------	
:drawmaps | --
	0 sprinscr> !
	|sprinscr ( sprinscr> <? @+ "%h " .print @+ "%h" .println ) drop 
	sprinscr>
	dup 'mapcol !
	dup 0 mapsw cfill
	mapsw +
	dup 'maplink ! | mapsw mapsh *
	0 mapsw mapsh * cfill
	
	xvp $1f and neg 'mapx !
	yvp $1f and neg 'mapy !
	xvp 5 >> 'mapsx !
	yvp 5 >> 'mapsy !
	
	|filltiles1
	drawtile1s
	|filltiles2
	drawtile2s
	;


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
	
	<f1> =? ( sprinscr ( sprinscr> <? @+ "%h " .print @+ "%h" .println ) drop .cr )
	<f2> =? ( 1 0 500 randmax +sprite )
	drop 
	;

|---------------------
#anidn ( 0 1 0 2 )
#anile ( 3 4 3 5 )
#aniri ( 6 7 6 8 )
#aniup ( 9 10 9 11 )
	
#anidn ( 12 13 12 14 )
#anile ( 15 16 15 17 )
#aniri ( 18 19 18 20 )
#aniup ( 21 22 21 23 )

#animplay

:panim | -- nanim	
	msec 7 >> $3 and + c@ ;

:dirv | v --
	-? ( 'anile ; ) 'aniri ;
:xmove
	dirv panim 'np ! a> +! ;
	
:dirh | v --
	-? ( 'aniup ; ) 'anidn ;
:ymove
	dirh panim 'np ! a> 8 + +! ;

:sumax | adv -- tilew
	0? ( ; ) -? ( drop -20 ; ) drop 16 ;
	
:xymove | dx dy --
	a> @ pick2 + 16 >> pick2 sumax + | costados
	maptw / 
	a> 8 + @ pick2 + 16 >> 32 + | piso
	mapth /
	map> @ $1000000000000 and? ( 3drop ; ) drop
	a> 8 + +!
	a> +!
	;
	
:viewportx | x -- x
	dup sw 1 >> - 'xvp ! ;
	
:viewporty | y -- y
	dup sh 1 >> - 'yvp ! ;
	
:player	
	>a
	btnpad
	%1000 and? ( 'aniup 'animplay ! 0 -1.0 xymove 	)
	%100 and? ( 'anidn 'animplay ! 0 1.0 xymove  )
	%10 and? ( 'anile 'animplay ! -1.0 0.0 xymove )
	%1 and? ( 'aniri 'animplay ! 1.0 0.0 xymove )
	drop	
	btnpad 1? ( msec 7 >> $3 and nip ) animplay + c@
|	dup "%d " .print
	a@+ int. viewportx xvp -
	a@+ int. viewporty yvp -
	+sprite | a x y --
	;	

:+jugador | x y --
	'player 'obj p!+ >a
	swap a!+ a!+
	'anidn 'animplay !
	;	

|---------------------
:npc	
	>a
	0
	a@+ int. xvp -
	a@+ int. yvp -
	+sprite	| a x y
	;	

:+npc | x y --
	'npc 'obj p!+ >a
	swap a!+ a!+
	;	

	
|----- JUGAR
:jugar
	0 SDLcls
	immgui		| ini IMMGUI	

	inisprite
	'obj p.draw
	drawmaps

	SDLredraw
	teclado
	;
	
:reset
	'obj p.clear
	;
		
:juego
	inisprite
	
	reset
	130.0 300.0 +jugador
	300.0 200.0 +npc
	400.0 600.0 +npc
	'jugar SDLshow
	;	

:main
	"r3sdl" 1024 600 SDLinit
	"media/ttf/Roboto-Medium.ttf" 12 TTF_OpenFont immSDL
	"r3/itinerario/diciembre/escuela1.bmap" loadmap 
	32 32 "r3/itinerario/diciembre/protagonista.png" ssload 'sprplayer !
	200 'obj p.ini
	juego
	SDLquit
	;
	
: main ;